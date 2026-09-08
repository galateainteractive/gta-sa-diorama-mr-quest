[CmdletBinding()]
param(
    [string]$Validator = 'D:\Android\Sdk\emulator\lib64\vulkan\glslangValidator.exe',
    [string]$Objdump = 'D:\Android\Sdk\ndk\27.2.12479018\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-objdump.exe',
    [Parameter(Mandatory = $true)][string]$LibGame
)
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

# Compile the real embedded shaders, not a retyped test approximation.
$source = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\Xr.cpp')
$start = $source.IndexOf('bool EnsureTabletopAlphaProgram()')
$end = $source.IndexOf('const GLuint vertex =', $start)
if ($start -lt 0 -or $end -lt $start) { throw 'Mask shader block not found' }
$block = $source.Substring($start, $end - $start)
foreach ($stage in @(@('vs', 'vert'), @('fs', 'frag'))) {
    $pattern = '(?s)const char\* ' + $stage[0] + ' = (.*?);\s*(?:const char\*|$)'
    $literals = [regex]::Match($block, $pattern).Groups[1].Value
    if (-not $literals) { throw 'Mask shader extraction failed' }
    $shader = ([regex]::Matches($literals, '"((?:[^"\\]|\\.)*)"') |
        ForEach-Object { [regex]::Unescape($_.Groups[1].Value) }) -join ''
    $shader | & $Validator --stdin -S $stage[1]
    if ($LASTEXITCODE -ne 0) { throw "Mask $($stage[1]) compilation failed" }
    Write-Output "PASS actual mask $($stage[1]) shader"
}

# Check the hook's exact retail ABI target, PLT/GOT slot and caller whitelist
# against the user's verified binary. This does not modify or execute it.
$expectedHash = '4C6A7445E30B27AFDDA781302E4DB9BAC89C28FC1181B68B1EEF16F84D6A282E'
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $LibGame).Hash -ne $expectedHash) {
    throw 'Unsupported retail libGame; do not use audited offsets'
}
$plt = (& $Objdump -d --start-address=0x800a40 --stop-address=0x800a50 $LibGame) -join "`n"
if ($LASTEXITCODE -ne 0) { throw 'PLT disassembly failed' }
foreach ($word in @('90000230', 'f947b211', '913d8210', 'd61f0220')) {
    if ($plt -notmatch $word) { throw "AddSparks PLT mismatch: $word" }
}
foreach ($call in @(0x4a2280, 0x6dfb74, 0x6e34fc)) {
    $startArg = '--start-address=0x{0:x}' -f $call
    $endArg = '--stop-address=0x{0:x}' -f ($call + 4)
    $code = (& $Objdump -d $startArg $endArg $LibGame) -join "`n"
    if ($LASTEXITCODE -ne 0 -or $code -notmatch 'bl\s+0x800a40.*AddSparks') {
        throw ('Scrape call-site mismatch: 0x{0:x}' -f $call)
    }
}
Write-Output 'PASS retail hash, spark PLT and three scoped call sites'

# Pause-map waypoint source: PlaceRedMarker reads the map cursor at +0x84/+0x88,
# creates the coordinate blip and stores its handle at +0x68. The tabletop code
# only observes these values; it does not replace retail marker creation.
$waypoint = (& $Objdump -d --start-address=0x71bbac --stop-address=0x71bc74 $LibGame) -join "`n"
foreach ($word in @('b9406a68', '2d508660', 'b9006a60')) {
    if ($waypoint -notmatch $word) { throw "PlaceRedMarker layout mismatch: $word" }
}
if ($waypoint -notmatch 'SetCoordBlip' -or $waypoint -notmatch 'SetBlipSprite') {
    throw 'PlaceRedMarker waypoint calls mismatch'
}
$mapSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\MapZoom.cpp')
foreach ($sourcePattern in @('ReadI\(0x68\)', 'ReadF\(0x84\)', 'ReadF\(0x88\)',
                             'SetNavigationWaypoint\(valid')) {
    if ($mapSource -notmatch $sourcePattern) {
        throw "Waypoint source audit failed: $sourcePattern"
    }
}
Write-Output 'PASS retail pause-map waypoint handle and coordinate layout'
$xrSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\Xr.cpp')
if ($xrSource -notmatch 'kPassthroughWeatherIntensity\s*=\s*3\.0f' -or
    $xrSource -notmatch 'AppendNavigationWaypoint\(' -or
    $xrSource -notmatch 'kFarNavigationTruePositionRadiusFactor\s*=\s*3\.0f') {
    throw 'Package 38 navigation/weather source audit failed'
}
Write-Output 'PASS Package 38 navigation range and weather validation intensity'
