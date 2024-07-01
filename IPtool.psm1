$modulesPath = "$PSScriptRoot/modules"

Get-ChildItem -Path $modulesPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
    # Extraire et afficher la version du module
    $moduleVersion = (Select-String -Path $_.FullName -Pattern "# Version:" | Select-Object -First 1).Line
    $moduleVersion = $moduleVersion -replace "# Version: ", ""
    Write-Host "Loaded module: $($_.Name) (version: $moduleVersion)" -ForegroundColor Green
}

Export-ModuleMember -Function * -Alias *
