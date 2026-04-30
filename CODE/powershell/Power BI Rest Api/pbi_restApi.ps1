Function Start-DataStreaming{
    foreach ($x in 0..500){
        $schedule = (get-date -format "yyyy-MM-ffTHH:mm:ss.000Z")
        $endpoint = "api link here"
        $payload = @{
            "date"=$schedule
            "value"=425000*$x
        }
        Invoke-RestMethod -Method Post -Uri "$endpoint" -Body (ConvertTo-Json @($payload))
        write-host "Run - {$x} {$method} {$payload}"
        start-sleep 10
    }
}

Function Get-AccessToken{
    param(
        [Parameter(Mandatory=$true)]
        [string]$tenantid,

        [Parameter(Mandatory=$true)]
        [string]$clientid,

        [securestring]$password,

        [System.Uri]$scope,

        [System.IO.FileInfo]$certificate
    )
    Connect-AzAccount -ServicePrincipal `
    -Tenant $tenantid `
    -ApplicationId $clientid `
    -CertificatePath $certificate `
    -CertificatePassword (ConvertTo-SecureString $password -AsPlainText -Force)
    $token = Get-AzAccessToken -ResourceUrl $scope
    $accessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.Token)
    )
    $header = @{
        Authorization = "Bearer $accessToken"
    }
    return $header
}

Function Get-PbiScheduleMetrics{
    param(
        [Parameter(Mandatory=$true)]
        [string]$developer,

        [Parameter(Mandatory=$true)]
        [psobject]$reports,

        [Parameter(Mandatory=$true)]
        [string]$workspace,

        [Parameter(Mandatory=$true)]
        [string]$domain,

        [Parameter(Mandatory=$true)]
        [object]$token
    )
    $history_datasets = @()
    foreach ($dataset in $reports){
        $dataset_id = $dataset.datasetId
        $dataset_name = $dataset.name
        $datasets_url = "https://api.powerbi.com/v1.0/myorg/groups/$workspace/datasets/$dataset_id/refreshes"
        $refresh_history_datasets = Invoke-RestMethod -Headers $token -Uri $datasets_url -Method Get
        $rfesh_dataset = $refresh_history_datasets.value
        $rfesh_dataset | Add-Member -MemberType NoteProperty -Name "ReportName" -Value $dataset_name -Force
        $history_datasets += $rfesh_dataset
    }
    Join-Object -Left $reports -Right $history_datasets -LeftJoinProperty "Name" -RightJoinProperty "ReportName" -Type OnlyIfInBoth | Select-Object "ReportId", "Name", "DatasetId", "WebUrl", "configuredBy", "Workspace", "refreshType", "startTime", "endTime", "status", "createdDate" | ConvertTo-Json | Out-File "$(Get-Location)\database\API\TFACT_$($domain)_PBI_REPORTS.json"
    $url_dataflow = "https://api.powerbi.com/v1.0/myorg/groups/$workspace/dataflows"
    $rest_api = Invoke-RestMethod -Headers $token -Uri $url_dataflow -Method Get
    $workspace_dataflows_id = $rest_api.value | Where-Object {$_.configuredBy -match $developer}
    $history_dataflow = @()
    foreach ($dataflow in $workspace_dataflows_id){
        $dataflow_id = $dataflow.objectId 
        $dataflow_name = $dataflow.name
        $dataflows_url = "https://api.powerbi.com/v1.0/myorg/groups/$workspace/dataflows/$dataflow_id/transactions"
        $refresh_history_dataflows = Invoke-RestMethod -Headers $token -Uri $dataflows_url -Method Get
        $refresh_dataflow = $refresh_history_dataflows.value
        $refresh_dataflow | Add-Member -MemberType NoteProperty -Name "ReportName" -Value $dataflow_name -Force
        $refresh_dataflow | Add-Member -MemberType NoteProperty -Name "DataflowName" -Value $dataflow_name -Force
        $history_dataflow += $refresh_dataflow
    }
    Join-Object -Left $workspace_dataflows_id -Right $history_dataflow -LeftJoinProperty "name" -RightJoinProperty "ReportName" -Type OnlyIfInBoth | Select-Object "DataflowName", "objectId", "refreshType", "startTime", "endTime", "status", "configuredBy", "description" | ConvertTo-Json | Out-File "$(Get-Location)\database\API\TFACT_$($domain)_PBI_DATAFLOW.json"
}


Function Get-PbiReports{
    param(
        [Parameter(Mandatory=$true)]
        [string]$developer,
        
        [Parameter(Mandatory=$true)]
        [string]$workspace,
        
        [Parameter(Mandatory=$true)]
        [string]$reports,
        
        [Parameter(Mandatory=$true)]
        [string]$datasets,
        
        [Parameter(Mandatory=$true)]
        [object]$token

    )
    $rest_api = Invoke-RestMethod -Headers $token -Uri $reports -Method Get
    $config_df = Invoke-RestMethod -Headers $token -Uri $datasets -Method Get
    $rest_api = $rest_api.value | Select-Object -Property @{Name='ReportId'; Expression={$_.id}}, DatasetId, Name, WebUrl
    $config_df = $config_df.value | Select-Object -Property id, configuredBy, isRefreshable, createdDate | Where-Object {$_.isRefreshable -eq $True}
    $engineer = Join-Object -Left $rest_api -Right $config_df -LeftJoinProperty "DatasetId" -RightJoinProperty "id" -Type OnlyIfInBoth
    $projects = $engineer | Where-Object {$_.configuredBy -match "$developer"} | Select-Object -Property ReportId, Name, DatasetId, WebUrl, configuredBy, createdDate
    $projects | Add-Member -MemberType NoteProperty -Name "Workspace" -Value "$workspace"
    return $projects
}

Function Set-PbiObjects{
    param(
        [Parameter(Mandatory=$true)]
        [psobject]$object,

        [Parameter(Mandatory=$false)]
        [string]$tp,

        [Parameter(Mandatory=$false)]
        [string]$business,
        
        [Parameter(Mandatory=$false)]
        [int]$attemptdt,

        [Parameter(Mandatory=$false)]
        [int]$attemptdf
    )
    try {
        $up_to_date = @()
        $object | Where-Object{$_.name -match $business} | ForEach-Object {
        if($_.unknown -eq 'None'){
                $url = "https://api.powerbi.com/v1.0/myorg/groups/$($_.workspace)/$($_.type)/$($_.id)/refreshes"
                if($_.body -eq 'None'){
                    Invoke-RestMethod -Headers $token -Uri $url -Method Post
                }else{
                    Invoke-RestMethod -Headers $token -Body $($_.body) -Uri $url -Method Post
                }
        }
        }
        $object | Where-Object{$_.name -match $business} | ForEach-Object {
            $status = $_.unknown
            do{
                if ($($_.type) -eq 'dataflows'){
                    start-sleep -Seconds $attemptdf
                }else{
                    start-sleep -Seconds $attemptdt
                }
                $url = "https://api.powerbi.com/v1.0/myorg/groups/$($_.workspace)/$($_.type)/$($_.id)/$($_.endpoint)"
                $transactions = Invoke-RestMethod -Headers $token -Uri $url -Method Get
                $df = $transactions.value
                $status = $df[0].status
            } while ($status -eq $_.track_status)
            if($status -eq 'Success' -or $status -eq 'Completed'){
                $up_to_date+=[PSCustomObject]@{
                    name = $_.name
                    status = $status
                    url = "https://app.powerbi.com/groups/$($_.workspace)/$($_.hype)/$($_.report)"
                    configby = 'Marcos A. De Vargas E.'
                }
            }
        }
        $sets = ($up_to_date).Count
        if ($sets -eq 1){
            $manual_validation = $up_to_date | Where-Object { $_.status -in @("Success", "Completed")}
            if($null -ne $manual_validation){
                $successdt = 1
            }else{
                $successdt = 0
            }
        }else{
            $successdt = ($up_to_date | Where-Object { $_.status -in @("Success", "Completed") }).Count
        }
        return $successdt
    }
    catch{
        write-error "Power BI REST Api failed while proccesing dataset or dataflow"
    }
}

Function Send-DaxOutput{
    param(
        [Parameter(Mandatory=$true)]
        [string]$dataset,

        [Parameter(Mandatory=$true)]
        [string]$folder,

        [Parameter(Mandatory=$true)]
        [string]$location
    )
    $access = start-job{Connect-PowerBIServiceAccount; Get-PowerBIAccessToken} | Receive-Job -Wait

    @(
        @{
            daxquery = $(Get-Content -Path "DAX_FILE" -Raw)
            save_as = "$(Get-Location)\FILE_NAME.csv" 
        }
    ) | ForEach-Object{
        try{
            $LastMod = Get-Date ((Get-Item -Path $($_.save_as)).LastWriteTime) -Format "MM-dd-yy"
        }catch{
            $LastMod = "00-00-00"
        }
        $today = Get-Date -Format "MM-dd-yy"
        if($LastMod -ne $today){
            $token = $access[1]
            $api = "https://api.powerbi.com/v1.0/myorg/datasets/$dataset/executeQueries"
            $body = @{
                        queries = @(
                            @{
                                query = "$($_.daxquery)"
                            }
                            )
                        serializerSettings = @{
                        includeNulls = $true
                        }
                        } | ConvertTo-Json
            $body = $body -replace '\\u0027', "'"
            $query = Invoke-RestMethod -Uri $api -Headers $token -Body $body -ContentType "application/json" -Method Post
            $query = $query.results.tables.rows
            $query | ConvertTo-Csv | Out-File -FilePath $($_.save_as)
        }
    }
}


# COMMON INPUTS

# $dataflows = @(
#     @{
#         workspace = 'workspace_id'
#         name = 'PROJECT_NAME'
#         id = 'dataflow_id'
#         report = 'dataflow_id'
#         track_status = 'InProgress'
#         type = 'dataflows'
#         hype = 'dataflows'
#         unknown = 'None'
#         endpoint = 'transactions'
#         body = @{
#             "refreshType" = "FullRefresh"
#             "notifyOption" = "MailOnFailure"
#             "isRefreshOnDataChange" = $false
#             "content-type" = "application/json"
#         }
#     }
# )

# $datasets = @(
#     @{
#         workspace = 'workspace_id'
#         name = 'PROJECT_NAME'
#         id = 'dataset_id'
#         report = 'report_id'
#         track_status = 'Unknown'
#         type = 'datasets'
#         hype = 'reports'
#         unknown = 'None'
#         endpoint = 'refreshes?`$top=1'
#         body = 'None'
#     }
# )

# Note: provide admin privileges to your application through Azure ADD and for credentials is needed key pair auth.