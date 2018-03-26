Function New-DummyFile {
	<#
	.Synopsis
		Creates a dummy file with or without random conntent
	.DESCRIPTION
		Creates a dummy file with or without random conntent 
		Credits for the randome content creation logic goes to Robert Robelo
	.PARAMETER Target
		The full path to a folder or file. If the target is a folder a random file name is generated
	.PARAMETER MegaByte
		The size of the random file to be genrated. Default is one MB
	.PARAMETER Filecontent
	    Possible values are <random> or <empty> When <random> is specified the file is filled with random values.
		The value <empty> fills the file with nulls. 
	.PARAMETER ShowProgress
		This parameter is optional and shows the progress of the file creation. 
	.EXAMPLE
		New-DummyFile -Target D:\DummyFile.txt -Megabyte 10 -Filecontent empty
		Crée un fichier vide de 10Mo 
	.EXAMPLE
		New-DummyFile -Target D:\DummyFile.txt -Megabyte 100 -Filecontent random -ShowProgress
		Crée un fichier au contenu aléatoire de 100Mo en affichant la progression
	#>
	[CmdletBinding()]
	param(
	    [Parameter(Mandatory=$true,Position=0)]
	        [String]$Target,
	    [Parameter(Mandatory=$false,Position=1)][ValidateRange(1, 10240)]
	        [UInt16]$MegaByte = 1,
	    [Parameter(Mandatory = $true,position=2)][ValidateSet("random","empty")]
	        [String]$FileContent,
	    [Switch]$ShowProgress
	)
    try{
		if(Test-Path -Path $Target -PathType 'Container'){
    		Write-Verbose "Provided input $Target is a folder"
    		$FileName = "$([guid]::NewGuid()).LF"
    		Write-Verbose "Random generated filename: $FileName"
    		$Target = Join-Path -Path $Target -ChildPath $FileName
    		$Folder = [System.IO.Path]::GetDirectoryName($Target)
		}
		if(Test-path -Path $Target){
			throw "File $Target already exists"
		}
		$TotalSize = 1mb * $MegaByte
		$strings = $bytes = 0
		
		if($FileContent -eq "random"){
			$Sw = New-Object IO.streamWriter $Target # create the stream writer
			
			# get a 64 element Char[]; I added the - and _ to have 64 chars
			[char[]]$chars = 'azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN0123456789-_'
			1..$MegaByte | ForEach-Object {
				1..4 | ForEach-Object { # get 1MB of chars from 4 256KB strings
					$rndChars = $chars | Get-Random -Count $chars.Count # randomize all chars and...
					$str = -join $rndChars # ...join them in a string
					$str_ = $str * 4kb # repeat random string 4096 times to get a 256KB string
					$sw.Write($str_) # write 256KB string to file
		    	
					if($ShowProgress) {
			    		$strings++
			    		$bytes += $str_.Length
			    		Write-Progress -Activity "Writing String #$strings" -Status "$bytes Bytes written" -PercentComplete ($bytes / $TotalSize * 100)
			    	}
					Clear-Variable str, str_ # release resources by clearing string variables
				}
			}
		}else{
		    $bufSize = 4096 # write 4K worth of data at a time
			$bytes = New-Object byte[] $bufSize
    		$file = [System.IO.File]::Create("$Target")
    		
			$file.Write($bytes, 0, $bufSize) # write the first block out to accommodate integer division truncation
			for($i = 0; $i -lt $Megabyte*1MB; $i = $i + $bufSize){
				$file.Write($bytes, 0, $bufSize) 
				if($ShowProgress) {
		        	Write-Progress -Activity "Writing String #$strings" -Status "Bytes written" -PercentComplete ($i/($megabyte*1MB)*100 )
		    	}
    		}
    		
		} 
	}catch{
		throw "Appel de la fonction $($MyInvocation.MyCommand) en erreur : $_"
	}finally{
		if($Sw){
			$sw.Close()
			$sw.Dispose()
			[GC]::Collect() # release resources through garbage collection
		}
		if($file){ $file.Close() }
	}
}
