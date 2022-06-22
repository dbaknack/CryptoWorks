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
             $connection.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Integrated Security=SSPI;"
   
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
function New-UDFSQLLogIndex{
    param(
        [string]$InstanceName       = "MST3K\DEVINSTANCE",
        [string]$DatabaseName       = "CWDB",
        [string]$processName        = $MyInvocation.MyCommand.name,
        [string]$ExecutingUser      = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        [string]$IntegratedSecurity = $true,
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
   # store the credentials to be used in the module
function Invoke-UDFSqlConnection {
    param(
        [Parameter(Mandatory)]
        [string]$InstanceName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$processName,

        [Parameter(Mandatory)]
        [string]$IntegratedSecurity,

       # [Parameter(Mandatory)]
        [string]$userName,

       [Parameter(Mandatory)]
        [securestring]$Password,
        [object]$sqlCommandObject)
    begin{
        $FunctionName = $MyInvocation.mycommand.name
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
   
function Get-UDFWeekofYear{
    Param($date)
        $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
        $cultureInfo.Calendar.GetWeekOfYear($Date,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
}

<#
.SYNOPSIS
    Read a credential object from the credential store. If no credential is available or valid it will
    prompt for the credential and store it in the credential store.
.DESCRIPTION
    This cmdlet can be used in scripts to avoid prompting for a credential everytime the script runs. This method
    is much safer then storing the credential in the script itself or using your own method. The Windows Data
    Protection API (DPAPI) is used to encrypt the password. The password can only be decrypted by the same
    user who encrypted it. Resetting your password will void the decryption key and make the credential unusable.
    As the encryption key is tied to the user, the credential store must be personal, wich means a seperate
    store for each user. The default store is the directory '<My Documents>\Credentials'.
.NOTES
    Author: Theo Hardendood, Metis IT B.V.

    Version History:
    1.0 - 06-07-2016 - Initial release
.PARAMETER Name
    The name of the credential. Used for naming the files in the credential store.
    The name is not case sensitive. Two files will be used for each credential: '<Name>.username'
    and '<Name>.password'. Whitespace or special characters are not allowed.
.PARAMETER StorePath
    The path to the credential store. Default is '<My Documents>\Credentials'. This must be a writeable
    directory that will be created if it does not exist. 
.PARAMETER Credential
    Save the supplied credential in the credential store, overwriting an existing credential.
.PARAMETER UserName
    The user name used in the credential when prompting. This will only be used when asking for a new credential,
    and can be changed by the user.
.PARAMETER Message
    The message that appears in the credential prompt.
.PARAMETER DoNotPrompt
    Do not prompt for the credential if it cannot be found or read and throw an exception.
.PARAMETER Reset
    Reset credential by prompting for a new one.
.PARAMETER Delete
    Delete credential and do not prompt for a new one.
.EXAMPLE
    $cred = Get-UDFStoredCredential -Name vCenter

    Read credential for vCenter and return as PSCredential object. The cmdlet will prompt for username and
    password if the credential cannot be read.
.EXAMPLE
    $cred = Get-UDFStoredCredential -Name JustAName -UserName "Administrator"

    If it must ask for a new credential, the user name field will be filled in as a suggestion.
.EXAMPLE
    $cred = Get-UDFStoredCredential -Name JustAName -StorePath "E:\Credentials\myname"

    Uses the file 'E:\Credentials\myname\JustAName.username' to store the user name and the file
    'E:\Credentials\myname\JustAName.password' to store the password.
.EXAMPLE
    Get-UDFStoredCredential -Name JustAName -Credential $cred

    Store the credential $cred in the credential store. Use this method for storing a credential if it is used
    in a script running under a service account and you cannot log in under that account. To make this work, create
    a script with the below contents (don't forget to use the correct UserName and Password) and run it under the
    service account. Make sure the path to the credential store is valid.

    $securePassword = ConvertTo-SecureString -String "ThePassword" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "TheUserName", $securePassword
    Get-UDFStoredCredential -Name JustAName -StorePath "E:\Credentials\ServiceAccount" -Credential $cred

    Do not forget to overwrite or delete this script afterward, or your password is still exposed.
.EXAMPLE
    Get-UDFStoredCredential -Name JustAName -Delete

    Delete the credential JustAName. If the -Delete parameter is used then no PSCredential object will be returned.
#>
function Get-UDFStoredCredential{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,HelpMessage="The name of the credential.")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$false,Position=1,HelpMessage="The path to the credential store.")]
        [string]$StorePath,
        [Parameter(Mandatory=$false,Position=2,HelpMessage="Save the supplied credential in the credential store, overwriting the existing credential.")]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false,Position=3,HelpMessage="The user name used in the credential when prompting.")]
        [string]$UserName,
        [Parameter(Mandatory=$false,Position=4,HelpMessage="The message that appears in the credential prompt.")]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=5,HelpMessage="Do not prompt for the credential if it cannot be read and throw an exception.")]
        [Switch]$DoNotPrompt,
        [Parameter(Mandatory=$false,Position=6,HelpMessage="Reset credential by prompting for a new one.")]
        [Switch]$Reset,
        [Parameter(Mandatory=$false,Position=7,HelpMessage="Delete credential and do not prompt for a new one.")]
        [Switch]$Delete
    )

    begin
    {
    }

    process
    {
        $ErrorActionPreference = "Stop"
        try
        {
            if ($Name -notmatch "^\w\w*$")
            {
                throw "Name cannot contain whitespace or special characters."
            }
            if ([String]::IsNullOrEmpty($StorePath))
            {
                $p_StorePath = [environment]::GetFolderPath("mydocuments") + "\Credentials"
            }
            else
            {
                $p_StorePath = $StorePath
            }
            if (-Not (Test-Path -Path $p_StorePath -PathType Container))
            {
                New-Item -Path $p_StorePath -ItemType Directory | Out-Null
            }
            $p_UserNamePath = [String]::Format("{0}\{1}.username", $p_StorePath, $Name)
            $p_PasswordPath = [String]::Format("{0}\{1}.password", $p_StorePath, $Name)
            if ($Delete.IsPresent)
            {
                if (Test-Path -Path $p_UserNamePath -PathType Leaf)
                {
                    Remove-Item -Path $p_UserNamePath -Force
                }
                if (Test-Path -Path $p_PasswordPath -PathType Leaf)
                {
                    Remove-Item -Path $p_PasswordPath -Force
                }
                return
            }
            if ($Credential -ne $null)
            {
                $Credential.UserName | Out-File $p_UserNamePath -Force
                $Credential.Password | ConvertFrom-SecureString | Out-File $p_PasswordPath -Force
                return $Credential
            }
            try
            {
                if ($Reset.IsPresent)
                {
                    throw "Request new credential"
                }
                $p_UserName = Get-Content -Path $p_UserNamePath
                $p_Password = Get-Content -Path $p_PasswordPath | ConvertTo-SecureString
                $p_Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $p_UserName, $p_Password
                return $p_Credential
            }
            catch
            {
                if ($DoNotPrompt.IsPresent)
                {
                    throw "Cannot read credential, and prompting for a new credential is not allowed."
                }
                if ([String]::IsNullOrEmpty($Message))
                {
                    $p_Message = "Please enter credential for $Name"
                }
                else
                {
                    $p_Message = $Message
                }
                $p_Args = @{}
                if ([String]::IsNullOrEmpty($UserName) -eq $false)
                {
                    $p_Args = @{ "UserName" = "$UserName"}
                }
                else
                {
                    if ([String]::IsNullOrEmpty($p_UserName) -eq $false)
                    {
                        $p_Args = @{ "UserName" = "$p_UserName"}
                    }
                }
                $p_Credential = Get-Credential -Message $p_Message @p_Args
                if ($p_Credential -ne $null)
                {
                    $p_Credential.UserName | Out-File $p_UserNamePath -Force
                    $p_Credential.Password | ConvertFrom-SecureString | Out-File $p_PasswordPath -Force
                }
                return $p_Credential
            }
        }
        catch
        {
            Write-Host -BackgroundColor Black -ForegroundColor Red "Get-UDFStoredCredential: $($_.Exception.Message)"
        }
    }
}

function Convertto-UDFASCII($string){
    $asciitochar   = @{}
    $ihartoascii   = @{}
    $asciitobinary = @{}
    97..122 | ForEach-Object {$asciitochar.add($_,([char]$_).toString())}
    foreach($k in $asciitochar.keys){$ihartoascii.add($asciitochar[$k],$k)}
    foreach($k in $asciitochar.keys){$asciitobinary.add($k,[convert]::ToString($k,2))}

    $collection = $null
    $countloop = 1
    $totalCharinString = ($string.tocharArray()).count
    $string = $string.ToCharArray() |ForEach-Object{$ihartoascii["$_"]}
    foreach($char in $string){
        if($totalCharinString -gt $countloop){$collection +="$char"+'.'}
        if($totalCharinString -eq $countloop){$collection +="$char"}
         $countloop++
    }
    $collection
}

function Get-UDFIndexBlocks{
    [CmdletBinding()]
    param (
        [switch]$StopWatchOn,
        [switch]$LoggingOn,
        [int]$RequestLimit = 5
    )
    begin {
        # default params are controlled in the DefaultParams Function
        # stop start if param given
        $FunctionName       = $MyInvocation.MyCommand.name

        
        $refDate = New-UDFSQLLogIndex -processName $FunctionName -refDateTime

        if($StopWatchOn){$StopWatch = [System.Diagnostics.Stopwatch]::new();   $StopWatch.Start()}

        $Span              = @{}
        $Span.offSet       = 0
        $Span.day          = New-TimeSpan -Days 1
        $Span.inBlocks     = $Span.day.TotalSeconds/15
        $rootObject        = [ordered]@{}
        $rootObject.blocks = New-Object System.Collections.Generic.List[pscustomobject]
        $TimeSegment       = @{}
        $TimeSegment.Start = @{}
        $TimeSegment.End   = @{}
        
        $DateTimeProps                             = @{}
        $DateTimeProps.seedWeekDay                 = @{}
        $DateTimeProps.seedWeekDay.Props           = @{}
        $DateTimeProps.dateFormat                  = "yyyy-MM-dd 00:00:00.00"
        $DateTimeProps.dateTimeSeed                = ([DateTime]((Get-Date).AddDays($Span.offSet)).ToString($DateTimeProps.dateFormat )).ToString($DateTimeProps.dateFormat)
        $DateTimeProps.seedWeekDay.Props.shortName = ([DateTime]$DateTimeProps.dateTimeSeed).toString('ddd')
        $DateTimeProps.seedWeekDay.Props.ASCII    = Convertto-UDFASCII -string $DateTimeProps.seedWeekDay.Props.shortName
        $DateTimeProps.seedWeekofYear              = Get-UDFWeekofYear -date ([DateTime]$DateTimeProps.dateTimeSeed)
        $DateTimeProps.seedMonth                   = [int]([DateTime]$DateTimeProps.dateTimeSeed).Month
        $DateTimeProps.seedDayofMonth              = [int]([DateTime]$DateTimeProps.dateTimeSeed).Day
        $DateTimeProps.seedDayofYear               = ([DateTime]$DateTimeProps.dateTimeSeed).DayOfYear
        $DateTimeProps.seedYear                    = ([DateTime]$DateTimeProps.dateTimeSeed).Year
        # state
        if($LoggingOn){
            $subStringDate = ($DateTimeProps.dateTimeSeed).substring(0,10)
            $logParams = @{
              SQL                       = $true
              Message                   = "Indexing date: {0}" -f $subStringDate
              refDate                   = $refDate
              DateTimeEvent             = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
              ElapsedTime_Milliseconds  = $StopWatch.Elapsed.TotalMilliseconds
              FunctionName              = $FunctionName
              StepID                    = 1
              FunctionStep              = 'Initializing varaiables'
              Level                     = 'Information'
              Server                    = "MST3K\DEVINSTANCE"
              Database                  = "CWDB"
              Table                     = "Logging"
            }
          Write-Log @logParams | Out-Null
        }
    }
    process {
        foreach($i in (1..($Span.inBlocks))){
            if($i -eq 1)    {$Start = [datetime]$DateTimeProps.dateTimeSeed}
            if(!($i -eq 1)) {$Start = $End}
            $Span.block = New-TimeSpan -Seconds 15
            $End        = $Start.AddSeconds($Span.block.seconds)
        
            if($Start.Second -eq 0)  {$SpanID = '01'}
            if($Start.Second -eq 15) {$SpanID = '02'}
            if($Start.Second -eq 30) {$SpanID = '03'}
            if($Start.Second -eq 45) {$SpanID = '04'}
        
            $TimeSegment.Start.hour   = $Start.Hour
            $TimeSegment.Start.minute = $Start.Minute
            $TimeSegment.Start.second = $Start.Second
            $TimeSegment.End.hour     = $end.Hour
            $TimeSegment.End.minute   = $end.Minute
            $TimeSegment.End.second   = $end.Second
        
            #weekofYear
            $woyID = $($DateTimeProps.seedWeekofYear)
            if($woyID -le [int](('1'+'0')- 1)) {$woyID = "0"+"$($woyID)"}
            if($woyID -ge [int](('1'+'0')))    {$woyID = $woyID = $woyID}
        
            #daynameID
            $nameDayID = $DateTimeProps.seedWeekDay.Props.shortName
            if($nameDayID  -match  'MON') {$dayID = '1'}
            if($nameDayID  -match  'TUE') {$dayID = '2'}
            if($nameDayID  -match  'WED') {$dayID = '3'}
            if($nameDayID  -match  'THU') {$dayID = '4'}
            if($nameDayID  -match  'FRI') {$dayID = '5'}
            if($nameDayID  -match  'SAT') {$dayID = '6'}
            if($nameDayID  -match  'SUN') {$dayID = '7'}
        
            #daytype
            if($dayID -le 5)  {$dayTypeID = 'weekday'}
            if($dayID -ge 6)  {$dayTypeID = 'weekend'}
            $dayID = "0$dayID"
        
            $hrID = $TimeSegment.Start.hour
            $mnID = $TimeSegment.Start.minute
            $snID = $TimeSegment.Start.second
            if($hrID -le 9) {$hrID = "0$hrID"}
            if($mnID -le 9) {$mnID = "0$mnID"}
            if($snID -le 9) {$snID = "0$snID"}
        
            #yearID
            $yearID = $DateTimeProps.seedYear
        
            #dayofYearID
            $doyID = $DateTimeProps.seedDayofYear 
            if($doyID -le 9)                    {$doyID = "00$($doyID)"}
            if($doyID -gt 9 -and $doyID -le 99) {$doyID = "0$($doyID)"}
            if($doyID -ge 100)                  {$doyID = "$($doyID)"}
        
            #SegmentID
            $SegmentID = $i
        
            # monthID
            $monthID = $DateTimeProps.seedMonth
            if($monthID -le [int](('1'+'0')- 1))    {$monthID = "0"+"$($monthID)"}
            if($monthID -ge [int](('1'+'0')))       {$monthID = $monthID}
        
            # dayofMonthID # test
            $domID = $DateTimeProps.seedDayofMonth
            if($domID -le [int](('1'+'0')- 1))  {$domID = "$('0'+$domID)"}
            if($domID -ge [int](('1'+'0')))     {$domID = $domID}
        
            $dowConvertedIDArray = ($DateTimeProps.seedWeekDay.Props.ASCII).Split('.')
            $dowID = $null
            $dowConvertedIDArray | ForEach-Object{
                $x = [int]$_
                if($x -le [int](('1'+'00')- 1))    {$x = "0"+"$($x)"}
                if($x -ge [int](('1'+'00')- 1))    {$x = "$($x)"}
                $dowID += $x
            }
           
            $RawData = "'$($RequestLimit)','$($SegmentID)','$($SpanID)','$($snID)','$($yearID)','$($monthID)','$($woyID)','$($doyID)','$($domID)','$($dayID)','$($hrID)','$($mnID)','$($Start.ToString("yyyy-MM-dd HH:mm:ss.00"))','$( $End.ToString("yyyy-MM-dd HH:mm:ss.00"))','$($($nameDayID))','$($dowID)','$($dayTypeID)'"
            $rootObject.blocks+= @{
                "$SegmentID" = @{
                   'ObjectParams' = [ordered]@{
                        RequestCounter = $($RequestLimit)
                        SegmentID      = $($SegmentID)
                        SpanID         = $($SpanID)
                        SecondofMin    = $($snID)
                        YearID         = $($yearID)
                        MonthofYear    = $($monthID)
                        WeekofYear     = $($woyID)
                        DayofYear      = $($doyID)
                        DayofMonth     = $($domID)
                        DayofWeek      = $($dayID)
                        HourofDay      = $($hrID)
                        MinuteofHr     = $($mnID)
                        StartofSpan    = $Start.ToString("yyyy-MM-dd HH:mm:ss.00")
                        EndtofSpan     = $End.ToString("yyyy-MM-dd HH:mm:ss.00")
                        DayofWeekName  = $($nameDayID)
                        DayofWeekAscii = $($dowID)
                        WeekDayDesc    = $($dayTypeID)
                   }
                CSV = @($RawData)
               }
            }
        }
    }
    end {
        if($StopWatchOn){
            if($LoggingOn){
                $logParams = @{
                  SQL                       = $true
                  Message                   = "Parsing complete" -f $DateTimeProps.dateTimeSeed
                  refDate                   = $refDate
                  DateTimeEvent             = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
                  ElapsedTime_Milliseconds  = $StopWatch.Elapsed.TotalMilliseconds
                  FunctionName              = $FunctionName
                  StepID                    = 2
                  FunctionStep              = 'Parsing'
                  Level                     = 'Information'
                  Server                    = "MST3K\DEVINSTANCE"
                  Database                  = "CWDB"
                  Table                     = "Logging"
                }
                Write-Log @logParams | Out-Null
            }
            $StopWatch.stop()
        }
        $rootObject | out-null
    }
}


$credentials = Get-UDFStoredCredential -Name "SQLSERVER_SA"

$PSDefaultParameterValues = @{
    'Invoke-UDFSqlConnection:UserName' = $credentials.UserName
    'Invoke-UDFSqlConnection:PassWord' = $credentials.PassWord
}

Get-UDFIndexBlocks -StopWatchOn -LoggingOn