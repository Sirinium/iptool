# Version: 1.0.0
function Get-SpeedTestDownloadLink {
    try {
        $url = "https://www.speedtest.net/apps/cli"
        $webContent = Invoke-WebRequest -Uri $url -UseBasicParsing
        if ($webContent.Content -match 'href="(https://install\.speedtest\.net/app/cli/ookla-speedtest-[\d\.]+-win64\.zip)"') {
            return $matches[1]
        } else {
            Write-Host "Unable to find the win64 zip download link." -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Error "Error retrieving download link: $_"
        return $null
    }
}

function Get-SpeedTestZip {
    param (
        [string]$downloadLink,
        [string]$destination
    )
    try {
        Invoke-WebRequest -Uri $downloadLink -OutFile $destination -UseBasicParsing
    } catch {
        Write-Error "Error downloading zip file: $_"
    }
}

function Expand-Zip {
    param (
        [string]$zipPath,
        [string]$destination
    )
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destination)
    } catch {
        Write-Error "Error extracting zip file: $_"
    }
}

function invoke-SpeedTest {
    param (
        [string]$executablePath,
        [array]$arguments
    )
    if (-not ($arguments -contains "--accept-license")) {
        $arguments += "--accept-license"
    }
    if (-not ($arguments -contains "--accept-gdpr")) {
        $arguments += "--accept-gdpr"
    }
    try {
        & $executablePath $arguments
    } catch {
        Write-Error "Error running SpeedTest: $_"
    }
}

function Remove-File {
    param (
        [string]$Path
    )
    try {
        if (Test-Path -Path $Path) {
            Remove-Item -Path $Path -Recurse -ErrorAction Stop
        }
    } catch {
        Write-Error "Unable to remove item: $_"
    }
}

function Remove-Files {
    param(
        [string]$zipPath,
        [string]$folderPath
    )
    Remove-File -Path $zipPath
    Remove-File -Path $folderPath
}

function CheckSpeed {
    param (
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$ScriptArgs
    )

    try {
        $tempFolder = $env:TEMP
        $zipFilePath = Join-Path $tempFolder "speedtest-win64.zip"
        $extractFolderPath = Join-Path $tempFolder "speedtest-win64"

        Remove-Files -zipPath $zipFilePath -folderPath $extractFolderPath

        $downloadLink = Get-SpeedTestDownloadLink
        if ($downloadLink) {
            Get-SpeedTestZip -downloadLink $downloadLink -destination $zipFilePath
            Expand-Zip -zipPath $zipFilePath -destination $extractFolderPath
            $executablePath = Join-Path $extractFolderPath "speedtest.exe"
            invoke-SpeedTest -executablePath $executablePath -arguments $ScriptArgs
            Remove-Files -zipPath $zipFilePath -folderPath $extractFolderPath
        } else {
            Write-Host "Failed to retrieve download link. Exiting script." -ForegroundColor Red
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}

Write-Host "Loaded module: SpeedTest.ps1" -ForegroundColor Green
