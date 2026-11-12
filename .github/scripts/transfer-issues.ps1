$origen = "rtres-net/AssistanceTravelers"
$destino = "rockespier/EUA2026"

# Issues que quieres copiar
$issues = 107

foreach ($issue in $issues) {

    Write-Host ""
    Write-Host "------------------------------------"
    Write-Host "Copiando issue #$issue..."
    Write-Host "------------------------------------"

    $tempFile = Join-Path $env:TEMP "github-issue-$issue.md"

    try {

        # Obtener información de la issue
        $json = gh issue view $issue `
            --repo $origen `
            --json title,body

        if ($LASTEXITCODE -ne 0) {
            throw "No se pudo obtener la issue #$issue"
        }

        $data = $json | ConvertFrom-Json

        $titulo = $data.title
        $body   = $data.body

        # Crear contenido nuevo
        $bodyNuevo = @"
$body

---

### Issue original

https://github.com/$origen/issues/$issue

> Migrada desde $origen - Issue #$issue
"@

        # Guardar body en archivo UTF-8
        [System.IO.File]::WriteAllText(
            $tempFile,
            $bodyNuevo,
            [System.Text.UTF8Encoding]::new($false)
        )

        # Crear issue usando archivo para el body
        $resultado = gh issue create `
            --repo $destino `
            --title $titulo `
            --body-file $tempFile

        if ($LASTEXITCODE -eq 0) {

            Write-Host "OK - Issue #$issue copiada correctamente." -ForegroundColor Green
            Write-Host $resultado

        }
        else {

            Write-Host "ERROR copiando issue #$issue" -ForegroundColor Red

        }

    }
    catch {

        Write-Host "ERROR en issue #$issue" -ForegroundColor Red
        Write-Host $_.Exception.Message

    }
    finally {

        # Eliminar archivo temporal
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }

    }
}