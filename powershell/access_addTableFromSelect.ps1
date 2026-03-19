$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object System.Data.OleDb.OleDbConnection("Provider = Microsoft.ACE.OLEDB.12.0; Data Source = $database")
$query = @"
CREATE VIEW USERS_TEMP AS
    SELECT
        *
    FROM USERS
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