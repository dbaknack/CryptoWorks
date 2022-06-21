function Invoke-SqlConnection {
    param(
        [Parameter(Mandatory)]
        [string]$InstanceName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$processName,

        [Parameter(Mandatory)]
        [string]$IntegratedSecurity,

        [Parameter(Mandatory)]
        [string]$userName,

        [Parameter(Mandatory)]
        [securestring]$Password,
        [object]$sqlCommandObject)
    begin{
        $ErrorActionPreference = 'Stop'
        $connectionString   = "
            Data Source         =   $($InstanceName);
            Database            =   $($DatabaseName);
            Application Name    =   $($ProcessName);
            Integrated Security =   $($IntegratedSecurity);
            User ID             =   $($username);
            Password            =   $($Password)"
        
        $sqlConnection  = New-Object System.Data.SqlClient.SqlConnection $connectionString
        if(-Not $($sqlConnection.State -like "Open")){
            $sqlConnection.Open()
        }
    }
    process{
        $sqlCommandObject.Connection = $sqlConnection
        try{$sqlCommandObject.ExecuteNonQuery()   | Out-Null}
        catch{Write-Error "Unable to Insert Log Record: $($_.Exception.Message)"}
    }
    end{
        if($sqlConnection.State -like "Open"){
            $sqlConnection.Close()
        }
    }
}