$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
try {
    [psobject]@(
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(15, ", 'Marcos Alejandro'", ", 'De Vargas Etiene',", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
        },
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(19, ", 'Isaac Maria'", ", 'Encarnacion Rodriguez', ", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
        }
    ) | ForEach-Object{
        $sql = "INSERT INTO USERS ($($_.COLUMNS)) VALUES ($($_.VALUES))"
        $connection.CurrentDb().Execute($sql)
    }
}
catch {
    Throw $_
}
finally{
    if ($connection){
        Stop-Process -Name "MSACCESS"
    }
}