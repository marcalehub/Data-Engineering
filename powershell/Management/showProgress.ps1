1..50 | ForEach-Object{
    Write-Progress `
        -Activity "Processing Files" `
        -Status "Processing Files $($_) out of 50" `
        -PercentComplete $_
    Start-Sleep -Second 1
}