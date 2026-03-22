---
name: secrets
description: |
  Secrets management skill. Activates when user needs to manage sensitive configuration: API keys, database credentials, tokens, certificates. Supports HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault. Handles rotation scheduling, access auditing, .env file management, and secret leak detection. Triggers on: /godmode:secrets, "manage secrets", "rotate credentials", "check for leaks", "set up vault", or when security audit flags exposed secrets.
---

# Secrets — Secrets Management

## When to Activate
- User invokes `/godmode:secrets`
- User says "manage secrets", "rotate credentials", "set up vault"
- User says "check for leaks", "scan for exposed secrets"
- Security audit flags hardcoded credentials or exposed API keys
- New service needs secret configuration
- Credential rotation is scheduled or overdue
- `.env` files need management or validation

## Workflow

### Step 1: Secret Inventory
Discover and catalog all secrets in the project:

```
SECRET INVENTORY:
┌──────────────────────────────────────────────────────────┐
│  Secret                │ Source        │ Status           │
│  ─────────────────────────────────────────────────────── │
│  DATABASE_URL          │ .env          │ PRESENT          │
│  JWT_SECRET            │ .env          │ PRESENT          │
│  AWS_ACCESS_KEY_ID     │ .env          │ PRESENT          │
│  AWS_SECRET_ACCESS_KEY │ .env          │ PRESENT          │
│  STRIPE_SECRET_KEY     │ hardcoded     │ LEAKED           │
│  SMTP_PASSWORD         │ config.yaml   │ EXPOSED          │
│  API_KEY_INTERNAL      │ env var       │ RUNTIME ONLY     │
│  TLS_CERT              │ vault         │ MANAGED          │
│  TLS_KEY               │ vault         │ MANAGED          │
├──────────────────────────────────────────────────────────┤
│  Total secrets: 9                                         │
│  Properly managed: 3 (vault/runtime)                      │
│  In .env files: 4 (acceptable for local dev)              │
│  LEAKED/EXPOSED: 2 (MUST FIX IMMEDIATELY)                 │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Secret Leak Detection
Scan codebase and git history for exposed secrets:

```bash
# Scan current codebase with gitleaks
gitleaks detect --source . --verbose

# Scan git history for past leaks
gitleaks detect --source . --log-opts="--all" --verbose

# ... (condensed)
```

```
LEAK DETECTION RESULTS:
┌──────────────────────────────────────────────────────────┐
│  Scanner           │ Findings │ Verified │ False Positive │
│  ─────────────────────────────────────────────────────── │
│  gitleaks          │ 3        │ 2        │ 1              │
│  truffleHog        │ 1        │ 1        │ 0              │
│  pattern scan      │ 5        │ 2        │ 3              │
├──────────────────────────────────────────────────────────┤
│  VERIFIED LEAKS:                                          │
│                                                           │
│  LEAK 1: Stripe API Key                                   │
│  File: src/services/payment.ts:12                         │
│  Evidence: const STRIPE_KEY = "sk_live_abc123..."         │
│  Severity: CRITICAL                                       │
│  Action: Revoke key immediately, rotate, use env var      │
```

For each verified leak:
```
LEAK REMEDIATION <N>:
1. REVOKE the exposed credential immediately
2. ROTATE — generate a new credential
3. REMOVE from codebase (use env var or secret manager)
4. SCRUB from git history if committed:
   git filter-branch or BFG Repo-Cleaner
5. VERIFY the old credential no longer works
6. AUDIT access logs for unauthorized usage during exposure window
```

### Step 3: Secret Store Setup
Configure a centralized secret management system:

#### HashiCorp Vault
```bash
# Initialize Vault
vault operator init -key-shares=5 -key-threshold=3

# Enable secrets engine
vault secrets enable -path=app kv-v2

# ... (condensed)
```

#### AWS Secrets Manager
```bash
# Create a secret
aws secretsmanager create-secret \
  --name "prod/api-service/database" \
  --secret-string '{"username":"admin","password":"rotated-pass","host":"db.example.com"}'

# Enable automatic rotation
# ... (condensed)
```

#### GCP Secret Manager
```bash
# Create a secret
echo -n "super-secret-value" | gcloud secrets create api-key \
  --data-file=- \
  --replication-policy="automatic"

# Add a new version (rotation)
# ... (condensed)
```

### Step 4: .env File Management
Manage local development secrets safely:

#### .env File Structure
```bash
# .env.example — Committed to repo (template with dummy values)
DATABASE_URL=postgres://user:password@localhost:5432/myapp_dev
JWT_SECRET=development-secret-change-in-production
REDIS_URL=redis://localhost:6379
STRIPE_KEY=sk_test_placeholder
AWS_REGION=us-east-1
# ... (condensed)
```

#### .gitignore Verification
```
.ENV FILE SAFETY CHECK:
- [x] .env is in .gitignore
- [x] .env.local is in .gitignore
- [x] .env.production is in .gitignore
- [x] .env.*.local is in .gitignore
- [x] .env.example exists with placeholder values
- [ ] .env was never committed to git history
- [x] No .env files in Docker images (multi-stage build)
```

#### .env Validation
```bash
# Compare .env against .env.example
# Ensure all required variables are present

diff <(grep -oP '^[A-Z_]+=?' .env.example | sort) \
     <(grep -oP '^[A-Z_]+=?' .env | sort)
```

```
ENV VALIDATION:
┌──────────────────────────────────────────────────────────┐
│  Variable              │ .env.example │ .env   │ Status  │
│  ─────────────────────────────────────────────────────── │
│  DATABASE_URL          │ present      │ present│ OK      │
│  JWT_SECRET            │ present      │ present│ OK      │
│  REDIS_URL             │ present      │ present│ OK      │
│  STRIPE_KEY            │ present      │ present│ OK      │
│  SENTRY_DSN            │ present      │ MISSING│ WARNING │
│  NEW_FEATURE_FLAG      │ MISSING      │ present│ STALE   │
└──────────────────────────────────────────────────────────┘
Missing in .env: SENTRY_DSN (add to your local .env)
Extra in .env: NEW_FEATURE_FLAG (add to .env.example)
```

### Step 5: Rotation Scheduling
Define and enforce credential rotation policies:

```
ROTATION POLICY:
┌──────────────────────────────────────────────────────────┐
│  Secret Type           │ Rotation   │ Last Rotated │ Due │
│  ─────────────────────────────────────────────────────── │
│  Database passwords    │ 30 days    │ 2025-01-01   │ NOW │
│  API keys              │ 90 days    │ 2024-12-15   │ OK  │
│  JWT signing key       │ 90 days    │ 2024-11-01   │ DUE │
│  TLS certificates      │ 365 days   │ 2024-06-01   │ OK  │
│  OAuth client secrets  │ 180 days   │ 2024-08-01   │ OK  │
│  Service account keys  │ 90 days    │ 2024-12-20   │ OK  │
│  Encryption keys       │ 365 days   │ 2024-03-01   │ DUE │
├──────────────────────────────────────────────────────────┤
│  OVERDUE: 2 secrets need immediate rotation               │
│  Database passwords — 15 days overdue                     │
│  JWT signing key — 6 days overdue                         │
└──────────────────────────────────────────────────────────┘
```

#### Rotation Procedure
```
ROTATION STEPS:
1. Generate new credential
2. Store new credential in secret manager (new version)
3. Update application to use new credential
   - If secret manager: automatic (no deploy needed)
   - If env var: deploy with new value
4. Verify application works with new credential
5. Revoke old credential (after grace period)
6. Update rotation log with timestamp and operator
7. Verify old credential no longer works
```

### Step 6: Access Auditing
Track who accesses which secrets and when:

```
ACCESS AUDIT:
┌──────────────────────────────────────────────────────────┐
│  Secret                │ Accessor          │ Last Access  │
│  ─────────────────────────────────────────────────────── │
│  prod/database         │ api-service       │ 2 min ago    │
│  prod/database         │ migration-job     │ 3 days ago   │
│  prod/database         │ dev-john (HUMAN)  │ 7 days ago   │
│  prod/stripe-key       │ payment-service   │ 5 min ago    │
│  prod/stripe-key       │ dev-sarah (HUMAN) │ 30 days ago  │
│  prod/jwt-secret       │ api-service       │ 1 min ago    │
│  prod/jwt-secret       │ auth-service      │ 1 min ago    │
├──────────────────────────────────────────────────────────┤
│  ANOMALIES:                                               │
│  - dev-john accessed prod/database directly (investigate) │
│  - prod/stripe-key accessed 3x more than usual today      │
└──────────────────────────────────────────────────────────┘
```

#### Access Policy Best Practices
```
ACCESS CONTROL:
- [ ] Each service has its own identity (AppRole, Service Account, IAM Role)
- [ ] Services can only access their own secrets (least privilege)
- [ ] Human access requires MFA and is logged
- [ ] Production secrets are never accessed directly by developers
- [ ] Emergency break-glass procedure documented and tested
- [ ] Secret access logs retained for 90+ days
- [ ] Alerts on anomalous access patterns
- [ ] Regular access review (quarterly minimum)
```

### Step 7: Pre-Commit Secret Prevention
Set up guardrails to prevent future leaks:

```bash
# Install pre-commit hook for secret scanning
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
# ... (condensed)
```

```
PREVENTION LAYER:
┌──────────────────────────────────────────────────────────┐
│  Layer              │ Tool            │ Status            │
│  ─────────────────────────────────────────────────────── │
│  Pre-commit hook    │ gitleaks        │ ACTIVE            │
│  CI pipeline scan   │ gitleaks action │ ACTIVE            │
│  IDE plugin         │ GitGuardian     │ RECOMMENDED       │
│  GitHub push prot.  │ Secret scanning │ ACTIVE            │
│  Baseline file      │ detect-secrets  │ ACTIVE            │
│  PR review check    │ Custom action   │ ACTIVE            │
└──────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Report
```
1. Save secrets audit report as `docs/security/secrets-audit.md`
2. Save rotation policy as `docs/security/rotation-policy.md`
3. Commit: "secrets: <description> — <N> secrets managed, <N> leaks remediated"
4. If leaks found: "CRITICAL: <N> exposed secrets found. Revoke and rotate immediately."
5. If rotation overdue: "WARNING: <N> secrets overdue for rotation."
6. If all secure: "All secrets properly managed. No leaks detected."
```

## Key Behaviors

1. **Leaks are emergencies.** An exposed secret is not a TODO item. It is an active security incident. Revoke first, then fix the code.
2. **Never commit secrets.** Not even "temporarily." Git history is permanent. If it was committed, it is leaked.
3. **Environment variables are not secret management.** They are better than hardcoding, but a proper secret manager (Vault, AWS SM, GCP SM) provides rotation, auditing, and access control.
4. **.env.example is documentation.** Keep it in sync with .env. New developers set up from .env.example alone.
5. **Rotation is not optional.** Credentials age like milk. Even if a secret has not been compromised, rotate it on schedule.
6. **Least privilege for secret access.** Each service reads only its own secrets. No shared service accounts reading everything.
7. **Audit access regularly.** If a human accessed production secrets, document the reason.
8. **Defense in depth.** Pre-commit hooks catch local mistakes. CI scans catch missed hooks. GitHub push protection catches everything else. Use all three layers.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full secret audit: inventory, leak scan, rotation check |
| `--scan` | Scan for leaked secrets only |
| `--rotate` | Check rotation status and rotate overdue secrets |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check for .env files: .env, .env.local, .env.production (should be in .gitignore)
2. Check .gitignore for .env entries: if missing, flag as CRITICAL
3. Detect secret manager: vault config, AWS Secrets Manager SDK, GCP Secret Manager, Azure Key Vault
4. Scan for hardcoded secrets: grep for API_KEY=, SECRET=, PASSWORD=, TOKEN= in source files
5. Check for pre-commit hooks: .pre-commit-config.yaml with detect-secrets, gitleaks, trufflehog
6. Detect CI/CD secrets: check .github/workflows for ${{ secrets.* }}, GitLab CI variables
7. Check for .env.example: if .env exists but .env.example does not, flag as missing
8. Scan git history: check for accidentally committed secrets (use gitleaks or trufflehog)
```

## Iterative Secret Audit Loop: Detect → Classify → Rotate → Verify

```
current_iteration = 0
max_iterations = 8
audit_tasks = [inventory, scan_source, scan_history, check_rotation, check_access, remediate, automate, verify]

WHILE audit_tasks is not empty AND current_iteration < max_iterations:
    task = audit_tasks.pop(0)
    current_iteration += 1

    PHASE 1 — DETECT:
      IF inventory: catalog all secrets (DB creds, API keys, tokens, certs) with locations
      IF scan_source: run gitleaks/trufflehog on current codebase for hardcoded secrets
      IF scan_history: run gitleaks on full git history for previously committed secrets

    PHASE 2 — CLASSIFY:
      FOR each detected secret:
```

## False Positive Handling

```
FOR each scanner finding:
  1. AUTO-CLASSIFY as likely false positive if:
     - Found in test/fixtures/, test/mocks/, or __tests__/ directories
     - Matches known placeholder patterns: "placeholder", "example", "changeme", "xxx", "your-key-here"
     - Is a public key (not a secret — only private keys are secrets)
     - Is a hash/checksum (SHA-256 of a file, not a credential)
     - Is in .env.example with obviously dummy values

  2. VERIFICATION for suspected false positives:
     - Attempt to authenticate with the detected value against the suspected service
     - IF authentication succeeds: TRUE POSITIVE — treat as leaked secret
     - IF authentication fails: mark as FALSE POSITIVE with verification evidence

  3. DISPOSITION:
     - TRUE POSITIVE: KEEP → proceed to Classify → Rotate → Verify
     - FALSE POSITIVE: DISCARD → add pattern to scanner allowlist (.gitleaks.toml)
     - UNCERTAIN: KEEP as LOW severity → flag for manual review

  4. LOG to .godmode/secrets-false-positives.tsv:
     timestamp	scanner	file_line	detected_pattern	disposition	verification_method	allowlist_added
```

## Keep/Discard Discipline

```
FOR each detected secret:
  KEEP if:
    - Verified as real credential (auth test succeeds or matches known provider format)
    - Found in production code, config, or git history (not test fixtures)
    - Has not been previously cataloged and remediated
  DISCARD if:
    - Confirmed false positive (auth test fails, known placeholder, public key)
    - Already remediated in a previous iteration (check .godmode/secrets-audit.tsv)
    - In allowlisted path with documented justification
  EVERY discard recorded with reason — no silent drops
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Zero verified leaks in current codebase and git history
  - All production secrets are in a secret manager (not hardcoded or in env vars)
  - Pre-commit hook for secret scanning is installed and active
  - User explicitly requests stop

DO NOT STOP just because:
  - Some secrets have not been rotated yet (remediate leaks first, rotate second)
  - False positives remain in scanner output (add them to the allowlist)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER hardcode secrets in source code, config files, Dockerfiles, or CI configs.
2. .env files MUST be in .gitignore. Verify before first commit.
3. NEVER share secrets via Slack, email, or chat. Use a secret manager or one-time links.
4. EVERY environment (dev, staging, prod) must have unique credentials.
5. NEVER log secrets. Sanitize all log output. Mask values in error messages.
6. Prefer short-lived credentials over long-lived ones (IAM roles > access keys, short JWT > permanent tokens).
7. EVERY repository must have a pre-commit secret scanning hook. No exceptions.
8. IF a secret is exposed in git history, rotate it IMMEDIATELY. Then scrub history.
9. Secret rotation MUST be automated. Manual rotation is forgotten rotation.
10. NEVER store secrets in plain text at rest. Use encrypted storage (Vault, KMS, Secrets Manager).
```

## Output Format

Every secrets invocation must produce a structured report:

```
┌────────────────────────────────────────────────────────────┐
│  SECRETS AUDIT RESULT                                       │
├────────────────────────────────────────────────────────────┤
│  Secrets inventoried: <N>                                   │
│  Properly managed (vault/runtime): <N>                      │
│  In .env files (local dev): <N>                             │
│  LEAKED/EXPOSED: <N>                                        │
│  Rotation overdue: <N>                                      │
│  Pre-commit hook: <ACTIVE | MISSING>                        │
│  Verdict: <SECURE | NEEDS ROTATION | LEAKS FOUND>           │
└────────────────────────────────────────────────────────────┘
```

## TSV Logging

Log every secrets audit to `.godmode/secrets-audit.tsv`:

```
timestamp	scope	total_secrets	managed	env_only	leaked	rotation_overdue	precommit_hook	verdict
```

Append one row per invocation. Never overwrite previous rows.

## Success Criteria

```
PASS if ALL of the following:
  - Zero verified leaks in current codebase and git history
  - .env files are in .gitignore (verified)
  - .env.example exists and is in sync with .env
  - All production secrets are in a secret manager (not env vars)
  - Pre-commit hook for secret scanning is installed and active
  - CI pipeline includes secret scanning step
  - All secrets are within rotation policy (none overdue)
  - Each service has its own identity with least-privilege access

FAIL if ANY of the following:
  - Any verified secret leak exists in source code or git history
  - .env file is not in .gitignore
  - Production secrets are hardcoded anywhere
  - No pre-commit secret scanning hook is installed
  - Secrets are shared across environments (dev/staging/prod use same credentials)
  - Any secret rotation is overdue by more than 7 days
```

## Error Recovery

```
IF a leaked secret is discovered:
  1. REVOKE the credential immediately (do not wait for a fix PR)
  2. ROTATE — generate a new credential through the provider's dashboard/API
  3. UPDATE the secret manager with the new value
  4. VERIFY the old credential no longer works (attempt authentication with it)
  5. AUDIT access logs during the exposure window for unauthorized usage
  6. SCRUB from git history if the secret was committed (BFG Repo-Cleaner or git filter-repo)
  7. LOG the incident: when exposed, when discovered, when revoked, blast radius

IF secret manager is unavailable:
  1. Do not fall back to hardcoding or .env files in production
  2. Retry with exponential backoff (secret managers have high availability)
  3. If extended outage: use cached secrets (applications should cache with short TTL)
  4. If no cache: halt the affected service rather than operating without secrets
  5. Post-incident: review whether multi-region secret replication is needed
```

