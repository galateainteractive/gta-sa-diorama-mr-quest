[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$BuildRoot
)
$ErrorActionPreference = 'Stop'
$native = Join-Path $BuildRoot 'native\libsavr.so'
$cache = Join-Path $BuildRoot 'native\CMakeCache.txt'
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
                '[tabletop.flicker.fix] package=34',
                '[tabletop.flicker.fix] retained=',
                '[tabletop.flicker.identity] membership=v2',
                '[tabletop.flicker.alpha_depth]',
                '[tabletop.flicker.mask_window] package=34',
                'window_frames=%u failed_masks=',
                '[tabletop.aim] attack edge',
                '[tabletop.aim.area]'
            )) {
                if (-not $text.Contains($required)) { throw "Missing player-APK log: $required" }
                Write-Output "PASS packaged release log: $required"
            }
            Write-Output "PASS APK/native SHA256 $actual"
        } finally { $stream.Dispose(); $memory.Dispose() }
    } finally { $zip.Dispose() }
}
if ($found -ne 1) { throw "Expected one arm64 APK carrying libsavr.so, found $found" }
Write-Output 'PASS player APK telemetry audit (does not prove runtime hook execution)'
