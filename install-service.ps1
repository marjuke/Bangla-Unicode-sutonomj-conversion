param(
    [string]$NssmPath = "C:\\tools\\nssm\\nssm.exe",
    [string]$ServiceName = "UnicodeBijoyAPI",
    [string]$AppDir = "D:\\PyProject",
    [string]$Host = "127.0.0.1",
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

$python = Join-Path $AppDir ".venv\\Scripts\\python.exe"
if (-not (Test-Path $python)) {
    throw "Virtualenv Python not found at $python. Create venv first."
}

if (-not (Test-Path $NssmPath)) {
    throw "NSSM not found at $NssmPath. Update -NssmPath to your nssm.exe."
}

& $NssmPath install $ServiceName $python "-m uvicorn api:app --host $Host --port $Port"
& $NssmPath set $ServiceName AppDirectory $AppDir
& $NssmPath set $ServiceName AppEnvironmentExtra "PYTHONIOENCODING=utf-8"
& $NssmPath start $ServiceName

Write-Host "Service '$ServiceName' installed and started."
