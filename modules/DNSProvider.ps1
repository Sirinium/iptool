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
            Write-Host "No DNS records found for the domain ." -ForegroundColor Red
        }
    } catch {
        Write-Host "DNS Query Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host "Loaded module: DNSProvider.ps1" -ForegroundColor Green
