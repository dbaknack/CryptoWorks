Function Write-Log{
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
           [switch]$IntegratedSecurity,
           [Switch]$File,
           [decimal]$ElapsedTime_Milliseconds,
           [string]$FunctionName,
           [string]$FunctionStep,
           [int]$StepID,
           [string]$DateTimeEvent,
           [string]$refDate

       )
       Process {
           $DateFormat = "yyyy-MM-dd HH:mm:ss.ff"
           #$DateTimeInitiated
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
            $DateFormat = "yyyy-MM-dd HH:mm:ss.ff"
            #$DateTimeInitiated = [datetime]::parseexact($DateTimeInitiated, 'yyyy-MM-dd HH:mm:ss.ff', $null).ToString('yyyy-MM-dd HH:mm:ss.ff')
             If (-Not $Server -Or -Not $Database -Or -Not $Table) {
               Write-Error "Missing Parameters"
               Return
             }
              # define the connection string first
             $connection                  = New-Object System.Data.SqlClient.SqlConnection
             $connection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Integrated Security=$($IntegratedSecurity);"
   
             If (-Not ($connection.State -like "Open")) {
               $connection.Open()
             }
   
             $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
             $sqlCommand.Connection = $connection
   
             $sqlCommand.CommandText = "
             DECLARE @LID INT =  (SELECT LID FROM [CWDB].dbo.LogLookUp WHERE DateTimeLogged = @refDate)
             
            INSERT INTO [$Database].dbo.$table (
            LID,
            DateTimeEvent,
            ElapsedTime_Milliseconds, 
            FunctionName, 
            StepID,
            FunctionStep, 
            Level, 
            Message
              ) VALUES (@LID, @DateTimeEvent , @ElapsedTime_Milliseconds , @FunctionName , @StepID , @FunctionStep , @Level, @Message )"
             $sqlCommand.Parameters.Add("@DateTimeEvent",             [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@refDate",                   [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@ElapsedTime_Milliseconds",  [System.Data.SqlDbType]::Float) | Out-Null
             $sqlCommand.Parameters.Add("@FunctionName",              [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@StepID",                    [System.Data.SqlDbType]::int) | Out-Null
             $sqlCommand.Parameters.Add("@FunctionStep",              [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@Level",                   [System.Data.SqlDbType]::VarChar, 255) | Out-Null
             $sqlCommand.Parameters.Add("@Message",                 [System.Data.SqlDbType]::VarChar, 255) | Out-Null
   
             $sqlCommand.Parameters['@DateTimeEvent'].Value             = (([datetime]$DateTimeEvent).ToString($DateFormat))
             $sqlCommand.Parameters['@refDate'].Value                   = (([string]$refDate))
             $sqlCommand.Parameters['@ElapsedTime_Milliseconds'].Value  = ($ElapsedTime_Milliseconds | Out-String)
             $sqlCommand.Parameters['@FunctionName'].Value              = ($FunctionName | Out-String)
             $sqlCommand.Parameters['@StepID'].Value                    = ($StepID | Out-String)
             $sqlCommand.Parameters['@FunctionStep'].Value              = ($FunctionStep | Out-String)
             $sqlCommand.Parameters['@Level'].Value                     = $Level
             $sqlCommand.Parameters['@Message'].Value                   = ($message | Out-String)
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