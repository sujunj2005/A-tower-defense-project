#Requires -Version 7.2
param([switch]$SkipGodot)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolchain = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'godot-toolchain.json') -Raw | ConvertFrom-Json
$cacheRoot = Join-Path $projectRoot '.godot/toolchain'
$downloads = Join-Path $cacheRoot 'downloads'
[void][IO.Directory]::CreateDirectory($downloads)

function Get-VerifiedArchive($Dependency, [string]$Name) {
    $archive = Join-Path $downloads "$Name.zip"
    if ((Test-Path -LiteralPath $archive -PathType Leaf) -and
        (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -eq $Dependency.sha256) {
        return $archive
    }

    $partial = "$archive.$([guid]::NewGuid().ToString('N')).part"
    try {
        Write-Host "Downloading $Name"
        Invoke-WebRequest -Uri $Dependency.url -OutFile $partial -TimeoutSec 180
        $hash = (Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash
        if ($hash -ne $Dependency.sha256) {
            throw "SHA-256 mismatch for ${Name}: $hash"
        }
        [IO.File]::Move($partial, $archive, $true)
    } finally {
        if (Test-Path -LiteralPath $partial -PathType Leaf) {
            Remove-Item -LiteralPath $partial
        }
    }
    return $archive
}

function Install-Archive([string]$Archive, [string]$ArchivePath, [string]$Entry, [string]$Destination) {
    $staging = Join-Path $cacheRoot ("staging-" + [guid]::NewGuid().ToString('N'))
    try {
        Expand-Archive -LiteralPath $Archive -DestinationPath $staging
        $source = $staging
        if ($ArchivePath) { $source = Join-Path $staging $ArchivePath }
        if (-not (Test-Path -LiteralPath (Join-Path $source $Entry) -PathType Leaf)) {
            throw "Expected $Entry in $Archive"
        }

        $rootPrefix = $projectRoot + [IO.Path]::DirectorySeparatorChar
        $source = (Resolve-Path -LiteralPath $source).ProviderPath
        $Destination = [IO.Path]::GetFullPath($Destination)
        if (-not $source.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase) -or
            -not $Destination.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Dependency installation must stay inside the project.'
        }
        [void][IO.Directory]::CreateDirectory((Split-Path -Parent $Destination))
        [IO.Directory]::Move($source, $Destination)
    } finally {
        if (Test-Path -LiteralPath $staging -PathType Container) {
            $resolvedStage = (Resolve-Path -LiteralPath $staging).ProviderPath
            if ($resolvedStage -eq $staging -and (Split-Path -Parent $resolvedStage) -eq $cacheRoot) {
                Remove-Item -LiteralPath $resolvedStage -Recurse -Force
            }
        }
    }
}

if (-not $SkipGodot) {
    $engine = $toolchain.godot
    $destination = Join-Path $cacheRoot "godot-$($engine.version)"
    if (-not (Test-Path -LiteralPath $destination)) {
        $archive = Get-VerifiedArchive $engine "godot-$($engine.version)-win64"
        Install-Archive $archive '' $engine.console $destination
    }
    $installed = Join-Path $destination $engine.console
    if (-not (Test-Path -LiteralPath $installed -PathType Leaf)) {
        throw "Incomplete Godot installation at $destination."
    }
    $version = & $installed --version
    if ($LASTEXITCODE -ne 0 -or $version -notmatch "^$([regex]::Escape($engine.version))\.stable\b") {
        throw "Unexpected Godot version at ${installed}: $version"
    }
    Write-Host "Godot $version"
}

foreach ($addon in $toolchain.addons) {
    $destination = Join-Path $projectRoot "addons/$($addon.name)"
    if (-not (Test-Path -LiteralPath $destination)) {
        $archive = Get-VerifiedArchive $addon "$($addon.name)-$($addon.version)"
        Install-Archive $archive $addon.archivePath $addon.entry $destination
    }

    $configuration = Join-Path $destination 'plugin.cfg'
    $expected = '(?m)^version\s*=\s*"' + [regex]::Escape($addon.version) + '"\s*$'
    if (-not (Test-Path -LiteralPath (Join-Path $destination $addon.entry) -PathType Leaf) -or
        -not (Test-Path -LiteralPath $configuration -PathType Leaf) -or
        (Get-Content -LiteralPath $configuration -Raw) -notmatch $expected) {
        throw "Expected $($addon.name) $($addon.version) at $destination. Move the existing addon out of the project before retrying."
    }
    Write-Host "$($addon.name) $($addon.version)"
}
