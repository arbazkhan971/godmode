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
┌──────────────────────────────────────────────────────────────┐
│  Aspect              │ Status    │ Current State              │
│  ─────────────────────────────────────────────────────────── │
│  Format              │ POOR      │ Unstructured console.log   │
│  Log Levels          │ PARTIAL   │ info/error only            │
│  Context             │ NONE      │ No request IDs or user IDs │
│  Correlation         │ NONE      │ No trace/correlation IDs   │
│  Aggregation         │ NONE      │ stdout only, no pipeline   │
│  PII Handling        │ NONE      │ Sensitive data in logs     │
│  Retention Policy    │ NONE      │ No rotation or archival    │
│  Performance         │ UNKNOWN   │ Synchronous logging        │
├──────────────────────────────────────────────────────────────┤
│  Overall Score: 1/10 — INSUFFICIENT                          │
│  Priority: Structured format + correlation IDs               │
└──────────────────────────────────────────────────────────────┘
```

### Step 2: Log Level Strategy
Define when to use each log level:

```
LOG LEVEL STRATEGY:
┌──────────────────────────────────────────────────────────────┐
│  Level  │ When to Use                    │ Examples           │
│  ─────────────────────────────────────────────────────────── │
│  FATAL  │ Process cannot continue.       │ Startup failure    │
│         │ Requires immediate human       │ Out of memory      │
│         │ intervention. Process exits.   │ Uncaught exception │
│         │                                │ Critical config    │
│         │                                │ missing            │
│  ─────────────────────────────────────────────────────────── │
│  ERROR  │ Operation failed. The specific │ Payment API 500    │
│         │ request/task cannot be         │ Database query fail│
│         │ completed, but the process     │ File write failed  │
│         │ continues serving others.      │ Auth token invalid │
│  ─────────────────────────────────────────────────────────── │
│  WARN   │ Something unexpected happened  │ Retry succeeded    │
│         │ but the operation completed.   │ Cache miss fallback│
│         │ Or: a condition that will      │ Deprecated API used│
│         │ become an error soon.          │ Disk 80% full      │
│         │                                │ Slow query (>1s)   │
│  ─────────────────────────────────────────────────────────── │
│  INFO   │ Normal operations that are     │ Server started     │
│         │ significant business events.   │ User signed up     │
│         │ What you'd want in production. │ Order completed    │
│         │                                │ Deploy finished    │
│         │                                │ Config loaded      │
│  ─────────────────────────────────────────────────────────── │
│  DEBUG  │ Detailed diagnostic info for   │ SQL query text     │
│         │ troubleshooting. Disabled in   │ HTTP request/resp  │
│         │ production unless investigating│ Cache hit/miss     │
│         │ a specific issue.              │ Function entry/exit│
│         │                                │ Variable values    │
│  ─────────────────────────────────────────────────────────── │
│  TRACE  │ Very fine-grained. Individual  │ Loop iterations    │
│         │ steps within an algorithm.     │ Wire-level protocol│
│         │ Almost never enabled.          │ Byte-level parsing │
└──────────────────────────────────────────────────────────────┘

PRODUCTION LOG LEVELS:
  Default: INFO (business events + errors)
  Debugging: DEBUG for specific service/module (not globally!)
  Incident: WARN threshold lowered temporarily

RULES:
  1. If it wakes someone up at 3am, it's ERROR or FATAL
  2. If it's "interesting but handled", it's WARN
  3. If you'd want to see it in a dashboard, it's INFO
  4. If you only need it while debugging, it's DEBUG
  5. Never log at ERROR level for expected conditions (404, validation failure)
  6. A healthy system should have ZERO ERROR logs in normal operation
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
    "service": "checkout-api",
    "environment": "production",
    "requestId": "req_abc123",
    "traceId": "trace_def456",
    "userId": "usr_789",
    "orderId": "ord_12345",
    "amount": 99.99,
    "gateway": "stripe",
    "errorCode": "card_declined",
    "declineReason": "insufficient_funds",
    "duration_ms": 1523
  }

Benefits:
  - Machine-parseable — direct ingestion into ELK/Loki/CloudWatch
  - Searchable by any field (orderId, userId, errorCode)
  - Aggregatable (group by errorCode, gateway)
  - Filterable (environment=production AND level=error)
  - PII fields identifiable and redactable
```

#### Implementation — Node.js (pino)
```javascript
const pino = require('pino');

// Create the logger
const logger = pino({
  level: process.env.LOG_LEVEL || 'info',

  // Base fields included in every log line
  base: {
    service: process.env.SERVICE_NAME || 'my-service',
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || 'unknown',
    hostname: require('os').hostname(),
  },

  // Timestamp as ISO string (not epoch)
  timestamp: pino.stdTimeFunctions.isoTime,

  // Serializers for common objects
  serializers: {
    err: pino.stdSerializers.err,  // serialize Error objects properly
    req: (req) => ({
      method: req.method,
      url: req.url,
      headers: {
        'user-agent': req.headers['user-agent'],
        'content-type': req.headers['content-type'],
        // Explicitly list allowed headers — don't log all
      },
    }),
    res: (res) => ({
      statusCode: res.statusCode,
    }),
  },

  // Redaction of sensitive fields
  redact: {
    paths: [
      'password',
      'req.headers.authorization',
      'req.headers.cookie',
      'creditCard',
      'ssn',
      'token',
      '*.password',
      '*.creditCard',
      '*.ssn',
    ],
    censor: '[REDACTED]',
  },

  // Pretty print in development only
  transport: process.env.NODE_ENV === 'development'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined,
});

// Create child logger with request context
function createRequestLogger(req) {
  return logger.child({
    requestId: req.id,
    traceId: req.headers['x-trace-id'] || req.id,
    userId: req.user?.id,
    method: req.method,
    path: req.path,
  });
}

// Express middleware to attach logger to request
function requestLoggerMiddleware(req, res, next) {
  req.log = createRequestLogger(req);
  const startTime = process.hrtime.bigint();

  res.on('finish', () => {
    const duration = Number(process.hrtime.bigint() - startTime) / 1e6;
    const logData = {
      statusCode: res.statusCode,
      duration_ms: Math.round(duration * 100) / 100,
      contentLength: res.getHeader('content-length'),
    };

    if (res.statusCode >= 500) {
      req.log.error(logData, 'Request completed with server error');
    } else if (res.statusCode >= 400) {
      req.log.warn(logData, 'Request completed with client error');
    } else {
      req.log.info(logData, 'Request completed');
    }
  });

  next();
}

// Usage in route handlers
app.post('/api/orders', asyncHandler(async (req, res) => {
  req.log.info({ items: req.body.items?.length }, 'Creating order');

  const order = await orderService.create(req.body, req.user);

  req.log.info({ orderId: order.id, total: order.total }, 'Order created');

  res.status(201).json(order);
}));
```

#### Implementation — Go (slog)
```go
package logger

import (
    "context"
    "log/slog"
    "os"
    "time"
)

// Setup creates a structured JSON logger
func Setup(service, environment, version string) *slog.Logger {
    handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: parseLevel(os.Getenv("LOG_LEVEL")),
        ReplaceAttr: func(groups []string, a slog.Attr) slog.Attr {
            // Redact sensitive fields
            if isSensitive(a.Key) {
                return slog.String(a.Key, "[REDACTED]")
            }
            // Use ISO timestamp
            if a.Key == slog.TimeKey {
                return slog.String("timestamp", a.Value.Time().Format(time.RFC3339Nano))
            }
            return a
        },
    })

    return slog.New(handler).With(
        slog.String("service", service),
        slog.String("environment", environment),
        slog.String("version", version),
    )
}

var sensitiveFields = map[string]bool{
    "password": true, "token": true, "authorization": true,
    "creditCard": true, "ssn": true, "cookie": true,
}

func isSensitive(key string) bool {
    return sensitiveFields[key]
}

// Context-aware logging: embed logger in context
type contextKey string
const loggerKey contextKey = "logger"

func WithContext(ctx context.Context, l *slog.Logger) context.Context {
    return context.WithValue(ctx, loggerKey, l)
}

func FromContext(ctx context.Context) *slog.Logger {
    if l, ok := ctx.Value(loggerKey).(*slog.Logger); ok {
        return l
    }
    return slog.Default()
}

// Middleware to create request-scoped logger
func RequestLoggerMiddleware(baseLogger *slog.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            requestID := r.Header.Get("X-Request-ID")
            if requestID == "" {
                requestID = uuid.New().String()
            }

            traceID := r.Header.Get("X-Trace-ID")
            if traceID == "" {
                traceID = requestID
            }

            reqLogger := baseLogger.With(
                slog.String("requestId", requestID),
                slog.String("traceId", traceID),
                slog.String("method", r.Method),
                slog.String("path", r.URL.Path),
                slog.String("remoteAddr", anonymizeIP(r.RemoteAddr)),
            )

            ctx := WithContext(r.Context(), reqLogger)
            r = r.WithContext(ctx)

            wrapped := &responseWriter{ResponseWriter: w, statusCode: 200}
            start := time.Now()

            next.ServeHTTP(wrapped, r)

            duration := time.Since(start)
            logAttrs := []slog.Attr{
                slog.Int("statusCode", wrapped.statusCode),
                slog.Float64("duration_ms", float64(duration.Microseconds())/1000),
            }

            if wrapped.statusCode >= 500 {
                reqLogger.LogAttrs(r.Context(), slog.LevelError, "Request completed with server error", logAttrs...)
            } else if wrapped.statusCode >= 400 {
                reqLogger.LogAttrs(r.Context(), slog.LevelWarn, "Request completed with client error", logAttrs...)
            } else {
                reqLogger.LogAttrs(r.Context(), slog.LevelInfo, "Request completed", logAttrs...)
            }
        })
    }
}

// Usage in handlers
func CreateOrderHandler(w http.ResponseWriter, r *http.Request) {
    log := FromContext(r.Context())

    log.Info("Creating order", slog.Int("itemCount", len(req.Items)))

    order, err := orderService.Create(r.Context(), req)
    if err != nil {
        log.Error("Failed to create order", slog.String("error", err.Error()))
        HandleError(w, r, err)
        return
    }

    log.Info("Order created",
        slog.String("orderId", order.ID),
        slog.Float64("total", order.Total),
    )

    json.NewEncoder(w).Encode(order)
}
```

#### Implementation — Python (structlog)
```python
import structlog
import logging
import uuid
from functools import wraps

# Configure structlog
structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        # PII redaction processor
        redact_sensitive_fields,
        # JSON output for production, pretty for dev
        structlog.dev.ConsoleRenderer() if os.getenv("ENV") == "development"
        else structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(
        logging.getLevelName(os.getenv("LOG_LEVEL", "INFO"))
    ),
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
    cache_logger_on_first_use=True,
)

# PII redaction processor
SENSITIVE_FIELDS = {"password", "token", "authorization", "credit_card",
                    "ssn", "cookie", "secret"}

def redact_sensitive_fields(logger, method_name, event_dict):
    for key in list(event_dict.keys()):
        if key.lower() in SENSITIVE_FIELDS:
            event_dict[key] = "[REDACTED]"
    return event_dict

# Create base logger
logger = structlog.get_logger(
    service=os.getenv("SERVICE_NAME", "my-service"),
    environment=os.getenv("ENV", "development"),
    version=os.getenv("APP_VERSION", "unknown"),
)

# FastAPI middleware for request-scoped logging
from starlette.middleware.base import BaseHTTPMiddleware

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        request_id = request.headers.get("x-request-id", str(uuid.uuid4()))
        trace_id = request.headers.get("x-trace-id", request_id)

        # Bind request context to structlog context vars
        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(
            request_id=request_id,
            trace_id=trace_id,
            method=request.method,
            path=str(request.url.path),
        )

        start_time = time.time()

        try:
            response = await call_next(request)
            duration_ms = (time.time() - start_time) * 1000

            log_data = {
                "status_code": response.status_code,
                "duration_ms": round(duration_ms, 2),
            }

            if response.status_code >= 500:
                logger.error("Request completed with server error", **log_data)
            elif response.status_code >= 400:
                logger.warning("Request completed with client error", **log_data)
            else:
                logger.info("Request completed", **log_data)

            response.headers["X-Request-ID"] = request_id
            return response

        except Exception as exc:
            duration_ms = (time.time() - start_time) * 1000
            logger.error("Request failed with exception",
                         error=str(exc), duration_ms=round(duration_ms, 2))
            raise

# Usage
@app.post("/api/orders")
async def create_order(request: CreateOrderRequest):
    logger.info("Creating order", item_count=len(request.items))

    order = await order_service.create(request)

    logger.info("Order created", order_id=order.id, total=order.total)

    return order
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
    │    Generate:           │            │           │
    │    requestId=req_001   │            │           │
    │    traceId=trace_xyz   │            │           │
    │          │             │            │           │
    │          └──Headers──→ │            │           │
    │               X-Request-ID: req_001 │           │
    │               X-Trace-ID: trace_xyz │           │
    │               X-Span-ID: span_aaa   │           │
    │                        │            │           │
    │                        │ New span:  │           │
    │                        │ spanId=span_bbb        │
    │                        │ parentSpanId=span_aaa  │
    │                        │ traceId=trace_xyz (same│
    │                        └──Headers──→│           │
    │                                     │           │
    │                                     │ New span: │
    │                                     │ span_ccc  │

Log correlation:
  Every log line from every service includes traceId.
  Searching by traceId shows the complete request journey.

  Service A log: { "traceId": "trace_xyz", "message": "Received order" }
  Service B log: { "traceId": "trace_xyz", "message": "Charging payment" }
  Service A log: { "traceId": "trace_xyz", "message": "Order confirmed" }
```

#### Implementation — Propagation Middleware
```javascript
// Correlation ID middleware — generates or propagates IDs
function correlationMiddleware(req, res, next) {
  // Propagate from upstream or generate new
  req.id = req.headers['x-request-id'] || generateId('req');
  req.traceId = req.headers['x-trace-id'] || generateId('trace');
  req.spanId = generateId('span');
  req.parentSpanId = req.headers['x-span-id'] || null;

  // Set response headers for client correlation
  res.set('X-Request-ID', req.id);
  res.set('X-Trace-ID', req.traceId);

  next();
}

// HTTP client that propagates correlation IDs
class TracedHttpClient {
  constructor(baseLogger) {
    this.logger = baseLogger;
  }

  async request(url, options, context) {
    const childSpanId = generateId('span');

    const headers = {
      ...options.headers,
      'X-Request-ID': context.requestId,
      'X-Trace-ID': context.traceId,
      'X-Span-ID': childSpanId,
    };

    const start = Date.now();
    this.logger.debug('Outbound request', {
      url,
      method: options.method || 'GET',
      traceId: context.traceId,
      spanId: childSpanId,
      parentSpanId: context.spanId,
    });

    try {
      const response = await fetch(url, { ...options, headers });
      const duration = Date.now() - start;

      this.logger.info('Outbound request completed', {
        url,
        statusCode: response.status,
        duration_ms: duration,
        traceId: context.traceId,
        spanId: childSpanId,
      });

      return response;
    } catch (error) {
      const duration = Date.now() - start;
      this.logger.error('Outbound request failed', {
        url,
        error: error.message,
        duration_ms: duration,
        traceId: context.traceId,
        spanId: childSpanId,
      });
      throw error;
    }
  }
}

function generateId(prefix) {
  return `${prefix}_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
}
```

#### OpenTelemetry Integration
```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { OTLPLogExporter } = require('@opentelemetry/exporter-logs-otlp-http');

const sdk = new NodeSDK({
  serviceName: process.env.SERVICE_NAME,
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT + '/v1/traces',
  }),
  logRecordExporter: new OTLPLogExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT + '/v1/logs',
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-http': {
        requestHook: (span, request) => {
          span.setAttribute('http.request_id', request.headers['x-request-id']);
        },
      },
      '@opentelemetry/instrumentation-express': { enabled: true },
      '@opentelemetry/instrumentation-pg': { enabled: true },
      '@opentelemetry/instrumentation-redis': { enabled: true },
    }),
  ],
});

sdk.start();

// Logs automatically include trace context (traceId, spanId)
// from the active OpenTelemetry span
```

### Step 5: PII Redaction in Logs

#### PII Redaction Strategy
```
PII REDACTION POLICY:
┌──────────────────────────────────────────────────────────────┐
│  Data Type             │ Action    │ Technique               │
│  ─────────────────────────────────────────────────────────── │
│  Email address         │ MASK      │ j***@example.com        │
│  Phone number          │ MASK      │ +1-***-***-5678         │
│  Credit card number    │ REDACT    │ [REDACTED]              │
│  CVV                   │ NEVER LOG │ —                       │
│  Password / secret     │ NEVER LOG │ —                       │
│  SSN / National ID     │ REDACT    │ [REDACTED]              │
│  IP address            │ ANONYMIZE │ 192.168.1.0/24          │
│  Full name             │ MASK      │ J*** D***               │
│  Date of birth         │ MASK      │ ****-**-15              │
│  Home address          │ REDACT    │ [REDACTED]              │
│  Auth token / JWT      │ TRUNCATE  │ eyJhb....[TRUNCATED]    │
│  API key               │ TRUNCATE  │ sk_live_...abc          │
│  Cookie values         │ REDACT    │ [REDACTED]              │
│  Request body (POST)   │ SELECTIVE │ Log allowed fields only │
│  Query parameters      │ SELECTIVE │ Redact known PII params │
└──────────────────────────────────────────────────────────────┘

RULES:
  1. Allowlist, not blocklist — log only explicitly allowed fields
  2. Redact by default — if unsure, redact
  3. Redact at the logger level, not in business logic
  4. Test redaction — log a known PII value and verify it's redacted
  5. Audit quarterly — new fields may introduce PII
```

#### Implementation — Redaction Utilities
```javascript
// PII redaction utilities
const redactor = {
  email(value) {
    if (!value || typeof value !== 'string') return value;
    const [local, domain] = value.split('@');
    if (!domain) return '[REDACTED_EMAIL]';
    return `${local[0]}***@${domain}`;
  },

  phone(value) {
    if (!value || typeof value !== 'string') return value;
    const digits = value.replace(/\D/g, '');
    if (digits.length < 4) return '[REDACTED_PHONE]';
    return value.slice(0, -4).replace(/\d/g, '*') + value.slice(-4);
  },

  creditCard(value) {
    return '[REDACTED]';
  },

  ip(value) {
    if (!value || typeof value !== 'string') return value;
    // Anonymize last octet (IPv4) or last 80 bits (IPv6)
    const parts = value.split('.');
    if (parts.length === 4) {
      parts[3] = '0';
      return parts.join('.');
    }
    return '[ANONYMIZED_IP]';
  },

  name(value) {
    if (!value || typeof value !== 'string') return value;
    return value.split(' ')
      .map(part => part[0] + '***')
      .join(' ');
  },

  token(value) {
    if (!value || typeof value !== 'string') return value;
    if (value.length <= 8) return '[REDACTED]';
    return value.slice(0, 4) + '...[TRUNCATED]';
  },
};

// Deep redaction for objects
function redactObject(obj, fieldRules) {
  if (!obj || typeof obj !== 'object') return obj;

  const result = Array.isArray(obj) ? [...obj] : { ...obj };

  for (const [key, value] of Object.entries(result)) {
    const lowerKey = key.toLowerCase();

    // Check explicit rules
    if (fieldRules[lowerKey]) {
      result[key] = fieldRules[lowerKey](value);
      continue;
    }

    // Auto-detect by field name
    if (lowerKey.includes('password') || lowerKey.includes('secret')) {
      result[key] = '[REDACTED]';
    } else if (lowerKey.includes('email')) {
      result[key] = redactor.email(value);
    } else if (lowerKey.includes('phone') || lowerKey.includes('mobile')) {
      result[key] = redactor.phone(value);
    } else if (lowerKey.includes('card') || lowerKey.includes('cvv')) {
      result[key] = '[REDACTED]';
    } else if (lowerKey.includes('ssn') || lowerKey.includes('national_id')) {
      result[key] = '[REDACTED]';
    } else if (lowerKey.includes('token') || lowerKey.includes('authorization')) {
      result[key] = redactor.token(value);
    } else if (typeof value === 'object') {
      result[key] = redactObject(value, fieldRules);
    }
  }

  return result;
}

// Pino redaction config (alternative: built-in redact option)
const pinoRedactPaths = [
  'password', '*.password',
  'creditCard', '*.creditCard',
  'ssn', '*.ssn',
  'req.headers.authorization',
  'req.headers.cookie',
  'token', '*.token',
  'secret', '*.secret',
];
```

### Step 6: Log Aggregation Architecture

#### ELK Stack (Elasticsearch, Logstash, Kibana)
```
ELK STACK PIPELINE:

Application → stdout (JSON) → Filebeat → Logstash → Elasticsearch → Kibana
                                  │
                            ┌─────┴──────┐
                            │  Filebeat   │
                            │  - Tails    │
                            │    log files│
                            │  - Adds     │
                            │    metadata │
                            │  - Buffers  │
                            │    & ships  │
                            └─────┬──────┘
                                  ↓
                            ┌─────────────┐
                            │  Logstash   │
                            │  - Parse    │
                            │  - Transform│
                            │  - Enrich   │
                            │  - Filter   │
                            │  - Route    │
                            └─────┬──────┘
                                  ↓
                            ┌─────────────┐
                            │Elasticsearch│
                            │  - Index    │
                            │  - Search   │
                            │  - Aggregate│
                            └─────┬──────┘
                                  ↓
                            ┌─────────────┐
                            │   Kibana    │
                            │  - Dashboards│
                            │  - Alerts   │
                            │  - Explore  │
                            └─────────────┘

Logstash filter example:
  filter {
    json { source => "message" }
    if [level] == "error" {
      mutate { add_tag => ["error"] }
    }
    if [userId] {
      mutate { add_field => { "[@metadata][index]" => "logs-user-activity" } }
    }
  }
```

#### Grafana Loki (Lightweight Alternative)
```
LOKI PIPELINE:

Application → stdout (JSON) → Promtail → Loki → Grafana
                                  │
                            ┌─────┴──────┐
                            │  Promtail  │
                            │  - Discovers│
                            │    targets │
                            │  - Extracts│
                            │    labels  │
                            │  - Ships   │
                            └─────┬──────┘
                                  ↓
                            ┌─────────────┐
                            │    Loki     │
                            │  - Label    │
                            │    index    │
                            │  - Chunk   │
                            │    storage │
                            │  - LogQL   │
                            └─────┬──────┘
                                  ↓
                            ┌─────────────┐
                            │  Grafana    │
                            │  - Explore  │
                            │  - Dashboard│
                            │  - Alerts   │
                            └─────────────┘

Why Loki over ELK:
  - Indexes labels only (not full text) — much cheaper storage
  - Prometheus-like label model — familiar if you use Prometheus
  - Integrates natively with Grafana dashboards
  - Lower operational overhead

Promtail config:
  scrape_configs:
    - job_name: kubernetes
      kubernetes_sd_configs:
        - role: pod
      pipeline_stages:
        - json:
            expressions:
              level: level
              service: service
              requestId: requestId
        - labels:
            level:
            service:
        - timestamp:
            source: timestamp
            format: RFC3339Nano

LogQL queries:
  # All errors from checkout service
  {service="checkout-api", level="error"}

  # Errors with specific requestId
  {service=~".+"} |= "req_abc123"

  # Error rate over time
  rate({level="error"}[5m])

  # Top 10 error messages
  topk(10, sum by (message) (rate({level="error"}[1h])))
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
  | filter level = "error"
  | sort errorCount desc

  # P95 request duration
  stats percentile(duration_ms, 95) as p95
  | filter message = "Request completed"

  # Trace a specific request
  fields @timestamp, service, message
  | filter traceId = "trace_xyz"
  | sort @timestamp asc

CloudWatch agent config:
  {
    "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            {
              "file_path": "/var/log/app/*.log",
              "log_group_name": "/app/my-service",
              "log_stream_name": "{instance_id}",
              "retention_in_days": 30
            }
          ]
        }
      }
    }
  }
```

### Step 7: Log Retention and Rotation

```
LOG RETENTION POLICY:
┌──────────────────────────────────────────────────────────────┐
│  Environment │ Log Level │ Retention │ Storage Tier          │
│  ─────────────────────────────────────────────────────────── │
│  Production  │ ERROR     │ 365 days  │ Hot (30d) → Warm (90d)│
│              │           │           │ → Cold (365d)         │
│  Production  │ WARN      │ 90 days   │ Hot (30d) → Warm (90d)│
│  Production  │ INFO      │ 30 days   │ Hot (30d)             │
│  Production  │ DEBUG     │ 7 days    │ Hot (7d) — only when  │
│              │           │           │ explicitly enabled    │
│  ─────────────────────────────────────────────────────────── │
│  Staging     │ All       │ 14 days   │ Hot (14d)             │
│  Development │ All       │ 3 days    │ Hot (3d)              │
│  ─────────────────────────────────────────────────────────── │
│  Compliance  │ Audit logs│ 7 years   │ Hot (90d) → Archive   │
│  (if needed) │           │           │ (7 years, immutable)  │
└──────────────────────────────────────────────────────────────┘

ROTATION:
  File-based logging:
    - Rotate daily or at 100MB, whichever comes first
    - Compress rotated files (gzip)
    - Delete after retention period
    - Use logrotate (Linux) or built-in library rotation

  Container logging:
    - Log to stdout/stderr (12-factor app)
    - Container runtime handles rotation (Docker: max-size, max-file)
    - Log shipper (Filebeat/Promtail) handles delivery
    - Aggregation system handles retention

Docker log rotation:
  {
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "50m",
      "max-file": "5"
    }
  }

Kubernetes:
  Container logs rotated by kubelet (default 10MB, 5 files)
  Ship to aggregation system before rotation deletes them
```

### Step 8: Logging Performance

```
LOGGING PERFORMANCE GUIDELINES:
┌──────────────────────────────────────────────────────────────┐
│  Concern               │ Solution                           │
│  ─────────────────────────────────────────────────────────── │
│  Synchronous I/O       │ Use async loggers (pino, slog)     │
│  blocks event loop     │ Buffer and flush periodically      │
│  ─────────────────────────────────────────────────────────── │
│  High-volume logging   │ Sample DEBUG logs (1 in 100)       │
│  causes CPU pressure   │ Don't stringify objects you won't  │
│                        │ log (check level first)            │
│  ─────────────────────────────────────────────────────────── │
│  Large log messages    │ Set max message size (10KB)        │
│                        │ Truncate request/response bodies   │
│  ─────────────────────────────────────────────────────────── │
│  Disk fill from logs   │ Rotation + retention policy        │
│                        │ Alerts on disk usage > 80%         │
│  ─────────────────────────────────────────────────────────── │
│  Log shipper backpres  │ Drop oldest on buffer full (not    │
│                        │ block the application)             │
└──────────────────────────────────────────────────────────────┘

Performance code pattern:
  // BAD: Stringify even when debug is disabled
  logger.debug(`User data: ${JSON.stringify(largeObject)}`);

  // GOOD: Only compute if level is enabled
  if (logger.isLevelEnabled('debug')) {
    logger.debug({ userData: largeObject }, 'User data loaded');
  }

  // BEST: Use lazy serialization (pino does this automatically)
  logger.debug({ userData: largeObject }, 'User data loaded');
  // pino only serializes if debug level is active
```

### Step 9: Logging Checklist

```
LOGGING VERIFICATION CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Category            │ Check                          │ Pass?│
│  ─────────────────────────────────────────────────────────── │
│  Format              │                                │      │
│    [ ] All logs are structured JSON in production    │      │
│    [ ] ISO 8601 timestamps with timezone             │      │
│    [ ] Consistent field names across all services    │      │
│    [ ] Base fields: service, environment, version    │      │
│  ─────────────────────────────────────────────────────────── │
│  Levels              │                                │      │
│    [ ] Log level strategy documented and followed    │      │
│    [ ] No ERROR logs for expected conditions (404)   │      │
│    [ ] DEBUG disabled in production by default       │      │
│    [ ] Log level configurable at runtime             │      │
│  ─────────────────────────────────────────────────────────── │
│  Context             │                                │      │
│    [ ] Request ID in every log within a request      │      │
│    [ ] Trace ID propagated across service boundaries │      │
│    [ ] User ID included when authenticated           │      │
│    [ ] Error logs include stack trace and cause chain│      │
│  ─────────────────────────────────────────────────────────── │
│  PII                 │                                │      │
│    [ ] Sensitive fields redacted (password, token)   │      │
│    [ ] Email/phone masked, not fully logged          │      │
│    [ ] Auth headers and cookies never logged         │      │
│    [ ] Redaction tested with sample PII values       │      │
│  ─────────────────────────────────────────────────────────── │
│  Aggregation         │                                │      │
│    [ ] Logs ship to aggregation system (ELK/Loki/CW)│      │
│    [ ] Can search by requestId/traceId across services│     │
│    [ ] Alert rules configured for error rate spikes  │      │
│    [ ] Dashboards for key log metrics                │      │
│  ─────────────────────────────────────────────────────────── │
│  Retention           │                                │      │
│    [ ] Retention policy defined per environment      │      │
│    [ ] Log rotation configured (size/time based)     │      │
│    [ ] Compliance logs archived per policy           │      │
│    [ ] Storage tiering in place (hot/warm/cold)      │      │
│  ─────────────────────────────────────────────────────────── │
│  Performance         │                                │      │
│    [ ] Async logging (no blocking I/O in hot path)   │      │
│    [ ] Debug-level computation guarded by level check│      │
│    [ ] Max message size enforced                     │      │
│    [ ] Log shipper backpressure won't block app      │      │
└──────────────────────────────────────────────────────────────┘
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
7. NEVER deploy without correlation IDs — requestId and traceId must be in every log line within a request.
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
   - grep for email, password, token, ssn, credit in log statements
   - Identify fields that need redaction
5. Detect log aggregation:
   - docker-compose with elasticsearch, kibana, logstash → ELK
   - promtail config, loki → Grafana Loki
   - CloudWatch agent config → AWS CloudWatch
   - OTEL_EXPORTER config → OpenTelemetry
6. Check log rotation:
   - logrotate config, Docker log-opts
   - Log retention policies in cloud config
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
     - console.log/print → structured logger calls
     - Add context fields (userId, orderId, etc.)
     - Assign correct log levels
  5. VERIFY:
     - Run application, check log output is valid JSON
     - Verify PII is redacted (test with sample sensitive data)
     - Verify correlation IDs propagate across service calls
  6. COMMIT: "logging: {service} — structured logging with correlation IDs"
  7. current_service += 1

EXIT when all services have structured logging
```

## Multi-Agent Dispatch
For multi-service logging infrastructure:
```
DISPATCH parallel agents (one per concern):

Agent 1 (worktree: logging-core):
  - Logger configuration and middleware for all services
  - Scope: shared logging library/config
  - Output: Reusable logger setup with PII redaction

Agent 2 (worktree: logging-migrate):
  - Replace unstructured logs with structured calls
  - Scope: all source files with console.log/print/log.Println
  - Output: Structured log calls with proper levels and context

Agent 3 (worktree: logging-correlation):
  - Correlation ID propagation across service boundaries
  - Scope: HTTP clients, message queue producers/consumers
  - Output: Trace ID propagation middleware + traced HTTP client

Agent 4 (worktree: logging-pipeline):
  - Log aggregation pipeline setup (ELK/Loki/CloudWatch)
  - Scope: infrastructure configs, docker-compose, k8s
  - Output: Log shipping + dashboards + alert rules

MERGE ORDER: core → migrate → correlation → pipeline
CONFLICT RESOLUTION: core branch owns logger config, others depend on it
```

## Chaining
- **From `/godmode:errorhandling`:** After designing error hierarchy, implement structured logging with `/godmode:logging`
- **From `/godmode:logging` to `/godmode:observe`:** After logging is in place, add metrics and tracing with `/godmode:observe`
- **From `/godmode:resilience`:** Resilience patterns need logging for circuit breaker states, retries, and degradation events
- **From `/godmode:secure`:** Security audit requires PII redaction in logs
- **From `/godmode:incident`:** Post-mortem reveals insufficient logging → improve with `/godmode:logging`

## Anti-Patterns

```
LOGGING ANTI-PATTERNS:
┌──────────────────────────────────────────────────────────────┐
│  Anti-Pattern              │ Why It's Dangerous              │
│  ─────────────────────────────────────────────────────────── │
│  console.log in production │ Unstructured, no levels, no     │
│                            │ context, can't search/aggregate │
│  Log and forget            │ Logs go to stdout but nobody    │
│                            │ reads them or sets up alerts    │
│  Log everything at ERROR   │ Alert fatigue — real errors     │
│                            │ buried in noise                 │
│  Log sensitive data        │ PII in logs = compliance risk   │
│                            │ and potential data breach       │
│  String interpolation      │ Can't parse, can't search by   │
│  for structured data       │ field, can't aggregate          │
│  Log at every function     │ Massive volume, mostly useless  │
│  entry/exit                │ noise — log at boundaries only  │
│  Synchronous file writes   │ Blocks the event loop / thread  │
│                            │ pool under high throughput      │
│  No correlation IDs        │ Can't trace a request across    │
│                            │ services during an incident     │
│  Different log formats     │ Can't build unified dashboards  │
│  per service               │ or search across services       │
│  No retention policy       │ Disk fills up or costs explode  │
│                            │ in cloud log storage            │
└──────────────────────────────────────────────────────────────┘
```


## Output Format
Print on completion: `Logging: {service_count} services configured. Format: structured JSON. Levels: {level_config}. Correlation: {correlation_status}. PII: {pii_status}. Retention: {retention_policy}. Verdict: {verdict}.`

## TSV Logging
Log every logging configuration step to `.godmode/logging-results.tsv`:
```
iteration	task	services_configured	format	correlation_ids	pii_redacted	retention_days	status
1	core_setup	4	structured_json	yes	yes	30	configured
2	migration	2	migrated_from_console	yes	yes	30	migrated
3	correlation	4	structured_json	verified	yes	30	verified
4	pipeline	1	aggregator	n/a	n/a	90	configured
```
Columns: iteration, task, services_configured, format, correlation_ids, pii_redacted, retention_days, status(configured/migrated/verified/failed).

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

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run logging tasks sequentially: core setup, then migration, then correlation, then pipeline.
- Use branch isolation per task: `git checkout -b godmode-logging-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
