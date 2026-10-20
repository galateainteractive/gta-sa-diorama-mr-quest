# Package 35: synchronized-frame mask authority

Baseline: `0d1b3ad`, tag `pacote-34-diagnostico`.
Build: `work-upstream/runs/20260907-230857-984be6cd`.
Manual installer: `<project-root>\INSTALAR_PACOTE_35.bat`.

## Confirmed cause

The Package 34 capture started at 22:59:24 while the global border flashing was
already visible. In approximately 13 seconds, 22 stereo pairs reported at least
one mask not applied. At 22:59:32 the sampled pair directly reported `mask=0/1`.
In the same period, captured mask inputs were active and valid, colour/depth
generations remained paired, and there were no generation races or rejected
pairs. Alpha spill drops and the audited no-Z-write model path were both zero.

The GameThread deliberately stores the live `g_tabletopActive` flag as false at
the beginning of every camera rebuild and restores it after producing a valid
tabletop camera. The independent XR presentation thread used this mutable flag
to gate the already-leased frame's alpha mask. If an eye landed inside that
small interval, it returned before either applying the mask or clearing alpha,
allowing RenderWare's arbitrary source alpha to reveal distant scenery.

## Fix

- Decide mask treatment from the immutable `TabletopMaskState.active` captured
  with the leased colour/depth generation. A synchronized tabletop snapshot is
  applied even when the live GameThread flag is transiently false.
- Preserve the live flag only to distinguish a real non-tabletop frame from the
  transition case where the live camera is tabletop but the captured mask is
  unavailable; that case still fails closed.
- Keep passthrough activity as a required gate. A frame without active
  passthrough retains the existing skip behaviour.
- Aggregate flicker diagnostics based on the captured tabletop frame as well,
  so their own visibility cannot suffer the same race.
- Add `snapshot_authority` to the half-second stereo record. A non-zero value
  counts eyes that P34 would have left unmasked; `failed_masks` should remain
  zero for valid tabletop snapshots after this correction.

The mask shader, fade shape, radius presets, visibility/streaming policies,
alpha spill selection, controls, passthrough colour treatment, combat, audio,
data, saves and settings are unchanged. The pure decision helper has
compile-time assertions for every live/snapshot/passthrough combination.

## Manual confirmation

Install Package 35 manually. Use the same scene and zoom where the outer-radius
scenery flashed. Running `INICIAR_DIAGNOSTICO.bat` is useful but not required:
the decisive expected pattern is `failed_masks=0`, with occasional non-zero
`snapshot_authority` proving that the race occurred and was handled.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- Six-APK personal split set, payload and preserved audio were hash-verified.
- The source audit confirms the synchronized snapshot outranks the transient
  live camera flag, and compile-time assertions cover all decision inputs.
- The packaged-library audit found every Package 35 diagnostic inside the
  arm64 APK and matched it to the tested native build.
- Tabletop math and both actual embedded mask shaders passed. Verified retail
  engine hash and the existing scoped spark-hook audit also passed.
- `libsavr.so` SHA-256:
  `A9EC99BC728088BADD25B39542588B9DE200A70E683F689DCD4BBABDF8E7F0D3`.
- arm64 APK SHA-256:
  `A5A616A12C6A3FF3B1E0BEF5D450C19AF71C341C6B89F65C2E3164E0A6C0E830`.

No headset was selected or modified by the build-only workflow. On-headset
confirmation remains pending.
