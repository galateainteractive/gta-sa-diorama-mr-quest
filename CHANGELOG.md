# Changelog

## 0.1.4 alpha

### Added

- Added release-build swim-state diagnostics confirming that tabletop movement
  remains headset-relative and immersive arm-stroke locomotion stays blocked.

### Improved

- Replaced the 90 metre radius preset with an 80 metre test step between the
  stable 60 metre profile and the expensive 120 metre profile.
- Made mission/checkpoint cylinders mandatory tabletop information rather than
  tying them to the optional stock objective-marker preference.

### Fixed

- Removed the experimental height-only aircraft shell after headset testing
  showed that it also revealed upper portions of unrelated scenery outside the
  tabletop radius. Aircraft now obey the normal mask again.
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

- Capped procedural-grass detail at the proven 60 m budget for the 80/120 m
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
