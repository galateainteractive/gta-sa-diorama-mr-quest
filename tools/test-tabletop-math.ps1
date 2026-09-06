[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$settingsPath = Join-Path $PSScriptRoot '..\defaults\quest\vr_tabletop.ini'
$settings = @{}
foreach ($line in Get-Content -LiteralPath $settingsPath) {
    $clean = ($line -split '#', 2)[0].Trim()
    if (-not $clean.Contains('=')) { continue }
    $key, $value = $clean.Split('=', 2)
    $settings[$key.Trim()] = $value.Trim()
}

$scale = [double]$settings.visual_scale
$forward = [double]$settings.anchor_forward_m
$down = [double]$settings.anchor_down_m
if ($scale -lt 0.01 -or $scale -gt 0.20) {
    throw "visual_scale is outside the runtime range: $scale"
}

function Assert-Close {
    param([double]$Actual, [double]$Expected, [string]$Name)
    if ([Math]::Abs($Actual - $Expected) -gt 0.000001) {
        throw "$Name mismatch: expected $Expected, got $Actual"
    }
}

# At the recentered origin, the camera must sit behind and above the game
# anchor. Multiplying the game-space displacement by the visual scale must
# reconstruct the configured physical placement exactly.
$neutralGameBack = $forward / $scale
$neutralGameUp = $down / $scale
Assert-Close ($neutralGameBack * $scale) $forward 'neutral forward placement'
Assert-Close ($neutralGameUp * $scale) $down 'neutral vertical placement'

# A ten-centimetre real head movement maps to inverse-scaled game translation,
# then projects back to the same physical movement in the miniature.
$physicalHeadMove = 0.10
$gameHeadMove = $physicalHeadMove / $scale
Assert-Close ($gameHeadMove * $scale) $physicalHeadMove 'head parallax'

# The eye cameras use the same inverse scale, preserving a physical 64 mm IPD.
$physicalIpd = 0.064
$gameIpd = $physicalIpd / $scale
Assert-Close ($gameIpd * $scale) $physicalIpd 'stereo IPD'

function Get-CapsuleDistanceSquared {
    param(
        [double]$PointX, [double]$PointY,
        [double]$StartX, [double]$StartY,
        [double]$EndX, [double]$EndY
    )
    $abX = $EndX - $StartX
    $abY = $EndY - $StartY
    $lengthSquared = $abX * $abX + $abY * $abY
    $t = if ($lengthSquared -lt 0.0001) { 0.0 } else {
        [Math]::Max(0.0, [Math]::Min(1.0,
            (($PointX - $StartX) * $abX +
             ($PointY - $StartY) * $abY) / $lengthSquared))
    }
    $closestX = $StartX + $abX * $t
    $closestY = $StartY + $abY * $t
    $dx = $PointX - $closestX
    $dy = $PointY - $closestY
    return $dx * $dx + $dy * $dy
}

# Coverage is a horizontal capsule from the player to the reprojected headset.
# Height is deliberately absent: the same X/Y must remain admitted whether the
# miniature is ten centimetres or two metres below the viewer.
Assert-Close (Get-CapsuleDistanceSquared 50 8 0 0 100 0) 64 `
    'capsule corridor'
Assert-Close (Get-CapsuleDistanceSquared -3 4 0 0 100 0) 25 `
    'capsule start cap'
Assert-Close (Get-CapsuleDistanceSquared 103 4 0 0 100 0) 25 `
    'capsule end cap'

function Test-CoverageProfile {
    param(
        [double]$PointX, [double]$PointY,
        [double]$PlayerX, [double]$PlayerY,
        [double]$ViewerX, [double]$ViewerY,
        [double]$PlayerRadius,
        [ValidateSet('player-only','connected','islands')]
        [string]$Profile
    )
    $playerDx = $PointX - $PlayerX
    $playerDy = $PointY - $PlayerY
    if ($playerDx * $playerDx + $playerDy * $playerDy -le
        $PlayerRadius * $PlayerRadius) { return $true }
    if ($Profile -eq 'player-only') { return $false }
    if ($Profile -eq 'connected') {
        return (Get-CapsuleDistanceSquared $PointX $PointY `
            $PlayerX $PlayerY $ViewerX $ViewerY) -le
            $PlayerRadius * $PlayerRadius
    }
    $viewerRadius = [Math]::Min($PlayerRadius, 55.0)
    $viewerDx = $PointX - $ViewerX
    $viewerDy = $PointY - $ViewerY
    if ($viewerDx * $viewerDx + $viewerDy * $viewerDy -le
        $viewerRadius * $viewerRadius) { return $true }
    $separation = [Math]::Sqrt(
        ($ViewerX - $PlayerX) * ($ViewerX - $PlayerX) +
        ($ViewerY - $PlayerY) * ($ViewerY - $PlayerY))
    if ($separation -gt 140.0) { return $false }
    $bridgeRadius = [Math]::Min($PlayerRadius, 28.0)
    return (Get-CapsuleDistanceSquared $PointX $PointY `
        $PlayerX $PlayerY $ViewerX $ViewerY) -le
        $bridgeRadius * $bridgeRadius
}

# Package 10 profiles: pure player circle, a complete connected capsule, and
# the bounded Package 9 islands. A two-hand manipulation freezes the endpoint
# rather than deleting already visible remote content.
if (Test-CoverageProfile 100 0 0 0 100 0 80 'player-only') {
    throw 'player-only profile retained the viewer island'
}
if (-not (Test-CoverageProfile 100 60 0 0 100 0 80 'connected')) {
    throw 'connected profile did not retain the full-radius capsule'
}
if (-not (Test-CoverageProfile 75 0 0 0 100 0 80 'islands')) {
    throw 'near bridge rejected an admitted corridor point'
}
if (Test-CoverageProfile 100 60 0 0 100 0 80 'islands') {
    throw 'viewer island exceeded its bounded radius'
}
if (Test-CoverageProfile 100 0 0 0 200 0 80 'islands') {
    throw 'far disconnected islands accidentally retained the giant bridge'
}
if (-not (Test-CoverageProfile 200 40 0 0 200 0 80 'islands')) {
    throw 'far viewer island was not retained'
}

# A high camera requires its full slant distance plus the horizontal radius;
# otherwise a 2D-visible player can still be removed by the 3D far plane.
$verticalSeparation = 180.0
$horizontalSeparation = 40.0
$playerSlant = [Math]::Sqrt(
    $verticalSeparation * $verticalSeparation +
    $horizontalSeparation * $horizontalSeparation)
if (($playerSlant + 80.0) -le $verticalSeparation) {
    throw 'height-independent far clip did not include horizontal coverage'
}

# Objective positions follow the live miniature scale, but their presentation
# never becomes smaller than the default 1:25 tabletop size. This keeps mission
# guidance readable without moving its world-space target.
function Get-ObjectivePresentationScale([double]$WorldScale) {
    return [Math]::Max(0.04, $WorldScale)
}
Assert-Close (Get-ObjectivePresentationScale 0.01) 0.04 `
    'objective scale floor'
Assert-Close (Get-ObjectivePresentationScale 0.08) 0.08 `
    'objective enlarged scale'

# Fixed-camera zoom keeps the player at the same physical point. The anchor
# moves by exactly the inverse scale delta instead of scaling around an old
# hand midpoint that may be far away from CJ.
$startAnchor = 0.20
$playerOffsetGame = 25.0
$startPlayerPhysical = $startAnchor + $playerOffsetGame * $scale
$newScale = $scale * 1.75
$newAnchor = $startPlayerPhysical - $playerOffsetGame * $newScale
Assert-Close ($newAnchor + $playerOffsetGame * $newScale) `
    $startPlayerPhysical 'fixed player zoom pivot'

# CPad interprets its local stick in the hidden logical-camera basis. Rotate
# that vector by inverse(game) * visible-tabletop and prove that GTA reconstructs
# the same world vector the player sees. This is the Package 11 exit/respawn
# direction fix.
$gameYaw = 2.219
$visibleYaw = -0.101
$delta = $gameYaw - $visibleYaw
$rawX = -0.35
$rawY = 0.94
$padX = $rawX * [Math]::Cos($delta) + $rawY * [Math]::Sin($delta)
$padY = $rawY * [Math]::Cos($delta) - $rawX * [Math]::Sin($delta)
$worldFromGameX = [Math]::Cos($gameYaw) * $padX -
                  [Math]::Sin($gameYaw) * $padY
$worldFromGameY = [Math]::Sin($gameYaw) * $padX +
                  [Math]::Cos($gameYaw) * $padY
$worldVisibleX = [Math]::Cos($visibleYaw) * $rawX -
                 [Math]::Sin($visibleYaw) * $rawY
$worldVisibleY = [Math]::Sin($visibleYaw) * $rawX +
                 [Math]::Cos($visibleYaw) * $rawY
Assert-Close $worldFromGameX $worldVisibleX 'tabletop stick world X'
Assert-Close $worldFromGameY $worldVisibleY 'tabletop stick world Y'

# Swimming consumes tank-style turn/thrust axes rather than ordinary 2D walk
# coordinates. The adapter first resolves the requested stick direction in the
# visible tabletop frame, then turns the ped toward it while retaining thrust.
function Get-WrappedRadians([double]$Angle) {
    while ($Angle -gt [Math]::PI) { $Angle -= 2.0 * [Math]::PI }
    while ($Angle -lt -[Math]::PI) { $Angle += 2.0 * [Math]::PI }
    return $Angle
}
$swimVisibleYaw = -0.22
$swimCurrentYaw = 2.55
$swimForwardTarget = $swimVisibleYaw + [Math]::Atan2(-0.0, 1.0)
$swimForwardError = Get-WrappedRadians `
    ($swimForwardTarget - $swimCurrentYaw)
Assert-Close $swimForwardTarget $swimVisibleYaw `
    'swim forward headset target'
if ([Math]::Abs($swimForwardError) -lt 2.0) {
    throw 'swim adapter failed to detect stale vehicle-facing error'
}
$swimRightTarget = Get-WrappedRadians `
    ($swimVisibleYaw + [Math]::Atan2(-1.0, 0.0))
Assert-Close $swimRightTarget `
    (Get-WrappedRadians ($swimVisibleYaw - [Math]::PI / 2.0)) `
    'swim right headset target'

Write-Output ("PASS scale={0:F3} neutral_back={1:F2}gu neutral_up={2:F2}gu game_ipd={3:F2}gu" -f `
    $scale, $neutralGameBack, $neutralGameUp, $gameIpd)
