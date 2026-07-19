function Get-RecallStatus {
    [CmdletBinding()]
    param()

    $windows = Get-RecallWindowsInfo
    $feature = Get-RecallFeatureState
    $policies = @(Get-RecallPolicyState)
    $effective = Get-RecallEffectiveState -Feature $feature -Policies $policies

    [pscustomobject]@{
        TimestampUtc = (Get-Date).ToUniversalTime().ToString('o')
        ComputerName = $windows.ComputerName
        Windows = $windows
        IsAdministrator = Test-RecallAdministrator
        Feature = $feature
        Policies = $policies
        EffectiveState = $effective.State
        Explanation = $effective.Reason
        SnapshotDataAccess = 'Not inspected: Recall snapshot content is user-scoped, encrypted, and Windows Hello protected.'
        RestartNeeded = [bool]$feature.RestartNeeded
    }
}
