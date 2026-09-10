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

# Package 39 keeps combat on GTA's classic task, but supplies a complete
# mobile target-widget lifecycle and a context-gated modern trigger alias.
$cameraSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\VrCamera.cpp')
$fireSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\VrFire.cpp')
$mainSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\main.cpp')
foreach ($sourcePattern in @('TabletopModernAimRaw\(',
                             'TabletopModernAttackForCombat\(',
                             'target widget justpressed=.*bridge=L2',
                             'target widget released=1 bridge=L2')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 39 target bridge audit failed: $sourcePattern"
    }
}
if ($cameraSource -match 'target widget .*bridge=none' -or
    $fireSource -notmatch 'IsTabletopModernAttackActive\(' -or
    $fireSource -notmatch 'targets=lock:%p/free:%p' -or
    $fireSource -notmatch 'route=classic_pad_target_no_physical_ray' -or
    $mainSource -notmatch 'attackHeld \|\| modernTriggerAttack' -or
    $cameraSource -notmatch 'tabletopCombatReleaseGate') {
    throw 'Package 39 modern combat routing audit failed'
}
Write-Output 'PASS Package 39 L2 target lifecycle, R2 attack and prompt isolation'

# Package 40 corrects the first headset finding: controller missions bypass the
# mobile widget and call CPad targeting directly. R2 must therefore depend only
# on the physical L2+R2 chord, while nearby-ped safety includes CJ's centre.
foreach ($sourcePattern in @('_ZN4CPad9GetTargetEb',
                             '_ZN4CPad17GetEnterTargetingEv',
                             '_ZN4CPad16GetExitTargetingEv',
                             'direct pad targeting active=',
                             '(?s)return TabletopModernAimRaw\(in\).*?in\.triggers\[1\]',
                             'pedPlayerDistSq < pedSafetySq')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 40 direct targeting/ped safety audit failed: $sourcePattern"
    }
}
$attackBody = [regex]::Match(
    $cameraSource,
    '(?s)bool TabletopModernAttackForCombat\([^)]*\)\s*\{(?<body>.*?)\n\}')
if (-not $attackBody.Success -or
    $attackBody.Groups['body'].Value -match 'TabletopModernAimForCombat') {
    throw 'Package 40 R2 still depends on a widget/target poll'
}
Write-Output 'PASS Package 40 direct CPad targeting, independent R2 and CJ ped safety'

# Package 41 makes the controller layout fit Quest's split face buttons and
# makes targeting edges frame-coherent instead of first-caller one-shots.
$locomotionSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\Locomotion.cpp')
$drivingSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\Driving.cpp')
foreach ($sourcePattern in @(
        '(?s)kBindingDefault\[BIND_SRC_COUNT\].*?BIND_ACT_JUMP,\s*BIND_ACT_SPRINT,\s*BIND_ACT_ATTACK,\s*BIND_ACT_ENTER',
        'BindingsVersion=%d',
        'kBindingLegacyDefault',
        'migrated Quest bindings')) {
    if ($locomotionSource -notmatch $sourcePattern) {
        throw "Package 41 Quest binding/migration audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'viewChord = input\.grip\[0\].*?l3Edge',
        'suppressL3UntilRelease',
        'if \(suppressL3UntilRelease\) input\.l3 = false',
        'g_tabletopAimPressFrame',
        'g_tabletopAimReleaseFrame',
        'currentFrame == g_tabletopAimReleaseFrame',
        'frame=%u bridge=L2')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 41 tabletop control/aim audit failed: $sourcePattern"
    }
}
if ($cameraSource -match '(?m)^\s*input\.l3 = false;' -or
    $drivingSource -notmatch '!vrcam::IsTabletopActive\(\).*?input\.triggers\[1\]') {
    throw 'Package 41 still consumes plain L3 or lets tabletop R2 sprint'
}
Write-Output 'PASS Package 41 Quest bindings, crouch ownership and frame-coherent L2 release'

# Package 42 promotes only a compact once-per-window aggregate and event-driven
# thermal transitions into player logs. Full CSV/dev telemetry stays disabled.
$perfSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\PerfTelemetry.cpp')
foreach ($sourcePattern in @(
        '\[tabletop\.perf42\]',
        'g_debugStats\.renderedHz\.load',
        'w\.last\.runtimeGpuValid \? metaGpu',
        'w\.waitFrame\.P95\(\)',
        'w\.work\.P95\(\)',
        'w\.endFrame\.P95\(\)',
        'w\.writeFenceWaitTimeouts')) {
    if ($perfSource -notmatch $sourcePattern) {
        throw "Package 42 bounded performance audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        '\[tabletop\.perf42\.init\]',
        '\[tabletop\.perf42\.thermal\]',
        'XR_TYPE_EVENT_DATA_PERF_SETTINGS_EXT')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 42 runtime/thermal audit failed: $sourcePattern"
    }
}
if ($perfSource -match '(?s)void SubmitPresentFrame\([^)]*\).*?\[tabletop\.perf42\]') {
    throw 'Package 42 diagnostic escaped the one-second aggregate into the per-frame path'
}
Write-Output 'PASS Package 42 bounded release XR/GPU and thermal diagnostics'

# Package 44 strengthens the three palettes identified on-headset while keeping
# clear weather neutral and making low GTA rain transitions visible sooner.
foreach ($sourcePattern in @(
        '-0\.010f, 0\.025f, 1\.04f.*0\.40f',
        '-0\.035f, -0\.105f, 0\.78f.*0\.16f',
        '-0\.065f, -0\.130f, 0\.68f.*0\.24f',
        'cloudWeight = Smoothstep',
        '0\.15f, 0\.85f.*state\.clouds',
        'rainWeight = Smoothstep',
        '0\.0f, 0\.45f.*state\.rain')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 44 weather tuning audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 44 stronger dawn, overcast and rain response'

# Package 45 retires the successful manual preview, restores plain R3 radius
# selection and places the existing opaque theater menu over passthrough. The
# GameThread publishes menu state atomically so XR never reads GTA UI memory.
if ($xrSource -match 'PassthroughWeatherPreview|CyclePassthroughWeatherPreview' -or
    $cameraSource -notmatch '(?s)r3Edge.*?CycleRadiusPreset\(\)' -or
    $cameraSource -notmatch 'g_mobileMenuOpenSnapshot\.store\(MobileMenuOpen\(\)' -or
    $xrSource -notmatch 'submitMenuPassthrough' -or
    $xrSource -notmatch '(?s)submitMenuPassthrough\s*=.*?IsMobileMenuOpen\(\).*?GameSurface' -or
    $xrSource -notmatch 'if \(submitTabletopPassthrough\)') {
    throw 'Package 45 menu passthrough/R3 restoration audit failed'
}
Write-Output 'PASS Package 45 menu-only passthrough and plain R3 radius restore'
