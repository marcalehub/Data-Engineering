$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\USERS_DETAIL.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
$currentDb = $connection.CurrentDb()
$query = @"
    SELECT
        *
    FROM USERS
"@
try{
    $currentDb.OpenRecordset($query)
}
catch {
    Throw $_
}
finally{
    if ($connection){
        $currentDb.Close()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($currentDb) | Out-Null
        $connection.CloseCurrentDatabase()
        $connection.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($connection) | Out-Null
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}