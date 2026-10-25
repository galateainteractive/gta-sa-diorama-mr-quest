# Package 50: radial text weapon selector

Baseline: Package 49 plus the publication and Galatea-installer work on `main`.

## Change

- Press plain `R3` on foot in Diorama MR to open a lightweight weapon selector.
- Point with the right stick to highlight one of CJ's currently owned weapon
  slots. Press `R3` again to equip it and close the selector.
- Selecting the already equipped weapon simply closes the panel. No separate
  `B` cancel command is required.
- The first test UI uses the existing compositor text panel: abbreviated radial
  labels, a large selected-weapon name, current-weapon state and ammunition.
  It adds no artwork dependency and no additional render pass.
- Neutralize gameplay movement, camera, attack, trigger, grip and face-button
  input while the selector is visible. The game world itself is not paused.
- Move the production camera cycle to `L3 + R3`; plain `L3` remains crouch.
- Treat Meta's normal system recenter as the Diorama recenter. The Meta button
  remains reserved by Horizon; after OpenXR says the new `LOCAL` origin is in
  effect, the GameThread recenters on CJ/current vehicle and refreshes the
  headset-relative movement frame.
- Explicitly link Android's static libc++ runtime and ABI support so the native
  build also works when the SDK lives under a Windows path containing spaces.

## Headset test

1. On foot with at least two weapons, press `R3`. Confirm the text selector
   appears and CJ does not turn, walk, aim or fire behind it.
2. Point the right stick in several directions. Confirm the highlighted label,
   centre name and ammunition update, with a light haptic tick on each change.
3. Press `R3` again. Confirm the highlighted weapon equips and the panel closes.
4. Reopen it, leave the current weapon selected and press `R3`. Confirm it
   closes without changing inventory. `B` should retain no selector role.
5. Press `L3 + R3` outside the selector and confirm the camera order remains
   `TRACK`, `FOLLOW`, `FIXED`, then `TRACK`. Confirm plain `L3` still crouches.
6. Hold the Meta system button to perform the Quest recenter. After returning
   to the app, confirm the diorama is centred in front of the headset and
   movement is again headset-relative.
7. Enter a vehicle and confirm the selector cannot open and vehicle controls
   are unchanged.

## Verification

- Run `tools/test-tabletop-effects.ps1`.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify the personal six-APK split set without selecting or
  modifying a Quest.
