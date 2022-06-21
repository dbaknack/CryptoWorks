. ./Get-UDFWeekofYear.ps1
. ./Convertto-UDFASCII.ps1
. ./Get-UDFIndexBlocks.ps1
. ./Get-StoredCredential.ps1
. ./Invoke-SqlConnection.ps1
. ./Write-log.ps1
. ./New-UDFSQLLogIndex.ps1

$credentials    = Get-StoredCredential -Name sqlserver

New-UDFSQLLogIndex