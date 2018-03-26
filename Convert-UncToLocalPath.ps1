Function Convert-UncToLocalPath {
	<# 
	.SYNOPSIS
		Convertit un chemin UNC en chemin local.
	.DESCRIPTION
	.PARAMETER UncPath
		Chemin Unc à convertir. 
	.INPUTS
	.OUTPUTS
		Chemin UNC
	.EXAMPLE
		Convert-UncToLocalPath -UNCPath "\\MyServer\C$\ProgramData\Microsoft"
		Convertit le chemin UNC \\MyServer\C$\ProgramData\Microsoft en chemin local : C:\ProgramData\Microsoft
	.NOTES
	.LINK
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,Position=0,HelpMessage="Chemin UNC")]
			[ValidateNotNullOrEmpty()]
			[string]$UncPath
	)
	try{
		if(-not(([Uri]$UncPath).IsUnc)){
			throw "Le chemin `"$UncPath`" n'est pas UNC"
		}
		$regex = "\\\\([a-zA-Z0-9\.\-_]{1,})\\([a-zA-Z0-9\-_]{1,}){1,}[\$]{0,1}(.{1,})"
		$ResultRegex = [regex]::Match($UncPath,$Regex)
		$drive = $ResultRegex.Groups[2].Value
		$endpath = $ResultRegex.Groups[3].Value
		$localPath = "${drive}:${endpath}"
		Return $localPath
	}catch{
		Throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}
}
