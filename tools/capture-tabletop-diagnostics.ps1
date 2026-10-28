[CmdletBinding()]
param(
    [string]$Serial = '',
    [string]$OutputDirectory = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$driveRoot = [IO.Path]::GetPathRoot($projectRoot)
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $projectRoot 'diagnosticos'
}

$adbCandidates = @(
    (Join-Path $projectRoot 'work-upstream\.tools\platform-tools-37.0.1\platform-tools\adb.exe'),
    (Join-Path $driveRoot 'Android\Sdk\platform-tools\adb.exe'),
    (Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe')
)
$adb = $adbCandidates |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1
if (-not $adb) {
    throw "ADB was not found. Checked paths: $($adbCandidates -join '; ')"
}

& $adb start-server | Out-Host
if ([string]::IsNullOrWhiteSpace($Serial)) {
    $authorizedQuests = @(
        & $adb devices -l |
            ForEach-Object {
                if ($_ -match '^\s*(\S+)\s+device\s+.*\bmodel:Quest(?:_|\s)') {
                    $Matches[1]
                }
            }
    )
    if ($authorizedQuests.Count -eq 0) {
        throw 'No authorized Meta Quest was found. Connect the headset, accept USB debugging inside it, and run this BAT again.'
    }
    if ($authorizedQuests.Count -gt 1) {
        throw "More than one authorized Quest was found: $($authorizedQuests -join ', '). Disconnect the headset you do not want to capture."
    }
    $Serial = $authorizedQuests[0]
} else {
    $requested = @(& $adb devices | Where-Object {
        $_ -match ('^\s*' + [regex]::Escape($Serial) + '\s+device(?:\s|$)')
    })
    if ($requested.Count -ne 1) {
        throw "Requested Quest is not connected and authorized: $Serial"
    }
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
        & $adb -s $Serial wait-for-device 2>&1 |
            Tee-Object -FilePath $logPath -Append | Out-Host
        "# connected $(Get-Date -Format o)" |
            Add-Content -LiteralPath $logPath -Encoding Unicode
        # Begin at the current moment instead of replaying the complete device
        # log history. This makes short tutorial captures start immediately.
        & $adb -s $Serial logcat -T 1 -v threadtime 'SAVR:I' '*:S' 2>&1 |
            Tee-Object -FilePath $logPath -Append | Out-Host
        "# logcat ended $(Get-Date -Format o); reconnecting" |
            Add-Content -LiteralPath $logPath -Encoding Unicode
    } catch {
        "# capture error $(Get-Date -Format o): $($_.Exception.Message)" |
            Add-Content -LiteralPath $logPath -Encoding Unicode
    }
    Start-Sleep -Seconds 2
}
