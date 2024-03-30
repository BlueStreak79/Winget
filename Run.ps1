# Suppress progress information
$progressPreference = 'silentlyContinue'

# Check if WinGet is installed
$wingetInstalled = Get-Command "winget" -ErrorAction SilentlyContinue

# If WinGet is not installed, download and install it
if (-not $wingetInstalled) {
    Write-Host "Downloading WinGet..."

    # Download WinGet
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

    # Install WinGet
    try {
        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -ErrorAction Stop
        Write-Host "WinGet installed successfully."
    }
    catch {
        Write-Host "An error occurred during installation: $_"
    }
}
else {
    Write-Host "WinGet is already installed."
}

# Check if WinGet is installed successfully and verify everything works
$wingetInstalled = Get-Command "winget" -ErrorAction SilentlyContinue
if ($wingetInstalled) {
    Write-Host "Verifying WinGet installation..."
    # Run a sample command to verify WinGet functionality
    try {
        $wingetOutput = winget --version
        Write-Host "WinGet installation verified. Version: $wingetOutput"
    }
    catch {
        Write-Host "An error occurred while verifying WinGet installation: $_"
    }
}
else {
    Write-Host "WinGet installation failed. Please check for errors."
}
