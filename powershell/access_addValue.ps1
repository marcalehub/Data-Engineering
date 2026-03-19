$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object System.Data.OleDb.OleDbConnection("Provider = Microsoft.ACE.OLEDB.12.0; Data Source = $database")
$query = @"
INSERT INTO USERS (USER_ID, USER_NAME, USER_LAST_NAME, ENTRY_DATE)
VALUES(?, ?, ?, ?)
"@
$connection.Open()
$transaction = $connection.BeginTransaction()
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.Transaction = $transaction
$today = Get-Date -Format "MM/dd/yyyy HHHH:mm:ss"
try {
    [psobject]@(
        @{
            INSERT_INTO = 
                @{
                    NAME = 'USER_ID'
                    VALUE = 10
                },
                @{
                    NAME = 'USER_NAME'
                    VALUE = 'Marcos Alejandro'
                },
                @{
                    NAME ='USER_LAST_NAME'
                    VALUE = 'De Vargas Etiene'
                },
                @{
                    NAME ='ENTRY_DATE'
                    VALUE = [datetime]$today
                }
        },
        @{
            INSERT_INTO = 
                @{
                    NAME = 'USER_ID'
                    VALUE = 9
                },
                @{
                    NAME = 'USER_NAME'
                    VALUE = 'Isaac Maria'
                },
                @{
                    NAME ='USER_LAST_NAME'
                    VALUE = 'Encarnacion Rodriguez'
                },
                @{
                    NAME ='ENTRY_DATE'
                    VALUE = [datetime]$today
                }
        }
    ) | ForEach-Object{
        $start = 0
        $records = [int]($_.INSERT_INTO).Length
        $_.INSERT_INTO | ForEach-Object{
            $start++
            $command.Parameters.AddWithValue("@$($_.NAME)", $_.VALUE)
            if ($records -eq $start){
                $command.ExecuteNonQuery()
                $command.Parameters.Clear()
                $start = 0
            }
        }
    }
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