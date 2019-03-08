
param([String]$habitatUtilitiesFolder )
if (Test-Path $habitatUtilitiesFolder) 
{
  Remove-Item $habitatUtilitiesFolder
}

New-Item -ItemType directory -Path $habitatUtilitiesFolder

git clone https://github.com/Sitecore/Sitecore.HabitatHome.Utilities.git $habitatUtilitiesFolder
