# PowerShell Automation Scripts

This repository contains PowerShell scripts created by Mike, focused on automation and systems administration tasks.

## 📂 Scripts

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

### 🔹 Generate Ninja Org and Location GUIDs
**File:** `generate ninja org and location guids if empty and update existing to all caps if needed.ps1`  
**Description:**  
Uses the NinjaOne API to:
- Generate organization and location GUIDs if they are missing  
- Standardize existing GUIDs to uppercase  
- Update global custom fields accordingly  

---

### 🔹 M365 Group Export (Including Empty Groups)
**File:** `m365 group export include groups with no members.ps1`  
**Description:**  
Exports Microsoft 365 group data to CSV, including:
- Groups with no members  
- Includes unified groups, security groups (non mail-enabled), and security & distribution groups (mail-enabled)  
- Useful for auditing and reporting purposes  

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

## 🛠️ Technologies Used
- PowerShell  
- REST APIs  
- Microsoft 365  
- NinjaOne  

---

## 📌 Purpose
These scripts demonstrate practical automation skills for managing cloud environments and IT systems.
