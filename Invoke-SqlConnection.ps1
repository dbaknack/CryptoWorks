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

        [string]$TSQLCommand)
    begin{
        $ErrorActionPreference = 'Stop'
        $connectionString = "
            Data Source         =   $($InstanceName);
            Database            =   $($DatabaseName);
            Application Name    =   $($ProcessName);
            Integrated Security =   $($IntegratedSecurity);
            User ID             =   $($userName);
            Password            =   $($Password)"
    }
    process{
        if($processName -eq 'CRPTWRKS_001'){
            try {
                $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
                $sqlConnection.Open()
                
                ## This will run if the Open() method does not throw an exception
                $connectionStatus = $true
            } catch {
                $connectionStatus =  $false
            } finally {
                ## Close the connection when we're done
                $sqlConnection.Close()
            }
        }
    }
    end{
        if($processName -eq 'CRPTWRKS_002'){
                $sqlConnection  = New-Object System.Data.SqlClient.SqlConnection $connectionString
                $sqlCmd         = New-Object System.Data.SqlClient.SqlCommand
                $sqlConnection.Open()
                $SqlCmd.CommandText = $TSQLCommand
                $SqlCmd.Connection = $sqlConnection
                $sqlCmd.ExecuteNonQuery()  | out-null
                $sqlConnection.Close() | out-null
        }
    }
}