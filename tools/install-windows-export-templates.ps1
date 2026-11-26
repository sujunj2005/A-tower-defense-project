#Requires -Version 7.2
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'godot-toolchain.json') -Raw | ConvertFrom-Json
$engine = $manifest.godot
$project = Split-Path -Parent $PSScriptRoot
$cache = Join-Path $project '.godot/toolchain/downloads'
$destination = Join-Path $env:APPDATA "Godot/export_templates/$($engine.version).stable"
$templates = @('windows_debug_x86_64.exe', 'windows_release_x86_64.exe')
if (@($templates | Where-Object { -not (Test-Path -LiteralPath (Join-Path $destination $_) -PathType Leaf) }).Count -eq 0) {
    Write-Output "Windows export templates already installed at $destination"
    return
}

[void][IO.Directory]::CreateDirectory($cache)
$archive = Join-Path $cache "Godot_v$($engine.version)-stable_export_templates.tpz"
if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) {
    $part = "$archive.$([guid]::NewGuid().ToString('N')).part"
    try {
        Invoke-WebRequest -Uri $engine.exportTemplates.url -OutFile $part -TimeoutSec 600
        if ((Get-FileHash -LiteralPath $part -Algorithm SHA256).Hash -ne $engine.exportTemplates.sha256) {
            throw 'Godot export template checksum mismatch.'
        }
        [IO.File]::Move($part, $archive, $false)
    } finally {
        if (Test-Path -LiteralPath $part -PathType Leaf) { Remove-Item -LiteralPath $part }
    }
}
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $engine.exportTemplates.sha256) {
    throw "Godot export template checksum mismatch at $archive"
}

$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    [void][IO.Directory]::CreateDirectory($destination)
    foreach ($name in $templates) {
        $entry = $zip.GetEntry("templates/$name")
        if (-not $entry) { throw "Official archive is missing $name." }
        $target = Join-Path $destination $name
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $false)
        }
    }
} finally {
    $zip.Dispose()
}
Write-Output "Installed Windows export templates at $destination"
