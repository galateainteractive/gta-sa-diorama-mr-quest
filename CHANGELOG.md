# Changelog

## Package 26 test candidate

- Expand the late stereo objective-marker pool from 16 to 64 entries. GTA's
  radar can submit more than sixteen active 3D blips in one frame; the old
  ring silently replaced early mission colours with later markers.
- Add a bounded `[objective.pool]` heartbeat reporting live entries, pool
  evictions, expirations and tabletop scale for headset confirmation.
- Preserve Package 25 sparks and every Package 24 passthrough/control change.
  See `PACKAGE_26.md`.

## Package 25 test candidate

- Extend the stereo-safe 3D scraping/wheel spark replacement from CJ's current
  vehicle to matching contacts around the player inside the tabletop radius.
- Make the replacement streaks 20% wider and modestly longer while retaining
  the 96-particle pool and eight-birth global frame budget. Nearby traffic may
  use at most half that budget, reserving capacity for CJ's vehicle.
- Make red, yellow and blue objective-marker presentation independent of map
  scale, then enforce a minimum angular footprint from the viewer in the late
  stereo overlay without moving the marker's gameplay position.
- Retain objective markers for 1.25 seconds to bridge short GTA marker/LOD
  update gaps while tabletop zoom changes.
- Preserve Package 24 passthrough grading and all approved controls, data,
  audio, saves and configuration. See `PACKAGE_25.md`.

## Package 24 test candidate

- Add gradual weather-reactive passthrough driven by the verified retail GTA
  clock, rain, fog, cloud-coverage and sandstorm values.
- Keep clear daytime neutral; use restrained dawn, sunset, night, rain/fog and
  sandstorm palettes with a smooth 1.35 s transition.
- Prefer a compact `XR_META_passthrough_color_lut` path updated at no more than
  4 Hz, with FB brightness/contrast/saturation fallback.
- Change only OpenXR passthrough styling; preserve Package 23 rendering,
  effects, controls, data, audio, saves and configuration.
- Headset colour validation remains pending; see `PACKAGE_24.md`.

## Package 23 test candidate

- Replace scoped nearby vehicle scraping/wheel sparks with capped world-space
  crossed fins shared by both stereo eyes; retain other stock effect producers.
- Stop heuristic left-to-right Fx batch substitution in tabletop.
- Require high-precision depth sampling for the radial mask, isolate its
  sampler state, and reject invalid mask inputs/non-finite distances.
- Make mask failure counters available in player APKs and add a bounded
  success heartbeat. P22 used a logging macro compiled out in these APKs.
- Preserve P22 road admission and all previously approved gameplay changes.
- Headset validation remains pending; see `PACKAGE_23.md` for test guidance.

## 0.1.4 alpha

### Added

- Added release-build swim-state diagnostics confirming that tabletop movement
  remains headset-relative and immersive arm-stroke locomotion stays blocked.

### Improved

- Extended stereo stabilization from 32 to 64 vertices for matrix-null Fx
  batches. Live scraping diagnostics showed that isolated sparks were already
  stable while denser collision bursts just above the old limit diverged.
- Replaced the 90 metre radius preset with a 75 metre test step between the
  stable 60 metre profile and the expensive 120 metre profile.
- Made mission/checkpoint cylinders mandatory tabletop information rather than
  tying them to the optional stock objective-marker preference.

### Fixed

- Made the tabletop passthrough mask fail closed. A transient missing mask,
  depth-copy failure, allocation failure, or shader error now leaves that
  frame transparent instead of exposing arbitrary RenderWare alpha and
  flashing distant scenery outside the radial boundary.
- Extended the immediate player-safety island by each entity's bounded
  collision sphere. Large road shoulders, plazas, and terrain slabs routed
  through GTA's non-road path can no longer disappear beside CJ merely because
  their authored pivot lies outside the safety radius.
- Added rate-limited mask fallback counters identifying inactive state,
  program, source-depth, storage, copy, and shader failures in headset logs.
- Added a tabletop-specific swimming adapter. The left stick now selects a
  headset-relative world direction and is converted into GTA's separate swim
  turn/thrust axes, with a short water-surface debounce and no vehicle-yaw
  inheritance.
- Removed the experimental height-only aircraft shell after headset testing
  showed that it also revealed upper portions of unrelated scenery outside the
  tabletop radius. Aircraft now obey the normal mask again.
- Removed the boundary-object completion experiment after headset testing; the
  fade is once again the original continuous radial mask with no per-building
  or vegetation extensions.
- Fixed yellow objective cones using the immersive world transform in tabletop,
  which could place them far away from their matching miniature location.
- Kept red mission areas and yellow objective markers physically readable when
  the model is shrunk, and draw them as unobstructed tabletop navigation UI.
- Fixed tabletop mission cylinders being captured successfully and then skipped
  by the late-overlay renderer's tabletop early return.
- Added a cylinder-only fallback when shared scene depth is unavailable, so a
  mission trigger area is not silently lost for that frame.

## 0.1.3 alpha

### Added

- Added a tabletop-only actor-up radar mode: the CJ/vehicle arrow stays aligned
  while the map rotates from the gameplay heading instead of the independent VR
  camera.
- Added targeted tabletop aim diagnostics for the classic attack route and the
  Android targeting widget, without enabling physical weapons in miniature mode.
- Added a stereo tabletop replacement for script mission cylinders and tube
  checkpoints captured from the complete `C3dMarkers::PlaceMarker` path.
- Added an APK-only installer option that hash-checks preserved Quest audio,
  refreshes its read permissions, and republishes it only when invalid.
- Added Vice City-style volumetric bullet tracers with a thin core and a
  multi-fin smoke volume.
- Added in-game tracer colour selection (`VICE CITY` or `GOLD`) and live smoke
  spread adjustment from 25% to 400%.
- Added the full retail mission list to the mission launcher instead of the old
  fixed 20-mission limit.
- Added the settings export helper for copying VR calibration files from Quest
  to a PC without including saves, logs, screenshots, game data, or the device
  serial number.

### Improved

- Capped procedural-grass detail at the proven 60 m budget for the 75/120 m
  tabletop radius presets while retaining the established 18 m object residency
  skirt to avoid extra pop/flicker. Ground, roads, large structures, and every
  object inside the selected visible radius remain.
- Shortened tracer length and lifetime so shots read as fast projectiles rather
  than persistent laser beams.
- Stabilized parachute visibility distance against altitude changes and moved
  the custom VR risers farther toward the canopy.
- Hid the redundant retail parachute strings and ripcord while the VR risers
  are active.
- Included the UltimateXR open-palm basketball hand meshes in player builds.
- Updated the Classic HUD health crop to the current tested `244 x 84` source
  region without changing the selected HUD preset.

### Fixed

- Fixed BMX/bicycle steering in tabletop mode being overwritten by the idle
  immersive-handlebar value after the left-stick query had succeeded.
- Fixed the direct BMX fork/handling write using the opposite steering sign
  from the tabletop `CPad` query.
- Fixed older tracers dimming newly spawned smoke by sharing one averaged alpha
  value.
- Fixed mission selection wrapping and page-specific mission counts.
- Fixed the public packager omitting the basketball palm assets even though the
  runtime referenced them.
