
param([String]$sitecoreWDPXp0Zip, [String]$sitecoreInstallFolder )

Write-Host "unpacking the Sitecore 9 WDP ZIP From: $sitecoreWDPXp0Zip To: $sitecoreInstallFolder"

Set-Location -Path $sitecoreInstallFolder

expand-archive -path $sitecoreWDPXp0Zip  -destinationpath $sitecoreInstallFolder -Force

Write-Host "FINISHED unpacking the Sitecore 9 WDP ZIP"

Write-Host "unpacking XP0 Configuration files 9.1.0 rev. 001564.zip"
$configFileZip = "$sitecoreInstallFolder"+"XP0 Configuration files 9.1.0 rev. 001564.zip"
expand-archive -path $configFileZip  -destinationpath $sitecoreInstallFolder -Force
Write-Host "FINISHED unpacking the Sitecore 9 WDP ZIP"


Write-Host "override sitecore-XP0.json + xconnect-xp0.json + IdentityServer.json + XP0-SingleDeveloper.json in order to inject the custom install directory"
$XP0Json = "$sitecoreInstallFolder"+"config_overrides\sitecore-XP0.json"
Copy-Item -Path $XP0Json -Destination $sitecoreInstallFolder -Force

$XconnectXP0Json = "$sitecoreInstallFolder"+"config_overrides\xconnect-xp0.json"
Copy-Item -Path $XconnectXP0Json -Destination $sitecoreInstallFolder -Force

$IdentityServerJson = "$sitecoreInstallFolder"+"config_overrides\IdentityServer.json"
Copy-Item -Path $IdentityServerJson -Destination $sitecoreInstallFolder -Force

$SingleDeveloperJson = "$sitecoreInstallFolder"+"config_overrides\XP0-SingleDeveloper.json"
Copy-Item -Path $SingleDeveloperJson -Destination $sitecoreInstallFolder -Force

Write-Host "installing sitecore prerequisites"
Install-SitecoreConfiguration -Path .\prerequisites.json
Write-Host "COMPLETED -- prerequisites"