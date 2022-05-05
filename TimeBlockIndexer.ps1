$a001   = new-timespan -Days 1
$a002   = $a001.TotalSeconds/15
$0      = [ordered]@{}
$0.1 = @{}

  $a003  = [datetime]((get-date).AddDays(236)).ToString("yyyy-MM-dd 00:00:00.00")
  $a00301 = $a003.DayOfYear
  $a00302 = $a003.Year
  $a00303 = $a003.Month
  $a00304 = $a003.toString('ddd').toupper()
foreach($c in (1..($a002))){

    if($c -eq 1){$c001 = $a003}
    else{$c001 = $c002}
    $s0001 = New-TimeSpan -Seconds 15
    $c002   = $c001.AddSeconds($s0001.TotalSeconds)
    if($c001.Second -eq 0){$C0101 = '01'}
    if($c001.Second -eq 15){$C0101 = '02'}
    if($c001.Second -eq 30){$C0101 = '03'}
    if($c001.Second -eq 45){$C0101 = '04'}
    $ca = $c001.hour
    $cb = $c001.Minute
    $cd = $c001.Second

    if($a00304 -match 'MON')    {$c04  =  '01'}
    if($a00304 -match 'MON')    {$c041 = 'StartofWeek'}
    if($a00304 -match 'TUE')    {$c04  =  '02'}
    if($a00304 -match 'WED')    {$c04  =  '03'}
    if($a00304 -match 'THU')    {$c04  =  '04'}
    if($a00304 -match 'FRI')    {$c04  =  '05'}
    if($a00304 -match 'SAT')    {$c04  =  '06'}
    if($a00304 -match 'SUN')    {$c04  =  '07'}
    if($a00304 -match 'SAT')    {$c042 = 'WND'}
    if($a00304 -match 'SUN')    {$c042 = 'WND'}
    if(!($a00304 -match 'SAT')) {$c042 = 'WDY'}
    if(!($a00304 -match 'SUN')) {$c042 = 'WDY'}
    $c02 ='|'
    if($ca -le 9) {$ca = "0$ca"}
    if($cb -le 9) {$cb = "0$cb"}
    if($cd -le 9) {$cd = "0$cd"}

    if($a00303 -le 9)                           {$_03 = "0"+"$a00303"}
    if($a00303 -ge 9)                           {$_03 = $a00303}

    if($a00301 -le 9)                           {$_01 = "00$a00301"}
    if($a00301 -gt 9 -and $a00301 -le 99)           {$_01 = "0$a00301"}
    if($a00301 -ge 100)                         {$_01 = "$a00301"}

    if($c -le 9)                            {$c01 = [int]"00000000$c"}
    if($c -gt 9 -and $c -le 99)             {$c01 = [int]"0000000$c"}
    if($c -ge 100 -and $c -le 999)          {$c01 = [int]"000000$c"}
    if($c -ge 1000 -and $c -le 9999)        {$c01 = [int]"00000$c"}
    if($c -ge 10000 -and $c -le 99999)      {$c01 = [int]"0000$c"}
    if($c -ge 100000 -and $c -le 999999)    {$c01 = [int]"000$c"}
    if($c -ge 1000000 -and $c -le 9999999)  {$c01 = [int]"00$c"}
    if($c -ge 10000000 -and $c -le 99999999){$c01 = [int]"0$c"}
    if($c -ge 100000000)                    {$c01 = [int]$c}
    #"$6-$C0101-$c-$a00302-$a00303-$3-$a00301-$ca-$cb-$cd"
    $0.'1'.add($c01,@{})
    $0.'1'.$c01.add(1,"$c042$c02$a00304$c02$C0101$c02$c01$c02$a00302$c02$_03$c02$c04$c02$_01$c02$ca$c02$cb$c02$cd")
    $0.'1'.$c01.add(2,$c001)
    $0.'1'.$c01.add(3,$s0001)
    $0.'1'.$c01.add(4,$c002)
    #$obj.block[$c].end
}

($0.'1'[000004892])[1]



$asciitochar   = @{}
$chartoascii   = @{}
$asciitobinary =@{}
97..122 | ForEach-Object {$asciitochar.add($_,([char]$_).toString())}
foreach($k in $asciitochar.keys){$chartoascii.add($asciitochar[$k],$k)}
foreach($k in $asciitochar.keys){$asciitobinary.add($k,[convert]::ToString($k,2))}

 $ascii = [ordered]@{}
0..122 | ForEach-Object {
    $int   = [int]$_
    $ascii = ([char]$int)
    [convert]::ToString($int,2)
}
$string = 'SUN'
$string = $string.ToCharArray() |%{$chartoascii["$_"]}
[convert]::ToString($string[0],2)
$string |%{$ascii[$_]}


