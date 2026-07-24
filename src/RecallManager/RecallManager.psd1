@{
    RootModule        = 'RecallManager.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '6a4293ad-25f9-49b4-b9dc-851c320794f5'
    Author            = 'Tony Flores'
    CompanyName       = 'Community'
    Copyright         = '(c) 2024-2026 Tony Flores. MIT License.'
    Description       = 'Audit, explain, configure, verify, and restore Windows Recall privacy state.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-RecallStatus',
        'Get-RecallAudit',
        'Get-RecallPlan',
        'Set-RecallProfile',
        'Restore-RecallConfiguration',
        'Export-RecallReport'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('Windows11', 'Recall', 'Privacy', 'Security', 'PowerShell')
            LicenseUri = 'https://github.com/antonflor/RecallManager/blob/main/LICENSE'
            ProjectUri = 'https://github.com/antonflor/RecallManager'
        }
    }
}
