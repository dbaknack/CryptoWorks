

Get-UDFIndexBlocks -StopWatchOn

$PSDefaultParameterValues = @{
    'Get-UDFIndexBlocks:StopWatchOn'      = $true
}
$PSDefaultParameterValues.clear()


$PSDefaultParameterValues = @{
    'Write-Log:SQL'      = $true
    'Write-Log:Server'   = 'SQLServer'
    'Write-Log:Database' = 'Logging'
    'Write-Log:Table'      = 'Logs'
}

## Logging
Write-Log -Message 'test'


Write-Log -Message "$($MyInvocation.MyCommand)"
Write-Log "Second Message" -Level "Warning"
Write-Log "Third Message" -NoHost -File
Write-Log "Fourth Message" -SQL -Server "SQLServer" -Database "Logging" -Table "Logs"
Write-Log "Fifth Message" -Level "Error" -File -Path .\LOG\



