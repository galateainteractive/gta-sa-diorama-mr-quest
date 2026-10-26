# Package 55: compact radial weapon labels

Baseline: Package 54 on `main`.

## Change

- Use a separate label function for the weapon-selector ring.
- Abbreviate only names that can collide at the production two-pixel ring font:
  `BASEBALL BAT` becomes `BAT`, `DESERT EAGLE` becomes `DEAGLE`,
  `FLAMETHROWER` becomes `FLAMER`, `EXTINGUISHER` becomes `EXTING.`, and
  `NIGHT VISION` becomes `NV GOGGLES`.
- Keep the full weapon name in the centre when the entry is highlighted.
- Leave selector size, spacing, contrast, input, saves, audio and game data
  unchanged.

## Headset test

1. Open the selector with a baseball bat in CJ's inventory and confirm its ring
   entry reads `BAT` without touching adjacent or centre text.
2. Highlight it and confirm the centre still reads `BASEBALL BAT`.
3. If available, inspect the other abbreviated weapons and confirm every label
   remains unambiguous and selects the correct inventory slot.
4. Equip an abbreviated entry with `R3` and confirm ordinary weapon use is
   unchanged.

## Verification

- Run `tools/test-tabletop-effects.ps1` against the verified retail library.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify both personal six-APK split sets without selecting or
  modifying a Quest.
