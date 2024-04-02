$progressPreference = 'silentlyContinue'

# Function to install application with retry
function Install-WithRetry ($appId, $source) {
    $retryCount = 3
    $retryDelay = 5  # seconds
    
    for ($i = 1; $i -le $retryCount; $i++) {
        Write-Host "Attempting to install $appId (Attempt $i of $retryCount)..."
        
        if (winget show $appId 2>$null) {
            Write-Host "$appId already installed."
            return $true
        }

        $installResult = winget install --id $appId --source $source -Quiet -ErrorAction SilentlyContinue

        if ($installResult) {
            Write-Host "$appId installation successful!"
            return $true
        } else {
            Write-Warning "$appId installation failed. Retrying in $retryDelay seconds..."
            Start-Sleep -Seconds $retryDelay
        }
    }
    
    Write-Error "Failed to install $appId after $retryCount attempts."
    return $false
}

# Function to check if dependencies are installed
function Check-Dependencies {
    $wingetPath = Get-Command -Name "winget.exe" -ErrorAction SilentlyContinue
    $vclibsInstalled = Get-AppPackage "Microsoft.VCLibs.x64.14.00.Desktop" -ErrorAction SilentlyContinue
    $uixamlInstalled = Get-AppPackage "Microsoft.UI.Xaml.2.8.x64" -ErrorAction SilentlyContinue
    return ($wingetPath -and $vclibsInstalled -and $uixamlInstalled)
}

# Check if dependencies are installed
$wingetPath = Get-Command -Name "winget.exe" -ErrorAction SilentlyContinue

if (-not $wingetPath) {
    Write-Information "Downloading and installing Winget..."
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
}

# Check dependencies only if Winget is installed
if ($wingetPath) {
    $vclibsInstalled = Get-AppPackage "Microsoft.VCLibs.x64.14.00.Desktop" -ErrorAction SilentlyContinue
    $uixamlInstalled = Get-AppPackage "Microsoft.UI.Xaml.2.8.x64" -ErrorAction SilentlyContinue
    
    if (-not ($vclibsInstalled -and $uixamlInstalled)) {
        Write-Information "Installing missing dependencies..."
        
        # Install missing dependencies
        if (-not $vclibsInstalled) {
            Write-Information "Installing VCLibs..."
            Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction SilentlyContinue
            Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        }
        
        if (-not $uixamlInstalled) {
            Write-Information "Installing UI.Xaml..."
            Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx -ErrorAction SilentlyContinue
            Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
        }
    }
}

# Install applications using winget with retry function
$apps = @(
    @{Id="7zip.7z"; Source="winget.run"},
    @{Id="Adobe.AcrobatReader"; Source="winget.run"},
    @{Id="Google.Chrome"; Source="winget.run"},
    @{Id="VideoLAN.VLC"; Source="winget.run"},
    @{Id="WinRAR.WinRAR"; Source="winget.run"}
)

foreach ($app in $apps) {
    Install-WithRetry -appId $app.Id -source $app.Source
}

Write-Host "Script execution complete."
