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

function Get-DNSProvider {
    param (
        [string]$domain
    )

    try {
        $dnsRecords = Resolve-DnsName -Name $domain -Type NS

        if ($dnsRecords) {
            Write-Host "=== DNS Provider Information ===" -ForegroundColor Cyan
            foreach ($record in $dnsRecords) {
                if ($record.NameHost) {
                    $dnsProvider = $record.NameHost
                    Write-Host "DNS Provider: $dnsProvider" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "No DNS records found for the domain." -ForegroundColor Red
        }
    } catch {
        Write-Host "DNS Query Error: $($_.Exception.Message)" -ForegroundColor Red
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

function Get-DefaultGateway {
    $gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1 -ExpandProperty NextHop
    return $gateway
}

function Test-SIPALG {
    param (
        [string]$ip,
        [int]$port
    )

    # Define a sample SIP INVITE request
    $sipRequest = @"
INVITE sip:user@example.com SIP/2.0
Via: SIP/2.0/UDP $($env:COMPUTERNAME):5060;rport;branch=z9hG4bK776asdhds
Max-Forwards: 70
To: <sip:user@example.com>
From: <sip:caller@$env:COMPUTERNAME>;tag=49583
Call-ID: 1234567890@$env:COMPUTERNAME
CSeq: 1 INVITE
Contact: <sip:caller@$env:COMPUTERNAME>
Content-Length: 0

"@

    # Convert SIP request to bytes
    $sipBytes = [System.Text.Encoding]::ASCII.GetBytes($sipRequest)

    # Create a UDP client
    $udpClient = New-Object System.Net.Sockets.UdpClient
    $udpClient.Connect($ip, $port)

    # Send the SIP request
    $udpClient.Send($sipBytes, $sipBytes.Length)

    # Set a timeout for receiving a response
    $udpClient.Client.ReceiveTimeout = 5000  # 5 seconds

    try {
        # Receive the response
        $remoteEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $responseBytes = $udpClient.Receive([ref]$remoteEndPoint)

        # Convert response bytes to string
        $responseString = [System.Text.Encoding]::ASCII.GetString($responseBytes)

        # Check for signs of SIP ALG in the response
        if ($responseString -match "Via: SIP/2.0/UDP.*rport") {
            Write-Host "SIP ALG likely not enabled on ${ip}:${port} (rport present in response)." -ForegroundColor Green
        } else {
            Write-Host "SIP ALG might be enabled on ${ip}:${port} (rport missing in response)." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "No response from ${ip}:${port}. SIP ALG not detected." -ForegroundColor Red
    } finally {
        # Close the UDP client
        $udpClient.Close()
    }
}

function CheckSIPALG {
    # Get the default gateway
    $defaultGateway = Get-DefaultGateway

    # Define the common SIP ports to scan
    $ports = @(5060, 5061)

    # Scan the default gateway for SIP ALG
    Write-Host "=== SIP ALG Detection ===" -ForegroundColor Cyan
    foreach ($port in $ports) {
        Write-Host "Testing ${defaultGateway}:${port}..." -ForegroundColor Yellow
        Test-SIPALG -ip $defaultGateway -port $port | Out-Null
    }
}

function Show-Help {
    Write-Host "iptool <ipOrDomain> /locate  - Retrieve geolocation information for the specified IP or domain." -ForegroundColor Yellow
    Write-Host "iptool <ipOrDomain> /DNS     - Retrieve DNS provider information for the specified domain." -ForegroundColor Yellow
    Write-Host "iptool /me                   - Retrieve your public IP address and geolocation information." -ForegroundColor Yellow
    Write-Host "iptool /alg                  - Check for SIP ALG on your default gateway." -ForegroundColor Yellow
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
    } else {
        switch ($option) {
            '/locate' {
                Get-GeoLocation -ipOrDomain $ipOrDomain
            }
            '/DNS' {
                Get-DNSProvider -domain $ipOrDomain
            }
            default {
                Write-Host "Unknown option: $option. Available options: /locate, /DNS, /me, /alg" -ForegroundColor Red
            }
        }
    }
}
