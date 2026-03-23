$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("$($Env:linkedIn_host)/callback/")
$listener.Start()

Start-Process "https://api.linkedin.com/oauth/v2/authorization?response_type=code&client_id=$($Env:linkedIn_client)&redirect_uri=$($Env:linkedIn_host)/callback&scope=$($Env:linkedIn_mscope)"

$context = $listener.GetContext()
$request = $context.Request
$code = $request.QueryString["code"]
$listener.Stop()

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

$header = @{
    Authorization = "Bearer $($content.access_token)"
    "X-Restli-Protocol-Version" = "2.0.0"
    "LinkedIn-Version" = "202402"
  }

$publish = @{
    author = "urn:li:organization:$($Env:linkedIn_user)"
    lifecycleState = "PUBLISHED"
    specificContent = @{
        "com.linkedin.ugc.ShareContent" = @{
            "shareCommentary" = @{
                text = "Hello World! This is my first Share on LinkedIn with PowerShell! Code will be available on GitHub soon."
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