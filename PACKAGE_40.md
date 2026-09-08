# Package 40: direct controller targeting and nearby companion safety

Baseline: `492dcbe`, tag `pacote-39-teste`.
Build: `work-upstream/runs/20260908-184305-8e5b85d8`.
Manual installer:
`D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_40.bat`.

## What the headset capture proved

The bottle tutorial produced no `widget_target` poll and no `[tabletop.aim]`
event. Package 39 intentionally required a fresh widget-19 poll before enabling
R2, so that mission could use only the older `B` attack binding. The retail
2.11.311 engine exposes a separate controller path through `CPad::GetTarget`,
`CPad::GetEnterTargeting` and `CPad::GetExitTargeting`; that is the correct
integration point for this scene.

The same capture kept 36--37 stereo frames in each half-second window, close to
the Quest 72 Hz target, so it did not show a sustained FPS collapse. It did show
large render-list membership/LOD-set transitions. The previous nearby-ped
safety was centred only on the virtual camera, which can be separated from CJ
in tabletop mode.

## Corrections

- `L2` now supplies the native CPad target press, held state and release edge.
- `L2` + `R2` reaches the classic attack query without waiting for a touch
  widget. `B` remains available.
- Vehicles retain brake/accelerator, either grip blocks targeting, and the
  completed combat chord is quarantined from touch-prompt answers until both
  triggers return to rest.
- The 25 m omnidirectional pedestrian render safety uses the union of virtual
  camera distance and CJ/tabletop-centre distance. It remains bounded and does
  not increase ambient pedestrian population.
- The resolved-flicker diagnostic families remain capturable but publish every
  two seconds instead of every half second.

## Headset check

1. In the bottle tutorial, hold `L2`; press/hold `R2` and confirm that CJ enters
   the normal aiming task and fires.
2. Confirm `B` still fires.
3. Watch both nearby mission companions while changing physical viewpoint and
   tabletop zoom.
4. Note whether the earlier frame-pacing discomfort remains.
5. Check one vehicle and one yes/no touch prompt for regressions.

No installer step may select or modify a Quest automatically. Data, audio,
saves and settings are preserved by the APK-only manual installer.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified; build-only mode selected no device.
- Tabletop math, embedded shaders, retail ABI offsets, direct CPad targeting,
  CJ-centred ped safety and packaged telemetry audits passed.
- `libsavr.so` SHA-256:
  `6D4B01DB9A6441F4FF7F90F3F0F4ACF10422BC9E9C51936F4292A10B319C5F0F`.
- arm64 APK SHA-256:
  `1180A63B14918AE769FFDFEA9F876B69D71F416E32E8F1B4C26A8BC053D99616`.
- The repository-wide audit reached only its external Bash availability check;
  this Windows environment has no Bash executable. Native compilation and all
  Windows/packaged-player checks completed successfully.
