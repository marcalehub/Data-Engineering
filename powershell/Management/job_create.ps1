start-job {
    ForEach-Object{1..10} {
        Write-Host $_  (Get-Date)
        Start-Sleep -Seconds 1
    }
} | Wait-Job | Receive-Job