# Package 42: bounded XR slowdown diagnostic

Baseline: `52304c5`, tag `pacote-41-teste`.
Build: `work-upstream/runs/20260908-213257-72b3bb72`.
Manual installer:
`<project-root>\INSTALAR_PACOTE_42.bat`.

## Purpose

The last headset capture showed GTA continuing to produce about 70--72 frames
per second while XR presentation fell as low as 39 Hz. Package 42 does not try
to fix that symptom speculatively. It exposes enough already-existing timing to
distinguish runtime GPU saturation, CPU pressure, OpenXR/driver waits, repeated
game frames and thermal/performance throttling.

## Release telemetry

`[tabletop.perf42]` is one logcat record per completed one-second XR window. It
contains:

- GTA render rate plus average frame wall, CPU and blocked time;
- XR presentation rate, fresh-frame rate, display refresh and frame budget;
- Quest META application CPU/GPU frame times when the runtime exposes them;
- average, 95th percentile and maximum XR loop, `xrWaitFrame`, application work
  and `xrEndFrame` times;
- XR thread CPU time, stereo repeats, synchronization/fence waits and timeouts;
- current entity, LOD and alpha-list pressure from the latest game window.

`[tabletop.perf42.init]` appears once and says whether the refresh-rate and META
performance paths are available. `[tabletop.perf42.thermal]` appears only when
OpenXR sends a performance/thermal warning or recovery transition.

The package does not enable `SAVR_DEV`, CSV output, the per-stage GPU timer or
per-frame logging. It performs no extra GL/runtime query and changes no graphics
or gameplay behaviour.

## Headset capture

1. Install the Package 42 BAT manually; it preserves data, audio, saves and
   settings.
2. Start `INICIAR_DIAGNOSTICO.bat`, then play normally through a smooth period,
   the severe slowdown and at least ten seconds after it begins.
3. Stop the diagnostic with `Ctrl+C` and send the newest file from
   `<project-root>\diagnosticos`.

The useful records are tagged `[tabletop.perf42]`; there is no need to remember
an exact wall-clock time if the capture contains the transition.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, embedded shaders, retail ABI offsets, bounded source telemetry
  and packaged player-APK telemetry audits passed.
- `libsavr.so` SHA-256:
  `98A8EC2D37B6BB52592CFC85DE18EEE436ECFDF335836F7D5710FCA1C4438DE9`.
- arm64 APK SHA-256:
  `D87EE933A39CD17A1EF1BFD0C53B9AA539875414AB88B1BEB944BD6647B87D89`.
