if ($PSVersionTable.PSVersion.Major -eq 7) {
  Write-Warning "This script is not recommended for PowerShell 7. Use Windows PowerShell instead."
  return
}

# Check for Desktop App Installer presence
$daiInstalled = Get-AppPackage "Microsoft.DesktopAppInstaller"

if (-Not $daiInstalled) {
  Write-Verbose "Installing Desktop App Installer requirement..."
  Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -ErrorAction Stop
} else {
  Write-Host "Desktop App Installer already installed."
}

# Check winget registration by checking if 'winget.exe' exists in the PATH
$wingetPath = Get-Command -Name "winget.exe" -ErrorAction SilentlyContinue

if ($wingetPath) {
  Write-Host "winget is already registered."
} else {
  Write-Verbose "Registering winget..."
  Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
}

# Function to install application with retry
function Install-WithRetry ($appId, $source) {
  if (winget show $appId | Out-Null) {
    Write-Host "$appId already installed."
    return
  }

  if (winget install --id $appId --source $source -Quiet -ErrorAction Stop) {
    Write-Host "$appId installation successful!"
  } else {
    Write-Warning "$appId installation failed. Retry?"
    $confirm = Read-Host "Type 'y' to retry or any other key to skip: " -NoEcho
    if ($confirm -eq "y") {
      Install-WithRetry -appId $appId -source $source
    }
  }
}

# Install applications using winget with retry function
Install-WithRetry -appId "7zip.7z" -source "winget.run"
Install-WithRetry -appId "Adobe.Acrobat.Reader.DC" -source "a
