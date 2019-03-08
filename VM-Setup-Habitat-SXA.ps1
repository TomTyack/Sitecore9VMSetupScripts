# Documentation https://github.com/Sitecore/Sitecore.HabitatHome.Utilities/blob/develop/XP/install/README.md

#Settings
$sqlUser = "sa"
$sqlUserPassword = "Password1!"

$siteDevNetUsername = "myuser@aceik.com.au"
$siteDevNetPassword = "aapassword"
$Secure2 = $siteDevNetPassword | ConvertTo-SecureString -AsPlainText -Force

$sitecoreInstallFolder = 'c:\sc9_install\'
$SCInstallRoot = "c:\sc9_install"
$habitatUtilitiesFolder = "$sitecoreInstallFolder"+"habitatutils"
$habitatInstallFolder = "$habitatUtilitiesFolder"+"\XP\install"
$habitatAssetsFolder = "$habitatInstallFolder"+"\Assets\"
$habitatAssetsConfigFolder = "$habitatAssetsFolder"+"\configuration\"
$habitatRepoFolder = "$sitecoreInstallFolder"+"habitat"

#Turn off PowerShell Progress Bar to greatly enhance download speeds
$Global:ProgressPreference = 'SilentlyContinue'

#JAVA SETTINGS
# IF you get an error about the KeyStore mossing you may need to run:  "start powershell"
# Then try this script again.
$javaLocation = "C:\Program Files\Java\jre1.8.0_201"
$javaBin = ";$javaLocation\Bin;"
$env:JAVA_HOME="$javaLocation"

$existingPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)

Write-Host "------"
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + "$javaBin", [EnvironmentVariableTarget]::Machine)
$newPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)


Write-Host "habitatInstallFolder = $habitatInstallFolder"

Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force

$confirmationPrograms = Read-Host "Proceed to setup all developer programs [y] or [n]:"
if ($confirmationPrograms -eq 'y') {
	.\Aceik\chocoInstall.ps1
	.\Aceik\windowSettings.ps1
}

$confirmationSQL = Read-Host "Proceed to setup SQL with sa password and Mixed mode Auth [y] or [n]:"
if ($confirmationSQL -eq 'y') {
	.\Aceik\setSqlServerAdmin.ps1 SQLEXPRESS $sqlUser $sqlUserPassword
	.\Aceik\restartSqlServer.ps1 "$env:COMPUTERNAME"
}

####### YOU MAY NEED TO MANUALL RESTART YOU SQL SERVER AT THIS POINT #####
# Open the habitat project and build it in VS first
$sqlStarted = Read-Host "Please confirm that SQL server is running and the Browser service is running ? [y] or [n]:"
if ($sqlStarted -eq 'n') {
	Write-Host "*** SORT OUT THE ISSUE ***"
}

.\Aceik\installAllModules.ps1 -Azure $false
.\Aceik\Sitecore9Gallery.ps1

Install-Module SqlServer -Repository PSGallery -AllowClobber

.\Aceik\containedSQL.ps1

# IF you get a GIT not found error run the command:  "start powershell"
####### YOU MAY NEED TO Execute start powershell #####
$confirmationUtilities = Read-Host "Proceed to checkout habitat utilities and unzip [y] or [n]:"
if ($confirmationUtilities -eq 'y') {
  # proceed
  .\Aceik\cloneHabitatUtilities $habitatUtilitiesFolder
  
  # Utilities Script references a silly random log file
  New-Item -ItemType directory -Path C:\projects\Demo.Utilities.VSTS\XP\Install\
}

Write-Host "Copy the habitat configuration overrides file into place"
$configOverridesHT = "$sitecoreInstallFolder"+"config_overrides\set-installation-overrides.ps1"
Copy-Item -Path $configOverridesHT -Destination $habitatInstallFolder -Force

$sitecoreLIcenseFile = "$sitecoreInstallFolder"+"license.xml"
Copy-Item -Path $sitecoreLIcenseFile -Destination $habitatAssetsFolder -Force

#Navigate to the XP\install\assets\Configuration folder
Set-Location $habitatAssetsConfigFolder
Install-SitecoreConfiguration -Path (Resolve-Path .\prerequisites.json)

Set-Location -Path $habitatInstallFolder
.\set-installation-defaults.ps1
.\set-installation-overrides.ps1

$confirmationSOLR = Read-Host "Proceed to setup SOLR [y] or [n]:"
if ($confirmationSOLR -eq 'y') {
	# Install SOLR
	Set-Location -Path $habitatInstallFolder\Solr
	.\install-solr -installFolder C:\Solr -Clobber
}

# Install Sitecore
# ISSUE -- If running for a second time and it complains about database containment. Delete all DBS and DB users from the Database Server.  Retry this process.
$confirmationSitecore = Read-Host "Proceed to install modules [y] or [n]:"
if ($confirmationSitecore -eq 'y') {
	Set-Location -Path $habitatInstallFolder
	.\install-singledeveloper.ps1  -devSitecoreUsername $siteDevNetUsername -devSitecorePassword $siteDevNetPassword
}

# Install Modules
# ISSUE NOTES:  if you experience a named pipe exception attempt the following:  https://stackoverflow.com/questions/9945409/how-do-i-fix-the-error-named-pipes-provider-error-40-could-not-open-a-connec
#  --- For this issue you can also manually copy  /config_overrides/remove-databaseuser.json   to  ->   /habitatutils/Shared/assets/configuration/remove-databaseuser.json
# ISSUE 2:  Double check ISS features are enabled on the control panel if other issues found  https://labs.tadigital.com/index.php/2018/12/03/sitecore-9-1-installation-guide/ 
$confirmationUtilities = Read-Host "Proceed to install modules [y] or [n]:"
if ($confirmationUtilities -eq 'y') {
	  Set-Location -Path $habitatInstallFolder
	.\install-modules.ps1 -devSitecoreUsername $siteDevNetUsername -devSitecorePassword $Secure2
}

# NOW IS A GOOD TIME TO BACK C:\inetpub\wwwroot
$confirmationBackup = Read-Host "Now is a good time to backup C:\inetpub\wwwroot [y] or [n]:"
if ($confirmationBackup -eq 'y') {
}

# clone Habitat Main Repo and install projects
$habitatProceed = Read-Host "Proceed to clone habitat [y] or [n]:"
if ($habitatProceed -eq 'y') {
	 Set-Location -Path $sitecoreInstallFolder
	 .\Aceik\cloneHabitatRepo.ps1 -habitatRepoFolder $habitatRepoFolder -sitecoreInstallFolder $sitecoreInstallFolder
}

# Open the habitat project and build it in VS first
$confirmationBackup = Read-Host "Now is a good time to open the habitat project and build it in VS before proceeding. Is this done ? [y] or [n]:"
if ($confirmationBackup -eq 'y') {
}

# HABITAT BUILD
# if you get the error:  error MSB4057: The target "restore" does not exist in the project  
# Follow the instructions: https://blog.house-of-code.com/how-to-run-visual-studio-2017-projects-using-build-tools-for-visual-studio/
# You need to copy the nuget folder as mentioned in the page above.
# Make sure the VS2017 build tools are all installed as well.
$habitatBuild = Read-Host "Proceed to build habitat [y] or [n]:"
if ($habitatBuild -eq 'y') {
	 Set-Location -Path $habitatRepoFolder
	 .\..\Aceik\buildHabitat.ps1
}



