function Create-AsciiIndex($string){
    $asciitochar   = @{}
    $ihartoascii   = @{}
    $asciitobinary = @{}
    97..122 | ForEach-Object {$asciitochar.add($_,([char]$_).toString())}
    foreach($k in $asciitochar.keys){$ihartoascii.add($asciitochar[$k],$k)}
    foreach($k in $asciitochar.keys){$asciitobinary.add($k,[convert]::ToString($k,2))}

    $collection = $null
    $countloop = 1
    $totalCharinString = ($string.tocharArray()).count
    $string = $string.ToCharArray() |%{$ihartoascii["$_"]}
    foreach($char in $string){
        if($totalCharinString -gt $countloop){$collection +="$char"+'.'}
        if($totalCharinString -eq $countloop){$collection +="$char"}
         $countloop++
    }
    $collection
}