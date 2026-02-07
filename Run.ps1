# WinGet Bootstrapper - Single File (PS 5.1 Compatible)
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

if ($IsAdmin) {
    $InstallScope = 'AllUsers'
}
else {
    $InstallScope = 'CurrentUser'
    Write-Host "WARNING: Not running as Administrator." -ForegroundColor Yellow
    Write-Host "Attempting user-scope installation..."
}

try {
    # ---- Ensure NuGet ----
    Write-Host "Ensuring NuGet Package Provider..."
    Install-PackageProvider -Name NuGet -Force -Confirm:$false | Out-Null

    # ---- Install WinGet PowerShell Module ----
    Write-Host "Installing Microsoft.WinGet.Client module ($InstallScope)..."
    Install-Module -Name Microsoft.WinGet.Client `
        -Repository PSGallery `
        -Force `
        -Confirm:$false `
        -AllowClobber `
        -Scope $InstallScope | Out-Null

    # ---- Bootstrap WinGet ----
    if ($IsAdmin) {
        Write-Host "Bootstrapping / Repairing WinGet (All Users)..."
        Repair-WinGetPackageManager -AllUsers
    }
    else {
        Write-Host "Skipping Repair-WinGetPackageManager (Admin required)."
        Write-Host "If App Installer already exists, WinGet should still work."
    }

    # ---- Final Validation ----
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is now available." -ForegroundColor Green
    }
    else {
        Write-Host "WinGet not detected after install attempt." -ForegroundColor Yellow
        Write-Host "Likely LTSC / Store-less system."
    }
}
catch {
    Write-Host "WinGet bootstrap failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
