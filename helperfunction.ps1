Function logging-test{
[CmdletBinding()]
    param (
        [int]$ElapsedMilliseconds
    )
}

logging-test -timing 

$stopwatch = [System.Diagnostics.Stopwatch]::new()

$stopwatch.start()

$stopwatch.Stop()