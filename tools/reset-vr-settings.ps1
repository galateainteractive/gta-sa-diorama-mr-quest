[CmdletBinding()]
param(
    [string]$Adb,
    [string]$AndroidSdk,
    [string]$WorkDir = 'C:\SAVRBuild',
    [string]$Serial,
    [switch]$BackupBeforeReset,
    [string]$BackupRoot,
    [switch]$Yes,
    [switch]$NonInteractive
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$script:PackageName = 'com.rockstargames.gtasa'
$script:RemoteFilesRoot = "/sdcard/Android/data/$($script:PackageName)/files"
$script:SelectedSerial = $null
$script:AdbExe = $null
$script:SettingsFiles = @(
    'vr_appearance.ini',
    'vr_basketball.ini',
    'vr_calib.ini',
    'vr_calib.ini.tmp',
    'vr_driving.ini',
    'vr_graphics.ini',
    'vr_holsters.ini',
    'vr_hud.ini',
    'vr_locomotion.ini',
    'vr_tabletop.ini',
    'vr_tabletop.ini.tmp'
)

function Invoke-NativeCapture {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $raw = @(& $FilePath @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
    $lines = @($raw | ForEach-Object { $_.ToString() })
    $text = $lines -join [Environment]::NewLine
    if ($exitCode -ne 0 -and -not $AllowFailure.IsPresent) {
        throw "Command failed ($exitCode): $FilePath $($Arguments -join ' ')`n$text"
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Lines = $lines; Text = $text }
}

function Resolve-Adb {
    $candidates = New-Object System.Collections.Generic.List[string]
    if (-not [string]::IsNullOrWhiteSpace($Adb)) {
        $candidates.Add([System.IO.Path]::GetFullPath($Adb.Trim().Trim('"').Trim("'")))
    }
    foreach ($sdk in @($AndroidSdk, $env:ANDROID_SDK_ROOT, $env:ANDROID_HOME)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$sdk)) {
            $candidates.Add((Join-Path $sdk 'platform-tools\adb.exe'))
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($WorkDir)) {
        $candidates.Add((Join-Path $WorkDir '.tools\platform-tools-37.0.1\platform-tools\adb.exe'))
        $candidates.Add((Join-Path $WorkDir '.android-sdk\platform-tools\adb.exe'))
    }
    $localAppData = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
    if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
        $candidates.Add((Join-Path $localAppData 'Android\Sdk\platform-tools\adb.exe'))
    }
    $pathAdb = Get-Command adb.exe -ErrorAction SilentlyContinue
    if ($null -ne $pathAdb) { $candidates.Add($pathAdb.Source) }

    foreach ($candidate in $candidates) {
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { continue }
        $probe = Invoke-NativeCapture -FilePath $candidate -Arguments @('version') -AllowFailure
        if ($probe.ExitCode -eq 0 -and $probe.Text -match 'Android Debug Bridge') {
            return (Get-Item -LiteralPath $candidate).FullName
        }
    }
    throw 'ADB was not found. Run BUILD_AND_INSTALL once, install Android Platform-Tools, or pass -Adb/-AndroidSdk/-WorkDir.'
}

function Invoke-Adb {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$WithoutSerial,
        [switch]$AllowFailure
    )
    $allArguments = @()
    if (-not $WithoutSerial.IsPresent) {
        if ([string]::IsNullOrWhiteSpace([string]$script:SelectedSerial)) {
            throw 'No Quest has been selected.'
        }
        $allArguments += @('-s', $script:SelectedSerial)
    }
    $allArguments += $Arguments
    return Invoke-NativeCapture -FilePath $script:AdbExe -Arguments $allArguments -AllowFailure:$AllowFailure
}

function Select-Quest {
    Invoke-Adb -Arguments @('start-server') -WithoutSerial -AllowFailure | Out-Null
    $result = Invoke-Adb -Arguments @('devices', '-l') -WithoutSerial
    $devices = @()
    foreach ($line in $result.Lines) {
        if ($line -match '^([^\s]+)\s+(device|unauthorized|offline|no permissions)\b\s*(.*)$') {
            $devices += [pscustomobject]@{
                Serial = $Matches[1]; State = $Matches[2]; Detail = $Matches[3]
            }
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($Serial)) {
        $match = @($devices | Where-Object { $_.Serial -eq $Serial })
        if ($match.Count -ne 1) { throw "Requested ADB device was not found: $Serial" }
        if ($match[0].State -ne 'device') { throw "Requested ADB device is $($match[0].State): $Serial" }
        $script:SelectedSerial = $Serial
    }
    else {
        $ready = @($devices | Where-Object { $_.State -eq 'device' })
        if ($ready.Count -eq 0) {
            if (@($devices | Where-Object { $_.State -eq 'unauthorized' }).Count -gt 0) {
                throw 'Quest is connected but unauthorized. Put on the headset and allow USB debugging.'
            }
            if (@($devices | Where-Object { $_.State -eq 'offline' }).Count -gt 0) {
                throw 'Quest is offline. Reconnect USB and restart ADB.'
            }
            if (@($devices | Where-Object { $_.State -eq 'no permissions' }).Count -gt 0) {
                throw 'ADB cannot access the Quest because USB permissions are missing.'
            }
            throw 'No authorized Quest was found.'
        }
        if ($ready.Count -eq 1) {
            $script:SelectedSerial = $ready[0].Serial
        }
        elseif ($NonInteractive.IsPresent) {
            throw 'More than one ADB device is connected. Pass -Serial with -NonInteractive.'
        }
        else {
            Write-Host 'Connected ADB devices:'
            for ($index = 0; $index -lt $ready.Count; $index++) {
                Write-Host "  [$($index + 1)] $($ready[$index].Serial) $($ready[$index].Detail)"
            }
            $selection = Read-Host 'Choose a device number'
            [int]$number = 0
            if (-not [int]::TryParse($selection, [ref]$number) -or
                $number -lt 1 -or $number -gt $ready.Count) {
                throw 'Invalid device selection.'
            }
            $script:SelectedSerial = $ready[$number - 1].Serial
        }
    }

    $model = (Invoke-Adb -Arguments @('shell', 'getprop', 'ro.product.model')).Text.Trim()
    $manufacturer = (Invoke-Adb -Arguments @('shell', 'getprop', 'ro.product.manufacturer')).Text.Trim()
    $identity = "$manufacturer $model".Trim()
    if ($identity -notmatch '(?i)quest|oculus|meta') {
        throw "The selected device does not identify itself as a Meta/Oculus Quest: '$identity'."
    }
    Write-Host "Selected Quest: $($script:SelectedSerial) ($identity)"
}

function Test-RemoteExists {
    param([Parameter(Mandatory = $true)][string]$Path)
    $result = Invoke-Adb -Arguments @('shell', 'test', '-e', $Path) -AllowFailure
    return $result.ExitCode -eq 0
}

function Backup-QuestSavesAndSettings {
    param([Parameter(Mandatory = $true)][string]$Destination)

    if (Test-Path -LiteralPath $Destination) {
        throw "Backup destination already exists: $Destination"
    }
    New-Item -ItemType Directory -Path $Destination | Out-Null
    $filesRoot = Join-Path $Destination 'files'
    New-Item -ItemType Directory -Path $filesRoot | Out-Null

    $copiedNames = @()
    if (Test-RemoteExists -Path $script:RemoteFilesRoot) {
        $list = Invoke-Adb -Arguments @('shell', 'ls', '-1A', $script:RemoteFilesRoot) -AllowFailure
        if ($list.ExitCode -ne 0) {
            throw "Could not enumerate Quest saves/settings: $($list.Text)"
        }
        foreach ($rawName in $list.Lines) {
            [string]$name = [string]$rawName
            if ([string]::IsNullOrEmpty($name)) { continue }
            if ($name -in @('audio', 'vrhands') -or
                $name -like '.savr-stage-*' -or
                $name -like '.savr-backup-*') { continue }
            if ($name -notmatch '^[A-Za-z0-9_.-]+$' -or $name -in @('.', '..')) {
                throw "Unsafe filename in Quest files directory: $name"
            }
            $remoteChild = "$($script:RemoteFilesRoot)/$name"
            $pull = Invoke-Adb -Arguments @('pull', $remoteChild, $filesRoot)
            if ($pull.ExitCode -ne 0) {
                throw "Could not back up $remoteChild`: $($pull.Text)"
            }
            $copiedNames += $name
        }
    }

    $records = @()
    foreach ($file in @(Get-ChildItem -LiteralPath $filesRoot -File -Recurse)) {
        $relative = $file.FullName.Substring($filesRoot.Length).TrimStart('\').Replace('\', '/')
        if ($relative -match "['`r`n]" -or (($relative -split '/') -contains '..')) {
            throw "Unsafe path in the save/settings backup: $relative"
        }
        $localHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
        $remoteFile = "$($script:RemoteFilesRoot)/$relative"
        $remoteResult = Invoke-Adb -Arguments @(
            'shell', 'toybox', 'sha256sum', $remoteFile
        ) -AllowFailure
        if ($remoteResult.ExitCode -ne 0) {
            throw "Could not hash the remote save/settings file: $remoteFile`n$($remoteResult.Text)"
        }
        $remoteHash = (($remoteResult.Text.Trim() -split '\s+')[0]).ToUpperInvariant()
        if ($remoteHash -ne $localHash) {
            throw "Save/settings backup hash mismatch: $relative"
        }
        $records += [pscustomobject]@{
            path = $relative
            size = [int64]$file.Length
            sha256 = $localHash
        }
    }

    $manifest = [ordered]@{
        formatVersion = 1
        package = $script:PackageName
        deviceSerial = $script:SelectedSerial
        createdUtc = [DateTime]::UtcNow.ToString('o')
        remoteRoot = $script:RemoteFilesRoot
        excluded = @('audio', 'vrhands', '.savr-stage-*', '.savr-backup-*')
        topLevelItems = $copiedNames
        files = $records
    }
    $manifestPath = Join-Path $Destination 'backup-manifest.json'
    $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    Write-Host "Verified save/settings backup: $manifestPath ($($records.Count) files)" -ForegroundColor Green
    return $manifestPath
}

try {
    $script:AdbExe = Resolve-Adb
    Write-Host "ADB: $($script:AdbExe)"
    Select-Quest

    $package = Invoke-Adb -Arguments @('shell', 'pm', 'path', $script:PackageName) -AllowFailure
    if ($package.ExitCode -ne 0 -or $package.Text -notmatch '(?m)^package:') {
        throw "$($script:PackageName) is not installed on the selected Quest."
    }

    Write-Host ''
    Write-Host 'The following VR settings will be removed:' -ForegroundColor Yellow
    foreach ($name in $script:SettingsFiles) {
        Write-Host "  $($script:RemoteFilesRoot)/$name"
    }
    Write-Host ''
    Write-Host 'Saves, audio, game data, vrhands, performance logs, and the APK will be preserved.'
    Write-Host 'The game will remain stopped. New defaults load the next time you start it.'

    if (-not $Yes.IsPresent) {
        if ($NonInteractive.IsPresent) {
            throw '-NonInteractive requires -Yes before settings can be removed.'
        }
        $answer = Read-Host 'Type RESET to continue'
        if ($answer -cne 'RESET') { throw 'Reset was cancelled; no settings were removed.' }
    }

    $stop = Invoke-Adb -Arguments @('shell', 'am', 'force-stop', $script:PackageName) -AllowFailure
    $processResult = Invoke-Adb -Arguments @('shell', 'pidof', $script:PackageName) -AllowFailure
    if (-not [string]::IsNullOrWhiteSpace($processResult.Text)) {
        throw "$($script:PackageName) is still running after force-stop. PID: $($processResult.Text.Trim())"
    }
    if ($stop.ExitCode -ne 0) { throw "Could not stop $($script:PackageName): $($stop.Text)" }

    $backupManifest = $null
    if ($BackupBeforeReset.IsPresent) {
        $backupBase = if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
            Join-Path ([System.IO.Path]::GetFullPath($WorkDir)) 'device-backups\manual-vr-reset'
        }
        else {
            [System.IO.Path]::GetFullPath($BackupRoot.Trim().Trim('"').Trim("'"))
        }
        New-Item -ItemType Directory -Force -Path $backupBase | Out-Null
        $backupDestination = Join-Path $backupBase (Get-Date -Format 'yyyyMMdd-HHmmss')
        Write-Host ''
        Write-Host 'Creating and hash-verifying a local save/settings backup...'
        $backupManifest = Backup-QuestSavesAndSettings -Destination $backupDestination
    }

    $removed = 0
    foreach ($name in $script:SettingsFiles) {
        $path = "$($script:RemoteFilesRoot)/$name"
        if (Test-RemoteExists -Path $path) { $removed++ }
        $delete = Invoke-Adb -Arguments @('shell', 'rm', '-f', '--', $path) -AllowFailure
        if ($delete.ExitCode -ne 0) { throw "Could not remove $path`: $($delete.Text)" }
    }
    foreach ($name in $script:SettingsFiles) {
        $path = "$($script:RemoteFilesRoot)/$name"
        if (Test-RemoteExists -Path $path) { throw "Reset verification failed; file still exists: $path" }
    }

    Write-Host ''
    Write-Host "VR settings reset verified: $removed existing file(s) removed." -ForegroundColor Green
    if ($null -ne $backupManifest) {
        Write-Host "Backup retained at: $backupManifest" -ForegroundColor Green
    }
    Write-Host 'The game was not launched.' -ForegroundColor Green
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
