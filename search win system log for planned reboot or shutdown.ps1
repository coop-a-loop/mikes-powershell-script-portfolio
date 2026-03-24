# Define the log name and event ID for a planned reboot or shutdown
$logName = "System"
$eventID = 1074

# Get the current date at midnight (start of today)
$startOfToday = (Get-Date).Date

# Get reboot/shutdown events from today
$events = Get-WinEvent -LogName $logName | Where-Object {
    $_.Id -eq $eventID -and $_.TimeCreated -ge $startOfToday
}

# Process and display relevant information
if ($events) {
    foreach ($event in $events) {
        $time = $event.TimeCreated
        $message = $event.Message

        # Extract the username from the message
        $userMatch = $message -match "initiated by user\s*:\s*(.+)"
        $user = if ($userMatch) { $matches[1] } else { "Unknown" }

        # Display the event details
        Write-Host "Reboot/Shutdown Event:"
        Write-Host "Time: $time"
        Write-Host "User: $user"
        Write-Host "Details: $message"
        Write-Host "---------------------------------------"
    }
} else {
    Write-Host "No reboot or shutdown events (Event ID 1074) from today found in the logs."
}
