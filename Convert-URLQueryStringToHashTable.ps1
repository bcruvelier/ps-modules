Function Convert-URLQueryStringToHashTable {
	<#
	.SYNOPSIS
		Convertit la query string d'une URL en hashtable
	.DESCRIPTION
		Récupère la querystring d'une url (partie après le ?) puis stocke dans un tableau chaque élément (nom et valeur)
	.PARAMETER Url
		Url à traiter
	.OUTPUTS
		System.Collections.Hashtable
	.EXAMPLE
		Convert-URLQueryStringToHashTable -Url 'https://mydomain.com/login.aspx?id=12345&name=myname&redirect=index.htm'
		
		Name                           Value
		----                           -----
		id                             12345
		redirect                       index.htm
		name                           myname
			
		Récupère un tableau contenant les noms et valeurs présentes dans la querystring
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,HelpMessage="Url")]
			[ValidateNotNullOrEmpty()]
			[string]$Url
	)
	try{
		$QueryString = $Url.Split('?')[1]
		if(-not $QueryString){ Return $null }
		$QueryStringSplit = $QueryString.Split('&')
		$QueryStringHashTable = ConvertFrom-StringData $($QueryStringSplit -join "`r`n" | Out-String)
		Return $QueryStringHashTable
	}catch{
		throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}
}
