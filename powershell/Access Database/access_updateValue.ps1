$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\USERS_DETAIL.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
try {
    $sql = "UPDATE USERS SET USER_NAME = 'Noemi', LAST_MODIFIED = Format(Now(), 'yyyy-mm-dd hh:nn:ss') WHERE USER_ID = 2"
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