Function Convert-LocalToUncPath {
	<# 
	.SYNOPSIS
		Convertit un chemin local en chemin UNC.
	.DESCRIPTION
    	Renvoit le chemin UNC
	.PARAMETER LocalPath
		Chemin Local à convertir. 
	.PARAMETER Server
		Serveur
	.INPUTS
	.OUTPUTS
		System.String
	.EXAMPLE
		Convert-LocalToUncPath -LocalPath "C:\ProgramData\Cegid" -Server "S119700IIS001"
		Convertit le chemin C:\ProgramData\Cegid en chemin UNC : \\S119700IIS001\C$\ProgramData\Cegid
	.NOTES
	.LINK
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,Position=0,HelpMessage="Chemin local")]
			[ValidateNotNullOrEmpty()]
			[string]$LocalPath,
		
		[parameter(Mandatory=$true,Position=1,HelpMessage="Serveur")]
			[ValidateNotNullOrEmpty()]
			[string]$Server
	)
	try{
		if(([Uri]$LocalPath).IsUnc){
			throw "Le chemin `"$LocalPath`" est déjà UNC"
		}
		if(-not(Split-Path -Path $localPath -IsAbsolute)){
			throw "Chemin relatif interdit"
		}
		$drive = Split-Path -Path $localPath -Qualifier
		$path = Split-Path -Path $localPath -noQualifier
		$UNCPath = "\\$Server\$($drive.Replace(':','$'))$path"
		Return $UNCPath
	}catch{
		Throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}
}
