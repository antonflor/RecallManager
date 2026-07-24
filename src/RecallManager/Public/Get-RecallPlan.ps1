function Get-RecallPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('AuditOnly', 'UserControlled', 'SnapshotsOff', 'PrivacyHardened')]
        [string]$Profile
    )

    $definition = Get-RecallProfileDefinition -Profile $Profile
    $steps = New-Object System.Collections.Generic.List[object]
    $order = 1
    foreach ($property in $definition.machinePolicies.PSObject.Properties) {
        $action = if ($null -eq $property.Value) { 'Remove policy override' } else { "Set to $($property.Value)" }
        $steps.Add([pscustomobject]@{ Order = $order; Scope = 'Machine'; Target = $property.Name; Action = $action }); $order++
    }
    foreach ($property in $definition.userPolicies.PSObject.Properties) {
        $action = if ($null -eq $property.Value) { 'Remove policy override' } else { "Set to $($property.Value)" }
        $steps.Add([pscustomobject]@{ Order = $order; Scope = 'CurrentUser'; Target = $property.Name; Action = $action }); $order++
    }
    if ($definition.featureAction -ne 'None') { $steps.Add([pscustomobject]@{ Order = $order; Scope = 'Windows'; Target = 'Recall optional feature'; Action = $definition.featureAction }); $order++ }
    if ($Profile -ne 'AuditOnly') {
        $steps.Insert(0, [pscustomobject]@{ Order = 0; Scope = 'RecallManager'; Target = 'Current configuration'; Action = 'Back up before changes' })
        $steps.Add([pscustomobject]@{ Order = $order; Scope = 'RecallManager'; Target = 'Effective state'; Action = 'Re-audit and verify' })
    }

    [pscustomobject]@{
        Profile = $Profile; Description = $definition.description; Destructive = [bool]$definition.destructive
        RequiresAdmin = $Profile -ne 'AuditOnly'; MayDeleteData = $Profile -in @('SnapshotsOff', 'PrivacyHardened')
        RestartMayBeNeeded = $definition.featureAction -ne 'None'; Steps = $steps.ToArray()
    }
}
