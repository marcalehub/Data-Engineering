begin {
    Add-Type -AssemblyName PresentationFrameWork
    $window = New-Object System.Windows.Window
    $table = New-Object System.Windows.Controls.DataGrid
    $data = Get-Process | `
        Select-Object Id , Name, ProcessName, CPU
    $cpuUsage = [decimal]($data | Measure-Object CPU -Sum).Sum
    $data | ForEach-Object{
        if($_.CPU -gt 0){
            $percent = ($_.CPU / $cpuUsage) * 100
            $_ | Add-Member -NotePropertyName 'CPU %' -NotePropertyValue ("{0:N4}" -f $percent)
        }
        else{
            $_ | Add-Member -NotePropertyName 'CPU %' -NotePropertyValue ("{0:N4}" -f 0)
        }
    }
    $data = $data | Sort-Object 'CPU %' -Descending
}

process {
    $window.Title = 'Desktop Application'
    $window.ResizeMode = 'CanResize'
    $window.WindowStartupLocation = 'CenterScreen'
    $table.ItemsSource = $data
    $window.AddChild($table)
}

end {
    $window.ShowDialog() | Out-Null
}