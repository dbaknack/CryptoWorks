function Get-ModuleVariables{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)][ValidateSet('DateFormat','FunctionName')][string]$var,
        [Parameter(Mandatory = $true)][ValidateLength(1,22)][string]$DateFormat
    )
    process{
        switch($var){
            'DateFormat'    { $noMatch = $false; $requestedVariable  = $DateFormat }
            'FunctionName'  { $noMatch = $false; $requestedVariable  = '{4}'       }
                     default{ $noMatch = $true;  $requestedVariable  = $null       }
        }
    }
    end{if($noMatch){return -1}
    $requestedVariable; return
    }
}