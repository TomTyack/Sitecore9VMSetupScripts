# Sitecore9VMSetupScripts
Contains Powershell scripts to setup VMs

1) Open powershell console and run the following:

$installToolsFolder = "C:\sc9_install\"

New-Item -ItemType directory -Path $installToolsFolder -Force

git clone https://github.com/TomTyack/Sitecore9VMSetupScripts.git $installToolsFolder

2) Download your license file to the folder C:\sc9_install\

3) Choose which VM you want to setup: 
a) For a habitat based VM: powershell -ExecutionPolicy ByPass -File VM-Setup-Habitat-SXA.ps1
b) For a clean Sitecore 9.2 VM: powershell -ExecutionPolicy ByPass -File VM-Setup-Sitecore9.ps1
-- Before running the step 3 Line in powershell. Edit the file and fill in the settings at the top. 
