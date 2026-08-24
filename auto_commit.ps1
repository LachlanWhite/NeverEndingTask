<#
Appends a timestamped entry to activity.log, commits it, and pushes to origin.
Intended to be run on a schedule (Windows Task Scheduler).
#>

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$notes = @(
    "routine check-in",
    "housekeeping pass",
    "log rotation",
    "status update",
    "periodic sync",
    "maintenance touch",
    "scheduled update",
    "checkpoint"
)
$note = $notes | Get-Random

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path "activity.log" -Value "$timestamp - $note"

git add activity.log
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Output "Nothing to commit."
    exit 0
}

git commit -m "$note ($timestamp)" | Out-Null
Write-Output "Committed: $note ($timestamp)"

git push

# Reschedule the next run at a random point 1-3 days out, between 08:00 and 21:59,
# so the cadence and time of day both vary instead of firing on a fixed clock.
$dayOffset = Get-Random -Minimum 1 -Maximum 4
$hour = Get-Random -Minimum 8 -Maximum 22
$minute = Get-Random -Minimum 0 -Maximum 60
$nextRun = (Get-Date).Date.AddDays($dayOffset).AddHours($hour).AddMinutes($minute)

$trigger = New-ScheduledTaskTrigger -Once -At $nextRun
Set-ScheduledTask -TaskName "AutoGitPusher" -Trigger $trigger | Out-Null
Write-Output "Next run scheduled for $nextRun"
