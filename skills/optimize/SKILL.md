---
name: optimize
description: |
  Core autonomous iteration loop — the heart of Godmode. Activates when user wants to improve code quality, performance, or any measurable metric through autonomous experimentation. Runs a disciplined loop: measure baseline, hypothesize, modify, verify mechanically, keep if better or revert if worse, repeat. Git-as-memory ensures every experiment is tracked. Features: automatic metric detection, multi-agent parallel optimization, diminishing returns detection, domain-specific playbooks, compound optimization, regression prevention, and ASCII progress visualization. Triggers on: /godmode:optimize, "make this faster", "improve this", "optimize", or when godmode orchestrator detects OPTIMIZE phase.
---

# Optimize — Autonomous Iteration Loop

## When to Activate
- User invokes `/godmode:optimize`
- User says "make this faster," "improve performance," "optimize," "iterate on this"
- Godmode orchestrator routes here (implementation exists, tests pass, quality improvement desired)
- After build phase completes and user wants to push quality further
- When a specific metric needs improvement (response time, bundle size, memory usage, etc.)

## The Core Loop

This is the most important skill in Godmode. Everything else exists to support this loop.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE AUTONOMOUS LOOP                               │
│                                                                     │
│   ┌──────────┐     ┌──────────┐     ┌──────────────┐              │
│   │ DETECT   │────▶│ MEASURE  │────▶│  MULTI-AGENT │              │
│   │ METRICS  │     │ BASELINE │     │  HYPOTHESIZE │              │
│   └──────────┘     └──────────┘     └──────────────┘              │
│        ▲                                   │                       │
│        │                          ┌────────┼────────┐              │
│        │                          ▼        ▼        ▼              │
│   ┌──────────┐              ┌────────┐┌────────┐┌────────┐        │
│   │ COMPOUND │              │AGENT 1 ││AGENT 2 ││AGENT 3 │        │
│   │ + REGRESS│              │WorktreeA││WorktreeB││WorktreeC│       │
│   │ PREVENT  │              └────┬───┘└────┬───┘└────┬───┘        │
│   └──────────┘                   │         │         │             │
│        ▲                         ▼         ▼         ▼             │
│        │                    ┌──────────────────────────┐           │
│        │                    │   VERIFY ALL 3. KEEP     │           │
│   ┌──────────┐              │   THE BEST. REVERT REST. │           │
│   │ DIMINISH │◀─────────────│   VISUALIZE PROGRESS.    │           │
│   │ RETURNS? │              └──────────────────────────┘           │
│   └──────────┘                                                     │
│                                                                     │
│   Every iteration: git commit. Every decision: evidence.            │
│   Every round: 3 parallel agents. Every plateau: radical pivots.    │
└─────────────────────────────────────────────────────────────────────┘
```

### THE LOOP — EXACT EXECUTION PROTOCOL

This is the loop body. Follow it literally. Not the phases below — THIS.

```
current_round = 0
max_rounds = N  # from "Iterations: N" or Infinity if unbounded
baseline = run_verify_command_3x_take_median()
log_tsv(round=0, status="baseline", metric=baseline)

WHILE current_round < max_rounds:
    current_round += 1

    # 1. REVIEW (30 seconds max)
    Read in-scope files. Read last 10 entries from .godmode/optimize-results.tsv.
    Read git log --oneline -10.
    IF bounded AND (max_rounds - current_round) < 3: prioritize exploitation over exploration.

    # 2. SELECT 3 HYPOTHESES from playbook (Phase 3)
    Pick 3 independent, untested hypotheses.
    IF all playbook entries exhausted: generate new ones from codebase analysis.
    IF >5 consecutive discards: trigger RADICAL MODE (opposite of what failed).

    # 3. DISPATCH 3 AGENTS IN PARALLEL (Phase 4)
    FOR agent_id IN [1, 2, 3]:
        Create worktree: git worktree add .worktree-agent-{agent_id}
        Agent makes ONE change, commits: "optimize: round {current_round} agent {agent_id} — {description}"
        Agent runs guard command. Agent runs verify 3x, takes median.
        Agent reports: {metric, commit_sha, description, guard_pass}

    # 4. PICK WINNER
    Sort agents by metric improvement (descending).
    best_agent = agents[0]  # best metric
    IF best_agent.metric_improved AND best_agent.guard_passed:
        Cherry-pick best_agent.commit onto main branch.
        baseline = best_agent.metric  # new baseline
        STATUS = "keep"
    ELIF best_agent.metric_improved AND NOT best_agent.guard_passed:
        Rework (max 2 attempts). IF still fails: STATUS = "discard"
    ELSE:
        STATUS = "discard"  # no agent improved

    # 5. CLEANUP worktrees
    Remove all worktrees.

    # 6. LOG
    FOR each agent: append row to .godmode/optimize-results.tsv
    Append to .godmode/session-log.tsv

    # 7. STATUS PRINT (every 5 rounds)
    IF current_round % 5 == 0:
        Print: "Round {current_round}: metric at {baseline} (from {original}, {delta}%), {keeps}/{discards}"
        Print ASCII bar chart.

    # 8. DIMINISHING RETURNS CHECK
    IF last 3 KEEP deltas are all < 1%:
        Trigger RADICAL MODE (Phase 6)
    IF radical mode exhausted:
        Trigger COMPOUND OPTIMIZATION (Phase 7)
    IF compound exhausted:
        Print summary and STOP.

    # 9. STOP CONDITIONS
    IF target_reached: Print summary. STOP.
    IF max_rounds reached: Print summary. STOP.
    IF guard permanently broken: Print summary. STOP.

    # 10. REPEAT — go to top of WHILE loop
    # DO NOT ask "should I continue?"
    # DO NOT summarize between rounds
    # DO NOT pause for feedback
```

**If you are not tracking `current_round` and comparing against `max_rounds`, you are not running this skill.** The phases below are reference documentation for each step. The loop above is the execution protocol.

---

## Phase 0: Automatic Metric Detection

**Before asking the user anything**, scan the project to auto-detect available metrics and suggest verify commands. This eliminates guesswork and gets the user into the loop faster.

### Detection Procedure

Run all of the following scans in parallel:

```bash
# 1. Detect test infrastructure
TEST_FRAMEWORK="none"
if [ -f "package.json" ] && grep -q '"test"' package.json; then
  TEST_FRAMEWORK="npm"
elif [ -f "pytest.ini" ] || [ -f "setup.cfg" ] || [ -f "pyproject.toml" ]; then
  TEST_FRAMEWORK="pytest"
elif [ -f "Cargo.toml" ]; then
  TEST_FRAMEWORK="cargo"
elif [ -f "go.mod" ]; then
  TEST_FRAMEWORK="go"
elif [ -f "Gemfile" ] && grep -q 'rspec' Gemfile; then
  TEST_FRAMEWORK="rspec"
fi

# 2. Detect build system and bundle output
BUILD_SYSTEM="none"
if [ -f "package.json" ] && grep -q '"build"' package.json; then
  BUILD_SYSTEM="npm"
  # Check for common output dirs
  for dir in dist build out .next; do
    [ -d "$dir" ] && BUNDLE_DIR="$dir"
  done
elif [ -f "webpack.config.js" ] || [ -f "webpack.config.ts" ]; then
  BUILD_SYSTEM="webpack"
elif [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
  BUILD_SYSTEM="vite"
fi

# 3. Detect benchmark scripts
BENCHMARK="none"
if [ -f "package.json" ] && grep -q '"bench' package.json; then
  BENCHMARK="npm"
elif ls bench* benchmark* 2>/dev/null | head -1; then
  BENCHMARK="script"
elif [ -f "Cargo.toml" ] && grep -q '\[bench\]' Cargo.toml; then
  BENCHMARK="cargo"
elif ls *_bench_test.go 2>/dev/null | head -1; then
  BENCHMARK="go"
fi

# 4. Detect API server
API_SERVER="none"
if grep -r "app.listen\|createServer\|express()\|fastify()\|Hono()" --include="*.ts" --include="*.js" -l 2>/dev/null | head -1; then
  API_SERVER="node"
elif grep -r "Flask\|FastAPI\|Django\|uvicorn" --include="*.py" -l 2>/dev/null | head -1; then
  API_SERVER="python"
elif grep -r "gin.Default\|http.ListenAndServe\|fiber.New\|echo.New" --include="*.go" -l 2>/dev/null | head -1; then
  API_SERVER="go"
elif grep -r "Rails.application\|Sinatra" --include="*.rb" -l 2>/dev/null | head -1; then
  API_SERVER="ruby"
fi

# 5. Detect coverage configuration
COVERAGE="none"
if [ -f ".nycrc" ] || [ -f ".nycrc.json" ] || [ -f ".c8rc.json" ] || grep -q "coverage" package.json 2>/dev/null; then
  COVERAGE="nyc_or_c8"
elif [ -f ".coveragerc" ] || [ -f "setup.cfg" ] && grep -q "coverage" setup.cfg 2>/dev/null; then
  COVERAGE="pytest-cov"
fi

# 6. Detect Docker / containerized services
DOCKER="none"
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] || [ -f "compose.yml" ]; then
  DOCKER="compose"
elif [ -f "Dockerfile" ]; then
  DOCKER="dockerfile"
fi

# 7. Detect database (for query optimization)
DATABASE="none"
if grep -r "prisma\|typeorm\|sequelize\|knex\|drizzle" --include="*.ts" --include="*.js" -l 2>/dev/null | head -1; then
  DATABASE="node-orm"
elif grep -r "sqlalchemy\|django.db\|peewee\|tortoise" --include="*.py" -l 2>/dev/null | head -1; then
  DATABASE="python-orm"
fi
```

### Present Detected Metrics

After scanning, present findings to the user with auto-suggested verify commands:

```
┌─────────────────────────────────────────────────────────────────────┐
│  DETECTED METRICS                                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [1] Test Suite Speed        (jest detected, 142 test files)        │
│      Verify: /usr/bin/time -p npm test 2>&1 | grep real | awk      │
│              '{print $2}'                                           │
│      Current estimate: ~45s                                         │
│                                                                     │
│  [2] Test Coverage           (.c8rc.json found)                     │
│      Verify: npm run test:coverage 2>&1 | grep 'All files' |       │
│              awk '{print $NF}' | tr -d '%'                          │
│      Current: 67.3%                                                 │
│                                                                     │
│  [3] Bundle Size             (vite build detected, dist/ exists)    │
│      Verify: npm run build 2>/dev/null && find dist -name '*.js'   │
│              -exec du -cb {} + | tail -1 | cut -f1                  │
│      Current: 2,415,623 bytes (2.30MB)                              │
│                                                                     │
│  [4] API Response Time       (express server in src/server.ts)      │
│      Verify: curl -s -o /dev/null -w '%{time_total}\n'             │
│              http://localhost:3000/api/health | awk '{print $1*1000}'│
│      (requires server running)                                      │
│                                                                     │
│  [5] Benchmark               (npm run bench detected)               │
│      Verify: npm run bench -- --json | jq '.results[0].mean'       │
│                                                                     │
│  Which metric to optimize? (or describe your own goal)              │
└─────────────────────────────────────────────────────────────────────┘
```

**If the user picks a detected metric**, auto-populate the entire optimization config (goal, metric, verify command, baseline) and proceed directly to baseline measurement. Zero friction.

**If the user describes a custom goal**, use the detected infrastructure context to suggest the best verify command, then confirm.

---

## Phase 1: Setup (Run Once)

Before the loop starts, establish the optimization target.

If `/godmode:setup` has not been run, collect these interactively (pre-populated from auto-detection when possible):

```
OPTIMIZATION CONFIG:
Goal: <what are we optimizing? e.g., "reduce API response time">
Metric: <measurable quantity, e.g., "p95 response time in ms">
Baseline: <current value, measured not estimated>
Target: <desired value, e.g., "< 200ms">
Verify command: <exact command that outputs the metric>
Guard rails:
  - Tests must pass: <test command>
  - Lint must pass: <lint command>
  - No regressions: <other commands>
Max iterations: <default 25>
Scope: <files/directories in scope for modifications>
Optimization domain: <auto-detected or user-specified — see Playbooks section>
```

**Critical: The verify command must be MECHANICAL.** It must:
- Run without human intervention
- Produce a parseable numeric result
- Be deterministic (same code = same result, within tolerance)
- Complete in under 60 seconds

Example verify commands:
```bash
# Response time
curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/health

# Bundle size
du -b dist/bundle.js | cut -f1

# Test execution time
/usr/bin/time -f '%e' npm test 2>&1 | tail -1

# Memory usage
node --max-old-space-size=512 -e "require('./dist'); console.log(process.memoryUsage().heapUsed)"

# Custom benchmark
npm run benchmark -- --json | jq '.results[0].mean'

# Test count
npm test -- --json 2>/dev/null | jq '.numPassedTests'

# Coverage percentage
npm run test:coverage 2>&1 | grep 'All files' | awk '{print $NF}' | tr -d '%'

# Docker image size
docker image inspect myapp:latest --format='{{.Size}}'

# Startup time
/usr/bin/time -p node dist/index.js --exit-after-init 2>&1 | grep real | awk '{print $2}'
```

---

## Phase 2: Measure Baseline

Run the verify command and record the baseline:

```bash
# Run verify command 3 times, take median for stability
RESULT_1=$(verify_command)
RESULT_2=$(verify_command)
RESULT_3=$(verify_command)
BASELINE=median($RESULT_1, $RESULT_2, $RESULT_3)
```

```
BASELINE MEASUREMENT:
Metric: p95 response time
Value: 847ms
Target: < 200ms
Gap: 647ms (76% improvement needed)
```

Commit: `"optimize: baseline — <metric> = <value>"`

---

## Phase 3: Analyze and Select Playbook

Based on the optimization domain (auto-detected or user-specified), load the appropriate hypothesis playbook. This provides a prioritized list of approaches so we don't waste iterations on low-probability changes.

### Optimization Playbooks by Domain

#### API Speed Playbook
Priority-ordered hypotheses for reducing API/endpoint response time:

```
PRIORITY  HYPOTHESIS                         TYPICAL IMPACT   CHECK METHOD
───────────────────────────────────────────────────────────────────────────────
P0        N+1 queries (eager load missing)   30-80% faster    Search for loops containing DB calls;
                                                              check ORM includes/preloads
P0        Missing database indexes           20-70% faster    EXPLAIN ANALYZE on slow queries;
                                                              check WHERE/JOIN columns for indexes
P1        No query result caching            20-60% faster    Check for repeated identical queries;
                                                              look for Redis/memcached usage
P1        No connection pooling              15-40% faster    Check DB connection config;
                                                              look for pool size settings
P1        Synchronous blocking operations    20-50% faster    Search for sync I/O, await-in-loop,
                                                              blocking file reads in request path
P2        No HTTP compression (gzip/brotli)  10-30% smaller   Check response headers;
                                                              look for compression middleware
P2        No pagination on list endpoints    10-90% faster    Check if queries have LIMIT;
                                                              look for unbounded SELECT *
P2        Heavy serialization overhead       10-30% faster    Check JSON serialization;
                                                              look for toJSON() overhead
P3        No HTTP/2 or keep-alive            5-15% faster     Check server config
P3        Redundant middleware               5-20% faster     Profile middleware stack;
                                                              check if auth/logging runs unnecessarily
P3        No request batching/DataLoader     15-40% faster    Check for GraphQL resolvers
                                                              hitting DB individually
P4        Suboptimal algorithm complexity    Variable         Profile hot paths for O(n^2) or worse
P4        Excessive logging in hot path      5-15% faster     Check for console.log/logger in
                                                              request handlers
```

#### Bundle Size Playbook
Priority-ordered hypotheses for reducing frontend bundle size:

```
PRIORITY  HYPOTHESIS                         TYPICAL IMPACT   CHECK METHOD
───────────────────────────────────────────────────────────────────────────────
P0        No tree shaking / dead code        10-40% smaller   Check webpack/vite sideEffects config;
                                                              analyze bundle for unused exports
P0        No code splitting                  20-60% smaller   Check for dynamic import();
          (single monolithic bundle)                          look for route-based splitting
P0        Huge dependency (moment, lodash)   10-30% smaller   npm ls --all | sort by size;
                                                              check for lighter alternatives
P1        No lazy loading of routes          15-40% smaller   Check if all routes imported statically
P1        Unoptimized images in bundle       10-50% smaller   Check for inlined images;
                                                              look for SVG/PNG in JS bundles
P1        Duplicate dependencies             5-20% smaller    npm dedupe; check bundle analysis
                                                              for same lib at multiple versions
P2        No minification or weak minifier   5-15% smaller    Check build config for terser/esbuild
P2        Source maps included in bundle     10-30% smaller   Check if .map files in dist;
                                                              verify devtool config
P2        Unused CSS                         5-20% smaller    Check for PurgeCSS/unused styles
P3        No compression (gzip/brotli)       60-80% smaller   Check if server serves compressed;
          in served assets                   (transfer size)  check for precompression in build
P3        Polyfills for modern browsers      5-15% smaller    Check browserslist;
                                                              remove IE11 polyfills if unneeded
P4        Inlined large data blobs           Variable         Search for base64 or large string
                                                              literals in source
```

#### Memory Playbook
Priority-ordered hypotheses for reducing memory usage:

```
PRIORITY  HYPOTHESIS                         TYPICAL IMPACT   CHECK METHOD
───────────────────────────────────────────────────────────────────────────────
P0        Memory leaks (growing over time)   Critical         Take heap snapshots at intervals;
                                                              check for monotonic growth
P0        Unbounded caches / maps            20-80% less      Search for Map/Set/object that only
                                                              grows; look for missing eviction
P0        Event listener leaks               10-50% less      Search for addEventListener without
                                                              removeEventListener; check .on() calls
P1        Large object retention             10-40% less      Check for closures capturing large
                                                              scope; look for global state
P1        Buffer/stream not cleaned up       10-30% less      Check for unclosed streams,
                                                              unreleased buffers
P2        Inefficient data structures        10-30% less      Check for arrays where Sets are better;
                                                              look for object overhead
P2        Excessive cloning / copying        10-20% less      Search for JSON.parse(JSON.stringify),
                                                              spread operator on large objects
P3        No worker thread offloading        Variable         Check if heavy computation runs
                                                              on main thread
P3        Large dependency footprint          5-15% less      Check node_modules size;
                                                              look for lighter alternatives
```

#### Test Speed Playbook
Priority-ordered hypotheses for reducing test suite execution time:

```
PRIORITY  HYPOTHESIS                         TYPICAL IMPACT   CHECK METHOD
───────────────────────────────────────────────────────────────────────────────
P0        Tests running sequentially         40-80% faster    Check for --parallel/--concurrent flag;
                                                              look at test runner config
P0        Real DB/network in tests           30-70% faster    Search for actual HTTP calls,
                                                              real DB connections in test files
P1        No mocking of expensive ops        20-50% faster    Check for unmocked file I/O,
                                                              crypto, network calls in tests
P1        Heavy global setup/teardown        10-40% faster    Check beforeAll/beforeEach for
                                                              expensive initialization
P1        In-memory DB not used              20-50% faster    Check if tests use SQLite in-memory
                                                              or similar
P2        Running all tests always           20-60% faster    Check for --changedSince, affected
                                                              test detection
P2        Unnecessary test isolation          10-30% faster   Check for per-test DB resets
          (full reset between each test)                      vs transaction rollback
P3        Large test fixtures                 5-20% faster    Check fixture sizes;
                                                              use factory pattern instead
P3        Snapshot tests with large output    5-15% faster    Check .snap file sizes;
                                                              reduce snapshot scope
P4        No test sharding across workers    10-30% faster    Check for --shard flag support
```

**Using the playbook:** Start at P0 and work down. Skip hypotheses that don't apply to the project. Within a priority level, choose the hypothesis with the easiest verification first.

---

## Phase 4: Multi-Agent Parallel Optimization

**This is the key accelerator.** Instead of testing one hypothesis at a time, dispatch 3 agents in parallel, each exploring a DIFFERENT approach. This makes the loop 3x faster.

### How Multi-Agent Rounds Work

```
┌─────────────────────────────────────────────────────────────────────┐
│  ROUND <N> — PARALLEL DISPATCH                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Agent 1 (Worktree A)          Agent 2 (Worktree B)               │
│  Hypothesis: Add DB index      Hypothesis: Add caching layer       │
│  File: schema.prisma           File: src/services/cache.ts         │
│  ┌─ modify ─┐                  ┌─ modify ─┐                       │
│  │ commit   │                  │ commit   │                        │
│  │ verify   │                  │ verify   │                        │
│  │ measure  │                  │ measure  │                        │
│  └──────────┘                  └──────────┘                        │
│  Result: 612ms (-27.7%)        Result: 534ms (-36.9%)              │
│                                                                     │
│  Agent 3 (Worktree C)                                              │
│  Hypothesis: Restructure query with subselect                      │
│  File: src/queries/products.ts                                     │
│  ┌─ modify ─┐                                                      │
│  │ commit   │                                                      │
│  │ verify   │                                                      │
│  │ measure  │                                                      │
│  └──────────┘                                                      │
│  Result: 703ms (-17.0%)                                            │
│                                                                     │
│  WINNER: Agent 2 — caching layer (-36.9%)                          │
│  ACTION: Cherry-pick Agent 2's commit into main worktree.          │
│          Discard Agent 1 and Agent 3 worktrees.                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Implementation Protocol

For each round of parallel optimization:

**Step 1: Select 3 hypotheses** from the playbook (or generate from code analysis). They MUST be:
- **Independent**: Changes to different files/systems so they don't conflict
- **Diverse**: Different approaches to the same problem (don't try 3 variations of the same idea)
- **Ordered by expected impact**: So if we can only run 2, we skip the weakest

**Step 2: Create isolated worktrees** for each agent:
```bash
# Create worktrees branching from current optimize branch
git worktree add /tmp/godmode-agent-1 -b optimize/round-<N>-agent-1
git worktree add /tmp/godmode-agent-2 -b optimize/round-<N>-agent-2
git worktree add /tmp/godmode-agent-3 -b optimize/round-<N>-agent-3
```

**Step 3: Dispatch agents in parallel.** Each agent independently:
1. Makes its one change in its worktree
2. Commits: `"optimize: round <N> agent <M> — <description>"`
3. Runs guard rails (tests, lint)
4. Runs verify command 3 times, records median

**Step 4: Compare results and pick winner:**
```
ROUND <N> RESULTS:
Agent 1: 612ms (-27.7%) — guard rails: PASS
Agent 2: 534ms (-36.9%) — guard rails: PASS
Agent 3: 703ms (-17.0%) — guard rails: FAIL (2 tests broke)

Winner: Agent 2 (best improvement + guards pass)
```

**Step 5: Apply winner to main branch:**
```bash
# Cherry-pick the winning commit
git cherry-pick <agent-2-commit-sha>

# Clean up worktrees
git worktree remove /tmp/godmode-agent-1 --force
git worktree remove /tmp/godmode-agent-2 --force
git worktree remove /tmp/godmode-agent-3 --force
git branch -D optimize/round-<N>-agent-1
git branch -D optimize/round-<N>-agent-2
git branch -D optimize/round-<N>-agent-3
```

**Step 6: Update the new baseline** to the winner's measurement and log ALL 3 agents' results in the TSV.

### When to Use Multi-Agent vs Single-Agent

| Condition | Mode |
|-----------|------|
| 3+ independent hypotheses available | Multi-agent (3 parallel) |
| 2 independent hypotheses available | Multi-agent (2 parallel) |
| Hypotheses modify overlapping files | Single-agent (sequential) |
| Near the target (< 10% gap remaining) | Single-agent (precision) |
| Diminishing returns mode activated | Multi-agent with RADICAL hypotheses |

### Fallback

If worktrees are unavailable (e.g., shallow clone, unsupported filesystem), fall back to sequential single-agent mode using git branches:
```bash
# Fallback: branch-based isolation
git checkout -b optimize/round-<N>-agent-<M>
# ... make change, measure ...
git checkout optimize/main-branch
git merge optimize/round-<N>-agent-<M>  # if winner
git branch -D optimize/round-<N>-agent-<M>
```

---

## Phase 5: The Iteration Round (Measure, Modify, Verify, Keep/Revert)

Whether running in multi-agent or single-agent mode, each individual agent follows this same inner loop.

### Step 5a: Hypothesize

```
HYPOTHESIS FOR ROUND <N>, AGENT <M>:
Observation: <what I see in the code that could be improved>
Theory: <why this change should improve the metric>
Proposed change: <specific modification>
Expected impact: <estimated improvement>
Risk: <what could go wrong>
Files to modify: <exact file paths>
Playbook reference: <domain>/<priority>/<hypothesis name>
```

Rules for hypotheses:
- **One change per agent per round.** Never modify multiple things at once.
- **Highest impact first.** Attack the biggest bottleneck first. Use the playbook priority order.
- **Evidence-based.** The hypothesis must be based on code analysis, not guessing.
- **Reversible.** The change must be committable and revertable.

### Step 5b: Modify

Make the change. Follow these rules:

1. **One logical change only.** If you're tempted to fix "one more thing," resist. That's the next round.
2. **Modify, don't rewrite.** Targeted changes are safer than rewrites.
3. **Stay in scope.** Only modify files within the defined scope.
4. **Don't break the interface.** Internal changes only. Public APIs stay stable.

Commit: `"optimize: round <N> agent <M> — <brief description of change>"`

### Step 5c: Verify Mechanically

Run ALL verification checks in order:

```
VERIFICATION — Round <N>, Agent <M>:
1. Guard rails:
   [ ] Tests pass: <result>
   [ ] Lint clean: <result>
   [ ] No regressions: <result>

2. Metric measurement (3 runs, median):
   Run 1: <value>
   Run 2: <value>
   Run 3: <value>
   Median: <value>

3. Comparison:
   Baseline: <baseline value>
   Current:  <current value>
   Delta:    <change> (<percentage>)
   Verdict:  IMPROVED / NO CHANGE / REGRESSED
```

**CRITICAL RULES FOR VERIFICATION:**
- **NEVER claim improvement without running the verify command.** No "this should be faster." Run it. Measure it. Prove it.
- **NEVER skip the guard rails.** An optimization that breaks tests is not an optimization.
- **Run 3 times minimum.** Single measurements are unreliable. Use the median.
- **Evidence before claims.** The log entry is written AFTER measurement, not before.

### Step 5d: Keep or Revert

**If IMPROVED and guard rails pass:**
```
KEEP — Round <N>, Agent <M>
Change: <description>
Metric: <baseline> -> <new value> (<improvement>)
Cumulative: <original baseline> -> <new value> (<total improvement>)
```

**If NO CHANGE or REGRESSED or guard rails fail:**
```bash
git revert HEAD --no-edit
```
```
REVERT — Round <N>, Agent <M>
Change: <description>
Reason: <REGRESSED by X% | NO MEASURABLE CHANGE | TESTS FAILED | LINT FAILED>
Learning: <what this tells us about the problem>
```

The revert is NOT a failure. It's valuable information. We now know this approach doesn't work.

---

## Phase 6: Diminishing Returns Detection

Track the delta percentage of every KEPT change. When the improvement rate drops, automatically shift strategy.

### Detection Algorithm

```
DIMINISHING RETURNS TRACKER:
Keep history (most recent first):
  Round 6: +0.8% (keep)
  Round 5: +0.5% (keep)
  Round 4: +0.9% (keep)
  Round 3: +12.3% (keep)  <-- last big win

Rule: If the last 3 KEEPs each improved < 1%, trigger diminishing returns mode.
      If the last 5 rounds (kept or reverted) show <2% cumulative improvement,
      also trigger.
```

### What Happens When Diminishing Returns Triggers

Print this alert:

```
┌─────────────────────────────────────────────────────────────────────┐
│  DIMINISHING RETURNS DETECTED                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Last 3 kept improvements: +0.9%, +0.5%, +0.8%                     │
│  Incremental gains are shrinking. The low-hanging fruit is gone.   │
│                                                                     │
│  Switching strategy. Options:                                       │
│                                                                     │
│  [AUTO] 1. RADICAL MODE — Try architectural changes:               │
│            - Introduce caching layer (Redis/in-memory)              │
│            - Switch to streaming/chunked responses                  │
│            - Parallelize independent operations                     │
│            - Replace algorithm entirely (e.g., O(n^2) -> O(n))     │
│                                                                     │
│  [AUTO] 2. VECTOR SWITCH — Optimize a different dimension:         │
│            - If optimizing latency, try reducing memory instead     │
│            - If optimizing size, try optimizing load time instead   │
│            - Find a NEW bottleneck via profiling                    │
│                                                                     │
│  [AUTO] 3. COMPOUND MODE — Combine top improvements (see below)    │
│                                                                     │
│  [USER] 4. ACCEPT RESULTS — Current metric is good enough.         │
│            Print summary and exit.                                  │
│                                                                     │
│  Proceeding with option 1 (RADICAL MODE) unless user intervenes.   │
└─────────────────────────────────────────────────────────────────────┘
```

**Radical Mode Changes:**
- Hypotheses shift from incremental tweaks to architectural changes
- Allowed to modify more files per iteration (still ONE logical change, but a bigger one)
- Reuse insights from the results log to guide radical bets
- Use multi-agent dispatch to try 3 completely different radical approaches at once

**Vector Switch Changes:**
- Re-run auto-metric detection to find a secondary metric
- If current metric is within 10% of target, ask user to confirm switching
- Log the vector switch in the results TSV

If radical mode also hits diminishing returns (last 3 radical KEEPs each < 1%), THEN present the user with results and suggest accepting current performance.

---

## Phase 7: Compound Optimization

After individual iterations plateau (either naturally or via diminishing returns), try combining the top performing changes that were individually measured. Sometimes optimizations interact positively (superlinear improvement) or negatively (interference).

### When to Trigger

- After diminishing returns is detected
- After all playbook hypotheses for a priority level are exhausted
- When the user requests `/godmode:optimize --compound`
- After reaching 70% of target improvement

### Protocol

```
COMPOUND OPTIMIZATION:
Step 1: Identify the top 3 individually-kept changes from the results log.
Step 2: Test all pairwise combinations and the triple combination.
Step 3: Measure each combination against current baseline.

Combination matrix:
  A alone:     already measured (Round 2, -34.5%)
  B alone:     already measured (Round 4, -18.2%)
  C alone:     already measured (Round 7, -12.1%)
  A + B:       create worktree, apply both, measure
  A + C:       create worktree, apply both, measure
  B + C:       create worktree, apply both, measure
  A + B + C:   create worktree, apply all three, measure

Report:
┌─────────────────────────────────────────────────────────────────────┐
│  COMPOUND OPTIMIZATION RESULTS                                      │
├─────────────────────────────────────────────────────────────────────┤
│  Individual baselines (already applied and kept):                   │
│    A (index):     847 -> 555  (-34.5%)                              │
│    B (pooling):   555 -> 454  (-18.2%)                              │
│    C (cache):     454 -> 399  (-12.1%)                              │
│                                                                     │
│  Current (A+B+C sequential): 399ms                                  │
│                                                                     │
│  Re-measured compounds from original 847ms baseline:                │
│    A + B together:     398ms  (-53.0%) -- expected: -46.4%          │
│    A + C together:     412ms  (-51.4%) -- expected: -42.4%          │
│    B + C together:     489ms  (-42.3%) -- expected: -28.1%          │
│    A + B + C together: 371ms  (-56.2%) -- expected: -53.6%  <<<    │
│                                                                     │
│  SYNERGY DETECTED: A+B+C together yields -56.2%,                   │
│  which is BETTER than sequential application (-52.9%).              │
│  The compound gains 28ms beyond sequential.                         │
│                                                                     │
│  Action: Rebase to apply A+B+C as a single atomic commit           │
│  for maximum benefit.                                               │
└─────────────────────────────────────────────────────────────────────┘
```

### Important Constraints
- Compound optimization requires that the individual changes are compatible (no file conflicts).
- If a compound combination fails guard rails, drop it and try the next combination.
- Only compound changes that have already been individually verified as KEEP.
- Log compound results as separate rows in the TSV with `verdict=compound-keep` or `compound-discard`.

---

## Phase 8: Progress Visualization

After every round (and at any status checkpoint), print an ASCII progress chart showing the metric trajectory over time.

### Chart Format

For metrics where LOWER is better (response time, bundle size, memory):

```
Metric: Response Time (ms)
847 |============================================
612 |==============================
401 |====================
384 |===================
226 |===========
198 |==========
    +----+----+----+----+----+----+
     #0   #1   #2   #3   #4   #5
       baseline ........... current

Target: 200ms  [============================|=>  ] 96.5% there
Baseline: 847ms -> Current: 198ms (-76.6%)
```

For metrics where HIGHER is better (coverage %, test count, throughput):

```
Metric: Test Coverage (%)
67.3 |==========================
72.1 |=============================
78.4 |================================
81.7 |=================================
85.2 |==================================
88.9 |====================================
     +----+----+----+----+----+----+
      #0   #1   #2   #3   #4   #5
        baseline ........... current

Target: 90%  [==================================|=> ] 95.2% there
Baseline: 67.3% -> Current: 88.9% (+21.6pp)
```

### Progress Bar

Always include a target progress bar:

```
Target progress: [=========================>-----] 83.2%
                  start                     now   target
```

### Implementing the Visualization

Generate the chart by:
1. Reading all KEEP entries from `.godmode/optimize-results.tsv`
2. Scaling the bar widths proportionally (longest bar = 44 chars)
3. Labeling each bar with its round number
4. Showing the target line and percentage progress

Print this chart:
- After every round in multi-agent mode
- Every 5 iterations in single-agent mode
- On every status checkpoint (Rule 7)
- In the final summary report
- When `--report` flag is used

### Sparkline for Compact Status

For the every-5-iterations status print, also include a sparkline:

```
Round 15: 312ms (from 847ms, -63.2%), 9 keeps / 6 discards
Trend: 847 612 401 384 367 345 334 321 312 [=========\___---]
```

---

## Phase 9: Regression Prevention

After optimization completes (target reached or user accepts results), automatically generate a performance benchmark test that encodes the achieved metric as a test assertion. This prevents future changes from regressing the optimization gains.

### Protocol

**Step 1: Generate benchmark test file**

Detect the test framework and generate an appropriate test:

For Node.js / Jest / Vitest:
```javascript
// __tests__/performance/api-response-time.perf.test.ts
// Auto-generated by godmode:optimize on <date>
// Baseline: 847ms -> Optimized: 198ms
// DO NOT weaken these thresholds without team discussion.

import { describe, it, expect } from 'vitest'; // or jest

const PERF_THRESHOLD_MS = 300; // 50% buffer above achieved 198ms
const PERF_RUNS = 5;
const PERF_TIMEOUT = 30_000;

describe('Performance regression guard: API response time', () => {
  it(
    `GET /api/products responds under ${PERF_THRESHOLD_MS}ms (median of ${PERF_RUNS} runs)`,
    async () => {
      const times: number[] = [];
      for (let i = 0; i < PERF_RUNS; i++) {
        const start = performance.now();
        const res = await fetch('http://localhost:3000/api/products');
        const elapsed = performance.now() - start;
        expect(res.status).toBe(200);
        times.push(elapsed);
      }
      times.sort((a, b) => a - b);
      const median = times[Math.floor(times.length / 2)];

      console.log(`Performance: median=${median.toFixed(1)}ms, all=[${times.map(t => t.toFixed(1)).join(', ')}]`);
      expect(median).toBeLessThan(PERF_THRESHOLD_MS);
    },
    PERF_TIMEOUT,
  );
});
```

For Python / pytest:
```python
# tests/performance/test_api_response_time.py
# Auto-generated by godmode:optimize on <date>
# Baseline: 847ms -> Optimized: 198ms

import time
import statistics
import requests
import pytest

PERF_THRESHOLD_MS = 300  # 50% buffer above achieved 198ms
PERF_RUNS = 5

@pytest.mark.performance
def test_api_response_time_regression():
    """GET /api/products should respond under {PERF_THRESHOLD_MS}ms (median of {PERF_RUNS} runs)."""
    times = []
    for _ in range(PERF_RUNS):
        start = time.perf_counter()
        resp = requests.get("http://localhost:3000/api/products")
        elapsed_ms = (time.perf_counter() - start) * 1000
        assert resp.status_code == 200
        times.append(elapsed_ms)

    median = statistics.median(times)
    print(f"Performance: median={median:.1f}ms, all={[f'{t:.1f}' for t in times]}")
    assert median < PERF_THRESHOLD_MS, (
        f"Performance regression! Median {median:.1f}ms exceeds threshold {PERF_THRESHOLD_MS}ms. "
        f"Optimized value was 198ms. Run /godmode:optimize to investigate."
    )
```

For Go:
```go
// performance_test.go
// Auto-generated by godmode:optimize on <date>

func BenchmarkAPIResponseTime(b *testing.B) {
    threshold := 300 * time.Millisecond
    // ... similar pattern
}
```

**Step 2: Set the threshold with buffer**

The threshold is NOT the achieved value. It includes a safety buffer:
- **50% buffer** above achieved value (for timing-sensitive metrics)
- **10% buffer** for deterministic metrics (bundle size, test count)
- **5 percentage points buffer** for percentage metrics (coverage)

This prevents flaky failures from normal variance while still catching real regressions.

**Step 3: Add to test suite**

```bash
# Commit the regression test
git add <test-file>
git commit -m "optimize: add performance regression test — <metric> must stay under <threshold>"
```

**Step 4: Verify the regression test passes**

```bash
# Run only the new test to confirm it passes against optimized code
<test-runner> <test-file>
```

**Step 5: Document in results log**

Add a final row to the TSV:
```
regression-guard	<time>	"Performance test"	"Add <metric> regression test at <threshold>"	<final>	<final>	0.0	guard	<sha>
```

### What the Regression Test Catches

When a future change causes performance to degrade beyond the threshold:
```
FAIL tests/performance/test_api_response_time.py
  Performance regression! Median 423.1ms exceeds threshold 300ms.
  Optimized value was 198ms. Run /godmode:optimize to investigate.
```

This gives the developer immediate signal that their change hurt performance, with a pointer to re-run optimization.

---

## Phase 10: Log Results

Append to the results log (TSV format) after EVERY agent in EVERY round:

```
# File: .godmode/optimize-results.tsv
iteration	round	agent	timestamp	hypothesis	change_description	baseline	measured	delta_pct	verdict	commit_sha
0	0	-	2024-01-15T10:20:00Z	baseline	-	847	847	0.0	baseline	abc1234
1	1	1	2024-01-15T10:23:00Z	"N+1 query in getUserPosts"	"Add eager loading for posts relation"	847	612	-27.7	keep	def5678
2	1	2	2024-01-15T10:23:00Z	"Unindexed WHERE clause"	"Add index on posts.user_id"	847	588	-30.6	discard	-
3	1	3	2024-01-15T10:23:00Z	"JSON serialization overhead"	"Switch to streaming JSON"	847	715	-15.6	discard	-
4	2	1	2024-01-15T10:31:00Z	"No connection pooling"	"Add pg pool with size 20"	612	401	-34.5	keep	ghi9012
5	2	2	2024-01-15T10:31:00Z	"Redundant middleware"	"Remove unused auth on public routes"	612	580	-5.2	discard	-
6	2	3	2024-01-15T10:31:00Z	"No HTTP caching headers"	"Add Cache-Control for static data"	612	598	-2.3	discard	-
7	3	compound	2024-01-15T10:38:00Z	"Compound: eager+pool"	"Combined eager loading + pooling"	847	371	-56.2	compound-keep	jkl3456
```

---

## Phase 11: Decide — Continue or Stop

**Continue if:**
- Target not yet reached
- Iterations/rounds remaining (under max)
- Still have untested hypotheses in the playbook
- Last 3 rounds weren't all REVERT across all agents (total failure signal)
- Diminishing returns not yet exhausted (radical mode not yet tried, compound not yet tried)

**Stop if:**
- Target reached
- Max iterations reached
- Diminishing returns exhausted (radical + compound both tried and plateaued)
- Guard rails can't be maintained
- User manually intervenes (Ctrl+C)

---

## Phase 12: Summary Report

When the loop ends, print the complete summary with visualization:

```
┌─────────────────────────────────────────────────────────────────────┐
│  OPTIMIZATION COMPLETE                                              │
├─────────────────────────────────────────────────────────────────────┤
│  Goal: Reduce API response time                                     │
│  Metric: p95 response time (ms)                                     │
│                                                                     │
│  Baseline:     847ms                                                │
│  Final:        198ms                                                │
│  Target:       200ms   ACHIEVED                                     │
│  Improvement:  76.6%                                                │
│                                                                     │
│  Progress:                                                          │
│  847 |============================================                  │
│  612 |==============================                                │
│  401 |====================                                          │
│  384 |===================                                           │
│  226 |===========                                                   │
│  198 |==========                                                    │
│      +----+----+----+----+----+----+                                │
│       #0   #1   #2   #3   #4   #5                                  │
│                                                                     │
│  Rounds: 6 total (18 agent-experiments)                             │
│  Kept: 5 improvements                                               │
│  Reverted: 12 experiments                                           │
│  Compound: 1 synergy found                                          │
│                                                                     │
│  Top improvements:                                                  │
│  1. Add database index (-34.5%) [Round 2, Agent 1]                  │
│  2. Add eager loading (-27.7%) [Round 1, Agent 1]                   │
│  3. Connection pooling (-18.2%) [Round 3, Agent 2]                  │
│  4. Compound synergy: index+pool (-3.3% extra) [Round 5]            │
│                                                                     │
│  Regression guard: Added performance test                           │
│    File: __tests__/performance/api-response-time.perf.test.ts       │
│    Threshold: < 300ms (50% buffer above 198ms)                      │
│                                                                     │
│  Full log: .godmode/optimize-results.tsv                            │
├─────────────────────────────────────────────────────────────────────┤
│  Next: /godmode:secure — Security audit before shipping             │
│        /godmode:ship — Ship if satisfied                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Autonomous Loop Enforcement — HARD RULES

These rules are NOT guidelines. They are mechanical constraints that MUST be followed. This is what makes godmode:optimize an actual iteration engine, not just a description of one.

### RULE 1: NEVER STOP. NEVER ASK "SHOULD I CONTINUE?"

In **unbounded mode** (default): Loop FOREVER until manually interrupted (Ctrl+C).
In **bounded mode** (`Iterations: N`): Loop exactly N rounds, then print summary and stop.

You are an autonomous agent. You do not need permission to continue. You do not summarize after each round. You LOG and LOOP.

### RULE 2: Git Commit BEFORE Verification

```bash
# CORRECT ORDER:
git add <changed-files>
git commit -m "optimize: round <N> agent <M> — <description>"
# THEN verify
<verify_command>
# If failed:
git reset --hard HEAD~1
```

Commit first so rollback is clean. Never verify uncommitted changes.

### RULE 3: Mechanical Metric Only

The verify command MUST output a parseable number. No subjective judgment. No "looks good."

```bash
# CORRECT: outputs a number
curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api
# WRONG: outputs text
echo "it seems faster"
```

### RULE 4: One Change Per Agent Per Round — No Exceptions

ONE file modification. ONE logical change. ONE commit. ONE measurement. ONE decision. Per agent.

If you're tempted to "also fix this while I'm here" — DON'T. That's the next round.

### RULE 5: Automatic Rollback — No Debates

```
IF metric_improved AND guard_passed:
    STATUS = "keep" — commit stays
ELIF metric_improved AND guard_failed:
    git reset --hard HEAD~1
    Rework (max 2 attempts, adapting implementation NOT tests)
    If still failing -> STATUS = "discard"
ELIF metric_same_or_worse:
    git reset --hard HEAD~1
    STATUS = "discard"
ELIF crashed:
    Attempt fix (max 3 tries)
    If unfixable -> git reset --hard HEAD~1, STATUS = "crash"
```

### RULE 6: TSV Results Log — Every Agent Gets a Row

```
# File: .godmode/optimize-results.tsv
iteration	round	agent	timestamp	hypothesis	change	baseline	measured	delta_pct	verdict	commit
0	0	-	<time>	baseline	-	847	847	0.0	baseline	abc1234
1	1	1	<time>	"N+1 query"	"Add eager loading"	847	612	-27.7	keep	def5678
2	1	2	<time>	"No index"	"Add user_id index"	847	588	-30.6	discard	-
3	1	3	<time>	"JSON overhead"	"Switch to streaming"	847	715	-15.6	discard	-
4	2	1	<time>	"No pooling"	"Add connection pool"	612	401	-34.5	keep	ghi9012
```

### RULE 7: Status Print and Visualization Every 5 Rounds

Do NOT summarize after every round. Do NOT ask for feedback. Just loop.

Every 5 rounds, print status with compact visualization:

```
Round 15: metric at 312ms (from 847ms, -63.2%), 9 keeps / 24 discards
Trend: 847 612 401 384 367 345 334 321 312
847 |============================================
612 |==============================
401 |====================
384 |===================
367 |==================
345 |=================
334 |=================
321 |================
312 |================
    +----+----+----+----+----+----+----+----+----
     #0   #1   #2   #3   #4   #5   #6   #7   #8
Target: [================================>------] 82.7%
```

### RULE 8: When Stuck (>5 Consecutive Discards Across ALL Agents)

1. Re-read ALL in-scope files from scratch
2. Re-read the original goal
3. Review entire results log for patterns
4. Advance to next priority level in the playbook
5. Try the OPPOSITE of what hasn't been working
6. Try a radical architectural change
7. Trigger compound optimization if not yet tried
8. If still stuck after 3 more rounds, trigger diminishing returns protocol

### RULE 9: Guard Commands Are Read-Only

NEVER modify test files, lint configs, or guard commands to make an optimization pass. Always adapt the implementation to pass the guard, not the other way around.

### RULE 10: Simplicity Override

- Metric barely improved (+<0.1%) but adds complexity -> DISCARD
- Metric unchanged but code is simpler -> KEEP
- Equal results + less code = always KEEP

### RULE 11: Multi-Agent Consistency

- All agents in a round start from the SAME baseline commit
- Agent results are compared against the SAME baseline measurement
- Only ONE agent's change is kept per round (the best performer)
- If two agents both improve but conflict, keep the one with larger delta

### RULE 12: Diminishing Returns Triggers Are Automatic

- Do NOT wait for user input to switch to radical mode
- Do NOT wait for user input to try compound optimization
- Only ask the user when ALL automatic strategies are exhausted

---

## Bounded Iterations

Add `Iterations: N` to your invocation to run exactly N rounds:

```
/godmode:optimize
Goal: Reduce API response time
Iterations: 20
```

After N rounds, print a final summary:
```
=== Godmode Optimize Complete (20/20 rounds, 60 agent-experiments) ===
Baseline: 847ms -> Final: 198ms (-76.6%)
Keeps: 8 | Discards: 48 | Crashes: 2 | Compounds: 2
Best round: #4 — Add database index (-34.5%)
Regression guard: __tests__/performance/api-response-time.perf.test.ts
```

---

## Example Usage

### Optimizing database query performance (multi-agent)
```
User: /godmode:optimize The /api/products endpoint is too slow

Optimize: Scanning project for available metrics...

DETECTED METRICS:
[1] API Response Time   (express server in src/server.ts, 12 routes)
    Verify: curl -s -o /dev/null -w '%{time_total}\n' http://localhost:3000/api/products | awk '{print $1*1000}'
[2] Test Suite Speed    (jest, 142 test files)
[3] Bundle Size         (vite build, dist/ = 1.8MB)

User selected: [1] API Response Time

Loading playbook: API Speed (13 hypotheses across P0-P4)

Measuring baseline (3 runs)...
Run 1: 1247ms | Run 2: 1189ms | Run 3: 1223ms
Baseline: 1223ms (median)
Target: < 300ms | Gap: 923ms

ROUND 1 — Dispatching 3 agents in parallel:
  Agent 1: [P0] N+1 query — Add eager loading for products.images, products.category
  Agent 2: [P0] Missing index — Add index on products.category_id (used in WHERE)
  Agent 3: [P1] No caching — Add Redis cache for product list (TTL 60s)

  Creating worktrees...
  Agents working in parallel...

  Results:
  Agent 1: 601ms (-50.9%)  guards: PASS
  Agent 2: 734ms (-40.0%)  guards: PASS
  Agent 3: 523ms (-57.2%)  guards: PASS

  Winner: Agent 3 — Redis caching (-57.2%)
  Cherry-picked. New baseline: 523ms.

ROUND 2 — Dispatching 3 agents:
  Agent 1: [P0] N+1 query (retry from R1) — eager loading
  Agent 2: [P0] Missing index (retry from R1) — category_id index
  Agent 3: [P1] No connection pooling — Add pgBouncer config

  Results:
  Agent 1: 312ms (-40.3%)  guards: PASS  <<< winner
  Agent 2: 445ms (-14.9%)  guards: PASS
  Agent 3: 487ms (-6.9%)   guards: PASS

  Winner: Agent 1 — Eager loading (-40.3%)
  New baseline: 312ms.

... (continues autonomously)

Round 4: metric at 198ms (from 1223ms, -83.8%), 5 keeps / 7 discards

Metric: Response Time (ms)
1223 |============================================
 523 |===================
 312 |===========
 284 |==========
 198 |=======
     +----+----+----+----+----+
      #0   #1   #2   #3   #4
Target: [====================================>--] 96.2%

TARGET ACHIEVED at Round 4! (198ms < 300ms target)

Generating regression test: __tests__/performance/api-products-response.perf.test.ts
Threshold: 450ms (50% buffer above 198ms + margin for CI variance)
Test passes: confirmed.

OPTIMIZATION COMPLETE
Baseline: 1223ms -> Final: 198ms (-83.8%)
Rounds: 4 (12 agent-experiments)
Kept: 5 | Discards: 7
```

### Optimizing bundle size
```
User: /godmode:optimize Our frontend bundle is too large (2.3MB)

Optimize: Scanning project...

DETECTED METRICS:
[1] Bundle Size         (vite build, dist/assets/index-*.js = 2,415,623 bytes)
[2] Test Suite Speed    (vitest, 89 test files)
[3] Test Coverage       (c8, current: 71.2%)

Auto-selected: [1] Bundle Size (matches user request)
Loading playbook: Bundle Size (12 hypotheses across P0-P4)

Baseline: 2,415,623 bytes (2.30MB)
Target: < 500,000 bytes (< 500KB)

ROUND 1 — 3 agents:
  Agent 1: [P0] No tree shaking — sideEffects: false missing in package.json
  Agent 2: [P0] No code splitting — All routes imported statically
  Agent 3: [P0] Huge dep: moment.js (320KB) — Replace with dayjs (2KB)

  Winner: Agent 2 — Code splitting (-41.2%)
  New baseline: 1,421,456 bytes

... (continues autonomously until target reached)
```

---

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Auto-detect metrics, interactive setup, then autonomous loop |
| `--goal "<goal>"` | Set optimization goal directly |
| `--metric "<metric>"` | Set metric name |
| `--verify "<cmd>"` | Set verify command |
| `--target <value>` | Set target value |
| `--max <N>` | Maximum rounds (default 25) |
| `--resume` | Resume a previously paused optimization |
| `--report` | Show results + visualization from the last optimization run |
| `--dry-run` | Show what would happen without making changes |
| `--single-agent` | Force sequential single-agent mode (no parallel dispatch) |
| `--compound` | Trigger compound optimization on existing kept changes |
| `--radical` | Start in radical mode (skip incremental) |
| `--playbook <domain>` | Force a specific playbook (api, bundle, memory, test-speed) |

---

## Anti-Patterns

- **Do NOT claim improvement without measurement.** This is the cardinal sin. "I refactored the code, it should be faster" is meaningless. Measure it.
- **Do NOT change multiple things per agent per round.** If you add an index AND refactor a query in one agent, you don't know which one helped.
- **Do NOT skip guard rails.** A 50% speedup that breaks 3 tests is a regression, not an optimization.
- **Do NOT optimize without a target.** "Make it faster" is not a target. "Reduce p95 to under 200ms" is a target.
- **Do NOT continue after diminishing returns + radical + compound all exhausted.** Accept results.
- **Do NOT rewrite instead of optimizing.** The loop makes targeted changes. If you need a rewrite, that's a new THINK->BUILD cycle.
- **Do NOT forget to log.** The results TSV is the permanent record. Every agent in every round gets a row.
- **Do NOT optimize prematurely.** If the code doesn't work yet, go back to `/godmode:build` or `/godmode:fix`.
- **Do NOT skip auto-detection.** Always scan the project first. The user shouldn't have to tell you what metrics exist.
- **Do NOT run agents on overlapping files.** Each agent in a parallel round must modify independent files.
- **Do NOT skip the regression test.** After optimization completes, always generate the performance guard test.
- **Do NOT ignore compound optimization.** Individual gains often compose nonlinearly. Always try combinations.
