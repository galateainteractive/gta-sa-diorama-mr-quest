# Package 26: objective-marker pool fix

Baseline: `a64954b`, tag `pacote-25-teste`.
Build: `work-upstream/runs/20260907-002238-fce49b6d`.
Manual installer: `<project-root>\INSTALAR_PACOTE_26.bat`.

## Changes

- Expand the stereo objective-marker bridge from 16 to 64 live entries. GTA SA
  can submit many radar traces, entrances, services and mission targets in the
  same frame. The old circular fallback could overwrite the desired red,
  yellow or blue marker even though the game was still publishing it.
- Keep allocation static and draw only occupied entries, so an empty capacity
  slot has no per-frame rendering cost.
- Add a rate-limited `[objective.pool]` diagnostic with live count, capacity,
  evictions, expirations and visual scale. If a marker still disappears, this
  distinguishes another pool overflow from a producer/lifecycle issue.

Package 25's zoom-independent presentation, slightly larger nearby 3D sparks
and fixed global spark budget are unchanged. Passthrough, controls, radial
mask, audio, data, saves and configuration are unchanged. Six APKs were built
and hash-checked without selecting or modifying a headset.

## Headset test

Use a scene with a known red, yellow or blue world marker. Leave it visible for
a few seconds at a close map scale, then shrink/zoom the tabletop away and wait
at least five seconds. The marker should remain at the correct location.

Package 25 remains the immediate rollback point.
