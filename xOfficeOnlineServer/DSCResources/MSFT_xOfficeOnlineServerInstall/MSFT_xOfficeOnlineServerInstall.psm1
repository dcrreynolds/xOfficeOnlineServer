function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path
	)

    $wacRegPathExist = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer
	
	$returnValue = @{
		Installed = $wacRegPathExist
		Path = $Path
	}

	$returnValue	
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path
	)

    Start-Process -FilePath $Path -ArgumentList '/config .\files\setupsilent\config.xml' -Wait

    Write-Verbose "Checking for Office Online Server Uninstall key to verify successful installation"
    $wacRegPathExist = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer

    If($wacRegPathExist)
    {
        Write-Verbose "Office Online Server successfully installed."
    }
    Else
    {
        throw "Office Online Server failed installation. Checked $($env:TEMP)\Wac Server Setup.log for details"
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path
	)

    $wacRegPathExist = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Office16.WacServer

    If($wacRegPathExist)
    {
        Write-Verbose "Office Online Server Unistall key found"
        return $true
    }
    Else
    {
        Write-Verbose "Office Online Server registgry key not found"
        return $false
    }
}


Export-ModuleMember -Function *-TargetResource

