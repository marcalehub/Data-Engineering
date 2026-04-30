$counting = start-job {
    ForEach-Object{1..10} {
        Write-Host $_  (Get-Date)
        Start-Sleep -Seconds 1
    }
}

$condition = start-job {
    $i = 0
    while($true) {
        Write-Host "Condition: $i" (Get-Date)
        Start-Sleep -Seconds 1
        if ($i -eq 10) {
            break
        }
        $i++
    }
}

Wait-Job -Id $counting.Id, $condition.Id
Receive-Job -Id $counting.Id, $condition.Id