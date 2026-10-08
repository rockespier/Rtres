<#
.SYNOPSIS
Empaqueta Rtres y despliega la API y el portal en el Windows Server (IIS).

.DESCRIPTION
- api.rtres.net    -> Windows Server (IIS): API ASP.NET Core + Hangfire.
- portal.rtres.net -> Windows Server (IIS): SPA estática.
- rtres.net        -> hosting Linux (Apache): el site es 100 % prerenderizado, se sube site.zip a mano (FTP o
                      administrador de archivos). Este script no toca el servidor Linux.
La base de datos no se migra sola fuera de Development: se genera publish\migrations.sql (idempotente) para ejecutarlo
en SQL Server antes de iniciar la API nueva.
#>
# PowerShell 7: el zip de .NET Core usa '/' en las rutas (el de Windows PowerShell 5.1 usa '' y Linux no lo descomprime bien).
#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiDestination,

    [Parameter(Mandatory = $true)]
    [string]$PortalDestination,

    # localhost (por defecto) despliega en esta maquina sin PowerShell Remoting.
    [string]$ComputerName = 'localhost',

    [string]$ApiAppPool,
    [string]$PortalAppPool,
    [pscredential]$Credential,
    [switch]$UseSsl,
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
# (robocopy no borra archivos del destino, asi que los appsettings ya instalados se conservan).
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
    Invoke-Checked { npx ng build site --configuration production } 'Compilando site (prerender es/en/it)'
    Invoke-Checked { npx ng build portal --configuration production } 'Compilando portal'
}
finally {
    Pop-Location
}

foreach ($required in (Join-Path $siteDist 'es\index.html'), (Join-Path $siteDist 'en\index.html'), (Join-Path $siteDist 'it\index.html'), (Join-Path $portalDist 'index.html')) {
    if (-not (Test-Path -LiteralPath $required)) { throw "El build no genero $required" }
}

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
Write-Host "  API:         $apiPackage"
Write-Host "  Portal:      $portalPackage"
Write-Host "  Site:        $sitePackage.zip  (subir al hosting Linux, carpeta publica de rtres.net)"
Write-Host "  Migraciones: $migrationsScript  (ejecutar en SQL Server antes de iniciar la API)"

if ($PackageOnly) {
    Write-Host "`nPackageOnly indicado: no se modifico ningun servidor." -ForegroundColor Yellow
    return
}

# Copia los paquetes a sus destinos con los app pools detenidos (liberan las DLL de la API).
$install = {
    param($staging, $apiDestination, $portalDestination, $apiAppPool, $portalAppPool)
    $ErrorActionPreference = 'Stop'
    $pools = @($apiAppPool, $portalAppPool) | Where-Object { $_ }
    if ($pools) { Import-Module WebAdministration }

    foreach ($pool in $pools) {
        if ((Get-WebAppPoolState -Name $pool).Value -eq 'Started') { Stop-WebAppPool -Name $pool }
    }
    try {
        foreach ($deployment in @(
            @{ Source = (Join-Path $staging 'api'); Destination = $apiDestination },
            @{ Source = (Join-Path $staging 'portal'); Destination = $portalDestination }
        )) {
            New-Item -ItemType Directory -Path $deployment.Destination -Force | Out-Null
            robocopy $deployment.Source $deployment.Destination /E /COPY:DAT /R:2 /W:2 /NFL /NDL /NP
            if ($LASTEXITCODE -gt 7) { throw "robocopy fallo al copiar a $($deployment.Destination) (codigo $LASTEXITCODE)." }
        }
    }
    finally {
        foreach ($pool in $pools) {
            Start-WebAppPool -Name $pool
        }
    }
}

$installArgs = @($ApiDestination, $PortalDestination, $ApiAppPool, $PortalAppPool)
if ($ComputerName -in 'localhost', '.', '127.0.0.1', $env:COMPUTERNAME) {
    Write-Host "`n==> Instalando en esta maquina" -ForegroundColor Cyan
    & $install $publishRoot @installArgs
}
else {
    if (-not $Credential) {
        $Credential = Get-Credential -Message "Credenciales de PowerShell Remoting para $ComputerName"
    }
    $session = New-PSSession -ComputerName $ComputerName -Credential $Credential -UseSSL:$UseSsl
    try {
        $remoteStaging = Invoke-Command -Session $session -ScriptBlock {
            $path = Join-Path $env:TEMP ("rtres-deploy-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            $path
        }
        foreach ($package in $apiPackage, $portalPackage) {
            Copy-Item -ToSession $session -LiteralPath $package -Destination $remoteStaging -Recurse -Force
        }
        try {
            Invoke-Command -Session $session -ScriptBlock $install -ArgumentList (@($remoteStaging) + $installArgs)
        }
        finally {
            Invoke-Command -Session $session -ScriptBlock { param($path) Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue } -ArgumentList $remoteStaging
        }
    }
    finally {
        if ($session) { Remove-PSSession $session }
    }
}

Write-Host "`nAPI y portal desplegados en $ComputerName. Falta subir site.zip al hosting Linux." -ForegroundColor Green
