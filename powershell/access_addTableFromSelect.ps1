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
    try {
        $currentDb.QueryDefs.Delete("USERS_TEMP")
    }
    catch {
        Throw $_
    }
    $currentDb.CreateQueryDef("USERS_TEMP", $query)
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