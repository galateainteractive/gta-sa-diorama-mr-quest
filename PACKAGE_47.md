# Package 47: cutscene surround and tabletop aircraft

Baseline: `7af08f4`, tag `pacote-46-teste`.
Build: `work-upstream/runs/20260909-230850-996dd50c`.
Manual installer:
`D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_47.bat`.

## Changes

- GTA's story video stays on its opaque theater quad, with passthrough submitted
  behind it instead of a black room surround. Menus, loading, shops and stereo
  recovery retain their existing independently gated paths.
- Fixed-wing aircraft in tabletop always use conventional left-stick pitch,
  regardless of a preserved immersive-yoke setting. Hold `R2` to accelerate;
  pull the left stick back to raise the nose and push it forward to lower it.
- `Track`/conveyor latches the vertical reference upon entering an airplane or
  helicopter. It continues following X/Y but not altitude, so the ground stays
  on the table and the aircraft climbs physically within the miniature.
- Recenter or a view change establishes a fresh altitude reference, and leaving
  the aircraft clears the latch.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Production shaders, retail ABI checks, official-marker isolation, cutscene
  composition, tabletop airplane pitch and Track altitude source audits passed.
- The packaged arm64 library matches the tested native build.
- `libsavr.so` SHA-256:
  `78C5A28186BCC8D2D2C90B0ADC4A84FB307DA0C4B6DF6B469B3B5A7387D3B09D`.
- arm64 APK SHA-256:
  `CCB20994C85C3EC8969D4780BA3C58146B716AAD19A203BF0C64E93117935536`.
