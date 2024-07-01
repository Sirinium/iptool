# Version: 1.0.1
function Update-Module {
    $moduleName = "IPtool"
    $modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
    $baseGitHubUrl = "https://raw.githubusercontent.com/Sirinium/iptool/main/modules"
    $modules = @("GeoLocation.ps1", "DNSProvider.ps1", "SIPALG.ps1", "SpeedTest.ps1", "UpdateModule.ps1", "Utility.ps1")

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

    # Fonction pour comparer les versions de fichiers
    function Compare-Version {
        param (
            [string]$localFilePath,
            [string]$remoteUrl
        )

        try {
            $localVersion = (Select-String -Path $localFilePath -Pattern "# Version:" | Select-Object -First 1).Line
            $remoteVersion = (Invoke-WebRequest -Uri $remoteUrl -UseBasicParsing).Content | Select-String -Pattern "# Version:" | Select-Object -First 1

            $localVersion = $localVersion -replace "# Version: ", ""
            $remoteVersion = $remoteVersion.Line -replace "# Version: ", ""

            if ($localVersion -ne $remoteVersion) {
                return $true
            } else {
                return $false
            }
        } catch {
            return $true
        }
    }

    # Créer le dossier du module s'il n'existe pas déjà
    if (-not (Test-Path -Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
        Write-Host "Created module directory at $modulePath" -ForegroundColor Green
    }

    # Télécharger les fichiers du module depuis GitHub si la version est différente
    Write-Host "=== Downloading module files ===" -ForegroundColor Cyan
    foreach ($module in $modules) {
        $localFilePath = "$modulePath\$module"
        $remoteUrl = "$baseGitHubUrl/$module"

        if ((Test-Path -Path $localFilePath) -and (-not (Compare-Version -localFilePath $localFilePath -remoteUrl $remoteUrl))) {
            Write-Host "$module is up to date." -ForegroundColor Green
        } else {
            Write-Host "Updating $module..." -ForegroundColor Yellow
            Get-File -url $remoteUrl -outputPath $localFilePath
            Write-Host "Updated $module" -ForegroundColor Green
        }
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
}
