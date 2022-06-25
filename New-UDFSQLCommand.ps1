function New-UDFSQLCommand{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('SELECT','INSERT','UPDATE','DELET','CALL')]
        [string]$DML,
        [parameter(Mandatory = $true)]
        [string]$InstanceName,
        [parameter(Mandatory = $true)]
        [string]$DatabaseName,
        [parameter(Mandatory = $true)]
        [string]$TableName,
        [parameter(Mandatory = $true)]
        [string]$SQLStatement,
        [string]$ExecutingUser  = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    )
    begin{
       
        $ProcessName            = Get-ModuleVariables -var 'FunctionName'
        $ProcessName
        $DateFormat             = Get-ModuleVariables -var 'DateFormat'
        $DateTimeCollected      = Get-Date
        $DateTimeCollected.ToString($DateFormat)
        $sqlCommand             = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.commandText =  $SQLStatement -f $InstanceName,$DatabaseName,$TableName


        $sqlCommand.Parameters.Add("@InstanceName", [System.Data.SqlDbType]::nVarChar) | Out-Null
        $sqlCommand.Parameters.Add("@DatabaseName",  [System.Data.SqlDbType]::nVarChar, 1000) | Out-Null
        $sqlCommand.Parameters.Add("@TableName",  [System.Data.SqlDbType]::nVarChar, 1000) | Out-Null

        $sqlCommand.Parameters.Add("@DateTimeLogged", [System.Data.SqlDbType]::DateTime) | Out-Null
        $sqlCommand.Parameters.Add("@ProcessName",    [System.Data.SqlDbType]::VarChar, 255) | Out-Null
        
        $sqlCommand.Parameters.Add("@SQLStatement",  [System.Data.SqlDbType]::nVarChar, 1000) | Out-Null
        $sqlCommand.Parameters.Add("@ExecutingUser",  [System.Data.SqlDbType]::VarChar, 255) | Out-Null

        $sqlCommand.Parameters['@DateTimeLogged'].Value = (($DateTimeCollected).ToString("$DateFormat"))
        $sqlCommand.Parameters['@ProcessName'].Value    = ($processName | Out-String)
        $sqlCommand.Parameters['@InstanceName'].Value  = ($InstanceName | Out-String)
        $sqlCommand.Parameters['@DatabaseName'].Value  = ($DatabaseName | Out-String)
        $sqlCommand.Parameters['@TableName'].Value  = ($TableName | Out-String)
        $sqlCommand.Parameters['@SQLStatement'].Value  = ($SQLStatement | Out-String)
        $sqlCommand.Parameters['@ExecutingUser'].Value  = ($ExecutingUser | Out-String)
        $sqlCommand.commandText
    }
    process{
        $sqlConnectionParams    = @{
            sqlCommandObject    =  $sqlCommand
        }
        Invoke-UDFSqlConnection @sqlConnectionParams -Verbose
    }
    end{
        if($refDateTime){
            $DateTimeCollected.ToString($DateFormat)
            #return
        }
        #return
    }
}