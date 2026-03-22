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
  ...
```
### Step 2: Identify Failure Domains
Map all the ways the system can fail:

```
FAILURE DOMAIN MAP:
| Category | Components | Impact if Failed |
|--|--|--|
| Network | Load balancer | Total outage |
|  | DNS resolution | Total outage |
|  | Inter-service network | Partial outage |
|  | External API access | Feature degraded |
| Compute | Application process | Service restart |
|  | Worker processes | Queue backlog |
|  | Cron/scheduled jobs | Delayed tasks |
|  | Container/VM host | Service relocation |
| Storage | Primary database | Read/write loss |
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
  ...
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

  ...
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

Verify:
  - Cached responses served for previously-resolved hosts
  ...
```

**Experiment N3: Packet Loss**
```
Hypothesis: "With 10% packet loss, the system maintains >95% success
  rate through retries and connection management."

Injection:
  # Add 10% packet loss
  tc qdisc add dev eth0 root netem loss 10%

Verify:
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

Verify:
  ...
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

Verify:
  - Application detects memory pressure
  ...
```

**Experiment P3: CPU Saturation**
```
Hypothesis: "At 95% CPU utilization, the system prioritizes health checks
  and critical paths over background tasks."

Injection:
  # Saturate CPU
  stress-ng --cpu $(nproc) --timeout 300s

Verify:
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

Verify:
  - Read traffic continues on replica immediately
  ...
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

Verify:
  ...
```

**Experiment S3: Disk Full**
```
Hypothesis: "When disk reaches 95%, the system stops non-critical writes,
  alerts operators, and continues serving read traffic."

Injection:
  # Fill disk to 95%
  fallocate -l $(df --output=avail / | tail -1 | awk '{print int($1*0.90)}')k /tmp/fill-disk

Verify:
  - Log rotation and temp file cleanup triggered
  - Non-critical writes (analytics, logs) paused
  - Critical writes (transactions) continue to reserved space
  - Alert fires with disk usage percentage
  ...
```

### Step 4: Circuit Breaker Validation
Specifically test circuit breaker behavior:

```
CIRCUIT BREAKER VALIDATION:
  State Transitions
  CLOSED ──(failures > threshold)──→ OPEN
| ▲ |  |
|  |  | (timeout) |
|  | ▼ |
  └──(success)── HALF-OPEN ←─────────┘
  CLOSED: Normal operation, requests flow through
  OPEN: All requests fail fast (no network call)
  HALF-OPEN: Limited requests to test recovery

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
  ...
```
### Step 6: Resilience Scorecard

```
  CHAOS ENGINEERING REPORT — <system>
  Experiments run: <N>
  Hypotheses confirmed: <N>/<total>
  Surprises found: <N>
  RESILIENCE SCORECARD:
  ┌─────────────────────────┬────────┬───────────────────┐
|  | Failure Domain | Grade | Notes |  |
  ├─────────────────────────┼────────┼───────────────────┤
|  | Network latency | A/B/C/F | <detail> |  |
|  | Network partition | A/B/C/F | <detail> |  |
|  | Process crash | A/B/C/F | <detail> |  |
|  | Memory pressure | A/B/C/F | <detail> |  |
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

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full chaos assessment — map failure domains, design experiments |
| `--experiment <name>` | Run a specific pre-designed experiment |
| `--network` | Network failure experiments only |

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
  ...
```
## Success Criteria
Verify all of these before marking the task complete:
1. Steady state hypothesis is defined with measurable metric and threshold (e.g., `p99 latency < 200ms`).
2. At least one chaos experiment designed with: hypothesis, injection method, blast radius, abort conditions.
3. Monitoring dashboards show the target metric BEFORE injection (baseline captured).
4. Experiment runs in a non-production environment first (dev or staging) with expected behavior validated.
5. Abort mechanism works: operator stops injection within 30 seconds and system recovers.
6. Findings documented: each surprise becomes a backlog item with severity and remediation plan.
7. Circuit breakers (if applicable) trip correctly under failure conditions and recover when failure is removed.
8. Runbook updated with observed failure modes and recovery steps.

## Error Recovery
| Failure | Action |
|--|--|
| Injection cannot be reversed | Kill the injection process immediately. If using Toxiproxy: `toxiproxy-cli toxic remove`. If using tc: `tc qdisc del dev eth0 root`. If process kill: restart the service. Document the failed abort path and fix it before next experiment. |
| Monitoring not showing impact | Verify metric queries target the correct service/pod. Check time range alignment. If metrics are delayed (>30s lag), do not proceed — you cannot observe what you cannot measure. |
| System crashes instead of degrading | This IS a finding. Document it. The expected behavior was graceful degradation; actual behavior was crash. Create a high-priority backlog item for resilience improvement. |

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

## Output Format
Print: `Chaos: {system} — {N} experiments, {confirmed}/{total} hypotheses confirmed. Surprises: {S}. Resilience: {RESILIENT|ADEQUATE|FRAGILE}. Status: {DONE|PARTIAL}.`
