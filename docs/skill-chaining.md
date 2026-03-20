# Skill Chaining -- Practical Reference

How godmode skills chain together: what each skill produces, what the next skill consumes, and which steps you can skip.

---

## The Default Chain

The full development lifecycle runs 12 skills in sequence:

```
think -> predict -> scenario -> plan -> build -> test -> fix -> review -> optimize -> secure -> ship -> finish
```

```
think ----> predict --> scenario --> plan ----> build ----> test
[spec.md]   [eval]     [matrix]    [tasks]    [code]      [tests]
                                                             |
finish <--- ship <----- secure <-- optimize <- review <--- fix
[session]   [PR/deploy] [audit]    [tuned]    [findings]   [fixes]
```

Each arrow is a file-based handoff. The producing skill writes an artifact; the next skill reads it.

---

## Artifact Flow

| Skill | Primary artifact | Location | Consumed by |
|-------|-----------------|----------|-------------|
| **think** | Spec document | `.godmode/specs/<name>.md` | predict, scenario, plan |
| **predict** | Expert consensus | `.godmode/predictions/<name>.md` | plan, think (refine) |
| **scenario** | Edge-case matrix | `.godmode/scenarios/<name>.md` | plan, test |
| **plan** | Task list + deps | `.godmode/plan.md` | build |
| **build** | Code + commits + build log | `.godmode/build-log.tsv` | test, review, secure |
| **test** | Test files + results | `.godmode/test-results.tsv` | fix, optimize |
| **fix** | Fixes + regression tests | `.godmode/fix-log.tsv` | review, optimize |
| **review** | Severity-rated findings | `.godmode/review-log.tsv` | fix (if MUST FIX), ship |
| **optimize** | Tuned code + iteration log | `.godmode/optimize-results.tsv` | ship |
| **secure** | Audit + findings | `docs/security/<name>-audit.md` + `.godmode/security-findings.tsv` | fix, ship |
| **ship** | PR/deploy + ship log | `.godmode/ship-log.tsv` | finish |
| **finish** | Session archive | `.godmode/session-log.tsv` | (next cycle) |

All `.godmode/` artifacts are committed to git so they survive across sessions. Skills coordinate through `.godmode/state.json` (phase, plan_file, current_task, metrics, iteration count).

---

## Common Shortcut Chains

### Quick fix

```
fix -> verify
```

You already know what is broken. Fix it, confirm the suite passes.

### Feature (standard)

```
think -> plan -> build -> test -> ship
```

Good for internal tools, prototypes, and low-risk features.

### Performance

```
optimize
```

Standalone. Runs an autonomous modify/measure/keep-or-revert loop until the target is met.

### Security audit

```
secure -> fix -> verify
```

Audit, remediate, confirm. For high-stakes code, double-audit: `secure -> fix -> secure -> verify`.

### Full cycle

```
think -> plan -> build -> test -> review -> optimize -> secure -> ship
```

The standard chain for production features. Drops predict/scenario (optional) and finish (run separately).

### Bug triage

```
debug -> fix -> verify -> ship
```

Root-cause analysis, remediation, evidence, deploy.

### Design exploration (no code)

```
think -> predict -> scenario -> think (refine)
```

Explore architecture decisions before writing any code.

---

## Skipping Skills

| Skill | Can skip? | Note |
|-------|-----------|------|
| **predict** | Safe | Advisory only; less design validation |
| **scenario** | Safe | Advisory only; fewer test ideas upfront |
| **review** | Safe | Risk of style/quality issues going unnoticed |
| **optimize** | Safe | Code works, just not tuned |
| **finish** | Safe | Cleanup deferred; state not archived |
| **think** | Caution | plan/build lack context without a spec |
| **plan** | Caution | OK for single-file changes |
| **test** | Caution | Risky for anything beyond a one-liner |
| **secure** | Caution | Acceptable for internal/non-sensitive code |
| **build** | Never | Nothing to ship without it |
| **ship** | Never | Code stays local without it |
| **fix** (errors exist) | Never | Broken code should not advance |

If you skip a skill, downstream skills fall back to defaults gracefully. Godmode warns but does not block.

---

## Conditional Transitions

Some transitions branch on the preceding skill's result:

| Skill | On success | On failure |
|-------|-----------|------------|
| **secure** | ship | fix -> secure (re-audit) |
| **review** | ship | fix -> review (re-review) |
| **optimize** | ship | fix -> optimize (resume) |

These loops repeat until the gate passes or the user intervenes.

---

## Cross-Platform Note

Chaining works identically on macOS, Linux, and Windows (WSL). Only execution speed differs -- platforms with faster I/O and more cores complete parallel sub-agents sooner. Artifact format, file paths, and chain logic are platform-independent.

---

## Quick-Reference Table

| Goal | Chain | Pipeline flag |
|------|-------|---------------|
| Ship a feature end-to-end | think -> plan -> build -> test -> review -> optimize -> secure -> ship | `--pipeline full` |
| Build from an existing spec | plan -> build -> review | `--pipeline build` |
| Harden existing code | test -> secure -> fix -> optimize | `--pipeline harden` |
| Find and fix all bugs | debug -> fix -> verify | `--pipeline fix-all` |
| Ship existing feature | review -> secure -> ship -> finish | `--pipeline ship` |

Invoke with `/godmode --pipeline full` or chain ad-hoc with `/godmode:secure --chain fix --chain optimize`.

---

## See Also

- [Chaining Guide](chaining.md) -- artifact flow and communication patterns
- [Skill Chains Reference](skill-chains.md) -- named chains and custom chain YAML syntax
- [Quick Reference Card](quick-reference.md) -- all commands on one page
