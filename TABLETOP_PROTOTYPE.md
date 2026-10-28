# GTA San Andreas Diorama MR technical notes

Diorama MR adds a small, reversible miniature-world camera mode to the native
Meta Quest port. It changes rendering and tracked interaction only; missions,
physics, collision, traffic, pedestrians, vehicles, and saves continue to use
the retail game's coordinate system.

The implementation continues to use `tabletop` in source names, configuration
keys and diagnostics. Those are stable technical identifiers, not the public
product name.

## Views and controls

- startup visual scale: `0.01` (one game metre appears as one centimetre);
- physical anchor: 1.25 m forward and 0.55 m below the recentered headset;
- default game anchor: the existing player/vehicle camera anchor, refreshed every frame;
- orientation: the normal player/vehicle yaw plus 1:1 headset rotation;
- HUD: the existing classic VR HUD remains at readable human scale;
- theater cutscenes: keep GTA's video quad with passthrough around it.

Runtime controls:

- both grips + the left-controller `Menu` button: open or close the Diorama MR
  menu; both grips + `Y` is the fallback when the system consumes `Menu`;
- `A`: jump on foot;
- `B`: sprint on foot;
- `X`: alternate classic attack on foot;
- `Y`: enter or exit a vehicle;
- `L2`: hold GTA's native targeting state; releasing it lowers the weapon;
- `R2`: fire while `L2` is held;
- `L3`: toggle crouch on foot;
- `R3`: open the on-foot weapon selector; point at an owned weapon with the
  right stick and press `R3` again to equip it and close the selector;
- `L3 + R3`: cycle the `TRACK`, `FOLLOW` and `FIXED` views; a short English
  status line confirms the selected camera;
- hold Meta's system button: the Quest performs its normal recenter, and the
  resulting OpenXR `LOCAL` reference-space change recenters the diorama on the
  live player/vehicle after the new origin becomes effective;
- fixed table + one grip: drag the model through the room;
- fixed table + both grips: move, rotate and resize the model (hands farther
  apart make it larger; hands closer make it smaller);
- visible-world radius: fixed at the proven 60 metre profile during normal
  play; the older experimental radii are not exposed by a controller shortcut;
- coverage authority: CJ/current vehicle only during normal play; the former
  connected and two-island experiments remain source-level prototypes;
- selecting the already equipped weapon simply closes the selector without
  changing CJ's inventory.

The physical miniature size is independent of the visible-world radius. Two
grips may still resize the diorama freely without changing how many game-world
metres are streamed and rendered around CJ or the current vehicle.

Red mission areas and coloured objective cones follow the same miniature-world
transform as CJ. Their presentation has a physical minimum size and is drawn as
navigation UI, so shrinking the model does not hide them in the ground. Their
late stereo projection converts the eye pass's game-unit clip distances back
to physical metres using the scale captured for the same frame. In tabletop
mode mission cylinders use 58% opacity, while stock objective cones use a
hollow 34%-opacity outline so miniature streets, vehicles and buildings remain
visible behind the navigation cue.

Package 59 makes stock red/yellow/blue cones less obstructive without changing
their gameplay position. In Diorama MR only, a 34%-opacity perimeter and four
guide ribs replace the filled surface, and the distance-based minimum footprint
is smaller. Mission cylinders retain their 58% presentation and Immersive VR
retains the original filled cone.

The waypoint selected on the retail pause map remains inside GTA's map only.
The experimental custom 3D boundary beacon was removed after headset testing;
official red, yellow and blue world/mission markers retain their late stereo
tabletop presentation.

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

Package 42 adds a bounded release-build performance witness for intermittent
headset slowdowns. `[tabletop.perf42]` is emitted once per completed one-second
window and correlates GTA production rate with XR presentation/fresh-frame rate,
runtime CPU/GPU frame time, pacing, compositor/application work, `xrEndFrame`,
stereo repeats, synchronization waits and current scene counts. It reuses
measurements that were already collected; it adds no per-frame formatting,
file output or GPU query. `[tabletop.perf42.thermal]` is event-driven and records
OpenXR performance warning and recovery transitions when Quest supplies them.

Package 43 is a temporary passthrough-palette validation build. Plain `R3`
walks through `NORMAL`, `DAWN`, `SUNSET`, `NIGHT`, `OVERCAST`, `RAIN`, `FOG`,
`SANDSTORM` and finally `AUTO`; chorded `R3` controls retain priority. These
forced states use the exact amplified production palettes and their normal
smooth transition, but bypass GTA's clock/weather values. A release log is
written only when the selected preview or a coarse automatic weather bucket
changes, making it possible to distinguish a bad palette from a missing GTA
rain signal without per-frame cost.

Package 44 keeps that manual preview while applying the first headset-guided
art pass. Dawn is warmer and more pronounced. Overcast and rain now borrow the
approved fog palette's desaturation and softened contrast, but stay darker and
less white. Automatic weather uses an earlier smooth response for GTA rain and
cloud transitions, with a cloud dead zone that protects clear daytime colour.

Package 45 retires the palette-preview input and gives plain `R3` back to the
radius presets. The boot frontend and in-game pause/map menu now keep the
passthrough layer behind their existing opaque theater quad, so only the menu
screen is dark and the room remains visible around it. A GameThread-owned
atomic snapshot gates this path; cutscenes, shops and stereo fallback screens
do not inherit the menu passthrough behaviour.

Package 49 supersedes that Package 45 controller assignment: plain `R3` now
cycles the three production diorama cameras, while normal gameplay is locked to
the stable 60 metre CJ/vehicle-only coverage profile. See `PACKAGE_49.md`.

Package 50 supersedes Package 49's controller assignment without changing its
camera or coverage implementation. Plain `R3` opens a lightweight owned-weapon
selector, the right stick highlights a radial text entry, and the next `R3`
equips it. `L3 + R3` now cycles the production cameras. The Meta system button
remains owned by Horizon; its standard OpenXR reference-space-change event is
used to recenter the diorama after the Quest finishes its own recenter.

Package 51 places that selector in the existing late, depth-free controller HUD
pass as a compact transparent texture above the right-hand status panel. It is
no longer a large head-locked quad, and its GL upload is revision-gated. Camera
cycling also stops requesting a recenter: the old and new leveled camera bases
are rebased through physical-anchor and map-yaw compensation, preserving the
whole visible miniature transform at the transition. Finally, classic attack
is published as both a frame-stable held state and a just-down edge through
GTA Android's dedicated melee pad queries, allowing `X` to start and continue
punch, bat and other held-melee animations with or without a nearby target.

Package 52 makes the right-controller selector physically smaller while
increasing the relative size of its surrounding weapon labels and tightening
their radius. Camera cycling now reconstructs the outgoing mode's effective
anchor from the live frame rather than reusing the previous rendered frame;
this removes the last small correction visible when CJ or a vehicle was moving
at the moment of a `TRACK`/`FOLLOW`/`FIXED` switch. Diorama also ignores the
right stick for snap/smooth scene rotation because two-grip manipulation owns
map rotation. The selector and existing aircraft-control paths still receive
the stick, and immersive turning remains unchanged.

Package 53 keeps Package 52's 18-centimetre selector footprint but raises it
farther above the right hand and expands the internal weapon ring. Fully opaque
brighter glyphs receive a thin dark outline before the colour pass, preserving
contrast over GTA's bright map/HUD without adding an opaque background card.

Package 54 consolidates the production commands in the headset itself. The
Welcome/About panel points players to `Menu > Controls > Guide`; the Diorama
guide identifies the modern face-button layout, targeting and weapon selector,
defines all three camera modes, documents Meta recenter and grip manipulation,
and separates fixed Diorama shortcuts from ordinary remappable bindings.

Package 55 separates the selector's radial and centre labels. A small set of
long weapon names receives an unambiguous ring abbreviation, while the centre
continues to show the complete weapon name. This prevents `BASEBALL BAT` and
later long inventory entries from overlapping adjacent or central text without
shrinking the readable two-pixel ring font.

Package 56 adapts mobile help prompts at the final OpenXR text boundary. GTA's
language files and mission scripts are never modified: only the copied help
string is inspected, and only while Diorama MR is active. Verified semantic
`~widget_*~` markers become the corresponding Quest labels (`L2`, `R2`, `L3`,
`A`, `B`, `Y`, the `R3` weapon selector, or the established grip chords), so
the original sentence and selected game language remain intact. A short exact
allowlist also corrects early English screen-region instructions whose retail
text contains no widget marker. Unknown controls retain their original text
path and emit one bounded `[tabletop.tutorial] unmapped` diagnostic per distinct
message for safe follow-up coverage.

Package 57 extends that same Diorama-only boundary to GTA's brief-text channel,
which is where the opening bicycle lessons are published. Exact verified
English bicycle sentences teach `Y` to mount, hold `R2` to pedal, left-stick
weight shifting and `A` bunny hop; generic semantic widgets continue to retain
the original sentence and language. The in-headset reference is split into two
colour-grouped pages selected with `L2`/`R2`, and the automatic welcome is now
a short start-here page rather than a dense copy of the full About panel.

The next diagnostic pass observes the common mobile tutorial enqueue function
itself. Each distinct `CWidgetHelpText::AddMessageToQueue` string is recorded
once with bounded metadata, so any ordinary tutorial can reveal its exact GXT
text without requiring a live capture at a particular mission frame. The
retail queue and displayed text are not modified by this diagnostic.

Package 62 also observes the final storage directly after Package 61 proved
that visible mobile prompts can bypass that enqueue function. It checks the
brief buffer, every large-message style and all ten help slots, logging only a
new channel/slot/text combination. This diagnostic still leaves the stored and
displayed strings untouched.

Package 63 moves the diagnostic to the final font boundary. It hooks the exact
retail `CFont::PrintString` entry but records only return addresses inside the
audited `CWidgetHelpText` implementation, capturing the GXT string at the
moment the mobile touch layer draws it without logging unrelated HUD text.

Package 58 gives that first-run page the complete GTA San Andreas Diorama MR
identity. It names Diorama MR as the default, points to Immersive VR under the
restart-gated Play Mode row, and presents short Galatea/upstream credits before
directing the player to the two-page control guide.

Package 46 makes the requested presentation defaults explicit: gameplay starts
at `visual_scale=0.010` in the translation-following `Track`/conveyor view. A
preserved settings file is migrated only when its scale is exactly the former
shipped `0.040`, so a deliberately customized value is not overwritten. A
GameThread snapshot also separates loading from menus and cutscenes. While the
passthrough backend is live, a classified loading frame submits passthrough
alone; otherwise GTA's loading quad remains the fallback. Cutscene videos keep
their existing theater presentation and black surround. The experimental 3D
beacon derived from a user point on the pause map is removed, while the retail
map zoom and official mission-marker bridge are unchanged.

Package 47 puts passthrough behind the finite story-cutscene theater quad, so
the video remains unchanged but no longer sits in an entirely black room.
Tabletop fixed-wing pitch always comes from the conventional left stick even
when an old immersive-yoke preference is preserved. In `Track`/conveyor view,
aircraft latch their current altitude on entry or recenter and subsequently
follow only horizontal translation: the miniature ground stays at table height
while planes and helicopters visibly rise above it. Leaving the aircraft clears
that altitude latch.

Package 48 corrects deep-water masking without changing GTA's water renderer.
Transparent water often leaves only the opaque seabed in the shared depth
buffer; at an oblique tabletop view that distant seabed can project beyond the
radial boundary even though the water surface is inside it. The GameThread now
queries GTA's own stable water level beneath the live player/vehicle and stores
that plane with the matching stereo generation. For a depth fragment confirmed
below the plane, the compositor evaluates the radius at the ray/water-surface
intersection and combines it with the ordinary depth result. It never fills a
clear-depth sky pixel, so the correction cannot manufacture water where GTA
rendered no scene. This path is tabletop-only and can be disabled at process
start with `debug.savr.tabletop_water_mask=0`.

Swimming remains left-stick controlled, but uses a dedicated adapter: the stick
selects a direction relative to the visible tabletop/headset frame, which is
then converted into the game's native turn-and-thrust swimming controls.

Tabletop attacks use GTA's classic combat task rather than tracked physical-hand
aiming. The modern trigger layout routes `L2` through GTA Android's native
`CPad::GetTarget`, `GetEnterTargeting` and `GetExitTargeting` lifecycle, while
retaining `widget_target` as a mobile-script compatibility path. `L2` + `R2`
merges into `CPad::GetWeapon` for punches, melee, guns and spray weapons without
depending on a touch-widget poll; `X` remains a compatibility attack binding.
Targeting press/release edges remain visible to every native consumer for the
exact GTA frame, so one early query cannot steal the L2-release event from CJ.
The bridge stays on foot and outside tabletop grabs, preserving vehicle trigger
controls. Diagnostic captures report `[tabletop.aim]` for the direct pad/widget
target lifecycle, attack source and GTA's selected target pointers;
`[tabletop.aim.area]` reports the actual spray-area arguments and actor
direction.

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

`vr_tabletop.ini` is installed in the GTA external-files directory. Diorama MR
ships with the miniature mode enabled. Set `enabled=0` and restart the game to
use the original immersive VR path without rebuilding.

Supported process-start values:

```ini
enabled=1
passthrough=1
visual_scale=0.010
anchor_forward_m=1.25
anchor_down_m=0.55
radius_preset=1
```

For quick A/B tests, Android properties `debug.savr.tabletop` and
`debug.savr.tabletop_scale` override the file for that process.

## Current prototype limits

- no in-headset Diorama MR settings page yet;
- tracked hands, physical weapons, wrist panels, cockpit controls, physical
  pickups, basketball, and late world overlays are disabled in Tabletop;
- the visible radius uses a depth-aware soft radial fade; some large objects
  whose pivots lie outside the coverage can still expose retail LOD/culling
  edge cases;
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

Package 64 adapts the final retail font call rather than trying to predict
which Android help queue a mission will use. In Diorama MR, only verified touch
tutorial wording and semantic `~widget_*~` controls are replaced; subtitles,
mission prose, menus and unknown prompts retain the original string and draw
path. Adapted cards are labelled `DIORAMA MR TIP`, while unknown candidates are
deduplicated in diagnostics for later additions. The adapter fails closed on a
retail fingerprint mismatch and can be disabled at process start with
`debug.savr.diorama_tutorials=0`. Controls now lands on the guide for the active
play mode, with remapping explicitly secondary, and the menu chord is repeated
once per Diorama application session in a five-second top-centre notice.

Package 65 fixes the new-install handoff between Welcome and that centred
notice: closing Welcome no longer consumes the session reminder. It also maps
the exact opening Android cards from the user's verified `american.gxt` to the
Quest controls for movement, sprint, weapon selection and melee. Known semantic
widgets may safely normalise `Tap` to `Press`; unknown touch wording is logged
once and otherwise remains unchanged.

Package 66 replaces the short gameplay reminder with a persistent lower banner
on GTA's own frontend and pause-menu theater screen. The banner is transparent
outside its compact high-contrast card and uses the existing cached OpenXR menu
swapchain, so it is present whenever players need to rediscover the Diorama
menu chord without adding gameplay composition work. The temporary tutorial
enqueue hook, per-frame help-buffer scans and scoped final-render diagnostics
from Packages 61-63 are removed from production; only the bounded final-font
adapter and once-per-unknown-text reporting remain.

Package 67 isolates the black procedural-shrub defect captured in the opening
Grove Street scene. A fingerprinted retail `CGrassRenderer::DrawTriPlants`
wrapper applies GTA's current ambient colour only to near-zero RGB triplets,
guarantees vertex-alpha blending for that draw and restores every source byte
and RenderWare state afterwards. The wrapper runs only during active Diorama
stereo and fails closed on any unknown executable. The old flicker investigation
witnesses are now `SAVR_DEV`-only, removing their frame-by-frame aggregation and
periodic Android logging from production while retaining real error reports.
