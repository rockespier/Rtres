# Plan — Mejoras del Site y Registro de compras (crédito fiscal IGV) en el Portal

## Contexto
El site público (Angular SSR, ES/EN/IT) hoy es **una sola página** (`pages/home/home-page.component.ts` + `components/home/*`): el menú apunta a anclas que no existen (`#sectores`, `#nosotros`, `#recursos`), los 4 servicios y los 2 casos no tienen página propia, los testimonios son 2 fijos y el pie usa el logo para fondo blanco. Se quiere convertirlo en un sitio multipágina con contenido real (fuente: `Documentacion/Casos de exito Rtres.docx`, `Carta presentacion.docx`, `Opiniones.docx`).
En el portal, los gastos no distinguen comprobantes: no se puede calcular el **crédito fiscal** del IGV de las compras, así que el reporte muestra solo el IGV de ventas (débito) y sobreestima el IGV a pagar.

Decisiones tomadas: pie **lima `--v2-lime` + logo en una tinta oscura**; videos de Recursos **administrados desde el portal**; páginas **directo en Angular** sobre el sistema v2 (plantilla → revisión → replicar); compras como **módulo separado** de Gastos (con opción de generar el gasto vinculado para no registrar dos veces).

---

## Parte A — Site

### A1. Estructura multipágina (base de todo lo demás)
- Nuevo `SiteLayoutComponent` (top-bar + header fijo + `<router-outlet>` + footer) en `projects/site/src/app/layout/`. `HomeHeroComponent` deja de incluir top-bar/header (hoy los embebe).
- `site.routes.ts`: rutas hijas del layout —
  `''` home · `servicios/software-a-medida` · `servicios/apps-y-experiencias-web` · `servicios/integracion-y-automatizacion` · `servicios/hosting-dominios-y-soporte` · `casos/euroamerican-assistance` · `casos/grupo-crosland` · `nosotros` · `recursos`. Se mantiene `:lang`. Slugs en español en los 3 idiomas (los locales ya van en el prefijo `/es|/en|/it`).
- Enlaces: anclas `#x` → `routerLink="/" fragment="x"`; activar `withInMemoryScrolling({ anchorScrolling:'enabled', scrollPositionRestoration:'top' })`.
- SEO por página: `Title` + `Meta` (description) con textos `$localize`.
- Prerender: las rutas estáticas se descubren solas; `recursos` se excluye del prerender (contenido vivo desde el API) o se refresca en cliente.

### A2. Header fijo (punto 5)
- `site-header.component.ts`: `position:sticky; top:0` con fondo blanco, borde/sombra al hacer scroll (listener solo en navegador), altura 72px compacta al bajar.
- Menú: "Soluciones ⌄" despliega los 4 servicios; "Casos de éxito ⌄" los 2 casos; "Nosotros" → `/nosotros`; "Recursos" → `/recursos`. "Sectores" se quita (no hay sección ni página).
- Móvil (<850px): hoy el nav desaparece sin alternativa → botón hamburguesa + panel (reusar/adaptar `components/mobile-menu`).

### A3. Páginas de servicio (puntos 1–4) — una plantilla, 4 configuraciones
- `pages/service/service-page.component.ts` + `service-content.ts` (datos por slug, textos `$localize` con ids `@@service.<slug>.*`).
- Secciones (patrón editorial v2, sin rejillas de tarjetas): hero con título sobredimensionado + foto duotono · "El problema" (1 párrafo) · "Qué construimos" como filas numeradas (`01 / 02 …`, mismo estilo que `services.component.ts`) · entregables y tecnologías (lista en 2 columnas) · caso relacionado (enlace a la página del caso) · banda lima de CTA → contacto.
- Contenido base: Software a medida (sistemas de ventas/comisiones/BI, DMS), Apps y experiencias web (sitios, portales, e-commerce), Integración y automatización (SAP, facturación electrónica SUNAT, inventario), Hosting, dominios y soporte (hosting, dominios, SSL, backups, soporte con tickets en el portal).
- La lista de `services.component.ts` en home enlaza a cada página.

### A4. Páginas de caso (puntos 6–7) — plantilla + 2 configuraciones
- `pages/case/case-page.component.ts` + `case-content.ts`.
- Secciones: sector · cliente y descripción · cifra destacada ("Desde 2008", "+300 talleres Bajaj") · El desafío · Nuestra solución (filas numeradas; Crosland separado en "Taller Kawasaki" y "Red Bajaj") · Integraciones (SAP, facturación) · Impacto · testimonio (EUA: Erick Weston) · CTA.
- Las tarjetas de `success-cases.component.ts` enlazan a su página.

### A5. Testimonios en carrusel (punto 8)
- `support.component.ts`: los 7 testimonios de `Opiniones.docx` (texto completo, traducidos EN/IT). **Christian Falcon y José Antonio Mujica tienen el mismo texto** — se usa uno salvo que se indique otra cosa.
- 2 visibles en escritorio / 1 en móvil; botones anterior/siguiente + puntos; autoavance cada 7 s solo en navegador (`afterNextRender`), pausado al pasar el mouse/foco y desactivado con `prefers-reduced-motion`; `aria-live="polite"` y `aria-roledescription="carrusel"`.

### A6. Imagen en Contacto (punto 10)
- `contact.component.ts` a 2 columnas: texto/CTA a la izquierda, foto a la derecha (duotono a la paleta, 100% alto de la sección, oculta o arriba en móvil). Foto de stock con licencia libre (Unsplash) en `assets/`, reemplazable.

### A7. Pie lima + logo oscuro (punto 11)
- Generar `assets/logo-rtres-dark.png` desde `assets/logo-rtres.png` (Python/Pillow: todo píxel no transparente → `#141414`, conservando alfa).
- `site-footer.component.ts`: fondo `var(--v2-lime)`, texto `--v2-ink`, enlaces a las nuevas rutas, verificación de contraste AA de textos secundarios sobre lima.

### A8. Quiénes somos (punto 12)
- `pages/about/about-page.component.ts`: historia (fundada en 2007, Lima, operación en España e Italia) · filosofía (relaciones largas, "no desaparecemos al entregar") · cifras (desde 2007, clientes desde 2008, +300 talleres) · marcas con las que trabajamos (Kawasaki, Bajaj, Euroamerican Assistance, Travel Solutions Assistance, SOS 24, Building Connections…) · cómo trabajamos (fases) · CTA.

### A9. Recursos con videos (punto 13)
- **API**: entidad `LearningVideo` (Id, Title, YoutubeId, Category, Language `es|en|it|null=todos`, Description?, SortOrder, IsPublished) + migración. Admin CRUD en `/api/admin/learning-videos` (acepta URL de YouTube y extrae el id; valida). Público: `GET /api/public/{locale}/videos` en `PublicContentController` (solo publicados, del idioma o "todos").
- **Portal**: página admin "Recursos" (lista, agregar con URL, editar, ordenar, publicar/ocultar), entrada en `core/nav.ts`.
- **Site**: `pages/resources/resources-page.component.ts` vía `public-api.service.ts`; filtro por categoría (Marca personal, Disciplina y hábitos, Negocios, Tecnología…); embed liviano (miniatura → iframe `youtube-nocookie.com` al hacer clic).
- Solo se embeben videos públicos que elijas (no se descargan ni se re-suben).

### A10. Traducciones
- Todo texto nuevo con ids `@@…`; `ng extract-i18n` y completar `messages.en.xlf` / `messages.it.xlf` (redacción EN/IT a cargo nuestro, revisable).

---

## Parte B — Portal: Registro de compras y crédito fiscal

### Cómo funciona en SUNAT (resumen de la investigación)
- **IGV a pagar del mes = débito fiscal (IGV de ventas) − crédito fiscal (IGV de compras) − saldo a favor del mes anterior.** Si el resultado es negativo, es saldo a favor y se arrastra al mes siguiente.
- Requisitos del crédito fiscal: comprobante que **discrimine el IGV** (factura, nota de débito/crédito, DUA; **no** boletas ni recibos por honorarios), que la compra sea **costo o gasto deducible** para Renta y esté destinada a operaciones gravadas, y que esté **anotada en el Registro de Compras (SIRE)**.
- Plazo de anotación (D. Leg. 1669, set-2024, eliminó los 12 meses): comprobante **electrónico → en el periodo de su emisión** (o del pago del IGV); no electrónico → hasta 2 meses después; con detracción → hasta 3 meses.
- MYPE: el pago a cuenta mensual de Renta (1%) es sobre ingresos — las compras **no** lo reducen, pero sí reducen la Renta anual como gasto deducible.

### B1. Modelo
- Nueva entidad `Purchase`: IssueDate, Period (año-mes de anotación, por defecto el de emisión), DocumentType (Factura, NotaCredito, NotaDebito, Boleta, ReciboPorHonorarios, Extranjero, Otro), Series, Number, SupplierTaxId (RUC u otro), SupplierName, Currency, TaxBase, Igv, NonTaxable (inafecto/exonerado), Total, BasePen/IgvPen (snapshot con `RateToPenAsync`), `GivesTaxCredit` (true solo si el tipo lo permite e IGV > 0; desmarcable si no se destina a operaciones gravadas), ExpenseId? (gasto vinculado), Notes. Índice único (SupplierTaxId, DocumentType, Series, Number). Notas de crédito restan.
- Validaciones: RUC de 11 dígitos para comprobantes peruanos; Base + IGV + NoGravado = Total (tolerancia 0.01); IGV ≈ 18% de la base (aviso, no bloqueo).

### B2. Evitar doble registro
- Al crear una compra: casilla **"Registrar también como gasto"** (por defecto activa) → crea el `Expense` vinculado con categoría elegida y monto = **base** si da crédito fiscal (el IGV recuperable no es costo) o **total** si no. Editar/eliminar la compra actualiza/ofrece eliminar el gasto vinculado.

### B3. API y pantallas
- `PurchasesController` (`/api/admin/purchases`): listar por periodo, crear, editar, eliminar; importar Excel (plantilla con valores válidos, mismo patrón `CreateWorkbook`/`Import` de `AccountController`).
- Portal: nueva página **Compras** (sección Finanzas en `core/nav.ts`): resumen del periodo (compras, IGV crédito fiscal, IGV sin derecho), tabla ordenable con filtro de mes, diálogo de registro (tipo, RUC, serie-número, montos con cálculo automático de IGV/total), importación Excel. Formato de montos con `money` pipe.

### B4. Reporte de IGV
- Ampliar el endpoint de impuestos de `AccountController` (hoy `igvEstimado` = solo débito, ~línea 385) con: `debitoFiscal`, `creditoFiscal`, `saldoAFavorAnterior`, `igvAPagar` o `saldoAFavorSiguiente`, calculado mes a mes desde el primer mes con datos.
- `reports.component.ts`: bloque "IGV del periodo" con esa cascada y el aviso existente (`TaxDisclaimer`: estimación, no liquidación oficial).

### B5. Sugerencias (no incluidas en este plan; para decidir después)
1. **Importar la propuesta del Registro de Compras del SIRE** (archivo que SUNAT arma con tus facturas electrónicas recibidas) → carga automática de compras. Hay que verificar el formato real del archivo antes de diseñarlo.
2. **Utilización de servicios de no domiciliados** (Claude, GitHub, hosting extranjero): como empresa domiciliada, el IGV de esos servicios se paga con el Formulario 1662 y luego es crédito fiscal. Hoy esos pagos son gastos sin IGV; convendría marcarlos y calcular el IGV a pagar y su crédito. **Confirmar con tu contador** antes de implementarlo.
3. **Exportación de servicios**: las ventas a clientes del exterior (USD/EUR) van sin IGV; el IGV de las compras destinadas a esas ventas puede recuperarse como saldo a favor del exportador (requiere estar inscrito en el registro de exportadores de servicios). Reporte que separe crédito fiscal atribuible a ventas gravadas vs exportaciones.
4. **Calendario de vencimientos SUNAT** según el último dígito del RUC, con recordatorio por correo (job Hangfire existente).
5. **Estimación de Renta anual** (ya registrada como objetivo): ingresos − gastos deducibles (incluidas las compras) → Renta MYPE (10% hasta 15 UIT, 29.5% el exceso) − pagos a cuenta − retenciones.

---

## Orden de ejecución
1. A1 + A2 + A7 (layout, header fijo, pie) → revisión rápida.
2. A3 (plantilla con "Software a medida") → **revisión del diseño** → resto de servicios.
3. A4 (plantilla con EUA) → revisión → Crosland.
4. A5, A6, A8.
5. A9 (API + portal + site).
6. A10 traducciones.
7. Parte B (B1–B4).

## Archivos principales
- Site: `projects/site/src/app/site.routes.ts`, `app.config.ts`, `components/home/{site-header,hero,services,success-cases,support,contact,site-footer}.component.ts`, nuevos `layout/`, `pages/{service,case,about,resources}/`, `core/public-api.service.ts`, `styles.css` (tokens `--v2-*`), `locale/messages.*.xlf`.
- API: `Rtres.Domain/Entities.cs` (`LearningVideo`, `Purchase`), `RtresDbContext.cs`, `Controllers/PublicContentController.cs`, nuevos `Controllers/{LearningVideosController,PurchasesController}.cs`, `Controllers/AccountController.cs` (reporte IGV), migraciones.
- Portal: `core/nav.ts`, `core/portal-api.service.ts`, nuevos `components/{learning-videos,purchases}/`, `components/reports/reports.component.ts`.

## Verificación
- `dotnet test Rtres.Api.Tests`: tests nuevos para videos (extracción de id de YouTube, filtro público por idioma/publicado), compras (validaciones, unicidad, gasto vinculado con base vs total, notas de crédito) y la cascada de IGV con arrastre de saldo a favor entre meses.
- `ng build site` (prerender de las nuevas rutas en es/en/it, sin ids i18n faltantes) y `npm run serve:ssr:site`: recorrer cada página en los 3 idiomas en el navegador, header fijo al hacer scroll, menú móvil, carrusel (teclado, pausa, reduced-motion), anclas desde páginas internas, contraste del pie.
- Móvil con el truco del iframe de 390px (el `resize_window` no cambia el viewport en esta sesión).
- `ng build portal` + prueba en navegador de Recursos admin y Compras (registro, gasto vinculado, reporte IGV).
- Migraciones: revisar `defaultValue` generados antes de aplicarlas a `rtres_dev`.
