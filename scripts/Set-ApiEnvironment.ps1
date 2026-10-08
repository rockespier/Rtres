<#
.SYNOPSIS
Copia la configuración de un appsettings*.json a variables de entorno del app pool de la API en IIS.

.DESCRIPTION
Aplana el JSON con el formato de ASP.NET Core ("GitHub": { "Tokens": { "rockespier": "x" } } -> GitHub__Tokens__rockespier)
y guarda cada valor en system.applicationHost/applicationPools/add[@name=AppPool]/environmentVariables, donde el
deploy no las pisa. Nunca imprime los valores, solo los nombres. Ejecutar como administrador en el servidor IIS.

Corre en Windows PowerShell 5.1: el módulo WebAdministration no funciona de forma nativa en PowerShell 7 (se carga en
una sesión de compatibilidad sin la unidad IIS:\). Si se lanza desde PowerShell 7, se vuelve a ejecutar solo en 5.1.

.EXAMPLE
# Solo los tokens de GitHub (recomendado: el resto del archivo de desarrollo apunta a sandbox y a la BD de dev)
.\Set-ApiEnvironment.ps1 -SettingsFile .\appsettings.Development.local.json -AppPool 'api.rtres.net' -Only 'GitHub:Tokens'

.EXAMPLE
# Ver qué variables se crearían, sin tocar IIS
.\Set-ApiEnvironment.ps1 -SettingsFile .\appsettings.Development.local.json -AppPool 'api.rtres.net' -Only 'GitHub' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$SettingsFile,

    [Parameter(Mandatory = $true)]
    [string]$AppPool,

    # Prefijos de configuración a copiar (con ':' o '__'), ej. 'GitHub:Tokens', 'Smtp'. Vacío = todo el archivo.
    [string[]]$Only = @(),

    # No reinicia el app pool al terminar (las variables se aplican en el próximo reinicio).
    [switch]$NoRestart
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ($PSVersionTable.PSEdition -eq 'Core') {
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-SettingsFile', (Resolve-Path -LiteralPath $SettingsFile).Path, '-AppPool', $AppPool)
    if ($Only) { $arguments += '-Only'; $arguments += ($Only -join ',') }
    if ($NoRestart) { $arguments += '-NoRestart' }
    if ($WhatIfPreference) { $arguments += '-WhatIf' }
    & "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe" @arguments
    exit $LASTEXITCODE
}

function ConvertTo-FlatSettings {
    param($Node, [string]$Prefix)
    $join = { param($name) if ($Prefix) { "${Prefix}__$name" } else { $name } }
    if ($Node -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $Node.PSObject.Properties) { ConvertTo-FlatSettings $property.Value (& $join $property.Name) }
    }
    elseif ($Node -is [System.Array]) {
        for ($i = 0; $i -lt $Node.Count; $i++) { ConvertTo-FlatSettings $Node[$i] (& $join $i) }
    }
    elseif ($null -ne $Node) {
        # Booleanos en minúsculas, como los espera la configuración de .NET.
        $value = if ($Node -is [bool]) { $Node.ToString().ToLowerInvariant() } else { [string]$Node }
        [pscustomobject]@{ Name = $Prefix; Value = $value }
    }
}

# Al relanzarse desde PowerShell 7, -Only llega como un solo texto separado por comas.
$prefixes = @($Only | ForEach-Object { $_ -split ',' } | Where-Object { $_ } | ForEach-Object { $_.Trim().Replace(':', '__') })
$settings = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
$variables = @(ConvertTo-FlatSettings $settings '' | Where-Object {
    $name = $_.Name
    $_.Value -ne '' -and ($prefixes.Count -eq 0 -or @($prefixes | Where-Object { $name -eq $_ -or $name.StartsWith("${_}__", [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0)
})
if ($variables.Count -eq 0) { throw "No hay valores para copiar en $SettingsFile (filtro: $($Only -join ', '))." }

Import-Module WebAdministration
if (-not (Test-Path "IIS:\AppPools\$AppPool")) {
    $existing = (Get-ChildItem IIS:\AppPools | ForEach-Object Name) -join ', '
    throw "No existe el app pool '$AppPool'. App pools en este servidor: $existing"
}
$filter = "system.applicationHost/applicationPools/add[@name='$AppPool']/environmentVariables"

foreach ($variable in $variables) {
    if ($PSCmdlet.ShouldProcess($AppPool, "Definir $($variable.Name)")) {
        # Quitar y volver a agregar: el script se puede repetir sin duplicar ni fallar. La primera vez no hay nada que
        # quitar e IIS lo avisa con un warning (no un error), por eso también se silencian los warnings.
        Remove-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter $filter -Name '.' -AtElement @{ name = $variable.Name } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter $filter -Name '.' -Value @{ name = $variable.Name; value = $variable.Value }
        Write-Host "  $($variable.Name)" -ForegroundColor Green
    }
}

if (-not $NoRestart -and -not $WhatIfPreference) {
    Restart-WebAppPool -Name $AppPool
    Write-Host "App pool '$AppPool' reiniciado." -ForegroundColor Cyan
}
