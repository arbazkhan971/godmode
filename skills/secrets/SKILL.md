---
name: secrets
description: >
  Secrets management. Leak detection, rotation,
  vault setup, .env management, access auditing.
---

# Secrets -- Secrets Management

## Activate When
- `/godmode:secrets`, "manage secrets", "rotate credentials"
- "check for leaks", "scan for exposed secrets"
- Security audit flags hardcoded credentials
- Credential rotation is overdue

## Workflow

### Step 1: Secret Inventory
```
| Secret                | Source    | Status  |
|-----------------------|----------|---------|
| DATABASE_URL          | .env     | PRESENT |
| JWT_SECRET            | .env     | PRESENT |
| STRIPE_SECRET_KEY     | hardcoded| LEAKED  |
```

### Step 2: Leak Detection
```bash
# Scan current codebase
gitleaks detect --source . --verbose

# Scan full git history
gitleaks detect --source . --log-opts="--all" --verbose

# Pattern scan for hardcoded secrets
grep -rn 'API_KEY=\|SECRET=\|PASSWORD=\|TOKEN=' \
  --include="*.ts" --include="*.py" --include="*.go" \
  --include="*.env" src/ 2>/dev/null
```
```
IF verified leak found:
  1. REVOKE the credential immediately
  2. ROTATE — generate new credential
  3. REMOVE from code (use env var or vault)
  4. SCRUB git history (BFG Repo-Cleaner)
  5. VERIFY old credential no longer works
  6. AUDIT access logs during exposure window
```

### Step 3: Secret Store Setup
```
IF AWS infrastructure: AWS Secrets Manager
  (auto-rotation, IAM integration)
IF multi-cloud or on-prem: HashiCorp Vault KV-v2
IF GCP: GCP Secret Manager (auto-replication)
IF Azure: Azure Key Vault
WHEN self-hosted: Vault with AppRole auth
```

### Step 4: .env File Management
```bash
# .env.example — committed (template)
DATABASE_URL=postgres://user:pass@localhost:5432/dev
JWT_SECRET=development-secret-change-in-production
STRIPE_KEY=sk_test_placeholder

# Validate .env against .env.example
diff <(grep -oP '^[A-Z_]+=?' .env.example | sort) \
     <(grep -oP '^[A-Z_]+=?' .env | sort)
```
```
.ENV SAFETY CHECK:
- [x] .env in .gitignore
- [x] .env.local in .gitignore
- [x] .env.production in .gitignore
- [x] .env.example exists with placeholders
- [ ] .env was never committed to git history
```

### Step 5: Rotation Scheduling
```
| Secret Type       | Rotation | Threshold    |
|-------------------|----------|-------------|
| Database passwords| 30 days  | OVERDUE >45d|
| API keys          | 90 days  | OVERDUE >120d|
| JWT signing key   | 90 days  | OVERDUE >120d|
| TLS certificates  | 365 days | OVERDUE >400d|
| OAuth secrets     | 180 days | OVERDUE >210d|

ROTATION STEPS:
1. Generate new credential
2. Store in secret manager (new version)
3. Update app (auto if vault, deploy if env)
4. Verify app works with new credential
5. Revoke old (after 24h grace period)
```

### Step 6: Access Auditing
```
ACCESS CONTROL:
- Each service has own identity (AppRole/IAM)
- Services access only their own secrets
- Human access requires MFA and is logged
- Production secrets never accessed directly
- Access logs retained 90+ days
- Alerts on anomalous access patterns
```

### Step 7: Pre-Commit Prevention
```bash
# Install gitleaks pre-commit hook
cat >> .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
EOF
pre-commit install
```

### Step 8: Report
```
SECRETS AUDIT:
  Inventoried: <N>
  Managed (vault): <N>
  In .env (local): <N>
  LEAKED: <N>
  Rotation overdue: <N>
  Pre-commit hook: ACTIVE | MISSING
  Verdict: SECURE | NEEDS ROTATION | LEAKS FOUND
```
Commit: `"secrets: <N> managed, <N> leaks fixed"`

## Key Behaviors
1. **Leaks are emergencies.** Revoke first, fix later.
2. **Never commit secrets.** Git history is permanent.
3. **Env vars are not secret management.** Use vault.
4. **.env.example is documentation.** Keep in sync.
5. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER hardcode secrets in source or Dockerfiles.
2. ADD .env files to .gitignore before first commit.
3. NEVER share secrets via Slack, email, or chat.
4. EVERY environment must have unique credentials.
5. NEVER log secrets. Mask in error messages.
6. Prefer short-lived credentials over long-lived.
7. EVERY repo must have pre-commit secret scanning.

## Auto-Detection
```bash
ls .env .env.local .env.production 2>/dev/null
grep -q "\.env" .gitignore 2>/dev/null || echo "CRITICAL"
grep -r "vault\|aws-sdk.*secrets\|@google-cloud/secret" \
  package.json pyproject.toml 2>/dev/null
```

## TSV Logging
Log to `.godmode/secrets-audit.tsv`:
`timestamp\ttotal\tmanaged\tleaked\trotation_overdue\tverdict`

## Keep/Discard Discipline
```
KEEP if: verified real credential in production code
DISCARD if: false positive (placeholder, public key)
  OR already remediated in previous iteration
```

## Stop Conditions
```
STOP when:
  - Zero verified leaks in code and git history
  - Pre-commit hook installed and active
  - All production secrets in vault
  - User requests stop
```
