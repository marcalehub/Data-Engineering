$PATH = Get-Location
$SNOWCLI = '.exe'
Start-Job {
    & $using:SNOWCLI sql `
    --filename "$($using:PATH)\FILE_NAME.sql" `
    --silent `
    --format TABLE
} | Wait-Job