#Requires -Version 7.2
param([string]$GodotBin = $env:GODOT_BIN)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engine = (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'godot-toolchain.json') -Raw | ConvertFrom-Json).godot
if (-not $GodotBin) {
    $GodotBin = Join-Path $projectRoot ".godot/toolchain/godot-$($engine.version)/$($engine.console)"
}
if (-not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) {
    throw "Godot executable not found at $GodotBin. Run tools/bootstrap.ps1 or set GODOT_BIN to a Godot 4.7 console executable."
}

$executable = (Resolve-Path -LiteralPath $GodotBin).ProviderPath
if ([IO.Path]::GetExtension($executable) -ine '.exe') {
    throw 'GODOT_BIN must point directly to a Godot executable (.exe).'
}

$version = & $executable --version
$supportedSeries = [regex]::Escape(($engine.version -split '\.' | Select-Object -First 2) -join '.')
if ($LASTEXITCODE -ne 0 -or $version -notmatch "^${supportedSeries}\.\d+\.stable\b") {
    throw "Expected a Godot 4.7 stable console executable. Received version '$version' from $executable."
}
$executable
