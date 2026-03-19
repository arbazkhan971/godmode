# Recipe: Setting Up Full Observability

> From flying blind to complete system visibility. Metrics, logs, traces, alerts, and dashboards — the full observability stack.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `observe → logging → errortrack → reliability → deploy` |
| **Timeline** | 2-4 days for core observability, ongoing refinement |
| **Team size** | 1-2 developers (SRE or backend) |
| **Example project** | "ShopStream" — an e-commerce platform instrumented with full observability |

---

## Prerequisites

- Running application (any language/framework)
- Container orchestration (Docker Compose or Kubernetes)
- Godmode installed and configured

---

## The Three Pillars (Plus Two)

| Pillar | What It Answers | Tool |
|--------|----------------|------|
| **Metrics** | "Is the system healthy right now?" | Prometheus + Grafana |
| **Logs** | "What happened at this specific moment?" | Loki or ELK Stack |
| **Traces** | "What was the path of this request?" | Jaeger or Tempo via OpenTelemetry |
| **Alerts** | "When should a human be notified?" | Alertmanager or PagerDuty |
| **SLOs** | "Are we meeting our promises to users?" | Prometheus + custom dashboards |

---

## Technology Recommendations

| Approach | Stack | Best For |
|----------|-------|----------|
| Open source (self-hosted) | Prometheus + Grafana + Loki + Tempo + Alertmanager | Full control, no per-seat cost |
| Open source (managed) | Grafana Cloud (free tier: 10K metrics, 50GB logs) | Open source tools, no infra management |
| Cloud-native (AWS) | CloudWatch + X-Ray | Already on AWS, minimal setup |
| Cloud-native (GCP) | Cloud Monitoring + Cloud Trace | Already on GCP, tight integration |
| Commercial | Datadog or New Relic | Enterprise support, single pane of glass |

This recipe uses the open-source stack. The instrumentation patterns apply regardless of backend.

---

## Session Transcript

### Phase 1: Observe — Instrument the Application

```
> /godmode:observe Our e-commerce platform "ShopStream" has no monitoring.
  We have a Node.js API, a React frontend, a PostgreSQL database, and a
  Redis cache. We deploy on Kubernetes. We need metrics, logs, and traces.

Godmode: Analyzing application stack... Designing observability...

OBSERVABILITY PLAN:

1. Application Metrics (Prometheus)

  HTTP metrics (RED method):
    - http_requests_total (counter) — rate
    - http_request_duration_seconds (histogram) — duration
    - http_requests_errors_total (counter) — errors
    Labels: method, path, status_code

  Business metrics:
    - orders_created_total (counter)
    - orders_revenue_total (counter, in cents)
    - cart_abandoned_total (counter)
    - product_search_duration_seconds (histogram)
    - payment_processing_duration_seconds (histogram)
    - active_sessions_gauge (gauge)

  Infrastructure metrics:
    - nodejs_heap_used_bytes (gauge)
    - nodejs_event_loop_lag_seconds (histogram)
    - db_pool_active_connections (gauge)
    - db_pool_idle_connections (gauge)
    - db_query_duration_seconds (histogram)
    - redis_commands_total (counter)
    - redis_command_duration_seconds (histogram)

2. Structured Logging (JSON → Loki)

  Log format:
    {
      "level": "info",
      "message": "Order created",
      "timestamp": "2025-01-15T10:23:45.123Z",
      "traceId": "abc123",
      "spanId": "def456",
      "service": "shopstream-api",
      "orderId": "ord_789",
      "customerId": "cust_012",
      "total": 9999,
      "duration_ms": 234
    }

  Log levels:
    error  — unhandled exceptions, failed payments, data corruption
    warn   — degraded performance, retry attempts, cache misses
    info   — business events (order created, user login, payment processed)
    debug  — request/response details (disabled in production)

3. Distributed Tracing (OpenTelemetry → Tempo)

  Trace spans:
    API request → database query → Redis lookup → external API call
    Each span includes: service name, operation, duration, status, attributes

  Propagation:
    W3C Trace Context headers (traceparent, tracestate)
    Automatic propagation through HTTP clients and message queues

Files created:
  src/observability/metrics.ts        — Prometheus metrics registry
  src/observability/logger.ts         — Structured JSON logger with trace context
  src/observability/tracing.ts        — OpenTelemetry SDK setup
  src/middleware/request-metrics.ts   — HTTP metrics middleware
  src/middleware/request-logger.ts    — Request/response logging middleware
  src/middleware/trace-context.ts     — Trace propagation middleware

Commit: "observe: instrument ShopStream — metrics, structured logging, distributed tracing"
```

**Time: 45 minutes.**

### Phase 2: Logging — Configure Log Aggregation

```
> /godmode:logging

Godmode: Setting up log aggregation pipeline...

LOGGING PIPELINE:

Architecture:
  Application → stdout (JSON) → Container runtime → Promtail → Loki → Grafana

  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │  App     │    │ Promtail │    │   Loki   │    │ Grafana  │
  │ (stdout) │──→ │ (agent)  │──→ │ (store)  │──→ │ (query)  │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘

Why stdout, not files:
  - Container-native (12-factor app)
  - Kubernetes captures stdout automatically
  - No log rotation to manage
  - Promtail picks up from container runtime

Loki configuration:
  Retention: 30 days (production), 7 days (staging)
  Index: by service, level, traceId
  Storage: S3-compatible object storage

Log enrichment:
  - Every log line gets: traceId, spanId, service name, environment
  - Business events get: entity IDs (orderId, customerId, productId)
  - Error logs get: stack trace, request context, user context

Useful LogQL queries:
  # Error rate by service in last hour
  sum(rate({service="shopstream-api"} | json | level="error" [1h])) by (service)

  # Slow orders (processing > 5 seconds)
  {service="shopstream-api"} | json | message="Order created" | duration_ms > 5000

  # All logs for a specific trace
  {service=~"shopstream.*"} | json | traceId="abc123"

  # Payment failures with context
  {service="shopstream-api"} | json | level="error" | message=~".*payment.*"

Files created:
  infra/promtail/config.yml           — Promtail scrape config
  infra/loki/config.yml               — Loki storage and retention config
  src/observability/logger.ts          — Updated with enrichment
  docs/runbooks/log-queries.md         — Common LogQL queries

Commit: "logging: Promtail + Loki pipeline — structured JSON, 30-day retention"
```

**Time: 30 minutes.**

### Phase 3: Error Tracking — Aggregate and Analyze Errors

```
> /godmode:errortrack

Godmode: Setting up error tracking and analysis...

ERROR TRACKING SETUP:

Error classification:
  Category 1: Infrastructure errors
    - Database connection failures
    - Redis timeouts
    - Network errors to external services
    Action: alert on rate > threshold, auto-retry

  Category 2: Application errors
    - Unhandled exceptions
    - Validation errors (should be caught, indicates bug)
    - Null reference errors
    Action: alert immediately, create bug ticket

  Category 3: Business logic errors
    - Payment declined
    - Inventory unavailable
    - Rate limit exceeded
    Action: log and track, alert on unusual spike

  Category 4: Client errors
    - Invalid input (400)
    - Authentication failures (401)
    - Not found (404)
    Action: track for abuse patterns, no alert unless spike

Error aggregation:
  - Group by: error message fingerprint (normalized stack trace)
  - Track: first seen, last seen, occurrence count, affected users
  - Deduplicate: same error from same source within 5 minutes

Error budget:
  Target error rate: 0.1% (99.9% success rate)
  Monthly budget: 43.2 minutes of errors
  Current burn rate: tracked in real-time dashboard

  Budget states:
    GREEN  — burn rate < 1x (on track to stay within budget)
    YELLOW — burn rate 1-2x (will exhaust budget early, investigate)
    RED    — burn rate > 2x (budget at risk, immediate action required)

Alerting integration:
  - New error type (never seen before) → Slack immediately
  - Error rate spike (3x normal) → Slack + PagerDuty
  - Error budget burn rate > 2x → PagerDuty
  - Specific errors: payment failures → #payments Slack channel

Files created:
  src/observability/error-tracker.ts       — error classification and aggregation
  src/observability/error-budget.ts        — error budget calculation
  src/middleware/error-handler.ts          — global error handler with classification
  infra/grafana/dashboards/errors.json    — error dashboard

Commit: "errortrack: error classification, aggregation, and budget tracking"
```

**Time: 30 minutes.**

### Phase 4: Reliability — Define SLOs and Alerts

```
> /godmode:reliability

Godmode: Defining SLOs, SLIs, and alerting rules...

SERVICE LEVEL OBJECTIVES:

SLO 1: Availability
  SLI: Proportion of successful HTTP requests (status < 500)
  Target: 99.9% over 30-day rolling window
  Budget: 43.2 minutes of downtime per month
  Alert: Burn rate > 2x for 5 minutes → PagerDuty

SLO 2: Latency
  SLI: Proportion of requests completed within threshold
  Targets:
    p50 < 100ms (target: 99% of requests)
    p95 < 500ms (target: 95% of requests)
    p99 < 1000ms (target: 99% of requests)
  Alert: p99 > 2000ms for 10 minutes → PagerDuty

SLO 3: Order Processing
  SLI: Proportion of orders successfully processed within 30 seconds
  Target: 99.95% over 30-day rolling window
  Alert: Success rate < 99% for 5 minutes → PagerDuty

SLO 4: Payment Processing
  SLI: Proportion of payment attempts that succeed or fail gracefully
  Target: 99.99% (excludes legitimate declines)
  Alert: Unexpected payment errors > 0.1% → PagerDuty

ALERTING RULES:

Tier 1 — PagerDuty (wake someone up):
  - Service down (health check failing for 2 minutes)
  - Error rate > 5% for 5 minutes
  - SLO burn rate > 10x for 5 minutes (fast burn)
  - SLO burn rate > 2x for 60 minutes (slow burn)
  - Payment processing failures > 1%
  - Database connection pool exhausted

Tier 2 — Slack #alerts (investigate soon):
  - Error rate > 1% for 10 minutes
  - p99 latency > 2 seconds for 15 minutes
  - Disk usage > 80%
  - Certificate expiring within 14 days
  - Dependency degraded (external API slow)

Tier 3 — Slack #monitoring (informational):
  - Deployment completed
  - Scaling event (pods added/removed)
  - Daily SLO status report
  - Weekly error budget summary

Alert hygiene rules:
  - Every alert must have a runbook link
  - No alert should fire more than once per hour (group/dedupe)
  - Every PagerDuty alert reviewed in weekly reliability meeting
  - Noisy alerts (> 5 fires/week with no action) are deleted or fixed

Files created:
  infra/prometheus/alerts/availability.yml     — availability SLO alerts
  infra/prometheus/alerts/latency.yml          — latency SLO alerts
  infra/prometheus/alerts/business.yml         — business metric alerts
  infra/prometheus/alerts/infrastructure.yml   — resource alerts
  infra/grafana/dashboards/slo.json           — SLO dashboard
  docs/runbooks/alert-playbook.md              — response procedures per alert

Commit: "reliability: SLOs, SLIs, multi-tier alerting with runbooks"
```

**Time: 45 minutes.**

### Phase 5: Deploy — Deploy the Observability Stack

```
> /godmode:deploy --target observability-stack

Godmode: Deploying observability infrastructure to Kubernetes...

DEPLOYMENT:

Components deployed:
  Prometheus:
    - 2 replicas with 15-day local retention
    - ServiceMonitor for automatic target discovery
    - Recording rules for SLO calculations
    - Alert rules from Phase 4

  Grafana:
    - 1 replica with persistent storage
    - Datasources: Prometheus, Loki, Tempo
    - Dashboards: pre-provisioned from JSON

  Loki:
    - Single binary mode (scales to ~100GB/day)
    - S3 backend for chunk storage
    - 30-day retention

  Tempo:
    - Distributed tracing backend
    - S3 backend for trace storage
    - 7-day retention

  Promtail:
    - DaemonSet on every node
    - Scrapes all pod logs automatically
    - Labels: namespace, pod, container

  Alertmanager:
    - 2 replicas for high availability
    - Routes: PagerDuty, Slack #alerts, Slack #monitoring
    - Silences and inhibition rules configured

  OpenTelemetry Collector:
    - DaemonSet for trace collection
    - Receives OTLP from applications
    - Forwards to Tempo

Kubernetes resources:
  infra/k8s/monitoring/namespace.yml
  infra/k8s/monitoring/prometheus/
  infra/k8s/monitoring/grafana/
  infra/k8s/monitoring/loki/
  infra/k8s/monitoring/tempo/
  infra/k8s/monitoring/promtail/
  infra/k8s/monitoring/alertmanager/
  infra/k8s/monitoring/otel-collector/

Dashboards provisioned:
  1. Service Overview   — RED metrics for all services
  2. SLO Dashboard      — burn rates, error budgets, compliance
  3. Error Dashboard    — error classification, trends, budget
  4. Database Dashboard — query performance, connections, replication
  5. Redis Dashboard    — hit rate, memory, command latency
  6. Infrastructure     — CPU, memory, disk, network per pod
  7. Business Dashboard — orders, revenue, cart abandonment

Verification:
  ✓ Prometheus scraping 12 targets
  ✓ Grafana dashboards loading
  ✓ Loki receiving logs from all pods
  ✓ Tempo receiving traces
  ✓ Alertmanager routing test alert to Slack
  ✓ SLO calculations producing correct values

Commit: "deploy: full observability stack — Prometheus, Grafana, Loki, Tempo, Alertmanager"
```

**Time: 1-2 hours.**

---

## Dashboard Design Principles

### The Four Golden Signals (Google SRE)

Every service dashboard should show:

| Signal | Metric | What to Watch |
|--------|--------|--------------|
| **Latency** | Request duration histogram | p50, p95, p99 — look for divergence between them |
| **Traffic** | Requests per second | Normal patterns and anomalies |
| **Errors** | Error rate (5xx / total) | Absolute count AND rate — both matter |
| **Saturation** | Resource utilization | CPU, memory, connections — approaching limits |

### Dashboard Hierarchy

```
Level 1: Service Overview (executive view)
  "Is everything OK?"
  One row per service: status, error rate, latency, traffic

Level 2: Service Detail (engineering view)
  "What is wrong with this service?"
  RED metrics, dependency health, resource usage

Level 3: Debug Detail (incident view)
  "Why is this specific thing broken?"
  Individual request traces, log correlation, query performance
```

---

## Observability Maturity Levels

| Level | Capability | You Can Answer |
|-------|-----------|----------------|
| 0 — None | No monitoring | "Is the site up?" (only if users complain) |
| 1 — Basic | Health checks + uptime monitoring | "Is the site up?" (automatically) |
| 2 — Metrics | Prometheus + basic dashboards | "Is the system healthy?" |
| 3 — Logs | Structured logging + aggregation | "What happened at 3:42 PM?" |
| 4 — Traces | Distributed tracing | "Why was this specific request slow?" |
| 5 — SLOs | Error budgets + burn rate alerts | "Are we meeting our promises to users?" |
| 6 — Proactive | Anomaly detection + capacity planning | "Will we have a problem next week?" |

This recipe takes you to Level 5. Level 6 requires ML-based anomaly detection, which is a separate effort.

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| Alert fatigue | Too many low-value alerts | `/godmode:reliability` enforces tiered alerts with runbooks |
| Dashboard sprawl | Everyone creates dashboards | Hierarchy: overview → detail → debug |
| Missing correlation | Cannot link metrics to logs to traces | Trace ID in all three pillars |
| Cardinality explosion | High-cardinality labels on metrics | `/godmode:observe` restricts labels to bounded sets |
| No error budget | Alerts on symptoms, not SLO impact | `/godmode:reliability` defines SLOs with burn rate alerts |
| Log noise | Logging everything at INFO | Log level policy: business events at INFO, details at DEBUG |

---

## Custom Chain for Observability

```yaml
# .godmode/chains.yaml
chains:
  add-monitoring:
    description: "Add observability to a new service"
    steps:
      - observe        # instrument the service
      - logging        # configure log pipeline
      - errortrack     # set up error tracking
      - reliability    # define SLOs and alerts
      - deploy         # deploy updated configs

  incident-investigate:
    description: "Investigate a production incident using observability"
    steps:
      - incident       # classify severity, start timeline
      - observe        # check dashboards and metrics
      - debug          # trace the root cause
      - fix            # implement the fix
      - ship           # deploy the fix
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [From Docker to Kubernetes](docker-k8s.md) — Deploying the observability stack on K8s
- [Incident Response Recipe](incident-response.md) — Using observability during incidents
- [Building an Event System](event-system.md) — Monitoring event-driven architectures
