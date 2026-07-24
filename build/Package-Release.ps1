[CmdletBinding()]
param(
    [string]$Version = '1.0.0-beta.1',
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\dist')
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path $PSScriptRoot -Parent
$stage = Join-Path $env:TEMP ('RecallManager-{0}' -f $Version)
$archive = Join-Path $OutputDirectory ('RecallManager-{0}.zip' -f $Version)

Remove-Item -Path $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path $stage -ItemType Directory -Force | Out-Null
New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null

$include = @('RecallManager.ps1','README.md','CHANGELOG.md','LICENSE','SECURITY.md','config','src')
foreach ($item in $include) {
    Copy-Item -Path (Join-Path $repositoryRoot $item) -Destination $stage -Recurse -Force
}

Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -Force
$hash = Get-FileHash -Path $archive -Algorithm SHA256
$hashLine = '{0}  {1}' -f $hash.Hash.ToLowerInvariant(), (Split-Path $archive -Leaf)
$hashLine | Set-Content -Path ($archive + '.sha256') -Encoding ASCII

Remove-Item -Path $stage -Recurse -Force
Get-Item $archive, ($archive + '.sha256')
