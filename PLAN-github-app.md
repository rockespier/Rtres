# Plan (futuro): pasar la integración con GitHub a una GitHub App

Estado: pendiente, sin fecha. No bloquea nada; hoy funciona con tokens fine-grained.

## Situación actual

- La API crea issues, sube adjuntos (rama de adjuntos) y publica comentarios con un token fine-grained por dueño:
  `GitHub:Tokens:{owner}` o, si no hay, `GitHub:Token` (`GitHubIssuesClient.TokenFor` en
  `src/api/Rtres.Infrastructure/IntegrationClients.cs`).
- Problemas:
  - Los tokens vencen (el de `rockespier` vence el 25/12/2026): hay que regenerarlos y recargarlos en el pool a mano.
  - Cada dueño nuevo (una organización de un cliente) necesita su propio token.
  - Los comentarios del portal salen firmados con el usuario personal; se distinguen solo por la marca
    `PortalCommentMarker`.
  - En repos de un usuario (no organización) el webhook se configura repo por repo.

## Propuesta

Crear una GitHub App "Rtres" e instalarla en `rockespier` y en las organizaciones de los clientes.

- **Permisos de repositorio:** Issues (lectura y escritura), Contents (lectura y escritura, por los adjuntos),
  Metadata (lectura).
- **Eventos:** Issues e Issue comment, con un único webhook a nivel de la app:
  `https://api.rtres.net/api/webhooks/github` y el mismo `GitHub:WebhookSecret`. Ya no hay webhooks por repo.
- **Autenticación:** la API firma un JWT con la llave privada de la app, obtiene la instalación del dueño
  (`GET /users/{owner}/installation` o `/orgs/{owner}/installation`) y pide un installation token (dura 1 h; se cachea
  por dueño y se renueva solo).
- **Configuración:** `GitHub:App:Id` y `GitHub:App:PrivateKey` como variables del pool (`Set-ApiEnvironment.ps1`).
  La llave privada no va a git.

## Tareas

1. Crear la app en GitHub (Developer settings → GitHub Apps), con los permisos y eventos de arriba; descargar la llave
   privada.
2. En `IntegrationClients.cs`, reemplazar `TokenFor` por un proveedor de tokens: si hay `GitHub:App:Id`, usa la app;
   si no, sigue con `GitHub:Tokens`/`GitHub:Token` (transición sin corte).
3. Revisar el webhook: los comentarios de la app llegan con `user.type = "Bot"` y `GitHubWebhookProcessor` ya los
   ignora, que es lo correcto (son ecos del portal). Mantener la marca `PortalCommentMarker` como respaldo.
4. Tests: token por instalación cacheado y renovado al vencer, dueño sin instalación (error claro, Hangfire reintenta),
   fallback a tokens fine-grained.
5. Instalar la app en `rockespier` y en cada organización de cliente; borrar los webhooks por repo y, cuando todo
   funcione, los tokens fine-grained.
6. Documentar en `scripts/readme.md` cómo dar de alta un cliente nuevo: instalar la app en su repo y nada más.

## Fuera de alcance

- La software factory (`factory/`) sigue usando `gh` con el usuario personal; sus comentarios ya se filtran con la
  marca `<!-- factory -->`.
