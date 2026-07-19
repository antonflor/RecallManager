function Get-RecallBackupDirectory {
    [CmdletBinding()]
    param()
    $base = if ($env:ProgramData) { $env:ProgramData } else { $env:TEMP }
    return Join-Path $base 'RecallManager\Backups'
}

function Save-RecallConfigurationBackup {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Status)

    $directory = Get-RecallBackupDirectory
    New-Item -Path $directory -ItemType Directory -Force | Out-Null
    $path = Join-Path $directory ('recall-backup-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $backup = [ordered]@{
        SchemaVersion = 1
        CreatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        ComputerName = $env:COMPUTERNAME
        Feature = $Status.Feature
        Policies = $Status.Policies
    }
    $backup | ConvertTo-Json -Depth 8 | Set-Content -Path $path -Encoding UTF8
    return $path
}

function Get-LatestRecallBackup {
    [CmdletBinding()]
    param()
    $directory = Get-RecallBackupDirectory
    if (-not (Test-Path $directory)) { return $null }
    return Get-ChildItem -Path $directory -Filter 'recall-backup-*.json' | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
}
