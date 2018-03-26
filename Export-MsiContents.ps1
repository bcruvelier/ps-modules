Function Export-MsiContents {
	<#
	.SYNOPSIS
		Extrait les fichiers d'un msi
	.DESCRIPTION
		Renvoit le chemin du répertoire contenant les fichiers extraits
	.PARAMETER MsiPath
		Chemin du msi
	.PARAMETER TargetDirectory
		Répertoire ou seront placés les fichiers extraits
		Valeur par défaut : Dossier dans lequele se trouve le msi
		Dans tous les cas, un répertoire du nom du msi est crée dans le répertoire précisé
	.INPUTS
	.OUTPUTS
		System.String
	.EXAMPLE
		Export-MsiContents -MsiPath 'D:\DACFramework.msi'
	.EXAMPLE
		Export-MsiContents -MsiPath 'D:\Test\DACFramework.msi' -TargetDirectory 'D:\MsiExtract'
	.NOTES
	.LINK
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,HelpMessage="Chemin du msi")][ValidateNotNullOrEmpty()]
			[ValidateScript({Test-Path $_ -PathType Leaf})]
			[ValidateScript({$_.EndsWith(".msi")})]
			[string]$MsiPath,
		
		[Parameter(Mandatory=$false,HelpMessage="Dossier de destination")]
			[string]$TargetDirectory
	)
	try{
		$MsiDir = [System.IO.Path]::GetDirectoryName($MsiPath)
		$SubFolderName = [System.IO.Path]::GetFileNameWithoutExtension($MsiPath)
				
		if($TargetDirectory){
			$FinalFolder = Join-Path -Path $TargetDirectory -ChildPath $SubFolderName
			if(-not (Test-Path $TargetDirectory)){
				$null = New-Item -Path $TargetDirectory -ItemType Directory
			}
		}else{
			$FinalFolder = Join-Path -Path $MsiDir -ChildPath $SubFolderName
		}
		if(-not (Test-Path $FinalFolder)){
			$null = New-Item -Path $FinalFolder -ItemType Directory
		}
		
		$MsiPath = Resolve-Path $MsiPath
		$ExportResult = Start-CEGIDProcess -Exe "MSIEXEC" -Parameters "/a $MsiPath /qn TARGETDIR=$FinalFolder"
		if($ExportResult -ne 0){
			throw "Erreur lors de l'extraction du contenu du msi (code retour : $ExportResult)"
		}
		Return $FinalFolder
	}catch{
		Throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}
}
