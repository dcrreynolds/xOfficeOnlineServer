<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename MSFT_x<ResourceName>.tests.ps1
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>


# TODO: Customize these parameters...
$Global:DSCModuleName      = 'xOfficeOnlineServerInstall' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xOfficeOnlineServerInstall' # Example MSFT_xFirewall
# /TODO

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# TODO: Other Optional Init Code Goes Here...

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        # TODO: Optopnal Load Mock for use in Pester tests here...
        #endregion


        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            It 'Should return true when Test-Path returns True' {
                Mock -CommandName 'Test-Path' -MockWith { $true }

                Test-TargetResource -Path 'path' | should be $true
            }

            It 'Should return false when Test-Path returns false' {
                Mock -CommandName 'Test-Path' -MockWith { $false }

                Test-TargetResource -Path 'path' | should be $false
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            It 'Should return Installed as true when test-path returns true' {
                Mock -CommandName 'Test-Path' -MockWith { $true }

                $path = 'path'
                $results = Get-TargetResource -Path $path

                $results.Installed | should be $true
                $results.path | should be $path
            }

            It 'Should return Installed as fals when test-path returns false' {
                Mock -CommandName 'Test-Path' -MockWith { $false }

                $path = 'path'
                $results = Get-TargetResource -Path $path

                $results.Installed | should be $false
                $results.path | should be $path
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            It 'Should not throw when Test-Path is true' {
                Mock -CommandName 'Start-Process' -MockWith {}
                Mock -CommandName 'Test-Path' -MockWith { $true }

                try
                {
                    Set-TargetResource -Path 'Path'

                    $true | should be $true
                }
                catch
                {
                    $false | should be $true
                }
            }

            It 'Should throw when Test-Path is false' {
                Mock -CommandName 'Start-Process' -MockWith {}
                Mock -CommandName 'Test-Path' -MockWith { $false }

                try
                {
                    Set-TargetResource -Path 'Path'

                    $false | should be $true
                }
                catch
                {
                    $true | should be $true
                }
            }

            It 'Should throw when Start-Porcess throws' {
                $throwMessage = 'thrown message'

                Mock -CommandName 'Start-Process' -MockWith { throw $throwMessage }

                { Set-TargetResource -Path 'Path' } | should throw $throwMessage
            }
        }
        #endregion

        # TODO: Pester Tests for any Helper Cmdlets

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}

