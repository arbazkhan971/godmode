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

# Scan with truffleHog for high-entropy strings
trufflehog filesystem --directory . --only-verified

# Check for common patterns
grep -rn "password\s*=\s*['\"]" --include="*.py" --include="*.js" --include="*.ts"
grep -rn "api_key\s*=\s*['\"]" --include="*.py" --include="*.js" --include="*.ts"
grep -rn "secret\s*=\s*['\"]" --include="*.py" --include="*.js" --include="*.ts"
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
│                                                           │
│  LEAK 2: SMTP Password in config                          │
│  File: config/email.yaml:8                                │
│  Evidence: password: "smtp_password_here"                 │
│  Severity: HIGH                                           │
│  Action: Move to secret manager, rotate credential        │
│                                                           │
│  LEAK 3: AWS Key in git history                           │
│  Commit: a1b2c3d (2024-06-15)                             │
│  Evidence: AWS_SECRET_ACCESS_KEY in old .env commit       │
│  Severity: CRITICAL                                       │
│  Action: Rotate AWS credentials, remove from history      │
└──────────────────────────────────────────────────────────┘
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

# Store a secret
vault kv put app/api-service \
  DATABASE_URL="postgres://user:pass@host:5432/db" \
  JWT_SECRET="generated-256-bit-key" \
  STRIPE_KEY="sk_live_rotated_key"

# Create access policy
vault policy write api-service - <<EOF
path "app/data/api-service" {
  capabilities = ["read"]
}
path "app/metadata/api-service" {
  capabilities = ["read", "list"]
}
EOF

# Create AppRole for service authentication
vault auth enable approle
vault write auth/approle/role/api-service \
  token_policies="api-service" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=24h
```

#### AWS Secrets Manager
```bash
# Create a secret
aws secretsmanager create-secret \
  --name "prod/api-service/database" \
  --secret-string '{"username":"admin","password":"rotated-pass","host":"db.example.com"}'

# Enable automatic rotation
aws secretsmanager rotate-secret \
  --secret-id "prod/api-service/database" \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:123456:function:secret-rotator \
  --rotation-rules '{"AutomaticallyAfterDays": 30}'

# Retrieve secret in application
aws secretsmanager get-secret-value --secret-id "prod/api-service/database"
```

#### GCP Secret Manager
```bash
# Create a secret
echo -n "super-secret-value" | gcloud secrets create api-key \
  --data-file=- \
  --replication-policy="automatic"

# Add a new version (rotation)
echo -n "new-rotated-value" | gcloud secrets versions add api-key --data-file=-

# Grant access to service account
gcloud secrets add-iam-policy-binding api-key \
  --member="serviceAccount:api-service@project.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
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
LOG_LEVEL=debug

# .env — NOT committed (actual local values)
DATABASE_URL=postgres://dev:actual_pass@localhost:5432/myapp_dev
JWT_SECRET=actual-dev-jwt-secret
REDIS_URL=redis://localhost:6379
STRIPE_KEY=sk_test_actual_key
AWS_REGION=us-east-1
LOG_LEVEL=debug
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
      - id: gitleaks

# Alternative: git-secrets (AWS)
git secrets --install
git secrets --register-aws

# Alternative: detect-secrets (Yelp)
detect-secrets scan > .secrets.baseline
detect-secrets audit .secrets.baseline
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
4. **.env.example is documentation.** Keep it in sync with .env. New developers should be able to set up from .env.example alone.
5. **Rotation is not optional.** Credentials age like milk. Even if a secret has not been compromised, rotate it on schedule.
6. **Least privilege for secret access.** Each service reads only its own secrets. No shared service accounts reading everything.
7. **Audit access regularly.** If a human accessed production secrets, there should be a documented reason.
8. **Defense in depth.** Pre-commit hooks catch local mistakes. CI scans catch missed hooks. GitHub push protection catches everything else. Use all three layers.

## Example Usage

### Scanning for leaked secrets
```
User: /godmode:secrets Check for leaked secrets in our repo

Secrets: Scanning codebase and git history...

Running gitleaks... 3 findings
Running truffleHog... 1 finding (verified)
Running pattern scan... 2 findings

VERIFIED LEAKS: 2

LEAK 1: Stripe Live API Key
  File: src/payment.ts:12
  const key = "sk_live_abc123..."
  Severity: CRITICAL
  Action: Revoke in Stripe dashboard NOW

LEAK 2: Database password in git history
  Commit: a1b2c3d (committed 2024-06-15)
  File: .env (later gitignored but already committed)
  Severity: CRITICAL
  Action: Rotate database password, scrub git history

FALSE POSITIVES: 2 (test fixtures with fake keys)

Immediate actions required:
1. Revoke Stripe key sk_live_abc123...
2. Rotate database password
3. Scrub .env from git history with BFG
4. Install pre-commit hook to prevent future leaks
```

### Setting up secret management
```
User: /godmode:secrets Set up AWS Secrets Manager for our API

Secrets: Configuring AWS Secrets Manager...

Created secrets:
  prod/api-service/database — DB credentials (30-day rotation)
  prod/api-service/jwt — JWT signing key (90-day rotation)
  prod/api-service/stripe — Stripe API key (90-day rotation)

Updated application:
  - Added AWS SDK secret retrieval
  - Removed hardcoded values from config
  - Added secret caching (5-minute TTL)
  - Added graceful handling for rotation

Configured rotation:
  - Lambda function for database password rotation
  - Rotation schedules set per policy

All 3 secrets migrated to AWS Secrets Manager.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full secret audit: inventory, leak scan, rotation check |
| `--scan` | Scan for leaked secrets only |
| `--rotate` | Check rotation status and rotate overdue secrets |
| `--audit` | Access audit for secret usage |
| `--setup` | Set up secret management infrastructure |
| `--env` | Validate .env files against .env.example |
| `--hook` | Install pre-commit secret scanning hook |
| `--provider <name>` | Target secret provider (vault, aws, gcp, azure) |

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

## Iterative Secret Audit Loop

```
current_iteration = 0
max_iterations = 8
audit_tasks = [inventory, scan_source, scan_history, check_rotation, check_access, remediate, automate, verify]

WHILE audit_tasks is not empty AND current_iteration < max_iterations:
    task = audit_tasks.pop(0)
    1. IF inventory: catalog all secrets (DB creds, API keys, tokens, certs) with locations
    2. IF scan_source: run gitleaks/trufflehog on current codebase for hardcoded secrets
    3. IF scan_history: run gitleaks on full git history for previously committed secrets
    4. IF check_rotation: verify rotation policy and last rotation date for each secret
    5. IF check_access: audit who/what has access to each secret (least privilege check)
    6. IF remediate: move hardcoded secrets to manager, rotate any exposed secrets
    7. IF automate: install pre-commit hooks, configure CI secret scanning
    8. IF verify: run full scan again to confirm zero hardcoded secrets
    9. IF issues found → flag severity (CRITICAL: exposed, HIGH: hardcoded, MEDIUM: no rotation)
    10. current_iteration += 1

POST-LOOP: Generate secrets audit report with findings, remediations, and ongoing monitoring plan
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (2 worktrees):
  Agent 1 — "secrets-scan": scan source + history, identify all hardcoded/exposed secrets
  Agent 2 — "secrets-infra": set up secret manager, rotation policies, pre-commit hooks

MERGE ORDER: scan → infra (scan identifies what to migrate, infra sets up the target)
CONFLICT ZONES: config files referencing secrets (coordinate env var naming)
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

## Anti-Patterns

- **Do NOT hardcode secrets.** Not in source code, not in config files, not in Dockerfiles, not in CI/CD configs. Never.
- **Do NOT commit .env files.** Add to .gitignore before the first commit. If already committed, scrub from history.
- **Do NOT share secrets via Slack, email, or chat.** Use a secret manager or a one-time-use link (e.g., Vault wrapped tokens, 1Password share).
- **Do NOT use the same secret across environments.** Dev, staging, and production each get unique credentials.
- **Do NOT skip rotation because "nothing happened."** Rotation limits the blast radius of unknown compromises.
- **Do NOT log secrets.** Sanitize all log output. Mask values in error messages. Never include credentials in stack traces.
- **Do NOT use long-lived credentials when short-lived alternatives exist.** Prefer IAM roles over access keys. Prefer JWT with short TTL over permanent tokens.
- **Do NOT ignore secret scanning alerts.** GitHub, GitLab, and other platforms surface leaked secrets. Act on them immediately.


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

IF pre-commit hook is bypassed (--no-verify):
  1. CI pipeline secret scan is the second line of defense — it must catch the leak
  2. If CI also missed it: GitHub/GitLab push protection is the third line
  3. If all three layers failed: the secret scanning rules need updating
  4. Add the missed pattern to custom rules (.gitleaks.toml or equivalent)
  5. Re-scan the entire repository with updated rules
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run secrets tasks sequentially: scan for exposed secrets, then set up secret manager and rotation.
- Use branch isolation per task: `git checkout -b godmode-secrets-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
