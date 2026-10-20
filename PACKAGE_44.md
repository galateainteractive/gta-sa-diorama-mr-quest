# Package 44: stronger dawn and wet-weather passthrough

Baseline: `ffb8c00`, tag `pacote-43-teste`.
Build: `work-upstream/runs/20260909-214448-cfb1ec82`.
Manual installer:
`<project-root>\INSTALAR_PACOTE_44.bat`.

## Headset-guided tuning

The Package 43 manual sequence proved that the OpenXR palette path works.
Night, fog and sandstorm were clearly visible, while dawn, overcast and rain
needed stronger separation.

- Dawn receives a stronger warm tint and modestly greater colour/contrast.
- Overcast is darker, substantially less saturated and lower contrast, using a
  restrained cool tint instead of the brighter fog finish.
- Rain is darker and nearly monochrome, with contrast closer to fog and a
  slightly stronger cool cast.
- Automatic cloud response ignores the clear-weather tail, then ramps more
  decisively. Automatic rain reaches its intended palette earlier even if GTA
  is still publishing a partial transition value.

The temporary plain-`R3` sequence remains available:
`NORMAL`, `DAWN`, `SUNSET`, `NIGHT`, `OVERCAST`, `RAIN`, `FOG`, `SANDSTORM`,
then `AUTO`. Wait roughly two seconds after each click for the smooth change.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- The six-APK personal split set, staged payload and 59-file audio subset were
  hash-verified in build-only mode; no device was selected or modified.
- Tabletop math, production shaders, retail ABI checks and Package 38--44
  source audits passed.
- Both weather-preview release log signatures remain inside the packaged APK,
  whose embedded library matches the tested native build.
- `libsavr.so` SHA-256:
  `5AB63A7AAC48E90E94BE37F0E6D0A197F3D20E0389F6F2C8BCD97914B3331AEB`.
- arm64 APK SHA-256:
  `EBC1A8EF2AFE3906B76A6D9BA18E2D07C8D81F674AEB5F006DBE7840BEDE0B29`.
