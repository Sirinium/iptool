# Définir les variables
$moduleName = "IPtool"
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
$psm1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psm1"
$psd1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psd1"

# Fonction pour télécharger un fichier
function Get-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
    } catch {
        Write-Host "Failed to download $url" -ForegroundColor Red
        throw
    }
}

# Créer le dossier du module s'il n'existe pas déjà
if (-not (Test-Path -Path $modulePath)) {
    New-Item -Path $modulePath -ItemType Directory
    Write-Host "Created module directory at $modulePath" -ForegroundColor Green
}

# Télécharger les fichiers du module depuis GitHub
Write-Host "Downloading module files..." -ForegroundColor Cyan
Get-File -url $psm1Url -outputPath "$modulePath\$moduleName.psm1"
Get-File -url $psd1Url -outputPath "$modulePath\$moduleName.psd1"

# Importer le module dans la session PowerShell courante
Write-Host "Importing module..." -ForegroundColor Cyan
Import-Module $moduleName -Force

# Récupérer les informations du module
$module = Get-Module -Name $moduleName -ListAvailable | Select-Object -First 1

Write-Host "=== Module Information ===" -ForegroundColor Cyan
Write-Host "Name: $($module.Name)" -ForegroundColor Green
Write-Host "Version: $($module.Version)" -ForegroundColor Green
Write-Host "Author: $($module.Author)" -ForegroundColor Green

Write-Host "Module $moduleName has been installed and/or updated successfully." -ForegroundColor Green
pause
