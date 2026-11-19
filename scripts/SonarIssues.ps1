# Configuración
# El token se lee de la variable de entorno SONAR_TOKEN (SonarCloud > My Account > Security); nunca en el código.
$token = $env:SONAR_TOKEN
if ([string]::IsNullOrWhiteSpace($token)) { throw 'Define la variable de entorno SONAR_TOKEN antes de ejecutar este script.' }
$projectKey = "rockespier_Rtres" # ID de tu proyecto en SonarCloud

# Autenticación Básica segura
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($token.Trim() + ":")))
$headers = @{ Authorization = "Basic $base64AuthInfo" }

$page = 1
$pageSize = 500 
$allIssues = @()

Write-Host "Consultando issues con estado OPEN en SonarQube Cloud..."

do {
    # Concatenación estricta para evitar que saltos de línea invisibles rompan la URL
    $url = "https://sonarcloud.io/api/issues/search?componentKeys=" + $projectKey.Trim() + "&statuses=OPEN&ps=" + $pageSize + "&p=" + $page
    
    Write-Host "Ejecutando petición a: $url"
    
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    
    if ($response.issues.Count -gt 0) {
        $allIssues += $response.issues
    }
    
    $page++
} while ($response.issues.Count -eq $pageSize -and $page -le 20) 

# Exportar a CSV
$allIssues | Select-Object key, type, severity, status, message, component, line | 
             Export-Csv -Path "sonarcloud_issues_open.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Exportación completada. Total extraído: $($allIssues.Count) issues."