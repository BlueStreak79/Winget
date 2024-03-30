# Suppress progress information
$progressPreference = 'silentlyContinue'

# Function to check if a package is installed using WinGet
function Is-PackageInstalled {
    param (
        [string]$PackageId
    )
    $packageInstalled = winget show $PackageId -q
    return $packageInstalled -eq 0
}

# Function to install a package using WinGet
function Install-Package {
    param (
        [string]$PackageName
    )
    Write-Host "Installing $PackageName..."
    try {
        winget install $PackageName --silent
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

# Check if WinGet is installed
$wingetInstalled = Get-Command "winget" -ErrorAction SilentlyContinue

if (-not $wingetInstalled) {
    Write-Host "WinGet is not installed. Installing WinGet..."

    # Download and install WinGet
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    try {
        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -ErrorAction Stop
        Write-Host "WinGet installed successfully."
    }
    catch {
        Write-Host "An error occurred during installation of WinGet: $_"
        exit
    }
}

# Verify WinGet installation
$wingetInstalled = Get-Command "winget" -ErrorAction SilentlyContinue

if ($wingetInstalled) {
    Write-Host "WinGet is installed. Verifying installation..."

    # Verify WinGet functionality
    try {
        $wingetOutput = winget --version
        Write-Host "WinGet installation verified. Version: $wingetOutput"
    }
    catch {
        Write-Host "An error occurred while verifying WinGet installation: $_"
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
}
else {
    Write-Host "WinGet installation failed. Please check for errors."
}
