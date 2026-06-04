$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonPath = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$PidFile = Join-Path $ProjectRoot ".uvicorn.pid"
$Port = 8000

function Get-ListeningProcessIds {
    try {
        Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop |
            Select-Object -ExpandProperty OwningProcess -Unique
    }
    catch {
        @()
    }
}

function Start-Service {
    $running = @(Get-ListeningProcessIds)
    if ($running.Count -gt 0) {
        Write-Host "El servicio ya esta encendido en http://127.0.0.1:$Port"
        Write-Host "PID: $($running -join ', ')"
        return
    }

    if (-not (Test-Path $PythonPath)) {
        Write-Host "No se encontro el entorno virtual en .venv."
        Write-Host "Crea el entorno e instala dependencias antes de iniciar el servicio."
        return
    }

    $arguments = @(
        "-m", "uvicorn", "main:app",
        "--host", "127.0.0.1",
        "--port", "$Port",
        "--reload",
        "--reload-dir", $ProjectRoot
    )

    $process = Start-Process `
        -FilePath $PythonPath `
        -ArgumentList $arguments `
        -WorkingDirectory $ProjectRoot `
        -WindowStyle Hidden `
        -PassThru

    $process.Id | Set-Content -Path $PidFile -Encoding ascii

    Start-Sleep -Seconds 2
    $running = @(Get-ListeningProcessIds)
    if ($running.Count -gt 0) {
        Write-Host "Servicio encendido: http://127.0.0.1:$Port"
        Write-Host "PID: $($running -join ', ')"
    }
    else {
        Write-Host "Se intento iniciar el servicio, pero el puerto $Port aun no esta escuchando."
        Write-Host "Revisa la salida del proceso o ejecuta: .\.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port $Port --reload"
    }
}

function Stop-Service {
    $processIds = @(Get-ListeningProcessIds)

    if ((Test-Path $PidFile)) {
        $savedPid = Get-Content -Path $PidFile -ErrorAction SilentlyContinue
        if ($savedPid) {
            $processIds += $savedPid
        }
    }

    $processIds = @($processIds | Where-Object { $_ } | Select-Object -Unique)
    if ($processIds.Count -eq 0) {
        Write-Host "El servicio no esta encendido en el puerto $Port."
        return
    }

    foreach ($processId in $processIds) {
        try {
            Stop-Process -Id $processId -Force -ErrorAction Stop
            Write-Host "Proceso detenido: $processId"
        }
        catch {
            Write-Host "No se pudo detener el proceso ${processId}: $($_.Exception.Message)"
        }
    }

    if (Test-Path $PidFile) {
        Remove-Item -Path $PidFile -Force
    }
}

function Main {
    Write-Host ""
    Write-Host "Backend LLM"
    Write-Host "1. Start"
    Write-Host "2. Stop"
    Write-Host ""

    $option = Read-Host "Elige una opcion"

    switch ($option) {
        "1" { Start-Service }
        "2" { Stop-Service }
        default { Write-Host "Opcion invalida." }
    }
}

Main
