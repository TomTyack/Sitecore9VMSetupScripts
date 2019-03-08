Param(
    [string] $configurationFile = "configuration-xp0.json"
)

# Replace the values in this file with your installation Overrides
# all objects in the install-settings.json file can be overridden in this file

# You can remove any items that you do not need to override. Keep in mind the dependency on other settings when removing items.
# For example, $assets is used in various sections.

Write-Host "Setting Local Overrides in $configurationFile"

$json = Get-Content -Raw $configurationFile |  ConvertFrom-Json

# Assets and prerequisites
$assets = $json.assets
$assets.licenseFilePath = Join-Path $assets.root "license.xml"

# Settings

# Site Settings
$site = $json.settings.site
$site.prefix = "habitathome"
$site.suffix = "dev.local"
$site.webroot = "C:\inetpub\wwwroot"
$site.hostName = $json.settings.site.prefix + "." + $json.settings.site.suffix

$habitathomebasicBinding = [ordered]@{
    hostName            = "habitathomebasic.dev.local"
    createCertificate   = $true
    sslOnly             = $false
    port                = 443

}
$habitathomebasicBinding = $habitathomebasicBinding | ConvertTo-Json
$site.additionalBindings += (ConvertFrom-Json -InputObject $habitathomebasicBinding)  
# #### EXAMPLE additional bindings
# $otherAdditionalBinding = [ordered]@{
#     hostName = "otherexample.dev.local"
#     createCertificate = $false
# }
# $otherAdditionalBinding = $otherAdditionalBinding | ConvertTo-Json
# $site.additionalBindings += (ConvertFrom-Json -InputObject $otherAdditionalBinding)

# Sitecore Parameters
$sitecore = $json.settings.sitecore
$sitecore.adminPassword = "b"
$sitecore.exmCryptographicKey = "0x0000000000000000000000000000000000000000000000000000000000000000"
$sitecore.exmAuthenticationKey = "0x0000000000000000000000000000000000000000000000000000000000000000"
$sitecore.telerikEncryptionKey = "PutYourCustomEncryptionKeyHereFrom32To256CharactersLong"

# Solr Parameters
$solr = $json.settings.solr
$solr.url = "https://localhost:8721/solr"
$solr.root = "c:\solr\solr-7.2.1"
$solr.serviceName = "Solr-7.2.1"

# SQL Settings
$sql = $json.settings.sql

$SqlStrongPassword = "Str0NgPA33w0rd!!" # Used for all other services

if (!$sqlUser) { $sqlUser = "sa" }
if (!$sqlUserPassword) { $sqlUserPassword = "Password1!" }

$sql.server = "$env:COMPUTERNAME\SQLEXPRESS"
$sql.adminUser = $sqlUser
$sql.adminPassword = $sqlUserPassword
$sql.userPassword = $SqlStrongPassword
$sql.coreUser =  "coreuser"
$sql.corePassword = $SqlStrongPassword
$sql.masterUser =  "masteruser"
$sql.masterPassword = $SqlStrongPassword
$sql.webUser =  "webuser"
$sql.webPassword = $SqlStrongPassword
$sql.collectionUser =  "collectionuser"
$sql.collectionPassword = $SqlStrongPassword
$sql.reportingUser =  "reportinguser"
$sql.reportingPassword = $SqlStrongPassword
$sql.processingPoolsUser =  "poolsuser"
$sql.processingPoolsPassword = $SqlStrongPassword
$sql.processingTasksUser =  "tasksuser"
$sql.processingTasksPassword = $SqlStrongPassword
$sql.referenceDataUser =  "referencedatauser"
$sql.referenceDataPassword = $SqlStrongPassword
$sql.marketingAutomationUser =  "marketingautomationuser"
$sql.marketingAutomationPassword = $SqlStrongPassword
$sql.formsUser =  "formsuser"
$sql.formsPassword = $SqlStrongPassword
$sql.exmMasterUser =  "exmmasteruser"
$sql.exmMasterPassword = $SqlStrongPassword
$sql.messagingUser =  "messaginguser"
$sql.messagingPassword = $SqlStrongPassword
$sql.securityuser =  "securityuser"
$sql.securityPassword = $SqlStrongPassword

# XConnect Parameters
$xConnect = $json.settings.xConnect
$xConnect.siteName = $site.prefix + "_xconnect." + $site.suffix
$xConnect.siteRoot = Join-Path $site.webRoot -ChildPath $xConnect.siteName

# IdentityServer Parameters
$identityServer = $json.settings.identityServer
$identityServer.packagePath = Join-Path $assets.root $("Sitecore.IdentityServer " + $assets.identityServerVersion + " (OnPrem)_identityserver.scwdp.zip")
$identityServer.configurationPath = (Get-ChildItem $assets.root -filter "IdentityServer.json" -Recurse).FullName 
$identityServer.name = "IdentityServer." + $site.hostname
$identityServer.url = ("https://{0}" -f $identityServer.name)
$identityServer.clientSecret = "ClientSecret"


Write-Host "Setting  'modules' parameters"
# Modules

Function Get-HabitathomeAssetUrls {
    Param(
        [PSCustomObject]$habitatHome
    )
    $release = @{};
    $urls = @{};
    
    if ($habitatHome.prerelease) {
        # Get latest pre-release version
        $release = (Invoke-RestMethod -Uri "https://api.github.com/repos/Sitecore/Sitecore.HabitatHome.Platform/releases")[0]
    }
    elseif (![string]::IsNullOrEmpty($habitatHome.version) ) {
        # Get version specified (uses wildcard - 9.1.0.0 will return latest )
        $release = ((Invoke-RestMethod -Uri "https://api.github.com/repos/Sitecore/Sitecore.HabitatHome.Platform/releases") | Where-Object {$_.tag_name -like "{0}*" -f $habitatHome.version -and -not $_.prerelease})
        if ($null -ne $release)
        {
            $release= $release[0]
        }
    }
    else {
        # Get latest, non-prelease assets
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/Sitecore/Sitecore.HabitatHome.Platform/releases/latest"
    }
    if ($null -ne $release) {
        $releaseId = $release.id
        $assets = Invoke-RestMethod -Uri ("https://api.github.com/repos/Sitecore/Sitecore.HabitatHome.Platform/releases/{0}/assets" -f $releaseId)
        $urls.habitatHomePackageUrl = $assets | Where-Object {$_.name -eq "HabitatHome_single.scwdp.zip"} | Select -ExpandProperty browser_download_url
        $urls.habitatHomexConnectPackageUrl = $assets | Where-Object {$_.name -eq "HabitatHome_xConnect_single.scwdp.zip"} | Select -ExpandProperty browser_download_url
        return $urls
    }
    return $null
    
    
}

Function Replace-Path {
    param(
        $module,
        $root
    )
    $module.fileName = (Join-Path $root ("\packages\{0}" -f $module.fileName))    
}

$modulesConfig = Get-Content -Raw .\assets.json -Encoding Ascii |  ConvertFrom-Json

$modules = $json.modules

$sitecore = $modulesConfig.sitecore

$config = @{
    id       = $sitecore.id
    name     = $sitecore.name
    fileName = Join-Path $assets.root ("\{0}" -f $sitecore.fileName) 
    url      = $sitecore.url
    extract  = $sitecore.extract
    source   = $sitecore.source
    databases = $sitecore.databases
}
$config = $config| ConvertTo-Json
$modules += (ConvertFrom-Json -InputObject $config) 

foreach ($module in $modulesConfig.modules) {
    Replace-Path $module $assets.root
}
$modules += $modulesConfig.modules

$json.modules = $modules
$habitatHome = $modulesConfig.habitatHome

$habitatHomeurls = Get-HabitathomeAssetUrls $habitatHome
($habitathome.modules | Where-Object {$_.id -eq "habitathome"}).url = $habitatHomeurls.habitatHomePackageUrl
($habitathome.modules | Where-Object {$_.id -eq "habitathome_xConnect"}).url = $habitatHomeurls.habitatHomexConnectPackageUrl

foreach ($entry in $habitatHome.modules) {
    Replace-Path $entry $assets.root 
}

$modules += $modulesConfig.habitatHome

$json.modules = $modules

$habitatHome = $json.settings.habitatHome
($habitatHome | Where-Object {$_.id -eq "RootHostName"}).value = "dev.local"
($habitatHome | Where-Object {$_.id -eq "AnalyticsCookieDomain"}).value = "`$(rootHostName)"


Set-Content $configurationFile  (ConvertTo-Json -InputObject $json -Depth 6)