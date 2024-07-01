function Show-Help {
    Write-Host "iptool <ipOrDomain> /locate  - Retrieve geolocation information for the specified IP or domain." -ForegroundColor Yellow
    Write-Host "iptool <ipOrDomain> /DNS     - Retrieve DNS provider information for the specified domain." -ForegroundColor Yellow
    Write-Host "iptool /me                   - Retrieve your public IP address and geolocation information." -ForegroundColor Yellow
    Write-Host "iptool /alg                  - Check for SIP ALG on your default gateway." -ForegroundColor Yellow
    Write-Host "iptool /speed                - Run a speed test." -ForegroundColor Yellow
    Write-Host "iptool /update               - Update the IPtool module from GitHub." -ForegroundColor Yellow
    Write-Host "iptool                       - Show this help message." -ForegroundColor Yellow
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
    } else {
        switch ($option) {
            '/locate' {
                Get-GeoLocation -ipOrDomain $ipOrDomain
            }
            '/DNS' {
                Get-DNSProvider -domain $ipOrDomain
            }
            default {
                Write-Host "Unknown option: $option. Available options: /locate, /DNS, /me, /alg, /speed, /update" -ForegroundColor Red
            }
        }
    }
}

Write-Host "Loaded module: Utility.ps1" -ForegroundColor Green
