# Package 33: bounded tabletop alpha-overflow stabilizer

Baseline: `50164b8`, tag `pacote-32-diagnostico`.
Build: `work-upstream/runs/20260907-183531-32cfb10b`.
Manual installer: `<project-root>\INSTALAR_PACOTE_33.bat`.

## Flicker experiment

Package 32's headset capture kept the stereo colour/depth pair synchronized,
but GTA's ordinary alpha list remained at its fixed 200-entry capacity while
LOD populations changed in visible bursts. Package 33 therefore adds one
bounded spill list for rejected alpha scenery:

- only static building/object/dummy entities inside the existing tabletop
  coverage plus a small six-metre margin are eligible;
- vehicles, pedestrians and other lifecycle-owned entities are excluded;
- at most 96 entries are retained, and an entity must be observed again in the
  current frame before it can be drawn;
- entries that also overflowed in the preceding frame win replacement priority,
  reducing frame-to-frame churn without holding stale world pointers;
- the same frozen selection is drawn for both eyes;
- no radius, mask, streaming, opaque LOD policy or world asset is changed.

`[tabletop.flicker.fix]` reports the retained count and half-second capture,
replacement, draw and drop deltas. The process-start property
`debug.savr.tabletop_alpha_overflow=0` disables only this experiment for a
same-APK comparison.

## Spray and punch diagnostics

Tabletop intentionally uses GTA's classic combat route instead of physical-hand
aiming. The earlier log proved only that the attack button entered that route.
This package adds:

- the actor's real forward basis to `[tabletop.aim] attack edge`, covering
  unarmed punches and ordinary weapon attacks;
- `[tabletop.aim.area]` four times per second while CJ uses spray can,
  flamethrower or extinguisher, including the origin, explicit target direction
  when present, actor forward and GTA heading.

These are diagnostic-only changes: Package 33 does not yet redirect the spray.
The capture will tell whether the bad direction is a stale actor heading or a
null-target fallback through GTA's hidden classic camera.

## Verification

- RelWithDebInfo arm64 build completed successfully with `SAVR_DEV=OFF`.
- Tabletop math test passed.
- The complete six-APK personal split set and staged payload were hash-checked.
- No headset was selected, restarted or modified.

