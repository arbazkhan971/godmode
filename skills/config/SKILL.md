---
name: config
description: |
  Environment and configuration management skill. Activates when user needs to manage dev/staging/prod configs, validate environment parity, design feature flags, or plan A/B test rollouts. Ensures config consistency, secret safety, and environment drift detection. Triggers on: /godmode:config, "manage environments", "feature flags", "config validation", "A/B test setup", or when ship skill needs environment verification.
---

# Config — Environment & Configuration Management

## When to Activate
- User invokes `/godmode:config`
- User says "manage environments", "config validation", "feature flags"
- User needs dev/staging/prod parity checking
- User wants to design a feature flag system or A/B test rollout
- Ship skill needs environment verification before deployment
- User asks "are my environments in sync?" or "check config drift"

## Workflow

### Step 1: Inventory Current Configuration
Map all configuration sources and environments:

```bash
# Find config files
find . -name "*.env*" -o -name "*.config.*" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.ini" | grep -v node_modules | grep -v .git

# Check for environment-specific files
find . -name "*development*" -o -name "*staging*" -o -name "*production*" -o -name "*prod*" -o -name "*dev*" | grep -v node_modules | grep -v .git

```

```
CONFIG INVENTORY:
Environments: <dev | staging | prod | custom>
Config sources:
  - Environment variables: <list of .env files>
  - Config files: <list of config files>
  - Secret managers: <vault/AWS SSM/GCP Secret Manager/none>
  - Feature flag provider: <LaunchDarkly/Unleash/custom/none>
Config format: <JSON | YAML | TOML | dotenv | mixed>
Total config keys: <N>
Secret keys: <N>
Non-secret keys: <N>
```

### Step 2: Environment Parity Check
Compare configurations across environments to detect drift:

#### Key-Level Comparison
```
PARITY CHECK:
| Config Key | Dev | Staging | Prod |
|--|--|--|--|
| DATABASE_URL | ✓ | ✓ | ✓ |
| REDIS_URL | ✓ | ✓ | ✓ |
│ LOG_LEVEL           │ debug│ info    │ warn │  ← EXPECTED DIFF
│ FEATURE_NEW_UI      │ true │ true    │ false│  ← EXPECTED DIFF
│ MAX_CONNECTIONS     │ 10   │ 50      │ 100  │  ← EXPECTED DIFF
| API_TIMEOUT_MS | 5000 | 5000 | 5000 |
│ SENTRY_DSN          │ ✓    │ ✓       │ ✗    │  ← MISSING IN PROD
│ NEW_SERVICE_URL     │ ✓    │ ✗       │ ✗    │  ← ONLY IN DEV
```

#### Drift Categories
```
CRITICAL DRIFT (must fix):
- Keys present in one env but missing in another (likely deployment failure)
- Type mismatches (string in dev, number in prod)
- Secret keys with placeholder values in non-dev environments

EXPECTED DRIFT (document and accept):
- Log levels (debug in dev, warn in prod)
- Connection pool sizes (scaled per environment)
- Feature flags (intentional per-environment rollout)
- Debug/profiling settings (dev-only)

SUSPICIOUS DRIFT (investigate):
- Different values for same key with no documented reason
- Timeout or retry values that differ without scaling justification
- Third-party service URLs that don't match environment tier
```

### Step 3: Config Validation Schema
Generate or verify a validation schema for all configuration:

```typescript
// config/schema.ts — Single source of truth for all config keys
const configSchema = {
  DATABASE_URL: {
    type: 'string',
    required: true,
    format: 'uri',
```

#### Validation Rules
```
For EVERY config key, validate:
1. PRESENCE — Required keys exist in every environment
2. TYPE — Value matches expected type (string, number, boolean, URL, etc.)
3. FORMAT — Value matches pattern (URLs, email, API key formats)
4. RANGE — Numeric values within acceptable bounds
5. SENSITIVITY — Sensitive values not hardcoded or committed to git
6. CONSISTENCY — Same key has same type across all environments
```

#### Startup Validation
```typescript
// Validate config on application startup — fail fast
function validateConfig(env: Record<string, string>): void {
  const errors: string[] = [];
  for (const [key, schema] of Object.entries(configSchema)) {
    const value = env[key];
    if (schema.required && !value) {
```

### Step 4: Feature Flag Design
Design and manage feature flags for controlled rollouts:

#### Flag Types
```
FLAG TYPES:
1. RELEASE FLAG — Gate new features (temporary, remove after full rollout)
   Example: FEATURE_NEW_CHECKOUT=true
   Lifecycle: Create → Dev → Staging → % Prod → 100% Prod → Remove flag

2. EXPERIMENT FLAG — A/B test with measurement
   Example: EXPERIMENT_PRICING_V2={variant: "B", percentage: 25}
   Lifecycle: Create → Configure variants → Run → Measure → Pick winner → Remove

3. OPS FLAG — Control operational behavior
   Example: OPS_MAINTENANCE_MODE=false
   Lifecycle: Create → Toggle during incidents → Keep permanently

4. PERMISSION FLAG — Gate features by user segment
   Example: PERMISSION_BETA_FEATURES=["user_123", "org_456"]
   Lifecycle: Create → Add users/segments → Expand → Convert to release flag
```

#### Flag Schema
```typescript
interface FeatureFlag {
  name: string;                          // SCREAMING_SNAKE_CASE
  type: 'release' | 'experiment' | 'ops' | 'permission';
  description: string;                   // What this flag controls
  owner: string;                         // Team or person responsible
  createdAt: string;                     // ISO date
```

#### Flag Lifecycle Management
Every flag: owner + expiry date. Release flags >30 days at 100%: remove flag, keep code. Experiment flags >14 days: conclude, pick winner. Dead flags (no code refs): delete. Keep total under 20 for small teams. Weekly stale flag report.

### Step 5: A/B Test Setup
Design controlled experiments with statistical rigor:

#### Experiment Design
```
EXPERIMENT PLAN:
Name: <experiment_name>
Hypothesis: "Changing <X> will improve <metric> by <expected_delta>"
Primary metric: <conversion_rate | revenue | engagement | latency | etc.>
Secondary metrics: <list of guardrail metrics to monitor>
Minimum detectable effect: <smallest meaningful improvement, e.g., 2%>
Statistical significance: <p-value threshold, default 0.05>
Required sample size: <calculated from MDE and baseline>

Variants:
  Control (A): <current behavior>
  Treatment (B): <new behavior>
  [Treatment (C)]: <optional additional variant>

Traffic split: <50/50 | 80/20 | custom>
Duration: <calculated from traffic volume and required sample size>
Kill criteria: <when to stop early — e.g., >10% degradation in guardrail metric>
```

#### Rollout Strategy
Phase 1: Internal (100%, 2-3 days, catch bugs). Phase 2: Canary (1-5%, 24-48h, verify no regressions). Phase 3: Controlled (10% -> 25% -> 50%, 1-2 weeks per increment, gather statistical significance).

### Step 6: Secret Management Audit
Verify secrets are handled safely across all environments:

```
SECRET AUDIT:
| Check | Status | Finding |
|--|--|--|
| .env in .gitignore | PASS/FAIL | <detail> |
| No secrets in code | PASS/FAIL | <files with hardcoded> |
| No secrets in logs | PASS/FAIL | <log statements to fix> |
| Secrets rotatable | PASS/FAIL | <non-rotatable secrets> |
| Secrets have expiry | PASS/FAIL | <non-expiring secrets> |
| Dev ≠ prod secrets | PASS/FAIL | <shared secrets> |
| Secret manager in use | PASS/FAIL | <recommendation> |
| Encryption at rest | PASS/FAIL | <unencrypted stores> |
```

### Step 7: Generate Config Report

```
  CONFIG AUDIT — <project>
  Environments: <N> configured
  Total config keys: <N>
  Sensitive keys: <N>
  PARITY:
  Keys in all envs: <N>/<total>
  Missing keys: <N> (CRITICAL)
  Expected drift: <N> (documented)
  Suspicious drift: <N> (needs investigation)
  VALIDATION:
  Schema coverage: <X>% of keys have validation
```

### Step 8: Commit and Transition
1. Save report as `docs/config/<project>-config-audit.md`
2. Save validation schema if generated
3. Commit: `"config: <project> — <verdict> (<N> keys, <N> flags, <N> issues)"`
4. If CRITICAL: "Missing keys in production or secrets exposed. Fix immediately."
5. If HEALTHY: "Configuration is consistent. Ready for deployment."

## Key Behaviors

1. **Never commit secrets.** Flag as CRITICAL immediately.
2. **Schema is source of truth.** Type, validation, description.
3. **Parity before deploy.** Fail fast on missing keys.
4. **Flags have lifecycles.** Owner + expiry date required.
5. **A/B tests need math.** Sample size before launch.
6. **Environment drift is a bug.** Document or fix.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full config audit — parity, validation, secrets, flags |
| `--parity` | Environment parity check only |
| `--validate` | Config validation schema check only |

## HARD RULES

Never ask to continue. Loop autonomously until all environments are audited and drift is resolved.

1. **NEVER commit secrets** to source control. If found, flag as CRITICAL immediately.
2. **NEVER deploy to an environment with missing required config keys.** Fail fast.
3. **EVERY config key MUST have a schema entry** with type, validation, and description.
4. **EVERY feature flag MUST have an owner and expiry date.**
5. **NEVER add a flag without a cleanup plan** — document removal conditions at creation time.
6. **git commit BEFORE verify** — commit config changes, then validate against schema.
7. **Automatic revert on regression** — if config change causes startup failure, revert immediately.
8. **TSV logging** — log every config audit:
   ```
   timestamp	environments	total_keys	missing_keys	secret_issues	flags_stale	verdict
   ```

## Auto-Detection

On activation, automatically detect all configuration without asking:

```
AUTO-DETECT:
1. Config files:
   find . -name "*.env*" -o -name "*.config.*" -o -name "*.yml" \
     -o -name "*.yaml" -o -name "*.toml" -o -name "*.ini" \
     | grep -v node_modules | grep -v .git

2. Environment-specific files:
   find . -name "*development*" -o -name "*staging*" -o -name "*production*" \
     -o -name "*prod*" -o -name "*dev*" | grep -v node_modules

3. Secret references:
   grep -r "SECRET\|API_KEY\|PASSWORD\|TOKEN\|PRIVATE" \
     --include="*.env*" --include="*.config.*" -l

4. Feature flag provider:
```

## Output Format
Print on completion: `Config: {config_key_count} keys across {env_count} environments. Secrets: {secret_count} (all in secret manager: {secret_mgr_status}). Drift: {drift_count} keys differ. Validation: {validation_status}. Feature flags: {flag_count}. Verdict: {verdict}.`

## TSV Logging
Log every configuration operation to `.godmode/config-results.tsv`:
```
iteration	task	environment	keys_total	secrets_count	drift_detected	validation_status	status
1	inventory	production	45	12	0	passing	audited
2	inventory	staging	45	12	3	passing	drift_found
3	secrets	all	0	12	0	migrated	migrated
4	validation	all	45	0	0	zod_schema	configured
```
Columns: iteration, task, environment, keys_total, secrets_count, drift_detected, validation_status, status(audited/drift_found/migrated/configured/failed).

## Success Criteria
All keys inventoried. Secrets in secret manager. Startup validation fails fast. Drift detected and explained. Flags have expiry + cleanup plans. Typed config parsing (no raw `process.env`). Config changes auditable.

## Error Recovery
| Failure | Action |
|--|--|
| App fails to start after config change | Check validation errors for specific key. Compare with previous working config. |
| Secret rotation breaks app | Test rotation in staging first. Validate new secret before revoking old. |
| Config drift between envs | Run drift detection. Document intentional drift, fix accidental. |
| Feature flag stuck at 100% | Schedule cleanup: remove flag check, delete flag, remove old code path. |
| Startup validation too strict | Separate required/optional config. Use defaults for non-critical. |

## Keep/Discard Discipline
```
KEEP if: validation passes AND parity improved AND no regressions
DISCARD if: validation fails OR startup breaks OR new drift
Every change is atomic — never half-migrated config.
```

## Stop Conditions
```
STOP when: all envs audited AND critical drift resolved AND secrets migrated
  OR user requests stop OR max 15 iterations
```

