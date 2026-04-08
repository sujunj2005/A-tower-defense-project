# Task 4 GUT Test Runner Script
# Run GUT tests using Godot command line

$godotPath = "C:\Program Files (x86)\Steam\steamapps\common\Godot\Godot_v4.6-stable_windows.exe"

if (Test-Path $godotPath) {
    Write-Host "Found Godot: $godotPath"
    & $godotPath --headless --path "e:\Test_MCP\first\TestMCP" -s "res://test/run_task4_headless.gd"
} else {
    Write-Host "Error: Godot not found at default path"
    Write-Host "Please install Godot or set correct path"
    exit 1
}
