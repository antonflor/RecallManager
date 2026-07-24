# Architecture

RecallManager separates inspection, reasoning, planning, mutation, verification, and presentation. The PowerShell module is the product engine; the current CLI and any future desktop interface should call the same exported commands.

## Component model

```mermaid
flowchart TB
    subgraph Interfaces
        CLI[RecallManager.ps1 CLI]
        MENU[Interactive menu]
        FUTURE[Future desktop GUI]
        RMM[RMM / Intune / automation]
    end

    subgraph PublicModule[Public module commands]
        STATUS[Get-RecallStatus]
        AUDIT[Get-RecallAudit]
        PLAN[Get-RecallPlan]
        APPLY[Set-RecallProfile]
        RESTORE[Restore-RecallConfiguration]
        EXPORT[Export-RecallReport]
    end

    subgraph Detection[Detection layer]
        WIN[Windows build and edition]
        FEATURE[Optional feature state]
        MPOL[Machine policy]
        UPOL[Current-user policy]
    end

    subgraph Mutation[Controlled mutation layer]
        BACKUP[JSON backup]
        POLICY[Policy writer]
        DISM[Windows optional-feature cmdlets]
        VERIFY[Post-change reinspection]
    end

    CLI --> PublicModule
    MENU --> PublicModule
    FUTURE --> PublicModule
    RMM --> PublicModule
    STATUS --> Detection
    AUDIT --> STATUS
    PLAN --> Detection
    APPLY --> BACKUP --> POLICY
    APPLY --> DISM
    POLICY --> VERIFY
    DISM --> VERIFY
    RESTORE --> BACKUP
    EXPORT --> AUDIT
```

## Effective-state evaluation

The optional feature and policy layers can disagree. RecallManager normalizes them into one of three operator-facing states.

```mermaid
flowchart TD
    A[Read optional feature] --> D{Availability policy = 0?}
    B[Read machine policy] --> D
    C[Read current-user policy] --> D
    D -->|Yes| X[Disabled]
    D -->|No| E{Feature disabled, removed, or unavailable?}
    E -->|Yes| X
    E -->|No| F{DisableAIDataAnalysis = 1 at either scope?}
    F -->|Yes| Y[SnapshotsBlocked]
    F -->|No| Z[UserControlled]
```

`UserControlled` does not mean snapshots are actively being saved. Microsoft requires user opt-in; it means RecallManager did not detect a blocking policy or unavailable component.

## Change transaction

```mermaid
sequenceDiagram
    actor Operator
    participant CLI
    participant Plan
    participant Backup
    participant Windows
    participant Verify

    Operator->>CLI: Apply profile
    CLI->>Plan: Resolve desired state
    Plan-->>Operator: Confirmation / WhatIf output
    Operator->>CLI: Confirm
    CLI->>Backup: Save current feature and policies
    Backup-->>CLI: Backup path
    CLI->>Windows: Apply policy values
    CLI->>Windows: Change optional feature if required
    CLI->>Verify: Re-run full status inspection
    Verify-->>Operator: Before, after, restart requirement
```

## Data boundaries

RecallManager reads configuration metadata only:

- Windows version and edition;
- Recall optional-feature state;
- documented Windows AI policy values;
- RecallManager-created backup metadata.

It does not read or decrypt Recall snapshots, search indexes, databases, exported snapshot packages, or Windows Hello-protected content.

## Extension points

The module can later support:

- a WinUI or WPF frontend;
- fleet-oriented compliance output;
- signed PowerShell Gallery releases;
- richer edition/build compatibility rules;
- policy conflict provenance from domain policy or MDM;
- approved app and URI exclusion management;
- event log integration.
