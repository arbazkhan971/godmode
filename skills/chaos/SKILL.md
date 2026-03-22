---
name: chaos
description: |
  Chaos engineering skill. Activates when user needs to test system resilience through controlled failure injection, validate circuit breakers, plan game days, or verify disaster recovery procedures. Covers network failures, disk pressure, process crashes, dependency outages, and data corruption scenarios. Triggers on: /godmode:chaos, "chaos test", "resilience test", "failure injection", "game day", or when ship skill needs resilience validation.
---

# Chaos — Chaos Engineering

## When to Activate
- User invokes `/godmode:chaos`
- User says "chaos test", "resilience test", "failure injection", "break it on purpose"
- User asks "what happens when X fails?" or "is this resilient?"
- User wants to plan a game day or disaster recovery drill
- Ship skill needs resilience validation before production deployment
- After a production incident, to prevent recurrence

## Workflow

### Step 1: Define Steady State
Before injecting failures, establish what "healthy" looks like:

```
STEADY STATE DEFINITION:
System: <service name / system boundary>
Architecture: <monolith | microservices | serverless>

Health indicators (must all be true for "steady state"):
  - Response success rate: > <X>% (e.g., 99.9%)
  - Response time P95: < <X>ms (e.g., 500ms)
  - Error rate: < <X>% (e.g., 0.1%)
  - Queue depth: < <N> messages (e.g., 1000)
  - CPU usage: < <X>% (e.g., 80%)
  - Memory usage: < <X>% (e.g., 85%)
  - Active connections: < <N> (e.g., connection pool max)

Monitoring:
  Dashboard: <URL or tool — Grafana, Datadog, CloudWatch>
  Alerts: <PagerDuty, Opsgenie, Slack channel>
  Logs: <ELK, CloudWatch, Datadog Logs>

Verification command:
  <health check endpoint or monitoring query>
```

### Step 2: Identify Failure Domains
Map all the ways the system can fail:

```
FAILURE DOMAIN MAP:
┌──────────────────────────────────────────────────────────────┐
│  Category        │ Components              │ Impact if Failed │
├──────────────────────────────────────────────────────────────┤
│  Network         │ Load balancer           │ Total outage     │
│                  │ DNS resolution          │ Total outage     │
│                  │ Inter-service network   │ Partial outage   │
│                  │ External API access     │ Feature degraded │
├──────────────────────────────────────────────────────────────┤
│  Compute         │ Application process     │ Service restart  │
│                  │ Worker processes        │ Queue backlog    │
│                  │ Cron/scheduled jobs     │ Delayed tasks    │
│                  │ Container/VM host       │ Service relocation│
├──────────────────────────────────────────────────────────────┤
│  Storage         │ Primary database        │ Read/write loss  │
│                  │ Read replicas           │ Read degradation │
│                  │ Cache (Redis/Memcached) │ Performance drop │
│                  │ File storage (S3/GCS)   │ Upload/download  │
│                  │ Message queue           │ Async processing │
├──────────────────────────────────────────────────────────────┤
│  Dependencies    │ Auth provider (OAuth)   │ Login broken     │
│                  │ Payment gateway         │ Checkout broken  │
│                  │ Email/SMS service       │ Notifications    │
│                  │ CDN                     │ Static assets    │
│                  │ Search service          │ Search broken    │
├──────────────────────────────────────────────────────────────┤
│  Data            │ Data corruption         │ Incorrect results│
│                  │ Schema migration fail   │ Service crash    │
│                  │ Replication lag         │ Stale reads      │
│                  │ Full disk              │ Write failures   │
└──────────────────────────────────────────────────────────────┘
```

### Step 3: Design Chaos Experiments
Create specific, controlled experiments for each failure domain:

#### Experiment Template
```
CHAOS EXPERIMENT:
Name: <descriptive name>
Hypothesis: "When <failure condition>, the system will <expected behavior>"
Blast radius: <single request | single user | single service | entire system>
Duration: <how long to inject failure>
Rollback: <how to stop the experiment immediately>
Prerequisites:
  - [ ] Steady state verified
  - [ ] Monitoring dashboards open
  - [ ] Rollback procedure tested
  - [ ] Team notified (if production)
  - [ ] Incident response team on standby (if production)

Injection method: <tool or technique>
Success criteria: <what constitutes a "pass">
Failure criteria: <what triggers immediate rollback>
```

#### Network Failure Experiments

**Experiment N1: Dependency Timeout**
```
Hypothesis: "When the payment API responds slowly (5s+), the checkout
  service returns a user-friendly error within 3 seconds and does not
  block other requests."

Injection:
  # Using tc (traffic control) to add latency
  tc qdisc add dev eth0 root netem delay 5000ms

  # Or using toxiproxy
  toxiproxy-cli toxic add -n latency -t latency \
    -a latency=5000 payment-api

  # Or in application code (test mode)
  CHAOS_PAYMENT_LATENCY_MS=5000

Expected behavior:
  - Checkout returns "Payment processing delayed, please try again" within 3s
  - Circuit breaker opens after 5 consecutive timeouts
  - Other endpoints (product listing, search) unaffected
  - Queue message created for retry

Observe:
  - Response time of checkout endpoint
  - Circuit breaker state transitions
  - Error messages shown to users
  - Retry queue depth
```

**Experiment N2: DNS Failure**
```
Hypothesis: "When DNS resolution fails for external services, the
  system falls back to cached data or gracefully degrades."

Injection:
  # Block DNS for specific domains
  iptables -A OUTPUT -p udp --dport 53 -j DROP

  # Or modify /etc/hosts to return wrong IP
  echo "127.0.0.1 api.external-service.com" >> /etc/hosts

Expected behavior:
  - Cached responses served for previously-resolved hosts
  - Clear error logging with DNS failure details
  - No cascading failures to unrelated services
```

**Experiment N3: Packet Loss**
```
Hypothesis: "With 10% packet loss, the system maintains >95% success
  rate through retries and connection management."

Injection:
  # Add 10% packet loss
  tc qdisc add dev eth0 root netem loss 10%

Expected behavior:
  - Retry logic handles transient failures
  - Response time increases but stays under SLO
  - Error rate stays below threshold
  - No connection pool exhaustion
```

#### Process Failure Experiments

**Experiment P1: Process Crash**
```
Hypothesis: "When the application process crashes, it restarts within
  30 seconds and no requests are dropped (load balancer removes unhealthy
  instance)."

Injection:
  # Kill application process
  kill -9 $(pgrep -f "node server.js")

  # Or in Kubernetes
  kubectl delete pod <pod-name> --grace-period=0

Expected behavior:
  - Health check detects failure within 10 seconds
  - Load balancer removes instance from rotation
  - Process manager restarts the process
  - New instance passes health check within 30 seconds
  - Zero dropped requests (other instances handle traffic)
```

**Experiment P2: Memory Pressure**
```
Hypothesis: "Under memory pressure (90%+), the application gracefully
  sheds load rather than OOM-killing."

Injection:
  # Consume memory gradually
  stress-ng --vm 1 --vm-bytes 80% --timeout 300s

  # Or in application (test mode)
  CHAOS_MEMORY_LEAK_MB_PER_SEC=10

Expected behavior:
  - Application detects memory pressure
  - Non-critical caches are evicted
  - New requests are rejected with 503 (not crashed)
  - Alerts fire before OOM threshold
  - Process restarts cleanly if OOM occurs
```

**Experiment P3: CPU Saturation**
```
Hypothesis: "At 95% CPU utilization, the system prioritizes health checks
  and critical paths over background tasks."

Injection:
  # Saturate CPU
  stress-ng --cpu $(nproc) --timeout 300s

Expected behavior:
  - Health check endpoint still responds (< 1s)
  - Background jobs are deferred (not dropped)
  - Critical API endpoints degraded but functional
  - Autoscaling triggers (if configured)
```

#### Storage Failure Experiments

**Experiment S1: Database Failover**
```
Hypothesis: "When the primary database fails, the system fails over to
  the replica within 30 seconds with < 1 second of write unavailability."

Injection:
  # Stop primary database
  docker stop postgres-primary

  # Or in cloud — promote replica
  aws rds failover-db-cluster --db-cluster-identifier <cluster>

Expected behavior:
  - Read traffic continues on replica immediately
  - Write traffic queued or returns 503 for < 30s
  - Automatic failover promotes replica to primary
  - Application reconnects without restart
  - No data loss (RPO = 0 with synchronous replication)
```

**Experiment S2: Cache Failure (Cold Cache)**
```
Hypothesis: "When Redis is unavailable, the system falls back to direct
  database queries with acceptable performance degradation (P95 < 2s
  instead of < 200ms)."

Injection:
  # Flush all cached data
  redis-cli FLUSHALL

  # Or kill Redis entirely
  docker stop redis

Expected behavior:
  - Application detects cache unavailability
  - Requests hit database directly
  - Response time increases but stays functional
  - Cache reconnects automatically when available
  - No error responses to users (just slower)
```

**Experiment S3: Disk Full**
```
Hypothesis: "When disk reaches 95%, the system stops non-critical writes,
  alerts operators, and continues serving read traffic."

Injection:
  # Fill disk to 95%
  fallocate -l $(df --output=avail / | tail -1 | awk '{print int($1*0.90)}')k /tmp/fill-disk

Expected behavior:
  - Log rotation and temp file cleanup triggered
  - Non-critical writes (analytics, logs) paused
  - Critical writes (transactions) continue to reserved space
  - Alert fires with disk usage percentage
  - Application does not crash
```

### Step 4: Circuit Breaker Validation
Specifically test circuit breaker behavior:

```
CIRCUIT BREAKER VALIDATION:
┌───────────────────────────────────────────────────────────────┐
│  State Transitions                                            │
│                                                               │
│  CLOSED ──(failures > threshold)──→ OPEN                     │
│    ▲                                  │                       │
│    │                                  │ (timeout)             │
│    │                                  ▼                       │
│    └──(success)── HALF-OPEN ←─────────┘                      │
│                                                               │
│  CLOSED: Normal operation, requests flow through              │
│  OPEN: All requests fail fast (no network call)               │
│  HALF-OPEN: Limited requests to test recovery                 │
└───────────────────────────────────────────────────────────────┘

Test each transition:
1. CLOSED → OPEN
   Inject: <N> consecutive failures
   Verify: Circuit opens, requests return fallback immediately
   Verify: No further calls to the failing dependency

2. OPEN → HALF-OPEN
   Wait: <timeout period> (e.g., 30 seconds)
   Verify: Circuit transitions to half-open
   Verify: ONE request is allowed through to test the dependency

3. HALF-OPEN → CLOSED (recovery)
   Action: Restore the dependency
   Verify: Test request succeeds
   Verify: Circuit closes, normal traffic resumes

4. HALF-OPEN → OPEN (still failing)
   Action: Keep dependency down
   Verify: Test request fails
   Verify: Circuit re-opens for another timeout period

RESULTS:
┌────────────────────────┬──────────┬────────────────────────┐
│ Transition             │ Status   │ Notes                  │
├────────────────────────┼──────────┼────────────────────────┤
│ CLOSED → OPEN          │ PASS/FAIL│ <detail>               │
│ OPEN → HALF-OPEN       │ PASS/FAIL│ <detail>               │
│ HALF-OPEN → CLOSED     │ PASS/FAIL│ <detail>               │
│ HALF-OPEN → OPEN       │ PASS/FAIL│ <detail>               │
│ Fallback response      │ PASS/FAIL│ <detail>               │
│ Metrics/logging        │ PASS/FAIL│ <detail>               │
└────────────────────────┴──────────┴────────────────────────┘
```

### Step 5: Game Day Planning
Organize a structured resilience testing exercise:

```
GAME DAY PLAN:
Date: <scheduled date>
Duration: <2-4 hours>
Facilitator: <person>
Participants: <team members and roles>

OBJECTIVES:
1. Validate <specific resilience property>
2. Test <incident response procedure>
3. Verify <recovery time objective>

TIMELINE:
┌──────┬──────────────────────────────────────────────────────┐
│ Time │ Activity                                             │
├──────┼──────────────────────────────────────────────────────┤
│ 0:00 │ Kickoff — verify steady state, review experiment plan│
│ 0:15 │ Experiment 1 — <failure injection>                   │
│ 0:45 │ Observe and document — <what happened>               │
│ 1:00 │ Rollback Experiment 1 — verify recovery              │
│ 1:15 │ Break — discuss findings                             │
│ 1:30 │ Experiment 2 — <failure injection>                   │
│ 2:00 │ Observe and document                                 │
│ 2:15 │ Rollback Experiment 2 — verify recovery              │
│ 2:30 │ Experiment 3 — <failure injection>                   │
│ 3:00 │ Observe and document                                 │
│ 3:15 │ Rollback all — verify full steady state              │
│ 3:30 │ Retrospective — findings, action items, next steps   │
│ 4:00 │ End — publish game day report                        │
└──────┴──────────────────────────────────────────────────────┘

SAFETY PROTOCOLS:
- [ ] Production experiments require VP/Director approval
- [ ] Blast radius limited to <scope>
- [ ] Kill switch tested and accessible to all participants
- [ ] Incident channel open during all experiments
- [ ] No experiments during peak traffic hours
- [ ] Customer support team notified in advance
- [ ] Rollback verified for each experiment before injection

ESCALATION PATH:
If unexpected impact detected:
1. Immediately execute rollback procedure
2. Notify incident commander
3. Follow standard incident response process
4. Document the unexpected behavior for post-mortem
```

### Step 6: Resilience Scorecard

```
┌──────────────────────────────────────────────────────────────┐
│  CHAOS ENGINEERING REPORT — <system>                         │
├──────────────────────────────────────────────────────────────┤
│  Experiments run: <N>                                        │
│  Hypotheses confirmed: <N>/<total>                           │
│  Surprises found: <N>                                        │
│                                                              │
│  RESILIENCE SCORECARD:                                       │
│  ┌─────────────────────────┬────────┬───────────────────┐    │
│  │ Failure Domain          │ Grade  │ Notes             │    │
│  ├─────────────────────────┼────────┼───────────────────┤    │
│  │ Network latency         │ A/B/C/F│ <detail>          │    │
│  │ Network partition       │ A/B/C/F│ <detail>          │    │
│  │ Process crash           │ A/B/C/F│ <detail>          │    │
│  │ Memory pressure         │ A/B/C/F│ <detail>          │    │
│  │ CPU saturation          │ A/B/C/F│ <detail>          │    │
│  │ Database failure        │ A/B/C/F│ <detail>          │    │
│  │ Cache failure           │ A/B/C/F│ <detail>          │    │
│  │ Disk pressure           │ A/B/C/F│ <detail>          │    │
│  │ Dependency outage       │ A/B/C/F│ <detail>          │    │
│  │ Circuit breakers        │ A/B/C/F│ <detail>          │    │
│  └─────────────────────────┴────────┴───────────────────┘    │
│                                                              │
│  Grading:                                                    │
│  A = Resilient (graceful degradation, auto-recovery)         │
│  B = Adequate (handles failure, manual recovery needed)      │
│  C = Fragile (partial outage, slow recovery)                 │
│  F = Vulnerable (cascading failure, data loss risk)          │
│                                                              │
│  FINDINGS:                                                   │
│  1. <finding> — Grade impact: <domain>                       │
│  2. <finding> — Grade impact: <domain>                       │
│  3. <finding> — Grade impact: <domain>                       │
│                                                              │
│  RECOVERY TIMES:                                             │
│  Process restart: <X>s (target: <Y>s)                        │
│  DB failover: <X>s (target: <Y>s)                            │
│  Cache cold start: <X>s (target: <Y>s)                       │
│  Full system recovery: <X>s (target: <Y>s)                   │
│                                                              │
│  Overall Resilience: <RESILIENT | ADEQUATE | FRAGILE>        │
└──────────────────────────────────────────────────────────────┘
```

### Step 7: Commit and Transition
1. Save chaos experiment definitions to `docs/chaos/<system>-experiments.md`
2. Save game day plan to `docs/chaos/<system>-gameday-plan.md`
3. Save resilience scorecard to `docs/chaos/<system>-resilience-report.md`
4. Commit: `"chaos: <system> — <N> experiments, resilience: <grade>"`
5. If FRAGILE: "Critical resilience gaps found. Run `/godmode:fix` to address, then re-test."
6. If RESILIENT: "System handles failure gracefully. Ready for `/godmode:ship`."

## Key Behaviors

1. **Hypothesize before injecting.** Every chaos experiment starts with a hypothesis. If you don't predict the outcome, you won't learn from the results.
2. **Start small, increase blast radius.** Begin with single-request failures in development. Only run production chaos after validating in staging.
3. **Always have a rollback.** Before injecting any failure, verify you can undo it instantly. Test the rollback before the injection.
4. **Monitor everything.** Open dashboards before starting. You need to see the impact in real time to learn and to trigger rollback if needed.
5. **Breakage is a finding.** If the system breaks during chaos testing, you found a problem before users did.
6. **Production chaos requires ceremony.** Never run production chaos experiments casually. Game days need planning, approval, and incident response readiness.
7. **Document surprises.** The most valuable chaos engineering outcomes are the unexpected behaviors — things the team didn't know could happen.

## Example Usage

### Testing dependency resilience
```
User: /godmode:chaos Test what happens when our payment provider goes down

Chaos: Defining steady state...

STEADY STATE:
  Checkout success rate: 99.8%
  P95 response time: 340ms
  Error rate: 0.2%

EXPERIMENT: Payment Provider Outage
Hypothesis: "When the payment API is unreachable, checkout shows a user-
  friendly error and queues the order for retry. Other features (browsing,
  search, cart) are unaffected."

Injecting failure (toxiproxy: block payment-api)...

RESULTS:
  Checkout: Returns "Payment temporarily unavailable" in 2.1s ← PASS
  Circuit breaker: Opens after 5 failures ← PASS
  Order queue: 12 orders queued for retry ← PASS
  Browse/search: Unaffected, P95 = 42ms ← PASS
  SURPRISE: Cart total still calls payment API for tax calc ← FINDING

  Cart is coupled to payment API unnecessarily.
  Recommendation: Cache tax rates locally, update daily.
```

### Game day planning
```
User: /godmode:chaos Plan a game day for our microservices platform

Chaos: Analyzing your architecture...

Found 7 services, 3 databases, 2 caches, 4 external APIs

GAME DAY PLAN:
Duration: 3 hours
Experiments:
  1. Kill order-service pod (test auto-restart + request retry)
  2. Add 3s latency to user-service (test timeout + circuit breaker)
  3. Flush Redis cache (test cold-cache performance)
  4. Partition inventory-service from database (test read replica failover)
  5. Block Stripe API (test payment circuit breaker)

Safety: staging environment, kill switch per experiment
Team: 4 engineers + 1 facilitator
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full chaos assessment — map failure domains, design experiments |
| `--experiment <name>` | Run a specific pre-designed experiment |
| `--network` | Network failure experiments only |
| `--process` | Process/compute failure experiments only |
| `--storage` | Storage/database failure experiments only |
| `--deps` | External dependency failure experiments only |
| `--circuit-breaker` | Circuit breaker validation only |
| `--gameday` | Generate a game day plan |
| `--scorecard` | Generate resilience scorecard from past experiments |
| `--production` | Flag for production experiments (requires extra safety checks) |

## HARD RULES

1. **NEVER STOP** until all planned experiments are executed or explicitly skipped with documented reason.
2. **git commit BEFORE verify** — commit experiment definitions and results before running the next experiment.
3. **Automatic revert on regression** — if an experiment causes unrecoverable state, execute rollback immediately. No exceptions.
4. **TSV logging** — log every experiment run:
   ```
   timestamp	experiment_name	hypothesis	blast_radius	duration	result	surprises
   ```
5. **NEVER run production chaos without steady state verification first.**
6. **NEVER inject failure without a tested rollback procedure.**
7. **ALWAYS document surprises** — unexpected behavior is the most valuable output.

## Explicit Loop Protocol

When running a series of chaos experiments:

```
current_iteration = 0
experiments = planned_experiment_list
results = []

WHILE experiments is not empty:
    current_iteration += 1
    experiment = experiments.pop(0)

    # Pre-flight
    steady_state = verify_steady_state()
    IF NOT steady_state:
        ABORT "System not healthy — cannot inject failure"

    rollback_tested = test_rollback(experiment)
    IF NOT rollback_tested:
        SKIP experiment, log reason
        CONTINUE

    # Execute
    inject_failure(experiment)
    observe(experiment.duration)
    result = capture_metrics()
    execute_rollback(experiment)

    # Verify recovery
    post_steady_state = verify_steady_state()
    IF NOT post_steady_state:
        ESCALATE "System did not recover after rollback"
        BREAK

    results.append(result)
    git commit experiment result

    IF current_iteration % 5 == 0:
        print(f"Progress: {current_iteration}/{len(experiments) + current_iteration} experiments complete")
        print_scorecard(results)
```

## Auto-Detection

On activation, automatically detect infrastructure context:

```
AUTO-DETECT:
1. Container orchestration:
   kubectl cluster-info 2>/dev/null && echo "kubernetes"
   docker info 2>/dev/null && echo "docker"

2. Cloud provider:
   aws sts get-caller-identity 2>/dev/null && echo "aws"
   gcloud config get-value project 2>/dev/null && echo "gcp"

3. Service mesh / proxy:
   kubectl get crd | grep -i istio && echo "istio"
   linkerd check 2>/dev/null && echo "linkerd"

4. Monitoring stack:
   kubectl get svc -A | grep -i "grafana\|prometheus\|datadog"

5. Chaos tooling already installed:
   which toxiproxy-cli litmus chaostoolkit 2>/dev/null

-> Auto-select injection method based on detected infrastructure.
-> Auto-configure monitoring queries for the detected stack.
```

## Success Criteria
All of these must be true before marking the task complete:
1. Steady state hypothesis is defined with measurable metric and threshold (e.g., `p99 latency < 200ms`).
2. At least one chaos experiment designed with: hypothesis, injection method, blast radius, abort conditions.
3. Monitoring dashboards show the target metric BEFORE injection (baseline captured).
4. Experiment runs in a non-production environment first (dev or staging) with expected behavior validated.
5. Abort mechanism works: injection can be stopped within 30 seconds and system recovers.
6. Findings documented: each surprise becomes a backlog item with severity and remediation plan.
7. Circuit breakers (if applicable) trip correctly under failure conditions and recover when failure is removed.
8. Runbook updated with observed failure modes and recovery steps.

## Error Recovery
| Failure | Action |
|---------|--------|
| Injection cannot be reversed | Kill the injection process immediately. If using Toxiproxy: `toxiproxy-cli toxic remove`. If using tc: `tc qdisc del dev eth0 root`. If process kill: restart the service. Document the failed abort path and fix it before next experiment. |
| Monitoring not showing impact | Verify metric queries target the correct service/pod. Check time range alignment. If metrics are delayed (>30s lag), do not proceed — you cannot observe what you cannot measure. |
| System crashes instead of degrading | This IS a finding. Document it. The expected behavior was graceful degradation; actual behavior was crash. Create a high-priority backlog item for resilience improvement. |
| Blast radius exceeded | Abort immediately. Check scope configuration (target only intended pods/services). Review injection parameters. Reduce blast radius for next attempt. |
| Docker/K8s not available | Fall back to application-level injection: artificial latency in middleware, random error responses, connection pool exhaustion. No infrastructure access needed. |
| Team not available for game day | Never run production chaos experiments solo. Reschedule. For non-production, proceed but limit blast radius to single-service. |

## Multi-Agent Dispatch
```
Agent 1 (worktree: chaos-infra):
  - Set up monitoring dashboards for steady-state metrics
  - Configure chaos injection tools (Toxiproxy/tc/Litmus)
  - Build abort scripts with one-command rollback

Agent 2 (worktree: chaos-experiments):
  - Design experiment specifications (hypothesis, method, blast radius, abort)
  - Implement injection scripts per failure domain
  - Create experiment execution runbook

Agent 3 (worktree: chaos-resilience):
  - Implement circuit breakers and fallbacks for identified failure points
  - Add health checks and readiness probes
  - Write recovery validation tests

MERGE ORDER: infra -> experiments -> resilience
CONFLICT ZONES: monitoring config, service configuration, health check endpoints
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run chaos tasks sequentially: monitoring setup, then experiment design, then injection tooling, then resilience implementation.
- Use branch isolation per task: `git checkout -b godmode-chaos-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.

## Keep/Discard Discipline
```
After EACH chaos experiment:
  1. MEASURE: Did the system recover to steady state after rollback? What was the recovery time?
  2. COMPARE: Did the hypothesis hold? Were there surprises?
  3. DECIDE:
     - KEEP findings if: experiment ran to completion AND monitoring captured the impact AND system recovered
     - DISCARD results if: rollback failed (results are unreliable) OR monitoring was not active during injection
  4. COMMIT experiment results. Create backlog items for every surprise finding.

Never declare a system "resilient" based on an experiment where monitoring was not active.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All planned experiments executed and results documented
  - System recovers to steady state within target RTO for all failure domains
  - User explicitly requests stop
  - A rollback fails (investigate before running more experiments)

DO NOT STOP just because:
  - Some failure domains scored C instead of A (document and prioritize fixes)
  - Production experiments are not yet approved (complete staging experiments first)
```

## Anti-Patterns

- **Do NOT inject failures without monitoring.** If you cannot observe the impact, you cannot learn from the experiment.
- **Do NOT skip the hypothesis.** "Let's see what happens" is not chaos engineering. Predict the outcome, then verify.
- **Do NOT start in production.** Start in development, graduate to staging, then production.
- **Do NOT run chaos without a rollback plan.** If you cannot undo the injection in under 30 seconds, you are not ready.
- **Do NOT test during peak traffic.** Production chaos runs during low-traffic periods with the team on standby.
- **Do NOT treat chaos as a one-time event.** Resilience degrades as code changes. Run experiments monthly.
- **Do NOT ignore findings.** Every surprise should become a backlog item. A finding without a fix is wasted effort.
