# Contributing

RecallManager changes can affect Windows privacy settings and optional features. Contributions should favor documented Windows interfaces, idempotent behavior, explicit confirmation, and reversible changes.

## Development flow

1. Create a branch from `main`.
2. Keep public commands in `src/RecallManager/Public` and internal helpers in `Private`.
3. Add or update Pester tests.
4. Run PSScriptAnalyzer and Pester on Windows PowerShell 5.1 and PowerShell 7 where practical.
5. Document any destructive or restart-requiring behavior.
6. Open a pull request; do not commit feature development directly to `main`.

## Design rules

- Prefer official PowerShell, DISM, Group Policy, or Policy CSP surfaces.
- Never open, copy, decrypt, or inspect Recall snapshot contents.
- Build a plan before changing state.
- Back up every setting RecallManager changes.
- Re-query Windows after changes; do not treat command success as verification.
- Keep profiles declarative in `config/profiles.json`.
