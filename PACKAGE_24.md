# Package 24: weather-reactive passthrough

Baseline: `b311dd2`, tag `pacote-23-teste`.
Build: `work-upstream/runs/20260906-220633-ea9a7fb9`.
Manual installer: `D:\UNITY PROJETOS\GTASanAndreasTabletop\INSTALAR_PACOTE_24.bat`.

## Changes

- Publish the verified retail GTA clock plus rain, fog, cloud-coverage and
  sandstorm intensities from the GameThread to the OpenXR presentation thread.
- Grade only the passthrough layer from that state. Clear daytime remains an
  identity transform; dawn is mildly gold/pink, sunset warm orange, night
  darker/cooler, rain and fog greyer, and sandstorms orange/sepia.
- Blend time-of-day windows continuously and use GTA's already interpolated
  weather intensities. The presentation thread applies an additional 1.35 s
  low-pass transition, avoiding visible colour steps when weather or time
  changes.
- Prefer `XR_META_passthrough_color_lut`, using a compact 16-cube RGB LUT.
  LUT data is rebuilt only after a perceptible change and at most four times a
  second. This is compositor styling and adds no game-world render pass.
- Fall back to the existing FB brightness/contrast/saturation style when the
  META LUT extension is unavailable. That fallback preserves darkness and
  desaturation but cannot reproduce the warm/cool tint as accurately.
- Validate every retail global against the known 2.11.311 owner and offset.
  Missing or invalid state fails safely to natural passthrough.

No changes were made to the radial mask, draw radius, sparks, gameplay,
controls, world colour, audio, saves or settings. No headset was selected or
modified during the build.

## Headset test

Install the package manually. In clear daylight the room should initially look
natural. GTA sunrise/sunset should warm gradually and night should darken
without becoming opaque. The existing rainy-weather and sandstorm cheats are
the quickest checks for the two weather overrides. Transitions should settle
over roughly one to two seconds rather than snap.

Package 23 remains the immediate rollback point if the palette is too strong
or the Quest runtime rejects styling. Headset colour validation is pending.
