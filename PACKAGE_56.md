# Package 56: Diorama-aware tutorial controls

Baseline: Package 55 on `main`.

## Change

- Adapt GTA Android help prompts at the final OpenXR text-copy boundary and
  only while Diorama MR is active.
- Replace verified semantic touch-widget markers with their current Quest
  controls while preserving the original sentence, language and formatting.
- Cover the production on-foot layout, weapon selector, phone chord, supported
  mission/minigame prompts, basketball, stats, bicycle/swim prompts and the
  basic vehicle/aircraft labels that already have proven input bridges.
- Correct a small exact allowlist of early English screen-region instructions
  for crouching, parachute deployment and climbing out of water.
- Leave unknown instructions, GTA's GXT/script files, Immersive VR, saves,
  audio, game data and gameplay state unchanged.
- Emit one bounded diagnostic per distinct adapted or still-unmapped tutorial;
  there is no per-frame log stream.

## Headset test

1. Start Diorama MR and reach the early bottle lesson. Confirm the aiming help
   identifies `L2` and the firing help identifies `R2` while aiming.
2. Confirm later crouch, jump, sprint, enter/exit and weapon-selection prompts
   show `L3`, `A`, `B`, `Y` and `R3 WEAPON SELECTOR` where applicable.
3. If an unsupported mobile instruction still has a blank control icon, record
   a short diagnostic capture; `[tabletop.tutorial] unmapped` includes its
   bounded text preview for the next exact mapping.
4. Start Immersive VR after a restart and confirm its original tutorial path is
   unchanged.

## Verification

- Run `tools/test-tabletop-effects.ps1` against the verified retail library.
- Compile the Release ARM64 target with `SAVR_DEV=OFF`.
- Build and hash-verify both personal six-APK split sets without selecting or
  modifying a Quest.
