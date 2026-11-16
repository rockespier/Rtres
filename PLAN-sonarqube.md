# Plan SonarQube — issues MAJOR, CRITICAL y BLOCKER

**Fecha:** 13 de noviembre de 2026. **Origen:** `documentacion/sonarcloud_issues_open.xlsx` (4293 issues abiertos; 1957 MAJOR/CRITICAL/BLOCKER).

### Alcance
| Zona | Issues M/C/B | Tratamiento |
|---|---|---|
| `plantillaElementor/` (tema WP de terceros) | 1458 | Excluir |
| `infrastructure/sql/` (scripts de carga) | 133 | Excluir (revisar a mano el BLOCKER de `series-comprobantes.sql`) |
| `mockups/` | 58 | Excluir |
| filas sin componente en el export (pertenecen a la plantilla) | 80 | Desaparecen con la exclusión |
| `src/api/**` | 104 | Corregir |
| `src/web/projects/**` | 120 | Corregir |
| `factory/`, `scripts/` | 30 | Corregir |

Nota: las líneas del export pueden estar desfasadas respecto al código actual; localizar por mensaje + archivo.

### Fase 0 — Secretos expuestos (urgente, antes que todo)
- `src/api/Rtres.Api/appsettings.json`: contraseña de SQL Server (IP pública) y contraseña SMTP en claro (BLOCKER + 3 VULN). Vaciar los valores en el repo; moverlos a `appsettings.Development.local.json` (gitignored) y variables de entorno en producción (`scripts/Set-ApiEnvironment.ps1`, `documentacion/variables-entorno-produccion.md`).
- `scripts/SonarIssues.ps1`: token de SonarCloud en claro (no lo marca Sonar). Leerlo de `$env:SONAR_TOKEN`.
- **Rotar** las tres credenciales (DB `rtres_app`, buzón SMTP, token Sonar): siguen en el historial de git. Acción manual del usuario.
- `Services/JwtSettings.cs:21` (BLOCKER "JWT secret"): ya lee la clave de config y valida longitud/valor de ejemplo → probable falso positivo; verificar que no hay `Jwt:Key` en ningún appsettings versionado y marcar como "Safe" en SonarCloud.

### Fase 1 — Exclusiones
- Crear `.sonarcloud.properties` en la raíz:
  `sonar.exclusions=plantillaElementor/**,mockups/**,infrastructure/sql/**,coveragereport/**,inspiracion/**,output/**,publish/**,.worktrees/**`
- `infrastructure/sql/series-comprobantes.sql:12` (UPDATE sin WHERE): es intencional (tabla de una fila) pero añadir `WHERE Id = (SELECT TOP 1 Id FROM TaxSettings)` para dejarlo explícito.

### Fase 2 — BLOCKER restantes
- Portal, `@Output() close` choca con evento DOM (4): `client-form-dialog`, `client-product-assign-dialog`, `import-dialog`, `product-form-dialog` → renombrar a `closed` (patrón ya usado en `team-invite-dialog`) y actualizar `(close)=` en los padres.
- `subscribe-dialog.component.ts`: implementar `OnInit`.
- `site/.../resources-page.component.ts:132` `bypassSecurityTrustResourceUrl`: el id ya va con `encodeURIComponent` y dominio fijo → validar id con `/^[\w-]{11}$/` antes y marcar "Safe".

### Fase 3 — CRITICAL (código propio)
- Complejidad cognitiva >15 (14 métodos): extraer métodos privados sin cambiar comportamiento. API: `AccountController` (L114, 175, 291, 644), `AdminController.AnnualTax` L42, `AdminController.Purchases` L121, `BankTransfersController` L115, `PaymentsController` L37/L149, `TaxDocumentService` L43, `IntegrationClients` L284, `EmailTemplates` L29. Web: `notification-bell` L15, `site/core/seo.service.ts` L65. Factory: `dashboard.html` L603.
- Bucles `for` raros: `PaymentsController.cs:74` y `TaxDocumentService.cs:45` → reescribir como `while` legible.
- `RtresDbContext.cs:12`: renombrar parámetro `b` → `modelBuilder`.
- `learning-videos.component.ts:99`: `sort()` con `localeCompare`.

### Fase 4 — MAJOR por patrón (en lotes por regla)
| Regla | Cant. | Arreglo |
|---|---|---|
| Value type en input de controller sin `required`/nullable | ~38 | `required` en los records de `Contracts.cs` y DTOs de controllers (Account, Purchases, BankTransfers, TaxCalendar, Payments, Categories, AnnualTax) |
| Ternarios anidados | ~35 | Extraer a `if`/`switch` o función |
| `readonly` en miembros (TS) | ~45 | Añadir `readonly` a los `inject()` y campos no reasignados |
| Promesas sin manejar (`router.navigate`, `bootstrapApplication`) | ~15 | `void` delante o `.catch(console.error)` en `main.ts` |
| Regex con backtracking | 6 | `contact-form`, `lang-links`, `seo.service`, `site-paths`, `factory/dashboard.html` |
| Format provider en parse de fechas | 8 | `CultureInfo.InvariantCulture` (`Entities.cs:248`, `AdminController.Purchases.cs:139`) |
| Nullable en `EmailSenders.cs` | 4 | Validar settings SMTP al construir el sender |
| `new Guid()` en migraciones | 3 | `Guid.Empty` (solo texto, no altera la BD) |
| CSS: selectores duplicados, `!important`, reduced-motion | ~10 | `portal/styles.css`, `site/styles.css` |
| Resto (Program.cs RunAsync/static, RouteAttribute, model binding en webhook, request size en `PortalController:103`, `.dataset`, nested templates, parámetros >7, test bloqueante, checks.sh `[[` y `--ignore-scripts`) | ~30 | Uno a uno |

`PortalController.cs:103`: añadir `[RequestSizeLimit]` acorde al nginx (60 MB).

### Commits / PRs
Un PR por fase (0-1, 2, 3, 4 dividida por API / portal / site+factory). Comentarios en español.

### Verificación
- `bash factory/checks.sh` (build + tests API, build portal y site) en cada PR.
- `npx ng serve site` para revisar páginas tocadas; portal se verifica leyendo código (requiere API).
- Tras merge, re-ejecutar `scripts/SonarIssues.ps1` y comprobar: 0 BLOCKER/CRITICAL, MAJOR solo los marcados "Safe/Won't fix" con justificación.

