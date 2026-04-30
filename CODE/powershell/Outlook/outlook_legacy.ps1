Function Send-Email {
    param(
            [Parameter(Mandatory=$true)]
            [string]$file,

            [Parameter(Mandatory=$true)]
            [string]$subject,

            [Parameter(Mandatory=$true)]
            [string]$msg

        )
    $outlook = new-object -comobject outlook.application 
    $email = $outlook.CreateItem(0) 
    $email.To("email_name@company.com") 
    $email.Subject = "$subject"
    $email.BodyFormat = 1
    $email.htmlbody = "
            <font size = '+1.2'>
                <p>Hi, $msg</p>
                <p>Best Regards,</p>
            </font>
            <font size ='+1.2'>
                <p><font color='blue'>_____________________________________________________________________</font></p>
                <b>Name</b>
                <p>Role and Department</p>
                <p><b>Division</b></p>
                <p>Address</p>
                <p>Country</p>
                <p><font color='blue'>_____________________________________________________________________</font></p>
            </font>
    "
    $email.Attachments.Add($file)
    $email.Display() ; $email.Send()
}

Function Get-Scrapping{
    $outlook = new-object -comobject outlook.application 
    $mapi = $outlook.GetNamespace("MAPI")
    $inbox = $mapi.GetDefaultFolder(6)
    $messages = $inbox.Items
    @(
        @{
            "folder" = "" #provide folder name to be create here
            "subject" = "" #provide subject here
            "file-name" = "" #provide file name here
            "extension" = "" # provide file extention, example : .xlsx
        }
    ) | Foreach-Object{
        try {
            $folder = $_.folder; $subject = $_.subject; $extension = $_.extension
            if(Test-Path -path $folder -PathType Container){
                ;
            }else{
                New-Item -path $folder -ItemType Directory
            }
            $messages | Foreach-Object{
                if (($_.ConversationTopic).startswith($subject)){
                    $output_file = "Path.$extension"
                    $attachments = $_.Attachments
                    write-host $output_file
                    if(Test-Path -path $output_file){
                        ;
                    }
                    } else {       
                        foreach($attachment in $attachments){
                            if (($attachment.FileName).endswith($extension)){
                                if(Test-Path -path $output_file){
                                ;
                                }else{                                
                                    $attachment.SaveAsFile($output_file)
                                    write-host "$output_file was created"
                                }
                            }
                        }            
                        }
                    }
        }
        catch {
            write-host "Something went wrong: $($_.Exception.Message)"
        }
    }
}