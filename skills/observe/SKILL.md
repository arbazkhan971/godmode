---
name: observe
description: Monitoring and observability (metrics/logs/traces).
---

## Activate When
- `/godmode:observe`, "add monitoring", "set up logging"
- "create alerts", "define SLOs", "build dashboard"
- Shipping without observability instrumentation

## Workflow

### 1. Assessment
```
| Pillar | Status | Coverage | Tools |
| Metrics | PARTIAL | 40% | Prometheus |
| Logging | BASIC | 60% | stdout |
| Tracing | NONE | 0% | — |
| Alerting | MINIMAL | 20% | PagerDuty |
```
```bash
# Detect observability libraries
grep -rE "prom-client|datadog|opentelemetry" \
  package.json requirements.txt 2>/dev/null
```

### 2. Metrics (RED + USE methods)
```
RED (request-driven):
  http_requests_total (counter: method, path, status)
  http_request_duration_sec (histogram: method, path)
  http_requests_in_flight (gauge)
USE (infrastructure):
  CPU, memory, disk, network, connections
Business:
  user_signups_total, orders_completed_total,
  payment_failures_total, active_sessions
```
IF cardinality > 10K labels: remove high-cardinality
  (user_id, request_id go in logs, not metrics).

### 3. Structured Logging
```json
{
  "timestamp": "2025-01-15T10:30:45Z",
  "level": "info",
  "service": "api-gateway",
  "trace_id": "abc123",
  "request_id": "req-456",
  "message": "request completed",
  "duration_ms": 45
}
```
```
| Level | When | Alert? |
| FATAL | Cannot continue | Page on-call |
| ERROR | Operation failed | Alert channel |
| WARN | Unexpected but handled | Track trend |
| INFO | Business events | No |
| DEBUG | Diagnostic (dev only) | No |
```
NEVER log PII, tokens, passwords, or credit cards.
ALWAYS include request_id in every log entry.

### 4. Distributed Tracing
```
OpenTelemetry setup (recommended):
  Auto-instrument: HTTP, DB, Redis, gRPC
  Propagate: trace_id across all service calls
  Backend: Jaeger|Tempo|Zipkin|Datadog
```
IF sampling rate too low (< 1%): miss rare errors.
IF 100% sampling: too expensive at scale.
Default: 10% sampling, 100% for errors.

### 5. SLO/SLI Definition
```
| SLI | Target | Window | Error Budget |
| Availability | 99.9% | 30d | 43.2 min |
| Latency p99 | < 500ms | 30d | 0.1% slow |
| Error rate | < 0.1% | 30d | budget: 0.1% |
```
Burn rate alerts:
  Fast: 14.4x over 1h (consumes 2% budget)
  Slow: 6x over 6h (consumes 5% budget)

### 6. Alert Rules
```
| Alert | Condition | Severity |
| HighErrorRate | 5xx > 1% for 5m | Critical |
| HighLatencyP99 | p99 > 2s for 5m | Critical |
| DiskSpaceLow | usage > 85% | Warning |
| PodCrashLoop | restarts > 3/5m | Critical |
```
EVERY alert MUST have `for` duration (min 2m critical,
  5m warning). No flapping alerts.

### 7. Dashboard (Four Golden Signals)
```
Row 1: Request Rate, Error Rate, Latency, Saturation
Row 2: SLO status, error budget remaining
Row 3: Per-service breakdown
Row 4: Infrastructure (CPU, memory, disk, network)
```

## Hard Rules
1. NEVER ship without metrics + structured logging.
2. NEVER console.log/print in production.
3. NEVER high-cardinality in metric labels.
4. NEVER alert without `for` duration.
5. NEVER log PII/tokens/passwords.
6. ALWAYS include request_id in every log.
7. ALWAYS verify endpoints reachable before done.

## TSV Logging
Append `.godmode/observe-results.tsv`:
```
timestamp	pillar	tool	items_configured	coverage_pct	status
```

## Keep/Discard
```
KEEP if: pillar produces verified output AND
  latency increase < 5%.
DISCARD if: no output OR perf degrades > 5%
  OR cardinality explosion.
```

## Stop Conditions
```
STOP when FIRST of:
  - All 3 pillars verified (metrics/logs/traces)
  - SLOs defined + alerts configured
  - User requests stop
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Cardinality explosion | Remove labels, use histograms |
| Missing trace spans | Check sampling, propagation |
| Alert fatigue | Tune thresholds, add for: duration |
| Log volume exceeds budget | Drop DEBUG, sample paths |
