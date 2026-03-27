Function Start-SnowflakeEtl {
    param(
            [Parameter(Mandatory=$true)]
            [string]$stage,

            [Parameter(Mandatory=$true)]
            [string]$location

        )
    $location -Replace "\\", "/"
    $procedure = @(
        @{
            status = "ONLINE"
            procedure = "                CREATE OR REPLACE TEMP STAGE $stage
                COMMENT = 'FILES FROM DIFFERENTS API';

                CREATE TEMP FILE FORMAT IF NOT EXISTS PARQUET_FORMAT
                COMPRESSION = AUTO
                TYPE = 'PARQUET';

                CREATE TEMP FILE FORMAT IF NOT EXISTS JSON_FORMAT
                TYPE = 'JSON'
                COMPRESSION = AUTO
                STRIP_OUTER_ARRAY = TRUE;
            "
        },
        
        @{
            status = "ONLINE"
            procedure = "
                COPY INTO @$stage/FILE_NAME.parquet
                FROM (
                    $(Get-Content -Path "$location\SQL_FILE.sql" -Raw)
                )    
                FILE_FORMAT = (TYPE = PARQUET)
                HEADER = TRUE
                MAX_FILE_SIZE = 900000000
                SINGLE = TRUE;
                GET @$stage/FILE_NAME.parquet file://$PATH/
        "
        }
    ) 
    $command = ""
    $procedure | ForEach-Object {
        if ($null -ne $($_.procedure) -and $_.status -ne "OFFLINE") {
            $command += "$($_.procedure -replace "                ")"
        }
    }
    $embedded = @"
$command
"@
    Set-Content -Path "PATH.sql" -Value $embedded 
}