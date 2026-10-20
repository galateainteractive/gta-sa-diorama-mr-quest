# Package 23: scraping sparks and radial-mask investigation

Baseline: `e13d9e7`, tag `pacote-22-teste`.
Build: `work-upstream/runs/20260906-183548-ab23ef2e`.
Manual installer: `<project-root>\INSTALAR_PACOTE_23.bat`.
User feedback: no repeated missing road, swimming approved, outside-radius
flashes less frequent but not gone, scraping sparks still visually broken.

## Changes

- Replace only audited friction/wheel AddSparks calls within 8 game metres of
  the player's current vehicle in tabletop. Script, weapon and break-object
  callers retain retail behavior. Invalid inputs or unavailable hooks fall
  back to retail. The hook checks retail symbol and PLT/GOT ownership.
- New particles use two crossed world-space fins, a private random stream,
  game-time lifetimes (160–300 ms), 96 slots, and at most eight births per
  16 ms. One geometry snapshot is reused by both eyes. Maximum 384 triangles
  and one draw call per eye. Normal depth testing and the existing radial
  mask apply. This is a visual test candidate, not yet headset-approved.
- Disable the previous blind left/right batch substitution in tabletop:
  matching batch ordinal, vertex count and texture did not prove emitter
  identity and could alter effects unrelated to scraping.
- Explicit high-precision depth sampler in the radial shader. In GLSL ES,
  `precision highp float` alone does not promote sampler precision. Low
  precision can corrupt reconstructed depth near the far end of projection.
  This is a plausible remaining flicker source, not a confirmed live cause.
  Precision rule reference: [Khronos GLSL ES specification](https://registry.khronos.org/OpenGL/specs/es/3.2/GLSL_ES_Specification_3.20.html).
- Isolate depth sampling from an inherited sampler object; reject invalid
  mask/pose inputs and non-finite reconstructed distances.
- Fix P22 diagnostics being compiled out: `LOGW` is disabled with SAVR_DEV
  OFF. `[tabletop.mask]` now uses rate-limited player-build logs, cumulative
  failure counts and a five-second success heartbeat.

No changes to road admission, radius presets, swimming, audio, saves or
weather-reactive passthrough in this package. No headset was connected during
development, and installation remains manual.

## Verification and next headset test

Run `tools/test-tabletop-effects.ps1 -LibGame <verified retail libGame.so>`
to compile the actual embedded vertex/fragment shaders and audit the hook's
retail hash, PLT instructions and three caller addresses. Build with SAVR_DEV
OFF and verify the final APK manifest as usual.

Run INICIAR_DIAGNOSTICO.bat, scrape the same wall, and note the clock time if
scenery flashes. `[spark.replace] ready=1` confirms installation of the hook;
`calls` confirms the scoped producer ran, `active` is bounded by 96.
`[tabletop.mask] health` proves release telemetry is present; `fail_closed`
records failures. A fully transparent world frame remains a possible fallback
on mask failure, so P22 did not guarantee elimination of all flicker.

Stable sector **counts** do not prove identical sector contents, and the old
logs did not establish whether the missing road was unloaded, culled or
masked. Do not treat the earlier candidate causes as measured conclusions.

If the new spark hook reports zero calls during the problematic scrape, inspect
that producer rather than broadening replacement to arbitrary Fx batches. If
mask logs show no failures during a flash, investigate depth precision,
depth/color synchronization, LOD and actual sector identities separately.
