. ./Get-UDFWeekofYear.ps1
. ./Convertto-UDFASCII.ps1
. ./Get-UDFIndexBlocks.ps1
. ./Get-StoredCredential.ps1
. ./Invoke-SqlConnection.ps1
$TestConnectionParams       = (Get-Content -Path "E:\Credentials\ConnectionParams\TestConnParams.json") | convertfrom-json
$InsertConnectionParams     = (Get-Content -Path "E:\Credentials\ConnectionParams\InsertConnParams.json") | convertfrom-json
$Creds                      = Get-StoredCredential -Name SQLServer001 -StorePath "E:\Credentials\ServiceAccounts"

$splatConnection = @{
    InstanceName        =   $TestConnectionParams.InstanceName
    DatabaseName        =   $TestConnectionParams.DatabaseName
    ProcessName         =   $TestConnectionParams.ProcessName
    IntegratedSecurity  =   $TestConnectionParams.Authentication.IntegratedSecurity 
    userName            =   $Creds.UserName
    Password            =   $Creds.Password
    
}

Invoke-SqlConnection @splatConnection



$ref = Get-UDFIndexBlocks
foreach($key in $ref.blocks.keys){
    $block = $ref.blocks.$key.ObjectParams
    $insertString = "
    set nocount on
    INSERT INTO [dbo].[TimeIndex](
         [RequestCounter]
        ,[SegmentID]
        ,[SpanID]
        ,[SecondofMin]
        ,[YearID]
        ,[MonthofYear]
        ,[WeekofYear]
        ,[DayofYear]
        ,[DayofMonth]
        ,[DayofWeek]
        ,[HourofDay]
        ,[MinuteofHr]
        ,[StartofSpan]
        ,[EndofSpan]
        ,[DayofWeekName]
        ,[DayofWeekAscii]
        ,[WeekDayDesc]
    )
    VALUES(
         $($block.RequestCounter)
        ,$($block.SegmentID)
        ,$($block.SpanID)
        ,$($block.SecondofMin)
        ,$($block.YearID)
        ,$($block.MonthofYear)
        ,$($block.WeekofYear)
        ,$($block.DayofYear)
        ,$($block.DayofMonth)
        ,$($block.DayofWeek)
        ,$($block.HourofDay)
        ,$($block.MinuteofHr)
        ,'$($block.StartofSpan)'
        ,'$($block.EndtofSpan)'
        ,'$($block.DayofWeekName)'
        ,$($block.DayofWeekAscii)
        ,'$($block.WeekDayDesc)'
    )"
    $splatConnection = @{
        InstanceName        =   $InsertConnectionParams.InstanceName
        DatabaseName        =   $InsertConnectionParams.DatabaseName
        ProcessName         =   $InsertConnectionParams.ProcessName
        IntegratedSecurity  =   $InsertConnectionParams.Authentication.IntegratedSecurity 
        userName            =   $Creds.UserName
        Password            =   $Creds.Password
        TSQLCommand         =   $insertString
    }
    
    Invoke-SqlConnection @splatConnection
}

