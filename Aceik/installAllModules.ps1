#requires -RunAsAdministrator 
#requires -Version 5.1

# Do not display progress (performance improvement)
$global:ProgressPreference = 'silentlyContinue'

Get-PackageProvider -Name Nuget -ForceBootstrap

Write-Host "Checking WebAdministration"

#region "WebAdministration module"
# Module WebAdministration is required by Sitecore Install Framework
# This module is installed as part of Web-Server feature
if( (Get-Module -Name WebAdministration -ListAvailable) -eq $null )
{
	If ( [bool](Get-Command -Name "Install-WindowsFeature" -ErrorAction SilentlyContinue) )
	{
        Install-WindowsFeature -Name Web-Server
    }
	else 
	{
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
    }
}
#endregion

Write-Host "Checking PSGallery"

#Temporary change default installation policy
$defaultPolicy = (Get-PSRepository -Name PSGallery).InstallationPolicy
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Host "Checking SitecoreGallery"

#region "Register Sitecore Gallery
if( (Get-PSRepository -Name SitecoreGallery -ErrorAction SilentlyContinue) -eq $null )
{
    Write-Host "Configure SitecoreGallery repository"
    Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted
}
#endregion
 
Write-Host "Checking SitecoreInstallFramework"
 
#region "SitecoreInstallFramework for Sitecore 9.1 and later"
if( (Get-Module -Name SitecoreInstallFramework -ListAvailable) -eq $null )
{
    #If install-module is not available check https://www.microsoft.com/en-us/download/details.aspx?id=49186
    Install-Module SitecoreInstallFramework -Scope AllUsers -Repository SitecoreGallery
}
else
{
    Write-Host "SIF module already installed, update then"
	Update-Module SitecoreInstallFramework -Force
}
#endregion

Write-Host "Checking sifModule.Version"

#region "SitecoreInstallFramework for Sitecore 9.1"
$sifModule = Get-Module -Name SitecoreInstallFramework -ListAvailable
if(  $sifModule -eq $null -or $sifModule.Version -ne '2.0.0'  )
{
    Write-Host "Checking sifModule.Version"
	#If install-module is not available check https://www.microsoft.com/en-us/download/details.aspx?id=49186
    Install-Module SitecoreInstallFramework -Scope AllUsers -Repository SitecoreGallery -RequiredVersion 2.0.0 -AllowClobber
}
#endregion

Write-Host "Checking SitecoreFundamentals"

#region "SitecoreFundamentals"
if( (Get-Module -Name SitecoreFundamentals -ListAvailable) -eq $null )
{
    #If install-module is not available check https://www.microsoft.com/en-us/download/details.aspx?id=49186
    Install-Module SitecoreFundamentals -Scope AllUsers -Repository SitecoreGallery
}
else
{
    Write-Host "SitecoreFundamentals module already installed, update then"
	Update-Module SitecoreFundamentals -Force
}
#endregion

#region "SitecoreInstallExtensions"
if( (Get-Module -Name SitecoreInstallExtensions -ListAvailable) -eq $null )
{
    #If install-module is not available check https://www.microsoft.com/en-us/download/details.aspx?id=49186
    Install-Module SitecoreInstallExtensions -Scope AllUsers -Repository PSGallery
}
else
{
    Write-Host "SitecoreInstallExtensions module already installed, update then"
	Update-Module SitecoreInstallExtensions -Force
}
#endregion

#region "SitecoreInstallAzure"
if( $Azure -eq $true)
{
	if( (Get-Module -Name SitecoreInstallAzure -ListAvailable) -eq $null )
	{
    	#If install-module is not available check https://www.microsoft.com/en-us/download/details.aspx?id=49186
    	Install-Module SitecoreInstallAzure -Scope AllUsers -Repository PSGallery
	}
	else
	{
    	Write-Host "SitecoreInstallAzure module already installed, update then"
		Update-Module SitecoreInstallAzure -Force
	}
}
#endregion

Set-PSRepository PSGallery -InstallationPolicy $defaultPolicy

Get-Module Sitecore* -ListAvailable | Format-List