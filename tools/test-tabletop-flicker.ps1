[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$BuildRoot
)
$ErrorActionPreference = 'Stop'
$native = Join-Path $BuildRoot 'native\libsavr.so'
$cache = Join-Path $BuildRoot 'native\CMakeCache.txt'
$source = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot '..\native\src\Xr.cpp')
if ($source -notmatch 'DecideMask\(\s*mask\.active, liveActive, passthroughActive\)' -or
    $source -match '!vrcam::IsTabletopActive\(\)\s*\|\|\s*!g_passthroughActive') {
    throw 'Synchronized mask snapshot is not authoritative in player source'
}
Write-Output 'PASS captured mask snapshot outranks transient live camera flag'
if ($source -match 'SetPassthroughActive\(\s*tabletop::PassthroughEnabled\(\)\s*&&\s*vrcam::IsTabletopActive' -or
    $source -notmatch 'ShouldSubmitPassthrough\(\s*projectionTabletop') {
    throw 'Passthrough lifecycle still follows the transient live camera flag'
}
Write-Output 'PASS passthrough lifecycle follows synchronized projection state'
if (-not (Select-String -LiteralPath $cache -SimpleMatch 'SAVR_DEV:BOOL=OFF' -Quiet)) {
    throw 'Test requires the real player build (SAVR_DEV=OFF)'
}
$expected = (Get-FileHash -LiteralPath $native -Algorithm SHA256).Hash
Add-Type -AssemblyName System.IO.Compression.FileSystem
$found = 0
foreach ($apk in Get-ChildItem -LiteralPath (Join-Path $BuildRoot 'out') -Filter '*.apk') {
    $zip = [IO.Compression.ZipFile]::OpenRead($apk.FullName)
    try {
        $entry = $zip.GetEntry('lib/arm64-v8a/libsavr.so')
        if (-not $entry) { continue }
        $found++
        $stream = $entry.Open()
        $memory = [IO.MemoryStream]::new()
        try {
            $stream.CopyTo($memory)
            $bytes = $memory.ToArray()
            $sha = [Security.Cryptography.SHA256]::Create()
            try {
                $actual = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '')
            } finally { $sha.Dispose() }
            if ($actual -ne $expected) { throw 'Packaged native library differs from tested build' }
            $text = [Text.Encoding]::ASCII.GetString($bytes)
            foreach ($required in @(
                '[tabletop.flicker.fix] package=35',
                '[tabletop.flicker.fix] retained=',
                '[tabletop.flicker.identity] membership=v2',
                '[tabletop.flicker.alpha_depth]',
                '[tabletop.flicker.mask_window] package=36',
                '[tabletop.flicker.passthrough] package=36',
                'window_frames=%u failed_masks=',
                'snapshot_authority=%llu',
                '[tabletop.aim] attack edge',
                '[tabletop.aim.area]',
                'target widget justpressed=%d bridge=L2 injected=%d',
                'target widget released=1 bridge=L2',
                'route=classic_pad_target_no_physical_ray',
                'pad enter targeting=1 original=%d frame=%u bridge=L2',
                'pad exit targeting=1 original=%d frame=%u bridge=L2',
                '[tabletop.perf42]',
                '[tabletop.perf42.init]',
                '[tabletop.perf42.thermal]',
                '[tabletop.passthrough.weather.applied]'
            )) {
                if (-not $text.Contains($required)) { throw "Missing player-APK log: $required" }
                Write-Output "PASS packaged release log: $required"
            }
            if ($text.Contains('[tabletop.passthrough.weather.preview]')) {
                throw 'Retired Package 43 weather preview remains in player APK'
            }
            if ($text.Contains('debug.savr.tabletop_far_beacons') -or
                $text.Contains('WPYNT_VR')) {
                throw 'Retired custom pause-map waypoint remains in player APK'
            }
            if (-not $text.Contains('loading=%d')) {
                throw 'Missing Package 46 loading passthrough audit marker'
            }
            Write-Output 'PASS manual weather preview removed from player APK'
            Write-Output "PASS APK/native SHA256 $actual"
        } finally { $stream.Dispose(); $memory.Dispose() }
    } finally { $zip.Dispose() }
}
if ($found -ne 1) { throw "Expected one arm64 APK carrying libsavr.so, found $found" }
Write-Output 'PASS player APK telemetry audit (does not prove runtime hook execution)'
