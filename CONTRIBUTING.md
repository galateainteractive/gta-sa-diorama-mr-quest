# Contributing

Thank you for helping improve Diorama MR. Contributions must preserve the
repository's source-only boundary and the licensing of every included file.

## Before opening a pull request

- Base changes on the current `main` branch and keep each pull request focused.
- Explain the user-visible effect, supported Quest/game version, and how the
  change was tested.
- Keep the documented build and install flow fail-closed: unsupported or
  modified retail inputs must not silently pass validation.
- Update `README.md`, `BUILDING.md`, `CHANGELOG.md`, or the technical notes when
  behavior, controls, requirements, or safety boundaries change.
- Add the original source, exact version or commit, license, and required
  notice for every new third-party dependency or asset.

## Content that must never be committed or attached

- GTA San Andreas APKs, binaries, extracted data, models, textures, audio, or
  other Rockstar Games content;
- third-party mod archives or assets without explicit redistribution rights;
- built APKs, shared libraries, DEX files, signing keys, certificates, or
  credentials;
- saves, headset serial numbers, personal paths, user configuration, crash
  dumps, performance traces, or logs that have not been reviewed and scrubbed.

Use placeholders in examples and test fixtures. If sensitive data is committed
accidentally, rotate the affected credential immediately and contact the
maintainers through the private process in `SECURITY.md`.

## Validation

The `Source kit audit` GitHub Actions workflow runs the complete source audit
with PowerShell, Bash, and Python. Before submitting, run the checks available
on your platform and confirm that the working tree contains no generated
artifacts. A pull request should not weaken or bypass the audit.

By contributing, you agree that your contribution is provided under the
repository's MIT License and that you have the right to submit it.
