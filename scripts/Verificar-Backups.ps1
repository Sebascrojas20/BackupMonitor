
# ============================================================
# BackupMonitor 6.0
# Monitoreo, integridad y notificaciones de Windows
# ============================================================

# ============================================================
# CONFIGURACION EXTERNA
# ============================================================
$ProyectoPath = Split-Path -Parent $PSScriptRoot
$ConfigPath = Join-Path $ProyectoPath "config.json"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "No se encontro config.json en: $ConfigPath"
}

try {
    $Config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
}
catch {
    throw "No se pudo leer config.json: $($_.Exception.Message)"
}

if ([string]::IsNullOrWhiteSpace($Config.BackupPath)) {
    throw "BackupPath no esta configurado."
}

if ($Config.DiasMaximos -le 0 -or $Config.BackupsEsperados.Count -eq 0) {
    throw "La configuracion contiene valores invalidos."
}

$BackupPath = [string]$Config.BackupPath
$ReportPath = Join-Path $BackupPath "Reportes"
$DiasMaximos = [int]$Config.DiasMaximos
$BackupsEsperados = @($Config.BackupsEsperados)

# Crear carpeta de reportes
if (-not (Test-Path -LiteralPath $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
}

$FechaEjecucion = Get-Date
$IdEjecucion = $FechaEjecucion.ToString("yyyyMMdd_HHmmss")

$ReporteCSV = Join-Path $ReportPath "Reporte_Backups_$IdEjecucion.csv"
$HistorialCSV = Join-Path $ReportPath "Historial_Backups.csv"
$LogFile = Join-Path $ReportPath "BackupMonitor.log"

$Resultados = @()

function Escribir-Log {
    param([string]$Mensaje)

    $Linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Mensaje"
    Add-Content -LiteralPath $LogFile -Value $Linea -Encoding UTF8
}

# ============================================================
# NOTIFICACION NATIVA DE WINDOWS
# ============================================================

function Mostrar-NotificacionWindows {

    param(
        [string]$Titulo,
        [string]$Mensaje,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Tipo = "Warning"
    )

    try {

        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop

        $Icono = New-Object System.Windows.Forms.NotifyIcon

        $Icono.Icon = [System.Drawing.SystemIcons]::Warning
        $Icono.BalloonTipTitle = $Titulo
        $Icono.BalloonTipText = $Mensaje
        $Icono.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
        $Icono.Visible = $true

        if ($Tipo -eq "Info") {
            $Icono.Icon = [System.Drawing.SystemIcons]::Information
            $Icono.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        }

        if ($Tipo -eq "Error") {
            $Icono.Icon = [System.Drawing.SystemIcons]::Error
            $Icono.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
        }

        $Icono.ShowBalloonTip(10000)

        Start-Sleep -Seconds 8

        $Icono.Visible = $false
        $Icono.Dispose()

    }
    catch {

        Escribir-Log "ERROR - No fue posible mostrar la notificacion: $($_.Exception.Message)"

    }
}

Escribir-Log "INICIO - Ejecucion $IdEjecucion"

# ============================================================
# VERIFICACION DE ARCHIVOS
# ============================================================

foreach ($NombreArchivo in $BackupsEsperados) {

    $RutaArchivo = Join-Path $BackupPath $NombreArchivo

    $Estado = ""
    $TamanoMB = 0
    $AntiguedadDias = $null
    $FechaModificacion = ""
    $HashSHA256 = ""
    $Observacion = ""

    if (-not (Test-Path -LiteralPath $RutaArchivo -PathType Leaf)) {

        $Estado = "FALTANTE"
        $Observacion = "No se encontro el archivo esperado."

    }
    else {

        try {

            $Archivo = Get-Item -LiteralPath $RutaArchivo -ErrorAction Stop

            $TamanoMB = [math]::Round($Archivo.Length / 1MB, 2)
            $FechaModificacion = $Archivo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")

            $AntiguedadDias = [math]::Round(
                ((Get-Date) - $Archivo.LastWriteTime).TotalDays, 2
            )

            if ($Archivo.LastWriteTime -gt (Get-Date).AddMinutes(5)) {

                $Estado = "ERROR_FECHA"
                $Observacion = "Fecha de modificacion en el futuro."

            }
            elseif ($Archivo.Length -eq 0) {

                $Estado = "VACIO"
                $Observacion = "El archivo tiene 0 bytes."

            }
            else {

                try {

                    $HashSHA256 = (
                        Get-FileHash -LiteralPath $RutaArchivo `
                        -Algorithm SHA256 -ErrorAction Stop
                    ).Hash

                    if ($AntiguedadDias -gt $DiasMaximos) {

                        $Estado = "ANTIGUO"
                        $Observacion = "Supera el limite de antiguedad."

                    }
                    else {

                        $Estado = "OK"
                        $Observacion = "Archivo disponible y hash calculado."

                    }

                }
                catch {

                    $Estado = "ERROR"
                    $Observacion = "No fue posible calcular SHA-256."

                }
            }

        }
        catch {

            $Estado = "ERROR"
            $Observacion = "Error de lectura: $($_.Exception.Message)"

        }
    }

    if ($Estado -ne "OK") {
        Escribir-Log "ALERTA - $NombreArchivo : $Estado"
    }

    $Resultados += [PSCustomObject]@{
        IdEjecucion       = $IdEjecucion
        FechaEjecucion    = $FechaEjecucion.ToString("yyyy-MM-dd HH:mm:ss")
        Archivo           = $NombreArchivo
        Estado            = $Estado
        TamanoMB          = $TamanoMB
        AntiguedadDias    = $AntiguedadDias
        FechaModificacion = $FechaModificacion
        HashSHA256        = $HashSHA256
        Observacion       = $Observacion
    }
}

# ============================================================
# EXPORTAR REPORTES
# ============================================================

$Resultados | Export-Csv -LiteralPath $ReporteCSV `
    -NoTypeInformation -Delimiter ";" -Encoding UTF8

if (Test-Path -LiteralPath $HistorialCSV) {

    $Resultados | Export-Csv -LiteralPath $HistorialCSV `
        -NoTypeInformation -Delimiter ";" -Encoding UTF8 -Append

}
else {

    $Resultados | Export-Csv -LiteralPath $HistorialCSV `
        -NoTypeInformation -Delimiter ";" -Encoding UTF8

}

# ============================================================
# RESUMEN
# ============================================================

$Total = $Resultados.Count
$Correctos = @($Resultados | Where-Object Estado -eq "OK").Count
$Antiguos = @($Resultados | Where-Object Estado -eq "ANTIGUO").Count
$Faltantes = @($Resultados | Where-Object Estado -eq "FALTANTE").Count
$Vacios = @($Resultados | Where-Object Estado -eq "VACIO").Count
$Errores = @($Resultados | Where-Object Estado -eq "ERROR").Count
$ErroresFecha = @($Resultados | Where-Object Estado -eq "ERROR_FECHA").Count

$PorcentajeCorrectos = 0

if ($Total -gt 0) {
    $PorcentajeCorrectos = [math]::Round(($Correctos / $Total) * 100, 2)
}

$Problemas = @($Resultados | Where-Object Estado -ne "OK")

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "          BACKUP MONITOR 6.0" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$Resultados |
    Format-Table Archivo, Estado, TamanoMB, AntiguedadDias, HashSHA256 -AutoSize

Write-Host ""
Write-Host "RESUMEN EJECUTIVO" -ForegroundColor Cyan

Write-Host "Total esperado:       $Total"
Write-Host "Correctos:            $Correctos"
Write-Host "Antiguos:             $Antiguos"
Write-Host "Faltantes:            $Faltantes"
Write-Host "Vacios:               $Vacios"
Write-Host "Errores:              $Errores"
Write-Host "Errores de fecha:     $ErroresFecha"
Write-Host "Disponibilidad:       $PorcentajeCorrectos %"

# ============================================================
# ENVIAR NOTIFICACION SI EXISTEN PROBLEMAS
# ============================================================

if ($Problemas.Count -gt 0) {

    $Detalle = ($Problemas | ForEach-Object {
        "$($_.Archivo): $($_.Estado)"
    }) -join " | "

    # Windows limita el espacio visible del mensaje.
    if ($Detalle.Length -gt 220) {
        $Detalle = $Detalle.Substring(0, 217) + "..."
    }

    Mostrar-NotificacionWindows `
        -Titulo "BackupMonitor - Alertas detectadas" `
        -Mensaje $Detalle `
        -Tipo "Warning"

    Escribir-Log "NOTIFICACION - Se detectaron $($Problemas.Count) problemas."

}
else {

    Mostrar-NotificacionWindows `
        -Titulo "BackupMonitor - Verificacion correcta" `
        -Mensaje "Todos los backups esperados estan disponibles." `
        -Tipo "Info"

    Escribir-Log "NOTIFICACION - Todos los backups estan correctos."

}

Write-Host ""
Write-Host "REPORTE: $ReporteCSV" -ForegroundColor Green
Write-Host "HISTORIAL: $HistorialCSV" -ForegroundColor Green
Write-Host "LOG: $LogFile" -ForegroundColor Green

Escribir-Log "FIN - Ejecucion $IdEjecucion"

Write-Host ""
Write-Host "Ejecucion finalizada." -ForegroundColor Green
