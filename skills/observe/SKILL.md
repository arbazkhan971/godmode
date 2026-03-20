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
- Application is being shipped without observability instrumentation
- Incident response reveals missing visibility into system behavior
- Pre-ship check identifies observability gaps

## Workflow

### Step 1: Observability Assessment
Evaluate the current state of the three observability pillars:

```
OBSERVABILITY ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│  Pillar          │ Status    │ Coverage │ Tools           │
│  ─────────────────────────────────────────────────────── │
│  Metrics         │ PARTIAL   │ 40%      │ Prometheus      │
│  Logging         │ BASIC     │ 60%      │ stdout only     │
│  Tracing         │ NONE      │ 0%       │ —               │
│  Alerting        │ MINIMAL   │ 20%      │ PagerDuty       │
│  Dashboards      │ NONE      │ 0%       │ —               │
│  SLOs            │ NONE      │ 0%       │ —               │
├──────────────────────────────────────────────────────────┤
│  Overall Score: 2/10 — INSUFFICIENT                       │
│  Priority: Set up structured logging + core metrics       │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Metrics Design
Design application and infrastructure metrics using the RED/USE methodology:

#### RED Method (Request-driven services)
```
REQUEST METRICS:
┌──────────────────────────────────────────────────────────┐
│  Metric                    │ Type      │ Labels           │
│  ─────────────────────────────────────────────────────── │
│  http_requests_total       │ Counter   │ method, path,    │
│                            │           │ status_code      │
│  http_request_duration_sec │ Histogram │ method, path     │
│  http_requests_in_flight   │ Gauge     │ —                │
│  http_request_size_bytes   │ Histogram │ method, path     │
│  http_response_size_bytes  │ Histogram │ method, path     │
└──────────────────────────────────────────────────────────┘

Rate:    rate(http_requests_total[5m])
Errors:  rate(http_requests_total{status_code=~"5.."}[5m])
Duration: histogram_quantile(0.95, rate(http_request_duration_sec_bucket[5m]))
```

#### USE Method (Infrastructure resources)
```
RESOURCE METRICS:
┌──────────────────────────────────────────────────────────┐
│  Resource    │ Utilization         │ Saturation          │
│              │                     │ Errors              │
│  ─────────────────────────────────────────────────────── │
│  CPU         │ process_cpu_seconds │ cpu_throttled_total  │
│  Memory      │ process_resident_mb │ oom_kills_total      │
│  Disk        │ disk_usage_bytes    │ disk_io_wait_sec     │
│  Network     │ network_bytes_total │ network_errors_total │
│  Connections │ db_connections_open │ db_conn_wait_total   │
│  Queue       │ queue_depth         │ queue_age_seconds    │
└──────────────────────────────────────────────────────────┘
```

#### Business Metrics
```
BUSINESS METRICS:
┌──────────────────────────────────────────────────────────┐
│  Metric                       │ Type    │ Purpose         │
│  ─────────────────────────────────────────────────────── │
│  user_signups_total           │ Counter │ Growth tracking  │
│  orders_completed_total       │ Counter │ Revenue proxy    │
│  payment_failures_total       │ Counter │ Revenue risk     │
│  active_sessions_current      │ Gauge   │ Load indicator   │
│  feature_flag_evaluations     │ Counter │ Feature adoption │
│  background_job_duration_sec  │ Hist    │ Job performance  │
│  cache_hit_ratio              │ Gauge   │ Cache efficiency │
└──────────────────────────────────────────────────────────┘
```

#### Instrumentation Examples

**Prometheus (Node.js / Express)**
```javascript
const promClient = require('prom-client');

// Default metrics (CPU, memory, event loop)
promClient.collectDefaultMetrics();

// HTTP request duration histogram
const httpDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
});

// HTTP request counter
const httpRequests = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status_code'],
});

// Middleware
app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    const labels = {
      method: req.method,
      path: req.route?.path || req.path,
      status_code: res.statusCode,
    };
    end(labels);
    httpRequests.inc(labels);
  });
  next();
});
```

**DataDog (Python / Flask)**
```python
from datadog import statsd

@app.before_request
def before_request():
    g.start_time = time.monotonic()

@app.after_request
def after_request(response):
    duration = time.monotonic() - g.start_time
    tags = [
        f"method:{request.method}",
        f"path:{request.path}",
        f"status:{response.status_code}",
    ]
    statsd.increment("http.requests.total", tags=tags)
    statsd.histogram("http.request.duration", duration, tags=tags)
    return response
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
  "span_id": "789ghi012",
  "request_id": "req-uuid-here",
  "message": "Request completed",
  "method": "POST",
  "path": "/api/orders",
  "status_code": 201,
  "duration_ms": 45,
  "user_id": "user-123",
  "ip": "10.0.1.50",
  "error": null
}
```

#### Log Levels and Usage
```
LOG LEVEL GUIDE:
┌──────────────────────────────────────────────────────────┐
│  Level │ When to use                    │ Alert?          │
│  ─────────────────────────────────────────────────────── │
│  FATAL │ Process cannot continue        │ Page on-call    │
│  ERROR │ Operation failed, needs fix    │ Alert to channel│
│  WARN  │ Unexpected but handled         │ Track trend     │
│  INFO  │ Significant business events    │ No              │
│  DEBUG │ Diagnostic detail              │ No (dev only)   │
│  TRACE │ Fine-grained flow tracking     │ No (dev only)   │
└──────────────────────────────────────────────────────────┘

Rules:
- Production: INFO and above only (DEBUG/TRACE disabled)
- Every ERROR log must include: error message, stack trace, context
- Every request must have a request_id for correlation
- Never log: passwords, tokens, PII, credit card numbers
- Always log: request start/end, external calls, business events
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
- [ ] Background job start/complete/fail
- [ ] Cache hits and misses
- [ ] Configuration changes
- [ ] Application startup and shutdown
- [ ] Health check failures
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
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-http': { enabled: true },
      '@opentelemetry/instrumentation-express': { enabled: true },
      '@opentelemetry/instrumentation-pg': { enabled: true },
      '@opentelemetry/instrumentation-redis': { enabled: true },
    }),
  ],
  serviceName: process.env.OTEL_SERVICE_NAME || 'api-service',
});

sdk.start();
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

W3C Trace Context Headers:
  traceparent: 00-abc123-span1-01
  tracestate: vendor=value
```

#### Trace Backend Options
```
TRACING BACKENDS:
┌──────────────────────────────────────────────────────────┐
│  Backend   │ Best for            │ Storage     │ Cost     │
│  ─────────────────────────────────────────────────────── │
│  Jaeger    │ Self-hosted, K8s    │ Elastic/    │ Infra    │
│            │                     │ Cassandra   │ only     │
│  Zipkin    │ Simple setups       │ In-memory/  │ Free     │
│            │                     │ MySQL       │          │
│  Tempo     │ Grafana ecosystem   │ Object      │ Low      │
│            │                     │ storage     │          │
│  X-Ray     │ AWS-native          │ Managed     │ Per-trace│
│  Datadog   │ Full-stack APM      │ Managed     │ Per-host │
│  Honeycomb │ High-cardinality    │ Managed     │ Per-event│
└──────────────────────────────────────────────────────────┘
```

### Step 5: SLO/SLI Definition
Define Service Level Objectives and Indicators:

```
SLO FRAMEWORK:
┌──────────────────────────────────────────────────────────┐
│  Service: <service-name>                                  │
├──────────────────────────────────────────────────────────┤
│  SLI                  │ Target    │ Window  │ Burn Rate  │
│  ─────────────────────────────────────────────────────── │
│  Availability         │ 99.9%     │ 30 days │ Budget:    │
│  (successful requests │           │         │ 43.2 min   │
│   / total requests)   │           │         │ downtime   │
│                       │           │         │            │
│  Latency (P95)        │ < 200ms   │ 30 days │ Budget:    │
│  (95th percentile     │           │         │ 0.1% of    │
│   request duration)   │           │         │ requests   │
│                       │           │         │ can exceed │
│                       │           │         │            │
│  Latency (P99)        │ < 1000ms  │ 30 days │ Budget:    │
│  (99th percentile)    │           │         │ 0.1% of    │
│                       │           │         │ requests   │
│                       │           │         │            │
│  Error Rate           │ < 0.1%    │ 30 days │ Budget:    │
│  (5xx / total)        │           │         │ 0.1% of    │
│                       │           │         │ requests   │
│                       │           │         │            │
│  Throughput           │ > 1000    │ 5 min   │ Alert if   │
│  (requests/sec)       │ rps       │         │ < 500 rps  │
└──────────────────────────────────────────────────────────┘

Error budget remaining: 85% (12.7 min consumed of 43.2 min)
```

#### SLO Burn Rate Alerts
```yaml
# Multi-window burn rate alert (recommended by Google SRE)
# Fast burn: 14.4x burn rate over 1 hour (consumes 2% of budget)
- alert: SLOHighBurnRate_Fast
  expr: |
    (
      sum(rate(http_requests_total{status_code=~"5.."}[1h]))
      / sum(rate(http_requests_total[1h]))
    ) > (14.4 * 0.001)
    and
    (
      sum(rate(http_requests_total{status_code=~"5.."}[5m]))
      / sum(rate(http_requests_total[5m]))
    ) > (14.4 * 0.001)
  labels:
    severity: critical
  annotations:
    summary: "High error burn rate — SLO budget depleting rapidly"

# Slow burn: 3x burn rate over 3 days (consumes 10% of budget)
- alert: SLOHighBurnRate_Slow
  expr: |
    (
      sum(rate(http_requests_total{status_code=~"5.."}[3d]))
      / sum(rate(http_requests_total[3d]))
    ) > (3 * 0.001)
    and
    (
      sum(rate(http_requests_total{status_code=~"5.."}[6h]))
      / sum(rate(http_requests_total[6h]))
    ) > (3 * 0.001)
  labels:
    severity: warning
  annotations:
    summary: "Elevated error rate — SLO budget being consumed"
```

### Step 6: Alert Rule Design
Create actionable, low-noise alerts:

#### Alert Design Principles
```
ALERT RULES:
┌──────────────────────────────────────────────────────────┐
│  Alert Name            │ Condition          │ Severity    │
│  ─────────────────────────────────────────────────────── │
│  HighErrorRate         │ 5xx > 1% for 5m    │ Critical    │
│  HighLatencyP95        │ P95 > 500ms for 5m │ Warning     │
│  HighLatencyP99        │ P99 > 2s for 5m    │ Critical    │
│  PodCrashLooping       │ restarts > 3 in 5m │ Critical    │
│  DiskSpaceLow          │ usage > 85%        │ Warning     │
│  DiskSpaceCritical     │ usage > 95%        │ Critical    │
│  MemoryHigh            │ usage > 90% for 5m │ Warning     │
│  CertExpiringSoon      │ < 7 days to expiry │ Warning     │
│  CertExpiring          │ < 1 day to expiry  │ Critical    │
│  DatabaseConnExhausted │ free conns < 5     │ Critical    │
│  QueueBacklog          │ depth > 1000       │ Warning     │
│  ErrorBudgetBurning    │ burn rate > 14.4x  │ Critical    │
└──────────────────────────────────────────────────────────┘

Every alert MUST have:
  1. Clear, descriptive name
  2. Actionable runbook link
  3. Appropriate severity (page vs. notify)
  4. Sufficient duration threshold (no flapping)
  5. Context in annotations (current value, threshold, affected service)
```

#### Prometheus Alert Rules
```yaml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status_code=~"5.."}[5m]))
          / sum(rate(http_requests_total[5m]))
          > 0.01
        for: 5m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "Error rate above 1% for 5 minutes"
          description: "Current error rate: {{ $value | humanizePercentage }}"
          runbook: "https://wiki.example.com/runbooks/high-error-rate"
          dashboard: "https://grafana.example.com/d/api-overview"

      - alert: HighLatencyP95
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
          ) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "P95 latency above 500ms"
          description: "Current P95: {{ $value | humanizeDuration }}"

      - alert: PodCrashLooping
        expr: |
          increase(kube_pod_container_status_restarts_total[5m]) > 3
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Pod {{ $labels.pod }} is crash-looping"
          description: "{{ $value }} restarts in the last 5 minutes"
```

### Step 7: Dashboard Design
Create dashboards following the Four Golden Signals:

```
DASHBOARD LAYOUT — Service Overview:
┌──────────────────────────────────────────────────────────┐
│  ROW 1: Golden Signals (top-level health)                 │
│  ┌─────────────┐ ┌─────────────┐ ┌────────┐ ┌─────────┐ │
│  │ Request Rate│ │ Error Rate  │ │Latency │ │Saturation│ │
│  │  1.2k rps   │ │   0.03%     │ │ 45ms   │ │  62%     │ │
│  │  ▁▂▃▅▆█▇▅  │ │  ▁▁▁▁▂▁▁▁  │ │▂▃▂▃▂▃▂│ │ ▃▄▅▅▄▃▄ │ │
│  └─────────────┘ └─────────────┘ └────────┘ └─────────┘ │
│                                                           │
│  ROW 2: SLO Status                                        │
│  ┌────────────────────────────────────────────────────┐   │
│  │ Availability SLO: 99.9% │ Current: 99.95% │ OK    │   │
│  │ Error Budget: 85% remaining │ 12.7 min consumed   │   │
│  │ Latency SLO: P95 < 200ms │ Current: 145ms │ OK    │   │
│  └────────────────────────────────────────────────────┘   │
│                                                           │
│  ROW 3: Request Breakdown                                 │
│  ┌──────────────────────┐ ┌──────────────────────────┐   │
│  │ By Status Code       │ │ By Endpoint              │   │
│  │  200: 95.2%          │ │  /api/users: 420 rps     │   │
│  │  201: 3.5%           │ │  /api/orders: 380 rps    │   │
│  │  400: 0.8%           │ │  /api/products: 250 rps  │   │
│  │  500: 0.03%          │ │  /healthz: 100 rps       │   │
│  └──────────────────────┘ └──────────────────────────┘   │
│                                                           │
│  ROW 4: Infrastructure                                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │ CPU      │ │ Memory   │ │ Pods     │ │ Network  │    │
│  │ 62%      │ │ 71%      │ │ 3/3      │ │ 45 MB/s  │    │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘    │
│                                                           │
│  ROW 5: Dependencies                                      │
│  ┌──────────────────────┐ ┌──────────────────────────┐   │
│  │ Database             │ │ Redis Cache              │   │
│  │  Connections: 12/100 │ │  Hit rate: 94.2%         │   │
│  │  Query P95: 8ms      │ │  Memory: 256Mi/512Mi     │   │
│  │  Slow queries: 0     │ │  Evictions: 0            │   │
│  └──────────────────────┘ └──────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
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

## Key Behaviors

1. **Three pillars are mandatory.** Metrics, logs, and traces are not optional. Each gives visibility that the others cannot.
2. **Structured logs only.** No `console.log("something happened")`. Every log entry must be structured JSON with consistent fields.
3. **Alerts must be actionable.** If an alert fires and the on-call cannot act on it, the alert is noise. Remove or fix it.
4. **SLOs drive decisions.** Error budget remaining determines whether you ship features or fix reliability. Define SLOs before you need them.
5. **Dashboards tell stories.** A dashboard is not a wall of graphs. It answers specific questions: "Is the service healthy?" "What changed?"
6. **Cardinality matters.** Do not use high-cardinality labels (user_id, request_id) on metrics. That is what logs and traces are for.
7. **Trace critical paths.** Not every function needs a span. Trace service boundaries, database calls, and external API calls.
8. **Never log secrets.** Sanitize logs before emission. Mask PII, redact tokens, exclude passwords.

## Example Usage

### Setting up observability for a new service
```
User: /godmode:observe Set up monitoring for our API

Observe: Assessing current observability...

OBSERVABILITY ASSESSMENT:
  Metrics: NONE — No instrumentation found
  Logging: BASIC — console.log only, unstructured
  Tracing: NONE — No trace headers propagated
  Overall: 1/10 — needs full instrumentation

Setting up three pillars...

1. METRICS — Added Prometheus client
   - 4 RED metrics (rate, errors, duration, in-flight)
   - 6 infrastructure metrics (CPU, memory, connections)
   - 3 business metrics (signups, orders, payments)
   - /metrics endpoint exposed

2. LOGGING — Structured JSON logging
   - Winston logger configured with JSON format
   - Request ID middleware for correlation
   - Log levels: ERROR, WARN, INFO (production)
   - Sensitive fields redacted

3. TRACING — OpenTelemetry
   - Auto-instrumentation for HTTP, Express, pg, redis
   - W3C trace context propagation
   - OTLP exporter configured

4. ALERTS — 8 alert rules created
   - HighErrorRate, HighLatency, PodCrashLoop, etc.
   - All alerts have runbook links

5. SLOs — Defined
   - Availability: 99.9% (30-day window)
   - Latency P95: < 200ms
   - Error budget tracking enabled

New observability score: 9/10
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full observability assessment and recommendations |
| `--metrics` | Set up metrics instrumentation only |
| `--logging` | Set up structured logging only |
| `--tracing` | Set up distributed tracing only |
| `--alerts` | Design alert rules only |
| `--slos` | Define SLO/SLI framework only |
| `--dashboard` | Design monitoring dashboards only |
| `--audit` | Assess current observability coverage |
| `--tool <name>` | Target specific tool (prometheus, datadog, cloudwatch, etc.) |

## HARD RULES

1. **NEVER ship without at least metrics + structured logging.** Tracing can be added later. Metrics and logs are day-one requirements.
2. **NEVER use `console.log` / `print` in production code.** All logging goes through the structured logger with consistent fields.
3. **NEVER put high-cardinality values in metric labels.** `user_id`, `request_id`, `trace_id` go in logs/traces, not metric labels. Violating this kills Prometheus/DataDog.
4. **NEVER create alerts without a `for` duration.** Minimum 5 minutes for warnings, 2 minutes for critical. No flapping alerts.
5. **NEVER log PII, tokens, passwords, or credit card numbers.** Sanitize before emission. This is non-negotiable.
6. **NEVER create a dashboard without stating the question it answers.** If you cannot name the question, the dashboard is noise.
7. **ALWAYS include `request_id` in every log entry.** Cross-request correlation is impossible without it.
8. **ALWAYS verify webhook/exporter endpoints are reachable before declaring setup complete.**

## Auto-Detection

Before starting any observability work, detect the existing setup:

```
AUTO-DETECT SEQUENCE:
1. Scan for existing instrumentation:
   - grep for prom-client, datadog, statsd, opentelemetry, newrelic imports
   - grep for winston, pino, bunyan, structlog, loguru, slog, zerolog
   - grep for @opentelemetry, jaeger-client, zipkin, dd-trace
   - check for /metrics endpoint in routes

2. Detect monitoring infrastructure:
   - ls prometheus.yml, docker-compose*monitoring*, grafana/
   - check for OTEL_EXPORTER_*, DD_API_KEY, NEW_RELIC_LICENSE_KEY in .env*
   - scan Kubernetes manifests for prometheus annotations

3. Detect alerting:
   - ls monitoring/alerts*, alertmanager*, pagerduty*
   - grep for alert rules in yaml files

4. Output: OBSERVABILITY ASSESSMENT table (Step 1) auto-populated
```

## Explicit Loop Protocol

Observability instrumentation is iterative -- each pillar may need multiple passes:

```
current_iteration = 0
pillars_remaining = [metrics, logging, tracing, alerts, slos, dashboards]

WHILE pillars_remaining is not empty AND current_iteration < 6:
    current_iteration += 1
    pillar = pillars_remaining.pop(0)

    1. ASSESS current state of this pillar
    2. IMPLEMENT instrumentation for this pillar
    3. VERIFY instrumentation produces output (curl /metrics, check logs, trace visible)
    4. IF verification fails:
        pillars_remaining.append(pillar)  # retry next round
    5. REPORT: "Pillar {pillar}: {DONE|RETRY} -- iteration {current_iteration}/6"

IF pillars_remaining is not empty:
    REPORT: "Incomplete pillars: {pillars_remaining}. Manual intervention needed."
```

## Multi-Agent Dispatch

For large systems with multiple services, dispatch parallel agents:

```
MULTI-AGENT OBSERVABILITY SETUP:
Dispatch 2-4 agents in parallel worktrees when instrumenting multiple services.

Agent 1 (worktree: observe-metrics):
  - Instrument all services with metrics (RED/USE)
  - Configure /metrics endpoints
  - Set up Prometheus scrape targets

Agent 2 (worktree: observe-logging):
  - Replace unstructured logging with structured JSON
  - Add request_id correlation middleware
  - Configure log aggregation (ELK/Loki)

Agent 3 (worktree: observe-tracing):
  - Add OpenTelemetry auto-instrumentation
  - Configure trace propagation headers
  - Verify end-to-end trace visibility

Agent 4 (worktree: observe-alerts):
  - Define SLOs and error budgets
  - Create Prometheus alert rules
  - Build Grafana dashboards

MERGE ORDER: metrics -> logging -> tracing -> alerts (each depends on prior)
CONFLICT ZONES: middleware registration order, config files, docker-compose ports
```

## Anti-Patterns

- **Do NOT alert on symptoms without context.** "CPU is high" is not actionable. "CPU is high on api-server causing P95 latency > 500ms" is actionable.
- **Do NOT use unstructured logs.** `console.log("error: " + err)` is unsearchable and unparseable. Use structured JSON with consistent fields.
- **Do NOT create metric labels with unbounded cardinality.** Adding `user_id` as a Prometheus label creates millions of time series and kills your monitoring.
- **Do NOT set alerts without `for` duration.** Instant alerts cause flapping. Require the condition to persist (typically 5 minutes).
- **Do NOT log PII or secrets.** Audit every log statement. Mask email addresses, redact tokens, exclude passwords.
- **Do NOT build dashboards without a question.** "What does this dashboard answer?" If you cannot state the question, the dashboard is noise.
- **Do NOT skip trace context propagation.** If service A calls service B but the trace breaks, you lose visibility into the most critical part of the request.
- **Do NOT ignore error budget.** When the error budget is depleted, stop shipping features and fix reliability. That is the whole point of SLOs.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run observability tasks sequentially: metrics, then logging, then tracing, then alerts.
- Use branch isolation per task: `git checkout -b godmode-observe-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
