# /godmode:config

Environment and configuration management. Audits dev/staging/prod parity, validates config schemas, manages feature flags, and designs A/B test rollout strategies.

## Usage

```
/godmode:config                         # Full config audit — parity, validation, secrets, flags
/godmode:config --parity                # Environment parity check only
/godmode:config --validate              # Config validation schema check only
/godmode:config --flags                 # Feature flag inventory and hygiene check
/godmode:config --secrets               # Secret management audit only
/godmode:config --ab <name>             # Design an A/B test experiment
/godmode:config --schema                # Generate validation schema for all config keys
/godmode:config --drift                 # Detect and report environment drift
```

## What It Does

1. Inventories all config files, environment variables, and secret references
2. Compares configurations across dev/staging/prod to detect drift
3. Generates or validates config schemas with type, format, and range checks
4. Audits feature flags for staleness, ownership, and cleanup readiness
5. Designs A/B test experiments with sample size calculation and rollout strategy
6. Audits secret management for safety (no hardcoded secrets, rotation policy)

## Output
- Config audit report at `docs/config/<project>-config-audit.md`
- Validation schema (if generated)
- Commit: `"config: <project> — <verdict> (<N> keys, <N> flags, <N> issues)"`
- Verdict: HEALTHY / NEEDS ATTENTION / CRITICAL

## Next Step
If CRITICAL: Fix missing config keys and exposed secrets immediately.
If HEALTHY: `/godmode:ship` to deploy with confidence.

## Examples

```
/godmode:config                         # Full environment audit
/godmode:config --parity                # Are dev/staging/prod in sync?
/godmode:config --flags                 # Feature flag hygiene check
/godmode:config --ab new-pricing        # Design A/B test for new pricing
/godmode:config --secrets               # Are secrets handled safely?
```
