# Package 45: passthrough behind GTA menus

Baseline: `313511f`, tag `pacote-44-teste`.
Build: `work-upstream/runs/20260909-220203-c0a17945`.
Manual installer:
`D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_45.bat`.

## Changes

- Plain `R3` once again cycles the tabletop radius presets.
- The temporary manual passthrough-colour sequence and its input/API were
  removed. Automatic time/weather colouring keeps the Package 44 tuning.
- GTA's initial frontend and in-game pause/map menu remain an opaque, readable
  theater screen, with passthrough submitted beneath it instead of a black
  surrounding environment.
- The menu gate is published atomically from GameThread and requires a valid
  game-surface theater frame. Cutscenes, shops and recovery fallbacks keep the
  old behaviour.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, production shaders, retail ABI checks, weather tuning and
  menu-passthrough/R3 source audits passed.
- The packaged arm64 library matches the tested native build and retains the
  bounded automatic-weather telemetry.
- `libsavr.so` SHA-256:
  `55D8228E1AA52A9C10E4ACCB46F87A4724D0A73979F573DC3A658788D48D2414`.
- arm64 APK SHA-256:
  `D06F04AE2A49FB411B1F8D105FAD232BA3C30DB14753DD6DA55D4D08AD32B22D`.
