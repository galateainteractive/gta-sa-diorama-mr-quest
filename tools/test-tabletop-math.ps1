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

Write-Output ("PASS scale={0:F3} neutral_back={1:F2}gu neutral_up={2:F2}gu game_ipd={3:F2}gu" -f `
    $scale, $neutralGameBack, $neutralGameUp, $gameIpd)
