param(
    [string]$PythonPath = "",
    [switch]$SkipSmokeTest
)
$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONDONTWRITEBYTECODE = "1"
$env:PYTHONNOUSERSITE = "1"
$env:PIP_CONFIG_FILE = "NUL"
$env:PIP_DISABLE_PIP_VERSION_CHECK = "1"
$env:PIP_NO_INDEX = "1"
$bundleRoot = $PSScriptRoot

function Invoke-Checked([string]$Executable, [string[]]$Arguments) {
    & $Executable -X utf8 @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed (exit $LASTEXITCODE): $Executable" }
}

try {
    if ($env:OS -ne "Windows_NT") { throw "Use the Linux edition on Linux." }
    if (-not [Environment]::Is64BitOperatingSystem) { throw "64-bit Windows is required." }
    if (-not $PythonPath) {
        $launcher = Get-Command py.exe -ErrorAction SilentlyContinue
        if ($launcher) {
            $candidate = & $launcher.Source -3.12 -I -c "import json,sys; print(json.dumps(sys.executable,ensure_ascii=True))"
            if ($LASTEXITCODE -eq 0) { $PythonPath = (($candidate | Select-Object -Last 1) | ConvertFrom-Json) }
        }
        if (-not $PythonPath) {
            $candidate = Get-Command python.exe -ErrorAction SilentlyContinue
            if ($candidate -and $candidate.Source -notmatch "WindowsApps") { $PythonPath = $candidate.Source }
        }
    }
    if (-not $PythonPath -or -not (Test-Path -LiteralPath $PythonPath -PathType Leaf)) {
        throw "Install CPython 3.12 x64 first, or pass -PythonPath C:\Path\python.exe. Python itself is not bundled."
    }
    $PythonPath = (Resolve-Path -LiteralPath $PythonPath).Path
    Invoke-Checked $PythonPath @("-I", "-c", "import sys,struct,platform; assert sys.version_info[:2]==(3,12), 'CPython 3.12 required'; assert platform.python_implementation()=='CPython'; assert sys.platform=='win32' and struct.calcsize('P')==8 and platform.machine().lower() in ('amd64','x86_64'), 'Windows x64 required'")
    Invoke-Checked $PythonPath @("-I", (Join-Path $bundleRoot "verify_bundle.py"))
    $venvRoot = Join-Path $bundleRoot ".venv"
    Invoke-Checked $PythonPath @("-I", "-c", "import pathlib,sys,zipfile; root=pathlib.Path(sys.argv[1]); site=root/'.venv/Lib/site-packages'; longest=max((len(str(site/item)) for wheel in (root/'wheelhouse').glob('*.whl') for item in zipfile.ZipFile(wheel).namelist()), default=0); print('Longest estimated installation path:',longest); assert longest < 260, 'Installation path is too deep for default Windows path limits. Extract the ZIP to a shorter writable folder (for example D:/marl) and retry. No system setting has been changed.'", $bundleRoot)
    $markerPath = Join-Path $venvRoot "internal-install.json"
    $venvPython = Join-Path $venvRoot "Scripts\python.exe"
    if (Test-Path -LiteralPath $venvRoot) {
        if (-not (Test-Path -LiteralPath $markerPath)) { throw "Existing .venv has no delivery marker. Use a newly extracted folder; no existing environment will be overwritten." }
        $marker = Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
        if ($marker.edition -ne "windows-x64-cpu-py312" -or $marker.root -ne $bundleRoot) {
            throw "This environment belongs to another location/edition. Re-extract and install; do not copy .venv between computers."
        }
    } else {
        Invoke-Checked $PythonPath @("-I", "-m", "venv", $venvRoot)
        @{edition="windows-x64-cpu-py312";root=$bundleRoot} | ConvertTo-Json | Set-Content -LiteralPath $markerPath -Encoding UTF8
    }
    Invoke-Checked $venvPython @("-I", "-c", "import sys,pathlib; assert pathlib.Path(sys.prefix).resolve()==pathlib.Path(sys.argv[1]).resolve(), 'Wrong environment'", $venvRoot)
    Invoke-Checked $venvPython @("-I", "-m", "pip", "install", "--no-index", "--no-cache-dir", "--only-binary=:all:", "--find-links", (Join-Path $bundleRoot "wheelhouse"), "--require-hashes", "-r", (Join-Path $bundleRoot "requirements-lock.txt"))
    Invoke-Checked $venvPython @("-I", "-m", "pip", "check")
    Invoke-Checked $venvPython @("-I", "-c", "import torch,unified_marl; assert torch.__version__=='2.6.0+cpu'; assert unified_marl.__version__=='0.7.0'; print('Installed:', unified_marl.__version__, torch.__version__)")
    if (-not $SkipSmokeTest) {
        $stamp = [Guid]::NewGuid().ToString("N")
        Invoke-Checked $venvPython @("-I", (Join-Path $bundleRoot "smoke_test.py"), "--output", (Join-Path $bundleRoot "results\install-check-$stamp"))
    }
    Write-Host "Installation finished. Use run.ps1 --help. For Python scripts use .venv\Scripts\python.exe."
    exit 0
} catch {
    Write-Error -ErrorAction Continue ("Installation failed: " + $_.Exception.Message)
    exit 1
}
