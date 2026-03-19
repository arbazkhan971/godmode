---
name: errorhandling
description: |
  Error handling architecture skill. Activates when user needs to design error hierarchies, implement error boundaries, create structured error responses, set up global error handling, or separate user-facing errors from internal errors. Covers operational vs programmer errors, error boundaries (React, Express, Go), structured error formats, error logging and aggregation, and framework-specific global error handling. Triggers on: /godmode:errorhandling, "error handling", "error boundary", "error hierarchy", "error response", "global error handler", or when build skill encounters unhandled error patterns.
---

# Error Handling — Error Handling Architecture

## When to Activate
- User invokes `/godmode:errorhandling`
- User says "error handling", "error boundary", "error hierarchy"
- User says "structured errors", "error response format", "error codes"
- User asks "how should I handle errors?" or "what's the right error pattern?"
- User needs to separate user-facing errors from internal errors
- Build skill encounters unhandled exceptions or inconsistent error patterns
- Code review flags missing error handling or bare `catch {}` blocks

## Workflow

### Step 1: Error Classification
Classify all errors into two fundamental categories:

```
ERROR CLASSIFICATION:
┌──────────────────────────────────────────────────────────────┐
│  OPERATIONAL ERRORS              │ PROGRAMMER ERRORS          │
│  (Expected, recoverable)         │ (Bugs, not recoverable)    │
│  ────────────────────────────────│──────────────────────────  │
│  - Connection timeout            │ - TypeError / null deref   │
│  - DNS resolution failure        │ - Off-by-one errors        │
│  - Rate limit exceeded (429)     │ - Missing required argument│
│  - Disk full                     │ - Invalid regex            │
│  - Authentication failure        │ - Assert violation         │
│  - Input validation failure      │ - Stack overflow           │
│  - Resource not found            │ - Unhandled promise reject │
│  - Payment declined              │ - Reading undefined prop   │
│  - Upstream service unavailable  │ - SQL syntax error         │
│  - Database constraint violation │ - Infinite loop            │
│  ────────────────────────────────│──────────────────────────  │
│  HANDLE: Return error to caller, │ HANDLE: Log, alert, crash  │
│  retry, degrade gracefully       │ gracefully. Fix the code.  │
│  LOG: Info/Warn level            │ LOG: Error/Fatal level     │
│  RETRY: Often yes                │ RETRY: Never (same result) │
│  USER MSG: Helpful, actionable   │ USER MSG: Generic "oops"   │
└──────────────────────────────────────────────────────────────┘

Key distinction:
  Operational errors are part of normal operation — you expect them.
  Programmer errors are bugs — they should never happen in correct code.

  If you catch a programmer error and "handle" it, you're hiding a bug.
  If you crash on an operational error, you're overreacting.
```

### Step 2: Error Hierarchy Design
Design a typed error hierarchy for your application:

#### Error Hierarchy — TypeScript/Node.js
```typescript
// Base application error — all custom errors extend this
abstract class AppError extends Error {
  abstract readonly code: string;         // machine-readable error code
  abstract readonly statusCode: number;   // HTTP status code
  abstract readonly isOperational: boolean; // operational vs programmer
  readonly timestamp: string;
  readonly requestId?: string;
  readonly context: Record<string, unknown>;

  constructor(message: string, options: {
    cause?: Error;
    requestId?: string;
    context?: Record<string, unknown>;
  } = {}) {
    super(message, { cause: options.cause });
    this.name = this.constructor.name;
    this.timestamp = new Date().toISOString();
    this.requestId = options.requestId;
    this.context = options.context || {};
    Error.captureStackTrace(this, this.constructor);
  }

  // Serialize for logging (includes internal details)
  toLog(): Record<string, unknown> {
    return {
      error: this.name,
      code: this.code,
      message: this.message,
      statusCode: this.statusCode,
      isOperational: this.isOperational,
      timestamp: this.timestamp,
      requestId: this.requestId,
      context: this.context,
      stack: this.stack,
      cause: this.cause instanceof Error ? {
        name: this.cause.name,
        message: this.cause.message,
        stack: this.cause.stack,
      } : undefined,
    };
  }

  // Serialize for API response (safe for users)
  toResponse(): Record<string, unknown> {
    return {
      error: {
        code: this.code,
        message: this.message,
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}

// ── Validation Errors ──────────────────────────────────────
class ValidationError extends AppError {
  readonly code = 'VALIDATION_ERROR';
  readonly statusCode = 400;
  readonly isOperational = true;
  readonly fields: Array<{ field: string; message: string; value?: unknown }>;

  constructor(fields: Array<{ field: string; message: string; value?: unknown }>, options?: {
    cause?: Error;
    requestId?: string;
  }) {
    super(`Validation failed: ${fields.map(f => f.message).join(', ')}`, options);
    this.fields = fields;
  }

  toResponse() {
    return {
      error: {
        code: this.code,
        message: 'Validation failed',
        fields: this.fields.map(f => ({
          field: f.field,
          message: f.message,
        })),
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}

// ── Not Found ──────────────────────────────────────────────
class NotFoundError extends AppError {
  readonly code = 'NOT_FOUND';
  readonly statusCode = 404;
  readonly isOperational = true;

  constructor(resource: string, identifier: string | number, options?: {
    cause?: Error;
    requestId?: string;
  }) {
    super(`${resource} not found: ${identifier}`, {
      ...options,
      context: { resource, identifier },
    });
  }

  toResponse() {
    return {
      error: {
        code: this.code,
        message: `${this.context.resource} not found`,
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}

// ── Authentication & Authorization ─────────────────────────
class AuthenticationError extends AppError {
  readonly code = 'AUTHENTICATION_REQUIRED';
  readonly statusCode = 401;
  readonly isOperational = true;

  constructor(reason: string = 'Authentication required', options?: {
    cause?: Error;
    requestId?: string;
  }) {
    super(reason, options);
  }
}

class AuthorizationError extends AppError {
  readonly code = 'FORBIDDEN';
  readonly statusCode = 403;
  readonly isOperational = true;

  constructor(action: string, resource: string, options?: {
    cause?: Error;
    requestId?: string;
  }) {
    super(`Not authorized to ${action} on ${resource}`, {
      ...options,
      context: { action, resource },
    });
  }

  toResponse() {
    return {
      error: {
        code: this.code,
        message: 'You do not have permission to perform this action',
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}

// ── Conflict / Business Logic ──────────────────────────────
class ConflictError extends AppError {
  readonly code = 'CONFLICT';
  readonly statusCode = 409;
  readonly isOperational = true;

  constructor(message: string, options?: {
    cause?: Error;
    requestId?: string;
    context?: Record<string, unknown>;
  }) {
    super(message, options);
  }
}

// ── Rate Limiting ──────────────────────────────────────────
class RateLimitError extends AppError {
  readonly code = 'RATE_LIMIT_EXCEEDED';
  readonly statusCode = 429;
  readonly isOperational = true;
  readonly retryAfter: number;

  constructor(retryAfter: number, options?: {
    cause?: Error;
    requestId?: string;
  }) {
    super(`Rate limit exceeded. Retry after ${retryAfter} seconds`, options);
    this.retryAfter = retryAfter;
  }

  toResponse() {
    return {
      error: {
        code: this.code,
        message: 'Too many requests. Please try again later.',
        retryAfter: this.retryAfter,
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}

// ── External Service Errors ────────────────────────────────
class ExternalServiceError extends AppError {
  readonly code = 'EXTERNAL_SERVICE_ERROR';
  readonly statusCode = 502;
  readonly isOperational = true;

  constructor(service: string, message: string, options?: {
    cause?: Error;
    requestId?: string;
  }) {
    super(`External service '${service}' failed: ${message}`, {
      ...options,
      context: { service },
    });
  }

  toResponse() {
    return {
      error: {
        code: this.code,
        message: 'A dependent service is temporarily unavailable',
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}

// ── Internal / Unexpected ──────────────────────────────────
class InternalError extends AppError {
  readonly code = 'INTERNAL_ERROR';
  readonly statusCode = 500;
  readonly isOperational = false;  // programmer error

  constructor(message: string, options?: {
    cause?: Error;
    requestId?: string;
    context?: Record<string, unknown>;
  }) {
    super(message, options);
  }

  toResponse() {
    return {
      error: {
        code: this.code,
        message: 'An unexpected error occurred. Please try again later.',
        ...(this.requestId && { requestId: this.requestId }),
      },
    };
  }
}
```

#### Error Hierarchy — Go
```go
package apperr

import (
    "fmt"
    "net/http"
    "time"
)

// Code represents a machine-readable error code
type Code string

const (
    CodeValidation     Code = "VALIDATION_ERROR"
    CodeNotFound       Code = "NOT_FOUND"
    CodeAuthentication Code = "AUTHENTICATION_REQUIRED"
    CodeAuthorization  Code = "FORBIDDEN"
    CodeConflict       Code = "CONFLICT"
    CodeRateLimit      Code = "RATE_LIMIT_EXCEEDED"
    CodeExternalService Code = "EXTERNAL_SERVICE_ERROR"
    CodeInternal       Code = "INTERNAL_ERROR"
)

// AppError is the base application error type
type AppError struct {
    Code        Code                   `json:"code"`
    Message     string                 `json:"message"`
    StatusCode  int                    `json:"-"`
    Operational bool                   `json:"-"`
    Context     map[string]interface{} `json:"context,omitempty"`
    RequestID   string                 `json:"requestId,omitempty"`
    Err         error                  `json:"-"`
    Timestamp   time.Time              `json:"timestamp"`
}

func (e *AppError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%s: %s (caused by: %v)", e.Code, e.Message, e.Err)
    }
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

func (e *AppError) Unwrap() error {
    return e.Err
}

func (e *AppError) HTTPStatusCode() int {
    return e.StatusCode
}

func (e *AppError) IsOperational() bool {
    return e.Operational
}

// Safe response for API consumers (no internal details)
func (e *AppError) ToResponse() map[string]interface{} {
    resp := map[string]interface{}{
        "error": map[string]interface{}{
            "code":    e.Code,
            "message": e.safeMessage(),
        },
    }
    if e.RequestID != "" {
        resp["error"].(map[string]interface{})["requestId"] = e.RequestID
    }
    return resp
}

func (e *AppError) safeMessage() string {
    if !e.Operational {
        return "An unexpected error occurred. Please try again later."
    }
    return e.Message
}

// Constructor functions
func NewValidation(message string, fields []FieldError) *AppError {
    return &AppError{
        Code:        CodeValidation,
        Message:     message,
        StatusCode:  http.StatusBadRequest,
        Operational: true,
        Context:     map[string]interface{}{"fields": fields},
        Timestamp:   time.Now(),
    }
}

func NewNotFound(resource string, id interface{}) *AppError {
    return &AppError{
        Code:        CodeNotFound,
        Message:     fmt.Sprintf("%s not found", resource),
        StatusCode:  http.StatusNotFound,
        Operational: true,
        Context:     map[string]interface{}{"resource": resource, "id": id},
        Timestamp:   time.Now(),
    }
}

func NewInternal(message string, cause error) *AppError {
    return &AppError{
        Code:        CodeInternal,
        Message:     message,
        StatusCode:  http.StatusInternalServerError,
        Operational: false,
        Err:         cause,
        Timestamp:   time.Now(),
    }
}

func NewExternalService(service string, cause error) *AppError {
    return &AppError{
        Code:        CodeExternalService,
        Message:     fmt.Sprintf("External service '%s' is temporarily unavailable", service),
        StatusCode:  http.StatusBadGateway,
        Operational: true,
        Context:     map[string]interface{}{"service": service},
        Err:         cause,
        Timestamp:   time.Now(),
    }
}

type FieldError struct {
    Field   string `json:"field"`
    Message string `json:"message"`
}
```

### Step 3: Error Boundary Implementation
Implement error boundaries at different layers of the application:

#### Error Boundary — React
```tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode | ((error: Error, reset: () => void) => ReactNode);
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
  isolationKey?: string;  // reset boundary when key changes
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log to error tracking service
    logger.error('React error boundary caught error', {
      error: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
    });

    // Report to Sentry/Bugsnag
    errorReporter.captureException(error, {
      contexts: { react: { componentStack: errorInfo.componentStack } },
    });

    this.props.onError?.(error, errorInfo);
  }

  componentDidUpdate(prevProps: ErrorBoundaryProps) {
    if (prevProps.isolationKey !== this.props.isolationKey) {
      this.reset();
    }
  }

  reset = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError && this.state.error) {
      if (typeof this.props.fallback === 'function') {
        return this.props.fallback(this.state.error, this.reset);
      }
      return this.props.fallback || <DefaultErrorFallback error={this.state.error} reset={this.reset} />;
    }
    return this.props.children;
  }
}

// Default fallback UI
function DefaultErrorFallback({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div role="alert" className="error-boundary-fallback">
      <h2>Something went wrong</h2>
      <p>We're sorry for the inconvenience. Please try again.</p>
      <button onClick={reset}>Try Again</button>
      {process.env.NODE_ENV === 'development' && (
        <pre style={{ whiteSpace: 'pre-wrap', marginTop: 16 }}>
          {error.message}
          {'\n'}
          {error.stack}
        </pre>
      )}
    </div>
  );
}

// Usage: Layered error boundaries
function App() {
  return (
    <ErrorBoundary fallback={<AppCrashScreen />}>
      <Layout>
        {/* Page-level boundary */}
        <ErrorBoundary
          fallback={(error, reset) => <PageError error={error} onRetry={reset} />}
          isolationKey={location.pathname}
        >
          <Routes />
        </ErrorBoundary>

        {/* Widget-level boundary: sidebar doesn't crash the page */}
        <ErrorBoundary fallback={<SidebarPlaceholder />}>
          <Sidebar />
        </ErrorBoundary>
      </Layout>
    </ErrorBoundary>
  );
}
```

#### Error Boundary — Express.js Global Error Handler
```javascript
// Error handling middleware — MUST be registered last (after all routes)
function globalErrorHandler(err, req, res, next) {
  // Attach request context
  if (err instanceof AppError) {
    err.requestId = req.id;
  }

  // Determine if this is an operational error or a bug
  const isOperational = err instanceof AppError && err.isOperational;

  // Log the error
  if (isOperational) {
    logger.warn('Operational error', {
      ...err.toLog(),
      method: req.method,
      path: req.path,
      userId: req.user?.id,
      ip: req.ip,
    });
  } else {
    // Programmer error — this is a bug, log at error level
    logger.error('Unexpected error', {
      error: err.name || 'Error',
      message: err.message,
      stack: err.stack,
      method: req.method,
      path: req.path,
      userId: req.user?.id,
      requestId: req.id,
    });

    // Report to Sentry
    Sentry.captureException(err, {
      tags: { requestId: req.id, path: req.path },
      user: { id: req.user?.id },
    });
  }

  // Send response
  if (err instanceof AppError) {
    const response = err.toResponse();
    if (err instanceof RateLimitError) {
      res.set('Retry-After', String(err.retryAfter));
    }
    return res.status(err.statusCode).json(response);
  }

  // Unknown error — generic 500
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred. Please try again later.',
      requestId: req.id,
    },
  });
}

// Async error wrapper — catches promise rejections in route handlers
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// 404 handler — registered after all routes, before error handler
function notFoundHandler(req, res, next) {
  next(new NotFoundError('Route', `${req.method} ${req.path}`));
}

// Process-level error handlers
process.on('unhandledRejection', (reason, promise) => {
  logger.fatal('Unhandled promise rejection', {
    reason: reason instanceof Error ? reason.message : reason,
    stack: reason instanceof Error ? reason.stack : undefined,
  });
  Sentry.captureException(reason);
  // Don't exit — let the process handle remaining requests
  // But this is a bug — it should be fixed
});

process.on('uncaughtException', (error) => {
  logger.fatal('Uncaught exception — process will exit', {
    error: error.message,
    stack: error.stack,
  });
  Sentry.captureException(error);

  // Graceful shutdown: stop accepting new requests, finish in-flight
  server.close(() => {
    process.exit(1);
  });

  // Force exit after 10s if graceful shutdown fails
  setTimeout(() => process.exit(1), 10000);
});

// Setup
app.use(asyncHandler(routes));
app.use(notFoundHandler);
app.use(globalErrorHandler);
```

#### Error Handling — Go (http middleware)
```go
package middleware

import (
    "encoding/json"
    "errors"
    "net/http"

    "myapp/apperr"
    "myapp/logger"
)

// ErrorHandler is the global HTTP error handling middleware
func ErrorHandler(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Use panic recovery as a safety net
        defer func() {
            if rec := recover(); rec != nil {
                var err error
                switch v := rec.(type) {
                case error:
                    err = v
                case string:
                    err = errors.New(v)
                default:
                    err = fmt.Errorf("unknown panic: %v", v)
                }

                logger.Error("Panic recovered",
                    "error", err.Error(),
                    "stack", string(debug.Stack()),
                    "method", r.Method,
                    "path", r.URL.Path,
                    "requestId", RequestIDFromContext(r.Context()),
                )

                sentry.CaptureException(err)

                writeErrorResponse(w, apperr.NewInternal("internal error", err))
            }
        }()

        next.ServeHTTP(w, r)
    })
}

// HandleError writes an appropriate error response
func HandleError(w http.ResponseWriter, r *http.Request, err error) {
    var appErr *apperr.AppError
    if errors.As(err, &appErr) {
        appErr.RequestID = RequestIDFromContext(r.Context())

        if appErr.IsOperational() {
            logger.Warn("Operational error",
                "code", appErr.Code,
                "message", appErr.Message,
                "requestId", appErr.RequestID,
            )
        } else {
            logger.Error("Unexpected error",
                "code", appErr.Code,
                "message", appErr.Message,
                "requestId", appErr.RequestID,
                "cause", appErr.Unwrap(),
            )
            sentry.CaptureException(appErr)
        }

        writeErrorResponse(w, appErr)
        return
    }

    // Unknown error — wrap as internal
    internalErr := apperr.NewInternal("unexpected error", err)
    internalErr.RequestID = RequestIDFromContext(r.Context())

    logger.Error("Untyped error",
        "error", err.Error(),
        "requestId", internalErr.RequestID,
    )
    sentry.CaptureException(err)

    writeErrorResponse(w, internalErr)
}

func writeErrorResponse(w http.ResponseWriter, err *apperr.AppError) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(err.HTTPStatusCode())
    json.NewEncoder(w).Encode(err.ToResponse())
}

// Usage in handlers
func GetUserHandler(w http.ResponseWriter, r *http.Request) {
    userID := chi.URLParam(r, "id")

    user, err := userService.GetByID(r.Context(), userID)
    if err != nil {
        HandleError(w, r, err)
        return
    }

    json.NewEncoder(w).Encode(user)
}
```

### Step 4: Structured Error Responses
Design consistent error response formats across all APIs:

#### Standard Error Response Format
```
STRUCTURED ERROR RESPONSE:

Success response (for reference):
{
  "data": { ... },
  "meta": { "requestId": "req_abc123" }
}

Error response (single error):
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "requestId": "req_abc123"
  }
}

Error response (validation — multiple field errors):
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "fields": [
      { "field": "email", "message": "Must be a valid email address" },
      { "field": "age", "message": "Must be between 13 and 150" }
    ],
    "requestId": "req_abc123"
  }
}

Error response (rate limiting):
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "retryAfter": 30,
    "requestId": "req_abc123"
  }
}
Headers: Retry-After: 30

Error response (internal — safe message):
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred. Please try again later.",
    "requestId": "req_abc123"
  }
}
Note: Internal details (stack trace, SQL error, etc.) NEVER appear in response.
      They go to logs, referenced by requestId.

RULES:
  1. Always include a machine-readable "code" (for client-side switch statements)
  2. Always include a human-readable "message" (for display or debugging)
  3. Always include "requestId" (for correlation with server logs)
  4. Validation errors list individual field failures
  5. Internal errors use a generic message — details stay in logs
  6. Never expose stack traces, SQL queries, or file paths in responses
  7. Use appropriate HTTP status codes (don't send 200 with error body)
```

#### Error Code Registry
```
ERROR CODE REGISTRY:
┌──────────────────────────────────────────────────────────────┐
│  Code                     │ HTTP │ Description               │
│  ─────────────────────────────────────────────────────────── │
│  VALIDATION_ERROR         │ 400  │ Input validation failed   │
│  INVALID_JSON             │ 400  │ Request body not valid JSON│
│  MISSING_FIELD            │ 400  │ Required field missing    │
│  AUTHENTICATION_REQUIRED  │ 401  │ No valid credentials      │
│  TOKEN_EXPIRED            │ 401  │ Auth token has expired    │
│  FORBIDDEN                │ 403  │ Insufficient permissions  │
│  NOT_FOUND                │ 404  │ Resource does not exist   │
│  METHOD_NOT_ALLOWED       │ 405  │ HTTP method not supported │
│  CONFLICT                 │ 409  │ Resource state conflict   │
│  DUPLICATE_ENTRY          │ 409  │ Unique constraint violated│
│  PAYLOAD_TOO_LARGE        │ 413  │ Request body too large    │
│  UNPROCESSABLE_ENTITY     │ 422  │ Valid JSON, invalid data  │
│  RATE_LIMIT_EXCEEDED      │ 429  │ Too many requests         │
│  INTERNAL_ERROR           │ 500  │ Unexpected server error   │
│  EXTERNAL_SERVICE_ERROR   │ 502  │ Upstream service failed   │
│  SERVICE_UNAVAILABLE      │ 503  │ Server temporarily down   │
│  TIMEOUT                  │ 504  │ Request timed out         │
└──────────────────────────────────────────────────────────────┘
```

### Step 5: Error Logging and Aggregation
Design error logging that enables fast debugging:

#### Error Logging Rules
```
ERROR LOGGING RULES:

1. Log at the boundary, not at every level
   BAD:  function A catches, logs, re-throws → function B catches, logs, re-throws
   GOOD: function A throws → function B throws → global handler catches and logs once

2. Include context, not just the error message
   BAD:  logger.error("Payment failed")
   GOOD: logger.error("Payment failed", {
           orderId: "ord_123",
           amount: 99.99,
           gateway: "stripe",
           error: err.message,
           requestId: "req_abc",
         })

3. Use structured logging (JSON), not string interpolation
   BAD:  logger.error(`Error processing order ${orderId}: ${err.message}`)
   GOOD: logger.error("Error processing order", { orderId, error: err.message })

4. Separate what the user sees from what you log
   User sees: "Payment could not be processed. Please try again."
   You log:   { code: "EXTERNAL_SERVICE_ERROR", service: "stripe",
                error: "card_declined", decline_code: "insufficient_funds",
                orderId: "ord_123", userId: "usr_456", requestId: "req_abc" }

5. Never log sensitive data
   NEVER: credit card numbers, passwords, tokens, SSNs, full IP addresses
   MASK:  logger.info("User login", { email: mask(user.email), ip: anonymize(ip) })

6. Include the error chain (cause)
   logger.error("Order processing failed", {
     error: err.message,
     cause: err.cause?.message,
     causeStack: err.cause?.stack,
     requestId: req.id,
   })
```

#### Error Aggregation Pattern
```
ERROR AGGREGATION PIPELINE:

Application → Structured Logs → Log Shipper → Aggregation → Alerts
                                    │
                   ┌────────────────┼────────────────┐
                   ↓                ↓                ↓
              ELK Stack         Loki/Grafana      CloudWatch
              (Elasticsearch    (Lightweight,      (AWS native,
               Logstash          Prometheus-like    auto-scaling)
               Kibana)           label-based)

Grouping strategy:
  1. Group by error code (VALIDATION_ERROR, NOT_FOUND, etc.)
  2. Within code, group by stack trace fingerprint
  3. Within fingerprint, show timeline and affected users

Alert rules:
  - Error rate > 1% of requests for 5 minutes → WARN
  - Error rate > 5% of requests for 2 minutes → CRITICAL
  - New error code never seen before → INFO (investigate)
  - Single user hitting > 10 errors/minute → Rate limit check
  - 5xx errors > 0.1% for 10 minutes → SLO burn alert
```

### Step 6: User-Facing vs Internal Errors

```
USER-FACING ERROR MESSAGE GUIDELINES:

Principles:
  1. Be helpful, not technical — the user didn't cause a NullPointerException
  2. Be specific when possible — "Email is already registered" > "Invalid input"
  3. Suggest next steps — "Please try again" or "Contact support"
  4. Don't blame the user — "We couldn't process..." not "You entered..."
  5. Don't leak internals — no SQL errors, no stack traces, no server paths

TRANSLATION TABLE:
┌──────────────────────────────────────────────────────────────┐
│  Internal Error              │ User-Facing Message            │
│  ─────────────────────────────────────────────────────────── │
│  UNIQUE_VIOLATION on email   │ This email is already          │
│                              │ registered. Try signing in.    │
│  CONNECTION_REFUSED to DB    │ We're experiencing technical   │
│                              │ difficulties. Please try again.│
│  TIMEOUT to payment API      │ Payment processing is taking   │
│                              │ longer than expected. We'll    │
│                              │ email you when it's confirmed. │
│  JSON_PARSE_ERROR            │ The request couldn't be        │
│                              │ processed. Please check your   │
│                              │ input and try again.           │
│  OUT_OF_MEMORY               │ We're experiencing high demand.│
│                              │ Please try again in a moment.  │
│  SSL_HANDSHAKE_FAILED        │ We're having trouble connecting│
│                              │ to a required service. Please  │
│                              │ try again shortly.             │
│  FOREIGN_KEY_VIOLATION       │ This item is currently in use  │
│                              │ and cannot be deleted.         │
│  NullPointerException        │ Something went wrong. Our team │
│                              │ has been notified.             │
└──────────────────────────────────────────────────────────────┘
```

### Step 7: Framework-Specific Global Error Handling

#### Next.js (App Router)
```typescript
// app/error.tsx — Page-level error boundary
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Report to error tracking
    Sentry.captureException(error);
  }, [error]);

  return (
    <div className="error-page">
      <h2>Something went wrong</h2>
      <p>We've been notified and are looking into it.</p>
      <button onClick={reset}>Try Again</button>
      {error.digest && (
        <p className="error-id">Error ID: {error.digest}</p>
      )}
    </div>
  );
}

// app/global-error.tsx — Root layout error boundary
'use client';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html>
      <body>
        <h2>Something went wrong</h2>
        <button onClick={reset}>Try Again</button>
      </body>
    </html>
  );
}

// app/not-found.tsx — 404 handler
export default function NotFound() {
  return (
    <div>
      <h2>Page Not Found</h2>
      <p>The page you're looking for doesn't exist.</p>
      <Link href="/">Go Home</Link>
    </div>
  );
}
```

#### NestJS
```typescript
import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();
    const requestId = request.id;

    let status: number;
    let code: string;
    let message: string;

    if (exception instanceof AppError) {
      status = exception.statusCode;
      code = exception.code;
      message = exception.isOperational
        ? exception.message
        : 'An unexpected error occurred';

      if (exception.isOperational) {
        this.logger.warn('Operational error', { ...exception.toLog(), requestId });
      } else {
        this.logger.error('Unexpected error', { ...exception.toLog(), requestId });
      }
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      code = `HTTP_${status}`;
      message = exception.message;
      this.logger.warn('HTTP exception', { status, message, requestId });
    } else {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      code = 'INTERNAL_ERROR';
      message = 'An unexpected error occurred';
      this.logger.error('Unhandled exception', {
        error: exception instanceof Error ? exception.message : String(exception),
        stack: exception instanceof Error ? exception.stack : undefined,
        requestId,
      });
    }

    response.status(status).json({
      error: { code, message, requestId },
    });
  }
}

// Register globally in main.ts
app.useGlobalFilters(new GlobalExceptionFilter());
```

#### Python (FastAPI)
```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
import traceback
import uuid

app = FastAPI()

class AppError(Exception):
    def __init__(self, code: str, message: str, status_code: int = 500,
                 operational: bool = True, context: dict = None):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.operational = operational
        self.context = context or {}
        super().__init__(message)

class ValidationError(AppError):
    def __init__(self, fields: list[dict]):
        super().__init__(
            code="VALIDATION_ERROR",
            message="Validation failed",
            status_code=400,
            context={"fields": fields},
        )
        self.fields = fields

class NotFoundError(AppError):
    def __init__(self, resource: str, identifier):
        super().__init__(
            code="NOT_FOUND",
            message=f"{resource} not found",
            status_code=404,
            context={"resource": resource, "identifier": str(identifier)},
        )

# Global exception handlers
@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    request_id = getattr(request.state, "request_id", "unknown")

    if exc.operational:
        logger.warning("Operational error",
                       code=exc.code, message=exc.message,
                       request_id=request_id, context=exc.context)
    else:
        logger.error("Unexpected error",
                     code=exc.code, message=exc.message,
                     request_id=request_id, traceback=traceback.format_exc())
        sentry_sdk.capture_exception(exc)

    body = {
        "error": {
            "code": exc.code,
            "message": exc.message if exc.operational else
                       "An unexpected error occurred. Please try again later.",
            "requestId": request_id,
        }
    }

    if isinstance(exc, ValidationError):
        body["error"]["fields"] = [
            {"field": f["field"], "message": f["message"]}
            for f in exc.fields
        ]

    return JSONResponse(status_code=exc.status_code, content=body)

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    request_id = getattr(request.state, "request_id", "unknown")
    logger.error("Unhandled exception",
                 error=str(exc), request_id=request_id,
                 traceback=traceback.format_exc())
    sentry_sdk.capture_exception(exc)

    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred. Please try again later.",
                "requestId": request_id,
            }
        },
    )

# Request ID middleware
@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request.state.request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    response = await call_next(request)
    response.headers["X-Request-ID"] = request.state.request_id
    return response
```

### Step 8: Error Handling Checklist

```
ERROR HANDLING VERIFICATION CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Category            │ Check                          │ Pass?│
│  ─────────────────────────────────────────────────────────── │
│  Error Hierarchy     │                                │      │
│    [ ] Errors classified as operational vs programmer │      │
│    [ ] Custom error types extend a base AppError     │      │
│    [ ] Each error has code, message, statusCode      │      │
│    [ ] Error types match HTTP semantics (4xx vs 5xx) │      │
│  ─────────────────────────────────────────────────────────── │
│  Error Boundaries    │                                │      │
│    [ ] React error boundaries at page + widget level │      │
│    [ ] Express global error handler registered last  │      │
│    [ ] Async errors caught (asyncHandler wrapper)    │      │
│    [ ] Unhandled rejections and uncaught exceptions   │      │
│        have process-level handlers                   │      │
│    [ ] Go panic recovery middleware in place         │      │
│  ─────────────────────────────────────────────────────────── │
│  Error Responses     │                                │      │
│    [ ] Consistent JSON error format across all APIs  │      │
│    [ ] Error code registry documented                │      │
│    [ ] Request ID included in every error response   │      │
│    [ ] Validation errors list individual field issues│      │
│    [ ] No stack traces or internal details in responses│    │
│    [ ] Rate limit errors include Retry-After header  │      │
│  ─────────────────────────────────────────────────────────── │
│  Error Logging       │                                │      │
│    [ ] Errors logged at boundary, not at every level │      │
│    [ ] Structured (JSON) logging, not string concat  │      │
│    [ ] Context included (userId, requestId, etc.)    │      │
│    [ ] Error chain (cause) preserved and logged      │      │
│    [ ] No sensitive data in logs (PII, passwords)    │      │
│  ─────────────────────────────────────────────────────────── │
│  User Experience     │                                │      │
│    [ ] User-facing messages are helpful and actionable│     │
│    [ ] Internal errors show generic "oops" message   │      │
│    [ ] Error pages have retry/home navigation        │      │
│    [ ] Error messages don't blame the user           │      │
└──────────────────────────────────────────────────────────────┘
```

## Output
- Error handling design at `docs/errors/<service>-error-handling.md`
- Error type definitions in source directory
- Commit: `"errorhandling: <service> — <patterns applied> (<coverage>)"`

## Chaining
- **From `/godmode:build`:** Build encounters unhandled errors → design error handling with `/godmode:errorhandling`
- **From `/godmode:errorhandling` to `/godmode:errortrack`:** After implementing error handling, set up error tracking
- **From `/godmode:errorhandling` to `/godmode:logging`:** After error hierarchy, implement structured logging
- **From `/godmode:review`:** Code review flags missing error handling → apply `/godmode:errorhandling` patterns
- **From `/godmode:api`:** API design needs consistent error responses → use `/godmode:errorhandling` format

## Anti-Patterns

```
ERROR HANDLING ANTI-PATTERNS:
┌──────────────────────────────────────────────────────────────┐
│  Anti-Pattern              │ Why It's Dangerous              │
│  ─────────────────────────────────────────────────────────── │
│  Empty catch blocks        │ Errors silently disappear,      │
│  catch(err) {}             │ making bugs invisible           │
│  Log and re-throw          │ Same error logged multiple times│
│  at every layer            │ across the call stack           │
│  Catch-all returns null    │ Caller doesn't know why null    │
│  catch(err) { return null }│ was returned, can't handle it   │
│  String-based error checks │ Brittle — message text changes  │
│  if (err.msg.includes(...))│ break your error handling       │
│  Expose internals to user  │ Stack traces, SQL errors, paths │
│  in API responses          │ help attackers, confuse users   │
│  Boolean error returns     │ Caller gets false but no info   │
│  return { ok: false }      │ about what failed or why        │
│  Generic error for all     │ Every error is "Something went  │
│  situations                │ wrong" — no debugging info      │
│  Retry programmer errors   │ TypeError won't succeed on      │
│                            │ retry — you're hiding a bug     │
│  Error handling in business│ Validation, auth, and business  │
│  logic                     │ rules mixed with try/catch      │
└──────────────────────────────────────────────────────────────┘
```
