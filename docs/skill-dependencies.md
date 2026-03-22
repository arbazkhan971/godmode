# Skill Dependencies

How godmode's 15 skills relate to, call, and feed data to each other.

---

## 1. Skill Chain: The Ideal Flow

```
think → plan → [predict] → build → test → fix → review → optimize → secure → ship → finish
```

This is the full lifecycle from idea to deployed code. Most real workflows skip steps.

**When to skip steps:**

- **Skip think + plan** when the change touches 2 files or fewer. Build can run without a plan for trivial changes.
- **Skip predict** when confidence is high and the feature is low-risk. Predict is recommended but optional (bracketed in the chain). Use it for large plans (>10 tasks) or unfamiliar domains.
- **Skip test** when the codebase already has adequate coverage for the changed paths. Build already runs test_cmd after every merge.
- **Skip fix** when build, lint, and test all pass. Fix activates only when errors exist.
- **Skip optimize** when performance is not a concern or the change is not on a hot path.
- **Skip secure** for internal tools or changes with no auth/input/network surface.
- **Skip finish** when you want the branch to remain open for further work.

**Why the order matters:** Each skill assumes the output of prior skills. Build reads plan.yaml. Fix needs failing test output. Review needs committed code. Ship needs passing checks. Reversing the order (e.g., shipping before review) violates the invariants each skill depends on.

---

## 2. Skill Dependency Matrix

| Skill | Calls | Called By | Reads From | Writes To |
|-------|-------|-----------|------------|-----------|
| **godmode** | Any skill (router) | User invocation | Stack detection files (package.json, go.mod, etc.) | — |
| **think** | — | godmode, predict (gate < 7) | Codebase via `git ls-files` | `.godmode/spec.md`, `.godmode/think-log.tsv` |
| **plan** | — | godmode, think (implicit next step) | `.godmode/spec.md` | `.godmode/plan.yaml`, `.godmode/plan-log.tsv` |
| **predict** | think (gate < 7 or any NO vote) | godmode, plan (suggested for >10 tasks) | `.godmode/spec.md` | `.godmode/predict-log.tsv` |
| **scenario** | — | godmode | Spec + source code | `.godmode/scenario-log.tsv`, `tests/scenarios/` |
| **build** | fix (on merge/verify failure, max 3) | godmode | `.godmode/plan.yaml` | `.godmode/build-log.tsv`, source files |
| **test** | — | godmode | Coverage reports, source code | Test files, `.godmode/test-results.tsv` |
| **fix** | debug (when skipped errors remain) | build, ship, finish, debug | build_cmd + lint_cmd + test_cmd output | Source files, `.godmode/fix-log.tsv` |
| **debug** | fix (after root cause found) | godmode, fix (when skipped > 0) | test_cmd output, stack traces, git history | `.godmode/debug-findings.tsv` |
| **review** | — (auto-fixes NITs only) | godmode | `git diff main...HEAD`, source code | `.godmode/review-log.tsv`, NIT-fix commits |
| **optimize** | — | godmode | In-scope files, `.godmode/optimize-results.tsv` | `.godmode/optimize-results.tsv`, source files |
| **perf** | fix or optimize (suggested next) | godmode, optimize (deeper analysis) | Source code, runtime profilers | `docs/perf/`, flame graphs, benchmarks |
| **secure** | — (auto-fix with `--fix` flag) | godmode | Source code, dependency manifests, routes | `.godmode/security-findings.tsv` |
| **ship** | fix (on checklist failure) | godmode | `git log`, build/lint/test output | `.godmode/ship-log.tsv`, PR/tag/release |
| **finish** | fix (on pre-check failure) | godmode | `git status`, `git diff`, build/lint/test output | `.godmode/session-log.tsv`, merged commits |

**Key call chains in practice:**

- `build → fix` — Build calls fix up to 3 times when build_cmd, lint_cmd, or test_cmd fail after a merge.
- `ship → fix` — Ship refuses to proceed if any checklist item fails and delegates to fix.
- `finish → fix` — Finish requires clean state; delegates to fix when checks fail.
- `debug → fix` — Debug identifies root cause, then hands off to fix for the actual repair.
- `fix → debug` — When fix skips errors (3 failed attempts), it recommends debug for deeper investigation.
- `predict → think` — When confidence is below 7 or any persona votes NO, predict gates back to think with accumulated risks as constraints.

---

## 3. Skill Comparison: When to Use Which?

### test vs verify

| | test | verify |
|---|---|---|
| **Purpose** | Generate new tests using TDD (red-green-refactor) | Run a command and confirm a specific claim |
| **Output** | Test files, coverage delta | PASS/FAIL verdict with evidence |
| **Loop** | Iterates until coverage target met | Single evaluation (3 runs for numeric, 1 for boolean) |
| **Use when** | Coverage is low, new code needs tests | You need proof that a claim is true right now |

test creates artifacts. verify produces judgments. Use test to write tests, verify to check if something works.

### fix vs debug

| | fix | debug |
|---|---|---|
| **Purpose** | Eliminate known errors, one commit per fix | Find the root cause of unknown failures |
| **Input** | Error output from build/lint/test commands | Failing behavior with unclear origin |
| **Method** | Read error, patch source, verify error count drops | Reproduce, bisect, inspect state, prove root cause |
| **Use when** | You see "TypeError at line 42" | You see "sometimes returns wrong result" |

fix is mechanical: error in, patch out. debug is investigative: symptom in, root cause out. debug hands off to fix once the cause is proven.

### optimize vs perf

| | optimize | perf |
|---|---|---|
| **Purpose** | Autonomous metric improvement loop (3 parallel agents per round) | Profile once, identify bottlenecks with evidence |
| **Metric** | User-specified shell command outputting a number | CPU%, memory MB, latency ms from profiling tools |
| **Loop** | Runs until target reached or diminishing returns | Iterates through profiling modules (CPU, memory, concurrency, benchmarks) |
| **Use when** | You have a metric and want it better, hands-off | You need to understand why something is slow before deciding what to do |

perf diagnoses. optimize treats. Run perf first to find the bottleneck, then optimize to systematically improve the metric.

### plan vs think

| | think | plan |
|---|---|---|
| **Purpose** | Explore 2-3 approaches, pick one, write spec | Decompose a spec into executable tasks with deps |
| **Output** | `.godmode/spec.md` | `.godmode/plan.yaml` |
| **Use when** | You do not know the approach yet | You know the approach, need to break it into tasks |

think decides what to build. plan decides how to build it. think always precedes plan in the chain.

### review vs secure

| | review | secure |
|---|---|---|
| **Purpose** | 4-agent code review (correctness, security, performance, style) | Dedicated security audit (STRIDE + OWASP Top 10 + 4 red-team personas) |
| **Depth** | Broad scan across 4 dimensions | Deep dive into security only (40+ test cases) |
| **Output** | APPROVE / REQUEST CHANGES / REJECT with score | PASS/FAIL with finding counts by severity |
| **Use when** | Code is ready for merge and needs a quality check | You need a thorough security audit before production |

review includes a security pass but it is surface-level. secure runs a full audit with exploit steps and proof. For security-sensitive code, run both.

### ship vs finish

| | ship | finish |
|---|---|---|
| **Purpose** | Deploy code: create PR, trigger deploy, cut release | Finalize a branch: merge, PR, keep, or discard |
| **Scope** | Checklist + dry-run + ship action + post-ship verify | Pre-check + choose outcome + cleanup |
| **Use when** | Code needs to go to production or a PR needs creating | Branch work is done and you need to decide its fate |

ship is outward-facing (deploy, release, PR with verification). finish is inward-facing (branch lifecycle management). ship includes a post-deploy health check and rollback. finish includes squash-merge and branch deletion.

### predict vs scenario

| | predict | scenario |
|---|---|---|
| **Purpose** | 5-persona expert evaluation with confidence gate | Systematic edge case exploration across 12 dimensions |
| **Output** | Confidence score (1-10) + PROCEED/REVISE/RETHINK gate | Scored scenario list + test skeletons for HIGH/CRITICAL |
| **Use when** | You need a go/no-go decision on an approach | You need to enumerate what could break at runtime |

predict evaluates feasibility and risk at the design level. scenario enumerates failure modes at the implementation level. predict gates the approach; scenario stress-tests the code.

---

## 4. Data Flow: What Files Skills Share

### Core artifacts

```
.godmode/spec.md        think ──writes──→ plan, predict, scenario ──read
.godmode/plan.yaml      plan ──writes──→ build ──reads
```

### Per-skill logs (append-only TSV)

```
.godmode/think-log.tsv         ← think
.godmode/plan-log.tsv          ← plan
.godmode/predict-log.tsv       ← predict
.godmode/scenario-log.tsv      ← scenario
.godmode/build-log.tsv         ← build
.godmode/test-results.tsv      ← test
.godmode/fix-log.tsv           ← fix
.godmode/debug-findings.tsv    ← debug
.godmode/review-log.tsv        ← review
.godmode/optimize-results.tsv  ← optimize (also read by optimize for last-10 review)
.godmode/security-findings.tsv ← secure
.godmode/ship-log.tsv          ← ship
.godmode/verify-log.tsv        ← verify
```

### Session log (shared)

```
.godmode/session-log.tsv       ← all skills (timestamp, skill, iters, kept, discarded, outcome)
```

### Test artifacts

```
tests/scenarios/               ← scenario (test skeletons for HIGH/CRITICAL findings)
docs/perf/                     ← perf (flame graphs, profile reports)
```

### Data flow diagram

```
                    .godmode/spec.md
                         │
          think ─────────┤
                         ▼
          plan ──── .godmode/plan.yaml
                         │
          predict ───────┤ (reads spec, gates back to think)
                         ▼
          build ──── source files ──── build/lint/test commands
            │                              │
            └──→ fix ◄─────────────────────┘
                  │
                  └──→ debug (when fix skips errors)
                         │
                         └──→ fix (after root cause found)

          review ──── git diff ──── NIT-fix commits
          optimize ── metric cmd ── source files (cherry-pick winners)
          perf ────── profilers ─── docs/perf/ + flame graphs
          secure ──── source code ── security-findings.tsv
          ship ────── checklist ──── PR / tag / release
          finish ──── git status ─── squash-merge + branch delete
```

---

## 5. Entry Points

### Can be first in a chain (no prior context required)

| Skill | Why it works standalone |
|-------|----------------------|
| **think** | Starts from a user request and codebase scan. Produces spec.md from scratch. |
| **fix** | Reads error output directly from build/lint/test commands. Needs only a broken codebase. |
| **debug** | Starts from a failing test or symptom. Needs only reproducible failure. |
| **test** | Reads coverage reports and source code. Works on any codebase with a test runner. |
| **review** | Reads git diff. Works whenever there are committed changes vs main. |
| **secure** | Scans source code, deps, and routes. Works on any codebase. |
| **perf** | Profiles running code. Needs only a target to measure. |
| **scenario** | Can read source code directly if no spec exists. |
| **verify** | Takes any claim + command. Fully self-contained. |
| **godmode** | The router itself. Detects phase and dispatches to the right skill. |

### Require prior context

| Skill | What it needs | Provided by |
|-------|--------------|-------------|
| **plan** | `.godmode/spec.md` or user-provided spec | think |
| **predict** | `.godmode/spec.md` or user-provided proposal | think |
| **build** | `.godmode/plan.yaml` (skippable for <=2 file changes) | plan |
| **optimize** | A metric command, scope, and baseline | User input (or perf findings) |
| **ship** | Commits on a branch (`git log main..HEAD`) | build, fix, or manual work |
| **finish** | A branch with work to finalize | Any prior skill that created commits |

---

## 6. Error Recovery Chains

When a skill encounters a failure, Godmode has built-in recovery chains. These chains define which skill handles the error, how many retries are allowed, and what happens when recovery is exhausted.

### Recovery chain definitions

| Trigger | Recovery skill | Max retries | On exhaustion |
|---------|---------------|-------------|---------------|
| `build` task fails guard rails | `fix` | 3 | Revert task, log DISCARDED, move to next |
| `ship` checklist item fails | `fix` | 2 | Abort ship, report failing item |
| `finish` pre-check fails | `fix` | 2 | Abort finish, report failing check |
| `fix` cannot resolve after max retries | `debug` | 1 (diagnostic only) | Log SKIPPED, recommend manual investigation |
| `debug` identifies root cause | `fix` | 3 (new chain) | Log UNRESOLVED, report root cause to user |
| `optimize` approach fails verification | (self) | 0 | Revert approach, try next; if all fail, end round |
| `predict` confidence < 7 | `think` | 1 (rethink with risks) | Proceed with warnings if user confirms |

### Chain execution rules

1. **Max chain length: 3 hops.** A chain like `build -> fix -> debug -> fix` is the maximum. If the second `fix` also fails, the error is logged and the user is notified. Godmode never enters an unbounded recovery loop.
2. **Each hop resets the retry counter.** When `debug` hands off to `fix`, fix gets a fresh 3 retries. The retries consumed in the original `build -> fix` chain do not carry over.
3. **Revert before retry.** Every failed fix attempt is reverted (`git reset --hard HEAD~1`) before the next attempt. This ensures each retry starts from a clean state, not from a broken partial fix.
4. **Chains do not cross skill boundaries silently.** Every hop is logged in the session log with the chain path (e.g., `build -> fix -> debug -> fix`) so the user can trace the recovery path.
5. **User notification at exhaustion.** When a chain is exhausted, the skill reports what failed, what was tried, and what the user should investigate manually. It never silently drops errors.

### Example: full recovery chain in practice

```
build task T3: "add WebSocket handler"
  -> test_cmd FAIL: "TypeError: ws.on is not a function"
  -> fix attempt 1: patch import statement -> test_cmd FAIL (different error)
  -> revert fix 1
  -> fix attempt 2: rewrite handler with correct API -> test_cmd FAIL (timeout)
  -> revert fix 2
  -> fix attempt 3: add missing dependency + rewrite -> test_cmd PASS, lint PASS
  -> KEEP commit

Total chain: build -> fix (3 attempts, succeeded on 3rd)
```

```
build task T5: "add rate limiter middleware"
  -> test_cmd FAIL: "Cannot read property 'limit' of undefined"
  -> fix attempt 1: initialize config -> test_cmd FAIL
  -> fix attempt 2: rewrite middleware -> test_cmd FAIL
  -> fix attempt 3: different approach -> test_cmd FAIL
  -> fix exhausted (3/3 failed)
  -> debug: reproduce, bisect -> root cause: incompatible library version
  -> fix (new chain): pin library version -> test_cmd PASS
  -> KEEP commit

Total chain: build -> fix (3, exhausted) -> debug (1) -> fix (1, succeeded)
Chain length: 3 hops (within limit)
```

### Max chain length guidance

- **3 hops is the hard limit.** This prevents runaway recovery loops that consume tokens without progress.
- **Most chains resolve in 1 hop.** In practice, `build -> fix` resolves 80%+ of failures within 3 fix retries.
- **2-hop chains (`build -> fix -> debug`) are uncommon** but handle cases where the error message is misleading and the real cause is deeper.
- **3-hop chains (`build -> fix -> debug -> fix`) are rare** and indicate a genuinely complex issue. If this chain also fails, manual intervention is the right answer.
- **Never extend beyond 3 hops.** If `build -> fix -> debug -> fix` fails, log the full chain, report findings, and stop. Do not recurse into another `debug -> fix` cycle.

---

### Implicit chains the orchestrator follows

When no explicit skill is requested, godmode detects the current phase and dispatches:

```
No spec.md, no plan        → think
spec.md exists, no plan    → plan
plan.yaml, incomplete tasks → build
Code exists, tests failing  → fix
Tests passing, unreviewed   → review
Reviewed                    → optimize or ship
```

This means invoking `/godmode` with no arguments always advances the project to the next logical step.
