(Get-Location | Get-ChildItem -filter '*.ps1' -Recurse) | Select-Object 'FullName' | ForEach-Object {. $_.FullName} 