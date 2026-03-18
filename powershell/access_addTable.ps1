$database = "C:\Users\$($Env:USERNAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object System.Data.OleDb.OleDbConnection("Provider = Microsoft.ACE.OLEDB.12.0; Data Source = $database")
$query = @"
CREATE TABLE USERS (
    USER_ID NUMBER,
    USER_NAME TEXT (100),
    USER_LAST_NAME TEXT (100),
    ENTRY_DATE DATETIME,
    CONSTRAINT PK_USERS PRIMARY KEY (USER_ID)
)
"@
$connection.Open()
$transaction = $connection.BeginTransaction()
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.Transaction = $transaction
try {
    $command.ExecuteNonQuery()
    $transaction.Commit()
}
catch {
    $transaction.Rollback()
    Throw $_
}
finally{
    if ($connection.State -eq 'Open'){
        $connection.Close()
    }
}