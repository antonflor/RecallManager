function Get-RecallProfileDefinition {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Profile)

    if (-not (Test-Path $script:ProfilePath)) { throw "Profile file not found: $script:ProfilePath" }
    $configuration = Get-Content -Path $script:ProfilePath -Raw | ConvertFrom-Json
    $definition = $configuration.profiles.PSObject.Properties[$Profile]
    if ($null -eq $definition) { throw "Unknown profile '$Profile'." }
    return $definition.Value
}
