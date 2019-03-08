# Sitecore9VMSetupScripts
Contains Powershell scripts to setup VMs

1) Open powershell console and run the following:

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y git

2) Restart the Powershell window and type the command 'git' to make sure its installed.

3) Run the three commands below: 

$installToolsFolder = "C:\sc9_install\"

New-Item -ItemType directory -Path $installToolsFolder -Force

git clone https://github.com/TomTyack/Sitecore9VMSetupScripts.git $installToolsFolder

4) Download your license file to the folder C:\sc9_install\

5) Run the Command in powershell window:  Set-ExecutionPolicy RemoteSigned

5) Choose which VM you want to setup: 

Two Options: 

a) For a habitat based VM: powershell -ExecutionPolicy ByPass -File VM-Setup-Habitat-SXA.ps1
-- Before running the step 3 Line in powershell. Edit the file and fill in the settings at the top. 

b) For a clean Sitecore 9.2 VM: powershell -ExecutionPolicy ByPass -File VM-Setup-Sitecore9.ps1
-- Before running the step 3 Line in powershell. Edit the file and fill in the settings at the top. 
Download the files into "C:\sc9_install\" before beginning:
- license.xml
- Sitecore 9.1.0 rev. 001564 (WDP XPSingle packages).zip
- Sitecore Experience Accelerator 1.8 rev. 181112 for 9.1.zip
- solr-7.2.1.zip
