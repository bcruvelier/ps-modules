Function Compress-Item {
	<# 
	.SYNOPSIS
		Compresse un fichier/répertoire
	.DESCRIPTION
		Compresse un fichier/répertoire avec possibilité de paramétrer un mot de passe ou de splitter les fichiers selon une taille préfédinie.
		Renvoit la liste de la ou des archive(s) générée(s)
	.PARAMETER FilePath
		Chemin du fichier/répertoire à compresser
	.PARAMETER SplitSize
		Taille des fichiers splités (en Mo).
		Valeur par défaut : Le fichier ne sera pas splitté
	.PARAMETER Password
		Mot de passe de l'archive qui sera créée (caractères alphanumérique uniquement)
		Valeur par défaut : Aucun mot de passe
	.PARAMETER ZipName
		Nom de l'archive qui sera créée
		Valeur par défaut : Nom du fichier/répertoire
	.PARAMETER ZipPath
		Répertoire ou sera créée l'archive
		Valeur par défaut : Même dossier que fichier/répertoire à compresser
	.PARAMTER CompressionLevel
		Niveau de compression de l'archive
		Valeurs autorisées : 0, 1, 3, 5, 7, 9
		Valeur par défaut : 5
	.INPUTS
	.OUTPUTS
		System.IO.FileInfo
	.EXAMPLE
		Compress-Item -FilePath 'D:\Test'
		Compresse le répertoire D:\Test vers D:\Test.zip
	.EXAMPLE
		Compress-Item -FilePath 'D:\Test' -Password 'MyPass123' -SplitSize 2 -ZipName 'MyZip' -CompressionLevel 0
		Compresse le répertoire D:\Test en fichiers de 2Mo nommés MyZip.zip.00x sans compression avec le mot de passe d'archive MyPass123
	.NOTES
		7-Zip doit être accessible sous Program Files\7-Zip\7z.exe
	.LINK
		https://sevenzip.osdn.jp/chm/cmdline/switches/method.htm
	#>
	param(
		[Parameter(Mandatory=$true,Position=0,HelpMessage="Fichier/Répertoire à compresser")]
			[ValidateScript({Test-Path $_})]
			[string]$FilePath,
		
		[Parameter(Mandatory=$false,Position=1,HelpMessage="Taille de chaque split (en Mo)")]
			[string]$SplitSize = '',
		
		[Parameter(Mandatory=$false,Position=2,HelpMessage="Mot de passe de l'archive")]
			[string]$Password = '',
		
		[Parameter(Mandatory=$false,Position=3,HelpMessage="Nom de l'archive")]
			[string]$ZipName = '',
		
		[Parameter(Mandatory=$false,Position=4,HelpMessage="Chemin de l'archive")]
			[ValidateScript({Test-Path $_ -PathType Container})][string]$ZipPath = '',
		
		[Parameter(Mandatory=$false,Position=5,HelpMessage="Niveau de compression")]
			[ValidateSet('0','1','3','5','7','9')]
			[int]$CompressionLevel = 5,
		
			[switch]$Overwrite
		)
	try{
		if( -not(test-path "$env:ProgramFiles\7-Zip\7z.exe") ){
			throw "$env:ProgramFiles\7-Zip\7z.exe needed"
		}
		Set-Alias sz "$env:ProgramFiles\7-Zip\7z.exe"
		
		#region < Validation des paramètres >
		$FileDir 	= Split-Path $FilePath -Parent
		$FileName 	= Split-Path $FilePath -Leaf
	
		if($ZipName -eq ''){
			$FinalZipName = "${FileName}.zip"
		}else{
			if( $ZipName.EndsWith('.zip') ){ # On ajoute .zip si l'extension n'a pas été fournie dans le paramètre
				$FinalZipName = "${ZipName}"
			}else{
				$FinalZipName = "${ZipName}.zip"
			}
		}

		if($ZipPath -eq ""){ $FinalZipPath = "$FileDir\$FinalZipName" }
		else{ $FinalZipPath = "$ZipPath\$FinalZipName" }

		if($Password -ne ""){
			if($Password -match '[^a-zA-Z0-9]'){
				throw "Password must contain only alphanumeric characters"
			}
			$PasswordParam = "-p$Password"
		}else{ $PasswordParam = "" }
		
		if($SplitSize -ne ""){ $SplitSizeParam = "-v${SplitSize}m" }
		else{ $SplitSizeParam = "" }
		
		if(Test-Path $FinalZipPath -PathType Leaf){
			if($Overwrite){
				Remove-Item -Path $FinalZipPath -Force
			}else{
				throw "Le fichier $FinalZipPath existe déjà"
			}
		}
		#endregion
		
		#region < Création de l'archive >
		$SZParameters = @("a","-tzip",$SplitSizeParam,"-mx=${CompressionLevel}",$FinalZipPath,$FilePath,"$PasswordParam")
		$CreateZipResult = & sz $SZParameters
		if($CreateZipResult -icontains "Everything is Ok"){
	   		if($SplitSize -eq ''){
				$Return = Get-Item $FinalZipPath
			}else{
				$Return = Get-ChildItem "${FinalZipPath}.0*"
			}
			Return $Return
		}else{
			throw "Erreur lors de la création de l'archive : $CreateZipResult"
   		}
		#endregion
		
	}catch{
		Throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}
}
