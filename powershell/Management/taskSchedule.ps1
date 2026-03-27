Function global:Add-Pipeline{
    @(
        @{
            name = "TASK_NAME"
            program = "powershell"
            execute = "powershell.exe"
            file = """PATH"""
            schedule = @([System.DayOfWeek]::Monday, [System.DayOfWeek]::Tuesday, [System.DayOfWeek]::Wednesday, [System.DayOfWeek]::Thursday, [System.DayOfWeek]::Friday)
            time = '8:00am' 
            description = "TASK_NAME Production Datasets"
        }
    ) | foreach-object{
        $path = Get-Location
        if(Get-ScheduledTask "$($_.name)" -ErrorAction Ignore)
            {
                Export-ScheduledTask -TaskName $($_.name) -TaskPath "\" | Out-File "PATH\$($_.name).xml"
            } else {
                write-warning "Creating Pipeline on your machine"
                if ($_.execute -match 'powershell'){
                    $path =  "-ExecutionPolicy RemoteSigned -File $($_.file)"
                    $action = New-ScheduledTaskAction -execute $_.execute -argument $path
                }else{
                    $path = $_.file
                    $action = New-ScheduledTaskAction -execute $_.execute -argument $path
                }
                $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $_.schedule -At $_.time
                $condition = New-ScheduledTaskSettingsSet -allowstartifonbatteries -dontstopifgoingonbatteries
                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $_.name -Description $_.description -Settings $condition
                $msg = "Pipeline $($_.name) created successfully"
            }
            write-host $msg
    }
}