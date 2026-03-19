$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
$query = @"
CREATE TABLE USERS (
    USER_ID NUMBER,
    USER_NAME TEXT (100),
    USER_LAST_NAME TEXT (100),
    ENTRY_DATE DATETIME,
    CONSTRAINT PK_USERS PRIMARY KEY (USER_ID)
)
"@
try {
    $connection.CurrentDb().Execute($query)
}
catch {
    Throw $_
}
finally{
    if ($connection){
        $connection.CloseCurrentDatabase()
        $connection.Quit()
    }
}