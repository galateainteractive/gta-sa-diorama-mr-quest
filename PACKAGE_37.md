# Package 37: translucent tabletop objective markers

Baseline: `0822873`, tag `pacote-36-teste`.
Build: `work-upstream/runs/20260908-145824-9595bd1c`.
Manual installer: `<project-root>\INSTALAR_PACOTE_37.bat`.

## Change

Tabletop navigation markers now use 58% of their previous opacity. This applies
consistently to the coloured stock arrows, red/yellow mission-area cylinders
and the optional highlighted cages. Their colours, pulse, position, physical
minimum size and draw priority are unchanged, but roads, vehicles and buildings
remain visible through them.

The multiplier is applied only in tabletop mode. The original immersive marker
appearance is unchanged. Package 36's radial-mask and passthrough lifecycle fix,
along with controls, audio, data, saves and settings, is preserved.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- Six-APK personal split set, payload and preserved audio were hash-verified.
- Tabletop math, embedded radial-mask shaders, retail engine/spark audit and the
  Package 36 passthrough lifecycle audit passed against the packaged APK.
- `libsavr.so` SHA-256:
  `15D8BB4DF30B71FABCE73E7FDD829A34A1F4E8D6A5AC982AF5D8A120B9CD698F`.
- arm64 APK SHA-256:
  `C0511689CCE4B92718C6B8B8261A3B75A3D97D69A2EE620828FD681AAB56ED92`.

No headset was selected or modified. Visual confirmation remains pending.
