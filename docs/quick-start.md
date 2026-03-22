# Godmode Quick Start

**126 skills. 7 subagents. 5 platforms. Zero configuration.**

---

## Which Skill Should I Use?

Start here. Find your situation, follow the arrow.

```
"I have an idea but no code"
  └─→ /godmode:think → /godmode:plan → /godmode:build

"I have code but it's broken"
  ├─→ errors are clear (stack trace, lint failures) → /godmode:fix
  └─→ cause is unknown ("it just doesn't work")    → /godmode:debug

"I have working code, want it better"
  ├─→ it's slow (performance)         → /godmode:optimize
  └─→ it's messy (structure/debt)     → /godmode:refactor

"I want to check my code"
  ├─→ correctness + style             → /godmode:review
  ├─→ security vulnerabilities        → /godmode:secure
  └─→ test coverage gaps              → /godmode:test

"I'm ready to ship"
  ├─→ deploy to production            → /godmode:ship
  └─→ merge PR / finalize branch      → /godmode:finish

"I'm not sure"
  └─→ /godmode  (orchestrator auto-detects your phase)
```

The orchestrator reads your repo state -- spec files, plan files, test results, git history -- and routes to the right skill automatically. When in doubt, just type `/godmode`.

---

## Platform Quick Reference

Clone the repo, then run one command to install:

| Platform | Install | First command |
|----------|---------|---------------|
| **Claude Code** | `claude plugin install godmode` | `/godmode:think design a rate limiter` |
| **Cursor** | `bash godmode/adapters/cursor/install.sh .` | `/godmode:think design a rate limiter` |
| **Gemini CLI** | `bash godmode/adapters/gemini/install.sh .` | `/godmode:think design a rate limiter` |
| **Codex** | `bash godmode/adapters/codex/install.sh .` | `codex "Run /godmode:think design a rate limiter"` |
| **OpenCode** | `bash godmode/adapters/opencode/install.sh .` | `/godmode:think design a rate limiter` |

Replace `godmode/` with the actual path to your clone. All 126 skills work identically on every platform. The only difference is execution model (parallel agents on Claude Code/Cursor, sequential on others).

---

## 5-Minute Tutorials

### Tutorial 1: Make My API Faster

**Skill chain:** `optimize` (standalone loop)

```
/godmode:optimize
Goal: Reduce API response time for GET /api/products
Metric: curl -o /dev/null -s -w '%{time_total}' http://localhost:3000/api/products
Direction: ↓
Iterations: 10
```

Sample output:

```
Godmode: stack=Next.js, skill=optimize, phase=OPTIMIZE. Dispatching.

  BASELINE    847ms (median of 3 runs)
  ROUND 1     554ms  KEPT  (-34.5%)  — added index on category_id
  ROUND 2     382ms  KEPT  (-31.0%)  — enabled gzip compression
  ROUND 3     276ms  KEPT  (-27.7%)  — eager loading for posts
  ROUND 4     290ms  REVERTED        — batch loader (guard failed)
  ROUND 5     226ms  KEPT  (-18.2%)  — connection pool to 20
  ROUND 6     198ms  KEPT  (-12.4%)  — Redis response cache

  optimize: 847ms -> 198ms (76.6%). 5 kept, 1 discarded across 6 rounds.
```

Every improvement is measured with your metric command. Every regression is auto-reverted via `git reset --hard HEAD~1`. Every experiment is logged to `.godmode/optimize-results.tsv`.

---

### Tutorial 2: Fix Failing Tests

**Skill chain:** `fix` (standalone loop)

```
/godmode:fix
```

That's it. No arguments needed. Fix auto-detects your test/lint/build commands from the stack (e.g., `npm test` for Node, `pytest` for Python, `cargo test` for Rust).

Sample output:

```
Godmode: stack=TypeScript, skill=fix, phase=FIX. Dispatching.

  ERRORS: 7 (3 build, 1 lint, 3 test)
  iter 1  fix(auth): missing return type on verifyToken        KEPT  (6 remaining)
  iter 2  fix(db): nullable field not handled in migration     KEPT  (5 remaining)
  iter 3  fix(api): unused import triggering lint error        KEPT  (4 remaining)
  iter 4  fix(auth): test expected 401 but got 403             KEPT  (3 remaining)
  iter 5  fix(cart): off-by-one in quantity validation         KEPT  (2 remaining)
  iter 6  fix(cart): snapshot outdated after schema change     KEPT  (1 remaining)
  iter 7  fix(db): connection pool timeout in test env         KEPT  (0 remaining)

  Fixed: 7 -> 0 in 7 iterations. Skipped: none.
```

Fix priority order: build errors first (code must compile), then type errors, then lint, then tests. One fix per commit. If a fix causes a regression, it gets reverted and retried up to 3 times.

---

### Tutorial 3: Build a New Feature

**Skill chain:** `think` then `plan` then `build`

```
/godmode:think Add user notifications -- email on new follower, in-app on new comment
```

Output: a structured spec covering approaches (polling vs push, email providers, DB schema for notification preferences), trade-offs, and a recommendation.

```
/godmode:plan implement the notification spec
```

Output: a task list with dependencies and execution rounds:

```
Round 1: [1] Create notifications table  [2] Add email service adapter
Round 2: [3] Wire follower event handler (depends on 1,2)
         [4] Wire comment event handler (depends on 1,2)
Round 3: [5] Add notification preferences API (depends on 1)
Round 4: [6] Integration tests (depends on 3,4,5)
```

```
/godmode:build execute the notification plan
```

Build dispatches up to 5 parallel agents (Claude Code/Cursor) or runs tasks sequentially (other platforms). Each agent writes tests first, then implements, then verifies. Conflicts are auto-resolved; failures are rolled back.

---

### Tutorial 4: Security Check Before Deploy

**Skill chain:** `secure` then `ship`

```
/godmode:secure audit the authentication module
```

Runs STRIDE threat modeling + OWASP Top 10 scan with 4 adversarial personas. Output includes severity-ranked findings with file:line references and remediation steps.

```
/godmode:ship deploy to production
```

Ship runs pre-flight checks (tests pass, no lint errors, no secrets in diff), executes a dry-run deploy, then the real deploy, then post-deploy verification. Any failure at any stage halts the pipeline.

---

## Skill Cheat Sheet

Grouped by what you are trying to do, not alphabetical.

### Create Something New

| Skill | Use when | Example |
|--|--|--|
| `think` | You need a design/spec | `/godmode:think design a caching layer` |
| `predict` | You want expert evaluation of a design | `/godmode:predict will this auth flow scale?` |
| `scenario` | You want to explore edge cases | `/godmode:scenario what could go wrong with this queue?` |
| `plan` | You have a spec, need a task breakdown | `/godmode:plan implement the caching spec` |
| `build` | You have tasks, need implementation | `/godmode:build execute the caching plan` |

### Fix or Debug

| Skill | Use when | Example |
|--|--|--|
| `fix` | Errors are clear (stack traces, lint) | `/godmode:fix` |
| `debug` | Cause is unknown | `/godmode:debug why does checkout return 500?` |

### Improve Existing Code

| Skill | Use when | Example |
|--|--|--|
| `optimize` | Code is slow (measurable metric) | `/godmode:optimize reduce query time` |
| `refactor` | Code is messy (structure/readability) | `/godmode:refactor extract auth into a module` |
| `test` | Test coverage is low | `/godmode:test add coverage for the payment module` |

### Verify and Review

| Skill | Use when | Example |
|--|--|--|
| `review` | Pre-merge code review | `/godmode:review review the rate limiter PR` |
| `secure` | Security audit | `/godmode:secure audit auth and session handling` |
| `verify` | Prove a claim with evidence | `/godmode:verify prove the cache hit rate is >90%` |

### Ship and Finalize

| Skill | Use when | Example |
|--|--|--|
| `ship` | Deploy to production | `/godmode:ship deploy to staging` |
| `finish` | Merge PR, clean up branch | `/godmode:finish merge this branch` |

### Specialized Skills (100+)

Beyond the 15 core skills, godmode includes 100+ specialized skills for specific domains. Use them directly or let the orchestrator route you:

| Category | Skills | Example |
|----------|--------|---------|
| Architecture | `architect`, `rfc`, `ddd`, `pattern`, `schema` | `/godmode:architect design the event system` |
| API/Backend | `api`, `graphql`, `grpc`, `cache`, `queue`, `ratelimit` | `/godmode:ratelimit add rate limiting to /api/upload` |
| Frameworks | `react`, `nextjs`, `django`, `fastapi`, `rails`, `spring` | `/godmode:nextjs optimize SSR for the dashboard` |
| Security | `auth`, `rbac`, `pentest`, `secrets`, `crypto`, `comply` | `/godmode:auth implement OAuth2 PKCE flow` |
| DevOps | `k8s`, `docker`, `cicd`, `ghactions`, `infra`, `deploy` | `/godmode:k8s create deployment for the API` |
| Frontend | `ui`, `a11y`, `seo`, `state`, `forms`, `responsive` | `/godmode:a11y audit the checkout page` |
| Testing | `e2e`, `integration`, `loadtest`, `perf` | `/godmode:loadtest stress test /api/search` |
| AI/ML | `ml`, `rag`, `prompt`, `eval`, `mlops` | `/godmode:rag build retrieval pipeline for docs` |

Full list: [COMPLETE-SKILL-LIST.md](COMPLETE-SKILL-LIST.md)

---

## Reading Godmode Logs

Every skill appends to `.godmode/<skill>-results.tsv`. The TSV is the source of truth.

Example `optimize-results.tsv`:
```
round  agent    change              metric_before  metric_after  status
1      agent_1  add_index           847            554           kept
2      agent_2  enable_gzip         554            382           kept
3      agent_1  batch_loader        382            390           discarded
```

Read: Round 2 improved from 554->382 (31% better), kept. Round 3 made things worse (390>382), discarded.

---

## Enhanced Decision Tree

When in doubt, use this tree. Each branch tells you what NOT to pick.

```
"I have code but it's broken"
├─ errors are clear (stack trace, lint) → /godmode:fix
  (NOT debug — debug is for unclear failures)
└─ cause is unknown → /godmode:debug
   (NOT fix — fix assumes you know what's broken)

"I want to improve performance"
├─ have a metric command → /godmode:optimize
└─ don't know what's slow → /godmode:perf (profile first)
```

---

## Skill Output Format Guide

Every skill outputs a single summary line in a consistent format:

```
<Skill>: <before> → <after> (<delta>%). <kept> kept, <discarded> discarded. Status: DONE|PARTIAL.
```

Examples:
```
Optimize: 847ms → 198ms (76.6%). 5 kept, 1 discarded. Status: DONE.
Test: coverage 45% → 82%. 37 tests added. Status: DONE.
```

---

## Common Gotchas

**1. Using `fix` when you need `debug`.**
`fix` assumes the error message tells you what is wrong (build errors, lint failures, test assertions). If you see "it returns the wrong result but I don't know why," use `debug` instead -- it does root-cause analysis with techniques like `git bisect` and binary search.

**2. Skipping `think` and going straight to `build`.**
Without a spec, `build` has to guess at requirements. The `think` step takes 30 seconds and produces a spec that `plan` and `build` reference throughout. The full chain `think -> plan -> build` produces significantly better code than `build` alone.

**3. Not providing a measurable metric to `optimize`.**
Optimize needs a command that outputs a single number (e.g., `curl -s -w '%{time_total}'`, `hyperfine --export-json`, `pytest --benchmark-json`). If you say "make it faster" without a metric, optimize will ask you for one. Have it ready.

**4. Running `ship` without `secure` first.**
Ship runs pre-flight checks but does not do a deep security audit. If you are deploying auth, payment, or user data features, run `/godmode:secure` first. A good pre-deploy chain: `review -> secure -> ship`.

**5. Expecting parallel agents on Gemini CLI / Codex / OpenCode.**
Parallel agent dispatch (up to 5 agents per round) only works on Claude Code and Cursor. On other platforms, the same tasks run sequentially. Same results, just slower. No configuration needed -- godmode detects your platform automatically.

**6. Forgetting that every iterative skill commits before verifying.**
Skills like `fix`, `optimize`, `debug`, and `build` commit each change before running verification. If verification fails, the commit is reverted with `git reset --hard HEAD~1`. This means your git history stays clean, but you may see commits appear and disappear. This is intentional -- git is the undo mechanism.

**7. Manually editing files during a loop.**
While `optimize`, `fix`, or `build` is running its loop, do not edit files in the same branch. The skill tracks state via git commits and `.godmode/*.tsv` logs. External edits will confuse the loop. Wait for the skill to finish, or start a new branch.

---

## What Happens Under the Hood

When you type `/godmode` or `/godmode:<skill>`:

1. **Stack detection** -- reads `package.json`, `pyproject.toml`, `Cargo.toml`, etc. to identify your language, test command, lint command, and build command. Cached for the session.
2. **Skill routing** -- matches your request to a skill via keywords or, if ambiguous, detects your phase from repo state (no spec? -> think. spec but no plan? -> plan. plan with incomplete tasks? -> build).
3. **Execution** -- reads `skills/<skill>/SKILL.md` and follows it literally. Iterative skills run a WHILE loop. Each iteration: modify, commit, verify, keep-or-revert, log.
4. **Logging** -- every action is appended to `.godmode/<skill>-results.tsv` and `.godmode/session-log.tsv`. Nothing is overwritten.

---

## Next Steps

- **[FAQ](FAQ.md)** -- Common questions and troubleshooting
- **[Full Skill Catalog](COMPLETE-SKILL-LIST.md)** -- All 126 skills with descriptions
- **[Platform Details](../adapters/)** -- Deep-dive into each adapter
- **[Recipes](recipes/)** -- Pre-built skill chains for common workflows
- **[CONTRIBUTING](../CONTRIBUTING.md)** -- Add your own skills (every skill is just a Markdown file)
