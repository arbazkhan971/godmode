# /godmode:secrets

Manage secrets safely: scan for leaks, set up secret stores, enforce rotation policies, audit access, and prevent future exposure.

## Usage

```
/godmode:secrets                        # Full audit: inventory, leak scan, rotation check
/godmode:secrets --scan                 # Scan for leaked secrets only
/godmode:secrets --rotate               # Check rotation status and rotate overdue
/godmode:secrets --audit                # Access audit for secret usage
/godmode:secrets --setup                # Set up secret management infrastructure
/godmode:secrets --env                  # Validate .env files against .env.example
/godmode:secrets --hook                 # Install pre-commit secret scanning hook
/godmode:secrets --provider vault       # Target provider (vault, aws, gcp, azure)
```

## What It Does

1. Inventories all secrets in the project (env vars, config files, hardcoded)
2. Scans codebase and git history for leaked secrets (gitleaks, truffleHog)
3. Sets up centralized secret stores (Vault, AWS SM, GCP SM, Azure KV)
4. Enforces rotation schedules and flags overdue credentials
5. Audits secret access patterns and flags anomalies
6. Validates .env files against .env.example templates
7. Installs pre-commit hooks to prevent future leaks

## Output
- Secrets audit report at `docs/security/secrets-audit.md`
- Rotation policy at `docs/security/rotation-policy.md`
- Commit: `"secrets: <description> — <N> secrets managed, <N> leaks remediated"`

## Next Step
After secrets are secured: `/godmode:secure` for full security audit, or `/godmode:ship` if ready.

## Examples

```
/godmode:secrets --scan                 # Check for leaked secrets
/godmode:secrets --setup --provider aws # Set up AWS Secrets Manager
/godmode:secrets --rotate               # Rotate overdue credentials
/godmode:secrets --env                  # Validate .env completeness
```
