# Package 54: in-headset Diorama control guide

Baseline: Package 53 on `main`.

## Change

- Rename the active tips page to `DIORAMA CONTROL GUIDE` or
  `IMMERSIVE CONTROL GUIDE`, matching the current play mode.
- Document the complete production Diorama layout in the headset, including
  the weapon selector, classic attack, aim/fire, camera-mode chord, Meta
  recenter, grip manipulation, fixed radius and core vehicle controls.
- Define `TRACK`, `FOLLOW` and `FIXED` on screen instead of showing only a
  generic camera-cycle instruction.
- State that the right stick does not rotate the Diorama scene while retaining
  its selector and aircraft responsibilities.
- Update Welcome/About and Controls navigation text so returning players can
  always find the guide and do not mistake fixed Diorama shortcuts for ordinary
  remappable gameplay actions.
- Leave gameplay, saves, audio, game data and immersive controls unchanged.

## Headset test

1. Open the Diorama menu with both grips + `Menu` (or both grips + `Y`).
2. Enter `CONTROLS`, select `DIORAMA CONTROL GUIDE` and confirm the complete
   guide fits on one page without clipped rows.
3. Confirm the guide accurately describes `R3`, `L3 + R3`, Meta recenter,
   `A/B/X/Y`, `L2/R2`, one/two-grip manipulation and the camera modes.
4. Open `ABOUT` and confirm it points to `Menu > Controls > Guide` and lists
   the three principal Diorama shortcuts.
5. Switch the configured play mode to Immersive VR, restart, and confirm the
   Controls page still opens the separate immersive guide.

## Verification

- Run `tools/test-tabletop-effects.ps1` against the verified retail library.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify both personal six-APK split sets without selecting or
  modifying a Quest.
