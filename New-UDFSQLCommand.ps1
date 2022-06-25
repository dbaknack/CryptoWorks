function New-UDFSQLCommand{
    [CmdletBinding()]
    param(
        [parameter(Mandatory    = $true)][ValidateSet('SELECT','INSERT','UPDATE','DELET','CALL')][string]$DML,
        [parameter(Mandatory    = $true)][string]$InstanceName,
        [parameter(Mandatory    = $true)][string]$DatabaseName,
        [parameter(Mandatory    = $true)][string]$TableName,
        [parameter(Mandatory    = $true)][string]$SQLStatement,
        [string]$ExecutingUser  = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
    begin{
        $ProcessName            = Get-ModuleVariables -var 'FunctionName'
        $DateFormat             = Get-ModuleVariables -var 'DateFormat'
        $DateTimeCollected      = Get-Date
        $SQLCommand             = New-Object System.Data.SqlClient.SQLCommand
        $SQLCommand.commandText =  $SQLStatement -f $InstanceName,$DatabaseName,$TableName
        <#----------------------------------------------------------------------------------------------------#>
        <#1#>$SQLCommand.Parameters.Add( "@InstanceName",     [System.Data.SqlDbType]::nVarChar)      | Out-Null
        <#2#>$SQLCommand.Parameters.Add( "@DatabaseName",     [System.Data.SqlDbType]::nVarChar, 255) | Out-Null
        <#3#>$SQLCommand.Parameters.Add( "@TableName",        [System.Data.SqlDbType]::nVarChar, 255) | Out-Null
        <#4#>$SQLCommand.Parameters.Add( "@DateTimeLogged",   [System.Data.SqlDbType]::DateTime)      | Out-Null
        <#5#>$SQLCommand.Parameters.Add( "@ProcessName",      [System.Data.SqlDbType]::VarChar, 255)  | Out-Null
        <#6#>$SQLCommand.Parameters.Add( "@SQLStatement",     [System.Data.SqlDbType]::nVarChar, 255) | Out-Null
        <#7#>$SQLCommand.Parameters.Add( "@ExecutingUser",    [System.Data.SqlDbType]::VarChar, 255)  | Out-Null
        <#----------------------------------------------------------------------------------------------------#>
        <#1#>$SQLCommand.Parameters[ '@DateTimeLogged'].Value  = (($DateTimeCollected).ToString("$DateFormat"))
        <#2#>$SQLCommand.Parameters[ '@ProcessName'].Value     = ($processName     | Out-String)
        <#3#>$SQLCommand.Parameters[ '@InstanceName'].Value    = ($InstanceName    | Out-String)
        <#4#>$SQLCommand.Parameters[ '@DatabaseName'].Value    = ($DatabaseName    | Out-String)
        <#5#>$SQLCommand.Parameters[ '@TableName'].Value       = ($TableName       | Out-String)
        <#6#>$SQLCommand.Parameters[ '@SQLStatement'].Value    = ($SQLStatement    | Out-String)
        <#7#>$SQLCommand.Parameters[ '@ExecutingUser'].Value   = ($ExecutingUser   | Out-String)
    }
    process{ Invoke-UDFSQLConnection SQLCommandObject $SQLCommand -Verbose }
    end{ $DateTimeCollected.ToString($DateFormat);return }
}