# Package 48: deep-water tabletop mask

Baseline: `f2e8131`, tag `pacote-47-teste`.
Build: `work-upstream/runs/20260910-103544-32ba434e`.
Manual installer:
`<project-root>\INSTALAR_PACOTE_48.bat`.

## Change

- Keep GTA's transparent water visible when its opaque seabed is much deeper
  and the ordinary depth-reconstructed radial test would place that seabed
  outside the tabletop circle.
- Query the retail `CWaterLevel::GetWaterLevelNoWaves` map at the live
  player/vehicle X/Y and transform the returned surface into the exact OpenXR
  LOCAL frame captured beside the eye textures.
- Supplement alpha only when a real depth pixel lies beneath the confirmed
  surface and the view ray crosses that surface before reaching the depth
  fragment. Sky/clear-depth pixels remain transparent.
- Keep water drawing, reflections, waves, land/object culling, streaming,
  radii, controls and immersive VR unchanged. One bounded map lookup and a
  small shader branch are the only active costs while tabletop is running.
- Set `debug.savr.tabletop_water_mask=0` before starting the process for an
  exact same-APK A/B fallback.

## Verification

- The embedded production vertex and fragment shaders compile with the Android
  SDK validator.
- The retail 2.11.311 engine hash, exported no-wave water ABI and source-level
  synchronized mask contract were audited.
- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- The packaged arm64 library matches the tested native build and contains the
  Package 48 water-mask diagnostic.
- `libsavr.so` SHA-256:
  `8D746C0D18C86F7A5FC32CC0FB059A493669FAEEADD352B8650DB2B86A911BA3`.
- arm64 APK SHA-256:
  `550A67053E57FBD0E13C1A967F78FAEA67F45089EE01BACEDB69E5385B5F6970`.

## Headset test

Use the same deep-water/aircraft situation that previously showed the seabed
but lost the water surface. Confirm that the water now remains visible inside
the fade while the passthrough outside the radius stays clean. Also glance at a
shoreline to make sure land and water still meet normally.
