# Skill Chaining Guide

Godmode skills are designed to chain together. Each skill produces an artifact that the next skill consumes. This guide explains the chaining patterns.

## The Default Chain

The recommended full workflow:

```
think ─→ predict ─→ scenario ─→ plan ─→ build ─→ optimize ─→ secure ─→ ship ─→ finish
  │         │          │          │        │         │          │         │        │
  ▼         ▼          ▼          ▼        ▼         ▼          ▼         ▼        ▼
 spec    expert     scenario    plan    code +    optimized  security    PR/     clean
         review     matrix     + tasks   tests     code      report    deploy   branch
```

## Artifact Flow

Each skill produces artifacts that later skills consume:

| Skill | Produces | Consumed By |
|-------|----------|-------------|
| **think** | `docs/specs/<name>.md` | plan, predict, scenario, review |
| **predict** | Expert review appended to spec | think (iteration), plan |
| **scenario** | `docs/scenarios/<name>.md` | test, plan |
| **plan** | `docs/plans/<name>-plan.md` | build |
| **build** | Code + tests + commits | optimize, review, secure |
| **test** | Test files | build, review |
| **review** | Review report | build (fixes), ship |
| **optimize** | `.godmode/optimize-results.tsv` | ship (changelog) |
| **debug** | Root cause analysis | fix |
| **fix** | `.godmode/fix-log.tsv` | optimize, review |
| **secure** | `docs/security/<name>-audit.md` | fix (remediations), ship |
| **ship** | `.godmode/ship-log.tsv`, PR/deploy | finish |

## Common Chains

### Chain 1: New Feature (Full)
```
think → plan → build → review → optimize → secure → ship → finish
```
Best for: Major features, public APIs, anything user-facing.

### Chain 2: New Feature (Quick)
```
think → plan → build → ship
```
Best for: Internal tools, small features, prototypes. Skip optimization and security when speed matters more than perfection.

### Chain 3: Bug Fix
```
debug → fix → review → ship
```
Best for: Reported bugs. Debug finds the cause, fix remediates, review verifies, ship deploys.

### Chain 4: Performance Work
```
optimize → review → ship
```
Best for: When code works correctly but is too slow. Jump straight to the optimization loop.

### Chain 5: Security Hardening
```
secure → fix → secure → ship
```
Best for: Pre-launch security review. Audit, fix findings, re-audit, ship.

### Chain 6: Design Exploration
```
think → predict → scenario → think (refine)
```
Best for: Complex architecture decisions. Brainstorm, get expert opinions, explore edge cases, refine the design.

### Chain 7: Test Coverage
```
scenario → test → review
```
Best for: Improving test coverage on existing code. Generate scenarios, write tests, review.

### Chain 8: Hotfix
```
debug → fix → ship --deploy production
```
Best for: Production incidents. Skip everything non-essential.

## Chaining Mechanics

### Automatic Transitions
Each skill suggests the next skill when it completes:

```
think completes → "Run /godmode:plan to decompose this into tasks."
plan completes  → "Run /godmode:build to start executing."
build completes → "Run /godmode:optimize to improve, or /godmode:ship to deliver."
fix completes   → "Run /godmode:optimize to continue, or /godmode:review to check."
secure completes (FAIL) → "Run /godmode:fix to remediate, then re-audit."
secure completes (PASS) → "Run /godmode:ship to deploy."
```

### Manual Overrides
You can jump to any skill at any time:

```
# Skip think and plan, go straight to build
/godmode:build

# Skip build, go straight to optimize
/godmode:optimize

# Skip everything, just ship
/godmode:ship
```

Godmode will warn you if you skip important steps but won't block you.

### Conditional Chains
Some transitions depend on results:

```
secure → PASS → ship
secure → FAIL → fix → secure (re-audit)

review → APPROVED → ship
review → REQUEST CHANGES → fix → review (re-review)

optimize → TARGET MET → ship
optimize → DIMINISHING RETURNS → ship (accept current state)
```

## Loop Patterns

### The Optimize-Fix Loop
When optimization breaks tests:
```
optimize → (guard rail failure) → fix → optimize (resume)
```

### The Review-Fix Loop
When review finds issues:
```
review → (MUST FIX items) → fix → review (re-review)
```

### The Secure-Fix-Secure Loop
When security audit finds vulnerabilities:
```
secure → (CRITICAL findings) → fix → secure (re-audit)
```

## Tips for Effective Chaining

### 1. Let skills do their job
Each skill has a clear scope. Don't try to combine steps — let think produce the spec, then let plan consume it. The handoff is where quality happens.

### 2. Don't skip the artifacts
Skills communicate through files (specs, plans, reports). These files are the memory of your project. Without them, later skills lack context.

### 3. The orchestrator helps
Run `/godmode` (without a subcommand) at any point to get a recommendation for the next skill. The orchestrator reads the project state and suggests the best next step.

### 4. Chains can be partial
You don't have to run the full chain every time. For a quick bug fix, `debug → fix → ship` is perfectly fine. Use the full chain for important features.

### 5. Re-enter at any point
If you paused work yesterday at the build phase, today you can resume with `/godmode:build --continue` without re-running think and plan.
