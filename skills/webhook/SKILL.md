---
name: webhook
description: >
  Webhook design, delivery, retry, HMAC verification,
  event subscriptions, dead letter queues.
---

# Webhook -- Design, Delivery & Security

## Activate When
- `/godmode:webhook`, "webhook delivery", "callback URL"
- "verify webhook signature", "retry failed webhooks"
- "dead letter queue", "event notifications"
- When API needs to notify external systems

## Workflow

### Step 1: Discovery
```bash
# Detect webhook libraries and patterns
grep -r "svix\|standardwebhooks\|hmac\|createHmac" \
  package.json src/ --include="*.ts" -l 2>/dev/null
grep -r "webhook" --include="*.sql" \
  --include="*.prisma" -l 2>/dev/null
# Check queue integration
grep -r "BullMQ\|bull\|celery\|SQS\|amqplib" \
  package.json 2>/dev/null
```
```
WEBHOOK DISCOVERY:
Direction: Inbound | Outbound | Both
Events: <list event types>
Volume: <events/sec, daily total>
Latency SLA: <max delay>
Delivery: At-least-once | Best-effort
Auth: HMAC-SHA256 | mTLS | bearer token

IF inbound only: skip delivery system (Step 4)
IF outbound only: skip inbound handler (Step 3)
IF volume > 1000/sec: add partitioned queue
IF volume < 10/min: simple async dispatch OK
```

### Step 2: Event & Payload Design
```
NAMING: <resource>.<past_tense_verb>
  e.g., order.created, payment.completed

ENVELOPE:
  id: evt_<ULID> (unique, sortable)
  type: resource.verb
  api_version: 2025-01-15
  created_at: ISO 8601 UTC
  data: { object: {...}, previous_attributes: {} }
  livemode: true|false

RULES:
  Max payload: 64KB
  Monetary values: cents (integer)
  Timestamps: ISO 8601 UTC
  NEVER include PII or secrets in payloads
  IF payload > 64KB: send reference + fetch URL
  WHEN previous state needed: include diff
```

### Step 3: Inbound Webhook Handling
```
HANDLER PATTERN (strict order):
1. Verify HMAC-SHA256 signature
   Use raw bytes, constant-time comparison
   IF invalid: return 401 immediately
2. Check timestamp (5 min tolerance window)
   IF stale (>300s drift): return 403
3. Check idempotency (event ID seen?)
   IF duplicate: return 200 (already processed)
4. Parse payload, route to handler
5. Process in transaction
6. Return 200 within 5s timeout
   IF heavy work: offload to queue

SSRF PREVENTION (inbound callback URLs):
  Resolve DNS before connecting
  Block: 127.0.0.0/8, 10.0.0.0/8,
    172.16.0.0/12, 192.168.0.0/16,
    169.254.0.0/16, ::1
  Re-check on every retry
```

### Step 4: Outbound Delivery System
```
PIPELINE:
  Event Source -> Dispatcher -> Worker -> Endpoint
  Delivery Log    Retry Queue (exp backoff)
                      |
                 Dead Letter Queue

RETRY: 10 attempts over ~3 days
  Delays: 0s, 10s, 30s, 1m, 5m, 15m, 1h, 4h, 8h, 24h
  Jitter: random 0.5x-1.5x multiplier
  IF 5xx, 408, 429, timeout, DNS fail: retry
  IF 4xx (except 408/429): do NOT retry
  WHEN Retry-After header present: honor it

CIRCUIT BREAKER (per endpoint):
  CLOSED -> 5 consecutive failures -> OPEN
  OPEN: queue events, alert owner
  After 30 min -> HALF-OPEN (test 1 event)
  IF 2 successes -> CLOSED
  IF failure -> OPEN again
  Auto-disable after 72 hours open
```

### Step 5: Dead Letter Queue
```
Events land here after max retries (10)
  or prolonged circuit break (>72h)
Retention: 30 days
API: replay single, replay bulk, export, purge
WHEN DLQ grows > 1000 entries: alert + analyze
```

### Step 6: Subscription API
```
POST/GET   /api/v1/webhooks         Create/list
GET/PATCH  /api/v1/webhooks/:id     Get/update
DELETE     /api/v1/webhooks/:id     Delete
POST       /api/v1/webhooks/:id/test  Test ping
POST       /api/v1/webhooks/:id/rotate  Rotate secret
GET        /api/v1/webhooks/:id/deliveries  History

LIMITS:
  HTTPS only (no HTTP in production)
  Public IP only (SSRF block)
  Max 100 event types per subscription
  Max 20 subscriptions per account
  Event filtering: ["*"], ["order.*"], specific

WHEN subscription created: send test ping
IF test ping fails: warn but allow save
```

### Step 7: Secret Rotation
```
Dual-secret zero-downtime rotation:
  Phase 1: sign with both old + new secret
  Phase 2: grace period 24-72 hours
  Phase 3: revoke old secret
Secret shown ONCE at creation.
Rotation cadence: 90 days recommended.
IF >180 days since rotation: warn in dashboard
```

### Step 8: Database Schema
```sql
-- Core tables
webhook_subscriptions (
  id, account_id, url, events JSONB,
  secret_current, secret_previous,
  circuit_state, failure_count,
  disabled_at, created_at, updated_at
)
webhook_events (id, type, data JSONB, created_at)
webhook_deliveries (
  id, event_id, subscription_id,
  status, attempts, next_retry_at,
  response_code, response_body_preview,
  created_at
)
webhook_dead_letter (
  delivery_id, reason, replayed_at
)

Indexes: subscription(account_id),
  delivery(event_id, subscription_id),
  delivery(status, next_retry_at)
```

### Step 9: Monitoring
```
METRICS (alert thresholds):
  Delivery success rate: target >99%
    IF <95%: P1 alert
  First-attempt success: target >95%
    IF <90%: investigate endpoint health
  P50 delivery latency: <500ms
  P99 delivery latency: <5s
  DLQ entries: alert if >100 pending
  Open circuit breakers: alert if >0
  Retry queue depth: alert if >10000
```

### Step 10: Commit
Commit: `"webhook: <desc> -- <components>"`

## Key Behaviors
1. **Sign everything.** HMAC-SHA256 on every delivery.
2. **Retry with backoff + jitter.** 10 retries, 3 days.
3. **Circuit break bad endpoints.** Stop hammering.
4. **Dead letter with replay.** No silent data loss.
5. **Verify on receive.** Raw bytes, constant-time.
6. **Idempotency mandatory.** Both inbound and outbound.
7. **HTTPS only.** Block private IPs (SSRF).
8. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER deliver webhooks synchronously in request.
2. NEVER retry on 4xx (except 408/429).
3. NEVER use simple string comparison for HMAC.
   Constant-time only (timingSafeEqual).
4. NEVER parse body before verifying signature.
5. NEVER allow HTTP webhook URLs in production.
6. NEVER skip SSRF checks on callback URLs.
7. ALWAYS send failed events to DLQ.
8. ALWAYS add jitter to retry delays.

## Auto-Detection
```bash
grep -r "svix\|standardwebhooks" package.json \
  2>/dev/null
grep -r "createHmac\|timingSafeEqual" \
  src/ --include="*.ts" -l 2>/dev/null
grep -r "webhook" migrations/ --include="*.sql" \
  -l 2>/dev/null
```

## TSV Logging
Log to `.godmode/webhook-results.tsv`:
`timestamp\tproject\tdirection\tevent_types\tretry\tdlq\tssrf\tcommit`

## Output Format
```
Webhook: {endpoints} endpoints, {issues} issues
  -> {fixed} fixed. Status: {DONE|PARTIAL}.
```

## Keep/Discard Discipline
```
KEEP if: delivery succeeds AND retry works
  AND idempotency verified AND HMAC validates
DISCARD if: delivery fails after 10 retries
  OR duplicate processing detected
  Revert: git reset --hard HEAD~1
```

## Stop Conditions
```
STOP when FIRST of:
  - All endpoints verified (retry + idempotency)
  - Max iterations reached (budget exhausted)
  - 3 consecutive iterations <1% improvement
  - >5 consecutive discards
```
