
param([String]$habitatRepoFolder, [String]$sitecoreInstallFolder)
if (Test-Path $habitatRepoFolder) 
{
  Remove-Item $habitatRepoFolder
}

New-Item -ItemType directory -Path $habitatRepoFolder -Force

git clone https://github.com/Sitecore/Habitat.git $habitatRepoFolder

Write-Host "override gulp-config.js as it requires a custom setting"
$gulpConfig = "$sitecoreInstallFolder"+"habitat_overrides\gulp-config.js"
$gulpConfigDest = "$habitatRepoFolder"
Copy-Item -Path $gulpConfig -Destination $gulpConfigDest -Force

Write-Host "override Habitat.Dev.config as it requires a custom setting"
$devConfig = "$sitecoreInstallFolder"+"habitat_overrides\Habitat.Dev.config"
$devConfigDest = "$habitatRepoFolder"+"\src\Project\Habitat\code\App_Config\Environment\Project\"
Copy-Item -Path $devConfig -Destination $devConfigDest -Force

Write-Host "override publishsettings.targets as it requires a custom setting"
$pubSettingsConfig = "$sitecoreInstallFolder"+"habitat_overrides\publishsettings.targets"
$pubSettingsConfigDest = "$habitatRepoFolder"
Copy-Item -Path $pubSettingsConfig -Destination $pubSettingsConfigDest -Force

Write-Host "override settings.ps1 as it requires a custom setting"
$settingsConfig = "$sitecoreInstallFolder"+"habitat_overrides\settings.ps1"
$settingsConfigDest = "$habitatRepoFolder"
Copy-Item -Path $settingsConfig -Destination $settingsConfigDest -Force



