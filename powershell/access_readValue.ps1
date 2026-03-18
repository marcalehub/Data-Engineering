
$database = "C:\Users\$($Env:USERNAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object System.Data.OleDb.OleDbConnection("Provider = Microsoft.ACE.OLEDB.12.0; Data Source = $database")
$query = "
    SELECT
        *
    FROM USERS
"
$command = New-Object System.Data.OleDb.OleDbCommand($query, $connection)
$adapter = New-Object System.Data.OleDb.OleDbDataAdapter($command)
$dataframe = New-Object System.Data.DataSet($adapter)
try{
    $connection.Open()
    [void]$adapter.Fill($dataframe)
    $dataframe.Tables[0] | Format-Table
}
catch {
    Throw $_
}
finally{
    if ($connection.State -eq 'Open'){
        $connection.Close()
    }
}