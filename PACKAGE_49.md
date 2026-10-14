# Package 49: production diorama views

Baseline: Package 48 plus the Diorama MR publication preparation on `main`.
Build: `work-upstream/runs/20261014-150610-d8675e49`.

## Change

- Use the stable 60 metre visible-world radius for normal Diorama MR gameplay.
  Older preserved radius values are migrated automatically when the game starts.
- Keep coverage centred only on CJ or the current vehicle. The connected and
  two-island prototypes stay in source for possible future experimental-menu
  work, but no normal controller shortcut can select them.
- Keep physical two-grip resizing independent from the visible-world radius.
- Use plain `R3` to cycle the three production cameras in this order:
  `TRACK`, `FOLLOW`, `FIXED`, then back to `TRACK`.
- Recenter on the live player whenever the camera changes, preserving the
  established joystick/HMD direction re-latch.
- Show `CAMERA: TRACK`, `CAMERA: FOLLOW` or `CAMERA: FIXED` for two seconds in
  the direct compositor text layer after each change.
- Preserve `L3` crouch and `L3 + R3` recenter. The immersive-VR vehicle camera
  shortcut remains available only outside Diorama MR.

## Headset test

1. Start in Diorama MR and confirm the opening camera is `TRACK`/Esteira.
2. Press plain `R3` three times and confirm the order, short English label and
   recentering behavior for all three cameras.
3. Confirm `L3` still crouches and `L3 + R3` still recentres without changing
   camera mode.
4. Resize with both grips and confirm the miniature changes physical size while
   the rendered world remains the same 60 metre CJ/vehicle circle.
5. Hold either grip and press `R3`; no old radius or coverage mode should change.

## Verification

- Release ARM64 native compilation completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged game payload and 59-file audio subset
  were hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, embedded shader, retail-engine ABI, Package 39–49 behavior and
  packaged flicker/telemetry audits passed.
- `libsavr.so` SHA-256:
  `84F0B8EAF5E4B158EA5678674EE666B05A8BCCC366102552BB7B04E8249A61FE`.
- ARM64 split APK SHA-256:
  `0E72AAD9F6D52FB35BCBDAC484B65D4A64A9B27DCC8F6C8AE78F7D956F1D805E`.
