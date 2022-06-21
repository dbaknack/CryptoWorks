function New-UDFSQLLogIndex{
    param(
        [string]$InstanceName       = "MST3K\DEVINSTANCE",
        [string]$DatabaseName       = "CWDB",
        [string]$processName        = "Request-UDFLogID",
        [string]$IntegratedSecurity = $true
    )
    begin{
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
    }
    process{
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
    }
    end{}
} 