function Set-RecallProfile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('AuditOnly', 'UserControlled', 'SnapshotsOff', 'PrivacyHardened')]
        [string]$Profile
    )

    if ($Profile -eq 'AuditOnly') { return Get-RecallAudit }
    if (-not (Test-RecallAdministrator)) { throw 'Applying Recall profiles requires an elevated PowerShell session.' }

    $definition = Get-RecallProfileDefinition -Profile $Profile
    $before = Get-RecallStatus
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Apply Recall profile '$Profile'")) {
        $backupPath = Save-RecallConfigurationBackup -Status $before
        foreach ($property in $definition.machinePolicies.PSObject.Properties) { Set-RecallPolicyValue -Scope Machine -Name $property.Name -Value $property.Value -Confirm:$false }
        foreach ($property in $definition.userPolicies.PSObject.Properties) { Set-RecallPolicyValue -Scope CurrentUser -Name $property.Name -Value $property.Value -Confirm:$false }
        $featureResult = Set-RecallFeatureState -Action $definition.featureAction -Confirm:$false
        $after = Get-RecallStatus
        $verified = switch ($Profile) {
            'SnapshotsOff' { $after.EffectiveState -in @('SnapshotsBlocked', 'Disabled') }
            'PrivacyHardened' { $after.EffectiveState -eq 'Disabled' }
            'UserControlled' { $true }
            default { $false }
        }
        return [pscustomobject]@{
            Profile = $Profile; BackupPath = $backupPath; BeforeState = $before.EffectiveState; AfterState = $after.EffectiveState
            Verified = $verified; RestartNeeded = [bool]($after.RestartNeeded -or $featureResult.RestartNeeded); Status = $after
        }
    }
    return Get-RecallPlan -Profile $Profile
}
