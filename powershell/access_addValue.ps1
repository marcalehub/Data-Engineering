$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\USERS_DETAIL.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
try {
    [psobject]@(
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(0, ", 'Marcos Alejandro'", ", 'De Vargas Etiene',", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
        },
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(1, ", 'Isaac Maria'", ", 'Encarnacion Rodriguez', ", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
        },
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(2, ", 'Noemi'", ", 'De Vargas', ", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
        },
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(3, ", 'Anudis'", ", 'Reyes', ", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
        },
        @{
            COLUMNS = 'USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE'
            VALUES = @(4, ", 'Atahualpa'", ", 'De Vargas', ", "Format(Now(), 'yyyy-mm-dd hh:nn:ss') ")
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
        $connection.CloseCurrentDatabase()
        $connection.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($connection) | Out-Null
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}