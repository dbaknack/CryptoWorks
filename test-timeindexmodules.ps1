. ./Get-UDFWeekofYear.ps1
. ./Convertto-UDFASCII.ps1
. ./Get-UDFIndexBlocks.ps1

get-item . | Select-Object * 
$ref = Get-UDFIndexBlocks
$ref.blocks.values.CSV[0]

