# Définir les variables
$moduleName = "IPtool"
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
$modulesPath = "$modulePath\modules"
$baseUrl = "https://raw.githubusercontent.com/Sirinium/iptool/main/modules"

# Fonction pour télécharger un fichier
function Receive-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Host "Downloaded $(Split-Path -Leaf $url)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download $(Split-Path -Leaf $url)" -ForegroundColor Red
        throw
    }
}

# Créer les dossiers du module s'ils n'existent pas déjà
if (-not (Test-Path -Path $modulePath)) {
    New-Item -Path $modulePath -ItemType Directory
    Write-Host "Created module directory" -ForegroundColor Green
}

if (-not (Test-Path -Path $modulesPath)) {
    New-Item -Path $modulesPath -ItemType Directory
    Write-Host "Created modules directory" -ForegroundColor Green
}

# Télécharger le fichier principal du module
Write-Host "=== Downloading module files ===" -ForegroundColor Cyan
$psm1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psm1"
$psd1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psd1"
Receive-File -url $psm1Url -outputPath "$modulePath\$moduleName.psm1"
Receive-File -url $psd1Url -outputPath "$modulePath\$moduleName.psd1"

# Télécharger tous les modules individuels
$modules = @(
    'GeoLocation.ps1', 
    'DNSProvider.ps1', 
    'SIPALG.ps1', 
    'SpeedTest.ps1', 
    'UpdateModule.ps1',  
    'Utility.ps1'
)

foreach ($module in $modules) {
    $moduleUrl = "$baseUrl/$module"
    Receive-File -url $moduleUrl -outputPath "$modulesPath\$module"
}

# Vérifier que les fichiers ont bien été téléchargés
Write-Host "=== Verifying downloaded files ===" -ForegroundColor Cyan
foreach ($module in $modules) {
    $filePath = "$modulesPath\$module"
    if (Test-Path $filePath) {
        Write-Host "Verified $module (loaded)" -ForegroundColor Green
    } else {
        Write-Host "Error: $module not verified correctly!" -ForegroundColor Red
    }
}

# Importer le module dans la session PowerShell courante
Write-Host "=== Importing module ===" -ForegroundColor Cyan
try {
    Import-Module $moduleName -Force
    Write-Host "Module $moduleName imported successfully." -ForegroundColor Green
} catch {
    Write-Host "Error importing module $moduleName: $($_.Exception.Message)" -ForegroundColor Red
}

# Récupérer les informations du module
Write-Host "=== Retrieving module information ===" -ForegroundColor Cyan
try {
    $module = Get-Module -Name $moduleName -ListAvailable | Select-Object -First 1
    Write-Host "=== Module Information ===" -ForegroundColor Cyan
    Write-Host "Name: $($module.Name)" -ForegroundColor Green
    Write-Host "Version: $($module.Version)" -ForegroundColor Green
    Write-Host "Author: $($module.Author)" -ForegroundColor Green
} catch {
    Write-Host "Error retrieving module information: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Module $moduleName has been installed and/or updated successfully." -ForegroundColor Green
