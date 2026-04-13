---
name: logging
description: |
  Structured logging skill. JSON logs, log levels,
  correlation IDs, PII redaction, log aggregation,
  retention policies. ELK/Loki/CloudWatch pipelines.
  Triggers on: /godmode:logging, "structured logging",
  "log levels", "correlation ID", "PII redaction".
---

# Logging — Structured Logging

## Activate When
- User invokes `/godmode:logging`
- User says "structured logging", "JSON logs"
- User says "log levels", "correlation ID", "trace ID"
- User says "log aggregation", "ELK", "Loki"
- User needs PII redaction or compliance-aware logging

## Workflow

### Step 1: Logging Assessment

```bash
# Detect current logging state
grep -rn "console\.log\|console\.error" src/ \
  --include="*.ts" 2>/dev/null | wc -l
grep -rn "log\.Println\|fmt\.Println" . \
  --include="*.go" 2>/dev/null | wc -l
grep -rn "print(\|logging\." . \
  --include="*.py" 2>/dev/null | wc -l

# Check for structured loggers
grep -r "pino\|winston\|structlog\|zerolog\|slog" \
  package.json go.mod pyproject.toml 2>/dev/null
```

```
LOGGING ASSESSMENT:
| Aspect      | Status                    |
|-------------|---------------------------|
| Format      | Unstructured / JSON       |
| Levels      | info/error only / full    |
| Context     | requestId, userId present?|
| Correlation | traceId propagated?       |
| PII         | Redacted / exposed        |
| Aggregation | stdout / ELK / Loki       |
| Retention   | Configured / none         |

IF unstructured: migrate to JSON logger
IF no correlation IDs: add middleware
IF PII in logs: add redaction layer
IF no retention policy: configure rotation
```

### Step 2: Log Level Strategy

```
| Level | When to Use                  |
|-------|------------------------------|
| FATAL | Process cannot continue      |
| ERROR | Operation failed, process OK |
| WARN  | Degraded but functional      |
| INFO  | Business events, milestones  |
| DEBUG | Diagnostic detail            |

THRESHOLDS:
  Production default: INFO
  DEBUG in prod: only when explicitly enabled
  IF 404/validation fail logged as ERROR: fix to WARN
  IF > 100 ERROR/min sustained: investigate
  IF DEBUG enabled in prod > 1 hour: auto-disable
```

### Step 3: Structured Logging Implementation

```
STRUCTURED LOG FORMAT (JSON):
{
  "timestamp": "ISO 8601 with timezone",
  "level": "info",
  "service": "<name>",
  "environment": "<env>",
  "version": "<semver>",
  "requestId": "<uuid>",
  "traceId": "<uuid>",
  "message": "<event description>",
  "data": { <structured fields> }
}

LIBRARIES:
  Node.js: pino (async, fast, JSON native)
  Go: slog (stdlib) or zerolog (zero-alloc)
  Python: structlog (processor pipeline)

RULES:
  Always structured fields, never string interpolation
  Always ISO 8601 timestamps with timezone
  Always include service, environment, version
  IF log line > 10KB: truncate request/response
```

### Step 4: Correlation IDs

```
IDs:
  requestId — unique per HTTP request (edge-generated)
  traceId — spans entire distributed transaction
  spanId — unique per operation within a trace

PROPAGATION:
  Incoming: read X-Request-Id, X-Trace-Id headers
  IF missing: generate UUIDv4
  Outgoing: forward in headers to downstream
  Logging: include in every log line via context

OPENTELEMETRY:
  Auto-instrument with @opentelemetry/sdk-node
  Export traces to Jaeger/Zipkin/OTLP collector
  Correlate logs with traces via traceId
```

### Step 5: PII Redaction

```
PII REDACTION POLICY:
| Data Type     | Action    | Technique          |
|---------------|-----------|--------------------|
| Email         | MASK      | j***@example.com   |
| Phone         | MASK      | +1-***-***-5678    |
| Credit card   | REDACT    | [REDACTED]         |
| CVV/password  | NEVER LOG | —                  |
| SSN           | REDACT    | [REDACTED]         |
| IP address    | ANONYMIZE | 192.168.1.0/24     |

THRESHOLDS:
  IF any NEVER LOG field found in logs: P0 fix
  IF PII regex match rate > 0 in prod: alert
  Redaction must happen at logger level,
    not at call site (prevents human error)
```

### Step 6: Log Aggregation

```
PIPELINES:
  ELK: App → stdout → Filebeat → Logstash → ES → Kibana
  Loki: App → stdout → Promtail → Loki → Grafana
  CloudWatch: App → stdout → CW Agent → Insights

IF high volume (> 10K events/s): use Loki (cheaper)
IF need full-text search: use ELK
IF AWS-native: use CloudWatch
```

### Step 7: Retention & Performance

```
RETENTION POLICY:
| Env        | Level | Retention | Tier          |
|------------|-------|-----------|---------------|
| Production | ERROR | 365 days  | Hot→Warm→Cold |
| Production | WARN  | 90 days   | Hot→Warm      |
| Production | INFO  | 30 days   | Hot           |
| Production | DEBUG | 7 days    | On-demand only|
| Staging    | All   | 14 days   | Hot           |
| Dev        | All   | 3 days    | Hot           |
| Compliance | Audit | 7 years   | Hot→Archive   |

PERFORMANCE:
  Use async loggers (pino, slog, structlog)
  Buffer and flush periodically
  Sample DEBUG logs (1 in 100) at high volume
  Max message size: 10KB
  IF synchronous logging in hot path: refactor
```

### Step 8: Verification Checklist

```
| Check                              | Pass? |
|------------------------------------|-------|
| All logs structured JSON in prod   |       |
| ISO 8601 timestamps with timezone  |       |
| Consistent field names across svcs |       |
| Log level strategy documented      |       |
| No ERROR for expected conditions   |       |
| DEBUG disabled in prod by default  |       |
| Correlation IDs on every line      |       |
| PII redacted at logger level       |       |
| Retention policy configured        |       |
| Async logging in hot paths         |       |
```

Commit: `"logging: <service> — structured JSON
  with correlation IDs and PII redaction"`

## Key Behaviors
Never ask to continue. Loop autonomously until done.

1. **Structured JSON in production.** Always.
2. **Correct log levels.** 404 is not ERROR.
3. **Correlation IDs everywhere.** Every log line.
4. **PII redaction at logger level.** Not call site.
5. **Async writing.** Never block the event loop.
6. **Runtime log level control.** No redeploy needed.

<!-- tier-3 -->

## Quality Targets
- Log write latency: <5ms per entry
- Retention: >30 days for app logs
- Max line size: <10KB

## HARD RULES
1. Never use console.log in production.
2. Never log at ERROR for expected conditions.
3. Never log passwords, tokens, credit cards, SSN.
4. Never use string interpolation for structured data.
5. Never log at every function entry/exit.
6. Never use synchronous file writes in hot paths.
7. Never deploy without correlation IDs.
8. Always use JSON format in production.
9. Always include service, env, version, timestamp.
10. Always make log level configurable at runtime.

## Auto-Detection
```
1. Unstructured: console.log, log.Println, print()
2. Structured: pino/winston, slog/zerolog, structlog
3. Libraries: package.json, go.mod, pyproject.toml
```

## Quality Targets
- Target: <5ms per structured log write
- Log retention: >=30 days for application logs
- Max log line size: <10KB
- Target: 0 PII fields in log output (redaction enforced)

## Output Format
Print: `Logging: {N} services. Format: JSON.
  Correlation: {status}. PII: {status}.
  Retention: {policy}. Verdict: {verdict}.`

## TSV Logging
```
iteration	task	services_configured	format	correlation_ids	pii_redacted	retention_days	status
```

## Keep/Discard Discipline
```
KEEP if: valid JSON AND required fields present
  AND PII redacted AND no performance regression
DISCARD if: malformed output OR missing fields
  OR PII leaked OR blocks event loop
```

## Stop Conditions
```
STOP when ANY of:
  - All services produce structured JSON with IDs
  - PII redaction verified with test data
  - Log aggregation pipeline receiving logs
  - User requests stop
```

## Error Recovery
- Unstructured after migration: grep for console.log.
- Missing correlation IDs: check middleware ordering.
- Volume too high: audit levels, sample DEBUG.
- PII found: add redaction filters, use allowlists.
- Not in aggregator: check agent, network, rotation.

