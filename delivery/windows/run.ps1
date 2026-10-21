$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONNOUSERSITE = "1"
$env:PYTHONDONTWRITEBYTECODE = "1"
$pythonExecutable = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path -LiteralPath $pythonExecutable)) {
    Write-Error "Run install.ps1 first."
    exit 1
}
& $pythonExecutable -X utf8 -I -m unified_marl @args
exit $LASTEXITCODE
