# Helper to expand a directory object into name/email/type
function Expand-MgMember {
  param($obj)
  $type = $obj.'@odata.type'
  $props = $obj.AdditionalProperties
  [pscustomobject]@{
    MemberType   = $type
    Member       = $props.displayName
    EmailAddress = $props.mail
    UPN          = $props.userPrincipalName
    ObjectId     = $props.id
  }
}

$all = @()

# 2a) Unified groups
$unified = Get-MgGroup -All -Filter "groupTypes/any(c:c eq 'Unified')"

foreach ($g in $unified) {
  # Fast path: many Teams-connected groups include "Team" in ResourceProvisioningOptions
  $teamsConnected = $false
  if ($g.ResourceProvisioningOptions -contains 'Team') {
    $teamsConnected = $true
  }
  else {
    # Fallback: query the team resource; 200 => it's Teams-connected, 404 => not
    try {
      Get-MgGroupTeam -GroupId $g.Id -ErrorAction Stop | Out-Null
      $teamsConnected = $true
    } catch {
      $teamsConnected = $null
    }
  }

  $members = Get-MgGroupMember -GroupId $g.Id -All
  # NEW: record groups with no members
  if (-not $members) {
    $all += [pscustomobject]@{
      Group           = $g.DisplayName
      GroupType       = 'Microsoft 365 (Unified)'
      TeamsConnected  = $teamsConnected
      GroupEmail      = $g.Mail
      Member          = 'No Members'
      EmailAddress    = $null
    }
    continue
  }
  foreach ($m in $members) {
    $expanded = Expand-MgMember $m
    $all += [pscustomobject]@{
      Group          = $g.DisplayName
      GroupType      = 'Microsoft 365 (Unified)'
      TeamsConnected = $teamsConnected
      GroupEmail     = $g.Mail
      Member         = $expanded.Member
      EmailAddress   = $expanded.EmailAddress
    }
  }
}

# 2b) Security groups (non-mail-enabled)
$sec = Get-MgGroup -All -Filter "securityEnabled eq true and mailEnabled eq false"
foreach ($g in $sec) {
  $members = Get-MgGroupMember -GroupId $g.Id -All
  # NEW: record groups with no members
  if (-not $members) {
    $all += [pscustomobject]@{
      Group         = $g.DisplayName
      GroupType     = 'Security'
      TeamsConnected  = $null
      GroupEmail    = $g.Mail
      Member        = 'No Members'
      EmailAddress  = $null
    }
    continue
  }
  foreach ($m in $members) {
    $exp = Expand-MgMember $m
    $all += [pscustomobject]@{
      Group         = $g.DisplayName
      GroupType     = 'Security'
      TeamsConnected  = $null
      GroupEmail    = $g.Mail
      Member        = $exp.Member
      EmailAddress  = $exp.EmailAddress
    }
  }
}

# 2c) Mail-enabled security & distribution groups
$mailGroups = Get-MgGroup -All -Filter "mailEnabled eq true and securityEnabled eq true or mailEnabled eq true and securityEnabled eq false"
foreach ($g in $mailGroups | Where-Object { $_.GroupTypes -notcontains 'Unified' }) {
  $members = Get-MgGroupMember -GroupId $g.Id -All
  $gType = if ($g.SecurityEnabled) { 'Mail-Enabled Security' } else { 'Distribution' }
  # NEW: record groups with no members
  if (-not $members) {
    $all += [pscustomobject]@{
      Group         = $g.DisplayName
      GroupType     = $gType
      TeamsConnected  = $null
      GroupEmail    = $g.Mail
      Member        = 'No Members'
      EmailAddress  = $null
    }
    continue
  }
  foreach ($m in $members) {
    $exp = Expand-MgMember $m
    $all += [pscustomobject]@{
      Group         = $g.DisplayName
      GroupType     = $gType
      TeamsConnected  = $null
      GroupEmail    = $g.Mail
       Member        = $exp.Member
      EmailAddress  = $exp.EmailAddress
    }
  }
}

$all | Export-Csv "C:\Office365GroupMembers.csv" -NoTypeInformation -Encoding UTF8
