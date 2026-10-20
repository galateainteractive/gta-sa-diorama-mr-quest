# Package 32: targeted tabletop-border flicker diagnostic

Baseline: `495d230`, tag `pacote-31-teste`.
Build: `work-upstream/runs/20260907-133338-311592ad`.
Manual installer: `<project-root>\INSTALAR_PACOTE_32.bat`.

## Purpose

The 13:15 headset capture proved that the radial mask remained active and the
main nearby-scan candidate count stayed stable while extra scenery flashed at
the border. It could not distinguish a same-count GTA LOD/alpha substitution
from a colour/depth ring mismatch because normal performance logs compile out
of player APKs.

## Diagnostic additions

- `[tabletop.flicker.scene]` reports half-second min/max windows for visible
  entities, LODs, super-LODs, streaming requests and alpha nodes before/after
  each stereo eye, together with the live tabletop scale and radius preset.
- `[tabletop.flicker.identity]` hashes only render-list pointer identity. It
  counts substitutions between frames and mutations between left/right eyes,
  even when list sizes remain identical. No entity memory or game data is
  logged.
- `[tabletop.flicker.stereo]` confirms the leased ring generation and slot,
  both colour/depth resource IDs, mask success, clip planes, depth scale and
  physical radial size used by the compositor.

All records are bounded to two updates per second. Visibility, mask shaders,
LOD policy, gameplay, passthrough grading, audio, data, saves and configuration
are unchanged.

## Headset capture

Install the package manually. Start `INICIAR_DIAGNOSTICO.bat` before or during
a visible border flicker, keep the scene for several seconds, then change grab
zoom once or twice. Stop with `Ctrl+C` and report the approximate clock time.

The decisive comparison is:

- identity/LOD or alpha changes while stereo generations remain paired: GTA
  LOD/alpha-list churn;
- stable render-list identities with generation/resource anomalies: stereo
  colour/depth synchronization;
- stable lists and stereo pair with mask success: alpha geometry that does not
  contribute its own depth, requiring a targeted mask/depth treatment.
