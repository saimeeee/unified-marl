$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONNOUSERSITE = "1"
$env:PYTHONDONTWRITEBYTECODE = "1"
$bundleRoot = Split-Path -Parent $PSScriptRoot
$applicationCli = Join-Path $bundleRoot ".venv\Scripts\unified-marl-app.exe"
if (-not (Test-Path -LiteralPath $applicationCli -PathType Leaf)) {
    Write-Error "Run windows\install.ps1 first."
    exit 2
}
& $applicationCli @args
exit $LASTEXITCODE
