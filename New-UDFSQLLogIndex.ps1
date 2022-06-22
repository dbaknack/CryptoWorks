function New-UDFSQLLogIndex{
    param(
        [string]$InstanceName       = "MST3K\DEVINSTANCE",
        [string]$DatabaseName       = "CWDB",
        [string]$processName        = $MyInvocation.MyCommand.name,
        [string]$ExecutingUser      = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        [string]$IntegratedSecurity,
        [switch]$refDateTime
    )
    begin{ 
        $TableName              = "LogLookUp"
        $DateFormat             = "yyyy-MM-dd HH:mm:ss.ff"
        $DateTimeCollected      = Get-Date
        $sqlCommand             = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.commandText = "
            SET NOCOUNT ON
            INSERT INTO [$($InstanceName)].[$($DatabaseName)].[dbo].[$($TableName)]
                (DateTimeLogged,ProcessName,ExecutingUser)
            VALUES
            (@DateTimeLogged,@ProcessName,@ExecutingUser)"

        $sqlCommand.Parameters.Add("@DateTimeLogged", [System.Data.SqlDbType]::DateTime) | Out-Null
        $sqlCommand.Parameters.Add("@ProcessName",    [System.Data.SqlDbType]::VarChar, 255) | Out-Null
        $sqlCommand.Parameters.Add("@ExecutingUser",  [System.Data.SqlDbType]::VarChar, 255) | Out-Null
        $sqlCommand.Parameters['@DateTimeLogged'].Value = (($DateTimeCollected ).ToString($DateFormat))
        $sqlCommand.Parameters['@ProcessName'].Value    = ($processName | Out-String)
        $sqlCommand.Parameters['@ExecutingUser'].Value    = ($ExecutingUser | Out-String)
    }
    process{
        $sqlConnectionParams    = @{
            InstanceName        = $InstanceName
            DatabaseName        = $DatabaseName
            ProcessName         = $ProcessName
            IntegratedSecurity  = $true
            sqlCommandObject    =  $sqlCommand
        }
        Invoke-UDFSqlConnection @sqlConnectionParams
    }
    end{
        if($refDateTime){
            $DateTimeCollected.ToString($DateFormat)
            return
        }
        return
    }
}