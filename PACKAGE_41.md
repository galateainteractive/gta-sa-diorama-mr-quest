# Package 41: Quest controller ergonomics and reliable aim release

Baseline: `3209067`, tag `pacote-40-teste`.
Build: `work-upstream/runs/20260908-203701-bcd1500e`.
Manual installer:
`<project-root>\INSTALAR_PACOTE_41.bat`.

## Corrections

- The shipped on-foot Quest layout is now `A` jump, `B` sprint, `X` alternate
  attack and `Y` enter/exit. Vehicle-specific controls keep their existing
  vocabulary.
- An existing `vr_locomotion.ini` is migrated only if its six bindings still
  exactly equal the old shipped default. Custom mappings and every unrelated
  locomotion setting remain unchanged.
- Plain `L3` reaches the existing crouch latch again. Left grip + `L3` now
  cycles the three tabletop camera modes; the grip is suppressed until release
  so the same chord cannot begin dragging the map.
- `R3` continues to cycle radius, right grip + `R3` continues to cycle coverage
  and `L3` + `R3` continues to reset the table.
- L2 enter/exit-targeting edges are shared by all native CPad consumers during
  the exact game frame. Package 40 consumed an edge on the first query, which
  could leave CJ visually aiming after the physical L2 had been released.
- R2 no longer doubles as sprint in tabletop. It remains the aimed-fire trigger
  while L2 is held; X is the alternate attack path.

## Headset check

1. On foot, confirm `A` jumps while the left thumb stays on movement and `B`
   sprints.
2. Confirm `X` punches/fires as the compatibility attack.
3. Click plain `L3` twice and confirm CJ crouches, then stands.
4. Hold left grip and click `L3`; confirm the camera mode changes without the
   map jumping or beginning a drag.
5. Tap and release `L2`; confirm CJ lowers the weapon. Then hold `L2`, fire with
   `R2`, release `L2` and confirm the weapon lowers again.
6. Confirm `Y`, `R3`, right grip + `R3` and `L3` + `R3` retain their previous
   functions.

No installer step may select or modify a Quest automatically. Data, audio,
saves and settings are preserved by the APK-only manual installer.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, embedded shaders, retail ABI offsets, packaged telemetry,
  Quest bindings, crouch ownership and frame-coherent aim-edge audits passed.
- `libsavr.so` SHA-256:
  `62DCA5BD9D0135E9F9DEBF082363F4E9E5FBC40359C00CCCB72D312517CBB864`.
- arm64 APK SHA-256:
  `189D11DC3092D429C9CEE196FAD38636A5CAB5CE65B7EF80CC61A61CD6F08F1D`.
