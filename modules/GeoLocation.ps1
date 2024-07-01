# Version: 1.0.0
function Get-GeoLocation {
    param (
        [string]$ipOrDomain
    )

    if (-not [System.Net.IPAddress]::TryParse($ipOrDomain, [ref]$null)) {
        try {
            $ip = [System.Net.Dns]::GetHostAddresses($ipOrDomain)[0].IPAddressToString
            Write-Host "Resolved domain $ipOrDomain to IP $ip" -ForegroundColor Yellow
        } catch {
            Write-Host "Invalid IP Address or Domain. Please enter a valid IP or Domain." -ForegroundColor Red
            return
        }
    } else {
        $ip = $ipOrDomain
    }

    $url = "https://ipinfo.io/$ip/json"

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get

        if ($response) {
            $ipInfo = [PSCustomObject]@{
                City      = $response.city
                Region    = $response.region
                Country   = $response.country
                Loc       = $response.loc
                Org       = $response.org
                Postal    = $response.postal
                Timezone  = $response.timezone
            }

            Show-IPInfo -ipInfo $ipInfo
        } else {
            Write-Host "No response received from IP information service." -ForegroundColor Red
        }
    } catch {
        Write-Host "HTTP Request Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-IPInfo {
    param (
        [PSCustomObject]$ipInfo,
        [bool]$showIP = $false
    )

    Write-Host "=== Geolocation Information ===" -ForegroundColor Cyan
    if ($showIP) {
        Write-Host "IP Address: $($ipInfo.IP)" -ForegroundColor Green
    }
    Write-Host "Country: $($ipInfo.Country)" -ForegroundColor Green
    Write-Host "City: $($ipInfo.City)" -ForegroundColor Green
    Write-Host "Coordinates: $($ipInfo.Loc)" -ForegroundColor Green
    Write-Host "Postal Code: $($ipInfo.Postal)" -ForegroundColor Green
    Write-Host "Region: $($ipInfo.Region)" -ForegroundColor Green
    Write-Host "ASN: $($ipInfo.Org)" -ForegroundColor Green

    if ($ipInfo.Loc) {
        $coords = $ipInfo.Loc -split ','
        Write-Host "Google Maps: https://www.google.com/maps/?q=$($coords[0]),$($coords[1])" -ForegroundColor Blue
    }
}

function Get-MyIP {
    $url = "https://ipinfo.io/json"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get

        if ($response) {
            $ipInfo = [PSCustomObject]@{
                IP        = $response.ip
                City      = $response.city
                Region    = $response.region
                Country   = $response.country
                Loc       = $response.loc
                Org       = $response.org
                Postal    = $response.postal
                Timezone  = $response.timezone
            }

            Show-IPInfo -ipInfo $ipInfo -showIP $true

        } else {
            Write-Host "No response received from IP information service." -ForegroundColor Red
        }
    } catch {
        Write-Host "HTTP Request Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
