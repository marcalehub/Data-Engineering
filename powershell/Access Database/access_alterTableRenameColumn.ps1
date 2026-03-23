$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\USERS_DETAIL.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
$columnName = "LAST_MODIFIED"
try {
    try {
        $sql = "ALTER TABLE USERS DROP COLUMN $columnName"
        $connection.CurrentDb().Execute($sql)
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    $sql = "ALTER TABLE USERS ADD COLUMN $columnName DATETIME"
    $connection.CurrentDb().Execute($sql)
}
catch {
    Throw $_
}
finally{
    if ($connection){
        $connection.CloseCurrentDatabase()
        $connection.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($connection) | Out-Null
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}