#
# Tails the Veeam backup job log to aid monitoring when a backup is running.
#

$jobname = $(hostname)
$progdata = $env:programdata
$log="$progdata\Veeam\Endpoint\$jobname\Job.$jobname.Backup.log"

write-host -ForegroundColor yellow "Log file: $log"
write-host ""
Get-Content $log -Tail 20 -Wait
