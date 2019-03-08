# BASED ON -- https://buoctrenmay.com/2018/11/29/sitecore-xp-9-1-step-by-step-install-guide-on-your-machine/

#Settings
$sqlUser = "sa"
$sqlUserPassword = "Password1!"

$siteDevNetUsername = "myuser@aceik.com.au"
$siteDevNetPassword = "dev.sitecore.net < Password"
$Secure2 = $siteDevNetPassword | ConvertTo-SecureString -AsPlainText -Force

$solrZipLocation = 'c:\sc9_install\solr-7.2.1.zip'
$sitecoreWDPXp0Zip = 'c:\sc9_install\Sitecore 9.1.0 rev. 001564 (WDP XP0 packages).zip'
$sitecoreInstallFolder = 'c:\sc9_install\'
$SCInstallRoot = "c:\sc9_install"
$SCInstallRoot = "c:\sc9_install"

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
Write-Host "------ PATH SET"

Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force

$confirmationPrograms = Read-Host "Proceed to setup all developer programs [y] or [n]:"
if ($confirmationPrograms -eq 'y') {
	.\Aceik\chocoInstall.ps1
	.\Aceik\windowSettings.ps1
}


$confirmationSQL = Read-Host "Proceed to setup SQL with sa password and Mixed mode Auth [y] or [n]:"
Write-Host "------ After restarting via SQL Server Configuration Manager -- skip this step 2nd time around."
if ($confirmationSQL -eq 'y') {
	.\Aceik\setSqlServerAdmin.ps1 SQLEXPRESS $sqlUser $sqlUserPassword
	.\Aceik\restartSqlServer.ps1 "$env:COMPUTERNAME"
}

####### YOU MAY NEED TO MANUALL RESTART YOU SQL SERVER AT THIS POINT #####
$sqlStarted = Read-Host "Please confirm that SQL server is running and the Browser service is running ? [y] or [n]:"
if ($sqlStarted -eq 'n') {
	Write-Host "*** SORT OUT THE ISSUE ***"
}


.\Aceik\installAllModules.ps1 -Azure $false
.\Aceik\Sitecore9Gallery.ps1

Install-Module SqlServer -Repository PSGallery -AllowClobber

$confirmationSOLR = Read-Host "Proceed to setup SOLR [y] or [n]:"
if ($confirmationSOLR -eq 'y') {
	.\Aceik\Sitecore9InstallSOLR.ps1 $solrZipLocation 
}

Write-Host "-- Setting DB containement user setting "
.\Aceik\containedSQL.ps1
Write-Host "-- Setting DB containement user setting -- DONE"


Write-Host "-- We need to run the prerequisits script"
# We need to run the prerequisits script
.\Aceik\Sitecore9.ps1 $sitecoreWDPXp0Zip $sitecoreInstallFolder
Write-Host "-- We need to run the prerequisits script -- DONE"

# IF you get a GIT not found error run the command:  "start powershell"
####### YOU MAY NEED TO Execute start powershell #####
$confirmationUtilities = Read-Host "Proceed to install base Sitecore [y] or [n]:"
if ($confirmationUtilities -eq 'y') {
  .\sc91_install
}


