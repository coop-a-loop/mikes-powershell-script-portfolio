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
$scriptOrgName = "<insert org name>"
$scriptLocName = "<insert location name>"
$ninjaOrgName = $env:NINJA_ORGANIZATION_NAME
$ninjaLocName = $env:NINJA_LOCATION_NAME
$isWindows1022H2 = $false
$isWindows11 = $false
$win10ESUEligible = $false
$ESUKeyMatch = $false
$win10ESUYear1ActKey = Ninja-Property-Get win10EsuYear1ActivationKey
$win10ESUEpochExpDate = Ninja-Property-Get win10EsuExpirationDate
$win10ESUAct = Ninja-Property-Get win10EsuActive
$ScriptLogName = "msft-windows-win10-esu-activation.log"
$LogPath = "$ENV:WINDIR\logs\$ScriptLogName"

$dateOnly = $null

if ($win10ESUEpochExpDate) {
  # Convert epoch time to a DateTime object
  $dateTime = [DateTimeOffset]::FromUnixTimeSeconds($win10ESUEpochExpDate).DateTime
  
  # Extract only the date
  $dateOnly = $dateTime.ToString("yyyy-MM-dd")
}

Write-Host "Log path: $LogPath"
Write-Host "RMM: $RMM"
Write-Host "Script Org Name:" $scriptOrgName
Write-Host "Script Location Name:" $scriptLocName
Write-Host "Device Org Name:" $ninjaOrgName
Write-Host "Device Location Name:" $ninjaLocName
Write-Host "Computer Name:" $computerName
Write-Host "Existing Win 10 ESU Activation Key:" $win10ESUYear1ActKey
Write-Host "Existing Win 10 ESU Expiration Date:" $dateOnly
Write-Host "Existing Win 10 ESU Active?:" $win10ESUAct
  
# Proceed if org and location match

if (($ScriptOrgName -eq $ninjaOrgName) -and ($scriptLocName -eq $ninjaLocName) -and ($win10ESUAct -ne 1)) {

  Write-Host "Organization and location validated. Script can proceed."

  Start-Transcript -Path $LogPath

  # Define hash table mapping computer name to Win 10 ESU activation key 
  
  $Win10ESUActivationKeyMap = @{
    "<insert computer name 1>" = "<insert MAK multiple activation key>"
    "<insert computer name 2>" = "<insert MAK multiple activation key>"
    "<insert computer name 3>" = "<insert MAK multiple activation key>"
  }
  
  # Check existing computer name for win 11 pro product activation key match.
  
  if ($Win10ESUActivationKeyMap.ContainsKey($computerName)) {
       $scriptWin10ESUActivationKey = $Win10ESUActivationKeyMap[$computerName]
       $ESUKeyMatch = $true
       Write-Host "Win 10 ESU Activation Key found for $computerName"
       Write-Host "Win 10 ESU Activation Key: $scriptWin10ESUActivationKey"
   } else {
     Write-Host "Match for existing computer name $computername not found"
  }
  
  # If ESU activation key match found, only upgrade if Windows 10 21H2
  
  if ($ESUKeyMatch) {
    
    # Function to check for Windows 10 22H2
    function Check-Windows1022H2 {
      # Get the Windows version and edition information
      $osBuild = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber
      $windowsEdition = (Get-ComputerInfo).WindowsEditionId
      $win10ESUEligible = $false
      
      # Check if Windows version is 22000 or higher (Windows 11)
      $isWindows11 = [int]$osBuild -ge 22000
      
      # Check if Windows version is equal to 19045 (Windows 10 22H2)
      $isWindows1022H2 = [int]$osBuild -eq 19045
  
      # Evaluate and return results
      if ($isWindows1022H2) {
        Write-Host "The computer is running Windows 10 $windowsEdition 22H2 edition which is eligible for ESU."
        $win10ESUEligible = $true
      } elseif ($isWindows11) {
        Write-Host "The computer is running Windows 11 $windowsEdition edition which is not eligible for ESU."
      } else {
        Write-Host "The computer is running an OS prior to Winodws 10 22H2 and is not eligible for ESU."
        }
      return $win10ESUEligible
    }
  
    # Call above function to check Windows version
    $win10ESUEligible = Check-Windows1022H2
    
    Write-Host "Is ESU eligible?: $win10ESUEligible."
  
    # Install and activate ESU on eligible computer
  
    if ($win10ESUEligible) {
      
      try {
        # Install ESU
        slmgr /ipk $scriptWin10ESUActivationKey
        Write-Host "Windows 10 ESU has been installed."
        Ninja-Property-Set win10EsuYear1ActivationKey $scriptWin10ESUActivationKey
      } catch {
        Write-Host "Failed to install Windows 10 ESU. Error: $_"
      }
      
      try {
        # Activate ESU
        # Year 1 ESU Activation Key = f520e45e-7413-4a34-a497-d2765967d094
        # Year 2 ESU Activation Key = 1043add5-23b1-4afb-9a0f-64343c8f3f8d
        # Year 3 ESU Activation Key = 83d49986-add3-41d7-ba33-87c7bfb5c0fb
        slmgr / ato f520e45e-7413-4a34-a497-d2765967d094
        Write-Host "Windows 10 ESU has been activated."
        Ninja-Property-Set win10EsuActive 1
        # Using epoch timestamp - 1791907200 converts to 10/13/2026 16:00 GMT
        Ninja-Property-Set win10EsuExpirationDate 1791907200
      } catch {
        Write-Host "Failed to activate Windows 10 ESU. Error: $_"
      }   
      
    } else {
      # Upgrade not needed
      Write-Host "Computer is not eligible for Windows 10 ESU. No action taken."
    }
  
  Stop-Transcript
  
  }

} else {
  Write-Host "Windows 10 ESU already active or device organization & location does not match script."
  Write-Host "Script blocked from running."
}
