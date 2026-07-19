function Get-RecallFeatureState {
    [CmdletBinding()]
    param()

    if ($env:OS -ne 'Windows_NT') {
        return [pscustomobject]@{
            Name = 'Recall'; State = 'UnsupportedPlatform'; RestartNeeded = $false
            Source = 'PlatformCheck'; Error = $null
        }
    }

    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName 'Recall' -ErrorAction Stop
        return [pscustomobject]@{
            Name = 'Recall'; State = [string]$feature.State; RestartNeeded = [bool]$feature.RestartNeeded
            Source = 'Get-WindowsOptionalFeature'; Error = $null
        }
    }
    catch {
        return [pscustomobject]@{
            Name = 'Recall'; State = 'Unavailable'; RestartNeeded = $false
            Source = 'Get-WindowsOptionalFeature'; Error = $_.Exception.Message
        }
    }
}
