$config = Get-Content -path E:\Credentials\EmailParams\Outbound.Emails.Config.json | convertfrom-json
$Creds  = Get-StoredCredential -Name EmailService

$EmailSplat = @{
    from = $config.from
    to = $config.To
    subject = $config.Subject
    body = $config.Body
    SmtpServer = $config.SmtpServer
    port = $config.Port
    usessl = $true
    Credential = $Creds

}

Send-MailMessage @EmailSplat