# IIS Deployment Guide for Unicode Bijoy API

## Architecture

```
Internet → IIS (port 80/443) → Reverse Proxy → Uvicorn (port 8000)
```

IIS handles SSL, authentication, and forwards requests to your API running on localhost:8000.

---

## Prerequisites

### 1. Install IIS with Required Features

Run in PowerShell as Administrator:

```powershell
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
```

### 2. Install Required Modules

Download and install manually:
- [URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite)
- [Application Request Routing 3.0](https://www.iis.net/downloads/microsoft/application-request-routing)

### 3. Enable ARR Proxy

```powershell
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/proxy /enabled:"True" /commit:apphost
```

---

## Deployment Steps

### Step 1: Install Python and Setup Project

```powershell
# Install Python 3.12 from https://python.org (check "Add to PATH")

# Copy project to server (e.g., C:\Apps\UnicodeBijoyAPI)

cd C:\Apps\UnicodeBijoyAPI

# Create virtual environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Install as Windows Service

Run as Administrator:
```powershell
cd C:\Apps\UnicodeBijoyAPI
.\install-service.ps1
```

Verify it's running:
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/health"
```

### Step 3: Setup IIS

Run as Administrator:
```powershell
cd C:\Apps\UnicodeBijoyAPI\deploy
.\setup-iis.ps1
```

### Step 4: Test

```powershell
Invoke-RestMethod -Uri "http://localhost/health"
```

---

## SSL/HTTPS Setup

### Option 1: Use a Certificate

```powershell
$cert = Import-PfxCertificate -FilePath "C:\certs\your-cert.pfx" -CertStoreLocation "Cert:\LocalMachine\My" -Password (ConvertTo-SecureString "password" -AsPlainText -Force)

New-WebBinding -Name "UnicodeBijoyAPI" -Protocol "https" -Port 443 -SslFlags 0
$binding = Get-WebBinding -Name "UnicodeBijoyAPI" -Protocol "https"
$binding.AddSslCertificate($cert.Thumbprint, "My")
```

### Option 2: Use Let's Encrypt (Free)

Install win-acme: https://www.win-acme.com/

```powershell
wacs.exe --target iis --siteid 1 --installation iis
```

---

## Firewall Rules

```powershell
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Port 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -Port 443 -Protocol TCP -Action Allow
```

---

## Service Management

```powershell
# Check status
Get-Service UnicodeBijoyAPI

# Start/Stop/Restart
Start-Service UnicodeBijoyAPI
Stop-Service UnicodeBijoyAPI
Restart-Service UnicodeBijoyAPI
```

---

## Troubleshooting

### 502 Bad Gateway
- API backend is not running
- Check: `Invoke-RestMethod -Uri "http://localhost:8000/health"`
- Start service: `Start-Service UnicodeBijoyAPI`

### 500 Internal Server Error
- URL Rewrite module not installed
- ARR not enabled

### Check IIS Logs
```powershell
Get-Content "C:\inetpub\logs\LogFiles\W3SVC1\*.log" -Tail 50
```
