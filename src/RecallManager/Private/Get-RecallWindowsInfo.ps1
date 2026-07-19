function Get-RecallWindowsInfo {
    [CmdletBinding()]
    param()

    $isWindows = $env:OS -eq 'Windows_NT'
    if (-not $isWindows) {
        return [pscustomobject]@{
            IsWindows       = $false
            ProductName     = $null
            EditionId       = $null
            DisplayVersion  = $null
            CurrentBuild    = $null
            UBR             = $null
            Architecture    = if ([Environment]::Is64BitOperatingSystem) { '64-bit' } else { '32-bit' }
            ComputerName    = $env:COMPUTERNAME
        }
    }

    $cv = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    [pscustomobject]@{
        IsWindows       = $true
        ProductName     = $cv.ProductName
        EditionId       = $cv.EditionID
        DisplayVersion  = $cv.DisplayVersion
        CurrentBuild    = [int]$cv.CurrentBuildNumber
        UBR             = [int]$cv.UBR
        Architecture    = if ([Environment]::Is64BitOperatingSystem) { '64-bit' } else { '32-bit' }
        ComputerName    = $env:COMPUTERNAME
    }
}
