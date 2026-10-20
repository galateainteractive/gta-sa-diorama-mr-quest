# Package 29: per-marker grab-zoom diagnostics

Baseline: `80b79e3`, tag `pacote-28-teste`.
Build: `work-upstream/runs/20260907-121546-c2951834`.
Manual installer: `<project-root>\INSTALAR_PACOTE_29.bat`.

## Why another targeted capture

Package 28 still reproduced the disappearance. Its capture showed six live
markers with no pool eviction, but the aggregate draw heartbeat could only say
that one marker was visible; it could not identify whether that entry was the
red, yellow or blue marker observed in the headset.

## Added telemetry

Every two seconds, the left-eye `[objective.draw]` line now includes each live
marker as:

`id:kind-colour-clip rgb=R/G/B ndc=X/Y gu=D`

- Kind: `C` cylinder, `A` stock arrow, `H` optional highlight.
- Colour: `r` red, `y` yellow, `b` blue, `o` other.
- Clip: `V` visible, `O` outside, `B` behind the eye.
- `ndc`: normalized screen coordinate; approximately -1 through +1 is visible.
- `gu`: GTA-world distance from the player anchor.
- `reprojected=N`: how many entries used Package 28's synchronized transform.

The line is bounded to 3072 bytes and emitted only once every two seconds. No
rendering, marker appearance, sparks, controls, passthrough, radial mask, audio,
game data, saves or configuration changed. Six APKs were built and hash-checked
without selecting or modifying a headset.

## Test

Install Package 29 manually and start `INICIAR_DIAGNOSTICO.bat`. Keep the same
known marker visible for five seconds, use both grips until it disappears and
wait five seconds, then restore the original scale and wait another five
seconds. Stop with `Ctrl+C` and report that the capture is ready.

Package 28 remains the immediate rollback point.
