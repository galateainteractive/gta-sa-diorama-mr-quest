# GTA San Andreas Tabletop prototype

This branch adds a small, reversible miniature-world camera mode to the native
Meta Quest port. It changes rendering and tracked interaction only; missions,
physics, collision, traffic, pedestrians, vehicles, and saves continue to use
the retail game's coordinate system.

## Views and controls

- visual scale: `0.04` (one game metre appears as four centimetres);
- physical anchor: 1.25 m forward and 0.55 m below the recentered headset;
- default game anchor: the existing player/vehicle camera anchor, refreshed every frame;
- orientation: the normal player/vehicle yaw plus 1:1 headset rotation;
- HUD: the existing classic VR HUD remains at readable human scale;
- cutscenes: use the unchanged upstream VR camera.

Runtime controls:

- `L3`: alternate between the original follow-player view and a fixed table;
- fixed table + one grip: drag the model through the room;
- fixed table + both grips: move, rotate and resize the model (hands farther
  apart make it larger; hands closer make it smaller);
- `R3`: cycle the visible map radius through 30, 60, 75 and 120 metres;
- `L3 + R3`: reset scale, placement and radius while keeping the current view.

Red mission areas and coloured objective cones follow the same miniature-world
transform as CJ. Their presentation has a physical minimum size and is drawn as
navigation UI, so shrinking the model does not hide them in the ground. Their
late stereo projection converts the eye pass's game-unit clip distances back
to physical metres using the scale captured for the same frame. In tabletop
mode their coloured surfaces use 58% opacity so the miniature streets, vehicles
and buildings remain visible behind the navigation cue.

The waypoint selected on the retail pause map is also presented as a small red
3D navigation beacon without widening scenery culling. It uses its true
horizontal position up to three times the current radial range. A farther
waypoint is clamped just outside the circle in the correct direction so it
remains useful without appearing metres away across the room. Set process-start
property `debug.savr.tabletop_far_beacons=0` for an exact fallback.

The radial border also has a bounded alpha-overflow stabilizer. When GTA's
fixed ordinary transparency list fills, up to 96 current-frame static scenery
entries inside the tabletop coverage can use a shared two-eye spill list.
Vehicles and pedestrians are excluded, and no entity is held after it stops
appearing in the current frame. Set Android process-start property
`debug.savr.tabletop_alpha_overflow=0` for an exact fallback comparison.

Package 34 corrects returning-entry priority and restores release-build
overflow/combat logs. Flicker witnesses now ignore per-eye list reordering and
accumulate mask-transform changes and stereo anomalies over half-second windows.
No-depth model dispatches are reported separately; these counters are not a
pixel-level proof of mask correctness. See `PACKAGE_34.md`.

Package 35 fixes a measured cross-thread race in radial-mask presentation. The
XR thread now trusts the tabletop state captured with the exact leased colour
and depth generation, rather than the live camera flag that briefly becomes
false during each GameThread rebuild. This prevents a valid tabletop eye from
skipping both mask application and fail-closed alpha clearing.

Package 36 closes the second consumer of that transient flag. Passthrough stays
running while the focused session is configured for it, and its composition
layer is submitted only when the exact synchronized projection (including a
cached repeat) is a tabletop frame. Camera rebuild timing therefore cannot turn
one accepted tabletop projection into an opaque full-world flash.

Swimming remains left-stick controlled, but uses a dedicated adapter: the stick
selects a direction relative to the visible tabletop/headset frame, which is
then converted into the game's native turn-and-thrust swimming controls.

Tabletop attacks use GTA's classic combat task rather than tracked physical-hand
aiming. The modern trigger layout holds GTA Android's own `widget_target` with
`L2`, then merges `R2` into `CPad::GetWeapon` for punches, melee, guns and spray
weapons. `B` remains a compatibility attack binding. The trigger bridge is live
only on foot while the retail target widget is being polled, so vehicle
`L2`/`R2`, tabletop grips and non-combat prompt answers keep their established
meanings. Diagnostic captures report `[tabletop.aim]` for target lifecycle,
attack source and GTA's selected target pointers; `[tabletop.aim.area]` reports
the actual spray-area arguments and actor direction.

The fixed view captures the current player/vehicle frame once. Character and
vehicle controls continue to use the stock gameplay path while the physical
table stays in place.

When supported by the runtime, `XR_FB_passthrough` is submitted underneath the
world projection. Empty sky pixels are transparent, while road, opaque and
alpha entity dispatches are limited to the selected circular map radius.

The render camera is kept orthonormal. Instead of placing scale in its matrix,
physical head translation and eye separation are divided by `visual_scale`.
This produces correct miniature parallax without changing any game object.
The normal upstream camera remains in `TheCamera` outside the eye passes so
gameplay systems do not observe the large Tabletop camera displacement.

## Configuration

`vr_tabletop.ini` is installed in the GTA external-files directory. The private
branch ships with Tabletop enabled. Set `enabled=0` and restart the game to use
the original upstream VR path without rebuilding.

Supported process-start values:

```ini
enabled=1
passthrough=1
visual_scale=0.040
anchor_forward_m=1.25
anchor_down_m=0.55
radius_preset=1
```

For quick A/B tests, Android properties `debug.savr.tabletop` and
`debug.savr.tabletop_scale` override the file for that process.

## Current prototype limits

- no in-headset Tabletop settings page yet;
- tracked hands, physical weapons, wrist panels, cockpit controls, physical
  pickups, basketball, and late world overlays are disabled in Tabletop;
- the radius boundary is intentionally a hard prototype cut at render dispatch;
  a later package can add a soft/faded edge or a physical table base;
- draw distance, fog, LOD, and streaming still need on-device tuning for each
  radius preset;
- passthrough, grab direction and rotation sign require on-device Quest tuning.

## Package 24 experiment: weather-reactive passthrough

This remains isolated from rendering and visibility changes. Package 24 tints
the existing passthrough from GTA's live clock and interpolated weather state
while leaving clear daytime neutral. The first restrained palette is:

- sunrise: a mild gold/pink warmth;
- sunset: a gradually blended warm orange;
- night: darker, slightly blue and desaturated, with a safe brightness floor;
- rain: cooler grey with reduced saturation;
- fog: reduced saturation and contrast;
- sandstorm: a mild orange/sepia grade.

The implementation prefers `XR_META_passthrough_color_lut`, as validated in the
separate Mario 64 Tabletop MR prototype, with FB brightness/contrast/saturation
as fallback. GTA's exported rain, fog, cloud and sandstorm intensities already
carry its weather transitions; an additional 1.35 s compositor smoothing keeps
time/weather changes gradual. The compact 16-cube LUT updates only after a
perceptible change and no more than four times per second. This experiment does
not include lightning flashes or gameplay-event pulses.

Package 38 temporarily triples every non-neutral grade through one centralized
intensity value so headset validation is unambiguous. Successful compositor
updates report the live clock/weather values, final grade and whether the Quest
used the META LUT or the basic brightness/contrast/saturation fallback. After
validation, that single multiplier can be reduced without retuning the palette.
