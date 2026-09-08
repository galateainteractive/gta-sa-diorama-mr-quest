# Package 38: tabletop navigation beacon and stronger weather grade

Baseline: `dda1457`, tag `pacote-37-teste`.
Build: `work-upstream/runs/20260908-153457-73f8ce61`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_38.bat`.

## Pause-map waypoint beacon

- Observe the retail pause menu's own waypoint handle and world coordinates;
  marker creation, clearing, radar behaviour and saves remain owned by GTA.
- Present the user waypoint as a small translucent red 3D arrow after the radial
  mask, so it can act as a navigation beacon without rendering distant scenery.
- Within three times the selected tabletop radius, use the waypoint's true
  horizontal position. Beyond that range, place it just outside the radial edge
  in the correct direction, avoiding a marker metres away across the room.
- Keep existing mission arrows/cylinders as late navigation UI; they can remain
  visible outside the scenery circle whenever GTA publishes them.
- Allow an exact same-APK fallback with process-start property
  `debug.savr.tabletop_far_beacons=0`.

The compositor derives the beacon from the mask transform synchronized with the
leased stereo frame. It does not widen SetupMap, LOD, streaming, culling or the
radial alpha mask, and adds at most one tiny marker to the existing bounded pool.

## Passthrough validation intensity

The single weather/clock validation multiplier is increased from `2.0x` to
`3.0x`. Clear daytime remains neutral. Dawn, sunset, night, overcast, rain, fog
and sandstorm keep their gradual blends but should now be unmistakable on the
headset. This is intentionally a validation profile and can later be reduced by
changing the same one constant.

Package 37 marker translucency and Package 36's passthrough/flicker correction
are preserved, as are controls, game data, audio, saves and settings.

## Verification

- RelWithDebInfo arm64 build completed with `SAVR_DEV=OFF`.
- Six-APK personal split set, payload and preserved audio were hash-verified.
- The verified retail `PlaceRedMarker` disassembly confirms handle offset
  `+0x68`, map coordinates `+0x84/+0x88`, and the expected `SetCoordBlip` and
  `SetBlipSprite` calls used by the read-only bridge.
- Tabletop math, embedded mask shaders, retail engine/spark audit and the
  Package 36 lifecycle audit passed against the packaged arm64 library.
- `libsavr.so` SHA-256:
  `ABADD21B1F0FB58979DFD8990509578F66100D573CCBD59B18D30A314E458F4D`.
- arm64 APK SHA-256:
  `40C391D5DE27BC4BF73A6214D607263B114EAF667ADFE498DD111B791A297C68`.

No headset was selected or modified. On-headset visual confirmation remains
pending.
