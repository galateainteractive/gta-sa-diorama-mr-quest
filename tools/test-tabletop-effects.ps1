[CmdletBinding()]
param(
    [string]$Validator = '',
    [string]$Objdump = '',
    [Parameter(Mandatory = $true)][string]$LibGame
)
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sdkRoot = Join-Path ([IO.Path]::GetPathRoot($projectRoot)) 'Android\Sdk'
if ([string]::IsNullOrWhiteSpace($Validator)) {
    $Validator = Join-Path $sdkRoot 'emulator\lib64\vulkan\glslangValidator.exe'
}
if ([string]::IsNullOrWhiteSpace($Objdump)) {
    $Objdump = Join-Path $sdkRoot 'ndk\27.2.12479018\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-objdump.exe'
}

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

# Pause-map grip zoom remains isolated from marker creation. Package 46 removes
# the experimental compositor beacon for a user-placed map point; GTA's own
# blip stays inside the retail map and official world markers remain untouched.
$mapSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\MapZoom.cpp')
foreach ($sourcePattern in @('OnMapUpdate\(float dt\)',
                             'g_gripR.*?kGripOn',
                             'g_gripL.*?kGripOn',
                             'ReadF\(0x78\)',
                             'WriteF\(0x78, next\)')) {
    if ($mapSource -notmatch $sourcePattern) {
        throw "Pause-map zoom source audit failed: $sourcePattern"
    }
}
if ($mapSource -match 'NavigationWaypoint|ReadI\(0x68\)|ReadF\(0x84\)|ReadF\(0x88\)') {
    throw 'Retired custom pause-map waypoint publisher remains in source'
}
Write-Output 'PASS pause-map grip zoom retained and custom waypoint publisher removed'
$xrSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\src\Xr.cpp')
if ($xrSource -notmatch 'kPassthroughWeatherIntensity\s*=\s*3\.0f' -or
    $xrSource -match 'NavigationWaypoint|FarNavigation|tabletop_far_beacons' -or
    $xrSource -notmatch 'SnapshotObjectiveMarkers\(' -or
    $xrSource -notmatch 'RebaseObjectiveMarkersToTabletopMask\(') {
    throw 'Package 46 official-marker/custom-waypoint isolation audit failed'
}
Write-Output 'PASS official marker pipeline retained and custom waypoint beacon removed'

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
        'const bool (?:resetChordHeld|viewChordHeld) = input\.l3 && input\.r3',
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

# Package 45 retires the successful manual preview and places the existing
# opaque theater menu over passthrough. Package 49 supersedes its temporary R3
# radius assignment. The GameThread publishes menu state atomically so XR never
# reads GTA UI memory.
if ($xrSource -match 'PassthroughWeatherPreview|CyclePassthroughWeatherPreview' -or
    $cameraSource -notmatch 'g_mobileMenuOpenSnapshot\.store\(mobileMenuOpen' -or
    $xrSource -notmatch 'submitMenuPassthrough' -or
    $xrSource -notmatch '(?s)submitMenuPassthrough\s*=.*?IsMobileMenuOpen\(\).*?GameSurface' -or
    $xrSource -notmatch 'if \(submitTabletopPassthrough\)') {
    throw 'Package 45 menu passthrough/weather-preview retirement audit failed'
}
Write-Output 'PASS Package 45 menu-only passthrough and retired weather preview'

# Package 46 starts at the requested small/far tabletop scale and translation-
# following Track view. Loading hides its opaque retail quad only when an active
# passthrough backend can replace it; menus and cutscenes remain classified out.
$tabletopSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\Tabletop.cpp')
$defaultsSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'defaults\quest\vr_tabletop.ini')
foreach ($sourcePattern in @(
        'visual_scale=0\.010',
        'farthest/smallest tabletop zoom')) {
    if ($defaultsSource -notmatch $sourcePattern) {
        throw "Package 46 default scale audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'float visualScale\{0\.01f\}',
        'std::atomic<float> g_visualScale\{0\.01f\}',
        '(?s)loadedSettingsFile.*?0\.040f.*?0\.010f')) {
    if ($tabletopSource -notmatch $sourcePattern) {
        throw "Package 46 scale migration audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'TabletopViewMode mode\{TabletopViewMode::Track\}',
        'g_tabletopTransform\.mode = TabletopViewMode::Track',
        'g_loadingScreenSnapshot\.store\(loadingScreen',
        '!mobileMenuOpen && !cutsceneRunning',
        'bool IsLoadingScreenActive\(\)')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 46 Track/loading classification audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'loadingPassthroughOnly',
        'vrcam::IsLoadingScreenActive\(\)',
        'const bool submitLoadingPassthrough = loadingPassthroughOnly',
        'submitTabletopPassthrough \|\| submitMenuPassthrough \|\|')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 46 loading passthrough audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 46 far zoom, Track start, safe loading passthrough and waypoint removal'

# Package 47 keeps story video on GTA's finite theater quad but submits the
# room behind it, restores conventional tabletop plane pitch regardless of a
# saved immersive yoke, and makes Track follow aircraft horizontally only.
foreach ($sourcePattern in @(
        'g_cutsceneRunningSnapshot\.store\(cutsceneRunning',
        'bool IsCutsceneActive\(\)',
        'trackAircraftAltitudeValid',
        'trackAircraftAltitudeZ',
        '(?s)TabletopViewMode::Track.*?GetActiveVehicleType\(\).*?VEHICLE_PLANE.*?anchorBase\.pos\.z')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 47 cutscene/aircraft Track audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'const bool submitCutscenePassthrough',
        'vrcam::IsCutsceneActive\(\)',
        'submitCutscenePassthrough \|\| submitLoadingPassthrough')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 47 cutscene passthrough audit failed: $sourcePattern"
    }
}
if ($drivingSource -notmatch
        '(?s)appearance==5&&vrcam::IsTabletopActive\(\).*?ReadMappedGameplaySticks.*?-std::clamp\(moveY') {
    throw 'Package 47 tabletop airplane pitch override audit failed'
}
Write-Output 'PASS Package 47 cutscene surround, tabletop plane pitch and aircraft altitude Track'

# Package 48 keeps transparent water inside the same physical tabletop fade by
# supplementing only seabed-derived depth pixels with a retail-confirmed water
# plane intersection. The process-start property isolates the experiment.
$symbolsHeader = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\Symbols.h')
$symbolsSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\Symbols.cpp')
foreach ($sourcePattern in @(
        'CWaterLevel_GetWaterLevelNoWaves',
        'GetWaterLevelNoWavesEfffPfS0_S0_')) {
    if (($symbolsHeader + $symbolsSource) -notmatch $sourcePattern) {
        throw "Package 48 retail water lookup audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'debug\.savr\.tabletop_water_mask',
        'waterSurfaceActive = true',
        '(?s)TabletopWorldPointToLocalTracking.*?waterZ')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 48 water-state audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'uWaterPoint,uWaterNormal',
        'below>max\(0\.002,uDepthScale\*0\.5\)',
        'a=max\(a,coverage\(uEye\+ray\*t\)\)',
        'mask\.waterSurfaceActive \? 1 : 0')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 48 compositor water-plane audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 48 depth-safe tabletop water-surface mask'

# Package 49 promotes the headset-proven production profile: 60 m around the
# live player/vehicle, no normal coverage/radius cycling, and plain R3 camera
# cycling with a short compositor status line. Physical two-grip scale remains.
foreach ($sourcePattern in @(
        'constexpr int kOfficialRadiusPreset = 1',
        'loaded\.radiusPreset = kOfficialRadiusPreset',
        'g_radiusPreset\.store\(kOfficialRadiusPreset')) {
    if ($tabletopSource -notmatch $sourcePattern) {
        throw "Package 49 official radius audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'r3Edge && gripsFree && !input\.l3',
        'TabletopViewMode::Track:[\s\S]*?TabletopViewMode::Follow',
        'PublishStatusText\(status, 2\.0f\)',
        'TabletopCoverageMode::PlayerOnly')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 49 camera/coverage audit failed: $sourcePattern"
    }
}
if ($cameraSource -match 'coverageChord' -or
    $cameraSource -match '(?s)r3Edge.*?CycleRadiusPreset\(\)' -or
    $mainSource -notmatch '!tabletop::Enabled\(\).*?!cutsceneCameras') {
    throw 'Package 49 still exposes an old coverage/radius chord or tabletop vehicle-camera conflict'
}
foreach ($sourcePattern in @(
        'std::u16string status',
        'statusUntilNs',
        'void PublishStatusText\(const char\* text, float durationSeconds\)')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 49 status-text audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 49 fixed 60m coverage, R3 cameras and transient status text'

# Package 50 reassigns plain R3 to a radial owned-weapon selector, moves the
# production camera cycle to L3+R3, and mirrors Meta's system recenter only
# after OpenXR's LOCAL-space change time becomes effective.
foreach ($sourcePattern in @(
        'g_tabletopWeaponSelectorActive',
        'ReadTabletopWeaponInventory',
        'std::atan2\(sx, sy\)',
        'CPed_SetCurrentWeaponSlot\(selectorPed, selected\)',
        'viewChordHeld = input\.l3 && input\.r3')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 50 weapon-selector control audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'void SetWeaponSelector\(',
        'void BuildWeaponSelector\(\)',
        'R3 EQUIP AND CLOSE',
        'XR_TYPE_EVENT_DATA_REFERENCE_SPACE_CHANGE_PENDING',
        'g_systemRecenterPendingTime',
        'bool ConsumeSystemRecenter\(\)')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 50 selector/recenter compositor audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'xr::ConsumeSystemRecenter\(\)',
        'vrcam::WeaponSelectorActive\(\)',
        'DIORAMA RECENTERED')) {
    if ($mainSource -notmatch $sourcePattern) {
        throw "Package 50 GameThread input audit failed: $sourcePattern"
    }
}
$cmakeSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'native\CMakeLists.txt')
$buildSource = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'tools\build.ps1')
if ($cmakeSource -notmatch 'c\+\+_static\s+c\+\+abi' -or
    $buildSource -notmatch "-DANDROID_STL=c\+\+_static") {
    throw 'Package 50 space-safe Android libc++ link audit failed'
}
Write-Output 'PASS Package 50 weapon selector, camera chord, Meta recenter and space-safe Android link'

# Package 51 moves the selector into the right-controller late HUD, preserves
# the full miniature transform across camera modes, and feeds X into Android's
# dedicated held + just-down melee queries.
$vrFireSource = Get-Content -Raw -LiteralPath (
    Join-Path $projectRoot 'native\src\VrFire.cpp')
foreach ($sourcePattern in @(
        'EnsureWeaponSelectorTexture\(\)',
        'DrawTabletopControllerTexturePanel\(',
        'g_weaponSelectorTextureRevision',
        '0\.18f, 0\.24f, true, rp',
        'std::memset\(g_panelPixels, 0, sizeof\(g_panelPixels\)\)')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 51 right-controller selector audit failed: $sourcePattern"
    }
}
if ($xrSource -match
        '(?s)g_aboutActive\.load.*?\|\|\s*g_weaponSelectorActive.*?PresentDebugPanel') {
    throw 'Package 51 selector is still submitted as a head-locked debug quad'
}
foreach ($sourcePattern in @(
        'viewTransitionPending',
        'continuous view transition',
        'TabletopGameToTracking\(oldAnchor, gameAnchorDelta, oldYaw\)',
        'oldYaw \+ oldHeading - newHeading')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 51 continuous camera audit failed: $sourcePattern"
    }
}
if ([regex]::Match($cameraSource,
        '(?s)void CycleTabletopView\(\).*?^\}',
        [Text.RegularExpressions.RegexOptions]::Multiline).Value -match
        'RequestTabletopRecenter') {
    throw 'Package 51 camera cycle still invokes a full recenter'
}
foreach ($sourcePattern in @(
        'CPad_GetMeleeAttack',
        'CPad_MeleeAttackJustDown')) {
    if (($symbolsHeader + $symbolsSource) -notmatch $sourcePattern) {
        throw "Package 51 melee symbol audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'OnPadGetMeleeAttack\(',
        'OnPadMeleeAttackJustDown\(',
        'IsTabletopClassicAttackHeld\(\)',
        'IsTabletopClassicAttackJustDown\(\)',
        'InstallPadSingleGateHook\(')) {
    if ($vrFireSource -notmatch $sourcePattern) {
        throw "Package 51 classic melee bridge audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 51 hand selector, continuous cameras and classic melee bridge'

# Package 52 makes the controller selector physically smaller while preserving
# readable radial labels, rebases camera transitions from the outgoing mode's
# current-frame anchor, and reserves Diorama right-stick turning for UI/vehicle
# input rather than rotating the miniature.
foreach ($sourcePattern in @(
        'constexpr float radius = 175\.0f',
        'PanelTextOutlined\(label, x, y, 2,',
        'PanelTextOutlined\(selectedName, cx, 218, 3,',
        '0\.18f, 0\.24f, true, rp')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 52 compact selector audit failed: $sourcePattern"
    }
}
foreach ($sourcePattern in @(
        'Reconstruct the anchor the outgoing mode would use in THIS frame',
        'transitionFromMode == TabletopViewMode::Fixed',
        'transitionFromMode ==\s*TabletopViewMode::Track',
        'tabletop::Enabled\(\) \|\| in\.thumbrest\[0\]')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Package 52 camera/input audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 52 compact selector, current-frame camera rebase and Diorama turn suppression'

# Package 53 raises the compact selector, widens its radial entries and adds a
# fully opaque outlined text path so bright GTA HUD/map content cannot wash it
# out without placing an opaque card behind the controller overlay.
foreach ($sourcePattern in @(
        'void PanelTextOutlined\(',
        'linear filtering from washing their edges',
        'constexpr float radius = 175\.0f',
        '0\.18f, 0\.24f, true, rp')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 53 selector contrast audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 53 raised selector, wider ring and opaque outlined labels'

# Package 54 keeps the current production bindings discoverable in-headset and
# prevents the fixed Diorama shortcuts from looking like ordinary remap rows.
foreach ($sourcePattern in @(
        'MENU > CONTROLS OPENS DIORAMA GUIDE',
        'L3 \+ R3  CHANGE VIEW',
        'META BUTTON  RECENTER',
        'DIORAMA CONTROL GUIDE',
        'R3  OPEN SELECTOR',
        'TRACK   FOLLOWS POSITION; ROOM HEADING',
        'FOLLOW  FOLLOWS POSITION \+ CJ / CAR',
        'FIXED   DIORAMA STAYS IN THE ROOM',
        'DIORAMA SHORTCUTS FIXED - B RETURNS TO GUIDE')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 54 in-headset control guide audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 54 in-headset production control guide'

# Package 55 abbreviates only long radial labels while retaining the complete
# selected weapon name in the centre block.
foreach ($sourcePattern in @(
        'const char\* WeaponSelectorRingName\(int type\)',
        'case 5:\s+return "BAT"',
        'case 24: return "DEAGLE"',
        'case 37: return "FLAMER"',
        'case 42: return "EXTING\."',
        'case 44: return "NV GOGGLES"',
        'const char\* label = WeaponSelectorRingName\(types\[slot\]\)',
        'const char\* selectedName = WeaponSelectorName\(types\[selected\]\)')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 55 compact radial-label audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 55 compact ring labels and full centre names'

# Package 56 introduced the copied Diorama help-string adapter. Package 57
# applies it to brief/help, while Package 60 also covers large messages and
# tolerates the formatting markers used by the retail bicycle lesson.
foreach ($sourcePattern in @(
        'std::u16string AdaptDioramaTutorialText\(std::u16string text,',
        'text\.empty\(\) \|\| !tabletop::Enabled\(\)',
        '~widget_enter_targeting~", u"L2"',
        '~widget_attack~", u"X / R2 WHILE AIMING"',
        '~widget_explicit_crouch~", u"L3"',
        '~widget_enter_car~", u"Y"',
        '~widget_explicit_bicycle~", u"Y"',
        '~widget_explicit_next_weapon~", u"R3 WEAPON SELECTOR"',
        '~widget_phone~", u"BOTH GRIPS \+ R2"',
        'Hold R2 to pedal\.',
        'Left Stick up and down to shift your weight',
        'no partial "tap" rewriting is allowed',
        '\[tabletop\.tutorial\] unmapped',
        '\[tabletop\.tutorial\] mobile-unmapped',
        'nextBig=AdaptDioramaTutorialText\(std::move\(nextBig\), "big"\)',
        'nextBrief=AdaptDioramaTutorialText\(\s*copyGxt',
        'nextHelp=AdaptDioramaTutorialText')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 56 Diorama tutorial audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 60 three-channel Diorama tutorial controls'

foreach ($sourcePattern in @(
        'constexpr int tipsRow = 0',
        'HOLD BOTH GRIPS \+ MENU \(OR Y\)')) {
    if (($xrSource + $mainSource) -notmatch $sourcePattern) {
        throw "Package 60 menu-discovery audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 60 first-row guide and menu-chord discovery text'

# Package 57 also replaces the crowded one-screen Diorama reference with two
# colour-grouped pages and keeps the first-run welcome focused on discovery.
foreach ($sourcePattern in @(
        'g_controlsTipsPage',
        'ON FOOT & DIORAMA - 1 / 2',
        'VIEWS & VEHICLES - 2 / 2',
        'L2 / R2  PAGE',
        'WELCOME TO GTA SAN ANDREAS DIORAMA MR',
        'DIORAMA MR IS THE DEFAULT MODE',
        'SELECT IMMERSIVE VR IN MAIN MENU > PLAY MODE',
        'DIORAMA MR BY GALATEA DIORAMA MODS',
        'IMMERSIVE VR BASE: GTA SAN ANDREAS VR QUEST',
        'BY THE ORIGINAL PORT CONTRIBUTORS',
        'LEARN THE CONTROLS',
        'MENU > CONTROLS OPENS DIORAMA GUIDE')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 57 control-guide audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 57 two-page control guide and focused welcome'

# Package 59 changes only tabletop stock cones: the original immersive fill
# remains, mission cylinders keep their established opacity, and Diorama uses
# a smaller hollow outline that cannot cover the target at its centre.
foreach ($sourcePattern in @(
        'constexpr float kTabletopConeOpacity = 0\.34f',
        'primitive = GL_LINES',
        'constexpr int railCount = 4',
        'restrainedCone \? 0\.022f : 0\.035f',
        'tabletopMode \? kTabletopConeOpacity : 1\.0f')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 59 hollow objective-cone audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 59 hollow low-opacity Diorama objective cones'

# Packages 61-63 established the retail text path. Production now keeps only
# the final adapter hook and explicitly retires the old queue and per-frame
# buffer diagnostics.
$fontPrint = (& $Objdump -d --start-address=0x5d6ec4 --stop-address=0x5d6ed4 $LibGame) -join "`n"
if ($LASTEXITCODE -ne 0) { throw 'CFont::PrintString disassembly failed' }
foreach ($word in @('d10183ff', '6d0223e9', 'a9037bfd', 'f90023f5')) {
    if ($fontPrint -notmatch $word) {
        throw "Package 63 CFont::PrintString prologue mismatch: $word"
    }
}
foreach ($sourcePattern in @(
        'InstallTutorialRenderAdapter\(\)',
        '_ZN5CFont11PrintStringEffPs',
        'kRetailOffset = 0x5d6ec4u',
        'former queue/buffer diagnostics are retired')) {
    if ($cameraSource -notmatch $sourcePattern) {
        throw "Production tutorial-adapter audit failed: $sourcePattern"
    }
}
foreach ($retiredPattern in @(
        'InstallTutorialQueueDiagnostic',
        'LogTutorialBufferSnapshot',
        '\[tabletop\.tutorial\.buffer\]',
        '\[tabletop\.tutorial\.queue\]',
        'kHelpTextBegin = 0x364414u')) {
    if ($cameraSource -match $retiredPattern) {
        throw "Retired production tutorial diagnostic remains: $retiredPattern"
    }
}
Write-Output 'PASS production final-font adapter with old tutorial diagnostics retired'

# Package 64 turns the validated global CFont boundary into a conservative
# Diorama-only adapter. It must retain a fast content prefilter, a shell escape
# hatch, an explicit branded prefix and mode-specific Controls navigation.
foreach ($sourcePattern in @(
        'LooksLikeDioramaTouchTutorial',
        'leaves them byte-for-byte unchanged',
        'debug\.savr\.diorama_tutorials',
        'AdaptDioramaTutorialForStockRender',
        '~p~DIORAMA MR TIP~w~:',
        'mode=global-content-filter',
        'CUSTOMIZE CONTROLS',
        'A  CUSTOMIZE CONTROLS',
        'menuPage = PG_CONTROLS_TIPS')) {
    if (($xrSource + $cameraSource + $mainSource) -notmatch $sourcePattern) {
        throw "Package 64 final tutorial/control-discovery audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 64 filtered tutorials and guide-first Controls'

# Package 65 fixes the brand-new-install reminder handoff and expands only the
# exact opening Android tutorials proven in the official English GXT. Generic
# touch wording is diagnostic-only; only known widget prompts normalise Tap to
# Press after a successful control replacement.
foreach ($sourcePattern in @(
        'Use the Left Stick to move Carl\.',
        'Walk into the red marker to continue\. Hold B to sprint\.',
        'Press R3 to open the weapon selector\.',
        'Press X to perform a melee attack\.',
        '~widget_camera~", u"L3 \+ R3"',
        '~widget_reply_yes~", u"R2"',
        '~widget_reply_no~", u"L2"',
        'Normalise Android''s touch verb only in that proven case',
        '"tap ", "swipe ", "weapon icon"')) {
    if (($xrSource + $cameraSource + $mainSource) -notmatch $sourcePattern) {
        throw "Package 65 opening-tutorial/reminder audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 65 exact opening tutorials'

# Package 66 replaces the unreliable transient HUD notice with one persistent,
# cached and transparent banner over every GTA frontend/pause menu.
foreach ($sourcePattern in @(
        'void BuildFrontendMenuHint\(\)',
        'DIORAMA MR MENU',
        'HOLD BOTH GRIPS \+ MENU \(OR Y\)',
        'OPEN VR SETTINGS AND CONTROLS',
        'const bool frontendHint = !configuredPanel',
        'constexpr std::uint64_t kFrontendHintRevision',
        'const bool cacheablePanel = profilerPanel \|\| frontendHint',
        'const bool frontendMenuHint = tabletop::Enabled\(\)')) {
    if ($xrSource -notmatch $sourcePattern) {
        throw "Package 66 persistent frontend hint audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 66 persistent cached GTA-menu discovery banner'

# Package 68 retires the Package 67 procedural-plant experiment after headset
# validation showed no visible change. The proven Release telemetry cleanup is
# retained, while no DrawTriPlants hook or plant-colour mutation may ship.
foreach ($retiredPattern in @(
        'OnTabletopDrawTriPlants',
        'g_origTabletopDrawTriPlants',
        'kPPTriPlantBlackThreshold')) {
    if ($cameraSource -match $retiredPattern) {
        throw "Package 68 retired plant experiment remains: $retiredPattern"
    }
}
foreach ($sourcePattern in @(
        '#if defined\(SAVR_DEV\)\s*// Package 32 diagnostic witness',
        '#if defined\(SAVR_DEV\)\s*void ObserveTabletopMaskInputs',
        '#if defined\(SAVR_DEV\)\s*if \(tabletop::PassthroughEnabled\(\)\)')) {
    if (($cameraSource + $xrSource) -notmatch $sourcePattern) {
        throw "Package 67 Release-telemetry retirement audit failed: $sourcePattern"
    }
}
Write-Output 'PASS Package 68 plant experiment retired and Release telemetry remains quiet'

# Package 72 removes both exhausted runtime isolators and suppresses the source
# ProcObjectMan creation callback for one diagnostic build. This does not depend
# on an entity wrapper, an RpAtomic model index or a controller timing window.
foreach ($retiredPattern in @(
        'PlantDiagnosticMode',
        'OnDiagnosticDrawTriPlants',
        'CyclePlantDiagnosticMode',
        'PLANT TEST: NO PROCEDURAL\"',
        'PLANT TEST: NO STATIC VEGETATION',
        '\[tabletop\.plant_ab\]',
        'PlantModelIsolatorState',
        'ProcessPlantModelIsolatorEntity',
        'kPlantModelCaptureRadiusM',
        '\[tabletop\.model_isolator\]',
        'ProceduralPlantIsolatorState',
        'ProcessProceduralPlantAtomic',
        'CVisibilityPlugins_GetModelInfoIndex',
        '\[tabletop\.procedural_plant\]',
        'modelIsolatorAdvance',
        'modelIsolatorReset')) {
    if (($cameraSource + $mainSource) -match $retiredPattern) {
        throw "Package 72 retired diagnostic remains: $retiredPattern"
    }
}
foreach ($sourcePattern in @(
        'using ProcessProceduralTriangleFn = int \(\*\)\(void\*, void\*\)',
        'int OnProcessProceduralTriangle\(void\* manager, void\* triangle\)',
        'if \(tabletop::Enabled\(\)\) return 0;',
        '_ZN15ProcObjectMan_c20ProcessTriangleAddedEP12CPlantLocTri',
        'g\.LoadBase == 0x53e168u',
        'kProcessProceduralTrianglePrologue',
        'proc_source_test=%d')) {
    if (($cameraSource + $mainSource) -notmatch $sourcePattern) {
        throw "Package 72 ProcObject source suppression audit failed: $sourcePattern"
    }
}
if (([regex]::Matches($cameraSource,
        'InstallTrampoline\(\s*processProceduralTriangle,')).Count -ne 1) {
    throw 'Package 72 must install exactly one ProcObject source hook'
}
foreach ($forbiddenPattern in @(
        'kPPTriPlantBlackThreshold',
        'g_tabletopPlantAmbientColor',
        'g_tabletopPlantRenderStateGet')) {
    if ($cameraSource -match $forbiddenPattern) {
        throw "Package 72 reintroduced plant mutation: $forbiddenPattern"
    }
}
Write-Output 'PASS Package 72 direct ProcObject source suppression'
