function Get-RecallPolicyEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Scope
    )

    $value = $null
    $configured = $false
    if (Test-Path $Path) {
        $item = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
        if ($null -ne $item -and $null -ne $item.PSObject.Properties[$Name]) {
            $value = $item.$Name
            $configured = $true
        }
    }

    [pscustomobject]@{ Scope = $Scope; Name = $Name; Configured = $configured; Value = $value; Path = $Path }
}

function Get-RecallPolicyState {
    [CmdletBinding()]
    param()
    if ($env:OS -ne 'Windows_NT') { return @() }

    $entries = @()
    foreach ($name in @('AllowRecallEnablement','DisableAIDataAnalysis','SetMaximumStorageSpaceForRecallSnapshots','SetMaximumStorageDurationForRecallSnapshots','SetDenyUriListForRecall','SetDenyAppListForRecall','SetDataLossPreventionProvider','AllowRecallExport')) {
        $entries += Get-RecallPolicyEntry -Path $script:PolicyMachinePath -Name $name -Scope 'Machine'
    }
    foreach ($name in @('DisableAIDataAnalysis','SetMaximumStorageSpaceForRecallSnapshots','SetMaximumStorageDurationForRecallSnapshots','SetDenyUriListForRecall','SetDenyAppListForRecall')) {
        $entries += Get-RecallPolicyEntry -Path $script:PolicyUserPath -Name $name -Scope 'CurrentUser'
    }
    return $entries
}
