#Requires -Version 7.2
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$executable = & (Join-Path $PSScriptRoot 'resolve-godot.ps1')

# Omitting a param block lets PowerShell pass Godot's -- separator verbatim.
& $executable --path $projectRoot @args
exit $LASTEXITCODE
