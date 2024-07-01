function Update-Module {
    $moduleName = "IPtool"
    $modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
    $baseGitHubUrl = "https://raw.githubusercontent.com/Sirinium/iptool/main/modules"
    $modules = @("GeoLocation.ps1", "DNSProvider.ps1", "SIPALG.ps1", "SpeedTest.ps1", "UpdateModule.ps1", "Utility.ps1")

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

            if ($localVersion -ne $remoteVersion) {
                return $true
            } else {
                return $false
            }
        } catch {
            return $true
        }
    }


    if (-not (Test-Path -Path $modulePath)) {
        New-Item -Path $modulePath -ItemType Directory
        Write-Host "Created module directory at $modulePath" -ForegroundColor Green
    }


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

    Write-Host "=== Importing module ===" -ForegroundColor Cyan
    Import-Module $moduleName -Force

    $module = Get-Module -Name $moduleName -ListAvailable | Select-Object -First 1

    Write-Host "=== Module Information ===" -ForegroundColor Cyan
    Write-Host "Name: $($module.Name)" -ForegroundColor Green
    Write-Host "Version: $($module.Version)" -ForegroundColor Green
    Write-Host "Author: $($module.Author)" -ForegroundColor Green

    Write-Host "Module $moduleName has been installed and/or updated successfully." -ForegroundColor Green
}

Write-Host "Loaded module: Update.ps1" -ForegroundColor Green
