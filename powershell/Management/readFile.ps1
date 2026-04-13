Function Read-File{
    Get-Content -Path ".\file-name" -Raw
}

Function Open-File{
    Start-Process ".\file-name"
}

Function Read-MultFile{
    $path = "C:\Users\$Env:LOCALMACHINENAME\Documents"
    $data = @()
    get-childitem -Path $path -File | foreach-object{
        $files = $_.FullName
        $month = Get-Date -Format "MM"
        $regex = $files -match "$month-..-.."
        if($regex -eq $true){
            $files = get-content -Path $_.FullName -Raw | ConvertFrom-Json
            $data+=$files 
        }
    }
}