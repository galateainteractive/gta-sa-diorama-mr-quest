# Package 25: nearby 3D sparks and zoom-stable markers

Baseline: `28b1b2e`, tag `pacote-24-teste`.
Build: `work-upstream/runs/20260906-234224-d147e6a9`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_25.bat`.

## Changes

- Apply the Package 23 stereo-safe crossed-fin replacement to the same audited
  scraping and wheel-spark producers around the player throughout the visible
  tabletop radius, including nearby traffic instead of only CJ's current car.
- Increase each replacement streak from 15 to 18 mm half-width and make it
  modestly longer. Particle capacity remains 96 and the global creation ceiling
  remains eight per 16 ms. Nearby traffic is limited to four births per window,
  leaving capacity for CJ's vehicle.
- Decouple red mission cylinders and red/yellow/blue objective cones from map
  visual scale. Their world position remains exact, while the late stereo UI
  pass supplies a minimum apparent/angular size based on distance from each eye.
- Preserve the grounded lower edge of enlarged mission cylinders and retain the
  last marker for 1.25 seconds, bridging short producer gaps during zoom changes.

No changes were made to gameplay controls, swimming, driving, the radial mask,
weather-reactive passthrough, audio, game data, saves or configuration. The
build produced and hash-checked six APKs without selecting or modifying a
headset.

## Headset test

Install manually, then scrape CJ's car and watch another nearby car scrape or
lose a wheel. Both should use the slightly larger stable 3D streaks, without a
dense particle burst when traffic collides.

Check red mission areas plus yellow, red and blue objective arrows at every map
zoom. They should stay visible at the correct location; changing zoom must not
make them disappear or relocate them. A removed/completed marker may persist for
up to roughly 1.25 seconds before vanishing.

Package 24 remains the immediate rollback point.
