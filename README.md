# PowerShell Automation Scripts

This repository contains PowerShell scripts created by Mike, focused on automation and systems administration tasks.

## 📂 Scripts

---

### 🔹 Configure Windows Login Banner
**File:** `add login banner.ps1`  
**Description:**  
Configures a Windows login banner via registry settings, typically deployed through an RMM tool:
- Sets `LegalNoticeCaption` (banner title) and `LegalNoticeText` (login message)  
- Uses a customizable warning message for security and compliance purposes  
- Enables TLS 1.2 for secure communications  
- Leverages environment variables for script context (e.g., script URL, description)  
- Logs execution details to a transcript file in the Windows logs directory  
- Ensures users see a legal notice prior to system logon  

---

### 🔹 Analyze C Drive Usage
**File:** `analyze c drive usage.ps1`  
**Description:**  
Analyzes disk usage on the C:\ drive to identify space consumption:
- Displays total drive space (used, free, and total)  
- Lists top folders by size (configurable depth, default 4 levels)  
- Identifies largest individual files with size and last modified date  
- Includes Volume Shadow Copy storage details  
- Helps pinpoint disk space issues for cleanup and optimization  

---

### 🔹 Generate NinjaOne Org and Location GUIDs (Global Custom Fields)
**File:** `generate ninjaone org and location guids if empty and update existing to all caps if needed.ps1`  
**Description:**  
Uses the NinjaOne API to:
- Generate organization and location GUIDs if they are missing  
- Standardize existing GUIDs to uppercase  
- Updates NinjaOne global custom fields accordingly  

---

### 🔹 M365 Group Export (Including Empty Groups)
**File:** `m365 group export include groups with no members.ps1`  
**Description:**  
Export all Microsoft 365 security and distribution group memberships—including empty groups—to a CSV for auditing and reporting:
- Retrieves all Microsoft 365, security, and distribution groups
- Detects if Unified groups are Teams-connected
- Expands member info: name, email, UPN, ID, and type
- Includes groups with no members (No Members)
- Exports all data to Office365GroupMembers.csv

---

### 🔹 Search Windows System Log for Planned Reboots/Shutdowns
**File:** `search win system log for planned reboot or shutdown.ps1`  
**Description:**  
Searches the Windows System Event Log to identify planned reboots and shutdowns:
- Filters events for the current day  
- Checks for Event ID 1074 (planned restart/shutdown)  
- Helps track intentional system restarts and shutdown activity  
- Useful for troubleshooting and audit purposes  

---

### 🔹 Windows Computer Rename
**File:** `windows computer rename.ps1`  
**Description:**  
Renames a Windows computer based on a predefined mapping of current names to standardized naming conventions:
- Checks the current computer name against a defined rename map  
- Renames the system if a match is found  
- Uses `Rename-Computer` and logs the operation for auditing  
- Runs safely with error handling and transcript logging  
- Designed to operate in an RMM environment (e.g., NinjaRMM scripting path)  
- Supports TLS 1.2 for secure remote script execution scenarios  

---

### 🔹 Upgrade Windows 11 Home to Pro
**File:** `win 11 home to pro upgrade.ps1`  
**Description:**  
Automates upgrading Windows 11 Home devices to Pro using device-specific product keys via RMM:
- Maps computer names to assigned Windows 11 Pro product keys  
- Validates if the device is running Windows 11 Home/Core before upgrading  
- Skips upgrade if already on Pro or not running Windows 11  
- Executes upgrade using `changepk.exe` with the appropriate product key  
- Uses environment variables for context (e.g., computer name, script source)  
- Logs execution details to a transcript file in the Windows logs directory  
- Designed for controlled, per-device license assignment and upgrade automation  

---

## 🛠️ Technologies Used
- PowerShell  
- REST APIs  
- Microsoft 365  
- NinjaOne  

---

## 📌 Purpose
These scripts demonstrate practical automation skills for managing cloud environments and IT systems.
