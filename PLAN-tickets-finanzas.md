# Plan: tickets sin repositorio + carga financiera 2026 y reportes

Contexto para quien implemente: API .NET en `src/api` (EF Core + SQL Server, Hangfire), portal Angular en
`src/web/projects/portal`. Controladores clave: `PortalController.cs` (cliente), `AccountController.cs` (admin, rutas `/api/admin/*`).
Seguir el estilo existente (líneas largas, comentarios en español, DTOs anónimos). Cada fase con migración EF si toca esquema,
tests en `Rtres.Api.Tests` y `dotnet build` + `npx ng build portal` en verde.

---

## Parte 1 — Tickets en proyectos sin repositorio de GitHub

### Situación actual
- El cliente puede crear el ticket (`PortalController.CreateTicket`). `GitHubIssueSyncJob.CreateIssueAsync` detecta que el
  proyecto no tiene repo, deja un warning en el log y no hace nada más.
- El estado del ticket **solo cambia por el webhook de GitHub** (`GitHubWebhookProcessor`). Sin repo queda en `Abierto` para siempre.
- El SuperAdmin **no puede comentar** (`AddComment` → `Forbid()` si `IsSuperAdmin`) y no hay endpoint para cambiar el estado.
  Resultado: el ticket no tiene quién lo atienda desde el portal.

### Decisión
Modelo híbrido, decidido por proyecto:
- **Con repo** (hay código, deploys, GitHub Actions a QA): igual que hoy; GitHub es la fuente de verdad del estado.
- **Sin repo** (WordPress sin código propio, redes sociales, soporte): el ticket se gestiona 100 % en el portal.
- No se crean repos vacíos solo para tener issues. Si un proyecto pasa a tener código, se le asigna el repo y los tickets
  nuevos se sincronizan (los viejos pueden quedar solo en el portal).

### Tareas
1. **API admin de tickets** (`AccountController`, SuperAdmin):
   - `GET /api/admin/tickets?status=&clientId=&projectId=&page=`: bandeja de todos los tickets, ordenados por `UpdatedAt` desc.
     Cada uno con cliente, proyecto y `managedIn: "GitHub" | "Portal"` (según `HasRepo` del proyecto).
   - `PATCH /api/admin/tickets/{id}` `{ status }`: solo si el proyecto **no** tiene repo. Si tiene repo → 409 con el mensaje
     "El estado de este ticket se gestiona en GitHub".
   - `POST /api/admin/tickets/{id}/comments`: el SuperAdmin responde como "Rtres". Si el proyecto tiene repo, se encola
     `PostCommentAsync` igual que en los comentarios del cliente.
   - Extraer `HasRepo` de `GitHubIssueSyncJob` a una extensión de `Project` en el dominio y reutilizarla.
2. **Notificaciones**: cambio de estado o comentario de Rtres → correo al cliente, reutilizando el sistema de `Notifications`
   con `DedupeKey`. Ticket nuevo en proyecto sin repo → aviso a Rtres, porque no llegará ningún issue a GitHub.
3. **Portal**:
   - Nueva vista SuperAdmin "Tickets" en el menú, con filtros, chip "Portal"/"GitHub", selector de estado (deshabilitado
     si es GitHub) y respuesta.
   - Vista del cliente: si el ticket es de GitHub, mostrar el enlace al issue; si no, nada cambia.
4. **Tests**: cambio de estado en proyecto sin repo (OK), en proyecto con repo (409); comentario admin en proyecto con repo
   encola el job; el cliente no puede usar los endpoints admin.

---

## Parte 2 — Carga masiva 2026 y reportes de rentabilidad

### Situación actual
- **Ingresos**: `MonthlySalesAsync` suma `PaymentTransactions` (filtradas por `CreatedAt`) y `TaxDocuments` manuales
  (`PaymentTransactionId == null`, filtrados por `IssueDate`). Convierte a PEN con `AmountPen` o `RateToPenAsync`.
- `PaymentTransaction.ClientProductId` es **obligatorio**: no se puede registrar un ingreso (por ejemplo, una remesa del
  exterior por un desarrollo) sin un producto de cliente.
- **Gastos**: `Expense` con `AmountPen` e importación Excel (`/admin/expenses/import`). No existe la categoría de impuestos.
- **Reportes**: `reports/sales|tax-summary|expenses|net` son **solo mensuales**. No hay reporte por cliente.
- El impuesto en `reports/net` es una estimación: `ventas × RentaRate`. No considera impuestos realmente pagados ni
  retenciones de recibos por honorarios.
- Riesgo de **doble conteo**: una venta con `PaymentTransaction` y además un `TaxDocument` manual sin vincular se cuenta dos veces.

### Modelo propuesto
1. **`PaymentTransaction`** (migración):
   - `ClientId` (Guid, obligatorio, con backfill desde `ClientProduct`).
   - `ClientProductId` pasa a opcional.
   - `PaidAt` (DateOnly, fecha real del cobro; backfill = `CreatedAt`).
   - `Method` admite `Remesa` además de `PayPal` y `Transferencia`.
   - `Notes` (nullable).
   - Todos los reportes filtran por `PaidAt`, no por `CreatedAt`.
2. **Regla de ingresos (única fuente, sin doble conteo)**: un ingreso = una `PaymentTransaction`. El `TaxDocument` es el
   comprobante asociado (`PaymentTransactionId`), no un ingreso aparte.
   - Migración de datos: por cada `TaxDocument` manual sin transacción, crear su `PaymentTransaction`
     (`Method = Transferencia`, monto = total, `PaidAt = IssueDate`) y vincularla.
   - Luego simplificar `MonthlySalesAsync` para que lea solo transacciones.
3. **`ExpenseCategory.Impuestos`** (pagos a SUNAT: Renta mensual, IGV neto, etc.) y **`ExpenseCategory.Comisiones`**
   (PayPal, bancos, remesadoras). Para el reporte, los impuestos se separan de los gastos operativos.
4. **Retención de recibos por honorarios**: nuevo campo `TaxDocument.RetentionAmount` (nullable). Cuando el cliente
   retiene el 8 %, cuenta como impuesto ya pagado.

### Carga masiva SQL (`infrastructure/sql/carga-transacciones-2026.sql`)
Mismo patrón que `carga-inicial-suscripciones.sql`: tabla variable a completar, validación "todo o nada", reejecutable
(sin duplicar), `SET DATEFORMAT dmy`, resumen al final.
- **Bloque Ingresos**, una fila por cobro: `ClienteEmail`, `Fecha`, `Tipo` (`Factura` | `ReciboHonorarios` | `Remesa` | `SinComprobante`),
  `Moneda`, `MontoTotal` (con IGV si es Factura), `TipoCambio` (opcional; si falta, se toma `ExchangeRates` de esa fecha
  y, si tampoco existe, error), `Serie`, `Numero` (obligatorios para Factura/RH), `Retencion` (RH, opcional),
  `Producto`/`Proyecto` (opcionales), `Referencia` (N° de operación).
  - Crea la `PaymentTransaction` (`AmountPen = MontoTotal × TC`). Para Factura/RH también crea el `TaxDocument` con el
    desglose base/IGV según `TaxSettings.IgvRate`.
  - Clave de idempotencia: (`ClientId`, `Fecha`, `MontoTotal`, `Referencia`) o, en comprobantes, (`Serie`, `Numero`).
  - Los comprobantes importados **no** deben mover el correlativo automático de `TaxDocumentService`. Verificar cómo lo
    calcula; si usa `MAX(Number)`, documentarlo o reservar series distintas.
- **Bloque Gastos**: `Fecha`, `Descripcion`, `Categoria`, `Tipo` (Fijo/Variable), `Moneda`, `Monto`, `TipoCambio`
  (opcional). Idempotencia: (`Fecha`, `Descripcion`, `Monto`). Se puede usar esto o la importación Excel existente.
- Los montos en PEN se guardan con el tipo de cambio del día de la operación: los reportes no recalculan con el TC de hoy.

### Reportes
Todos los endpoints de reportes aceptan un rango: `from`/`to` (DateOnly), o `year` + `month` opcional. Sin `month`, el
periodo es el año completo. Mantener compatibilidad con `month` + `year`.
1. **`GET /api/admin/reports/clients?from&to`**, ranking de clientes: ingresos sin IGV en PEN, % del total, % acumulado
   (Pareto), N° de cobros, fecha del último cobro, variación contra el periodo anterior de igual duración.
2. **`GET /api/admin/reports/net?from&to`** (ampliado):
   - ventas sin IGV
   - − gastos operativos (sin Impuestos)
   - = utilidad operativa
   - − impuestos: se muestran los **pagados** (categoría Impuestos + retenciones de RH) y los **estimados**
     (`RentaRate` × base); `impuestosUsados` indica cuáles se restaron (pagados si existen en el periodo, si no, estimados)
   - = **utilidad neta**
   - margen %
   - serie mensual (12 puntos si el periodo es un año) para el gráfico
3. **Portal** (`/admin/reports`):
   - Selector "Mes / Año".
   - Tarjetas: Ingresos, Gastos, Impuestos, Utilidad neta y margen.
   - Gráfico mensual de ingresos contra gastos y utilidad.
   - Tabla "Clientes que más aportan" con barra de %; al hacer clic se abre el detalle del cliente.
   - Exportar a Excel (reutilizar la librería de las plantillas de importación).
   - Mantener el aviso `TaxDisclaimer`.

### Tests
- Doble conteo: un comprobante vinculado a su transacción se suma una sola vez.
- Remesa sin producto cuenta en el ranking del cliente.
- El rango anual es igual a la suma de los 12 meses.
- La utilidad neta usa impuestos pagados cuando existen y estimados cuando no.
- El script SQL es reejecutable (segunda corrida: 0 insertados).

---

## Orden sugerido
1. Parte 1 completa (independiente y pequeña).
2. Parte 2: migración del modelo y datos, luego endpoints de reportes, luego portal, y al final el script SQL
   (depende del esquema final).

## Fuera de alcance
Declaraciones ante SUNAT, facturación electrónica real y conciliación bancaria automática.
