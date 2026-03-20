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

# Check for secret references
grep -r "SECRET\|API_KEY\|PASSWORD\|TOKEN\|PRIVATE" --include="*.env*" --include="*.config.*" -l
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
┌─────────────────────┬──────┬─────────┬──────┐
│ Config Key          │ Dev  │ Staging │ Prod │
├─────────────────────┼──────┼─────────┼──────┤
│ DATABASE_URL        │ ✓    │ ✓       │ ✓    │
│ REDIS_URL           │ ✓    │ ✓       │ ✓    │
│ LOG_LEVEL           │ debug│ info    │ warn │  ← EXPECTED DIFF
│ FEATURE_NEW_UI      │ true │ true    │ false│  ← EXPECTED DIFF
│ MAX_CONNECTIONS     │ 10   │ 50      │ 100  │  ← EXPECTED DIFF
│ API_TIMEOUT_MS      │ 5000 │ 5000    │ 5000 │
│ SENTRY_DSN          │ ✓    │ ✓       │ ✗    │  ← MISSING IN PROD
│ NEW_SERVICE_URL     │ ✓    │ ✗       │ ✗    │  ← ONLY IN DEV
└─────────────────────┴──────┴─────────┴──────┘
```

#### Drift Categories
```
CRITICAL DRIFT (must fix):
- Keys present in one env but missing in another (likely deployment failure)
- Type mismatches (string in dev, number in prod)
- Secret keys with placeholder values in non-dev environments

EXPECTED DRIFT (document and accept):
- Log levels (debug in dev, warn in prod)
- Connection pool sizes (scale-appropriate)
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
    description: 'PostgreSQL connection string',
    sensitive: true,
    perEnvironment: true,
  },
  LOG_LEVEL: {
    type: 'string',
    required: true,
    enum: ['debug', 'info', 'warn', 'error'],
    default: 'info',
    description: 'Application log verbosity',
    sensitive: false,
    perEnvironment: true,
  },
  MAX_CONNECTIONS: {
    type: 'number',
    required: true,
    min: 1,
    max: 500,
    description: 'Database connection pool size',
    sensitive: false,
    perEnvironment: true,
  },
  API_KEY_STRIPE: {
    type: 'string',
    required: true,
    pattern: '^sk_(test|live)_[a-zA-Z0-9]+$',
    description: 'Stripe API key',
    sensitive: true,
    perEnvironment: true,
  },
};
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
      errors.push(`MISSING: ${key} — ${schema.description}`);
    }
    if (value && schema.type === 'number' && isNaN(Number(value))) {
      errors.push(`TYPE ERROR: ${key} expected number, got "${value}"`);
    }
    if (value && schema.enum && !schema.enum.includes(value)) {
      errors.push(`INVALID: ${key} must be one of [${schema.enum}], got "${value}"`);
    }
    if (value && schema.pattern && !new RegExp(schema.pattern).test(value)) {
      errors.push(`FORMAT: ${key} does not match expected pattern`);
    }
  }
  if (errors.length > 0) {
    console.error('CONFIG VALIDATION FAILED:');
    errors.forEach(e => console.error(`  - ${e}`));
    process.exit(1);
  }
}
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
   Lifecycle: Create → Toggle as needed → Keep permanently

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
  expectedRemovalDate: string | null;    // When to clean up (null for ops flags)
  environments: {
    dev: FlagValue;
    staging: FlagValue;
    prod: FlagValue;
  };
  rollout?: {
    strategy: 'percentage' | 'user-list' | 'org-list' | 'region';
    percentage?: number;                 // 0-100 for percentage rollout
    targets?: string[];                  // User/org IDs for targeted rollout
  };
  fallback: any;                         // Default value if flag evaluation fails
  cleanup: {
    codeLocations: string[];             // Files that reference this flag
    removedWhenTrue: boolean;            // If true, remove flag code when 100%
  };
}
```

#### Flag Lifecycle Management
```
FLAG HYGIENE:
- [ ] Every flag has an owner and expiry date
- [ ] Release flags older than 30 days at 100% → remove the flag, keep the code
- [ ] Experiment flags older than 14 days → conclude experiment, pick winner
- [ ] Dead flags (no code references) → delete from flag system
- [ ] Flag count audit: total flags should stay under 20 for a small team
- [ ] Stale flag report generated weekly
```

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
Statistical significance: <p-value threshold, typically 0.05>
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
```
ROLLOUT PHASES:
Phase 1: Internal (dogfooding)
  - 100% of internal users
  - Duration: 2-3 days
  - Goal: Catch obvious bugs

Phase 2: Canary
  - 1-5% of production traffic
  - Duration: 24-48 hours
  - Goal: Verify no regressions in error rate, latency, core metrics

Phase 3: Controlled Rollout
  - 10% → 25% → 50% of production traffic
  - Duration: 1-2 weeks per increment
  - Goal: Gather statistical significance

Phase 4: Full Rollout or Rollback
  - If experiment wins: 100% rollout, remove flag, clean up code
  - If experiment loses: Rollback to control, remove experiment code
  - If inconclusive: Extend duration or redesign experiment

ROLLBACK CRITERIA (auto-revert if any triggered):
  - Error rate increases >2x baseline
  - P95 latency increases >50%
  - Primary metric degrades >5% with p < 0.05
  - Any guardrail metric breaches threshold
```

### Step 6: Secret Management Audit
Ensure secrets are handled safely across all environments:

```
SECRET AUDIT:
┌─────────────────────────┬──────────┬──────────────────────────┐
│ Check                   │ Status   │ Finding                  │
├─────────────────────────┼──────────┼──────────────────────────┤
│ .env in .gitignore      │ PASS/FAIL│ <detail>                 │
│ No secrets in code      │ PASS/FAIL│ <files with hardcoded>   │
│ No secrets in logs      │ PASS/FAIL│ <log statements to fix>  │
│ Secrets rotatable       │ PASS/FAIL│ <non-rotatable secrets>  │
│ Secrets have expiry     │ PASS/FAIL│ <non-expiring secrets>   │
│ Dev ≠ prod secrets      │ PASS/FAIL│ <shared secrets>         │
│ Secret manager in use   │ PASS/FAIL│ <recommendation>         │
│ Encryption at rest      │ PASS/FAIL│ <unencrypted stores>     │
└─────────────────────────┴──────────┴──────────────────────────┘
```

### Step 7: Generate Config Report

```
┌──────────────────────────────────────────────────────────┐
│  CONFIG AUDIT — <project>                                │
├──────────────────────────────────────────────────────────┤
│  Environments: <N> configured                            │
│  Total config keys: <N>                                  │
│  Sensitive keys: <N>                                     │
│                                                          │
│  PARITY:                                                 │
│  Keys in all envs: <N>/<total>                           │
│  Missing keys: <N> (CRITICAL)                            │
│  Expected drift: <N> (documented)                        │
│  Suspicious drift: <N> (needs investigation)             │
│                                                          │
│  VALIDATION:                                             │
│  Schema coverage: <X>% of keys have validation           │
│  Startup validation: <YES/NO>                            │
│  Type safety: <YES/NO>                                   │
│                                                          │
│  FEATURE FLAGS:                                          │
│  Active flags: <N>                                       │
│  Stale flags (>30 days at 100%): <N>                     │
│  Experiments running: <N>                                │
│                                                          │
│  SECRETS:                                                │
│  Secret audit: <PASS/FAIL>                               │
│  Issues found: <N>                                       │
│                                                          │
│  Verdict: <HEALTHY | NEEDS ATTENTION | CRITICAL>         │
└──────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Save report as `docs/config/<project>-config-audit.md`
2. Save validation schema if generated
3. Commit: `"config: <project> — <verdict> (<N> keys, <N> flags, <N> issues)"`
4. If CRITICAL: "Missing keys in production or secrets exposed. Fix immediately."
5. If HEALTHY: "Configuration is consistent. Ready for deployment."

## Key Behaviors

1. **Never commit secrets.** If a secret is found in code or git history, flag it as CRITICAL immediately. Secrets belong in environment variables or secret managers, never in source code.
2. **Schema is the source of truth.** Every config key should be defined in a schema with type, validation, and description. Undocumented keys are tech debt.
3. **Parity before deploy.** Never deploy to an environment with missing required config keys. Fail fast on startup if config is invalid.
4. **Flags have lifecycles.** Every feature flag must have an owner, creation date, and expected removal date. Flags without expiry become permanent tech debt.
5. **A/B tests need math.** Don't eyeball results. Calculate required sample size, run until significant, and use proper statistical tests.
6. **Environment drift is a bug.** Unexpected differences between environments cause "works on my machine" failures. Document expected drift, investigate unexpected drift.

## Example Usage

### Full environment audit
```
User: /godmode:config Audit our environment configuration

Config: Scanning configuration files...

CONFIG INVENTORY:
Environments: dev, staging, prod
Config sources: .env.development, .env.staging, .env.production
Total keys: 47
Secret keys: 12

Running parity check...

CRITICAL: SENTRY_DSN missing in prod
CRITICAL: REDIS_URL missing in staging
SUSPICIOUS: API_TIMEOUT differs (5000 dev, 5000 staging, 30000 prod)

Running validation...
23/47 keys have schema validation (49%)
Startup validation: NO — app will start with invalid config

Generating validation schema for 24 undocumented keys...
```

### Feature flag design
```
User: /godmode:config Design feature flags for the new checkout flow

Config: Designing flag system...

Flag: FEATURE_CHECKOUT_V2
Type: release
Rollout: percentage-based
  Dev: 100% (always on)
  Staging: 100% (always on)
  Prod: 0% → 5% → 25% → 50% → 100%

Code locations: src/pages/checkout.tsx, src/api/orders.ts
Cleanup: When at 100%, remove flag checks and delete legacy checkout code
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full config audit — parity, validation, secrets, flags |
| `--parity` | Environment parity check only |
| `--validate` | Config validation schema check only |
| `--flags` | Feature flag inventory and hygiene check |
| `--secrets` | Secret management audit only |
| `--ab <name>` | Design an A/B test experiment |
| `--schema` | Generate validation schema for all config keys |
| `--drift` | Detect and report environment drift |

## HARD RULES

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
   grep -ri "launchdarkly\|unleash\|flagsmith\|split.io\|feature.flag" \
     package.json requirements.txt go.mod 2>/dev/null

5. Secret manager:
   grep -ri "aws.ssm\|vault\|secret.manager\|key.vault" src/ 2>/dev/null

6. Validation library:
   grep -ri "zod\|joi\|yup\|pydantic\|envalid" package.json pyproject.toml 2>/dev/null

-> Auto-inventory all config files and keys.
-> Auto-detect which environments exist.
-> Auto-identify secrets vs non-secrets.
-> Only ask user about expected drift justification.
```

## Anti-Patterns

- **Do NOT store secrets in config files.** Use environment variables or a secret manager. `.env` files are for local dev only.
- **Do NOT copy-paste config between environments.** Use templates with environment-specific overrides. Manual copying causes drift.
- **Do NOT add feature flags without an expiry plan.** Every flag is tech debt. Plan the cleanup before creating the flag.
- **Do NOT run A/B tests without sample size calculation.** Under-powered experiments give false results. Do the math first.
- **Do NOT skip startup validation.** An app that starts with invalid config will fail at runtime in harder-to-debug ways. Fail fast.
- **Do NOT use boolean env vars as strings.** `"true"` and `true` are different. Use a typed config parser.

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
- All configuration keys inventoried and documented.
- Secrets stored in a secret manager (not in config files or environment variables).
- Startup validation fails fast on missing or invalid config.
- Configuration drift between environments detected and explained.
- Feature flags have expiry dates and cleanup plans.
- Typed config parsing (no raw `process.env` string access in application code).
- Environment-specific overrides use templates, not copy-paste.
- Config changes are auditable (versioned, logged).

## Error Recovery
- **App fails to start after config change**: Check startup validation errors for the specific key that failed. Compare with the previous working config. Verify the config format matches the expected schema (type coercion issues are common).
- **Secret rotation breaks the app**: Use a config reload mechanism (environment variable re-read or config file watch). Test secret rotation in staging before production. Ensure the new secret is valid before revoking the old one.
- **Config drift between environments**: Run the drift detection tool to identify which keys differ. Determine if the drift is intentional (environment-specific) or accidental (missed update). Document intentional drift.
- **Feature flag stuck at 100% for months**: Flag has become tech debt. Schedule cleanup: remove the flag check, delete the flag, remove the old code path. Set a recurring reminder for flag cleanup.
- **Startup validation too strict (blocks deployment)**: Separate required and optional config. Use sensible defaults for non-critical config. Allow graceful degradation for optional features.
- **Environment variable injection fails in containers**: Verify the env vars are set in the container runtime config (not just the Dockerfile). Check for quoting issues in YAML/JSON config. Use `printenv` in the container to debug.

## Iterative Loop Protocol
```
current_env = 0
environments = detect_environments()  // e.g., [dev, staging, production]

WHILE current_env < len(environments):
  env = environments[current_env]
  1. INVENTORY: List all config keys and values for {env}
  2. CLASSIFY: Separate secrets from non-secrets
  3. VALIDATE: Check for missing keys, type mismatches, invalid values
  4. DRIFT: Compare with other environments, flag unexpected differences
  5. MIGRATE: Move secrets to secret manager if not already there
  6. LOG to .godmode/config-results.tsv
  7. current_env += 1
  8. REPORT: "Environment {current_env}/{total}: {env} — {keys} keys, {secrets} secrets, {drift} drift"

EXIT when all environments audited OR user requests stop
```

## Multi-Agent Dispatch
For multi-environment configuration management:
```
DISPATCH parallel agents (one per concern):

Agent 1 (worktree: config-inventory):
  - Inventory all config keys across all environments
  - Detect drift between environments
  - Scope: .env files, config directories, deployment configs
  - Output: Complete config inventory with drift report

Agent 2 (worktree: config-secrets):
  - Migrate secrets to secret manager
  - Configure secret rotation
  - Scope: .env files, secret references in code
  - Output: Secrets migrated to manager

Agent 3 (worktree: config-validation):
  - Add startup validation (Zod/pydantic/envconfig)
  - Add typed config access layer
  - Scope: src/config/, environment schema
  - Output: Validated config with typed access

MERGE ORDER: inventory → secrets → validation
CONFLICT RESOLUTION: secrets branch owns .env and secret references; validation branch owns config schema
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run config tasks sequentially: inventory, then secret migration, then validation setup.
- Use branch isolation per task: `git checkout -b godmode-config-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
