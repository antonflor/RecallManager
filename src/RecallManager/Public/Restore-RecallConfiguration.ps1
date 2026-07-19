function Restore-RecallConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param([string]$BackupPath)

    if (-not (Test-RecallAdministrator)) { throw 'Restoring Recall configuration requires an elevated PowerShell session.' }
    if ([string]::IsNullOrWhiteSpace($BackupPath)) {
        $latest = Get-LatestRecallBackup
        if ($null -eq $latest) { throw 'No RecallManager backup was found.' }
        $BackupPath = $latest.FullName
    }
    if (-not (Test-Path $BackupPath)) { throw "Backup not found: $BackupPath" }

    $backup = Get-Content -Path $BackupPath -Raw | ConvertFrom-Json
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Restore Recall configuration from $BackupPath")) {
        foreach ($entry in $backup.Policies) {
            $value = if ($entry.Configured) { $entry.Value } else { $null }
            Set-RecallPolicyValue -Scope $entry.Scope -Name $entry.Name -Value $value -Confirm:$false
        }
        $featureAction = 'None'
        if ($backup.Feature.State -eq 'Enabled') { $featureAction = 'Enable' }
        elseif ($backup.Feature.State -eq 'Disabled') { $featureAction = 'Disable' }
        elseif ($backup.Feature.State -eq 'DisabledWithPayloadRemoved') { $featureAction = 'DisableRemove' }
        $featureResult = Set-RecallFeatureState -Action $featureAction -Confirm:$false
        $after = Get-RecallStatus
        return [pscustomobject]@{ BackupPath = $BackupPath; Restored = $true; RestartNeeded = [bool]($after.RestartNeeded -or $featureResult.RestartNeeded); Status = $after }
    }
}
