$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
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
        Stop-Process -Name "MSACCESS"
    }
}