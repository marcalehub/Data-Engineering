$userPath = $Env:USERPROFILE
$download = Join-Path -Path $userPath -ChildPath "Downloads"
$database = Join-Path -Path $userPath -ChildPath "OneDrive\Documents\Data Engineering\access\ONE_IMPORTACIONES.accdb"
$connection = New-Object -ComObject Access.Application
$connection.Visible = $false
try {
    $connection.OpenCurrentDatabase($database)
}
catch {
    $connection.NewCurrentDatabase($database)
}
$currentDb = $connection.CurrentDb()
$request = Invoke-WebRequest -Uri "https://www.one.gob.do/datos-y-estadisticas/" -UseBasicParsing -ErrorAction Stop
if ($request.StatusCode -eq 200){
    $href = $request.Links | ForEach-Object {
        [PSCustomObject]@{
            Href = $_.href
        }
    }
    ForEach ($years in @(2025, 2024)){
        try {
            $tableName = "ONE_IMP_$($years)"
            $output = Join-Path -Path $download -ChildPath "IMP_$($years)_WEB.xlsx"
            if (-Not (Test-Path -Path $output)){
                Write-Host "Downloading file for year $($years)..."
                $url = $href | Where-Object { $_.Href -match "IMP_$($years)_WEB.xlsx" }
                if (-Not $($url.Href)) {
                    Write-Host "No URL found for year $($years). Skipping download."
                    continue
                }
                Invoke-WebRequest -Uri $($url.Href) -OutFile $output -UseBasicParsing
                try {
                    $currentDb.TableDefs.Delete($tableName)
                }
                catch {
                    ;
                }
                $connection.DoCmd.TransferSpreadsheet(0, 10, $tableName, $output, $true)
                Remove-Item -Path $output -Force
                Write-Host "Imported file for $years."
            }
        }
        catch {
            Throw $_
        }
    }
    if ($connection){
        $currentDb.Close()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($currentDb) | Out-Null
        $connection.CloseCurrentDatabase()
        $connection.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($connection) | Out-Null
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }

} else {
    Write-Host "Failed to access the website. Status code: $($request.StatusCode)"
}