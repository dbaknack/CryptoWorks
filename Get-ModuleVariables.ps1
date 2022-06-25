function Get-ModuleVariables{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('DateFormat','FunctionName')]
        [string]$var,
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,22)]
        [string]$DateFormat
    )
    process{
        switch($var){
            'DateFormat'    {$requestedVariable = $DateFormat}
            'FunctionName'  {$requestedVariable = '{4}'}
            default{
                $noMatch = $true
                'not sure what varaible you are needing'}
        }
    }
    end{
        if($noMatch){
            return -1
        }
        $requestedVariable; return
    }
}