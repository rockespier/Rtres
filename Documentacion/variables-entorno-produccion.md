# Variables de entorno — Producción

La API (`src/api/Rtres.Api`) lee la configuración de `appsettings.json` y la sobrescribe con variables de entorno.
En variables de entorno, el `:` de la clave se escribe como doble guion bajo `__` (ej. `GitHub:Token` → `GitHub__Token`).

> `appsettings.{Entorno}.local.json` es solo para desarrollo. En producción todo va como variable de entorno (o secreto del orquestador), nunca en archivos del repo.

## Obligatorias

| Variable | Ejemplo / formato | Para qué |
|---|---|---|
| `ASPNETCORE_ENVIRONMENT` | `Production` | Desactiva OpenAPI y el seeder de datos de prueba. |
| `ConnectionStrings__SqlServer` | `Server=<host>,1433;Database=rtres;User Id=rtres_app;Password=<secreto>;Encrypt=True;TrustServerCertificate=True` | BD de la aplicación y de Hangfire (jobs). |
| `Jwt__Key` | `openssl rand -base64 48` | Firma de los tokens de sesión. Mínimo 32 bytes; la API no arranca sin ella. |
| `Frontend__PublicUrl` | `https://rtres.net` | Web pública: CORS y enlaces en emails. |
| `Frontend__PortalUrl` | `https://portal.rtres.net` | Portal de clientes: CORS, enlaces en emails y retorno de PayPal. |

## Correo (SMTP)

Si `Smtp__Host` está vacío, los emails **no se envían**: solo se escriben en el log.

| Variable | Ejemplo | Notas |
|---|---|---|
| `Smtp__Host` | `mail.rtres.net` | |
| `Smtp__Port` | `587` | Por defecto 587. |
| `Smtp__Security` | `StartTls` | `StartTls`, `SslOnConnect`, `Auto`, `None`. |
| `Smtp__User` | `notificaciones@rtres.net` | |
| `Smtp__Password` | `<secreto>` | |
| `Smtp__From` | `notificaciones@rtres.net` | Si falta, usa `Smtp__User`. |
| `Smtp__FromName` | `Rtres Web Solutions` | |
| `Notifications__StaffEmail` | `equipo@rtres.net` | Avisos internos (tickets sin GitHub, pedidos por transferencia). Si falta, usa `Smtp__From`. |

## PayPal

| Variable | Producción | Notas |
|---|---|---|
| `PayPal__BaseUrl` | `https://api-m.paypal.com/` | En dev es `https://api-m.sandbox.paypal.com/`. |
| `PayPal__ClientId` | `<client id live>` | Credenciales de la app **Live**, no sandbox. |
| `PayPal__Secret` | `<secreto>` | |
| `PayPal__WebhookId` | `<id del webhook live>` | Id del webhook creado en la app Live apuntando a `https://<api>/api/payments/webhooks/paypal`. |
| `BankTransfer__Instructions` | `BCP Soles 123-456-789 …` | Texto con las cuentas para pagar por transferencia. |

## GitHub (tickets ↔ issues)

Un token fine-grained solo cubre **un** resource owner (tu usuario o una organización). Se usa el token del owner del repo y, si no hay, el token por defecto.

| Variable | Ejemplo | Notas |
|---|---|---|
| `GitHub__Token` | `github_pat_…` | Token por defecto: repos de tu usuario (`rockespier`). |
| `GitHub__Tokens__<owner>` | `GitHub__Tokens__mi-organizacion=github_pat_…` | Una variable por organización. `<owner>` = valor de **Owner** del repo en el proyecto (no distingue mayúsculas). |
| `GitHub__WebhookSecret` | `openssl rand -hex 32` | Mismo valor que el *Secret* del webhook en GitHub (`https://<api>/api/webhooks/github`). |

Permisos de cada token: **Issues: Read and write** + **Contents: Read and write** (adjuntos de tickets, se suben a `.rtres/attachments/` del repo) + **Metadata: Read**, con el resource owner correcto. Caducan: anota las fechas de renovación.

Para que mover la tarjeta en un **GitHub Project** cambie el estado del ticket (job `github-project-status`, cada 5 min), el token también necesita leer proyectos:
- Organización: *Organization permissions* → **Projects: Read-only**.
- Proyectos de tu usuario: si el token fine-grained no ofrece el permiso de Projects, usa un token clásico con el scope `read:project` (más `repo`).

Columnas reconocidas del campo **Status** (sin importar mayúsculas ni tildes): Recibido/Todo → Abierto · En progreso/In Progress → En progreso · Resuelto/Done → Resuelto · Publicado → Publicado · Cerrado → Cerrado. Otras columnas no cambian el ticket.

## Otras

| Variable | Valor | Notas |
|---|---|---|
| `WordPress__BaseUrl` | `https://web.rtres.net/` | CMS del blog/contenido. Por defecto `https://cms.rtres.net/`. |
| `Jwt__Issuer` | `Rtres.Api` | Opcional; solo si se cambia. |
| `Jwt__Audience` | `Rtres.Web` | Opcional; solo si se cambia. |

## Frontend (no son variables de entorno)

Las apps Angular (`site` y `portal`) tienen la URL de la API **fija en build**:
`src/web/projects/*/src/environments/environment.ts` → `apiBaseUrl: 'http://localhost:5010/api'`.
Antes de compilar para producción hay que apuntarla a la API real (ej. `https://api.rtres.net/api`) o crear un `environment.prod.ts` con `fileReplacements`.

## Checklist antes de publicar

- [ ] Quitar de `appsettings.json` los secretos que hoy están commiteados (contraseña SQL, contraseña SMTP) y rotarlos.
- [ ] `Jwt__Key` nueva y distinta a la de desarrollo.
- [ ] PayPal en Live (`BaseUrl`, credenciales y webhook).
- [ ] Un `GitHub__Tokens__<owner>` por cada organización con repos de clientes.
- [ ] Webhook de GitHub configurado en cada repo/organización con el mismo `GitHub__WebhookSecret`.
- [ ] Panel de Hangfire (`/jobs`) no expuesto públicamente (por defecto solo acepta peticiones locales).
- [ ] `apiBaseUrl` del frontend apuntando a producción.
