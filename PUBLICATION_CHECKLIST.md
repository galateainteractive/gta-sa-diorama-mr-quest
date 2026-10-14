# Diorama MR publication checklist

Package 48 is preserved at tag `pacote-48-teste` and branch
`archive/pacote-48`. The compile-verified publication candidate is the
independent repository's `main` branch.

## Source repository

- [x] Preserve the tested Package 48 state before publication changes.
- [x] Adopt the Diorama MR public name without renaming stable internal keys.
- [x] Preserve the MIT license and document the exact upstream provenance.
- [x] Create the independent private GitHub repository at
      `galateainteractive/gta-sa-diorama-mr-quest`.
- [x] Configure it as `origin` and push development history and safety tags.
- [x] Point `UPDATE.bat` at the independent Diorama MR repository.
- [ ] Run the complete release audit, including Bash syntax checks.

## Player-facing product

- [x] Add an in-headset mode selector for **DIORAMA MR** and **IMMERSIVE VR**;
      changing mode clearly requests a restart and never switches live hooks.
- [ ] Add a Diorama MR settings page for camera mode, map radius, scale,
      passthrough and safe reset defaults.
- [x] Make the in-headset controller help reflect the active mode and the
      shipped Quest bindings.
- [x] Keep the public README, feature overview, player-facing tools and
      in-headset text in English.
- [ ] Audit retail tutorial text that cannot be replaced by the VR menu panel.
- [ ] Update the About panel and visible version string for the first Diorama
      MR release.

## Release validation

- [ ] Build from a clean clone using only documented user-supplied inputs.
- [ ] Verify a fresh install and an update that preserves saves, audio and
      configuration.
- [ ] Test Diorama MR defaults and the immersive fallback on Quest.
- [ ] Publish no APK, Rockstar asset, audio bank, signing key, diagnostic log or
      personal path.
- [ ] Tag the first public pre-release only after the headset smoke test.
