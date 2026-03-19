# /godmode:errorhandling

Error handling architecture design. Creates error hierarchies, implements error boundaries, designs structured error responses, and sets up global error handling patterns. Separates operational errors from programmer errors and user-facing messages from internal details.

## Usage

```
/godmode:errorhandling                     # Full error handling architecture design
/godmode:errorhandling --hierarchy         # Design error type hierarchy
/godmode:errorhandling --boundary          # Implement error boundaries (React, Express, Go)
/godmode:errorhandling --response          # Design structured error response format
/godmode:errorhandling --logging           # Error logging and aggregation strategy
/godmode:errorhandling --user-facing       # User-facing vs internal error messages
/godmode:errorhandling --global            # Framework-specific global error handlers
/godmode:errorhandling --audit             # Audit existing error handling for gaps
```

## What It Does

1. Classifies all errors as operational (expected, recoverable) vs programmer (bugs, not recoverable)
2. Designs a typed error hierarchy with base AppError, codes, HTTP status mapping, and serialization (toLog/toResponse)
3. Implements error boundaries at multiple layers: React component boundaries, Express global handler, Go panic recovery
4. Creates consistent structured error response format with code, message, requestId, and field-level validation details
5. Establishes error code registry mapping every error code to its HTTP status and description
6. Separates user-facing error messages (helpful, actionable, no internals) from internal logging (detailed, contextual, structured)
7. Implements framework-specific global error handling (Express, NestJS, Next.js, FastAPI, Go net/http)
8. Designs error logging rules: log at the boundary, include context, use structured format, preserve error chain

## Output
- Error handling design at `docs/errors/<service>-error-handling.md`
- Error type definitions in source directory
- Commit: `"errorhandling: <service> — <patterns applied> (<coverage>)"`

## Error Classification

| Category | Examples | Handle | Retry? | User Message |
|----------|----------|--------|--------|-------------|
| Operational | Timeout, 429, DNS failure | Return/degrade | Often | Helpful, specific |
| Programmer | TypeError, null deref, assertion | Log + alert | Never | Generic "oops" |

## Next Step
After error hierarchy: `/godmode:logging` to implement structured error logging.
After implementation: `/godmode:errortrack` to set up error tracking and aggregation.
If errors indicate resilience gaps: `/godmode:resilience` to add circuit breakers and retries.

## Examples

```
/godmode:errorhandling                     # Full error handling architecture
/godmode:errorhandling --hierarchy         # Design TypeScript error class hierarchy
/godmode:errorhandling --boundary          # Add React error boundaries + Express global handler
/godmode:errorhandling --response          # Standardize API error response format
/godmode:errorhandling --audit             # Find missing error handling in codebase
```
