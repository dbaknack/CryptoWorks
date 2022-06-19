Function Write-Log {
    [CmdletBinding()]
       Param (
           [Parameter(
               Mandatory=$true,
               ValueFromPipeline=$true,
               Position=0)]
           [ValidateNotNullorEmpty()]
           [String]$Message,
   
         [Parameter(Position=1)]
           [ValidateSet("Information","Warning","Error","Debug","Verbose")]
           [String]$Level = 'Information',
   
           [String]$Path = [IO.Path]::GetTempPath(),
           [String]$Server,
           [String]$Database,
           [String]$Table,
   
           [Switch]$NoHost,
           [Switch]$SQL,
           [Switch]$File,
           [decimal]$ElapsedTime,
           [string]$FunctionName,
           [string]$FunctionStep,
           [int]$StepID
       )
   
       Process {
           $DateFormat = "yyyy-MM-dd HH:mm:ss.00"
   
           If (-Not $NoHost) {
             Switch ($Level) {
               "information" {
                 Write-Host ("[{0}] {1}" -F (Get-Date).toString($DateFormat), $Message)
                 Break
                 
               }
               "warning" {
                 Write-Warning ("[{0}] {1}" -F (Get-Date).toString($DateFormat), $Message)
                 Break
               }
               "error" {
                 Write-Error ("[{0}] {1}" -F (Get-Date).toString($DateFormat), $Message)
                 Break
               }
               "debug" {
                 Write-Debug ("[{0}] {1}" -F (Get-Date).toString($DateFormat), $Message) -Debug:$true
                 Break
               }
               "verbose" {
                 Write-Verbose ("[{0}] {1}" -F (Get-Date).toString($DateFormat), $Message) -Verbose:$true
                 Break
               }
             }
           }
   
           If ($File) {
             Add-Content -Path (Join-Path $Path 'log.txt') -Value ("[{0}] ({1}) {2}" -F (Get-Date).toString($DateFormat), $Level, $Message)
  
  }
   
           If ($SQL) {
            $DateFormat = "%m/%d/%Y %H:%M:%S"
             If (-Not $Server -Or -Not $Database -Or -Not $Table) {
               Write-Error "Missing Parameters"
               Return
             }
   
             $connection                  = New-Object System.Data.SqlClient.SqlConnection
             $connection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Integrated Security=SSPI;"
   
             If (-Not ($connection.State -like "Open")) {
               $connection.Open()
             }
   
             $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
             $sqlCommand.Connection = $connection
   
             $sqlCommand.CommandText = "INSERT INTO [$Database].dbo.$table ( DateTime, ElapsedTime_Milliseconds, FunctionName , StepID ,FunctionStep , Level, Message ) VALUES ( @DateTime, @ElapsedTime , @FunctionName , @StepID , @FunctionStep , @Level, @Message )"
   
             $sqlCommand.Parameters.Add("@DateTime",        [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@ElapsedTime",     [System.Data.SqlDbType]::Float) | Out-Null
             $sqlCommand.Parameters.Add("@FunctionName",    [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@StepID",          [System.Data.SqlDbType]::int) | Out-Null
             $sqlCommand.Parameters.Add("@FunctionStep",    [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@Level",           [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@Message",         [System.Data.SqlDbType]::VarChar, 255) | Out-Null
   
             $sqlCommand.Parameters['@DateTime'].Value          = (Get-Date -UFormat $DateFormat)
             $sqlCommand.Parameters['@ElapsedTime'].Value       = ($ElapsedTime | Out-String)
             $sqlCommand.Parameters['@FunctionName'].Value      = ($FunctionName | Out-String)
             $sqlCommand.Parameters['@StepID'].Value            = ($StepID | Out-String)
             $sqlCommand.Parameters['@FunctionStep'].Value      = ($FunctionStep | Out-String)
             $sqlCommand.Parameters['@Level'].Value             = $Level
             $sqlCommand.Parameters['@Message'].Value           = ($message | Out-String)
             
   
             Try {
               $sqlCommand.ExecuteNonQuery() | Out-Null
             } Catch {
               Write-Error "Unable to Insert Log Record: $($_.Exception.Message)"
             }
   
             If ($connection.State -like "Open") {
               $connection.Close()
             }
           }
       }
   }

