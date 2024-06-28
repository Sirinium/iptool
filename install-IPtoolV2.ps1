# Définir les variables
$moduleName = "IPtool"
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
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

# Créer le dossier du module s'il n'existe pas déjà
if (-not (Test-Path -Path $modulePath)) {
    New-Item -Path $modulePath -ItemType Directory
    Write-Host "Created module directory at $modulePath" -ForegroundColor Green
}

# Télécharger le fichier principal du module
Write-Host "=== Downloading module files ===" -ForegroundColor Cyan
$psm1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psm1"
Get-File -url $psm1Url -outputPath "$modulePath\$moduleName.psm1"

# Télécharger tous les modules individuels
$modules = @('Get-GeoLocation.ps1', 'Get-DNSProvider.ps1', 'Get-MyIP.ps1', 'Show-IPInfo.ps1', 'Get-DefaultGateway.ps1', 'Test-SIPALG.ps1', 'CheckSIPALG.ps1', 'Get-SpeedTestDownloadLink.ps1', 'Get-SpeedTestZip.ps1', 'Expand-Zip.ps1', 'Invoke-SpeedTest.ps1', 'Remove-File.ps1', 'Remove-Files.ps1', 'CheckSpeed.ps1', 'Update-Module.ps1', 'Show-Help.ps1', 'iptool.ps1')

foreach ($module in $modules) {
    $moduleUrl = "$baseUrl/$module"
    Get-File -url $moduleUrl -outputPath "$modulePath\modules\$module"
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
