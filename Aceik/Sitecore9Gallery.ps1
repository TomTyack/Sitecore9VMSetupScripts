Try
{
	#--- Sitecore 9 Install ---
	Unregister-PSRepository -Name SitecoreGallery
	Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2
	Update-Module SitecoreInstallFramework
	#Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v3
	Set-PSRepository -Name SitecoreGallery -InstallationPolicy Trusted
	Install-Module -Name SitecoreInstallFramework -Repository SitecoreGallery
}
Catch
{
	Write-Host -BackgroundColor Red -ForegroundColor White "Fail"
	$errText =  $Error[0].ToString()
		if ($errText.Contains("network-related"))
	{Write-Host "Connection Error. Check server name, port, firewall."}

	Write-Host $errText
	Write-Host "Sitecore Gallery may already have existed"
	continue
}