. ./Get-UDFWeekofYear.ps1
. ./Create-BinaryIndex.ps1

$Span             = @{}
$Span.offSet      = 0
$Span.day         = New-TimeSpan -Days 1
$Span.inBlocks    = $Span.day/15
$rootObject       = [ordered]@{}
$rootObject.block = [ordered]@{}
$rootObject.block.ID = [ordered]@{}

$TimeSegment       = @{}
$TimeSegment.Start = @{}
$TimeSegment.End   = @{}

$DateTimeProps                             = @{}
$DateTimeProps.seedWeekDay                 = @{}
$DateTimeProps.seedWeekDay.Props           = @{}
$DateTimeProps.dateFromat                  = "yyyy-MM-dd 00:00:00.00"
$DateTimeProps.dateTimeSeed                = ([DateTime]((Get-Date).AddDays($Span.offSet)).ToString($DateTimeProps.dateFromat )).ToString($DateTimeProps.dateFromat)
$DateTimeProps.seedWeekDay.Props.shortName = ([DateTime]$DateTimeProps.dateTimeSeed).toString('ddd')
$DateTimeProps.seedWeekDay.Props.Binary    = Create-BinaryIndex -string $DateTimeProps.seedWeekDay.Props.shortName
$DateTimeProps.seedWeekofYear              = Get-UDFWeekofYear -date ([DateTime]$DateTimeProps.dateTimeSeed)
$DateTimeProps.seedMonth                   = [int]([DateTime]$DateTimeProps.dateTimeSeed).Month
$DateTimeProps.seedDayofMonth              = [int]([DateTime]$DateTimeProps.dateTimeSeed).Day
$DateTimeProps.seedDayofYear               = ([DateTime]$DateTimeProps.dateTimeSeed).DayOfYear
$DateTimeProps.seedYear                    = ([DateTime]$DateTimeProps.dateTimeSeed).Year

foreach($i in (1..($Span.inBlocks.TotalSeconds))){
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

    # BlockID
    if($i -le [int]('1'+'0')-1)                          {$blockID = "$('0'*8)$i"}
    if($i -ge [int]('1'+'0'*1) -and $i -le [int]('9'*2)) {$blockID = "$('0'*7)$i"}
    if($i -ge [int]('1'+'0'*2) -and $i -le [int]('9'*3)) {$blockID = "$('0'*6)$i"}
    if($i -ge [int]('1'+'0'*3) -and $i -le [int]('9'*4)) {$blockID = "$('0'*5)$i"}
    if($i -ge [int]('1'+'0'*4) -and $i -le [int]('9'*5)) {$blockID = "$('0'*4)$i"}
    if($i -ge [int]('1'+'0'*5) -and $i -le [int]('9'*6)) {$blockID = "$('0'*3)$i"}
    if($i -ge [int]('1'+'0'*6) -and $i -le [int]('9'*7)) {$blockID = "$('0'*2)$i"}
    if($i -ge [int]('1'+'0'*7) -and $i -le [int]('9'*9)) {$blockID = "$('0'*1)$i"}
    if($i -ge [int]('1'+'0'*8))                          {$blockID = $i}

    # monthID
    $monthID = $DateTimeProps.seedMonth
    if($monthID -le [int](('1'+'0')- 1))    {$monthID = "0"+"$($monthID)"}
    if($monthID -ge [int](('1'+'0')))       {$monthID = $monthID}

    # dayofMonthID
    $domID = $DateTimeProps.seedDayofMonth
    if($domID -le [int](('1'+'0')- 1))  {$domID = "$('0'+$domID)"}
    if($domID -ge [int](('1'+'0')))     {$domID = $domID}

    $dowConvertedIDArray = ($DateTimeProps.seedWeekDay.Props.Binary).Split('.')
    $dowID = $null
    $dowConvertedIDArray | foreach{
        $x = [int]$_
        if($x -le [int](('1'+'00')- 1))    {$x = "0"+"$($x)"}
        if($x -ge [int](('1'+'00')- 1))    {$x = "$($x)"}
        $dowID += $x
    }

    $globalID = "$($SpanID)$($snID)$($yearID)$($monthID)$($woyID)$($doyID)$($domID)$($dayID)$($hrID)$($weekdayconverted)$($minID)$($blockID)"

    $rootObject.block.ID+= @{
       "$blockID" = @{
           'parameters' = [ordered]@{
                SpanID            = $($SpanID)
                SecondofMin       = $($snID)
                GlobalID          = $($globalID)
                Year              = $($yearID)
                MonthofYear       = $($monthID)
                WeekofYear        = $($woyID)
                DayofYear         = $($doyID)
                DayofMonth        = $($domID)
                DayofWeek         = $($dayID)
                HourofDay         = $($hrID)
                MinuteofHr        = $($mnID)
                StartofSpan       = $Start.ToString("yyyy-MM-dd HH:mm:ss.00")
                EndtofSpan        = $End.ToString("yyyy-MM-dd HH:mm:ss.00")  
                DayofWeekName     = $($nameDayID)
                DayofWeekAscii    = $($dowID)
                WeekDayDesc       = $($dayTypeID)
                BlockID           = $($blockID)
           }
       }
    }
    $rootObject.block.ID[$blockID].StartofSpan  = $Start.ToString("yyyy-MM-dd HH:mm:ss.00")                                   
    $rootObject.block.ID[$blockID].EndofSpan    = $End.ToString("yyyy-MM-dd HH:mm:ss.00")
}