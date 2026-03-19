# /godmode:logging

Structured logging implementation. Defines log level strategies, implements JSON structured logging, sets up log aggregation pipelines, adds request tracing with correlation IDs, handles PII redaction, and configures log retention and rotation policies.

## Usage

```
/godmode:logging                           # Full structured logging implementation
/godmode:logging --levels                  # Define log level strategy
/godmode:logging --structured              # Implement structured JSON logging
/godmode:logging --aggregation             # Set up log aggregation (ELK, Loki, CloudWatch)
/godmode:logging --tracing                 # Add correlation IDs and request tracing
/godmode:logging --pii                     # Implement PII redaction in logs
/godmode:logging --retention               # Design log retention and rotation policy
/godmode:logging --opentelemetry           # Integrate with OpenTelemetry
/godmode:logging --audit                   # Audit existing logging for gaps
```

## What It Does

1. Assesses current logging maturity (format, levels, context, correlation, aggregation, PII, retention, performance)
2. Defines log level strategy: FATAL (process dies), ERROR (operation failed), WARN (unexpected but handled), INFO (business events), DEBUG (diagnostic)
3. Implements structured JSON logging with consistent fields (timestamp, level, service, requestId, traceId)
4. Sets up request-scoped loggers with correlation IDs propagated across service boundaries
5. Implements PII redaction at the logger level (mask emails/phones, redact passwords/tokens/cards, anonymize IPs)
6. Configures log aggregation pipeline (ELK Stack, Grafana Loki, or AWS CloudWatch)
7. Integrates with OpenTelemetry for unified traces and logs with automatic context propagation
8. Defines log retention and rotation policy per environment with storage tiering (hot/warm/cold)

## Output
- Logging design at `docs/logging/<service>-logging.md`
- Logger configuration in service source directory
- Commit: `"logging: <service> — structured logging with <features> (<coverage>)"`

## Log Level Quick Reference

| Level | Production | Alerts | Example |
|-------|-----------|--------|---------|
| FATAL | Always | Immediate page | Startup failure, OOM |
| ERROR | Always | Alert within 5m | API call failed, DB error |
| WARN | Always | Dashboard | Retry succeeded, slow query |
| INFO | Always | — | User signup, order created |
| DEBUG | On-demand | — | SQL query, cache hit/miss |

## Next Step
After structured logging: `/godmode:observe` to add metrics and tracing alongside logs.
If error handling needed: `/godmode:errorhandling` to design error hierarchy first.
For security review: `/godmode:secure` to verify PII redaction compliance.

## Examples

```
/godmode:logging                           # Full structured logging implementation
/godmode:logging --structured              # Convert console.log to pino/structlog
/godmode:logging --tracing                 # Add correlation IDs across microservices
/godmode:logging --pii                     # Audit and redact PII from all log output
/godmode:logging --aggregation             # Set up Grafana Loki pipeline
```
