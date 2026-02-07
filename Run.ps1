# WinGet Bootstrapper - Single File (Existence + Non-Admin Tolerant)
# Usage: irm URL | iex

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Write-Host "=== WinGet Bootstrapper ==="

# ---- Check if WinGet already exists ----
try {
    if (Get-Command winget -ErrorAction Stop) {
        Write-Host "WinGet already installed. Skipping bootstrap." -ForegroundColor Green
        return
    }
}
catch {
    Write-Host "WinGet not detected. Proceeding with installation..."
}

# ---- Check Admin Rights ----
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "WARNING: Not running as Administrator." -ForegroundColor Yellow
    Write-Host "Attempting user-scope WinGet module install..."
}

try {
    # ---- Ensure NuGet ----
    Write-Host "Ensuring NuGet Package Provider..."
    Install-PackageProvider -Name NuGet -Force -Confirm:$false | Out-Null

    # ---- Install WinGet PowerShell Module ----
    Write-Host "Installing Microsoft.WinGet.Client module..."
    Install-Module -Name Microsoft.WinGet.Client `
        -Repository PSGallery `
        -Force `
        -Confirm:$false `
        -AllowClobber `
        -Scope ($IsAdmin ? 'AllUsers' : 'CurrentUser') | Out-Null

    # ---- Bootstrap WinGet ----
    if ($IsAdmin) {
        Write-Host "Bootstrapping / Repairing WinGet (All Users)..."
        Repair-WinGetPackageManager -AllUsers
    }
    else {
        Write-Host "Skipping Repair-WinGetPackageManager (Admin required)."
        Write-Host "WinGet may already exist via App Installer."
    }

    # ---- Final Validation ----
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is now available." -ForegroundColor Green
    }
    else {
        Write-Host "WinGet installation attempted but not detected." -ForegroundColor Yellow
        Write-Host "If this is LTSC or Store-less Windows, manual App Installer may be required."
    }
}
catch {
    Write-Host "WinGet bootstrap failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
