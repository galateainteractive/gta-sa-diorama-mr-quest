# Package 34: corrected overflow priority and release flicker witnesses

Baseline: `f678109`, tag `pacote-33-teste`.
Build: `work-upstream/runs/20260907-193504-0e4e8ec8`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_34.bat`.

## Correction and scope

- Fix P33's returning-entry selection: a newcomer with previous rank -1 is
  eligible for replacement, rather than accidentally cancelling the victim.
  Actual production helpers have compile-time regression assertions.
- Retain the 96-entry limit, current-frame observation requirement and shared
  two-eye selection. Keep the existing process-start off switch unchanged.
- Do not change the radial shader, presets, fade, streaming, controls, combat
  direction, passthrough grade, audio, saves, data or settings.

## Diagnostic corrections

P33's new LOGI records were compiled out with SAVR_DEV=OFF. They now use
explicit bounded player-build logging. The installed native library is audited
inside the arm64 APK with `tools/test-tabletop-flicker.ps1`, not just in source.
This also restores the attack-edge and spray-area witnesses promised in P33.

P32 used an order-sensitive hash: retail RenderEverythingBarRoads calls qsort
at 0x4b53a0 for each eye. Its LOD hash disagreement was not proof of different
membership. `membership=v2` sums independently mixed pointer identities,
preserving multiplicity and ignoring traversal order. Hash collisions remain
possible; the combined alpha witness does not distinguish movement between
the ordinary and underwater lists. No pointer is dereferenced by hashing.

New half-second records:

- `tabletop.flicker.fix`: captured, retained, replaced, drawn and dropped spill
  entries; startup includes package 34 and the active switch.
- `tabletop.flicker.alpha_depth`: both-eye alpha dispatch/rejection counts,
  missing instances, a model example, and dispatches with model+0x2c bit 3.
  Retail RenderEntity at 0x605f20..0x605f30 disables Z-write for this flag.
  `outer_pivot` counts these flagged models with pivots outside coverage;
  their collision bounds may legitimately overlap the visible disk. This is
  dispatch evidence, not proof of visible pixels or all no-depth materials.
- `tabletop.flicker.mask_window`: observes every attempted eye and retains
  maximum frame-to-frame component changes in centers, axes, scale, radius
  and render position; includes scale/radius/clip ranges, coverage/bridge
  changes and basis error. This targets the user's report of a global escape.
- `tabletop.flicker.stereo`: retains counters across all pairs reaching the
  final-eye check, including failed masks, generation races and rejected pairs.
  Early rejected presentation attempts do not reach this witness.

Existing mask-fallback cumulative counters and scene-list windows remain.
No screenshots, pixel readbacks or GPU stalls are introduced. Logs cannot
conclusively identify which visible fragment escaped or prove correct pixel
depth; if all witnesses remain stable during a confirmed flash, a targeted
pixel-depth experiment or an isolated A/B run is still required. Alpha spill
ordering relative to GTA's main alpha list remains a candidate limitation.

## Manual test

Install package 34 manually and use the existing INICIAR_DIAGNOSTICO.bat.
Try the same radius-2 scene and grab zoom that triggered the global flashes.
If it flashes, hold the scene briefly if convenient, note the clock time,
then stop capture with Ctrl+C. Keeping 5-10 seconds of quiet scene before and
after helps compare normal vs flashing windows. The capture can start while
already flashing; no special sequence is required.

For spray/punch, the same BAT captures attack edges and active spray arguments.
No combat redirection is included in this package.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- Six-APK personal split set, payload and preserved audio were hash-verified.
- `test-tabletop-flicker.ps1` found every required record inside the packaged
  arm64 native library and matched it to the tested build by SHA-256.
- Tabletop math passed; both actual embedded mask shaders compiled; the verified
  retail engine hash, spark PLT and three scoped spark callers passed.
- `libsavr.so` SHA-256:
  `15CB80F61167DA77F71B0DF52A0012E684E3BB2523F6EB0B29EC2AD1929490C4`.

No headset was selected or modified by the build-only workflow. Headset visual
validation and confirmation that runtime hooks execute remain pending.
