$endScript = 10
start-job {
    ForEach-Object{1..$using:endScript} {
        Write-Host $_  (Get-Date)
        Start-Sleep -Seconds 1
    }
} | Wait-Job | Receive-Job