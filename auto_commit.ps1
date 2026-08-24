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
