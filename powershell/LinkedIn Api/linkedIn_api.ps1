Function Get-Response {
    param(
        [Parameter(Mandatory=$true)]
        [System.Uri]$Url
    )
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("$($Env:linkedIn_host)/callback/")
    $listener.Start()
    
    Start-Process $Url
    
    $context = $listener.GetContext()
    $request = $context.Request
    $code = $request.QueryString["code"]
    $listener.Stop()
    return $code
}
Function Get-AccessToken {
    param(
        [Parameter(Mandatory=$true)]
        [string]$code
    )
    $payLoad = @{
        grant_type = "authorization_code"
        redirect_uri  = "$($Env:LinkedIn_host)/callback"
        client_id = $($Env:linkedIn_client)
        client_secret = $($Env:linkedIn_secrect)
        code = $($code)
    }

    $accessToken = Invoke-WebRequest `
        -Uri "https://api.linkedin.com/oauth/v2/accessToken" `
        -Body $payLoad `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -UseBasicParsing

    $content = $accessToken.Content | ConvertFrom-Json
    $token = $content.access_token
    return $token

}
Function Publish-BusinessFeed {
    param(
        [Parameter(Mandatory=$true)]
        [string]$token,

        [Parameter(Mandatory=$true)]
        [string]$message

    )
    $header = @{
        Authorization = "Bearer $token"
        "X-Restli-Protocol-Version" = "2.0.0"
        "LinkedIn-Version" = "202402"
    }

    $publish = @{
        author = "urn:li:organization:$($Env:linkedIn_user)"
        lifecycleState = "PUBLISHED"
        specificContent = @{
            "com.linkedin.ugc.ShareContent" = @{
                "shareCommentary" = @{
                    text = "$message"
                }
                shareMediaCategory = "NONE"
            }
        }
        visibility = @{
            "com.linkedin.ugc.MemberNetworkVisibility" = "PUBLIC"
        }
    }

    Invoke-WebRequest `
        -Uri "https://api.linkedin.com/v2/ugcPosts" `
        -Headers $header `
        -Body ($publish | ConvertTo-Json -Depth 10) `
        -Method Post `
        -ContentType "application/json"
}

$code = Get-Response -Url "https://api.linkedin.com/oauth/v2/authorization?response_type=code&client_id=$($Env:linkedIn_client)&redirect_uri=$($Env:linkedIn_host)/callback&scope=$($Env:linkedIn_mscope)"
$token = Get-AccessToken -code $code
Publish-BusinessFeed -token $token -message "Hello World from PowerShell"