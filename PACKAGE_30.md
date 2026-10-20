# Package 30: objective-marker clip-scale fix

Baseline: `ac11962`, tag `pacote-29-diagnostico`.
Build: `work-upstream/runs/20260907-122931-5c269788`.
Manual installer: `<project-root>\INSTALAR_PACOTE_30.bat`.

## Diagnosis

The Package 29 capture proved that red and yellow markers remained live,
retained their GTA positions and were reprojected through the synchronized
tabletop transform at every grab scale. When they disappeared, their X/Y
coordinates were still inside the visible viewport, but their depth was
classified outside the projection.

The stereo world pass publishes near/far clip distances in GTA units. In
tabletop it deliberately divides the physical five-centimetre near plane by
the miniature scale. The late marker pass receives vertices already expressed
in physical tracking-space metres, but reused those game-unit clip values
without converting them back. Shrinking the table could therefore move a
nearby marker in front of an incorrectly large near plane.

## Fix

- Convert the published near and far clip distances back to physical metres
  with the exact scale captured in the corresponding mask/eye frame.
- Keep the Package 28 world-position rebase, the Package 25 angular size floor
  and the Package 29 bounded diagnostics unchanged.
- Add a local regression check covering every representative grab scale and
  proving that the tabletop near plane remains five physical centimetres.

No marker position, radar behaviour, mask, passthrough, sparks, controls,
audio, game data, saves or configuration changed. Six APKs were built and
hash-checked without selecting or modifying a headset.

## Headset test

Install Package 30 manually. Keep a known red, yellow or blue world marker in
view and change the map size through the full two-grip zoom range. The marker
should stay at the same GTA location and remain visible at every scale.

Package 29 remains the immediate rollback/diagnostic point.
