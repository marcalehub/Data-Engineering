$PATH = Get-Location
$connection = 'snowflake.toml'
$server = 'connection_name'
$SNOWSQL = '.exe'
Start-Job {
    & $using:SNOWSQL `
    --config $using:connection `
    -c $using:server `
    -f "$($using:PATH)\FILE_NAME.sql" `
    -o log_level=INFO
} | Wait-Job