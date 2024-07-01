$modulesPath = "$PSScriptRoot/modules"

Get-ChildItem -Path $modulesPath -Filter *.ps1 | ForEach-Object {
    try {
        . $_.FullName
        Write-Host "Loaded module: $($_.Name)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to load module: $($_.Name)" -ForegroundColor Red
    }
}

Export-ModuleMember -Function * -Alias *
