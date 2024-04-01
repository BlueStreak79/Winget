if ($PSVersionTable.PSVersion.Major -eq 7) {
  Write-Warning "This script is not recommended for PowerShell 7. Use Windows PowerShell instead."
  return
}

# Check for Desktop App Installer
$requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"

if (-Not $requirement) {
  Write-Verbose "Installing Desktop App Installer requirement..."
  Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -ErrorAction Stop
}

# Register winget
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

# Function to install application with retry
function Install-WithRetry ($appId, $source) {
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
Install-WithRetry -appId "Adobe.Acrobat.Reader.DC" -source "adobe.com"
Install-WithRetry -appId "Google.Chrome" -source "winget.run"
Install-WithRetry -appId "VideoLAN.VLC" -source "winget.run"
Install-WithRetry -appId "WinRAR.WinRAR" -source "winrar.com"

Write-Host "Script execution complete."
