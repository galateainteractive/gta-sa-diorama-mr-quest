# Package 31: amplified weather-passthrough validation

Baseline: `2fbd627`, tags `pacote-30-teste` and `pacote-30-aprovado`.
Build: `work-upstream/runs/20260907-124846-901b9ebd`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_31.bat`.

## Changes

- Amplify the complete weather-reactive passthrough grade to `2.0x` through
  one centralized validation constant. Clear daytime remains a true identity
  grade, while dawn, sunset, night, clouds, rain, fog and sandstorm become
  deliberately obvious for headset validation.
- Apply the same intensity coherently to brightness, contrast and saturation.
  Split the tint gain between RGB displacement and tint blend strength so its
  effective increase is also approximately `2.0x`.
- Log every GTA-hour or material weather-state transition after a successful
  compositor update. The bounded line reports the live weather inputs, final
  grade and whether Quest used `META_LUT` or `FB_BASIC`.

Package 30 marker rendering and all world rendering, radial mask, sparks,
controls, audio, game data, saves and configuration are unchanged. Six APKs
were built and hash-checked without selecting or modifying a headset.

## Control audit (no change in this package)

The default tabletop attack/fire button is `B`. It is merged directly into
the retail `CPad::GetWeapon` query, which covers native punches, melee attacks,
guns and spray weapons. Physical-hand melee and physical weapon aiming remain
intentionally disabled in tabletop. Stick locomotion remains headset/tabletop
relative while attacking, but the actual weapon/spray ray follows GTA's
classic combat camera and heading path; that aim direction needs a separate
headset test if it proves incorrect.

## Headset test

Install manually and observe clear day, sunset/night, or invoke one of the
existing weather cheats. Clear day should remain natural; every other state
should now be unmistakable. If it is still unclear, run
`INICIAR_DIAGNOSTICO.bat`; look for
`[tabletop.passthrough.weather.applied]` and its `META_LUT`/`FB_BASIC` path.

Package 30 approved remains the immediate rollback point.
