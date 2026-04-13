Function Add-PrivatePublicKeySnowflake {
    param(
        [Parameter(Mandatory=$true)]
        [string]$location,

        [Parameter(Mandatory=$true)]
        [securestring]$password,

        [Parameter(Mandatory=$true)]
        [string]$name
    )
    ssh-keygen -t rsa -b 2048 -m PKCS8 -N "$password" -f "$private_key/files/$name.p8"
    ssh-keygen -f "$private_key/files/$name.p8" -e -m PKCS8 > "$private_key/files/$name.pub"
}

Function Add-PrivatePublicKeyMicrosoft {
    param(
        [Parameter(Mandatory=$true)]
        [string]$location,

        [Parameter(Mandatory=$true)]
        [securestring]$password,

        [Parameter(Mandatory=$true)]
        [string]$name
    )
    $private_key = New-SelfSignedCertificate -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeyLength 2048 -HashAlgorithm SHA256 -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyAlgorithm RSA -Subject "CN=MyAzureAppCert" -NotAfter (Get-Date).AddYears(2)
    $password = ConvertTo-SecureString -String $password -AsPlainText -Force
    Export-PfxCertificate -Cert $private_key -FilePath "$private_key/files/$name.pfx" -Password $password
    Export-Certificate -Cert $private_key -FilePath "$private_key/files/$name.cer"
}

Function Add-PrivatePublicKeyGitHub {
    ssh-keygen -t ed25519 -C "$Env:email"
    ssh -T git@github.com
}

Function Add-PrivatePublicKeyPowerShellRemoteSigned {
    param(
        [Parameter(Mandatory=$true)]
        [string]$location,
        $cert
    )
    New-SelfSignedCertificate -Type CodeSigningCert -Subject $cert -CertStoreLocation "Cert:\CurrentUser\My"
    $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $cert }
    $folder = Get-ChildItem -Path "$location"
    ForEach ($file in $folder) {
        Set-AuthenticodeSignature -FilePath $file.FullName -Certificate $cert
    }
    return $cert
}

Function Remove-PrivatePublicKeyPowerShellRemoteSigned{
    param(
        [Parameter(Mandatory=$true)]
        [string]$location,
        $cert
    )
    $folder = Get-ChildItem -Path "$location"
    ForEach ($file in $folder) {
        $unsigned = (Get-Content $($file.FullName) -Raw) -replace '(?s)# SIG # Begin signature block.*?# SIG # End signature block'
        Set-Content -Path $($file.FullName) -Value $unsigned
    }
    $main_handle = (Get-Content $("$location/main_file.ps1") -Raw) -replace '(?s)# SIG # Begin signature block.*?# SIG # End signature block'
    Set-Content -Path $("$location/main_file.ps1") -Value $main_handle
    Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $cert } | Remove-Item
}