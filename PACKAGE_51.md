# Package 51: controller selector, continuous cameras and classic melee

Baseline: Package 50 on `main`.

## Change

- Render the weapon selector as a compact transparent card above the right
  controller's status instrument instead of a large head-locked panel.
- Cache that card as an ordinary GL texture and upload it only when the owned
  inventory, highlighted slot, ammunition or active state changes.
- Cycle `TRACK`, `FOLLOW` and `FIXED` without invoking Diorama recenter. The
  transition compensates both camera-base heading and anchor translation, so
  the complete physical table pose remains continuous.
- Resolve and verify GTA Android 2.11.311's separate
  `CPad::GetMeleeAttack` and `CPad::MeleeAttackJustDown` paths.
- Publish the Quest attack binding as a held state and a frame-stable press
  edge. `X` can start and continue punches, baseball-bat swings, knives and
  other classic melee attacks without requiring a nearby target.
- Keep the change on foot and Diorama-only. Vehicles, immersive tracked melee,
  saves, audio, game data, graphics and other controls are unchanged.

## Headset test

1. On foot, press `R3`. Confirm the selector appears above the right hand, is
   substantially smaller, has no opaque black background, and remains above
   the miniature and the existing controller information.
2. Move the right stick and confirm selection text updates without visible
   stalls. Press `R3` to equip and close.
3. Stand still and cycle all views with `L3 + R3`. Confirm the table does not
   jump, rotate or change physical size at the instant of each transition.
4. Walk or drive after each transition and confirm `TRACK`, `FOLLOW` and
   `FIXED` retain their distinct ongoing behaviour.
5. Equip fists and press `X` with nobody nearby. Confirm CJ punches. Equip the
   baseball bat and press `X`; confirm every fresh press starts a swing and a
   held press can continue the normal GTA combo.
6. Confirm `A`, `B`, `Y`, `L2`/`R2`, vehicle controls and Meta recenter remain
   unchanged.

## Verification

- Run `tools/test-tabletop-effects.ps1` against the verified retail library.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify both personal six-APK split sets without selecting or
  modifying a Quest.
