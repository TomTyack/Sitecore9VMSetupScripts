Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y chocolateygui
#--- Browsers ---
choco install -y googlechrome
choco install -y firefox
# tools we expect devs across many scenarios will want
choco install -y vscode
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
choco install -y python
choco install -y 7zip.install
choco install -y sysinternals
choco install -y visualstudio2017buildtools
choco install -y nodejs
choco install -y notepadplusplus
choco install -y beyondcompare
choco install -y sql-server-express
choco install -y sql-server-management-studio
choco install -y visualstudio2017community
choco install -y netfx-4.7.1-devpack
choco install -y netfx-4.7.2-devpack
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
choco install -y webpi
choco install -y tortoisegit
choco install -y jre8
choco install -y powershell
choco install -y dotnetcore-runtime
choco install -y webdeploy
choco install -y urlrewrite
#choco install -y solr
choco install -y nssm
choco install -y scla
#choco install -y sim



#under construction
#based off of https://codealoc.wordpress.com/2013/03/15/installing-iis-with-chocolatey/
choco install IIS-WebServerRole --source WindowsFeatures
choco install IIS-ISAPIFilter --source WindowsFeatures
choco install IIS-ISAPIExtensions --source WindowsFeatures
choco install IIS-NetFxExtensibility --source WindowsFeatures
choco install IIS-ASPNET --source WindowsFeatures