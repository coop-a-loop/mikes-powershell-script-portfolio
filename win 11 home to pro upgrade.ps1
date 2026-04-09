# Enable TLS1.2 and TLS1.3
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType] 'Tls12'

$RMM = 1
$ScriptURL = $env:scripturl
$RMMScriptPath = $env:PROGRAMDATA + "\NinjaRMMAgent\scripting"
$Description = "Running from RMM. Upgrade Windows 11 Home to Pro."

Write-Host "Script URL: " $ScriptURL
Write-Host "RMM Script Path: " $RMMScriptPath
Write-Host "Description: " $Description

# Script specific varaibles
$computerName = $env:COMPUTERNAME
$osInfo = $null
$windowsEditionId = $null
$isWindows10 = $false
$isWindows11 = $false
$isHomeEdition = $false
$win11ProUpgradeNeeded = $false
$win11ProProductKey = $null
$productKeyMatch = $false

$ScriptLogName = "msft-windows-win11-pro-upgrade.log"
$LogPath = "$ENV:WINDIR\logs\$ScriptLogName"

Start-Transcript -Path $LogPath

Write-Host "Description: $Description"
Write-Host "Log path: $LogPath"
Write-Host "RMM: $RMM"
Write-Host "Computer Name: " $computerName

# Define hash table mapping computer name to win 11 pro 

$Win11ProProductKeyMap = @{
  "<insert computer name 1" = "<insert win 11 pro product key 1>"
  "<insert computer name 2" = "<insert win 11 pro product key 2>"
  "<insert computer name 3" = "<insert win 11 pro product key 3>"
  "<insert computer name 4" = "<insert win 11 pro product key 4>"
}

# Check existing computer name for win 11 pro product activation key match.

if ($Win11ProProductKeyMap.ContainsKey($computerName)) {
     $win11ProProductKey = $Win11ProProductKeyMap[$computerName]
     $productKeyMatch = $true
     Write-Host "Win 11 Product Activation Key found for $computerName"
     Write-Host "Product Activation Key: $win11ProProductKey"
 } else {
   Write-Host "Match for existing computer name not found"
}

# If product key match found, only upgrade if Win 11 Home / Core

if ($productKeyMatch) {
  
  # Function to check for Win 11 Home / Core
  function Check-Windows11Home {
    # Get the Windows version and edition information
    $osBuild = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber
    $windowsEdition = (Get-ComputerInfo).WindowsEditionId
    $win11ProUpgradeNeeded = $false
    
    # Check if Windows version is 22000 or higher (Windows 11)
    $isWindows11 = [int]$osBuild -ge 22000
    
    # Check if Windows version is between 10240 and 22000 (Windows 10)
    $isWindows10 = [int]$osBuild -ge 10240 -and [int]$osBuild -lt 22000

    # Check if the edition is "Home" or "Core"
    $isHomeEdition = $windowsEdition -eq "Home" -or $windowsEdition -eq "Core"

    # Evaluate and return results
    if ($isWindows11 -and $isHomeEdition) {
      Write-Host "The computer is running Windows 11 $windowsEdition edition. Upgrade to Windows 11 Pro is needed."
      $win11ProUpgradeNeeded = $true
    } elseif ($isWindows11) {
      Write-Host "The computer is already running Windows 11 $windowsEdition edition."
    } elseif ($isWindows10) {
      Write-Host "The computer is running Windows 10 $windowsEdition edition."
    } else {
      Write-Host "The computer is running an earlier version of Windows (pre-Windows 10)."
      Write-Host "OS Build Number: $osBuild"
      Write-Host "OS Edition: $windowsEdition"
    }
    return $win11ProUpgradeNeeded
  }

  # Call the function
  $win11ProUpgradeNeeded = Check-Windows11Home
  
  Write-Host "Is Upgrade needed: $win11ProUpgradeNeeded."

  # Upgrade computer to Win 11 Pro

  If ($win11ProUpgradeNeeded) {
    # Upgrade from Win 11 Home to Pro
    try {
      changepk.exe /ProductKey $win11ProProductKey
      Write-Host "$computerName has been upgraded to Windows 11 Pro and will take effect on next reboot."
    } catch {
      Write-Host "Failed to upgrade the computer to Windows 11 Pro. Error: $_"
    }
  } else {
    # Upgrade not needed
    Write-Host "Computer is not running Windows 11 Home. No action taken."
  }

}
