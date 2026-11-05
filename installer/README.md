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

The installer then asks for the separately supplied verified audio pack. On the
linked LibertyCity page choose **Original plan mod pack** (1.41 GB), then select
`gta-sa-ps2-style-mod-pack_1786856007_737162.7z` in the installer. Do not choose
CLASSIC ADVANCED v1.0 or v1.1. The installer validates every source, downloads
the pinned build toolchain when needed, builds and signs a personal six-APK
set, backs up ADB-accessible saves/settings if a signing change requires
reinstalling, installs the complete set, publishes the verified payloads, and
leaves the game stopped.

The **Build storage** field defaults to the user's Local AppData directory but
can be moved to any writable folder, such as `D:\Diorama MR`. The choice is
saved for later runs and controls the location of downloads, tools, game
exports, build runs and device backups. A new build or phone export is blocked
until the selected drive has at least 15 GB free; retrying an already completed
build remains available without repeating that space requirement.

Close SideQuest completely, including its system-tray process, before pressing
Build and Install. The installer detects SideQuest before starting an expensive
build. If a completed build later reaches a USB/ADB error, use **Install latest
completed build (no rebuild)**; all retained APK and payload hashes are checked
again before installation.

After restarting its pinned ADB server, the installer waits up to 45 seconds
for the same authorized Quest serial to return. Temporary missing, offline or
unauthorized states no longer discard a completed build after only one probe.

The installer also bounds redirected-output draining after the builder exits.
This prevents ADB's background server from leaving the window busy after the
log has already confirmed a successful installation. Embedded source-kit
revisions use hash-qualified folders, so an older open installer cannot lock a
new version out of its own source files.

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
