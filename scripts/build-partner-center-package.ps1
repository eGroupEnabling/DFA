param(
    [string]$Version,
    [string]$OutputDirectory,
    [string]$PackageName,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDirectory
$metadataPath = Join-Path $repoRoot 'marketplace\metadata.json'

if (-not (Test-Path -LiteralPath $metadataPath)) {
    throw "Marketplace metadata file not found: $metadataPath"
}

$metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = $metadata.offer.version
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw 'Package version was not provided and could not be resolved from marketplace/metadata.json.'
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot 'dist'
}

$safeOfferId = if ([string]::IsNullOrWhiteSpace($metadata.offer.id)) {
    'partner-center-package'
}
else {
    ($metadata.offer.id -replace '[^a-zA-Z0-9._-]', '-')
}

if ([string]::IsNullOrWhiteSpace($PackageName)) {
    $PackageName = "$safeOfferId-$Version.zip"
}
elseif (-not $PackageName.EndsWith('.zip', [System.StringComparison]::OrdinalIgnoreCase)) {
    $PackageName = "$PackageName.zip"
}

$packageRoot = Join-Path $OutputDirectory 'dfa'
$legacyStagingRoot = Join-Path $OutputDirectory 'staging'
$archivePath = Join-Path $OutputDirectory $PackageName

$requiredFiles = @(
    @{ Source = Join-Path $repoRoot 'src\mainTemplate.json'; Destination = 'mainTemplate.json' },
    @{ Source = Join-Path $repoRoot 'src\createUiDefinition.json'; Destination = 'createUiDefinition.json' }
)

$requiredDirectories = @()

foreach ($item in $requiredFiles + $requiredDirectories) {
    if (-not (Test-Path -LiteralPath $item.Source)) {
        throw "Required package asset not found: $($item.Source)"
    }
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

if (Test-Path -LiteralPath $legacyStagingRoot) {
    Remove-Item -LiteralPath $legacyStagingRoot -Recurse -Force
}

if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null

foreach ($file in $requiredFiles) {
    $destinationPath = Join-Path $packageRoot $file.Destination
    $destinationDirectory = Split-Path -Parent $destinationPath

    if (-not [string]::IsNullOrWhiteSpace($destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }

    Copy-Item -LiteralPath $file.Source -Destination $destinationPath -Force
}

foreach ($directory in $requiredDirectories) {
    $destinationPath = Join-Path $packageRoot $directory.Destination
    Copy-Item -LiteralPath $directory.Source -Destination $destinationPath -Recurse -Force
}

if (Test-Path -LiteralPath $archivePath) {
    if (-not $Force) {
        throw "Archive already exists: $archivePath. Use -Force to overwrite it."
    }

    Remove-Item -LiteralPath $archivePath -Force
}

Compress-Archive -Path (Join-Path $packageRoot '*') -DestinationPath $archivePath -CompressionLevel Optimal

$archiveInfo = Get-Item -LiteralPath $archivePath

[pscustomobject]@{
    ArchivePath = $archiveInfo.FullName
    PackageRoot = $packageRoot
    Version = $Version
    IncludedFiles = @(
        'mainTemplate.json',
        'createUiDefinition.json'
    )
    ExcludedFiles = @(
        'parameters/**',
        'docs/**',
        'samples/**',
        'marketplace/**'
    )
}