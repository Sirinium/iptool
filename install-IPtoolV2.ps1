# Définir les variables
$moduleName = "IPtool"
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
$modulesPath = "$modulePath\modules"
$baseUrl = "https://raw.githubusercontent.com/Sirinium/iptool/main/modules"

# Fonction pour télécharger un fichier
function Get-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Host "Downloaded $url" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download $url" -ForegroundColor Red
        throw
    }
}

# Créer les dossiers du module s'ils n'existent pas déjà
if (-not (Test-Path -Path $modulePath)) {
    New-Item -Path $modulePath -ItemType Directory
    Write-Host "Created module directory at $modulePath" -ForegroundColor Green
}

if (-not (Test-Path -Path $modulesPath)) {
    New-Item -Path $modulesPath -ItemType Directory
    Write-Host "Created modules directory at $modulesPath" -ForegroundColor Green
}

# Télécharger le fichier principal du module
Write-Host "=== Downloading module files ===" -ForegroundColor Cyan
$psm1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psm1"
Get-File -url $psm1Url -outputPath "$modulePath\$moduleName.psm1"

# Télécharger tous les modules individuels
$modules = @(
    'GeoLocation.ps1', 
    'DNSProvider.ps1', 
    'SIPALG.ps1', 
    'SpeedTest.ps1', 
    'UpdateModule.ps1',  # Ajout du module UpdateModule.ps1
    'Utility.ps1'
)

foreach ($module in $modules) {
    $moduleUrl = "$baseUrl/$module"
    Get-File -url $moduleUrl -outputPath "$modulesPath\$module"
}

# Importer le module dans la session PowerShell courante
Write-Host "=== Importing module ===" -ForegroundColor Cyan
Import-Module $moduleName -Force

# Récupérer les informations du module
$module = Get-Module -Name $moduleName -ListAvailable | Select-Object -First 1

Write-Host "=== Module Information ===" -ForegroundColor Cyan
Write-Host "Name: $($module.Name)" -ForegroundColor Green
Write-Host "Version: $($module.Version)" -ForegroundColor Green
Write-Host "Author: $($module.Author)" -ForegroundColor Green

Write-Host "Module $moduleName has been installed and/or updated successfully." -ForegroundColor Green
