# Skill Chaining Reference

> Every valid skill chain, named workflow, and custom chain syntax for Godmode.

---

## Core Concept

Skills communicate through artifacts (files, commits, logs). Each skill produces output that the next skill consumes. Chains define the order in which skills execute for a given workflow.

```
Skill A ──produces artifact──> Skill B ──produces artifact──> Skill C
```

---

## Named Chains

### full-stack

The complete development lifecycle from idea to shipped product.

```
think → plan → build → test → review → optimize → ship
```

**When to use:** Major features, public-facing APIs, anything that needs the full quality gauntlet.

**Example:**
```
/godmode:think "User authentication with OAuth2"
# produces docs/specs/oauth2-auth.md

/godmode:plan
# produces docs/plans/oauth2-auth-plan.md, creates feature branch

/godmode:build
# implements code with TDD, produces src/ and tests/

/godmode:test
# adds missing coverage, runs RED-GREEN-REFACTOR

/godmode:review
# 2-stage review: automated checks + agent-based review

/godmode:optimize --goal "reduce auth response time"
# autonomous improvement loop on auth endpoints

/godmode:ship --pr
# 8-phase shipping workflow, creates pull request
```

**Artifact flow:**
```
spec.md → plan.md → code + tests → review report → optimized code → PR/deploy
```

---

### hotfix

Emergency path from bug discovery to production fix.

```
debug → fix → verify → ship
```

**When to use:** Production bugs that need fast resolution. Skips design, planning, and optimization.

**Example:**
```
/godmode:debug --error "TypeError: Cannot read property 'id' of undefined"
# produces root cause analysis

/godmode:fix --from-debug
# fixes the bug, adds regression test

/godmode:verify
# runs test suite, confirms fix

/godmode:ship --deploy production
# deploys directly to production
```

**Artifact flow:**
```
root cause analysis → fix + regression test → evidence of fix → deploy log
```

---

### security-hardening

Security audit cycle with remediation and re-verification.

```
secure → fix → verify → review → ship
```

**When to use:** Pre-launch security review, compliance requirements, post-incident hardening.

**Example:**
```
/godmode:secure
# STRIDE + OWASP audit, produces docs/security/audit.md

/godmode:fix
# remediates CRITICAL and HIGH findings

/godmode:verify
# confirms all fixes pass, no regressions

/godmode:review
# code review of security fixes

/godmode:ship --pr
# ships with security audit attached to PR
```

**Extended variant — double audit:**
```
secure → fix → secure → verify → review → ship
```
Re-runs the security audit after fixes to confirm all findings are resolved.

**Artifact flow:**
```
audit.md → fixes + tests → evidence → review report → PR/deploy
```

---

### performance

Performance optimization from measurement to validated deployment.

```
perf → optimize → loadtest → verify → ship
```

> Note: `perf` is a planned skill. Until implemented, start with `optimize`.

**Current practical chain:**
```
optimize → loadtest → verify → ship
```

**When to use:** Code works correctly but is too slow, needs capacity validation before launch.

**Example:**
```
/godmode:optimize --goal "reduce p99 latency" --target "< 200ms"
# autonomous optimization loop

/godmode:loadtest
# stress test with k6/Artillery at expected load

/godmode:verify
# confirms metrics meet targets under load

/godmode:ship --deploy staging
# deploy to staging for final validation
```

**Artifact flow:**
```
optimize-results.tsv → load test report → evidence → deploy log
```

---

### new-api

End-to-end API development from design through documentation.

```
api → contract → build → test → docs → ship
```

**When to use:** Designing and implementing a new API, especially in a microservices architecture.

**Example:**
```
/godmode:api --type rest
# designs API, produces OpenAPI spec

/godmode:contract --consumer web-app --consumer mobile-app
# defines consumer contracts, generates mock servers

/godmode:build
# implements endpoints with TDD

/godmode:test
# adds integration tests, contract verification

/godmode:docs
# generates API documentation from OpenAPI spec

/godmode:ship --pr
# ships with contract compatibility check (can-i-deploy)
```

**Extended variant — with design phase:**
```
think → api → contract → plan → build → test → docs → ship
```

**Artifact flow:**
```
OpenAPI spec → contracts + mocks → code + tests → test results → API docs → PR/deploy
```

---

### incident

Production incident response from detection through resolution.

```
incident → debug → fix → verify → deploy
```

**When to use:** Production is down or degraded. Structured response with timeline tracking.

**Example:**
```
/godmode:incident --classify
# SEV2: API response times > 10s, classifies severity

/godmode:debug
# investigates root cause, finds N+1 query

/godmode:fix
# fixes the N+1 query, adds regression test

/godmode:verify
# confirms fix resolves the issue

/godmode:deploy --strategy canary --percentage 10
# canary deploy to 10%, then progressive rollout
```

**Extended variant — with post-mortem:**
```
incident → debug → fix → verify → deploy → incident --postmortem
```

**Artifact flow:**
```
incident timeline → root cause → fix + test → evidence → deploy → post-mortem doc
```

---

### ml-pipeline

Machine learning from experimentation through production serving.

```
ml → pipeline → mlops → observe → ship
```

**When to use:** Building and deploying ML models with proper experiment tracking and production monitoring.

**Example:**
```
/godmode:ml
# tracks experiments, validates dataset, evaluates model

/godmode:pipeline
# builds data pipeline for training and inference

/godmode:mlops
# configures model serving, drift detection, retraining triggers

/godmode:observe
# sets up model performance monitoring, SLOs, alerts

/godmode:ship
# deploys model serving infrastructure
```

**Extended variant — with design phase:**
```
think → ml → pipeline → mlops → observe → ship
```

**Artifact flow:**
```
experiment logs → pipeline config → serving config → monitoring dashboards → deploy
```

---

## Additional Named Chains

### design-exploration

Deep design thinking before writing any code.

```
think → predict → scenario → think (refine)
```

**When to use:** Complex architecture decisions where you need to explore the problem space thoroughly before committing to an approach.

---

### test-coverage

Improve test coverage on existing code.

```
scenario → test → e2e → review
```

**When to use:** Existing codebase needs better test coverage. Generate scenarios, write unit tests, add E2E tests, then review.

---

### infrastructure

Provision and validate cloud infrastructure.

```
think → infra → k8s → config → secure → deploy
```

**When to use:** Setting up new infrastructure from scratch or major infrastructure changes.

---

### mobile-release

Full mobile app development and release cycle.

```
think → plan → build → mobile → a11y → visual → ship
```

**When to use:** Building and releasing mobile applications with full quality checks.

---

### data-migration

Database schema changes with safety checks.

```
think → migrate → test → verify → deploy
```

**When to use:** Schema changes that need careful planning and rollback strategies.

---

### compliance-audit

Full compliance review and remediation.

```
comply → secure → secrets → fix → verify → ship
```

**When to use:** Pre-audit preparation, regulatory compliance checks.

---

### frontend-quality

Frontend quality assurance pipeline.

```
ui → a11y → visual → i18n → e2e → review → ship
```

**When to use:** Frontend features that need comprehensive quality validation.

---

### onboarding

New team member codebase orientation.

```
onboard → docs → pair
```

**When to use:** When a new developer joins the project and needs to ramp up.

---

### cost-optimization

Cloud cost reduction with infrastructure changes.

```
cost → infra → config → verify → deploy
```

**When to use:** Reducing cloud bills with infrastructure right-sizing.

---

### observability-setup

Full observability stack for a service.

```
observe → loadtest → errortrack → config → deploy
```

**When to use:** Adding comprehensive monitoring to an existing service.

---

## Conditional Transitions

Some skill transitions depend on results:

```
secure → PASS       → ship
secure → FAIL       → fix → secure (re-audit)

review → APPROVED   → ship
review → CHANGES    → fix → review (re-review)

optimize → TARGET MET        → ship
optimize → DIMINISHING        → ship (accept current)
optimize → GUARD RAIL FAIL   → fix → optimize (resume)

contract → COMPATIBLE        → ship
contract → BREAKING CHANGES  → fix → contract (re-verify)

comply → COMPLIANT           → ship
comply → NON-COMPLIANT       → fix → comply (re-audit)

loadtest → CAPACITY OK       → ship
loadtest → BOTTLENECK FOUND  → optimize → loadtest (re-test)
```

---

## Loop Patterns

### Optimize-Fix Loop

When optimization breaks tests:
```
optimize → (guard rail failure) → fix → optimize (resume)
```

### Review-Fix Loop

When review finds issues:
```
review → (MUST FIX items) → fix → review (re-review)
```

### Secure-Fix-Secure Loop

When security audit finds vulnerabilities:
```
secure → (CRITICAL findings) → fix → secure (re-audit)
```

### Debug-Fix-Verify Loop

When debugging reveals multiple issues:
```
debug → fix → verify → (still failing?) → debug (dig deeper)
```

### Contract-Fix-Contract Loop

When contract tests detect breaking changes:
```
contract → (breaking change) → fix → contract (re-verify)
```

---

## Custom Chain Definition Syntax

You can define custom chains for your team's workflows. A chain is a sequence of skills with optional conditions.

### Basic Syntax

```yaml
# .godmode/chains.yaml
chains:
  my-feature:
    description: "Our team's standard feature workflow"
    steps:
      - think
      - predict
      - plan
      - build
      - test
      - a11y
      - review
      - ship

  quick-fix:
    description: "Fast bug fix without full review"
    steps:
      - debug
      - fix
      - verify
      - ship
```

### With Conditions

```yaml
chains:
  guarded-ship:
    description: "Ship with security and compliance gates"
    steps:
      - build
      - test
      - secure:
          on_fail: fix
          retry: true
      - comply:
          on_fail: fix
          retry: true
      - review:
          on_fail: fix
          retry: true
      - ship
```

### With Parallel Steps

```yaml
chains:
  parallel-quality:
    description: "Run quality checks in parallel"
    steps:
      - build
      - parallel:
          - test
          - a11y
          - visual
          - secure
      - review
      - ship
```

### Invoking a Custom Chain

```
/godmode --chain my-feature
/godmode --chain quick-fix
/godmode --chain guarded-ship
```

---

## Chain Selection Guide

| Situation | Recommended Chain |
|-----------|------------------|
| New feature, full quality | full-stack |
| Production bug, fast fix | hotfix |
| Security review before launch | security-hardening |
| Code is too slow | performance |
| Building a new API | new-api |
| Production is down | incident |
| Training and deploying ML model | ml-pipeline |
| Architecture decision needed | design-exploration |
| Need more test coverage | test-coverage |
| Setting up cloud infrastructure | infrastructure |
| Mobile app release | mobile-release |
| Database schema change | data-migration |
| Regulatory compliance check | compliance-audit |
| Frontend quality sweep | frontend-quality |
| New team member joining | onboarding |
| Cloud bill too high | cost-optimization |
| Adding monitoring to a service | observability-setup |

---

## See Also

- [Master Skill Index](skill-index.md) — Complete list of all skills
- [Decision Tree](decision-tree.md) — "What skill do I need?"
- [Quick Reference Card](quick-reference.md) — All commands on one page
- [Chaining Guide](chaining.md) — Artifact flow and communication patterns
