# Package 39: modern tabletop targeting and attack controls

Baseline: `d98c102`, tag `pacote-38-teste`.
Build: `work-upstream/runs/20260908-165921-1a847058`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_39.bat`.

## Controls

- On foot in Tabletop, hold `L2` to press and hold GTA Android's retail
  `widget_target` control. Releasing `L2` supplies the matching touch release.
- While `L2` is held and the target widget is live, `R2` feeds GTA's classic
  attack query. This covers firearms, spray/extinguisher-style area weapons,
  fists and melee through the game's existing combat tasks.
- `B` remains an attack/fire alias for compatibility and an immediate fallback
  if a mission uses a control path not covered by the first headset test.

This is a controller-style third-person adapter. It does not enable tracked-hand
weapon rays or change weapon damage, cadence, ammunition, combat tasks or saves.

## Context isolation

- Inside vehicles, `L2` remains brake/reverse and `R2` remains accelerator.
- Either tabletop grip blocks the aim bridge, so dragging, rotating and scaling
  the miniature cannot also enter combat.
- GTA's own recent target-widget poll is required before R2 becomes attack.
  Outside that combat context, the established R2=yes/L2=no touch-prompt bridge
  remains active.
- After aiming, both triggers must return to rest before the prompt bridge can
  use them again. Releasing L2 before R2 therefore cannot accidentally accept
  a dialog or recruit a pedestrian.
- The phone, parachute, basketball, mission/minigame and vehicle-specific
  controls retain their existing scoped handlers.

## Diagnostics and headset check

`[tabletop.aim]` now identifies L2 target press/hold/release injection. Attack
edges report L2/R2 levels, whether the modern route fired, and GTA's internal
lock/free-aim target pointers. `[tabletop.aim.area]` remains available for spray
direction diagnosis.

Test on foot with:

1. a firearm near one or more enemies: hold L2, then press R2;
2. fists near a pedestrian: hold L2, then press R2;
3. the spray can facing a tag or wall: hold L2, then press R2;
4. a vehicle and a non-combat prompt to confirm their trigger meanings did not
   change;
5. `B` to confirm the compatibility attack path still works.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- Six-APK personal split set, payload and preserved audio were hash-verified.
- Tabletop math, embedded mask shaders, retail engine/spark audit, modern combat
  source audit and packaged player telemetry audit passed.
- The packaged player library contains the bounded L2 lifecycle, R2 attack,
  selected-target and spray-area diagnostic strings.
- `libsavr.so` SHA-256:
  `5C0C063C8289592CF4E6744D34070C9A42A6CF711614349305C0B26AFEEA604F`.
- arm64 APK SHA-256:
  `2C3DA9B80FE1F980A68AB657913C636B319CA2DF710B1846A29BF38483E5D53A`.

On-headset target selection and spray orientation remain pending because they
depend on the retail mobile combat state observed during live gameplay. No
headset was selected or modified by the package build.
