param(
    [string]$PythonPath = "",
    [ValidateSet("core", "warehouse", "warehouse-role", "traffic", "powergrid", "reward", "role", "hmf", "distributed")]
    [string]$Feature = "core"
)
$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONDONTWRITEBYTECODE = "1"
$env:PYTHONNOUSERSITE = "1"
$env:PIP_CONFIG_FILE = "NUL"
$env:PIP_DISABLE_PIP_VERSION_CHECK = "1"
$env:PIP_NO_INDEX = "1"
$env:PIP_EXTRA_INDEX_URL = ""
$env:PIP_FIND_LINKS = ""
$bundleRoot = Split-Path -Parent $PSScriptRoot

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
    Invoke-Checked $PythonPath @("-I", "-c", "import platform,struct,sys; assert sys.version_info[:2]==(3,12) and platform.python_implementation()=='CPython'; assert sys.platform=='win32' and struct.calcsize('P')==8 and platform.machine().lower() in ('amd64','x86_64'), 'Windows CPython 3.12 x64 required'")
    Invoke-Checked $PythonPath @("-I", (Join-Path $bundleRoot "verify_bundle.py"))
    Invoke-Checked $PythonPath @("-I", "-c", "import pathlib,sys,zipfile; root=pathlib.Path(sys.argv[1]); site=root/'.venv/Lib/site-packages'; longest=max((len(str(site/item)) for wheel in (root/'wheelhouse').glob('*.whl') for item in zipfile.ZipFile(wheel).namelist()), default=0); print('Longest estimated installation path:', longest); assert longest < 260, 'Installation path is too deep for default Windows path limits. Extract the ZIP to a shorter writable folder and retry.'", $bundleRoot)

    $venvRoot = Join-Path $bundleRoot ".venv"
    $venvPython = Join-Path $venvRoot "Scripts\python.exe"
    $markerPath = Join-Path $venvRoot "engineering-install.json"
    if (Test-Path -LiteralPath $venvRoot) {
        if (-not (Test-Path -LiteralPath $markerPath)) { throw "Existing .venv has no engineering delivery marker. Extract into a fresh directory." }
        $marker = Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
        if ($marker.edition -ne "windows-x64-cpu-py312-engineering" -or $marker.root -ne $bundleRoot) {
            throw "This .venv belongs to another delivery location. Extract a fresh copy before installing."
        }
    } else {
        Invoke-Checked $PythonPath @("-I", "-m", "venv", $venvRoot)
        @{edition="windows-x64-cpu-py312-engineering";root=$bundleRoot} | ConvertTo-Json | Set-Content -LiteralPath $markerPath -Encoding UTF8
    }
    Invoke-Checked $venvPython @("-I", "-c", "import pathlib,sys; assert pathlib.Path(sys.prefix).resolve()==pathlib.Path(sys.argv[1]).resolve(), 'Wrong environment'", $venvRoot)
    Invoke-Checked $venvPython @("-I", "-m", "pip", "install", "--no-index", "--no-cache-dir", "--only-binary=:all:", "--no-deps", "--find-links", (Join-Path $bundleRoot "wheelhouse"), "--require-hashes", "-r", (Join-Path $bundleRoot "requirements-lock.txt"))
    Invoke-Checked $venvPython @("-I", "-m", "pip", "check")
    Invoke-Checked $venvPython @("-I", "-c", "import unified_marl; assert unified_marl.__version__=='0.8.0'; print('Installed unified_marl', unified_marl.__version__)")

    if ($Feature -eq "powergrid") {
        $featureRequirements = Join-Path $bundleRoot "requirements-powergrid.txt"
        if (-not (Test-Path -LiteralPath $featureRequirements -PathType Leaf)) {
            throw "Optional powergrid requirements are not included. Follow docs/POWERGRID_GUIDE.md to install that feature."
        }
        $env:PIP_NO_INDEX = ""
        $env:PIP_EXTRA_INDEX_URL = ""
        $env:PIP_FIND_LINKS = ""
        Invoke-Checked $venvPython @("-I", "-m", "pip", "install", "--find-links", (Join-Path $bundleRoot "wheelhouse"), "--index-url", "https://pypi.org/simple", "-r", $featureRequirements)
        Invoke-Checked $venvPython @("-I", "-m", "pip", "check")
    }
    if ($Feature -eq "traffic") {
        Write-Host "CityFlow is built from its external source. Follow docs/TRAFFIC_GUIDE.md; no traffic simulator was downloaded."
    }
    if ($Feature -in @("warehouse", "warehouse-role", "reward", "role", "hmf", "distributed")) {
        Write-Host "The selected feature uses the bundled Windows wheel set."
    }
    Write-Host "Base installation finished. No training or simulation was started. Use windows\run.ps1 --help."
    exit 0
} catch {
    Write-Error -ErrorAction Continue ("Installation failed: " + $_.Exception.Message)
    exit 1
}
