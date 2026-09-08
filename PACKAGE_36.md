# Package 36: frame-bound passthrough lifecycle

Baseline: `d6339c5`, tag `pacote-35-teste`.
Build: `work-upstream/runs/20260908-132831-a621889f`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_36.bat`.

## Evidence from Package 35

The capture beginning at 13:06:26 used a fixed `0.01000` visual scale and the
60-metre radius throughout the relevant interval. Package 35 correctly rescued
18 eye presentations whose synchronized tabletop snapshots were active while
the live GameThread camera flag was temporarily false. Nevertheless, six stereo
pairs still reported a mask failure in four short windows around 13:06:33,
13:06:34, 13:06:35 and 13:06:37.

Those windows had valid active mask inputs, paired colour/depth generations,
no generation races, no rejected pairs, no bad generations, no fail-closed
events and no alpha-overflow drops. This excluded zoom changes and the entity
selection experiments as the immediate cause of the whole-radius flashes.

## Remaining cause and correction

The XR present loop had a second independent read of the same transient live
camera flag. It used that signal to pause the complete passthrough backend before
choosing the synchronized projection frame. A presentation landing in the
GameThread camera-rebuild interval could therefore submit an opaque world frame
without its passthrough layer, even though the leased frame itself was tabletop.

- Keep the passthrough backend active while passthrough is configured and the XR
  session is focused; camera rebuilds can no longer pause it for one frame.
- Submit the passthrough layer only when the exact synchronized projection frame
  being presented carries an active tabletop snapshot.
- Carry that tabletop bit in the zero-copy repeat cache, so replaying an accepted
  frame preserves the same passthrough decision as its original presentation.
- Add a bounded `[tabletop.flicker.passthrough] package=36` heartbeat reporting
  backend, synchronized projection, final submission and diagnostic live state.

Non-tabletop/cutscene projections remain opaque because they do not submit the
passthrough layer. The approved radial fade, radii, streaming/visibility rules,
controls, effects, audio, data, saves and settings are unchanged.

## Manual confirmation

Install Package 36 manually and use the same normal radius-only view. The
expected result is no scenery flash outside the radial border. If a capture is
needed, healthy tabletop heartbeats should show `backend=1 projection=1
submit=1`; mask windows should remain at `failed_masks=0`. A temporary `live=0`
is harmless when projection and submission remain 1.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- Six-APK personal split set, payload and preserved audio were hash-verified.
- Source and compile-time audits confirm that backend lifecycle no longer reads
  the transient camera flag and final submission follows synchronized-frame
  state, including cached repeat frames.
- The packaged arm64 library matches the tested native build and contains the
  Package 36 mask and passthrough telemetry.
- Tabletop math, both embedded mask shaders, verified retail engine hash and the
  existing scoped spark-hook audit passed.
- `libsavr.so` SHA-256:
  `3BBBD3744E108E0B59945F02BE9A4701B925B15CBA1E00E044242DD903CD0424`.
- arm64 APK SHA-256:
  `9A233D1A46FECCE6A5469FF36EED7A471532573BFCAAE5D787A877F6BE25ADDB`.

No headset was selected or modified. On-headset confirmation remains pending.
