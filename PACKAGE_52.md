# Package 52: compact selector and current-frame camera transitions

Baseline: Package 51 on `main`.

## Change

- Reduce the physical weapon-selector panel from 27 cm to 18 cm wide and move
  it closer to the right-hand status display.
- Increase the surrounding weapon labels relative to the centre selection,
  while tightening the radial spacing and retaining the transparent overlay.
- Reconstruct the outgoing camera mode's effective anchor from the live frame
  before entering `TRACK`, `FOLLOW` or `FIXED`. This avoids inheriting a stale
  previous-frame CJ or vehicle position.
- Suppress snap/smooth right-stick scene turning in Diorama MR. Two grips remain
  the intentional map-rotation control; the selector and aircraft still receive
  their required right-stick axes.
- Keep immersive VR, saves, audio, game data and retail mission behaviour
  unchanged.

## Headset test

1. On foot, press `R3`. Confirm the selector appears above the right hand at a
   substantially smaller overall size, with readable surrounding weapon names
   that are only moderately smaller than the centre selection.
2. Move the right stick around the complete selector and equip several weapons
   with `R3`. Confirm all owned labels remain selectable and gameplay input is
   blocked while the overlay is open.
3. While CJ is walking and while a vehicle is moving, cycle every view with
   `L3 + R3`. At the instant of each switch the miniature should retain its
   exact position, rotation and physical scale; only subsequent camera behaviour
   should differ.
4. In `FOLLOW`, `TRACK` and `FIXED`, move the right stick with the selector
   closed. Confirm it no longer rotates the scene. Rotate the map with both
   grips and confirm that gesture is unchanged.
5. If available, confirm airplane/Hydra right-stick controls still work. Switch
   to immersive VR and confirm its ordinary snap/smooth turning is unchanged.

## Verification

- Run `tools/test-tabletop-effects.ps1` against the verified retail library.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify both personal six-APK split sets without selecting or
  modifying a Quest.
