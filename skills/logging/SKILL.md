---
name: logging
description: |
  Logging and structured logging skill. Activates when user needs to implement structured logging, define log level strategies, set up log aggregation, add request tracing with correlation IDs, handle PII redaction, or configure log retention and rotation. Covers JSON logging, ELK/Loki/CloudWatch pipelines, distributed tracing, and compliance-aware logging. Triggers on: /godmode:logging, "structured logging", "log levels", "correlation ID", "trace ID", "log aggregation", "PII redaction", or when observe skill needs logging implementation.
---

# Logging — Logging & Structured Logging

## When to Activate
- User invokes `/godmode:logging`
- User says "structured logging", "JSON logs", "log format"
- User says "log levels", "correlation ID", "trace ID", "request tracing"
- User says "log aggregation", "ELK", "Loki", "CloudWatch Logs"
- User asks "how should I log?" or "what log level should this be?"
- User needs PII redaction in logs or compliance-aware logging
- Observe skill needs logging implementation details
- Code review flags inconsistent logging or missing context

## Workflow

### Step 1: Logging Assessment
Evaluate the current state of logging:

```
LOGGING ASSESSMENT:
| Aspect | Status | Current State |
|---|---|---|
| Format | POOR | Unstructured console.log |
| Log Levels | PARTIAL | info/error only |
| Context | NONE | No request IDs or user IDs |
| Correlation | NONE | No trace/correlation IDs |
| Aggregation | NONE | stdout only, no pipeline |
| PII Handling | NONE | Sensitive data in logs |
| Retention Policy | NONE | No rotation or archival |
| Performance | UNKNOWN | Synchronous logging |
  Overall Score: 1/10 — INSUFFICIENT
  Priority: Structured format + correlation IDs
```

### Step 2: Log Level Strategy
Define when to use each log level:

```
LOG LEVEL STRATEGY:
| Level | When to Use | Examples |
|---|---|---|
| FATAL | Process cannot continue. | Startup failure |
|  | Requires immediate human | Out of memory |
|  | intervention. Process exits. | Uncaught exception |
|  |  | Critical config |
|  |  | missing |
| ERROR | Operation failed. The specific | Payment API 500 |
|  | request/task cannot be | Database query fail |
|  | completed, but the process | File write failed |
|  | continues serving others. | Auth token invalid |
```

### Step 3: Structured Logging Implementation
Replace unstructured string logs with structured JSON:

#### Why Structured Logging
```
UNSTRUCTURED (BAD):
  2024-01-15 10:23:45 ERROR Payment failed for order 12345 by user john@example.com amount $99.99

Problems:
  - Can't search by orderId without regex
  - Can't aggregate by error type
  - Can't filter by user without parsing the string
  - PII (email) embedded in free text — can't redact
  - Different developers format differently

STRUCTURED (GOOD):
  {
    "timestamp": "2024-01-15T10:23:45.123Z",
    "level": "error",
    "message": "Payment failed",
```

#### Implementation — Node.js (pino)
```javascript
const pino = require('pino');

// Create the logger
const logger = pino({
  level: process.env.LOG_LEVEL || 'info',

# ... (condensed)
```

#### Implementation — Go (slog)
```go
package logger

import (
    "context"
    "log/slog"
    "os"
# ... (condensed)
```

#### Implementation — Python (structlog)
```python
import structlog
import logging
import uuid
from functools import wraps

# Configure structlog
# ... (condensed)
```

### Step 4: Correlation IDs and Request Tracing
Implement end-to-end request tracing across services:

#### Correlation ID Strategy
```
CORRELATION ID STRATEGY:

IDs:
  requestId  — Unique per HTTP request. Generated at the edge (API gateway/LB).
  traceId    — Spans the entire distributed transaction. Same across all services.
  spanId     — Unique per operation within a trace. Parent-child relationships.
  sessionId  — Ties requests to a user session (optional).

Flow:
  Client → API Gateway → Service A → Service B → Database
    │          │             │            │           │
| Generate: |  |  |
|---|---|---|
| requestId=req_001 |  |  |
| traceId=trace_xyz |  |  |
    │          │             │            │           │
```

#### Implementation — Propagation Middleware
```javascript
// Correlation ID middleware — generates or propagates IDs
function correlationMiddleware(req, res, next) {
  // Propagate from upstream or generate new
  req.id = req.headers['x-request-id'] || generateId('req');
  req.traceId = req.headers['x-trace-id'] || generateId('trace');
  req.spanId = generateId('span');
# ... (condensed)
```

#### OpenTelemetry Integration
```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { OTLPLogExporter } = require('@opentelemetry/exporter-logs-otlp-http');

const sdk = new NodeSDK({
# ... (condensed)
```

### Step 5: PII Redaction in Logs

#### PII Redaction Strategy
```
PII REDACTION POLICY:
| Data Type | Action | Technique |
|---|---|---|
| Email address | MASK | j***@example.com |
| Phone number | MASK | +1-***-***-5678 |
| Credit card number | REDACT | [REDACTED] |
| CVV | NEVER LOG | — |
| Password / secret | NEVER LOG | — |
| SSN / National ID | REDACT | [REDACTED] |
| IP address | ANONYMIZE | 192.168.1.0/24 |
| Full name | MASK | J*** D*** |
| Date of birth | MASK | ****-**-15 |
| Home address | REDACT | [REDACTED] |
| Auth token / JWT | TRUNCATE | eyJhb....[TRUNCATED] |
```

#### Implementation — Redaction Utilities
```javascript
// PII redaction utilities
const redactor = {
  email(value) {
    if (!value || typeof value !== 'string') return value;
    const [local, domain] = value.split('@');
    if (!domain) return '[REDACTED_EMAIL]';
# ... (condensed)
```

### Step 6: Log Aggregation Architecture

#### ELK Stack (Elasticsearch, Logstash, Kibana)
```
ELK STACK PIPELINE:

Application → stdout (JSON) → Filebeat → Logstash → Elasticsearch → Kibana
                                  │
                            ┌─────┴──────┐
  Filebeat
  - Tails
  log files
  - Adds
  metadata
  - Buffers
  & ships
                            └─────┬──────┘
                                  ↓
```

#### Grafana Loki (Lightweight Alternative)
```
LOKI PIPELINE:

Application → stdout (JSON) → Promtail → Loki → Grafana
                                  │
                            ┌─────┴──────┐
  Promtail
  - Discovers
  targets
  - Extracts
  labels
  - Ships
                            └─────┬──────┘
                                  ↓
  Loki
```

#### AWS CloudWatch Logs
```
CLOUDWATCH PIPELINE:

Application → stdout → CloudWatch Agent → CloudWatch Logs → Insights
                              or
Application → AWS SDK → CloudWatch Logs directly

CloudWatch Insights query examples:
  # All errors in the last hour
  fields @timestamp, @message
  | filter level = "error"
  | sort @timestamp desc
  | limit 100

  # Error rate by service
  stats count(*) as errorCount by service
```

### Step 7: Log Retention and Rotation

```
LOG RETENTION POLICY:
| Environment | Log Level | Retention | Storage Tier |
|---|---|---|---|
| Production | ERROR | 365 days | Hot (30d) → Warm (90d) |
|  |  |  | → Cold (365d) |
| Production | WARN | 90 days | Hot (30d) → Warm (90d) |
| Production | INFO | 30 days | Hot (30d) |
| Production | DEBUG | 7 days | Hot (7d) — only when |
|  |  |  | explicitly enabled |
| Staging | All | 14 days | Hot (14d) |
| Development | All | 3 days | Hot (3d) |
| Compliance | Audit logs | 7 years | Hot (90d) → Archive |
```

### Step 8: Logging Performance

```
LOGGING PERFORMANCE GUIDELINES:
| Concern | Solution |
|---|---|
| Synchronous I/O | Use async loggers (pino, slog) |
| blocks event loop | Buffer and flush periodically |
| High-volume logging | Sample DEBUG logs (1 in 100) |
| causes CPU pressure | Don't stringify objects you won't |
|  | log (check level first) |
| Large log messages | Set max message size (10KB) |
|  | Truncate request/response bodies |
| Disk fill from logs | Rotation + retention policy |
```

### Step 9: Logging Checklist

```
LOGGING VERIFICATION CHECKLIST:
| Category | Check | Pass? |
|---|---|---|
| Format |  |  |
| [ ] All logs are structured JSON in production |  |
| [ ] ISO 8601 timestamps with timezone |  |
| [ ] Consistent field names across all services |  |
| [ ] Base fields: service, environment, version |  |
| Levels |  |  |
| [ ] Log level strategy documented and followed |  |
| [ ] No ERROR logs for expected conditions (404) |  |
| [ ] DEBUG disabled in production by default |  |
| [ ] Log level configurable at runtime |  |
```

## Output
- Logging design at `docs/logging/<service>-logging.md`
- Logger configuration in service source directory
- Commit: `"logging: <service> — structured logging with <features> (<coverage>)"`

## HARD RULES
1. NEVER use `console.log` in production — use a structured logger (pino, slog, structlog).
2. NEVER log at ERROR level for expected conditions (404, validation failure) — these are WARN or INFO.
3. NEVER log sensitive data (passwords, tokens, credit cards, SSN) — redact at the logger level.
4. NEVER use string interpolation for structured data — use structured fields (`{ orderId, userId }` not `"order ${id}"`).
5. NEVER log at every function entry/exit — log at boundaries (HTTP, queue, service) not inside every function.
6. NEVER use synchronous file writes for logging in hot paths — use async loggers with buffered output.
7. NEVER deploy without correlation IDs — include requestId and traceId in every log line within a request.
8. ALWAYS use JSON format in production — machine-parseable, searchable, aggregatable.
9. ALWAYS include base fields in every log line: service, environment, version, timestamp (ISO 8601).
10. ALWAYS make log level configurable at runtime — enable DEBUG for specific modules during incidents without redeployment.

## Auto-Detection
On activation, detect logging context automatically:
```
AUTO-DETECT:
1. Detect current logging:
   - grep for console.log, console.error → unstructured Node.js
   - grep for log.Println, log.Printf → unstructured Go
   - grep for print(), logging.info → unstructured Python
   - grep for pino, winston, bunyan → structured Node.js
   - grep for slog, zerolog, zap → structured Go
   - grep for structlog, loguru → structured Python
2. Detect logging library:
   - package.json → pino, winston, bunyan
   - go.mod → log/slog, rs/zerolog, uber-go/zap
   - pyproject.toml → structlog, loguru, python-json-logger
3. Check for correlation IDs:
   - grep for requestId, traceId, correlationId, X-Request-ID
4. Check for PII in logs:
```

## Iterative Logging Implementation Protocol
Logging improvements are applied iteratively across services:
```
current_service = 0
services = [detected services sorted by traffic: highest first]

WHILE current_service < len(services):
  service = services[current_service]
  1. ASSESS current logging state for {service}
  2. CONFIGURE structured logger:
     a. Set up JSON output with base fields
     b. Configure log level strategy (ERROR/WARN/INFO/DEBUG)
     c. Add PII redaction rules
  3. ADD request logging middleware:
     a. Generate/propagate requestId and traceId
     b. Log request start + completion with duration
     c. Auto-classify log level by status code (5xx=ERROR, 4xx=WARN)
  4. REPLACE unstructured logs:
```

## Keep/Discard Discipline
```
After EACH logging configuration change:
  1. MEASURE: Run the application — are logs valid JSON? Do they include required fields (requestId, service, level)?
  2. COMPARE: Is the logging better than before? (structured vs unstructured, PII redacted, correlation IDs present)
  3. DECIDE:
     - KEEP if: log output is valid JSON AND required fields present AND PII redacted AND no performance regression
     - DISCARD if: log output is malformed OR required fields missing OR PII leaked OR logging blocks the event loop
  4. COMMIT kept changes. Revert discarded changes before the next service migration.

Never migrate a service to structured logging without verifying the output is parseable.
```

## Stuck Recovery
```
IF >3 consecutive iterations fail to produce valid structured logs:
  1. Check the logger library documentation — configuration syntax varies between pino, winston, slog, structlog.
  2. Simplify: start with a minimal logger config (just JSON format + level), then add fields incrementally.
  3. Check for middleware ordering issues — correlation ID middleware must run before handlers that log.
  4. If still stuck → log stop_reason=stuck, keep the current logging state, move to the next service.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All services produce structured JSON logs with correlation IDs
  - PII redaction verified with test data
  - Log aggregation pipeline receiving logs
  - User explicitly requests stop
  - Max iterations (12) reached

DO NOT STOP just because:
  - One service has complex legacy logging (migrate the simpler services first)
  - Log aggregation pipeline is not yet set up (structured logs to stdout is still an improvement)
```

## Simplicity Criterion
```
PREFER the simpler logging approach:
  - pino (Node.js) or slog (Go) or structlog (Python) — fast, structured, minimal config
  - Loki over ELK for small teams (lower operational overhead)
  - stdout JSON logs over file-based logging (let the container runtime handle rotation)
  - Auto-detection PII redaction (by field name pattern) before manual allowlists
  - Single shared logger config imported by all services before per-service custom configs
  - Fewer log levels in practice: ERROR + WARN + INFO covers 95% of production needs
```

## Chaining
- **From `/godmode:errorhandling`:** After designing error hierarchy, implement structured logging with `/godmode:logging`
- **From `/godmode:logging` to `/godmode:observe`:** After logging is in place, add metrics and tracing with `/godmode:observe`
- **From `/godmode:resilience`:** Resilience patterns need logging for circuit breaker states, retries, and degradation events
- **From `/godmode:secure`:** Security audit requires PII redaction in logs
- **From `/godmode:incident`:** Post-mortem reveals insufficient logging → improve with `/godmode:logging`

## Output Format
Print on completion: `Logging: {service_count} services configured. Format: structured JSON. Levels: {level_config}. Correlation: {correlation_status}. PII: {pii_status}. Retention: {retention_policy}. Verdict: {verdict}.`

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
iteration	task	services_configured	format	correlation_ids	pii_redacted	retention_days	status
1	core_setup	4	structured_json	yes	yes	30	configured
2	migration	2	migrated_from_console	yes	yes	30	migrated
3	correlation	4	structured_json	verified	yes	30	verified
4	pipeline	1	aggregator	n/a	n/a	90	configured
```

## Success Criteria
- All services use structured JSON logging (no `console.log` or `print` statements).
- Log levels correctly configured (ERROR for failures, WARN for degradation, INFO for business events, DEBUG disabled in production).
- Correlation IDs (request ID, trace ID) attached to every log line.
- PII redacted or masked in all log output (emails, tokens, passwords).
- Log aggregation pipeline configured (ship to centralized logging).
- Retention policy set per environment (production: 30-90 days, staging: 7 days).
- Async log writing configured (no blocking I/O on hot paths).
- Consistent log format across all services (same field names, same structure).

## Error Recovery

- **Logs are unstructured after migration**: Search for remaining `console.log`, `print()`, `fmt.Println` calls. Replace with the structured logger. Use lint rules to prevent regression (`no-console` ESLint rule).
- **Correlation IDs missing in some logs**: Check middleware ordering — correlation ID middleware must run before any handler that logs. Verify the logger context is propagated to all layers (service, repository, etc.).
- **Log volume too high (cost explosion)**: Audit log levels — production should not use DEBUG. Sample high-volume events instead of logging every one. Filter out health check logs at the aggregator level.
- **PII found in logs**: Add redaction middleware/filters. Audit all log statements for email, phone, SSN, token, password fields. Use allowlists (log only known-safe fields) instead of denylists.
- **Logs not appearing in aggregator**: Check the log shipping agent (Fluentd, Filebeat, CloudWatch agent). Verify network connectivity to the aggregator. Check log file rotation — the agent may be tailing a rotated file.
- **Different services use different log formats**: Standardize on a single schema. Create a shared logging library/wrapper that all services import. Enforce the schema in code review.

