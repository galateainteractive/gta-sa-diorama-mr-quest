# Package 46: passthrough loading and tabletop startup defaults

Baseline: `1316b28`, tag `pacote-45-teste`.
Build: `work-upstream/runs/20260909-223319-c10175b0`.
Manual installer:
`<project-root>\INSTALAR_PACOTE_46.bat`.

## Changes

- Gameplay starts at the farthest/smallest tabletop scale (`0.010`) and in
  `Track`/conveyor mode: player/vehicle translation is followed, but its heading
  does not rotate the miniature around the viewer.
- Personal updates migrate only the former exact shipped scale `0.040`; custom
  scale values and the debug property override remain authoritative.
- A positively classified loading screen is replaced by passthrough alone when
  the backend is active. The stock loading quad remains the fallback if it is
  not, avoiding an empty/black XR frame.
- Menus retain Package 45's opaque panel over passthrough. Story cutscenes keep
  the existing video theater with black around it.
- The experimental custom 3D pause-map waypoint beacon is removed. GTA's own
  pause-map point, grip zoom and official red/yellow/blue world markers remain.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, production shaders, retail ABI checks, automatic weather,
  menu/loading passthrough, default Track/scale and marker-isolation audits
  passed.
- The packaged arm64 library matches the tested native build and does not carry
  the retired custom waypoint beacon/property.
- `libsavr.so` SHA-256:
  `9F66FB93CFE1F13D814684CECCD8089A514709AB2332D54432B7691913994E48`.
- arm64 APK SHA-256:
  `934C3E8B5A5D7809F2438DD1EDB8BDDB9CA365CFCDD640F418E59938A8430485`.
