#Requires -Version 7.2
param([string]$Destination = 'stable/0.0.3')

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$output = [IO.Path]::GetFullPath($Destination, $root)
& (Join-Path $PSScriptRoot 'install-windows-export-templates.ps1')
[void][IO.Directory]::CreateDirectory($output)
$godot = & (Join-Path $PSScriptRoot 'resolve-godot.ps1')
$exe = Join-Path $output 'TestMCP.exe'
& $godot --headless --path $root --export-release 'Windows Desktop' $exe
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $exe -PathType Leaf) -or
    -not (Test-Path -LiteralPath (Join-Path $output 'TestMCP.pck') -PathType Leaf)) { throw 'Windows export did not produce the executable and PCK.' }
& (Join-Path $PSScriptRoot 'deploy-config.ps1') -Destination $output
