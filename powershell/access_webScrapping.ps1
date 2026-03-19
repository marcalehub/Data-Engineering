$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$database")
$connection.Open()
ForEach ($years in @(2024, 2023, 2022, 2021, 2020, 2019)){
    $url = "https://www.one.gob.do/catalogo-datos/Comercio/IMPORTACIONES/IMP_$($years)_WEB.xlsx"
    $output = "C:\Users\$($Env:LOCALMACHINENAME)\Downloads\IMP_$($years)_WEB.xlsx"
    try {
        if (-Not (Test-Path -Path $output)){
            Write-Host "Downloading file for year $($years)..."
            Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
            $file = Import-Excel $output -WorksheetName "IMP_$($years)_WEB"
            if ($file.Count -eq 0) {
                Write-Warning "Excel file is empty. No data imported."
                continue
            }
            # --- CREATE TABLE ---
            $columns = $file[0].PSObject.Properties.Name
            $colDefs = ($columns | ForEach-Object { "[$_] TEXT" }) -join ", "
            $query = "CREATE TABLE ONE_IMP_$($years) ($colDefs)"
            $command = $connection.CreateCommand()
            $command.CommandText = $query
            try {
                $command.ExecuteNonQuery()
            }
            catch {
                Write-Host "Table exists, skipping."
            }
            # --- INSERT ROWS ---
            foreach ($row in $file) {
                $colNames = ($columns | ForEach-Object { "[$_]" }) -join ", "
                $values = ($columns | ForEach-Object { "'" + ($row.$_ -replace "'", "''") + "'" }) -join ", "
                $insertSql = "INSERT INTO ONE_IMP_$($years) ($colNames) VALUES ($values)"
                $insertcommand = $connection.CreateCommand()
                $insertcommand.CommandText = $insertSql
                $insertcommand.ExecuteNonQuery() | Out-Null
            }
            Write-Host "Imported $($file.Count) rows for $years."
        }
    }
    catch {
        Throw $_
    }
}
if ($connection.State -eq 'Open'){
    $connection.Close()
}