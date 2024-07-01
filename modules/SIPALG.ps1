# Version: 1.0.0
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
