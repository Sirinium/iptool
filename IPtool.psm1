$modulesPath = Join-Path $PSScriptRoot 'modules'
Get-ChildItem -Path $modulesPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function *
