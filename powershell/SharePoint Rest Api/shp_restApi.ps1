Function Get-FilesShp{
    param(
        [Parameter(Mandatory=$true)]
        [System.Uri]$site,

        [Parameter(Mandatory=$true)]
        [string]$file,
        
        [Parameter(Mandatory=$true)]
        [string]$name,

        [string]$location,
        
        [string]$download,

        [string]$new_name,

        [string]$extension,

        [bool]$rename
    )
    try{
        $last_modified = [datetime](Get-Item -path $file).LastWriteTime.tostring("MM/dd/yyyy")
    }catch{
        $last_modified = $false
    }
    if($last_modified -ne $(Get-Date -Format "MM/dd/yyyy")){
        Connect-PnPOnline -Url $site -UseWebLogin -WarningAction Ignore
        $pnp = get-pnplist -Identity "Documents" -ThrowExceptionIfListNotFound 2>$null
        if($null -ne $pnp){
            if(Test-Path -Path $file){
                Remove-Item -Path $file
            }
            Get-PnPFile -Url $location -Path $download -AsFile -Force
            if ($rename -eq $true){
                Rename-Item -Path "$(Get-Location)\$name.$extension" -NewName "$(Get-Location)\$new_name.$extension"
            }
        }
    }
}

Function Copy-FilesShP{
    param(
        [Parameter(Mandatory=$true)]
        [string]$source,

        [Parameter(Mandatory=$true)]
        [System.Uri]$site,

        [Parameter(Mandatory=$true)]
        [System.Uri]$type,

        [Parameter(Mandatory=$false)]
        [string]$localpath,
        
        [Parameter(Mandatory=$true)]
        [string]$target
    )
    Connect-PnPOnline -Url $site -UseWebLogin -WarningAction Ignore
    $pnp = get-pnplist -Identity "Documents" -ThrowExceptionIfListNotFound 2>$null
    if($null -ne $pnp){
        if ($type -eq "Folder"){
            Get-ChildItem -Path $source -Recurse | ForEach-Object {
                if($($_.Length -le 262144000)) {
                    Add-PnPFile -Path $($_.FullName) -Folder $target
                } else {
                    Copy-Item -Path $($_.FullName) -Destination $localpath -Force
                }
            }
        }
        else{
            Add-PnPFile -Path $source -Folder $target
        }
    }
}