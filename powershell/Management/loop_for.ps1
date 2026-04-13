ForEach-Object{1..10} {
    Write-Host $_  (Get-Date)
    Start-Sleep -Seconds 1
}

For ($i=1; $i -le 10; $i++) {
    Write-Host $i (Get-Date)
    Start-Sleep -Seconds 1
}

ForEach ($i in 1..10) {
    Write-Host $i (Get-Date)
    Start-Sleep -Seconds 1
}

$ 1..10