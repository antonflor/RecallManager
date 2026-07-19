function Get-RecallEffectiveState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Feature,
        [Parameter(Mandatory = $true)][object[]]$Policies
    )

    $allow = $Policies | Where-Object { $_.Scope -eq 'Machine' -and $_.Name -eq 'AllowRecallEnablement' } | Select-Object -First 1
    $machineSnapshots = $Policies | Where-Object { $_.Scope -eq 'Machine' -and $_.Name -eq 'DisableAIDataAnalysis' } | Select-Object -First 1
    $userSnapshots = $Policies | Where-Object { $_.Scope -eq 'CurrentUser' -and $_.Name -eq 'DisableAIDataAnalysis' } | Select-Object -First 1

    $availabilityBlocked = $false
    if ($null -ne $allow -and $allow.Configured) { $availabilityBlocked = [int]$allow.Value -eq 0 }
    $machineBlocked = $false
    if ($null -ne $machineSnapshots -and $machineSnapshots.Configured) { $machineBlocked = [int]$machineSnapshots.Value -eq 1 }
    $userBlocked = $false
    if ($null -ne $userSnapshots -and $userSnapshots.Configured) { $userBlocked = [int]$userSnapshots.Value -eq 1 }

    $snapshotBlocked = $machineBlocked -or $userBlocked
    $featureUnavailable = $Feature.State -in @('Disabled','DisablePending','DisabledWithPayloadRemoved','Unavailable','UnsupportedPlatform')

    if ($availabilityBlocked -or $featureUnavailable) {
        $state = 'Disabled'
        $reason = if ($availabilityBlocked) { 'Recall availability is blocked by machine policy.' } else { "The Recall optional feature state is $($Feature.State)." }
    }
    elseif ($snapshotBlocked) {
        $state = 'SnapshotsBlocked'
        $reason = 'Recall may be installed, but saving snapshots is blocked by policy.'
    }
    else {
        $state = 'UserControlled'
        $reason = 'No blocking policy was detected; the signed-in user remains responsible for opt-in choices.'
    }

    [pscustomobject]@{ State = $state; Reason = $reason; AvailabilityBlocked = $availabilityBlocked; SnapshotSavingBlocked = $snapshotBlocked }
}
