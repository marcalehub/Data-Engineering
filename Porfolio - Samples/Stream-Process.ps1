$capturedData = @()
do {
    $process = (Get-Process |
        Select-Object CPU |
            Measure-Object CPU -Sum).Sum
    $dataSet = @{
        CPU = $process
        DATETIME = get-date
    }
    $capturedData+=$dataSet
    Write-Host "CPU: $($dataSet.CPU) - DATETIME: $($dataSet.DATETIME)"
    Start-Sleep -Seconds 5
} while (
    $true
)