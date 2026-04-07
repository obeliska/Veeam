#
# Displays the log messages associated with the start and end times for each 
# job's execution from the relevant Veeam log file. If no log file is specified
# the latest is used.
#

param(
    [string] $log
)

function fail {
	param([string] $msg)
	write-host -ForegroundColor red $msg
	exit 1
}

################################################################################

$jobname = $(hostname)
$progdata = $env:programdata

if ($log -eq "") {
	# Default to latest log.
	$log = "$progdata\Veeam\Endpoint\$jobname\Job.$jobname.Backup.log"
}

if (-not (test-path "$log")) { fail "Unable to find log file $log" }

write-host -ForegroundColor yellow "Log file: $log"
write-host ""
Get-Content $log | Where-Object {
	$_ -like '*Starting job mode:*' -or 
	$_ -like '*Completing storage*' -or 
	$_ -like '*Job session*completed, status:*'
	}
