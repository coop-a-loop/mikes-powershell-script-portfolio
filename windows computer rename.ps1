# Enable TLS1.2 and TLS1.3
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType] 'Tls12'

$RMM = 1
$ScriptURL = $env:scripturl
$RMMScriptPath = $env:PROGRAMDATA + "\NinjaRMMAgent\scripting"
$Description = "Running from RMM. Change computer name to new standard."

Write-Host "Script URL: " $ScriptURL
Write-Host "RMM Script Path: " $RMMScriptPath
Write-Host "Description: " $Description

# Script specific varaibles
$CurrentComputerName = $env:COMPUTERNAME
$RenameNeeded = $false

Write-Host "Current Computer Name: " $CurrentComputerName

# Define hash table mapping old to new computer name

$ComputerRenameMap = @{
  "OLD_NAME" = "NEW_NAME"
  "OLD_NAME1" = "NEW_NAME1"
  "OLD_NAME2" = "NEW_NAME2"
}

# Check existing computer name for match. Only call rename script if match found.

if ($ComputerRenameMap.ContainsKey($CurrentComputerName)) {
     $NewComputerName = $ComputerRenameMap[$CurrentComputerName]
     $RenameNeeded = $true
} else {
   Write-Host "Match for existing computer name not found"
}

Write-Host "Expected new computer name based on If Statement: " $NewComputerName

$ScriptLogName = "msft-windows-rename-compuer.log"

$LogPath = "$ENV:WINDIR\logs\$ScriptLogName"

# Start the script logic here. This is the part that actually gets done what you need done.

Start-Transcript -Path $LogPath

Write-Host "Description: $Description"
Write-Host "Log path: $LogPath"
Write-Host "RMM: $RMM `n"

# Rename computer if needed

If ($RenameNeeded) {
   # Rename the computer
   try {
       Rename-Computer -NewName $NewComputerName -Force
       Write-Host "Computer name has been changed to $NewComputerName and will take effect on next reboot"
   } catch {
       Write-Host "Failed to rename the computer. Error: $_"
   }
} else {
  # Rename not needed
  Write-Host "Computer rename not needed. No action taken."
}

Stop-Transcript
