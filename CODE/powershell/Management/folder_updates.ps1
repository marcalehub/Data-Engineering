Function Start-UpdateSigl{
    param(
        $Source,
        $Folder,
        $Destination
    )
    $updates = Get-ChildItem -Path $Source
    $main = $Folder
    $result = @()
    $Destination | ForEach-Object {
        $destination = "$main\$($_)"
        $file = (Get-ChildItem -Path "$main\$($_)")
        $file | ForEach-Object {
            foreach($update in $updates){
                if($update.Name -eq $_.Name -and $update.LastWriteTime -ne $_.LastWriteTime){
                    Copy-Item -Path "$source\$($update.Name)" -Destination "$destination\$($_)"
                    $result+=[PsCustomObject]@{
                        Status = "Updated"
                        File = "$($_)"
                        Location = "$destination"
                    }
                }eGet-ChildItemeif ($update.Name -eq $_.Name -and $update.LastWriteTime -eq $_.LastWriteTime) {
                    $result+=[PsCustomObject]@{
                        Status = "Up-To-Date"
                        File = "$($_)"
                        Location = "$destination"
                    }
                }
            }
        }
    }
    return $result
}

Function Start-UpdateMult{
    param(
        $Source,
        $Destination
    )
    $updates = @()
    $main = $Destination.folder
    $Destination.subfolder | foreach-object{
        $full_path = "$($main)\$($_)"
        Get-ChildItem -Path "$($main)\$($_)" | Where-Object {$_.Name -match "-" } | ForEach-Object{
            $full_Subpath = "$($full_path)\$($_.Name)" 
            Get-ChildItem -Path "$($full_path)\$($_.Name)" | foreach-object{
                $updates+=[PsCustomObject]@{
                    update_file = $_.Name
                    update_LastWriteTime = $_.LastWriteTime
                    update_location = $full_Subpath
                }
            }
        }
    }
    $source_updates = @()
    Get-ChildItem -Path $Source | Where-Object {$_.Name -match "-" } | ForEach-Object{
        $full_main_path = "$Source\$($_.Name)"
        Get-ChildItem -Path "$Source\$($_.Name)" | ForEach-Object{
            $source_updates+=[PsCustomObject]@{
                source_file = $_.Name
                source_LastWriteTime = $_.LastWriteTime
                source_location = $full_main_path
            }
        }
    }
    $comparison = Join-Object -Left $updates -Right $source_updates -LeftJoinProperty update_file -RightJoinProperty source_file -Type AllInLeft
    $comparison | foreach-object {$_ |  Add-Member -MemberType NoteProperty -Name UpToDate -Value ($_."update_LastWriteTime" -eq $_."source_LastWriteTime") -Force} 
    $comparison | Where-Object {$_.UpToDate -eq $False}| foreach-object{
        $_.update_file
        Copy-Item -Path "$source_location\$($_.update_file)" -Destination "$update_location\$($_.update_file)"
    }
    $result = $comparison | Select-Object "update_file", "update_LastWriteTime", "update_location", "UpToDate"
    return $result
} 
$Destination = @(
    @{
        folder = "Destination General Folder"
        subfolder = @("SubFolder to update")
    }
)
