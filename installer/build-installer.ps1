[CmdletBinding()]
param(
    [string]$TemplateRoot,
    [string]$AndroidSdk,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$projectFolder = Split-Path -Parent $repository
$projectsFolder = Split-Path -Parent $projectFolder

if ([string]::IsNullOrWhiteSpace($TemplateRoot)) {
    $TemplateRoot = Join-Path $projectsFolder 'galatea-diorama-installer'
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repository 'dist\GTA-SA-Diorama-MR-Installer.exe'
}

$templateBuilder = Join-Path $TemplateRoot 'build-installer.ps1'
$profile = Join-Path $PSScriptRoot 'GTA-SA-Diorama-MR.cs'
foreach ($required in @($templateBuilder, $profile)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required installer source was not found: $required"
    }
}

$dirty = @(& git -C $repository status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Git is required to create the reviewed source-kit snapshot.' }
if ($dirty.Count -ne 0) {
    throw 'Commit the GTA source-kit changes before building the public installer. The embedded snapshot must match a reviewed commit.'
}

$temporaryArchive = Join-Path ([System.IO.Path]::GetTempPath()) `
    ("gta-sa-diorama-source-kit-{0}.zip" -f [Guid]::NewGuid().ToString('N'))
try {
    & git -C $repository archive --format=zip --output=$temporaryArchive HEAD
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $temporaryArchive -PathType Leaf)) {
        throw 'Git could not create the source-kit archive.'
    }

    $arguments = @(
        '-ProfilePath', $profile,
        '-SourceKitPath', $temporaryArchive,
        '-OutputPath', $OutputPath,
        '-RunSelfTest'
    )
    if (-not [string]::IsNullOrWhiteSpace($AndroidSdk)) {
        $arguments += @('-AndroidSdk', $AndroidSdk)
    }
    & $templateBuilder @arguments
    if ($LASTEXITCODE -ne 0) { throw "Installer build failed with code $LASTEXITCODE." }
}
finally {
    if (Test-Path -LiteralPath $temporaryArchive -PathType Leaf) {
        Remove-Item -LiteralPath $temporaryArchive -Force
    }
}
