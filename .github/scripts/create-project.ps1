param(
    [string]$Owner = "rockespier",
    [string]$Repository = "EUA2026",
    [string]$ProjectTitle = "Modificaciones EUA"
)

$ErrorActionPreference = "Stop"

function Invoke-Gh {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    & gh @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Error ejecutando: gh $($Arguments -join ' ')"
    }
}

Write-Host "Verificando autenticacion..." -ForegroundColor Cyan

Invoke-Gh -Arguments @(
    "auth",
    "status"
)

Write-Host "Verificando permisos de GitHub Projects..." -ForegroundColor Cyan

gh auth refresh -s project

Write-Host ""
Write-Host "Creando Project: $ProjectTitle" -ForegroundColor Cyan

$projectJson = & gh project create `
    --owner $Owner `
    --title $ProjectTitle `
    --format json

if ($LASTEXITCODE -ne 0) {
    throw "No se pudo crear el Project."
}

$project = $projectJson | ConvertFrom-Json

$projectNumber = $project.number
$projectUrl = $project.url

if (-not $projectNumber) {
    throw "GitHub no devolvio el numero del Project."
}

Write-Host ""
Write-Host "Project creado: #$projectNumber" -ForegroundColor Green
Write-Host $projectUrl -ForegroundColor DarkGray

# ------------------------------------------------------------
# Vincular Project con el repositorio EUA2026
# ------------------------------------------------------------

Write-Host ""
Write-Host "Vinculando Project con $Owner/$Repository..." -ForegroundColor Cyan

Invoke-Gh -Arguments @(
    "project",
    "link",
    "$projectNumber",
    "--owner",
    $Owner,
    "--repo",
    $Repository
)

Write-Host "Project vinculado a $Owner/$Repository" -ForegroundColor Green

# ------------------------------------------------------------
# Priority
# ------------------------------------------------------------

Invoke-Gh -Arguments @(
    "project", "field-create", "$projectNumber",
    "--owner", $Owner,
    "--name", "Priority",
    "--data-type", "SINGLE_SELECT",
    "--single-select-options", "Critical,High,Medium,Low"
)

# ------------------------------------------------------------
# Area
# ------------------------------------------------------------

Invoke-Gh -Arguments @(
    "project", "field-create", "$projectNumber",
    "--owner", $Owner,
    "--name", "Area",
    "--data-type", "SINGLE_SELECT",
    "--single-select-options",
    "Backend .NET,Frontend Angular,Database,API,Authentication,Security,DevOps,Documentation"
)

# ------------------------------------------------------------
# Estimate
# ------------------------------------------------------------

Invoke-Gh -Arguments @(
    "project", "field-create", "$projectNumber",
    "--owner", $Owner,
    "--name", "Estimate",
    "--data-type", "SINGLE_SELECT",
    "--single-select-options", "XS,S,M,L,XL"
)

# ------------------------------------------------------------
# Assigned agent
# ------------------------------------------------------------

Invoke-Gh -Arguments @(
    "project", "field-create", "$projectNumber",
    "--owner", $Owner,
    "--name", "Assigned agent",
    "--data-type", "SINGLE_SELECT",
    "--single-select-options",
    "Unassigned,Architect .NET,Backend .NET,Angular,DBA - EF Core,DevOps,Codex,Claude Code,Human"
)

# ------------------------------------------------------------
# Target version
# ------------------------------------------------------------

Invoke-Gh -Arguments @(
    "project", "field-create", "$projectNumber",
    "--owner", $Owner,
    "--name", "Target version",
    "--data-type", "TEXT"
)

Write-Host ""
Write-Host "Campos creados correctamente." -ForegroundColor Green

Write-Host ""
Write-Host "Campos actuales:" -ForegroundColor Cyan

Invoke-Gh -Arguments @(
    "project",
    "field-list",
    "$projectNumber",
    "--owner",
    $Owner
)

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "CONFIGURACION TERMINADA" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

Write-Host ""
Write-Host "Repositorio:" -ForegroundColor Cyan
Write-Host "https://github.com/$Owner/$Repository"

Write-Host ""
Write-Host "Project:" -ForegroundColor Cyan
Write-Host $projectUrl

Write-Host ""
Write-Host "Configuraciones pendientes:" -ForegroundColor Yellow
Write-Host "1. Configurar las opciones del campo Status."
Write-Host "2. Crear/configurar el campo Iteration."