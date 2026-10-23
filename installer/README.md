# GTA San Andreas Diorama MR installer

This profile uses the private `galatea-diorama-installer` engine to produce a
single, Galatea-branded Windows installer. The executable embeds the open-source
Diorama MR source kit and ADB only. It never embeds a Rockstar APK, Rockstar
game data, the external audio pack, or a personal signing key.

The player can either:

1. connect an Android phone/tablet containing the official Google Play ARM64
   release of GTA San Andreas 2.11.311 and let the installer export its complete
   split set; or
2. select a previously exported split folder or supported APK archive.

The installer then asks for the separately supplied verified audio pack,
validates every source, downloads the pinned build toolchain when needed,
builds and signs a personal six-APK set, backs up ADB-accessible saves/settings
if a signing change requires reinstalling, installs the complete set, publishes
the verified payloads, and leaves the game stopped.

## Internal build

Keep the private template beside the project folder:

```text
<projects>\galatea-diorama-installer
<projects>\GTASanAndreasTabletop\repo
```

Commit the source-kit changes, then run:

```powershell
.\installer\build-installer.ps1
```

The self-tested output is written to:

```text
dist\GTA-SA-Diorama-MR-Installer.exe
```

`dist/` is ignored by Git. Share only the generated installer executable and
the public documentation; never publish a locally generated GTA APK set.
