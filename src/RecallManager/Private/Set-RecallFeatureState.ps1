function Set-RecallFeatureState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][ValidateSet('None', 'Enable', 'Disable', 'DisableRemove')][string]$Action)

    if ($Action -eq 'None') { return [pscustomobject]@{ Action = 'None'; RestartNeeded = $false } }
    if ($Action -eq 'Enable') {
        if ($PSCmdlet.ShouldProcess('Windows optional feature Recall', 'Enable')) {
            $result = Enable-WindowsOptionalFeature -Online -FeatureName 'Recall' -All -NoRestart -ErrorAction Stop
            return [pscustomobject]@{ Action = 'Enable'; RestartNeeded = [bool]$result.RestartNeeded }
        }
    }
    elseif ($Action -in @('Disable', 'DisableRemove')) {
        $remove = $Action -eq 'DisableRemove'
        if ($PSCmdlet.ShouldProcess('Windows optional feature Recall', $Action)) {
            $parameters = @{ Online = $true; FeatureName = 'Recall'; NoRestart = $true; ErrorAction = 'Stop' }
            if ($remove) { $parameters.Remove = $true }
            $result = Disable-WindowsOptionalFeature @parameters
            return [pscustomobject]@{ Action = $Action; RestartNeeded = [bool]$result.RestartNeeded }
        }
    }
    return [pscustomobject]@{ Action = $Action; RestartNeeded = $false; Preview = $true }
}
