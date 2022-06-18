# database Intraction
$ConnectionParams   = @{
    ProcessName     =   "CRPTWRKS_001"
    InstanceName    =   "MST3K\DEVINSTANCE"
    DatabaseName    =   "CWDB"
    Authentication  = @{
        Type = 'SQL'
    }
    Credentials = @{
        username    = $cred.UserName
        Password    = $cred.Password
    }
}

$ConnectionParams.Credentials.Password
<#
$Instance               = @{}
$Instance.Name          = "MST3K\DEVINSTANCE"
$Instance.Database      = "master"
$Authentication         = @{}
$Authentication.Type    = @{}
$Authentication.type    = 'SQL'
$SQLUser                = "SA"
$Password               = "P@55word"
$processName            = 'CWDB_User_SQLConnection'
$TsqlCommand            = "select * from sys.databases"

    get-verb
#>

function Invoke-UDFSQLCommand{
    [CmdletBinding()]
    Param (
        $InstanceName,
        $SQLUser,
        $ProcessName,
        $Password,
        $DatabaseName,
        $authType,
        $TsqlCommand
    )
    Write-Verbose $authType 
    if($authType -match 'SQL'){
        $connectionString = "
            Server              ='$($InstanceName)';
            Integrated Security = true;
            User ID             ='$($SQLUser)';
            Application Name    = $($processName);
            Password            ='$($Password)';
            Initial Catalog     = '$($DatabaseName)'"
    }
    if($authType -match 'Windows'){
        $connectionString = "
            Server              ='$($InstanceName)';
            Integrated Security = true;
            Application Name    = $($processName);
            Initial Catalog     = 'master'"
    }
    $sqlConnection                  = New-Object System.Data.SqlClient.sqlConnection
    $sqlConnection.ConnectionString = $connectionString
    $sqlcmd                         = $sqlConnection.CreateCommand()
    <# or #>
    $sqlcmd                         = New-Object System.Data.SqlClient.SqlCommand
    $sqlcmd.Connection              = $sqlConnection
    $query                          = $TsqlCommand   
    $sqlcmd.CommandText             = $query
    $adp                            = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
    $data                           = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null
    $data.Tables[0] | Format-Table -AutoSize
}

$splatConnection = @{
    InstanceName    = $Instance.name
    database        = $Instance.database
    SQLUser         = $SQLUser
    authType        = $Authentication.type
    TsqlCommand     = $TsqlCommand
    ProcessName     = $processName
}

Invoke-UDFSQLCommand   @splatConnection -Verbose