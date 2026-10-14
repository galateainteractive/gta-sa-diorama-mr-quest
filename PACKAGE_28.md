# Package 28: marker transform synchronized with grab zoom

Baseline: `41a000c`, tag `pacote-27-diagnostico`.
Build: `work-upstream/runs/20260907-115031-350704b0`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_28.bat`.

## Diagnosis

The Package 27 capture showed that marker capacity and lifetime were healthy:
five or six markers remained live, with zero pool evictions. At grab scales
around `0.010–0.014`, they still reached the late stereo draw but all marker
centres became outside clip space or behind the camera. At `0.036–0.047`, the
same pool again contained up to three clip-visible markers.

This isolated the failure to a transform timing mismatch. Marker positions were
stored in physical tracking coordinates before the two-hand map transform was
captured for the eye image.

## Fix

- Store the marker's absolute GTA world coordinate in addition to its fallback
  tracking coordinate.
- Publish the GTA world coordinate of the live player anchor in the tabletop
  mask snapshot.
- Immediately before the late stereo draw, reconstruct every marker from the
  same player centre, miniature scale, map X/Y axes and world-up axis used by
  that exact eye/mask frame.
- Keep the previous physical-size floor, angular readability compensation,
  64-entry pool and Package 27 logs.

Sparks, controls, passthrough, radial visibility, audio, game data, saves and
configuration are unchanged. Six APKs were built and hash-checked without
selecting or modifying a headset.

## Headset test

Install manually and repeat the previous close → far → close two-grip zoom with
a known red, yellow or blue marker. It should stay attached to the corresponding
map location at every scale. Running `INICIAR_DIAGNOSTICO.bat` is optional; if
the marker still disappears, its remaining Package 27 telemetry will show it.

Package 27 remains the immediate rollback point.
