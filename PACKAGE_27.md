# Package 27: marker zoom diagnostics

Baseline: `60326c7`, tag `pacote-26-teste`.
Build: `work-upstream/runs/20260907-010710-c8041ab1`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_27.bat`.

## Purpose

Package 26 proved that increasing presentation size and pool capacity was not
enough to keep mission markers visible throughout grab zoom. This package does
not add another visual guess. It records the marker at three exact stages:

- `[objective.source]`: GTA cone/cylinder source calls, successful tabletop
  publications, transform failures and red/yellow/blue/other publication count.
- `[objective.pool]`: live XR entries, capacity, evictions, expirations and
  current tabletop visual scale, including periods with zero live entries.
- `[objective.draw]`: markers submitted to the left-eye stereo draw and whether
  their centre is inside clip space, outside the frustum or behind the eye,
  including nearest/farthest physical distance.

Each line is rate-limited to once per two seconds. Package 26 marker rendering,
Package 25 sparks, passthrough, controls, radial mask, audio, data, saves and
configuration are unchanged. Six APKs were built and hash-checked without
selecting or modifying a headset.

## Diagnostic test

1. Install Package 27 manually.
2. Start `D:\UNITY PROJETOS\GTASanAndreasTabletop\INICIAR_DIAGNOSTICO.bat`.
3. Keep a known red, yellow or blue marker visible at a close grab zoom for at
   least five seconds.
4. Move both grips apart/together until the marker disappears, then remain at
   that scale for at least five seconds.
5. Return to the scale where it appears and wait another five seconds.
6. Stop capture with `Ctrl+C` and report the approximate clock time or simply
   say that the test is finished; the three tags are sufficient to align it.

Package 26 remains the immediate rollback point.
