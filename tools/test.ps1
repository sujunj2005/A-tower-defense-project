#Requires -Version 7.2
param(
    [ValidateSet('All', 'Unit', 'Integration')]
    [string]$Suite = 'All',
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$projectRoot = Split-Path -Parent $PSScriptRoot

foreach ($entry in @('addons/gut/gut_cmdln.gd', 'addons/godot_ai/runtime/game_helper.gd', '.gutconfig_all.json')) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $entry) -PathType Leaf)) {
        throw "Missing $entry. Run tools/bootstrap.ps1 and check the project files."
    }
}
$godot = & (Join-Path $PSScriptRoot 'resolve-godot.ps1') -GodotBin $GodotBin

$runRelative = '.godot/test-results/' + [guid]::NewGuid().ToString('N')
$runDirectory = Join-Path $projectRoot $runRelative
[void][IO.Directory]::CreateDirectory($runDirectory)
Write-Host "Test results: $runDirectory"

# Godot resolves user:// and editor settings through APPDATA on Windows.
$originalAppData = $env:APPDATA
$env:APPDATA = Join-Path $runDirectory 'appdata'
[void][IO.Directory]::CreateDirectory($env:APPDATA)
try {
    $importLog = Join-Path $runDirectory 'import.log'
    & $godot --headless --path $projectRoot --editor --import *> $importLog
    $importExit = $LASTEXITCODE
    if ($importExit -ne 0) {
        Get-Content -LiteralPath $importLog -Tail 45
        throw "Godot import failed (exit $importExit). See $importLog"
    }

    $suites = if ($Suite -eq 'All') { @('unit', 'integration') } else { @($Suite.ToLowerInvariant()) }
    $exitCode = 0
    if (Select-String -LiteralPath $importLog -Pattern '^SCRIPT ERROR: (Parse|Compile) Error:' -Quiet) {
        Write-Warning "Godot reported a script compilation error during import. See $importLog"
        $exitCode = 1
    }
    foreach ($name in $suites) {
        Write-Host "Running GUT $name tests"
        $log = Join-Path $runDirectory "$name.log"
        $report = Join-Path $runDirectory "$name.xml"
        & $godot --headless --path $projectRoot -s res://addons/gut/gut_cmdln.gd `
            -gconfig=res://.gutconfig_all.json "-gdir=res://tests/$name" -gexit `
            "-gjunit_xml_file=res://$runRelative/$name.xml" *> $log
        $gutExit = $LASTEXITCODE

        if (-not (Test-Path -LiteralPath $report -PathType Leaf)) {
            Write-Warning "GUT $name produced no JUnit report (exit $gutExit). See $log"
            Get-Content -LiteralPath $log -Tail 30
            $exitCode = 1
            continue
        }
        [xml]$junit = Get-Content -LiteralPath $report -Raw
        $result = $junit.DocumentElement
        $total = [int]$result.GetAttribute('tests')
        $failures = [int]$result.GetAttribute('failures')
        $skipped = @($junit.SelectNodes('/testsuites/testsuite/testcase/skipped')).Count
        $withoutAsserts = @($junit.SelectNodes('/testsuites/testsuite/testcase[@status="no asserts"]')).Count
        $compileError = Select-String -LiteralPath $log -Pattern '^SCRIPT ERROR: (Parse|Compile) Error:' -Quiet
        Write-Host ('{0}: {1} tests, {2} failures, {3} skipped, {4} without assertions (Godot exit {5})' -f $name, $total, $failures, $skipped, $withoutAsserts, $gutExit)
        if ($gutExit -ne 0 -or $failures -gt 0 -or $compileError -or ($total - $skipped - $withoutAsserts) -le 0) {
            Write-Warning "GUT $name did not pass. See $log and $report"
            $exitCode = 1
        }
    }
    exit $exitCode
} finally {
    $env:APPDATA = $originalAppData
}
