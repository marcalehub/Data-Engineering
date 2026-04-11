$access = New-Object -ComObject Access.Application
$source = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\USERS_DETAIL.accdb"
$temp   = "C:\Users\$($Env:LOCALMACHINENAME)\OneDrive\Documents\Data Engineering\access\USERS_DETAIL_TEMP.accdb"
try {
    $stream = [System.IO.File]::Open($source, 'Open', 'ReadWrite', 'None')
    $stream.Close()
} catch {
    Write-Host "Database is open or locked. Close Access first."
    exit
}
$access.CompactRepair($source, $temp, $true)
Remove-Item $source
Rename-Item $temp $source
$access.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null