Get-Process | Where-Object {$_.Name -eq 'EXCEL'} | Stop-Process -Force
try {
        $excel = new-object -comobject excel.application
        $excel.visible = $false
        $workbook = $excel.workbooks.open($localpath)
        $workbook.RefreshAll()
        Start-Sleep -seconds 120
        $workbook.save()
        $workbook.close($false)
        taskkill /FI "WINDOWTITLE eq $($name) - Excel"
}
catch {
        taskkill /FI "WINDOWTITLE eq $($name) - Excel"
        Throw $_
}