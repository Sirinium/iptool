@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'IPtool.psm1'

    # Version number of this module.
    ModuleVersion = '1.3.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'd6a86556-12f4-4c5a-94e4-25577a3776ec'

    # Author of this module
    Author = 'Sirinium'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = '(c) 2023 Sirinium. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Module IP and DNS tools'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @()

    # Scripts to execute in the caller's environment prior to importing this module
    ScriptsToProcess = @()

    # Type files to be loaded with this module
    TypesToProcess = @()

    # Formats files to be loaded with this module
    FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-GeoLocation',
        'Get-DNSProvider',
        'Get-MyIP',
        'Show-IPInfo',
        'Get-DefaultGateway',
        'Test-SIPALG',
        'CheckSIPALG',
        'Run-SpeedTest',
        'Get-SpeedTestDownloadLink',
        'Download-SpeedTestZip',
        'Extract-Zip',
        'Remove-File',
        'Remove-Files',
        'CheckSpeed',
        'Update-Module',
        'Show-Help',
        'iptool'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # DSC resources to export from this module
    DscResourcesToExport = @()

    # List of all files packaged with this module
    FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{}

    # HelpInfo URI of this module
    HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    DefaultCommandPrefix = ''
}
