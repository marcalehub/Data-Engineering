$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\database.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.OpenCurrentDatabase($database)
ForEach ($years in @(2025, 2024, 2023, 2022, 2021, 2020, 2019)){
    try {
        $output = "C:\Users\$($Env:LOCALMACHINENAME)\Downloads\IMP_$($years)_WEB.xlsx"
        if (-Not (Test-Path -Path $output)){
            Write-Host "Downloading file for year $($years)..."
            Invoke-WebRequest -Uri "https://www.one.gob.do/catalogo-datos/Comercio/IMPORTACIONES/IMP_$($years)_WEB.xlsx" -OutFile $output -UseBasicParsing
            $connection.DoCmd.TransferSpreadsheet(
                0, 10, "ONE_IMP_$($years)",
                $output, $true
            )
            Write-Host "Imported file for $years."
        }
    }
    catch {
        Throw $_
    }
}
finally{
    if ($connection){
        Stop-Process -Name "MSACCESS"
    }
}