# Package 53: raised high-contrast weapon selector

Baseline: Package 52 on `main`.

## Change

- Raise the 18-centimetre selector from 18 to 24 centimetres above the right
  controller reference point.
- Increase the internal radial-label radius from 145 to 175 texture pixels so
  weapon names do not collide with the selected weapon and ammunition text.
- Brighten peripheral, selected, equipped and instructional text.
- Draw a thin dark outline below every selector glyph. The glyph and outline
  pixels are fully opaque while all unused panel pixels remain transparent.
- Leave controls, camera behaviour, immersive VR, saves, audio and game data
  unchanged.

## Headset test

1. Open the selector with `R3` and confirm it floats clearly above the rendered
   right hand without covering it.
2. Rotate through a crowded inventory. Confirm peripheral weapon names remain
   clear of the selected centre name and ammunition line.
3. Open it over bright roads, the GTA map and darker nighttime scenery. Confirm
   the text remains strong while the background between glyphs stays transparent.
4. Equip and use several weapons, then confirm camera switching and both-grip
   map manipulation retain Package 52 behaviour.

## Verification

- Run `tools/test-tabletop-effects.ps1` against the verified retail library.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify both personal six-APK split sets without selecting or
  modifying a Quest.
