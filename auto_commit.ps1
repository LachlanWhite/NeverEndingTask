<#
Appends a timestamped entry to activity.log and commits it.
Intended to be run on a schedule (Windows Task Scheduler) via run_task.bat.
Local-only by default: this script never pushes to a remote.
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

# To also push to a remote, uncomment the line below once a remote is configured:
# git push
