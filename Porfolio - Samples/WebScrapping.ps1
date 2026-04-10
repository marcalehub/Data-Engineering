Function WebScrapping {
    param (
        [Parameter(Mandatory=$true)]
        [System.Uri]$url,  

        [Parameter(Mandatory=$true)]
        [String]$path,            

        [Parameter(Mandatory=$true)]
        [String]$name,

        [Parameter(Mandatory=$true)]
        [Regex]$namePattern,

        [Parameter(Mandatory=$true)]
        [string]$replaceName,

        [Parameter(Mandatory=$true)]
        [String]$tables,
        
        [Parameter(Mandatory=$true)]
        [Array]$years,

        [Parameter(Mandatory=$true)]
        [String]$sample,

        [Parameter(Mandatory=$true)]
        [Regex]$samplePattern,
        
        [Parameter(Mandatory=$false)]
        [String]$databaseProvider

    )
    $path = $Env:USERPROFILE
    $download = Join-Path -Path $path -ChildPath "Downloads"
    $fileList = @()
    $trySet = 0

    do {
        $trySet++
        $request = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        try{
            ForEach ($year in $years){
                ${file name} = $sample -replace "$samplePattern", "$year"
                $output = Join-Path -Path $download -ChildPath ${file name}
                $fileList+=@{
                    Table = "$tables$($year)"
                    Path = $output
                }
                $url = $request.Links |
                    Where-Object { $_ -match ${file name} } |
                        ForEach-Object{
                            $_.href
                        }
                if (-Not (Test-Path -Path $output)){
                    Write-Host "Downloading file for year $($year)..."
                    if (-Not $($url)) {
                        Write-Host "No URL found for year $($year). Skipping download."
                        continue
                    }
                    Invoke-WebRequest -Uri $($url) -OutFile $output -UseBasicParsing
                    Write-Host "Imported file for $year."
                }
            }
        } catch {
            Write-Host "Failed to access the website. Status code: $($request.StatusCode)"
            Throw $_
        }
        Start-Sleep -Seconds 60
    } 
    
    until (
        $request.StatusCode -eq 200 -or $trySet -eq 2
    )

    if($databaseProvider -eq 'Access') {
        $database = (Join-Path -Path $path -ChildPath "OneDrive\Documents\Data Engineering\access\$name$(
            $years | ForEach-Object{$_}).accdb"
        ) -replace "$namePattern", "$replaceName"
        
        $connection = New-Object -ComObject Access.Application
        $connection.Visible = $false
        
        try {
            $connection.OpenCurrentDatabase($database)
        }

        catch {
            $connection.NewCurrentDatabase($database)
        }
        $currentDb = $connection.CurrentDb()
        $fileList | ForEach-Object{
            
            try {
                $currentDb.TableDefs.Delete($_.Table)
            }

            catch {
                ;
            }

            $connection.DoCmd.TransferSpreadsheet(0, 10, $_.Table, $_.Path, $true)
            Remove-Item -Path $_.Path -Force
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
    }
}

WebScrapping `
    -url "https://www.one.gob.do/datos-y-estadisticas/"`
    -path $($Env:USERPROFILE)`
    -name "DB_ONE_IMPORTACIONES_"`
    -namePattern "(\d{4}) (\d{4})"`
    -replaceName '$1$2'`
    -tables "TFACT_ONE_IMP_"`
    -years @(2025, 2024)`
    -sample "IMP_2000_WEB.xlsx"`
    -samplePattern "\d{4}"`
    -databaseProvider 'Access'