$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
$query = @"
DROP TABLE USERS_TEMP
"@
try {
    $connection.CurrentDb().Execute($query)
}
catch {
    Throw $_
}
finally{
    if ($connection){
        Stop-Process -Name "MSACCESS"
    }
}