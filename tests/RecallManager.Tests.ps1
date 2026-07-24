# Imported at file scope so the module is loaded during Pester's discovery phase,
# which is required for the top-level InModuleScope block further down. BeforeAll
# re-imports it for the run phase.
$modulePath = Join-Path $PSScriptRoot '..\src\RecallManager\RecallManager.psd1'
Import-Module $modulePath -Force

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\src\RecallManager\RecallManager.psd1'
    Import-Module $modulePath -Force
}

Describe 'RecallManager module surface' {
    It 'exports the expected public commands' {
        $expected = @('Get-RecallStatus','Get-RecallAudit','Get-RecallPlan','Set-RecallProfile','Restore-RecallConfiguration','Export-RecallReport')
        $actual = (Get-Command -Module RecallManager).Name
        foreach ($name in $expected) { $actual | Should -Contain $name }
    }

    It 'loads every declared profile' {
        foreach ($profile in @('AuditOnly', 'UserControlled', 'SnapshotsOff', 'PrivacyHardened')) {
            { Get-RecallPlan -Profile $profile } | Should -Not -Throw
        }
    }

    It 'marks privacy profiles that can delete snapshots as destructive' {
        (Get-RecallPlan -Profile SnapshotsOff).Destructive | Should -BeTrue
        (Get-RecallPlan -Profile PrivacyHardened).Destructive | Should -BeTrue
    }

    It 'does not mark AuditOnly as destructive' {
        (Get-RecallPlan -Profile AuditOnly).Destructive | Should -BeFalse
    }
}

Describe 'Effective state reasoning' {
    InModuleScope RecallManager {
        BeforeEach {
            Mock Get-RecallWindowsInfo {
                [pscustomobject]@{
                    IsWindows = $true; ProductName = 'Windows 11 Pro'; EditionId = 'Professional'
                    DisplayVersion = '24H2'; CurrentBuild = 26100; UBR = 5000
                    Architecture = '64-bit'; ComputerName = 'TESTPC'
                }
            }
            Mock Test-RecallAdministrator { $true }
        }

        It 'reports Disabled when the availability policy blocks Recall' {
            Mock Get-RecallFeatureState { [pscustomobject]@{ State = 'Enabled'; RestartNeeded = $false } }
            Mock Get-RecallPolicyState {
                @(
                    [pscustomobject]@{ Scope = 'Machine'; Name = 'AllowRecallEnablement'; Configured = $true; Value = 0 },
                    [pscustomobject]@{ Scope = 'Machine'; Name = 'DisableAIDataAnalysis'; Configured = $false; Value = $null },
                    [pscustomobject]@{ Scope = 'CurrentUser'; Name = 'DisableAIDataAnalysis'; Configured = $false; Value = $null }
                )
            }
            (Get-RecallStatus).EffectiveState | Should -Be 'Disabled'
        }

        It 'reports SnapshotsBlocked when snapshot saving is blocked' {
            Mock Get-RecallFeatureState { [pscustomobject]@{ State = 'Enabled'; RestartNeeded = $false } }
            Mock Get-RecallPolicyState {
                @(
                    [pscustomobject]@{ Scope = 'Machine'; Name = 'AllowRecallEnablement'; Configured = $false; Value = $null },
                    [pscustomobject]@{ Scope = 'Machine'; Name = 'DisableAIDataAnalysis'; Configured = $true; Value = 1 },
                    [pscustomobject]@{ Scope = 'CurrentUser'; Name = 'DisableAIDataAnalysis'; Configured = $false; Value = $null }
                )
            }
            (Get-RecallStatus).EffectiveState | Should -Be 'SnapshotsBlocked'
        }

        It 'reports UserControlled when no blocking state is detected' {
            Mock Get-RecallFeatureState { [pscustomobject]@{ State = 'Enabled'; RestartNeeded = $false } }
            Mock Get-RecallPolicyState {
                @(
                    [pscustomobject]@{ Scope = 'Machine'; Name = 'AllowRecallEnablement'; Configured = $false; Value = $null },
                    [pscustomobject]@{ Scope = 'Machine'; Name = 'DisableAIDataAnalysis'; Configured = $false; Value = $null },
                    [pscustomobject]@{ Scope = 'CurrentUser'; Name = 'DisableAIDataAnalysis'; Configured = $false; Value = $null }
                )
            }
            (Get-RecallStatus).EffectiveState | Should -Be 'UserControlled'
        }
    }
}
