# Version: 1.0.5
function Show-Help {
    Write-Host "iptool <ipOrDomain> /locate  - Retrieve geolocation information for the specified IP or domain." -ForegroundColor Yellow
    Write-Host "iptool <ipOrDomain> /DNS     - Retrieve DNS provider information for the specified domain." -ForegroundColor Yellow
    Write-Host "iptool /me                   - Retrieve your public IP address and geolocation information." -ForegroundColor Yellow
    Write-Host "iptool /alg                  - Check for SIP ALG on your default gateway." -ForegroundColor Yellow
    Write-Host "iptool /speed                - Run a speed test." -ForegroundColor Yellow
    Write-Host "iptool /update               - Update the IPtool module from GitHub." -ForegroundColor Yellow
    Write-Host "iptool /v                    - Show version information for IPtool and its modules." -ForegroundColor Yellow
    Write-Host "iptool                       - Show this help message." -ForegroundColor Yellow
}

function Show-Version {
    Write-Host "=== IPtool Version Information ===" -ForegroundColor Cyan
    $modulesPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\IPtool\modules"
    $mainModule = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\IPtool\IPtool.psd1"
    
    if (Test-Path $mainModule) {
        $mainVersion = (Select-String -Path $mainModule -Pattern '# Version:' | Select-Object -First 1).Line.Split(':')[1].Trim()
        Write-Host "IPtool version: $mainVersion" -ForegroundColor Green
    } else {
        Write-Host "IPtool main module not found." -ForegroundColor Red
    }

    $modules = Get-ChildItem -Path $modulesPath -Filter *.ps1
    foreach ($module in $modules) {
        $version = (Select-String -Path $module.FullName -Pattern '# Version:' | Select-Object -First 1).Line.Split(':')[1].Trim()
        Write-Host "$($module.Name) version: $version" -ForegroundColor Green
    }
}

function iptool {
    param (
        [string]$ipOrDomain = $null,
        [string]$option = $null
    )

    if (-not $ipOrDomain -and -not $option) {
        Show-Help
    } elseif ($ipOrDomain -eq '/me') {
        Get-MyIP
    } elseif ($ipOrDomain -eq '/alg') {
        CheckSIPALG
    } elseif ($ipOrDomain -eq '/speed') {
        CheckSpeed -ScriptArgs $null
    } elseif ($ipOrDomain -eq '/update') {
        Update-Module
    } elseif ($ipOrDomain -eq '/v') {
        Show-Version
    } else {
        switch ($option) {
            '/locate' {
                Get-GeoLocation -ipOrDomain $ipOrDomain
            }
            '/DNS' {
                Get-DNSProvider -domain $ipOrDomain
            }
            default {
                Write-Host "Unknown option: $option. Available options: /locate, /DNS, /me, /alg, /speed, /update, -v" -ForegroundColor Red
            }
        }
    }
}
