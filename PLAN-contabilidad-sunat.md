# Plan — Contabilidad SUNAT: SIRE, Formulario 1662 y Renta anual

## Contexto
Sigue a la Parte B de `PLAN-site-y-compras.md` (sugerencias B5). Respuestas del contador en `Documentacion/Confirmacion_de_mi_contador.md`:
- **SIRE (Registro de Compras):** sí. Entregó `Documentacion/compras/20517137881-20261007-0334-resumen.xlsx`.
- **Formulario 1662 (IGV por servicios de no domiciliados):** sí, un formulario por pago, tributo **1041**, periodo = mes del pago, **18 %** del valor al **tipo de cambio venta del día del pago**. Proveedores actuales: OpenAI OpCo LLC (EE. UU.), Anthropic PBC (EE. UU.), Google LLC / Google Ireland Ltd.
- **Saldo a favor del exportador:** no se implementa.
- **Renta anual (Régimen MYPE Tributario):** utilidad neta = ventas sin IGV − gastos deducibles; **10 % hasta 15 UIT y 29.5 % sobre el exceso**, con la UIT del año; menos los pagos a cuenta mensuales (1 % o 1.5 %). Si se pagó de más, queda saldo a favor.

Hallazgos al revisar el código y los archivos:
- El archivo del SIRE es el **resumen por tipo de comprobante** (11 facturas: BI gravado 93.22, IGV 16.78, no gravado 3,121.07, total 3,231.07). **No trae una fila por factura**, así que con él no se pueden crear compras; solo sirve para **cuadrar** el periodo. Para importar hace falta el **detalle** de la propuesta (ver C1).
- El nombre del archivo trae el RUC de Rtres, **20517137881**: termina en 1, así que en el calendario de vencimientos le corresponde la columna del dígito 1. Hoy `TaxSettings.Ruc` está vacío en desarrollo.
- El tipo de cambio USD que ya se guarda es el **venta de SUNAT** (`ExchangeRateClient`). Es el que pide el 1662, así que no hace falta otra fuente.
- Los pagos a cuenta de Renta hoy son **solo estimados** (`TaxSettings.RentaRate` × ventas del mes); no se guarda lo realmente pagado.
- Las cuotas "Fracc SUNAT", "Préstamo SUNAT", "PDT" y "Deuda Leslie…" están en la categoría `Otros`, que cuenta como gasto operativo. En la Renta anual **no son deducibles**: son pago de deuda, no gasto. Hay que excluirlas sin recategorizarlas (ver C3).

---

## C1. Importar compras del SIRE
**Fase 1 — Cuadre con el resumen (con el archivo que ya tenemos).**
- En Compras, la opción "Cuadrar con SIRE" sube el `*-resumen.xlsx` y elige el periodo.
- La pantalla compara cada tipo de comprobante (cantidad, BI gravado, IGV, no gravado, total) con las compras anotadas en el portal para ese periodo. Las diferencias se marcan en rojo, por ejemplo "SIRE: 11 facturas / Portal: 9".
- Solo lee el archivo; no crea ni modifica compras.
- Se valida que el RUC del nombre del archivo sea el de `TaxSettings.Ruc`.

**Fase 2 — Importar el detalle (pendiente de recibir el archivo).**
- Desde SIRE → Registro de Compras → Propuesta → **Descargar propuesta** (TXT o Excel de detalle), que trae una fila por comprobante con RUC del proveedor, serie, número, fecha, BI, IGV y total.
- Cada fila crea un `Purchase` con el mismo modelo y las mismas validaciones que la importación de Excel actual. Los duplicados (mismo RUC + tipo + serie + número) se omiten y se informan.
- Se pide el archivo antes de programar: **no se asume el formato**.

## C2. Formulario 1662 (servicios de no domiciliados)
- **Modelo:** el gasto (`Expense`) gana estos campos:
  - `IsNonDomiciledService` (bool)
  - `ForeignSupplierName` (por ejemplo "Anthropic PBC")
  - `ForeignSupplierCountry`

  Los gastos recurrentes que genera `RecurringExpenseJob` heredan esos datos del gasto origen. Se precargan los 3 proveedores del contador como sugerencias.
- **Cálculo por pago:**
  - Base en soles = monto × TC venta SUNAT del día del pago. El TC ya está en `ExchangeRates`; si falta el de ese día, se usa el más cercano y se avisa.
  - IGV 1662 = 18 % de esa base, con la tasa de `TaxSettings.IgvRate`.
- **Pantalla "Formulario 1662"** (Finanzas):
  - Por periodo, una fila por pago: fecha, proveedor, país, monto en USD, TC, base en soles, **IGV a pagar** y la marca "Pagado" con fecha y N° de orden.
  - Total del mes y un recordatorio de los datos del formulario (tributo 1041, periodo MM/AAAA).
- **Calendario SUNAT:** se agrega en "Vencimientos SUNAT" el aviso "Tienes N pagos de 1662 sin marcar este mes", para que no se olviden.
- **Crédito fiscal (decisión pendiente, ver Preguntas):** el IGV pagado por 1662 suele poder usarse como crédito fiscal en el mes en que se paga, si el servicio se usa para operaciones gravadas. Como la mayoría de las ventas de Rtres son al exterior sin IGV, el uso del crédito depende del contador. Propuesta: un ajuste en Configuración "Usar el IGV del 1662 como crédito fiscal", **apagado por defecto**. Encendido, suma a la cascada de IGV de Reportes.

## C3. Estimación de Renta anual (MYPE)
- **Configuración por año:**
  - `UIT` del ejercicio (la ingresas tú; no se asume el valor).
  - Tasas por tramo: 10 % hasta 15 UIT y 29.5 % sobre el exceso, editables.
  - Coeficiente del pago a cuenta (1 % / 1.5 %), con aviso si las ventas acumuladas superan el umbral que indique el contador.
- **Gastos deducibles:**
  - Cada categoría de gasto gana el campo `IsDeductible`, verdadero por defecto. Las de impuesto a la Renta (`IsIncomeTax`) nunca son deducibles.
  - Cada gasto gana "**No deducible para Renta**", para casos puntuales como las cuotas de SUNAT y el préstamo, sin sacarlos de `Otros`.
  - Al migrar se proponen como no deducibles los gastos cuya descripción empiece con "Fracc SUNAT", "Prestamo SUNAT", "PDT" o "Deuda Leslie". Antes de aplicarlo se muestra la lista para que la confirmes.
  - Las compras con gasto vinculado ya cuentan por ese gasto; no se suman dos veces.
- **Pagos a cuenta reales:** al marcar un periodo como presentado en "Vencimientos SUNAT" se piden los montos pagados (IGV, Renta pago a cuenta y 1662). Si falta algún mes, el anual usa el estimado de ese mes y lo marca como "estimado".
- **Retenciones:** se restan las retenciones de los recibos por honorarios (`TaxDocument.RetentionAmount`).
- **Reporte "Renta anual"** (Reportes, por año), en el estilo de `admin/reports`:
  1. Ventas sin IGV
  2. − Gastos deducibles
  3. = Utilidad neta (renta neta imponible)
  4. Impuesto por tramos (detallado: hasta 15 UIT × 10 % y exceso × 29.5 %)
  5. − Pagos a cuenta
  6. − Retenciones
  7. = **Saldo a pagar o a favor**

  Además, una **proyección al cierre**: los meses que faltan se estiman con el promedio de los meses cerrados. Lleva el aviso de "estimación, no liquidación oficial".
- Cumple lo pedido en el objetivo guardado: preparar la declaración anual y estimar la deuda con SUNAT a fin de año.

## Orden de ejecución
1. C3 (Renta anual) y el registro de pagos reales en el calendario: es lo de más valor para el cierre del año.
2. C2 (1662): primero el modelo y el cálculo; el crédito fiscal según la respuesta del contador.
3. C1 Fase 1 (cuadre con el resumen) y Fase 2 cuando llegue el archivo de detalle.

## Archivos principales
- API: `Rtres.Domain/Entities.cs` (`Expense`, `ExpenseCategory`, `TaxSettings`, `TaxDueDate`, nuevo `AnnualTaxSettings`), `Controllers/AccountController.cs` (reportes) o un nuevo `Controllers/AnnualTaxController.cs`, `Controllers/AdminController.Purchases.cs` (cuadre SIRE), `Jobs/RecurringExpenseJob.cs` (heredar datos del 1662), migraciones.
- Portal: `components/expenses` (campos 1662 y "no deducible"), nueva `components/form-1662`, `components/reports` (pestaña Renta anual), `components/tax-calendar` (montos pagados), `components/purchases` (cuadre SIRE), `components/tax-settings` (UIT y tasas), `core/nav.ts`.

## Verificación
- Tests: tramos MYPE con los dos casos del contador (S/ 50,000 → S/ 5,000; S/ 100,000 con UIT 5,150 → S/ 14,436.25); exclusión de no deducibles e `IsIncomeTax`; pagos a cuenta reales frente a estimados; IGV del 1662 con el TC del día y el fallback al más cercano; herencia en gastos recurrentes; cuadre del resumen SIRE contra compras (incluido el archivo real de `Documentacion/compras`).
- Migraciones: revisar los `defaultValue` de `IsDeductible` (debe ser **true**) antes de aplicar.
- `ng build portal` y prueba en navegador de cada pantalla, con los importes en el formato del `money` pipe y tablas ordenables.

## Decisiones (respuestas del 2026-10-12)
1. **1662 como crédito fiscal:** sí, al 100 %, pero solo contra el IGV de las ventas gravadas. La cascada de IGV ya lo limita: el crédito no genera devolución y el exceso pasa como saldo a favor al mes siguiente. Hoy todavía **no** se declara el 1662 ni se anotan las invoices del exterior en el Registro de Compras, así que el ajuste queda **apagado por defecto** y se enciende cuando empiece a declararse.
2. **No deducibles:** "Fracc SUNAT", "Préstamo SUNAT", "PDT" y "Deuda Leslie" no se restan; no hay otros.
3. **UIT 2026 = S/ 5,500**, coeficiente del pago a cuenta **1 %**.
4. **Detalle del SIRE:** se deja para el final; el usuario avisará cuando los archivos estén en `Documentacion/compras/`.
5. **De quién es cada ingreso:**
   - De la MYPE: facturas y cobros **sin comprobante** (código interno).
   - Del usuario como persona natural (4ta categoría): **recibos por honorarios**. No entran en la Renta MYPE ni en su pago a cuenta del 1 %, que hoy se calcula sobre todas las ventas. Se muestran aparte, como información, junto con sus retenciones.
6. **Gastos:** todos son de la MYPE, salvo los marcados como no deducibles.
