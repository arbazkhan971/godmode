---
name: observe
description: |
  Monitoring and observability skill. Activates when user needs to instrument applications with metrics, logging, and tracing. Designs Prometheus/DataDog/CloudWatch metrics, structured logging strategies (ELK, Loki), distributed tracing (Jaeger, Zipkin, OpenTelemetry), alert rules, SLO/SLI definitions, and dashboards. Triggers on: /godmode:observe, "add monitoring", "set up logging", "create alerts", "define SLOs", "build dashboard", or when shipping requires observability.
---

# Observe — Monitoring & Observability

## When to Activate
- User invokes `/godmode:observe`
- User says "add monitoring", "set up logging", "create alerts"
- User says "define SLOs", "build dashboard", "add tracing"
- Team ships application without observability instrumentation
- Incident response reveals missing visibility into system behavior
- Pre-ship check identifies observability gaps

## Workflow

### Step 1: Observability Assessment
Evaluate the current state of the three observability pillars:

```
OBSERVABILITY ASSESSMENT:
| Pillar | Status | Coverage | Tools |
|--|--|--|--|
| Metrics | PARTIAL | 40% | Prometheus |
| Logging | BASIC | 60% | stdout only |
| Tracing | NONE | 0% | — |
| Alerting | MINIMAL | 20% | PagerDuty |
| Dashboards | NONE | 0% | — |
  ...
```
### Step 2: Metrics Design
Design application and infrastructure metrics using the RED/USE methodology:

#### RED Method (Request-driven services)
```
REQUEST METRICS:
| Metric | Type | Labels |
|--|--|--|
| http_requests_total | Counter | method, path, |
|  |  | status_code |
| http_request_duration_sec | Histogram | method, path |
| http_requests_in_flight | Gauge | — |
| http_request_size_bytes | Histogram | method, path |
  ...
```

#### USE Method (Infrastructure resources)
```
RESOURCE METRICS:
| Resource | Utilization | Saturation |
|  |  | Errors |
| CPU | process_cpu_seconds | cpu_throttled_total |
| Memory | process_resident_mb | oom_kills_total |
| Disk | disk_usage_bytes | disk_io_wait_sec |
| Network | network_bytes_total | network_errors_total |
| Connections | db_connections_open | db_conn_wait_total |
  ...
```

#### Business Metrics
```
BUSINESS METRICS:
| Metric | Type | Purpose |
|--|--|--|
| user_signups_total | Counter | Growth tracking |
| orders_completed_total | Counter | Revenue proxy |
| payment_failures_total | Counter | Revenue risk |
| active_sessions_current | Gauge | Load indicator |
| feature_flag_evaluations | Counter | Feature adoption |
  ...
```

#### Instrumentation Examples

**Prometheus (Node.js / Express)**
```javascript
const promClient = require('prom-client');

// Default metrics (CPU, memory, event loop)
promClient.collectDefaultMetrics();

// HTTP request duration histogram
```

**DataDog (Python / Flask)**
```python
from datadog import statsd

@app.before_request
def before_request():
    g.start_time = time.monotonic()

```

### Step 3: Structured Logging Strategy
Design a consistent, queryable logging approach:

#### Log Format Standard
```json
{
  "timestamp": "2025-01-15T10:30:45.123Z",
  "level": "info",
  "service": "api-gateway",
  "version": "1.2.3",
  "trace_id": "abc123def456",
```

#### Log Levels and Usage
```
LOG LEVEL GUIDE:
| Level | When to use | Alert? |
|--|--|--|
| FATAL | Process cannot continue | Page on-call |
| ERROR | Operation failed, needs fix | Alert to channel |
| WARN | Unexpected but handled | Track trend |
| INFO | Significant business events | No |
| DEBUG | Diagnostic detail | No (dev only) |
  ...
```

#### Log Aggregation Setup

**ELK Stack (Elasticsearch + Logstash + Kibana)**
```
Application -> Filebeat -> Logstash -> Elasticsearch -> Kibana
                              |
                         Parse, enrich,
                         filter, transform
```

**Loki + Grafana**
```
Application -> Promtail -> Loki -> Grafana
                              |
                         Label-based indexing
                         (cheaper than full-text)
```

**CloudWatch Logs**
```
Application -> CloudWatch Agent -> CloudWatch Logs -> CloudWatch Insights
                                                         |
                                                   Query with SQL-like syntax
```

#### What to Log (Checklist)
```
LOGGING CHECKLIST:
- [ ] HTTP request start (method, path, request_id)
- [ ] HTTP request complete (status, duration, request_id)
- [ ] External service calls (service, endpoint, duration, result)
- [ ] Database queries (query type, table, duration — NOT the query itself)
- [ ] Authentication events (login, logout, failed attempts)
- [ ] Authorization failures (who tried to access what)
- [ ] Business events (order placed, payment processed, user signup)
  ...
```

### Step 4: Distributed Tracing
Instrument request flows across service boundaries:

#### OpenTelemetry Setup (Recommended)
```javascript
// tracing.js — Initialize before application code
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

const sdk = new NodeSDK({
```

#### Trace Propagation
```
REQUEST FLOW WITH TRACING:
Client -> API Gateway -> Auth Service -> User Service -> Database
  |          |               |               |              |
  trace_id: abc123 propagated across all services via headers
  |          |               |               |              |
  span 1     span 2         span 3          span 4         span 5
  (12ms)     (8ms)          (3ms)           (5ms)          (2ms)

  ...
```

#### Trace Backend Options
```
TRACING BACKENDS:
| Backend | Best for | Storage | Cost |
|--|--|--|--|
| Jaeger | Self-hosted, K8s | Elastic/ | Infra |
|  |  | Cassandra | only |
| Zipkin | Simple setups | In-memory/ | Free |
|  |  | MySQL |  |
| Tempo | Grafana ecosystem | Object | Low |
  ...
```

### Step 5: SLO/SLI Definition
Define Service Level Objectives and Indicators:

```
SLO FRAMEWORK:
  Service: <service-name>
| SLI | Target | Window | Burn Rate |
|--|--|--|--|
| Availability | 99.9% | 30 days | Budget: |
| (successful requests |  |  | 43.2 min |
| / total requests) |  |  | downtime |
│                       │           │         │            │
  ...
```
#### SLO Burn Rate Alerts
```yaml
# Multi-window burn rate alert (recommended by Google SRE)
# Fast burn: 14.4x burn rate over 1 hour (consumes 2% of budget)
- alert: SLOHighBurnRate_Fast
  expr: |
    (
      sum(rate(http_requests_total{status_code=~"5.."}[1h]))
```

### Step 6: Alert Rule Design
Create actionable, low-noise alerts:

#### Alert Design Principles
```
ALERT RULES:
| Alert Name | Condition | Severity |
|--|--|--|
| HighErrorRate | 5xx > 1% for 5m | Critical |
| HighLatencyP95 | P95 > 500ms for 5m | Warning |
| HighLatencyP99 | P99 > 2s for 5m | Critical |
| PodCrashLooping | restarts > 3 in 5m | Critical |
| DiskSpaceLow | usage > 85% | Warning |
  ...
```

#### Prometheus Alert Rules
```yaml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status_code=~"5.."}[5m]))
```

### Step 7: Dashboard Design
Create dashboards following the Four Golden Signals:

```
DASHBOARD LAYOUT — Service Overview:
  ROW 1: Golden Signals (top-level health)
  ┌─────────────┐ ┌─────────────┐ ┌────────┐ ┌─────────┐
|  | Request Rate |  | Error Rate |  | Latency |  | Saturation |  |
|  | 1.2k rps |  | 0.03% |  | 45ms |  | 62% |  |
|  | ▁▂▃▅▆█▇▅ |  | ▁▁▁▁▂▁▁▁ |  | ▂▃▂▃▂▃▂ |  | ▃▄▅▅▄▃▄ |  |
  └─────────────┘ └─────────────┘ └────────┘ └─────────┘
  ROW 2: SLO Status
  ...
```
### Step 8: Commit and Report
```
1. Save observability configuration in `monitoring/` or `observability/` directory
2. Save alert rules as `monitoring/alerts.yaml`
3. Save dashboard definitions as `monitoring/dashboards/`
4. Save SLO definitions as `monitoring/slos.yaml`
5. Commit: "observe: <description> — <pillars covered> (<N> metrics, <N> alerts)"
6. If gaps found: "Observability gaps detected. Priority: <list gaps>."
7. If complete: "Full observability stack configured: metrics, logging, tracing, alerts, SLOs."
```

## Autonomous Operation
- Loop until all three pillars produce verified output or budget exhausted. Never pause.
- Measure before/after. Guard: test_cmd && lint_cmd.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Key Behaviors

1. **Three pillars are mandatory.** Metrics, logs, and traces are not optional. Each gives visibility that the others cannot.
2. **Structured logs only.** No `console.log("something happened")`. Format every log entry as structured JSON with consistent fields.
3. **Make alerts actionable.** If an alert fires and the on-call cannot act on it, the alert is noise. Remove or fix it.
4. **SLOs drive decisions.** Error budget remaining determines whether you ship features or fix reliability. Define SLOs before you need them.
## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full observability assessment and recommendations |
| `--metrics` | Set up metrics instrumentation only |
| `--logging` | Set up structured logging only |

## HARD RULES

1. **NEVER ship without at least metrics + structured logging.** Add tracing later. Metrics and logs are day-one requirements.
2. **NEVER use `console.log` / `print` in production code.** All logging goes through the structured logger with consistent fields.
3. **NEVER put high-cardinality values in metric labels.** `user_id`, `request_id`, `trace_id` go in logs/traces, not metric labels. Violating this kills Prometheus/DataDog.
4. **NEVER create alerts without a `for` duration.** Minimum 5 minutes for warnings, 2 minutes for critical. No flapping alerts.
5. **NEVER log PII, tokens, passwords, or credit card numbers.** Sanitize before emission. This is non-negotiable.
6. **NEVER create a dashboard without stating the question it answers.** If you cannot name the question, the dashboard is noise.
7. **ALWAYS include `request_id` in every log entry.** Cross-request correlation is impossible without it.
8. **ALWAYS verify webhook/exporter endpoints are reachable before declaring setup complete.**

## Auto-Detection
Scan for: prom-client, datadog, statsd, opentelemetry, newrelic, winston, pino, bunyan, structlog, loguru, slog, zerolog, jaeger-client, zipkin, dd-trace. Check for /metrics endpoint in routes.

## Keep/Discard Discipline
```
After EACH observability instrumentation change:
  1. MEASURE: Verify the pillar produces output (curl /metrics, check logs, verify trace appears in backend).
  2. COMPARE: Is observability coverage better than before?
  3. DECIDE:
     - KEEP if: instrumentation produces correct output AND no performance regression (< 5% latency increase)
     - DISCARD if: instrumentation produces no output OR performance degrades >5% OR cardinality explosion detected
  4. COMMIT kept changes. Revert discarded changes before the next pillar.

  ...
```

## Stop Conditions
```
STOP when ANY: all three pillars produce verified output, SLOs defined, alerts configured, user requests stop.
DO NOT STOP only because dashboards are not yet built.
```

## Output Format
Print on completion: `Observe: {pillar_count}/3 pillars configured (metrics/logs/traces). SLOs: {slo_count} defined. Alerts: {alert_count} configured. Dashboards: {dashboard_count}. Error budget: {error_budget_pct}% remaining. Verdict: {verdict}.`

## TSV Logging
Log to `.godmode/observe-results.tsv`:
```
iteration	pillar	tool	items_configured	coverage_pct	alert_count	status
```

## Success Criteria
- All three observability pillars implemented (metrics, logs, traces).
- SLOs defined for all critical services with error budgets.
- Alerts have `for` duration and actionable runbooks.
- No unbounded cardinality in metric labels.
- PII redacted from all logs and traces.

## Error Recovery
| Failure | Action |
|--|--|
| Metrics cardinality explosion | Remove high-cardinality labels. Use histograms instead of per-value counters. Set cardinality limits. |
| Traces missing spans | Check sampling rate. Verify context propagation. Check HTTP clients propagate trace headers. |
| Alert fatigue | Tune thresholds using historical data. Add `for:` duration. Use multi-signal alerts. |
| Log volume exceeds budget | Drop DEBUG in production. Sample high-volume paths. Compress before shipping. |
