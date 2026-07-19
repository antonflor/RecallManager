function Export-RecallReport {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path)

    $parent = Split-Path $Path -Parent
    if ($parent -and -not (Test-Path $parent)) { New-Item -Path $parent -ItemType Directory -Force | Out-Null }
    Get-RecallAudit | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
    return Get-Item $Path
}
