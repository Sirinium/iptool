$moduleName = "IPtool"
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
$modulesPath = "$modulePath\modules"
$baseUrl = "https://raw.githubusercontent.com/Sirinium/iptool/main/modules"

function Receive-File {
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

if (-not (Test-Path -Path $modulePath)) {
    New-Item -Path $modulePath -ItemType Directory
    Write-Host "Created module directory at $modulePath" -ForegroundColor Green
}

if (-not (Test-Path -Path $modulesPath)) {
    New-Item -Path $modulesPath -ItemType Directory
    Write-Host "Created modules directory at $modulesPath" -ForegroundColor Green
}

Write-Host "=== Downloading module files ===" -ForegroundColor Cyan
$psm1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psm1"
Receive-File -url $psm1Url -outputPath "$modulePath\$moduleName.psm1"

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

Write-Host "=== Verifying downloaded files ===" -ForegroundColor Cyan
foreach ($module in $modules) {
    $filePath = "$modulesPath\$module"
    if (Test-Path $filePath) {
        Write-Host "Verified $filePath exists." -ForegroundColor Green
    } else {
        Write-Host "Error: $filePath does not exist!" -ForegroundColor Red
    }
}

Write-Host "=== Importing module ===" -ForegroundColor Cyan
try {
    Import-Module $moduleName -Force -ErrorAction Stop
    Write-Host "Module $moduleName imported successfully." -ForegroundColor Green
} catch {
    Write-Host "Error importing module ${moduleName}: $($_.Exception.Message)" -ForegroundColor Red
}

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
