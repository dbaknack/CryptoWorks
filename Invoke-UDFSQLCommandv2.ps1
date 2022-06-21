

$InstanceName           = "MST3K\DEVINSTANCE"
$DatabaseName           = "CWDB"
$processName            = 'Test'
$IntegratedSecurity     = $true

$TableName              = "LogLookUp"
$DateFormat             = "yyyy-MM-dd HH:mm:ss.ff"
$sqlCommand             = New-Object System.Data.SqlClient.SqlCommand
$sqlCommand.commandText = "
    SET NOCOUNT ON
    INSERT INTO [$($InstanceName)].[$($DatabaseName)].[dbo].[$($TableName)]
        (DateTimeLogged)
    VALUES
        (@DateTimeLogged)"

$sqlCommand.Parameters.Add("@DateTimeLogged",[System.Data.SqlDbType]::DateTime) | Out-Null
$sqlCommand.Parameters['@DateTimeLogged'].Value = ((Get-Date).ToString($DateFormat))




$credentials            = Get-StoredCredential -Name sqlserver
$sqlConnectionParams    = @{
    InstanceName        = $InstanceName
    DatabaseName        = $DatabaseName
    ProcessName         = $ProcessName
    IntegratedSecurity  = $true
    UserName            = $credentials.username
    PassWord            = $credentials.password
    sqlCommandObject    =  $sqlCommand
}

Invoke-SqlConnection @sqlConnectionParams 



<#
"SET NOCOUNT ON
INSERT INTO [$($Database)].[$($dbo)].[$($table)](
    DateTimeLogged,
    DateTimeEvent,
    ElapsedTime_Milliseconds,
    FunctionName,
    StepID,
    FunctionStep,
    Level,
    Message)
VALUES(
    @DateTimeLogged,
    @DateTimeEvent,
    @ElapsedTime_Milliseconds,
    @FunctionName,
    @StepID,
    @FunctionStep,
    @Level,
    @Message)"
#>


$test = Request-UDFLogID