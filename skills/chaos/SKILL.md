---
name: chaos
description: |
  Chaos engineering skill. Activates when user needs to test system resilience through controlled failure injection,
    validate circuit breakers, plan game days, or verify disaster recovery procedures. Covers network failures, disk
    pressure, process crashes, dependency outages, and data corruption scenarios. Triggers on: /godmode:chaos, "chaos
    test", "resilience test", "failure injection", "game day", or when ship skill needs resilience validation.
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
IF experiment crashes service: halt and rollback.
WHEN steady-state violated: record finding.

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
Hypothesis: "System falls back to cached data when DNS fails." Injection: `iptables -A OUTPUT -p udp --dport
53 -j DROP`. Verify cached responses served, error messages shown for uncached.

**Experiment N3: Packet Loss**
Hypothesis: "With 10% packet loss, success rate stays >95%." Injection: `tc qdisc add dev eth0 root netem loss
10%`. Verify retry logic, SLO compliance, no pool exhaustion.

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
Hypothesis: "At 90%+ memory, app sheds load gracefully." Injection: `stress-ng --vm 1 --vm-bytes 80% --timeout
300s`. Verify load shedding, no OOM kill, health check alive.

**Experiment P3: CPU Saturation**
Hypothesis: "At 95% CPU, health checks and critical paths prioritized." Injection: `stress-ng --cpu $(nproc)
--timeout 300s`. Verify health check <1s, background deferred, autoscaling triggers.

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

```bash
# Chaos injection tools
tc qdisc add dev eth0 root netem delay 500ms
kubectl delete pod <pod-name> --grace-period=0
stress-ng --cpu $(nproc) --vm 1 --vm-bytes 80% --timeout 60s
redis-cli FLUSHALL
```
1. **Hypothesize before injecting.** Predict the outcome first.
2. **Start small.** Dev first, then staging, then production.
3. **Always have a rollback.** Test rollback before injection.
4. **Monitor everything.** Dashboards open before starting.
5. **Breakage is a finding.** You found it before users did.
6. **Production chaos requires ceremony.** Plan and approve.
7. **Document surprises.** Unexpected behaviors are most valuable.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full chaos assessment — map failure domains, design experiments |
| `--experiment <name>` | Run a specific pre-designed experiment |
| `--network` | Network failure experiments only |

## HARD RULES

1. **NEVER STOP** until all planned experiments are executed or explicitly skipped with documented reason.
2. **git commit BEFORE verify** — commit experiment definitions and results before running the next experiment.
3. **Automatic revert on regression** — if an experiment causes unrecoverable state, execute rollback
immediately. No exceptions.
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


## Keep/Discard
KEEP if: improvement verified. DISCARD if: regression or no change. Revert discards immediately.

## Stop Conditions
Stop when: target reached, budget exhausted, or >5 consecutive discards.

