<#
.SYNOPSIS
Empaqueta Rtres y despliega la API y el portal en el Windows Server (IIS) por SSH.

.DESCRIPTION
- api.rtres.net    -> Windows Server (IIS): API ASP.NET Core + Hangfire.
- portal.rtres.net -> Windows Server (IIS): SPA estática.
- rtres.net        -> hosting Linux (Apache): el site es 100 % prerenderizado, se sube site.zip a mano (FTP o
                      administrador de archivos). Este script no toca el servidor Linux.
La base de datos no se migra sola fuera de Development: se genera publish\migrations.sql (idempotente) para ejecutarlo
en SQL Server antes de iniciar la API nueva.

La copia usa scp/ssh con llave pública (la misma de EUA2026, ~/.ssh/id_ed25519): el script no maneja contraseñas.
En el servidor se detienen los pools, se descomprimen los zips sobre cada sitio y se vuelven a iniciar los pools.

.EXAMPLE
./scripts/Deploy-Ssh.ps1 -SkipNpmCi     # todo el flujo
./scripts/Deploy-Ssh.ps1 -PackageOnly   # solo genera los artefactos, sin tocar el servidor
#>
# PowerShell 7: el zip de .NET Core usa '/' en las rutas (el de Windows PowerShell 5.1 usa '\' y Linux no lo descomprime bien).
#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$Servidor = '161.132.56.79',
    [string]$Usuario = 'rramos',

    [string]$ApiDestination = 'D:\IISSites\api.rtres.net',
    [string]$PortalDestination = 'D:\IISSites\portal.rtres.net',
    [string]$ApiAppPool = 'api.rtres.net',
    [string]$PortalAppPool = 'portal.rtres.net',

    [switch]$SkipNpmCi,
    [switch]$PackageOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Checked {
    param([scriptblock]$Command, [string]$Description)

    Write-Host "`n==> $Description" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Description fallo (codigo de salida: $LASTEXITCODE)."
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$apiRoot = Join-Path $repositoryRoot 'src\api'
$apiProject = Join-Path $apiRoot 'Rtres.Api\Rtres.Api.csproj'
$infrastructureProject = Join-Path $apiRoot 'Rtres.Infrastructure\Rtres.Infrastructure.csproj'
$webRoot = Join-Path $repositoryRoot 'src\web'
$siteDist = Join-Path $webRoot 'dist\site\browser'
$portalDist = Join-Path $webRoot 'dist\portal\browser'
$deployTemplates = Join-Path $PSScriptRoot 'deploy'
$publishRoot = Join-Path $repositoryRoot 'publish'
$apiPackage = Join-Path $publishRoot 'api'
$sitePackage = Join-Path $publishRoot 'site'
$portalPackage = Join-Path $publishRoot 'portal'

if (-not (Test-Path -LiteralPath $apiProject)) { throw "No se encontro $apiProject" }
foreach ($template in 'site.htaccess', 'portal.web.config') {
    if (-not (Test-Path -LiteralPath (Join-Path $deployTemplates $template))) { throw "No se encontro $(Join-Path $deployTemplates $template)" }
}

Write-Host "Commit local: $(git -C $repositoryRoot rev-parse --short HEAD)"
git -C $repositoryRoot status --short

# Siempre se parte de artefactos nuevos; nunca se reutiliza publish/ anterior.
if (Test-Path -LiteralPath $publishRoot) {
    Remove-Item -LiteralPath $publishRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $apiPackage, $sitePackage, $portalPackage -Force | Out-Null

Invoke-Checked { dotnet publish $apiProject --configuration Release --output $apiPackage } 'Publicando API .NET (Release)'

# La configuracion del servidor vive en su propio appsettings/variables de entorno: el paquete no la pisa
# (Expand-Archive no borra archivos del destino, asi que los appsettings ya instalados se conservan).
Get-ChildItem -LiteralPath $apiPackage -Filter 'appsettings*.json' -File | Remove-Item -Force

$migrationsScript = Join-Path $publishRoot 'migrations.sql'
Invoke-Checked { dotnet ef migrations script --idempotent --project $infrastructureProject --startup-project $apiProject --configuration Release --output $migrationsScript } 'Generando script de migraciones (idempotente)'

Push-Location $webRoot
try {
    if (-not $SkipNpmCi) {
        Invoke-Checked { npm ci } 'Instalando dependencias bloqueadas del frontend'
    }
    # production: apiBaseUrl = https://api.rtres.net/api y bundles con hash. El prerender del site lee WordPress
    # a traves de esa API, asi que api.rtres.net debe estar en linea al compilar.
    # Posts del blog a prerenderizar: lee la API de produccion (si no responde, el build sigue sin ellos).
    Invoke-Checked { node (Join-Path $deployTemplates 'blog-routes.mjs') (Join-Path $webRoot 'projects\site\prerender-routes.generated.txt') } 'Listando posts del blog'
    Invoke-Checked { npx ng build site --configuration production } 'Compilando site (prerender es/en/it)'
    Invoke-Checked { npx ng build portal --configuration production } 'Compilando portal'
}
finally {
    Pop-Location
}

foreach ($required in (Join-Path $siteDist 'es\index.html'), (Join-Path $siteDist 'en\index.html'), (Join-Path $siteDist 'it\index.html'), (Join-Path $portalDist 'index.html')) {
    if (-not (Test-Path -LiteralPath $required)) { throw "El build no genero $required" }
}

# SEO: sitemap.xml, robots.txt y favicon.ico en la raiz del site (ver PLAN-seo.md, S1 y S9).
Invoke-Checked { node (Join-Path $deployTemplates 'seo-files.mjs') $siteDist } 'Generando sitemap.xml y robots.txt'

# Site: solo los archivos estaticos (el SSR no se usa en produccion) + .htaccess de Apache.
Copy-Item -Path (Join-Path $siteDist '*') -Destination $sitePackage -Recurse -Force
Copy-Item -LiteralPath (Join-Path $deployTemplates 'site.htaccess') -Destination (Join-Path $sitePackage '.htaccess') -Force

# Portal: SPA estatica; IIS reescribe las rutas de Angular a index.html.
Copy-Item -Path (Join-Path $portalDist '*') -Destination $portalPackage -Recurse -Force
Copy-Item -LiteralPath (Join-Path $deployTemplates 'portal.web.config') -Destination (Join-Path $portalPackage 'web.config') -Force

# Compress-Archive omite los archivos ocultos/punto con -Path '*': se usa .NET para incluir el .htaccess.
Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($package in $apiPackage, $sitePackage, $portalPackage) {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($package, "$package.zip")
}

Write-Host "`nArtefactos creados:" -ForegroundColor Green
Write-Host "  API:         $apiPackage.zip"
Write-Host "  Portal:      $portalPackage.zip"
Write-Host "  Site:        $sitePackage.zip  (subir al hosting Linux, carpeta publica de rtres.net)"
Write-Host "  Migraciones: $migrationsScript  (ejecutar en SQL Server antes de iniciar la API)"

if ($PackageOnly) {
    Write-Host "`nPackageOnly indicado: no se modifico ningun servidor." -ForegroundColor Yellow
    return
}

$destino = "$Usuario@$Servidor"
$sitios = @(
    @{ Zip = "$apiPackage.zip"; Pool = $ApiAppPool; Ruta = $ApiDestination },
    @{ Zip = "$portalPackage.zip"; Pool = $PortalAppPool; Ruta = $PortalDestination }
)

# Los zips van a la carpeta del usuario SSH (no dentro del sitio, para no dejarlos publicados) y se borran al terminar.
Invoke-Checked { scp ($sitios | ForEach-Object { $_.Zip }) "${destino}:" } "Copiando api.zip y portal.zip por scp a $destino"

# En el servidor: detener pools, descomprimir, levantar pools.
# Los pools se levantan en 'finally' para que el sitio no quede caido si falla la descompresion.
# Sin TTY, PowerShell remoto serializa progreso/Write-Host como CLIXML: se usa Write-Output y se silencia el progreso.
$sitiosRemotos = ($sitios | ForEach-Object {
    "@{Pool='$($_.Pool)';Ruta='$($_.Ruta)';Zip=(Join-Path `$env:USERPROFILE '$(Split-Path -Leaf $_.Zip)')}"
}) -join ','
$remoto = @"
`$ErrorActionPreference = 'Stop'
`$ProgressPreference = 'SilentlyContinue'
`$fallo = `$false
Import-Module WebAdministration
`$sitios = @($sitiosRemotos)
try {
    foreach (`$s in `$sitios) {
        if ((Get-WebAppPoolState -Name `$s.Pool).Value -ne 'Stopped') { Stop-WebAppPool -Name `$s.Pool }
        `$t = 0
        while ((Get-WebAppPoolState -Name `$s.Pool).Value -ne 'Stopped') {
            if (`$t -ge 60) { throw "El pool `$(`$s.Pool) no se detuvo en 60 s." }
            Start-Sleep -Seconds 1; `$t++
        }
        Write-Output "Pool detenido: `$(`$s.Pool)"
    }
    foreach (`$s in `$sitios) {
        New-Item -ItemType Directory -Path `$s.Ruta -Force | Out-Null
        Expand-Archive -Path `$s.Zip -DestinationPath `$s.Ruta -Force
        Write-Output "Descomprimido: `$(`$s.Zip) -> `$(`$s.Ruta)"
    }
}
catch {
    Write-Output "ERROR: `$(`$_.Exception.Message)"
    `$fallo = `$true
}
finally {
    foreach (`$s in `$sitios) {
        Start-WebAppPool -Name `$s.Pool
        Write-Output "Pool iniciado: `$(`$s.Pool) -> `$((Get-WebAppPoolState -Name `$s.Pool).Value)"
        Remove-Item -LiteralPath `$s.Zip -Force -ErrorAction SilentlyContinue
    }
}
if (`$fallo) { exit 1 }
"@

$codificado = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remoto))
Invoke-Checked { ssh $destino "powershell -NoProfile -NonInteractive -EncodedCommand $codificado" } "Despliegue remoto en $Servidor (detener pools, descomprimir, iniciar pools)"

Write-Host "`nAPI y portal desplegados en $Servidor. Si hubo migraciones, ejecuta publish\migrations.sql. Falta subir site.zip al hosting Linux." -ForegroundColor Green
