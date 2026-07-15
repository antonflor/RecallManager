<#
.SYNOPSIS
    Check, enable, or disable the Windows Recall feature using DISM.

.DESCRIPTION
    Queries the current state of the "Recall" optional feature and prompts the
    user to enable or disable it. Requires Administrator privileges (DISM).
    A restart may be required for changes to take effect.

.NOTES
    Author : Tony Flores (https://github.com/antonflor)
    License: MIT
#>

# Query the current state of the Recall feature.
# Returns $true (enabled), $false (disabled), or $null (unknown/unavailable).
function Get-RecallStatus {
    $featureInfo = dism /Online /Get-FeatureInfo /FeatureName:Recall /English
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Unable to query the Recall feature (DISM exit code $LASTEXITCODE)."
        Write-Host "Recall may not be available on this edition or build of Windows."
        return $null
    }

    if ($featureInfo -match 'State : Enable') {
        Write-Host "Recall is currently ENABLED."
        return $true
    } elseif ($featureInfo -match 'State : Disable') {
        Write-Host "Recall is currently DISABLED."
        return $false
    }

    Write-Host "Unable to determine the status of Recall."
    return $null
}

# Report the result of a DISM enable/disable operation based on its exit code.
function Show-DismResult {
    param([string]$Action)

    switch ($LASTEXITCODE) {
        0       { Write-Host "Recall has been successfully $Action." }
        3010    { Write-Host "Recall has been $Action. A RESTART is required to complete the change." }
        default { Write-Host "Failed to $($Action -replace 'd$','') Recall (DISM exit code $LASTEXITCODE)." }
    }
}

function Disable-Recall {
    Write-Host "Disabling Recall..."
    dism /Online /Disable-Feature /FeatureName:Recall /NoRestart
    Show-DismResult -Action 'disabled'
}

function Enable-Recall {
    Write-Host "Enabling Recall..."
    dism /Online /Enable-Feature /FeatureName:Recall /NoRestart
    Show-DismResult -Action 'enabled'
}

# --- Main ---

# DISM requires an elevated session.
$identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires running as Administrator!"
    Pause
    exit 1
}

$status = Get-RecallStatus

if ($status -eq $true) {
    $response = Read-Host "Recall is enabled. Do you want to disable it? (Y/N)"
    if ($response -eq 'Y') {
        Disable-Recall
    } else {
        Write-Host "No changes made."
    }
} elseif ($status -eq $false) {
    $response = Read-Host "Recall is disabled. Do you want to enable it? (Y/N)"
    if ($response -eq 'Y') {
        Enable-Recall
    } else {
        Write-Host "No changes made."
    }
} else {
    exit 1
}
