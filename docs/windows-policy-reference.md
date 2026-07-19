# Windows Recall policy reference

RecallManager v1 uses documented Windows AI policy names and the Windows optional-feature cmdlets.

| Purpose | Policy value | Scope used by RecallManager |
|---|---|---|
| Allow or block Recall availability | `AllowRecallEnablement` | Machine |
| Turn off snapshot saving | `DisableAIDataAnalysis` | Machine and current user |
| Maximum snapshot storage | `SetMaximumStorageSpaceForRecallSnapshots` | Audit only in v1 |
| Maximum retention | `SetMaximumStorageDurationForRecallSnapshots` | Audit only in v1 |
| URI exclusions | `SetDenyUriListForRecall` | Audit only in v1 |
| App exclusions | `SetDenyAppListForRecall` | Audit only in v1 |
| DLP provider | `SetDataLossPreventionProvider` | Audit only in v1 |
| EEA export control | `AllowRecallExport` | Audit only in v1 |

Registry policy path:

```text
SOFTWARE\Policies\Microsoft\Windows\WindowsAI
```

Official references:

- https://learn.microsoft.com/windows/client-management/manage-recall
- https://learn.microsoft.com/windows/client-management/mdm/policy-csp-windowsai
- https://learn.microsoft.com/powershell/module/dism/get-windowsoptionalfeature
- https://learn.microsoft.com/powershell/module/dism/enable-windowsoptionalfeature
- https://learn.microsoft.com/powershell/module/dism/disable-windowsoptionalfeature

Policy and feature behavior can change with Windows servicing. Revalidate destructive behavior before each stable release.
