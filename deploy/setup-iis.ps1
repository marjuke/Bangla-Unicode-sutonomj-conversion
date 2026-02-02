# IIS Setup Script for Unicode Bijoy API
# Run as Administrator

param(
    [string]$SiteName = "UnicodeBijoyAPI",
    [string]$SitePath = "C:\inetpub\UnicodeBijoyAPI",
    [string]$AppSourcePath = "C:\Apps\UnicodeBijoyAPI",
    [int]$Port = 80
)

$ErrorActionPreference = "Stop"

Write-Host "=== IIS Setup for Unicode Bijoy API ===" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "Please run this script as Administrator"
}

# Step 1: Install IIS
Write-Host "`n[1/6] Installing IIS..." -ForegroundColor Yellow
$iisFeature = Get-WindowsFeature -Name Web-Server
if (-not $iisFeature.Installed) {
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    Write-Host "  IIS installed successfully" -ForegroundColor Green
} else {
    Write-Host "  IIS already installed" -ForegroundColor Green
}

# Step 2: Check for URL Rewrite and ARR
Write-Host "`n[2/6] Checking URL Rewrite and ARR modules..." -ForegroundColor Yellow

$urlRewritePath = "$env:SystemRoot\System32\inetsrv\rewrite.dll"
$arrPath = "$env:SystemRoot\System32\inetsrv\requestRouter.dll"

if (-not (Test-Path $urlRewritePath)) {
    Write-Host "  WARNING: URL Rewrite module not found!" -ForegroundColor Red
    Write-Host "  Please download and install from:" -ForegroundColor Yellow
    Write-Host "  https://www.iis.net/downloads/microsoft/url-rewrite" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") { exit }
} else {
    Write-Host "  URL Rewrite module found" -ForegroundColor Green
}

if (-not (Test-Path $arrPath)) {
    Write-Host "  WARNING: Application Request Routing (ARR) not found!" -ForegroundColor Red
    Write-Host "  Please download and install from:" -ForegroundColor Yellow
    Write-Host "  https://www.iis.net/downloads/microsoft/application-request-routing" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") { exit }
} else {
    Write-Host "  ARR module found" -ForegroundColor Green
}

# Step 3: Enable ARR Proxy
Write-Host "`n[3/6] Enabling ARR Proxy..." -ForegroundColor Yellow
try {
    & "$env:SystemRoot\System32\inetsrv\appcmd.exe" set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>$null
    Write-Host "  ARR Proxy enabled" -ForegroundColor Green
} catch {
    Write-Host "  Could not enable ARR Proxy (may need manual configuration)" -ForegroundColor Yellow
}

# Step 4: Create site directory and copy files
Write-Host "`n[4/6] Setting up site directory..." -ForegroundColor Yellow
if (-not (Test-Path $SitePath)) {
    New-Item -ItemType Directory -Path $SitePath -Force | Out-Null
}

# Copy web.config
$webConfigSource = Join-Path $AppSourcePath "web.config"
if (Test-Path $webConfigSource) {
    Copy-Item $webConfigSource (Join-Path $SitePath "web.config") -Force
    Write-Host "  web.config copied" -ForegroundColor Green
} else {
    Write-Host "  WARNING: web.config not found at $webConfigSource" -ForegroundColor Yellow
}

# Step 5: Create IIS Site
Write-Host "`n[5/6] Creating IIS site..." -ForegroundColor Yellow
Import-Module WebAdministration

# Check if site exists
$existingSite = Get-Website -Name $SiteName -ErrorAction SilentlyContinue
if ($existingSite) {
    Write-Host "  Site '$SiteName' already exists. Removing..." -ForegroundColor Yellow
    Remove-Website -Name $SiteName
}

# Check if port is in use by another site
$portInUse = Get-Website | Where-Object { $_.Bindings.Collection.bindingInformation -like "*:${Port}:*" }
if ($portInUse) {
    Write-Host "  Port $Port is used by site: $($portInUse.Name)" -ForegroundColor Yellow
    $remove = Read-Host "  Remove binding from that site? (Y/N)"
    if ($remove -eq "Y" -or $remove -eq "y") {
        Remove-WebBinding -Name $portInUse.Name -Port $Port -Protocol "http"
    }
}

# Create the site
New-Website -Name $SiteName -Port $Port -PhysicalPath $SitePath -ApplicationPool "DefaultAppPool" | Out-Null
Write-Host "  Site '$SiteName' created on port $Port" -ForegroundColor Green

# Set App Pool to No Managed Code
Set-ItemProperty "IIS:\AppPools\DefaultAppPool" -Name "managedRuntimeVersion" -Value ""
Write-Host "  App Pool configured for reverse proxy" -ForegroundColor Green

# Step 6: Configure Firewall
Write-Host "`n[6/6] Configuring firewall..." -ForegroundColor Yellow
$existingRule = Get-NetFirewallRule -DisplayName "HTTP Inbound" -ErrorAction SilentlyContinue
if (-not $existingRule) {
    New-NetFirewallRule -DisplayName "HTTP Inbound" -Direction Inbound -Port 80 -Protocol TCP -Action Allow | Out-Null
    Write-Host "  Firewall rule for port 80 created" -ForegroundColor Green
} else {
    Write-Host "  Firewall rule for port 80 already exists" -ForegroundColor Green
}

# Final status
Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Make sure your API backend is running on localhost:8000" -ForegroundColor Yellow
Write-Host "   Docker: docker-compose up -d" -ForegroundColor Gray
Write-Host "   Service: Start-Service UnicodeBijoyAPI" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Test the API through IIS:" -ForegroundColor Yellow
Write-Host "   Invoke-RestMethod -Uri 'http://localhost/health'" -ForegroundColor Gray
Write-Host ""
Write-Host "Your API will be available at: http://YOUR-SERVER-IP/" -ForegroundColor Green
