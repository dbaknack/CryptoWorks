$PSDefaultParameterValues.clear()


$PSDefaultParameterValues = @{
    'Invoke-SqlConnection:InstanceName' = "MST3K\DEVINSTANCE"
    'Invoke-SqlConnection:DatabaseName' = 'CWDB'
    'Invoke-SqlConnection:Table'        = 'LogLookUp'
}

$PSDefaultParameterValues = @{
    'Invoke-SqlConnection:InstanceName' = "MST3K\DEVINSTANCE"
    'Invoke-SqlConnection:DatabaseName' = 'CWDB'
    'Invoke-SqlConnection:Table'        = 'LogLookUp'
}

## Logging
Write-Log -Message 'test'


Write-Log -Message "$($MyInvocation.MyCommand)"
Write-Log "Second Message" -Level "Warning"
Write-Log "Third Message" -NoHost -File
Write-Log "Fourth Message" -SQL -Server "SQLServer" -Database "Logging" -Table "Logs"
Write-Log "Fifth Message" -Level "Error" -File -Path .\LOG\



