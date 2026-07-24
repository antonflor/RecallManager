function Get-RecallAudit {
    [CmdletBinding()]
    param()

    $status = Get-RecallStatus
    $findings = New-Object System.Collections.Generic.List[object]
    if (-not $status.Windows.IsWindows) { $findings.Add([pscustomobject]@{ Severity = 'Error'; Code = 'UnsupportedPlatform'; Message = 'RecallManager changes require Windows.' }) }
    if ($status.Windows.IsWindows -and $status.Windows.CurrentBuild -lt 26100) { $findings.Add([pscustomobject]@{ Severity = 'Info'; Code = 'OlderBuild'; Message = 'This Windows build predates the supported Windows 11 24H2 Recall policy baseline.' }) }
    if ($status.Feature.State -eq 'Unavailable') { $findings.Add([pscustomobject]@{ Severity = 'Info'; Code = 'FeatureUnavailable'; Message = 'The Recall optional feature was not found or could not be queried on this device.' }) }
    if ($status.EffectiveState -eq 'UserControlled') { $findings.Add([pscustomobject]@{ Severity = 'Warning'; Code = 'UserControlled'; Message = 'No blocking Recall policy was detected. Snapshot saving remains dependent on device eligibility and user opt-in.' }) }
    if ($status.EffectiveState -eq 'SnapshotsBlocked') { $findings.Add([pscustomobject]@{ Severity = 'Pass'; Code = 'SnapshotsBlocked'; Message = 'Snapshot saving is blocked by policy while the component may remain installed.' }) }
    if ($status.EffectiveState -eq 'Disabled') { $findings.Add([pscustomobject]@{ Severity = 'Pass'; Code = 'RecallDisabled'; Message = 'Recall availability is blocked or the optional component is disabled/unavailable.' }) }

    $configuredPolicies = @($status.Policies | Where-Object { $_.Configured })
    $score = 100
    if ($status.EffectiveState -eq 'UserControlled') { $score = 50 }
    elseif ($status.EffectiveState -eq 'SnapshotsBlocked') { $score = 85 }

    [pscustomobject]@{
        TimestampUtc = $status.TimestampUtc
        ComputerName = $status.ComputerName
        EffectiveState = $status.EffectiveState
        PrivacyScore = $score
        Explanation = $status.Explanation
        Feature = $status.Feature
        ConfiguredPolicies = $configuredPolicies
        Findings = $findings.ToArray()
        Recommendations = @(
            'Run Plan before Apply to review every intended change.',
            'Use SnapshotsOff when you want policy enforcement without removing the component.',
            'Use PrivacyHardened only when you accept component removal and possible deletion of existing snapshots by Windows policy behavior.',
            'Capture screenshots for the documentation only after validating the workflow on a supported test device.'
        )
    }
}
