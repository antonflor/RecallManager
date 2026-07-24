# Changelog

All notable changes to RecallManager are documented here.

## [1.0.0-beta.1] - 2026-07-18

### Added

- State-aware Recall audit covering Windows build, optional-feature state, machine policy, and current-user policy.
- Effective-state explanation instead of a raw enabled/disabled flag.
- Four desired-state profiles: AuditOnly, UserControlled, SnapshotsOff, and PrivacyHardened.
- Change planning, native `WhatIf`, confirmation gates, pre-change JSON backup, post-change verification, and restore.
- Human-readable and JSON output for support, RMM, and endpoint workflows.
- PowerShell module architecture with public/private separation.
- Pester and PSScriptAnalyzer workflow for Windows.
- Product documentation, Mermaid diagrams, screenshot placeholders, and a website launch brief.

### Changed

- Replaced the original interactive-only DISM toggle with a command-oriented CLI while retaining an interactive menu.

### Safety

- Snapshot contents are never read.
- Destructive profiles are clearly identified and require confirmation by default.
- Main is not targeted by this launch work until testing is complete.
