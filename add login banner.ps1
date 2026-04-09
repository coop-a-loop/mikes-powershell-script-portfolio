# Enable TLS1.2 and TLS1.3
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType] 'Tls12'

$RMM = 1
$ScriptURL = $env:scripturl
$RMMScriptPath = $env:PROGRAMDATA + "\NinjaRMMAgent\scripting"
$Description = $env:description

Write-Host "Script URL: " $ScriptURL
Write-Host "RMM Script Path: " $RMMScriptPath
Write-Host "Description: " Running from RMM. Add login banner using specified value.

# Script specific varaibles
$bannerTitle = "WARNING: PRIVATE PROPERTY"
$bannerText = @"
This system is the private property of <enter company name>. Access to this system is restricted to company employees and other individuals expressly authorized by <enter company name>. Any individual using this system, by such use, acknowledges and expressly consents to the right of <enter company name> to monitor, access, record, audit, use and disclose any information generated, received, or stored on the system, and waives any right or expectation of privacy on the part of that individual in connection with his or her use of this system. Unauthorized, improper or criminal access to, use or modification of this system, as delineated by corporate policy and the law, is prohibited and may be a violation of state and federal, civil and criminal law. We reserve the right to take any and all action under company policy and the law to prevent such unauthorized, improper or criminal use, up to and including termination of employment, notification to law enforcement, and legal action which may result in both civil and criminal penalties. If you are not authorized to use this system, log off immediately.
"@

# Invoke the script via http
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString($ScriptURL))

$ScriptLogName = "msft-windows-add-login-banner.log"
$LogPath = "$ENV:WINDIR\logs\$ScriptLogName"

# Start the script logic here. This is the part that actually gets done what you need done.

Start-Transcript -Path $LogPath

Write-Host "Description: $Description"
Write-Host "Log path: $LogPath"
Write-Host "RMM: $RMM"

# Registry paths for login banner settings
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Set the "LegalNoticeCaption" (title) in the registry
Set-ItemProperty -Path $regPath -Name "LegalNoticeCaption" -Value $bannerTitle -Force

# Set the "LegalNoticeText" (message) in the registry
Set-ItemProperty -Path $regPath -Name "LegalNoticeText" -Value $bannerText -Force

# Confirm the changes
Write-Host "Login banner set successfully."

Stop-Transcript
