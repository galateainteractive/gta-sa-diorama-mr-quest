$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$diagnosticsRoot = Join-Path $projectRoot 'diagnosticos'

$adb = Get-ChildItem -LiteralPath $projectRoot -Filter 'adb.exe' -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $adb) {
    throw "ADB nao encontrado dentro de $projectRoot"
}

$devices = & $adb devices
$serials = @(
    $devices |
        Select-String '^\S+\s+device$' |
        ForEach-Object { ($_ -split '\s+')[0] }
)

if ($serials.Count -ne 1) {
    throw "Conecte exatamente um Quest autorizado. Detectados: $($serials.Count)"
}

$serial = $serials[0]
$pidText = (& $adb -s $serial shell pidof com.rockstargames.gtasa).Trim()
if (-not $pidText) {
    throw 'GTA San Andreas nao esta aberto no Quest.'
}
$gamePid = ($pidText -split '\s+')[0]

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$state = Read-Host 'Digite BOM se o audio esta normal, ou RUIM se esta falhado'
$state = if ($state -match '^(?i:bom)$') { 'good' } elseif ($state -match '^(?i:ruim)$') { 'bad' } else { 'unknown' }
$outputDir = Join-Path $diagnosticsRoot "audio-$state-$stamp"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

@(
    "captured_at=$((Get-Date).ToString('o'))"
    "state=$state"
    "serial=$serial"
    "pid=$gamePid"
    "adb=$adb"
) | Set-Content -LiteralPath (Join-Path $outputDir 'capture-info.txt') -Encoding UTF8

Write-Host "Capturando estado $state do audio..." -ForegroundColor Cyan
& $adb -s $serial shell dumpsys audio | Set-Content -LiteralPath (Join-Path $outputDir 'dumpsys-audio.txt') -Encoding UTF8
& $adb -s $serial shell dumpsys media.audio_flinger | Set-Content -LiteralPath (Join-Path $outputDir 'audio-flinger.txt') -Encoding UTF8
& $adb -s $serial shell top -b -n 1 -H -p $gamePid | Set-Content -LiteralPath (Join-Path $outputDir 'threads.txt') -Encoding UTF8
& $adb -s $serial logcat -d -v threadtime -t 4000 |
    Select-String 'AudioTrack|AudioFlinger|OpenSL|AAudio|AudioPolicy|AudioSystem|libOpenSLES|alsoft|gtasa' |
    Set-Content -LiteralPath (Join-Path $outputDir 'audio-logcat.txt') -Encoding UTF8

Write-Host "Salvo em: $outputDir" -ForegroundColor Green
