<#
.SYNOPSIS
    Command-line entry point for RecallManager.

.DESCRIPTION
    Audits, explains, plans, applies, verifies, and rolls back supported
    Windows Recall configuration. Run elevated for changes; audit commands can
    run without elevation.
#>
[CmdletBinding()]
param(
    [ValidateSet('Interactive', 'Status', 'Audit', 'Plan', 'Apply', 'Restore', 'Export')]
    [string]$Command = 'Interactive',

    [ValidateSet('AuditOnly', 'UserControlled', 'SnapshotsOff', 'PrivacyHardened')]
    [string]$Profile = 'AuditOnly',

    [ValidateSet('Text', 'Json')]
    [string]$Format = 'Text',

    [string]$OutputPath,
    [string]$BackupPath,
    [switch]$Yes,
    [switch]$Preview
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'src\RecallManager\RecallManager.psd1'
Import-Module $modulePath -Force

function Write-RecallObject {
    param([Parameter(Mandatory = $true)]$InputObject)

    if ($Format -eq 'Json') {
        $InputObject | ConvertTo-Json -Depth 8
    }
    else {
        $InputObject | Format-List
    }
}

function Invoke-InteractiveMenu {
    Write-Host ''
    Write-Host 'RecallManager' -ForegroundColor Cyan
    Write-Host 'Audit, explain, and control Windows Recall.'
    Write-Host ''
    Write-Host '[1] Show status'
    Write-Host '[2] Run privacy audit'
    Write-Host '[3] Preview SnapshotsOff plan'
    Write-Host '[4] Preview PrivacyHardened plan'
    Write-Host '[5] Apply SnapshotsOff profile'
    Write-Host '[6] Apply PrivacyHardened profile'
    Write-Host '[7] Restore latest backup'
    Write-Host '[Q] Quit'

    $selection = Read-Host 'Choose an action'
    switch ($selection.ToUpperInvariant()) {
        '1' { Write-RecallObject (Get-RecallStatus) }
        '2' { Write-RecallObject (Get-RecallAudit) }
        '3' { Write-RecallObject (Get-RecallPlan -Profile SnapshotsOff) }
        '4' { Write-RecallObject (Get-RecallPlan -Profile PrivacyHardened) }
        '5' { Set-RecallProfile -Profile SnapshotsOff }
        '6' { Set-RecallProfile -Profile PrivacyHardened }
        '7' { Restore-RecallConfiguration -BackupPath $BackupPath }
        'Q' { return }
        default { Write-Warning 'Unknown selection.' }
    }
}

try {
    switch ($Command) {
        'Interactive' { Invoke-InteractiveMenu }
        'Status' { Write-RecallObject (Get-RecallStatus) }
        'Audit' { Write-RecallObject (Get-RecallAudit) }
        'Plan' { Write-RecallObject (Get-RecallPlan -Profile $Profile) }
        'Apply' {
            $confirmPreference = -not $Yes.IsPresent
            Set-RecallProfile -Profile $Profile -Confirm:$confirmPreference -WhatIf:$Preview
        }
        'Restore' {
            $confirmPreference = -not $Yes.IsPresent
            Restore-RecallConfiguration -BackupPath $BackupPath -Confirm:$confirmPreference -WhatIf:$Preview
        }
        'Export' {
            if ([string]::IsNullOrWhiteSpace($OutputPath)) {
                $OutputPath = Join-Path (Get-Location) ('RecallManager-Audit-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
            }
            Export-RecallReport -Path $OutputPath
            Write-Host "Audit report written to $OutputPath"
        }
    }
}
catch {
    Write-Error $_
    exit 1
}
