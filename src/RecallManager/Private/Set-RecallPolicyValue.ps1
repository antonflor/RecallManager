function Set-RecallPolicyValue {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Machine', 'CurrentUser')][string]$Scope,
        [Parameter(Mandatory = $true)][string]$Name,
        [AllowNull()]$Value
    )

    $path = if ($Scope -eq 'Machine') { $script:PolicyMachinePath } else { $script:PolicyUserPath }
    if ($null -eq $Value) {
        if ((Test-Path $path) -and $PSCmdlet.ShouldProcess("$Scope policy $Name", 'Remove policy override')) {
            Remove-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue
        }
        return
    }

    if ($PSCmdlet.ShouldProcess("$Scope policy $Name", "Set value to $Value")) {
        New-Item -Path $path -Force | Out-Null
        $propertyType = if ($Value -is [string]) { 'String' } else { 'DWord' }
        New-ItemProperty -Path $path -Name $Name -Value $Value -PropertyType $propertyType -Force | Out-Null
    }
}
