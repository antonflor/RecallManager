# Security Policy

## Reporting

Please report security issues privately through GitHub's security advisory feature rather than opening a public issue.

## Scope

Security-sensitive areas include:

- privilege elevation and administrator checks;
- policy or registry writes;
- optional-feature servicing;
- backup-file permissions and contents;
- command injection or unsafe path handling;
- accidental exposure of Recall data.

RecallManager must never read, decrypt, upload, or export Recall snapshot contents. Audit reports should contain configuration metadata only. Before sharing reports publicly, review computer names, policy values, application names, and filtered URLs for sensitive information.
