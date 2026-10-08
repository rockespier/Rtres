Uso en el servidor (PowerShell 7 como administrador)

  1. Copia al servidor scripts\Set-ApiEnvironment.ps1 y tu appsettings.Development.local.json, por ejemplo a C:\deploy\.
  2. Mira primero qué crearía, sin tocar nada:
  cd C:\deploy
  .\Set-ApiEnvironment.ps1 -SettingsFile .\appsettings.Development.local.json -AppPool 'api.rtres.net' -Only 'GitHub:Tokens' -WhatIf
  .\Set-ApiEnvironment.ps1 -SettingsFile .\prod.json -AppPool 'api.rtres.net' -WhatIf
  3. Aplícalo:
  .\Set-ApiEnvironment.ps1 -SettingsFile .\appsettings.Development.local.json -AppPool RtresApi -Only 'GitHub:Tokens'
  4. Borra el JSON del servidor cuando termines, porque tiene secretos:
  Remove-Item .\appsettings.Development.local.json

  Por qué -Only

  Tu archivo de desarrollo tiene la conexión a la BD de desarrollo y PayPal sandbox. Si lo copias entero, producción apuntaría a esos entornos. Con -Only eliges
  qué secciones pasar:

  ┌──────────────────────────────────────────────────────────────┬───────────────────────┐
  │                         Para copiar                          │        Opción         │
  ├──────────────────────────────────────────────────────────────┼───────────────────────┤
  │ Solo los tokens por dueño                                    │ -Only 'GitHub:Tokens' │
  ├──────────────────────────────────────────────────────────────┼───────────────────────┤
  │ Todo GitHub (tokens, token por defecto, secreto del webhook) │ -Only 'GitHub'        │
  ├──────────────────────────────────────────────────────────────┼───────────────────────┤
  │ GitHub y SMTP                                                │ -Only 'GitHub','Smtp' │
  ├──────────────────────────────────────────────────────────────┼───────────────────────┤
  │ Todo el archivo (no recomendado para prod)                   │ sin -Only             │
  └──────────────────────────────────────────────────────────────┴───────────────────────┘
  
  Cómo verificarlas (PowerShell como administrador)

  1. Lista los nombres de las variables del pool:
  Import-Module WebAdministration
  (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
    -Filter "system.applicationHost/applicationPools/add[@name='api.rtres.net']/environmentVariables" `
    -Name '.').Collection | Select-Object name

  2. Comprueba los valores sin mostrar los secretos (solo los primeros 4 caracteres y el largo):
  (Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
    -Filter "system.applicationHost/applicationPools/add[@name='api.rtres.net']/environmentVariables" `
    -Name '.').Collection |
    Select-Object name, @{ n = 'valor'; e = { $_.value.Substring(0, [Math]::Min(4, $_.value.Length)) + '…' } }, @{ n = 'largo'; e = { $_.value.Length } }

  3. Con appcmd:
  & "$env:windir\System32\inetsrv\appcmd.exe" list apppool "api.rtres.net" /config | Select-String 'environmentVariables|add name'
  Ojo: appcmd muestra los valores completos en pantalla.

  4. Comprueba que la API las está usando:
  Restart-WebAppPool -Name api.rtres.net
  Invoke-WebRequest https://api.rtres.net/api/profile -SkipHttpErrorCheck | Select-Object StatusCode
  - 401: la API arrancó, así que leyó Jwt__Key y la configuración básica.
  - 500.30 o 502: falta una variable o tiene un valor mal. El motivo exacto está en el Visor de eventos → Registros de Windows → Aplicación, con origen IIS
    AspNetCore Module V2 o .NET Runtime.
	
	
	Siguientes pasos

  1. Prueba el portal en el navegador: entra a https://portal.rtres.net con tu SuperAdmin, revisa clientes, reportes y Vencimientos SUNAT, y crea un ticket de
     prueba.
  2. Correo: ese ticket debería mandarte un correo (va a Notifications__StaffEmail). Si no llega, mira el panel /jobs de Hangfire desde el servidor o el Visor de
     eventos.
  3. Webhooks:
     - PayPal live: https://api.rtres.net/api/payments/webhooks/paypal. El ID que te dé va en PayPal__WebhookId.
     - GitHub: https://api.rtres.net/api/webhooks/github, en cada repo o en la organización.
  4. Vencimientos SUNAT: carga tu RUC en la pantalla y marca como presentados los periodos de enero a agosto.
  5. Dominios secundarios: configura en el Linux que r3solucionesweb.com redirija con 301 a https://rtres.net/es/ y soluzionipersitiweb.it a
     https://rtres.net/it/, si aún no lo hacen.
  6. Seguridad: cambia las contraseñas de SQL Server y del correo que están en appsettings.json dentro de git, y deja ese archivo solo con valores vacíos.
  7. Backups: programa un respaldo diario de la base en SQL Server (con SQL Agent, o una tarea programada con sqlcmd si es la edición Express).

  Para los próximos deploys:
  .\scripts\Deploy-Local.ps1 -ApiDestination "D:\IISSites\api.rtres.net" -PortalDestination "<carpeta del portal>" `
    -ApiAppPool 'api.rtres.net' -PortalAppPool '<pool del portal>' -SkipNpmCi
  Si el deploy trae migraciones nuevas, ejecuta publish\migrations.sql antes. Después sube publish\site.zip al Linux.