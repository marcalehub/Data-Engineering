$opt = New-ScheduledJobOption -RequireNetwork -RunElevated -WakeToRun
$trigger = New-JobTrigger -Weekly -DaysOfWeek Monday,Thursday -At '3:00PM'
Register-ScheduledJob -Name "JOB_NAME" -FilePath "FILE_PATH.ps1"  -Trigger $trigger -ScheduledJobOption $opt