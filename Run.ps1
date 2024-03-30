# Suppress progress information
$progressPreference = 'silentlyContinue'

# Function to check if a package is installed using WinGet
function Is-PackageInstalled {
    param (
        [string]$PackageId
    )
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        $packageInstalled = winget show $PackageId -q
        return $packageInstalled -eq 0
    }
    else {
        # Handle case when WinGet is not available (Windows 10)
        return $false
    }
}

# Function to install a package using WinGet without any user confirmations
function Install-Package {
    param (
        [string]$PackageName
    )
    Write-Host "Installing $PackageName..."
    try {
        winget install $PackageName --silent --accept-package-agreements
        Write-Host "$PackageName installed successfully."
    }
    catch {
        Write-Host "An error occurred during installation of ${PackageName}: $_"
    }
}

# Applications to install
$packagesToInstall = @(
    "WinRAR",
    "VLC.MediaPlayer",
    "Adobe.AdobeAcrobatReader",
    "Google.Chrome",
    "7Zip.7Zip"
)

# Check if WinGet is available
$wingetInstalled = Get-Command "winget" -ErrorAction SilentlyContinue

if (-not $wingetInstalled) {
    Write-Host "WinGet is not available. This script requires Windows 11 with WinGet installed."
    exit
}

# Install applications
foreach ($package in $packagesToInstall) {
    if (-not (Is-PackageInstalled $package)) {
        Install-Package $package
    }
    else {
        Write-Host "$package is already installed."
    }
}
