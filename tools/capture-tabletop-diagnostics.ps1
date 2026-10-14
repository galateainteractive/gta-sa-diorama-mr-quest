[CmdletBinding()]
param(
    [string]$Serial = '2G0YC1ZF7B08DM',
    [string]$OutputDirectory = 'D:\UNITY PROJETOS\GTASanAndreasTabletop\diagnosticos'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$adbCandidates = @(
    'D:\UNITY PROJETOS\GTASanAndreasTabletop\work-upstream\.tools\platform-tools-37.0.1\platform-tools\adb.exe',
    'D:\Android\Sdk\platform-tools\adb.exe'
)
$adb = $adbCandidates |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1
if (-not $adb) {
    throw "ADB was not found on D:. Checked paths: $($adbCandidates -join '; ')"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logPath = Join-Path $OutputDirectory "tabletop-$stamp.log"

Write-Host '============================================================'
Write-Host '  GTA SAN ANDREAS DIORAMA MR DIAGNOSTICS'
Write-Host '============================================================'
Write-Host "Output file: $logPath"
Write-Host 'Play normally. If the problem occurs, note the exact time.'
Write-Host 'Keep this window open and press Ctrl+C only when you are finished.'
Write-Host ''

# Windows PowerShell 5 writes Tee-Object files as UTF-16LE. Start the file in
# that same encoding so logcat output remains directly searchable.
"# GTA SA Tabletop diagnostic - $(Get-Date -Format o) - serial $Serial" |
    Set-Content -LiteralPath $logPath -Encoding Unicode

while ($true) {
    try {
        & $adb start-server 2>&1 | Tee-Object -FilePath $logPath -Append | Out-Host
        & $adb -s $Serial wait-for-device 2>&1 |
            Tee-Object -FilePath $logPath -Append | Out-Host
        "# connected $(Get-Date -Format o)" |
            Add-Content -LiteralPath $logPath -Encoding Unicode
        & $adb -s $Serial logcat -v threadtime 'SAVR:I' '*:S' 2>&1 |
            Tee-Object -FilePath $logPath -Append | Out-Host
        "# logcat ended $(Get-Date -Format o); reconnecting" |
            Add-Content -LiteralPath $logPath -Encoding Unicode
    } catch {
        "# capture error $(Get-Date -Format o): $($_.Exception.Message)" |
            Add-Content -LiteralPath $logPath -Encoding Unicode
    }
    Start-Sleep -Seconds 2
}
