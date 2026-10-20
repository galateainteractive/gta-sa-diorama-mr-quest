# Package 43: manual passthrough weather palette preview

Baseline: `7bd92ff`, tag `pacote-42-diagnostico`.
Build: `work-upstream/runs/20260909-211946-decfcf9c`.
Manual installer:
`<project-root>\INSTALAR_PACOTE_43.bat`.

## Purpose

Night grading was visibly active on Quest, while visible GTA rain produced no
obvious passthrough change. This diagnostic package separates the two possible
causes: the actual colour palette/OpenXR output and GTA's live weather signal.

## Headset test

During normal tabletop gameplay, click plain `R3` and wait roughly two seconds
for each smooth transition. Starting from automatic mode, the sequence is:

1. `NORMAL`
2. `DAWN`
3. `SUNSET`
4. `NIGHT`
5. `OVERCAST`
6. `RAIN`
7. `FOG`
8. `SANDSTORM`
9. `AUTO`

Plain `R3` temporarily replaces radius selection in this package. Chorded R3
actions retain their existing priority. Reaching `AUTO` restores live GTA
clock/weather control without restarting the game.

`[tabletop.passthrough.weather.preview]` records each manual selection.
`[tabletop.passthrough.weather.applied]` records the selected preview, OpenXR
path, GTA hour/rain/fog/cloud/sand values and the final applied grade. It is
emitted only when a preview or coarse automatic weather bucket changes.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, production mask shaders, retail ABI checks and Package 38--43
  source audits passed.
- Both Package 43 release log signatures were found inside the packaged player
  APK, whose embedded library matches the tested native build.
- `libsavr.so` SHA-256:
  `DF93D743ED68648B200FB852AA0791C64824725F1A7F2004757B61E7A568CA76`.
- arm64 APK SHA-256:
  `27E8510A686797DA6C718433B07610A7267E95ABC0308C74CD726AE0ECA78DA7`.
