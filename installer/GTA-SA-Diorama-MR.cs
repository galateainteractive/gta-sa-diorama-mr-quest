using System;
using System.IO;

namespace GalateaDioramaInstaller
{
    // GTA SA is a personal source-kit workflow. The public installer embeds
    // only this project's open-source build files and never a Rockstar APK.
    internal static class ProductProfile
    {
        internal const InstallerWorkflow Workflow = InstallerWorkflow.PersonalSourceKit;
        internal const string ProfileId = "gta-sa-diorama-mr";
        internal const string BrandName = "Galatea Diorama Mods";
        internal const string ProductName = "GTA San Andreas Diorama MR";
        internal const string InstallerTitle = ProductName + " Installer";
        internal const string GameName = "GTA San Andreas 2.11.311";
        internal const string GameLongName = "Grand Theft Auto: San Andreas 2.11.311 (Google Play, ARM64)";

        internal const string CommandLineValue = "";
        internal const string CommandLineApkAssetPath = "";
        internal const string CommandLineDeviceRelativePath = "";
        internal const bool GrantAllFilesAccess = false;

        internal const string AndroidPackage = "com.savr.dioramamr";
        internal const string DeviceRoot = "/sdcard/savr";
        internal const string DevicePayloadRoot = DeviceRoot + "/data_main/assets";
        internal static readonly string[] LegacyDeviceRoots = new string[0];
        internal static readonly string[] LegacyMigrationExcludedNames = new string[0];

        internal const string EmbeddedApkResource = "";
        internal const string ExtractedApkName = "";
        internal const string TempFolderName = "GalateaDioramaMods\\GTASADioramaMR\\installer-v1";
        internal const string LocalBundleFolder = "";

        internal const string SourceKitResource = "Installer.SourceKit.zip";
        internal const string SourceKitArchiveName = "GTA-SA-Diorama-MR-Source-Kit.zip";
        internal const string SourceKitVersion = "installer-v1";
        internal const string SourceKitBuildScript = "tools\\build-and-install.ps1";
        internal const string SourceKitBuildArguments = "-DioramaPackage";
        internal const string SourceKitExportScript = "tools\\export-play-apks.ps1";
        internal const string SourceKitWorkFolder = "GalateaDioramaMods\\GTASADioramaMR";
        internal const long MinimumWorkFreeBytes = 15L * 1024L * 1024L * 1024L;
        internal const string GamePackageFilter =
            "GTA SA package (*.apk;*.zip;*.apks;*.xapk;*.apkm;*.7z;*.rar)|*.apk;*.zip;*.apks;*.xapk;*.apkm;*.7z;*.rar|All files (*.*)|*.*";
        internal const string AudioSourceLabel = "Verified GTA SA audio pack";
        internal const string AudioSourceFilter =
            "Audio pack (*.zip;*.7z;*.rar)|*.zip;*.7z;*.rar|All files (*.*)|*.*";
        internal const string AudioDownloadUrl =
            "https://libertycity.net/files/gta-san-andreas-ios-android/241069-gta-sa-classic-avanced-mod-pack.html";
        internal const string AudioSourceInstructions =
            "Download 'Original plan mod pack' (1.41 GB), then select gta-sa-ps2-style-mod-pack_1786856007_737162.7z. Do not select CLASSIC ADVANCED v1.0 or v1.1.";
        internal const bool RequireExclusiveAdbServer = true;
        internal const bool AllowExistingBuildRetry = true;
        internal const string PostInstallInstructions =
            "Inside the game, hold both grips and press the left-controller Menu button (or Y) to open the Diorama MR menu.";

        internal static readonly string[] SteamAppIds = new string[0];
        internal static readonly string[] RegistrySearchTerms = new string[0];
        internal static readonly string[] InstallRootCandidates = { "" };
        internal static readonly string[] CommonSearchRoots = new string[0];
        internal static readonly string[] CommonInstallParentPaths = new string[0];
        internal static readonly string[] CommonInstallNames = new string[0];
        internal static readonly PayloadRule[] Payload = new PayloadRule[0];
    }
}
