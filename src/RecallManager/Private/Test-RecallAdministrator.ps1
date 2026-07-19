function Test-RecallAdministrator {
    [CmdletBinding()]
    param()

    if ($env:OS -ne 'Windows_NT') { return $false }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
