Function Get-MSIFileInformation {
	<#
	.SYNOPSIS
		Récupère les propriétés (ProductCode, ProductVersion, ProductName, Manufacturer et ProductLanguage) d'un msi
	.DESCRIPTION
	.PARAMETER Path
		Chemin du msi
	.INPUTS
	.OUTPUTS
		Hashtable avec les valeurs
		$_ : Erreur
	.EXAMPLE
		Get-MSIFileInformation -Path 'C:\DACFramework.msi'
			Name                           Value
			----                           -----
			ProductLanguage                1033
			Manufacturer                   Microsoft Corporation
			ProductCode                    {77F305A4-0997-409C-B746-47946FCBB1B6}
			MsiName                        DACFramework.msi
			ProductName                    Microsoft SQL Server Data-Tier Application Framework
			ProductVersion                 12.0.1295.0
		Récupère les propriétés du msi DACFramework.msi
	.EXAMPLE
		(Get-MSIFileInformation -Path 'C:\DACFramework.msi').ProductVersion
			12.0.1295.0
		Récupère la propriété ProductVersion du msi DACFramework.msi
	.NOTES
	.LINK
	#>
	param(
		[parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$Path
	)
	process{
		try{
			$Properties = @("ProductCode", "ProductVersion", "ProductName", "Manufacturer", "ProductLanguage")
			$Result = @{}
			$Result.Add('MsiName',$Path.Name)
			
			# Read property from MSI database
			$WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
			$MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstaller, @($Path.FullName, 0))
			foreach($Property in $Properties){
				$Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
				$View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($Query))
				$View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
				$Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
				$Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)
				$Result.Add($Property,$Value)
			}
			# Commit database and close view
			$MSIDatabase.GetType().InvokeMember("Commit", "InvokeMethod", $null, $MSIDatabase, $null)
			$View.GetType().InvokeMember("Close", "InvokeMethod", $null, $View, $null)           
			$MSIDatabase = $null
			$View = $null
			
			# Return the value
			return $Result
		}catch{
			Throw $_.Exception.Message
		}
	}end{
		# Run garbage collection and release ComObject
		[System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller) | Out-Null
		[System.GC]::Collect()
	}
}
