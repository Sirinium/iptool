# IPtool - Module for IP and DNS Tools

![Version](https://img.shields.io/badge/version-1.2.0-blue)
![Status](https://img.shields.io/badge/status-beta-yellow)

## Overview

IPtool is a PowerShell module providing various tools for IP and DNS management. It includes functionalities for geolocation, DNS provider information, public IP retrieval, SIP ALG detection, speed testing, and module updates.

**Note:** This module is currently in beta. Use with caution and report any issues or feedback.

## Installation

1. Download the `install-IPtool.ps1` script from this repository.
2. Run the script in PowerShell:

   ```powershell
   ./install-IPtool.ps1
#Usage

### Get-GeoLocation: Retrieve geolocation information for a specified IP or domain.
iptool <ipOrDomain> /locate

### Get-DNSProvider: Retrieve DNS provider information for a specified domain.
iptool <ipOrDomain> /DNS

### Get-MyIP: Retrieve your public IP address and geolocation information.
iptool /me

### CheckSIPALG: Check for SIP ALG on your default gateway.
iptool /alg

### CheckSpeed: Run a speed test.
iptool /speed

### Update-Module: Update the IPtool module from GitHub.
iptool /update

### Show-Help: Show help message.
iptool

