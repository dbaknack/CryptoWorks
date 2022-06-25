@{
	RootModule 		        = 'CryptoWorks.psm1' 
	ModuleVersion 		    = '1.0.0' 
	CompatiblePSEditions 	= 'Desktop', 'Core' 
	GUID 			        = 'dc18a919-f4bf-4da2-8c76-24b68fa33ef0' 
	Author 			        = 'Fake Author' 
	CompanyName 		    = 'Fake Company' 
	Copyright 		        = '(c) Fake Author. All rights reserved.' 
	Description 		    = 'UtilityModule'
	FunctionsToExport 	    = @('Write-UDFLog','Invoke-UDFSQLConnection','New-UDFSQLCommand','Get-ModuleVariables','Get-UDFStoredCredential')
	ScriptsToProcess 		= @('Get-UDFStoredCredential.ps1','Set-DefaultValues.ps1','Get-ModuleVariables.ps1')
	CmdletsToExport 	    = @() 
	VariablesToExport 	    = @() 
	AliasesToExport 	    = @() 
}