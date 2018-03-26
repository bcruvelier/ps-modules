Function Approve-EmailAddress {
	<# 
	.SYNOPSIS
		Valide le format d'une adresse mail (xxx@yyy.zzz)
	.DESCRIPTION
		Renvoit $true si l'adresse est valide, $false sinon
	.PARAMETER Email
		Adresse mail à valider
	.INPUTS
	.OUTPUTS
		System.Boolean
	.EXAMPLE
		Approve-EmailAddress -Email 'jsmith@contoso.com'
		Valide l'email jsmith@contoso.com
	.NOTES
	.LINK
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,HelpMessage="Email à valider",Position=0)][ValidateNotNullOrEmpty()][String]$Email
	)
	try{
		$Regex = "^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,10})$"
		if($Email -match $Regex){
			return $true
		}else{
			return $false
		}
	}catch{
		Throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}
}
