function Invoke-UDFSqlConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$InstanceName,
        [Parameter(Mandatory)][string]$DatabaseName,
        [Parameter(Mandatory)][string]$IntegratedSecurity,
        [Parameter(Mandatory)][string]$userName,
        [Parameter(Mandatory)][object]$sqlCommandObject)
    begin{
        $ErrorActionPreference = 'Stop'
        $connectionString   = "
            Data Source         =   $($InstanceName);
            Database            =   $($DatabaseName);
            Integrated Security =   $($IntegratedSecurity);
            User ID             =   $($username);
            Password            =   $($Password)"
        
        $sqlConnection  = New-Object System.Data.SqlClient.SqlConnection $connectionString
        if(-Not $($sqlConnection.State -like "Open")){ $sqlConnection.Open();   Write-Verbose -message "SQL connection open" -Verbose }
    }
    process{
        $sqlCommandObject.Connection = $sqlConnection
        try{ $sqlCommandObject.ExecuteNonQuery() }
        catch{ Write-Error "Unable to Insert Log Record: $($_.Exception.Message)" ./Get-UDFIndexBlocks.ps1}
    }
    end{
        if($sqlConnection.State -like "Open"){ $sqlConnection.Close() }
    }
}