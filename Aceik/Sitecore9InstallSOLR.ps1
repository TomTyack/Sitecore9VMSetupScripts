
param([String]$solrZipLocation, [String]$sitecoreInstallFolder )

Try
{
	expand-archive -path $solrZipLocation  -destinationpath 'c:\solr' -Force
}
Catch
{
	Write-Host -BackgroundColor Red -ForegroundColor White "Fail"
	$errText =  $Error[0].ToString()
		if ($errText.Contains("network-related"))
	{Write-Host "Connection Error. Check server name, port, firewall."}

	Write-Host $errText
	Write-Host "SOLR may already be unzipped"
	continue
}

Write-Host "completed SOLR unzipp"
Write-Host "Begin SOLR install script"

Try
{
	cd Aceik
	#--- Install SOLR ---
	.\install-solr.ps1 -sitecoreInstallFolder $sitecoreInstallFolder
}
Catch
{
	Write-Host -BackgroundColor Red -ForegroundColor White "Fail"
	$errText =  $Error[0].ToString()
		if ($errText.Contains("network-related"))
	{Write-Host "Connection Error. Check server name, port, firewall."}

	Write-Host $errText
	Write-Host "SOLR may already be installed and running"
	continue
}

Write-Host "Completed SOLR INSTALL"

cd..


