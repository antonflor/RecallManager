Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$script:ModuleRoot = $PSScriptRoot
$script:RepositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$script:ProfilePath = Join-Path $script:RepositoryRoot 'config\profiles.json'
$script:PolicyMachinePath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'
$script:PolicyUserPath = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'

Get-ChildItem (Join-Path $PSScriptRoot 'Private\*.ps1') | Sort-Object Name | ForEach-Object { . $_.FullName }
Get-ChildItem (Join-Path $PSScriptRoot 'Public\*.ps1') | Sort-Object Name | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function @(
    'Get-RecallStatus',
    'Get-RecallAudit',
    'Get-RecallPlan',
    'Set-RecallProfile',
    'Restore-RecallConfiguration',
    'Export-RecallReport'
)
