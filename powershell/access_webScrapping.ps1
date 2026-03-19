$database = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\ONE_IMPORTACIONES.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
$connection.NewCurrentDatabase($database)
ForEach ($years in @(2025, 2024)){
    try {
        $output = "C:\Users\$($Env:LOCALMACHINENAME)\Downloads\IMP_$($years)_WEB.xlsx"
        if (-Not (Test-Path -Path $output)){
            Write-Host "Downloading file for year $($years)..."
            Invoke-WebRequest -Uri "https://www.one.gob.do/catalogo-datos/Comercio/IMPORTACIONES/IMP_$($years)_WEB.xlsx" -OutFile $output -UseBasicParsing
            $connection.DoCmd.TransferSpreadsheet(0, 10, "ONE_IMP_$($years)", $output, $true)
            Write-Host "Imported file for $years."
        }
    }
    catch {
        Throw $_
    }
}
if ($connection){
    $connection.CloseCurrentDatabase()
    $connection.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($connection) | Out-Null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}