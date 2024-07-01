# Define variables
$moduleName = "IPtool"
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName"
$modulesPath = "$modulePath\modules"
$baseUrl = "https://raw.githubusercontent.com/Sirinium/iptool/main/modules"

# Function to download a file
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

# Function to get module version
function Get-ModuleVersion {
    param (
        [string]$filePath
    )
    $versionLine = Select-String -Path $filePath -Pattern '# Version:' | Select-Object -First 1
    if ($versionLine) {
        return $versionLine.Line.Split(':')[1].Trim()
    } else {
        return "0.0.0"
    }
}

# Create directories if they don't exist
if (-not (Test-Path -Path $modulePath)) {
    New-Item -Path $modulePath -ItemType Directory
    Write-Host "Created module directory" -ForegroundColor Green
}

if (-not (Test-Path -Path $modulesPath)) {
    New-Item -Path $modulesPath -ItemType Directory
    Write-Host "Created modules directory" -ForegroundColor Green
}

# Download main module files
Write-Host "=== Downloading module files ===" -ForegroundColor Cyan
$psm1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psm1"
$psd1Url = "https://raw.githubusercontent.com/Sirinium/iptool/main/IPtool.psd1"
Receive-File -url $psm1Url -outputPath "$modulePath\$moduleName.psm1"
Receive-File -url $psd1Url -outputPath "$modulePath\$moduleName.psd1"

# Download individual modules
$modules = @(
    'GeoLocation.ps1', 
    'DNSProvider.ps1', 
    'SIPALG.ps1', 
    'SpeedTest.ps1', 
    'UpdateModule.ps1',  
    'Utility.ps1'
)

$updatedModules = @()
foreach ($module in $modules) {
    $moduleUrl = "$baseUrl/$module"
    $localModulePath = "$modulesPath\$module"

    if (Test-Path $localModulePath) {
        Remove-Item -Path $localModulePath -Force
    }

    $tempPath = Join-Path $env:TEMP $module
    Receive-File -url $moduleUrl -outputPath $tempPath
    $remoteVersion = Get-ModuleVersion -filePath $tempPath

    Copy-Item -Path $tempPath -Destination $localModulePath -Force
    $updatedModules += "Downloaded $module (version: $remoteVersion)"

    Remove-Item -Path $tempPath -Force
}

# Display updated modules
Write-Host "=== Updated Modules ===" -ForegroundColor Cyan
$updatedModules | ForEach-Object { Write-Host $_ -ForegroundColor Green }

# Verify downloaded files
Write-Host "=== Verifying downloaded files ===" -ForegroundColor Cyan
$mainFiles = @(
    "$modulePath\$moduleName.psm1",
    "$modulePath\$moduleName.psd1"
)
foreach ($file in $mainFiles) {
    if (Test-Path $file) {
        Write-Host "Verified $(Split-Path -Leaf $file) exists." -ForegroundColor Green
    } else {
        Write-Host "Error: $(Split-Path -Leaf $file) not found!" -ForegroundColor Red
        exit 1
    }
}

foreach ($module in $modules) {
    $filePath = "$modulesPath\$module"
    if (Test-Path $filePath) {
        Write-Host "Verified $(Split-Path -Leaf $filePath) exists." -ForegroundColor Green
    } else {
        Write-Host "Error: $(Split-Path -Leaf $filePath) not verified correctly!" -ForegroundColor Red
        exit 1
    }
}

# Import the module into the current PowerShell session
Write-Host "=== Importing module ===" -ForegroundColor Cyan
try {
    Import-Module $moduleName -Force
    Write-Host "Module $moduleName imported successfully." -ForegroundColor Green
} catch {
    Write-Host "Error importing module ${moduleName}: $($_.Exception.Message)" -ForegroundColor Red
}

# Retrieve module information
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
