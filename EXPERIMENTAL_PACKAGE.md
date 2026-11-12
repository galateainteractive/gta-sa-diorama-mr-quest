# Experimental side-by-side Android package

The normal builder still produces `com.rockstargames.gtasa`. Nothing changes
unless the experimental option is selected explicitly.

The experimental variant produces:

```text
com.savr.dioramamr
```

It continues to validate the player's source APKs as
`com.rockstargames.gtasa`, preserves the original Rockstar Java class names,
and rewrites only the final Android application identity. Its app-scoped
settings, audio, hands and diagnostics live under:

```text
/sdcard/Android/data/com.savr.dioramamr/files
```

## Safe first build

Run `BUILD_EXPERIMENTAL_PACKAGE.bat -BuildOnly`. This builds and audits the APK
set without selecting or modifying a Quest. Inspect the resulting
`build-manifest.json`; it must contain both:

```json
"package": "com.savr.dioramamr",
"sourcePackage": "com.rockstargames.gtasa"
```

## First headset test

After a successful build-only run, reuse that exact build directory with
`BUILD_EXPERIMENTAL_PACKAGE.bat -ExistingBuildRoot <run-directory>`. The
installer addresses only `com.savr.dioramamr`; it does not uninstall or replace
`com.rockstargames.gtasa`.

Before treating the variant as production-ready, verify:

1. both packages appear in `adb shell pm list packages`;
2. the original package still launches unchanged;
3. the experimental package reaches gameplay and OpenXR;
4. audio, VR hands and default settings load from the experimental data folder;
5. saves and calibration remain independent between the two packages;
6. a second experimental build updates in place with the same signing key.

For an ordinary public build, start from the verified retail APK set. A local
developer may combine the experimental flag with `-PersonalUpdate` to derive
the variant from an already verified SAVR personal split set; the assembler
keeps the existing VR entry point and rewrites its package identity.
