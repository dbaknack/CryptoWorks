# database Intraction

$InstanceName     = "MST3K\DEVINSTANCE" #use Server\Instance for named SQL instances!
$DatabaseName     = "master"
$SQLUser       = "SA"
$Password   = "P@55word"
$processName = 'CWDB_User_SQLConnection'
$TsqlCommand = "select * from Sys.databases"


function Invoke-UDFSQLCommand{
    param(
         [parameter(mandatory)]		[string[]]$InstanceName,
		 [parameter(mandatory)]		[string]$DatabaseName,
									[string]$TsqlCommand,
                                    [string]$Password,
                                    [string]$SQLUser, 
									[string]$ProcessName = "Invoke-UDFSQLCommand"
    )

    # sql connection to instance
	foreach($instance in $instancename){
		$sqlconnectionstring = 'Data Source={0};database={1};User ID={2};Password={3}' -f  $InstanceName,$DatabaseName,$SQLUser,$Password
		# sql connection, setup call
		$sqlconnection                  = new-object system.data.sqlclient.sqlconnection
		$sqlconnection.connectionstring = $sqlconnectionstring
		$sqlconnection.open()
		$sqlcommand                     = new-object system.data.sqlclient.sqlcommand
		$sqlcommand.connection          = $sqlconnection
		$sqlcommand.commandtext         = $TsqlCommand
		# sql connection, handle returned results
		$sqladapter                     = new-object system.data.sqlclient.sqldataadapter
		$sqladapter.selectcommand       = $sqlcommand
		$dataset                        = new-object system.data.dataset
		$sqladapter.fill($dataset.Ta) | out-null
		$resultsreturned               += $dataset.tables
		$sqlconnection.close()										# the session opens, but it will not close as expected
		$sqlconnection.dispose()									# TO-DO: make sure the connection does close
    }
    $resultsreturned | ft -autosize
}

Invoke-UDFSQLCommand -instance $instancename -databasename $databasename -password $password -SQLUser $SQLUser -processname $processName -TsqlCommand $TsqlCommand


#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection = 'Data Source={0};database={1};User ID={2};Password={3}' -f $SQLServer,$SQLDBName,$SQLUser,$SQLPassword

   
$SqlCmd                   = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText       = "Select * from Sys.databases"
$SqlCmd.Connection        = $SqlConnection 

$SqlAdapter               = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd 

$DataSet                  = New-Object System.Data.DataSet

$SqlAdapter.Fill($DataSet)
$DataSet.tables[0]| ft -autosize
$DataSet.tables | ft -autosize
#$SqlConnection.Close() 

#End :database Intraction
#clear



function Test-SqlConnection {
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $ErrorActionPreference = 'Stop'

    try {
        $userName = $Credential.UserName
        $password = $Credential.GetNetworkCredential().Password
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$password
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        ## This will run if the Open() method does not throw an exception
        $true
    } catch {
        $false
    } finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
    }
}

$ServerName     = 'mst3k\devinstance'
$DatabaseName   = 'master'
    
$userName       = 'sa'
$password       = 'P@55word'
$connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$password
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
$SqlCmd                   = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText       = "select @@version" 
$SqlAdapter               = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd 
$DataSet                  = New-Object System.Data.DataSet

$SqlAdapter.fill($DataSet)
$sqlConnection.Open()
        ## This will run if the Open() method does not throw an exception
        $true
    } catch {
        $false
    } finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
    }
}
