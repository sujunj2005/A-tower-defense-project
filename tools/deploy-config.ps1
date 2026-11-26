#Requires -Version 7.2
param(
    [Parameter(Mandatory)][string]$Destination,
    [switch]$ImportWorkbook
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ($ImportWorkbook) {
    if (-not (Test-Path -LiteralPath (Join-Path $root 'xlsx/config.xlsx') -PathType Leaf)) {
        throw 'Missing xlsx/config.xlsx. Restore the authorized workbook or export it from the current JSON.'
    }
    & python (Join-Path $root 'config_tool.py') import
    if ($LASTEXITCODE -ne 0) { throw 'Workbook import failed.' }
}
$files = @(Get-ChildItem -LiteralPath (Join-Path $root 'data') -File -Filter '*.json')
if ($files.Count -eq 0) { throw 'No project JSON data to deploy.' }
foreach ($file in $files) {
    Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -AsHashtable | Out-Null
}
$target = Join-Path $Destination 'data'
[void][IO.Directory]::CreateDirectory($target)
foreach ($file in $files) {
    Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $target $file.Name)
}
Write-Output "Deployed $($files.Count) JSON files to $target"
