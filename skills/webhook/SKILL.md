---
name: webhook
description: Webhook design, delivery, retry strategies, HMAC verification, event subscriptions. Use when user mentions webhooks, event delivery, callback URLs, webhook signatures, webhook retry.
---

# Webhook — Design, Delivery & Security

## When to Activate
- User invokes `/godmode:webhook`
- User says "set up webhooks", "add webhook support", "webhook delivery"
- User says "verify webhook signature", "HMAC verification", "webhook security"
- User says "retry failed webhooks", "dead letter queue", "webhook reliability"
- User says "subscribe to events", "event notifications", "callback URL"
- When `/godmode:plan` identifies webhook or event delivery tasks
- When `/godmode:api` designs endpoints that need to notify external systems
- When `/godmode:event` architecture requires pushing events to consumers

## Workflow

### Step 1: Discovery & Context
Understand the webhook requirements before designing anything:

```
WEBHOOK DISCOVERY:
Project: <name and purpose>
Direction: Inbound | Outbound | Both
Events: <list of event types to support — e.g., order.created, payment.completed>
Consumers: <who receives webhooks — third-party apps, partner services, internal>
Producers: <what systems emit events — your API, background jobs, external services>
Volume: <expected events/sec, peak burst, daily total>
Latency SLA: <max acceptable delivery delay — e.g., 30s, 5min>
Delivery guarantee: At-least-once | Best-effort
Auth model: <HMAC-SHA256, mTLS, bearer token, API key>
Existing infra: <message queue, database, cron — what's already available>
Constraints: <compliance, data residency, payload size limits>
```

If the user hasn't specified, ask: "Are you building inbound webhook handling (receiving from external services), outbound delivery (notifying your consumers), or both?"

### Step 2: Event & Payload Design
Define the event types and standardize the payload format:

```
EVENT CATALOG:
┌───────────────────────────┬──────────────────────────────────────────┐
│  Event Type               │  Description                             │
├───────────────────────────┼──────────────────────────────────────────┤
│  <resource>.<action>      │  <when this fires>                       │
│  order.created            │  New order placed                        │
│  order.updated            │  Order modified (status, items, etc.)    │
│  order.cancelled          │  Order cancelled by user or system       │
│  payment.completed        │  Payment successfully captured           │
│  payment.failed           │  Payment attempt failed                  │
│  invoice.generated        │  Invoice created for an order            │
│  user.created             │  New user registration                   │
│  user.deleted             │  User account removed                    │
└───────────────────────────┴──────────────────────────────────────────┘

NAMING CONVENTION: <resource>.<past_tense_verb>
- Use dot notation: resource.action
- Resource is singular noun: order, payment, user
- Action is past tense: created, updated, deleted, completed, failed
- Nest for sub-resources: order.item.added, subscription.plan.changed
```

Standardize the webhook payload envelope:

```json
PAYLOAD ENVELOPE:
{
  "id": "evt_01HZ3KQXYZ9876543210",
  "type": "order.created",
  "api_version": "2025-01-15",
  "created_at": "2025-07-15T14:32:00.000Z",
  "data": {
    "object": {
      "id": "ord_abc123",
      "status": "pending",
      "total": 9999,
      "currency": "usd"
    },
    "previous_attributes": {}
  },
  "livemode": true,
  "request": {
    "id": "req_xyz789",
    "idempotency_key": "idk_unique_key_here"
  }
}

PAYLOAD RULES:
- Every event has a globally unique `id` (prefixed: evt_<ULID or UUID>)
- `type` uses dot-separated resource.action naming
- `api_version` pins the payload shape — consumers know what to expect
- `data.object` contains the full resource at the time of the event
- `data.previous_attributes` shows what changed (for update events)
- `created_at` is ISO 8601 UTC — never local time
- Monetary values in smallest unit (cents, not dollars)
- No sensitive data in payloads (PII, secrets, full card numbers)
- Max payload size: 64 KB (reject or truncate if larger)
```

### Step 3: Inbound Webhook Handling
Design the system for receiving webhooks from external services:

```
INBOUND WEBHOOK ENDPOINT:
POST /api/v1/webhooks/inbound/<provider>

SIGNATURE VERIFICATION (HMAC-SHA256):
┌──────────────────────────────────────────────────────────────────────┐
│  1. Extract signature from header:                                   │
│     signature = request.headers["X-Webhook-Signature"]               │
│     (or X-Hub-Signature-256, Stripe-Signature, etc.)                │
│                                                                      │
│  2. Read raw request body (DO NOT parse JSON first):                │
│     raw_body = request.body  // bytes, not parsed object             │
│                                                                      │
│  3. Compute expected signature:                                      │
│     expected = HMAC-SHA256(webhook_secret, raw_body)                 │
│     expected_hex = hex_encode(expected)                               │
│                                                                      │
│  4. Compare using constant-time comparison:                          │
│     if NOT constant_time_equal(signature, expected_hex):             │
│       return 401 Unauthorized                                        │
│                                                                      │
│  5. NEVER use == for signature comparison (timing attack)            │
└──────────────────────────────────────────────────────────────────────┘

REPLAY PREVENTION:
┌──────────────────────────────────────────────────────────────────────┐
│  1. Extract timestamp from header or payload:                        │
│     timestamp = request.headers["X-Webhook-Timestamp"]               │
│                                                                      │
│  2. Reject if too old (tolerance window: 5 minutes):                │
│     if abs(now() - timestamp) > 300 seconds:                         │
│       return 403 Forbidden ("Timestamp outside tolerance")           │
│                                                                      │
│  3. Include timestamp in signature computation:                      │
│     signed_payload = f"{timestamp}.{raw_body}"                       │
│     expected = HMAC-SHA256(secret, signed_payload)                   │
│                                                                      │
│  4. Store processed event IDs (dedup window: 24-72 hours):          │
│     if event_id already in processed_events:                         │
│       return 200 OK (acknowledge but skip processing)                │
│     else:                                                            │
│       insert event_id into processed_events                          │
└──────────────────────────────────────────────────────────────────────┘

IDEMPOTENCY:
- Use the event's unique ID as the idempotency key
- Store processed event IDs in a fast-lookup store (Redis SET or DB unique index)
- On duplicate: return 200 OK immediately — do NOT reprocess
- Retention: keep IDs for 72 hours minimum, then prune
- Processing must be idempotent itself: use DB transactions, upserts, conditional updates

INBOUND HANDLER PATTERN:
1. Verify signature → 401 if invalid
2. Check timestamp tolerance → 403 if stale
3. Check idempotency (event ID already seen?) → 200 if duplicate
4. Parse payload
5. Route to event-specific handler
6. Process inside a transaction
7. Mark event ID as processed
8. Return 200 OK (within 5 seconds — offload heavy work to a queue)
```

```python
# Reference implementation — Inbound webhook handler
import hmac
import hashlib
import time
from functools import wraps

def verify_webhook_signature(payload: bytes, signature: str, secret: str) -> bool:
    """Verify HMAC-SHA256 webhook signature using constant-time comparison."""
    expected = hmac.new(
        secret.encode("utf-8"),
        payload,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(signature, expected)

def verify_webhook_with_timestamp(
    payload: bytes,
    signature: str,
    timestamp: str,
    secret: str,
    tolerance_seconds: int = 300
) -> bool:
    """Verify signature with timestamp to prevent replay attacks."""
    # Check timestamp tolerance
    ts = int(timestamp)
    if abs(time.time() - ts) > tolerance_seconds:
        return False

    # Compute signature over timestamp + payload
    signed_payload = f"{timestamp}.".encode("utf-8") + payload
    expected = hmac.new(
        secret.encode("utf-8"),
        signed_payload,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(signature, expected)
```

### Step 4: Outbound Webhook Delivery System
Design the full outbound delivery pipeline:

```
OUTBOUND DELIVERY ARCHITECTURE:

  ┌──────────┐     ┌──────────────┐     ┌───────────────┐     ┌──────────────┐
  │  Event    │────▶│  Webhook     │────▶│  Delivery     │────▶│  Consumer    │
  │  Source   │     │  Dispatcher  │     │  Worker       │     │  Endpoint    │
  └──────────┘     └──────────────┘     └───────────────┘     └──────────────┘
                          │                     │
                          │                     ▼
                          │              ┌───────────────┐
                          │              │  Retry Queue  │
                          │              │  (exp backoff)│
                          │              └───────────────┘
                          │                     │
                          ▼                     ▼
                   ┌──────────────┐     ┌───────────────┐
                   │  Delivery    │     │  Dead Letter   │
                   │  Log (DB)    │     │  Queue (DLQ)  │
                   └──────────────┘     └───────────────┘

FLOW:
1. Event source emits event (API action, background job, etc.)
2. Webhook dispatcher fans out: one delivery per active subscription matching the event type
3. Delivery worker sends HTTP POST to the consumer's endpoint
4. On success (2xx): log success, done
5. On failure (non-2xx, timeout, network error): enqueue for retry
6. After all retries exhausted: move to dead letter queue, notify subscription owner
```

#### Retry Strategy
```
RETRY STRATEGY — Exponential Backoff with Jitter:

RETRY SCHEDULE:
┌─────────┬────────────┬──────────────────────┐
│  Attempt│  Delay     │  With Jitter         │
├─────────┼────────────┼──────────────────────┤
│  1      │  Immediate │  0s                  │
│  2      │  10s       │  5-15s               │
│  3      │  30s       │  15-45s              │
│  4      │  1 min     │  30s-90s             │
│  5      │  5 min     │  2.5-7.5 min         │
│  6      │  15 min    │  7.5-22.5 min        │
│  7      │  1 hour    │  30-90 min           │
│  8      │  4 hours   │  2-6 hours           │
│  9      │  8 hours   │  4-12 hours          │
│  10     │  24 hours  │  12-36 hours         │
└─────────┴────────────┴──────────────────────┘

TOTAL WINDOW: ~3 days of retry attempts
MAX RETRIES: 10 (configurable per subscription)

BACKOFF FORMULA:
  delay = base_delay * (2 ^ attempt_number)
  jitter = random(0.5 * delay, 1.5 * delay)
  capped = min(jitter, max_delay)

RETRY CONDITIONS:
- Retry on: 5xx, 408, 429, connection timeout, DNS failure
- Do NOT retry on: 2xx (success), 4xx except 408/429 (client error — fix payload)
- Honor Retry-After header from 429 responses
- Record each attempt with status code, response body (first 1KB), latency
```

#### Circuit Breaker
```
CIRCUIT BREAKER — Per Consumer Endpoint:

STATES:
┌──────────┐   failure threshold   ┌──────────┐   recovery timeout   ┌───────────────┐
│  CLOSED  │──────────────────────▶│  OPEN    │──────────────────────▶│  HALF-OPEN    │
│  (normal)│                       │  (stop)  │                       │  (test one)   │
└──────────┘                       └──────────┘                       └───────────────┘
     ▲                                                                       │
     │                          success                                      │
     └───────────────────────────────────────────────────────────────────────┘
     │                          failure                                      │
     │                     ┌──────────┐                                      │
     │                     │  OPEN    │◀─────────────────────────────────────┘
     │                     └──────────┘

CONFIGURATION:
- Failure threshold: 5 consecutive failures → OPEN
- Recovery timeout: 30 minutes → HALF-OPEN
- Success threshold in HALF-OPEN: 2 consecutive successes → CLOSED
- When OPEN: queue events, do not attempt delivery
- When transitioning to OPEN: alert the subscription owner via email/dashboard
- Monitor: track circuit state per endpoint, expose in admin dashboard

DISABLED ENDPOINT POLICY:
- If circuit stays OPEN for 72 hours: auto-disable subscription
- Notify owner: "Your webhook endpoint has been disabled due to repeated failures"
- Provide re-enable button/API in dashboard
- On re-enable: send a test ping event before resuming full delivery
```

#### Dead Letter Queue
```
DEAD LETTER QUEUE (DLQ):

WHEN:
- All retry attempts exhausted (10 retries over ~3 days)
- Circuit breaker open for > 72 hours
- Payload rejected with 410 Gone (endpoint permanently removed)

STRUCTURE:
{
  "dlq_entry_id": "dlq_01HZ3...",
  "webhook_delivery_id": "del_01HZ3...",
  "subscription_id": "sub_01HZ3...",
  "event": { ... full event payload ... },
  "last_attempt": {
    "status_code": 503,
    "response_body": "Service Unavailable",
    "attempted_at": "2025-07-18T14:32:00Z"
  },
  "total_attempts": 10,
  "reason": "MAX_RETRIES_EXHAUSTED",
  "created_at": "2025-07-18T14:32:00Z",
  "expires_at": "2025-08-17T14:32:00Z"
}

RETENTION: 30 days (configurable)
ACTIONS:
- Manual replay: POST /api/v1/webhooks/dlq/:id/replay
- Bulk replay: POST /api/v1/webhooks/dlq/replay { filter: { subscription_id: "..." } }
- Export: GET /api/v1/webhooks/dlq?subscription_id=...&format=json
- Purge: DELETE /api/v1/webhooks/dlq/:id
```

### Step 5: Webhook Registration API
Design the subscription management API:

```
WEBHOOK SUBSCRIPTION API:

ENDPOINT CATALOG:
┌──────────┬──────────────────────────────────┬──────────────────────────────────────┐
│  Method  │  Path                            │  Description                         │
├──────────┼──────────────────────────────────┼──────────────────────────────────────┤
│  POST    │  /api/v1/webhooks                │  Create a webhook subscription       │
│  GET     │  /api/v1/webhooks                │  List all subscriptions (paginated)  │
│  GET     │  /api/v1/webhooks/:id            │  Get subscription details            │
│  PATCH   │  /api/v1/webhooks/:id            │  Update subscription                 │
│  DELETE  │  /api/v1/webhooks/:id            │  Delete subscription                 │
│  POST    │  /api/v1/webhooks/:id/test       │  Send a test ping event              │
│  POST    │  /api/v1/webhooks/:id/rotate     │  Rotate signing secret               │
│  GET     │  /api/v1/webhooks/:id/deliveries │  List delivery attempts (paginated)  │
│  GET     │  /api/v1/webhooks/:id/deliveries/:did │  Get single delivery detail     │
│  POST    │  /api/v1/webhooks/:id/deliveries/:did/retry │  Manually retry a delivery│
│  GET     │  /api/v1/webhooks/event-types    │  List all available event types      │
└──────────┴──────────────────────────────────┴──────────────────────────────────────┘

CREATE REQUEST:
POST /api/v1/webhooks
{
  "url": "https://example.com/webhook/receiver",
  "events": ["order.created", "order.updated", "payment.completed"],
  "description": "Order processing notifications",
  "active": true,
  "metadata": {
    "team": "payments"
  }
}

CREATE RESPONSE (201 Created):
{
  "id": "wh_01HZ3KQXYZ9876543210",
  "url": "https://example.com/webhook/receiver",
  "events": ["order.created", "order.updated", "payment.completed"],
  "description": "Order processing notifications",
  "active": true,
  "secret": "whsec_a1b2c3d4e5f6...",  ← shown ONCE at creation time
  "metadata": {
    "team": "payments"
  },
  "created_at": "2025-07-15T14:32:00.000Z",
  "updated_at": "2025-07-15T14:32:00.000Z"
}

VALIDATION RULES:
- url: must be HTTPS (reject HTTP in production)
- url: must resolve to a public IP (block private ranges: 10.x, 172.16-31.x, 192.168.x, 127.x, ::1)
- events: must be valid event types from the catalog, or ["*"] for all events
- events: max 100 event types per subscription
- Max subscriptions per account: 20 (configurable)
- url must respond to a verification challenge within 10 seconds of creation

EVENT FILTERING:
- Wildcard: ["*"] — receive all events
- Resource wildcard: ["order.*"] — receive all order events
- Specific: ["order.created", "payment.completed"] — only these events
- Filtering is evaluated at dispatch time — no events queued for non-matching subs
```

### Step 6: Secret Management & Signature Rotation
Design signing secret lifecycle:

```
SIGNING SECRET MANAGEMENT:

GENERATION:
- 32 bytes of cryptographically random data, hex-encoded (64 chars)
- Prefixed: whsec_<random> for easy identification in logs/configs
- Generated server-side — NEVER accept user-provided secrets
- Shown to user ONCE at subscription creation — cannot be retrieved afterward

ROTATION WORKFLOW:
POST /api/v1/webhooks/:id/rotate

DUAL-SECRET ROTATION (zero-downtime):
┌──────────────────────────────────────────────────────────────────────┐
│  Phase 1: Generate new secret, keep old active                       │
│    → Deliveries signed with BOTH secrets (two signatures)            │
│    → Headers: X-Webhook-Signature: v1=<old_sig>,v1=<new_sig>        │
│    → Consumer should verify against ANY matching signature            │
│                                                                      │
│  Phase 2: Grace period (24-72 hours)                                 │
│    → Consumer updates their stored secret to the new one             │
│    → Both secrets still produce valid signatures                     │
│                                                                      │
│  Phase 3: Revoke old secret                                          │
│    → Old secret removed, only new secret signs payloads              │
│    → Consumer must have updated by now                               │
└──────────────────────────────────────────────────────────────────────┘

ROTATION RESPONSE (200 OK):
{
  "id": "wh_01HZ3KQXYZ9876543210",
  "new_secret": "whsec_n3w53cr3t...",   ← shown ONCE
  "old_secret_expires_at": "2025-07-18T14:32:00Z",
  "rotation_status": "in_progress"
}

AUTOMATIC ROTATION:
- Recommend rotation every 90 days
- Send reminder notification at 75 days
- NEVER auto-rotate without warning — breaking change for consumers
```

### Step 7: Security Hardening

```
SECURITY CHECKLIST:
┌──────────────────────────────────────────────────────────────────────┐
│  Control                         │  Implementation                   │
├──────────────────────────────────┼───────────────────────────────────┤
│  HMAC-SHA256 signatures          │  Every outbound delivery signed   │
│  Constant-time comparison        │  hmac.compare_digest / crypto     │
│  Timestamp tolerance (replay)    │  Reject events > 5 min old        │
│  HTTPS only                      │  Reject HTTP webhook URLs         │
│  SSRF prevention                 │  Block private/reserved IPs       │
│  Payload size limit              │  64 KB max, reject larger          │
│  Rate limiting on registration   │  Max 20 subs/account, 5/min create│
│  Secret rotation support         │  Dual-secret window               │
│  IP allowlisting (optional)      │  Publish IP ranges, consumers     │
│                                  │  restrict inbound to those IPs    │
│  mTLS (optional, enterprise)     │  Client cert on delivery requests │
│  Idempotency keys                │  Event ID-based deduplication     │
│  Request timeout                 │  5 second timeout on delivery     │
│  No sensitive data in payload    │  Strip PII, tokens, card numbers  │
│  Audit logging                   │  Log all sub changes, deliveries  │
└──────────────────────────────────┴───────────────────────────────────┘

SSRF PREVENTION — Block these destination IPs:
- 127.0.0.0/8 (loopback)
- 10.0.0.0/8 (private)
- 172.16.0.0/12 (private)
- 192.168.0.0/16 (private)
- 169.254.0.0/16 (link-local / AWS metadata)
- ::1/128 (IPv6 loopback)
- fc00::/7 (IPv6 private)
- Resolve DNS BEFORE connecting — check the resolved IP, not just the hostname
- Re-check on every retry (DNS rebinding attack prevention)

IP ALLOWLISTING (for consumers):
- Publish your outbound IP ranges in a well-known endpoint:
  GET /api/v1/webhooks/ips → { "ipv4": ["203.0.113.0/24"], "ipv6": ["2001:db8::/32"] }
- Update consumers 30 days before IP range changes
- Include in docs and status page
```

### Step 8: Database Schema
Design the persistence layer:

```sql
DATABASE SCHEMA:

-- Webhook subscriptions
CREATE TABLE webhook_subscriptions (
    id              TEXT PRIMARY KEY,          -- wh_<ULID>
    account_id      TEXT NOT NULL,             -- owning account
    url             TEXT NOT NULL,             -- delivery endpoint (HTTPS)
    description     TEXT,
    events          JSONB NOT NULL,            -- ["order.created", "payment.*"]
    signing_secret  TEXT NOT NULL,             -- whsec_<secret> (encrypted at rest)
    previous_secret TEXT,                      -- for rotation grace period
    previous_secret_expires_at TIMESTAMPTZ,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    metadata        JSONB DEFAULT '{}',
    circuit_state   TEXT NOT NULL DEFAULT 'closed', -- closed | open | half_open
    circuit_opened_at TIMESTAMPTZ,
    consecutive_failures INT NOT NULL DEFAULT 0,
    disabled_at     TIMESTAMPTZ,              -- auto-disabled after prolonged failure
    disabled_reason TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_webhook_subs_account ON webhook_subscriptions(account_id);
CREATE INDEX idx_webhook_subs_active ON webhook_subscriptions(active) WHERE active = TRUE;

-- Webhook events (source of truth for what happened)
CREATE TABLE webhook_events (
    id              TEXT PRIMARY KEY,          -- evt_<ULID>
    type            TEXT NOT NULL,             -- order.created
    api_version     TEXT NOT NULL,
    data            JSONB NOT NULL,
    livemode        BOOLEAN NOT NULL DEFAULT TRUE,
    request_id      TEXT,
    idempotency_key TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_webhook_events_type ON webhook_events(type);
CREATE INDEX idx_webhook_events_created ON webhook_events(created_at);

-- Webhook deliveries (one per subscription per event)
CREATE TABLE webhook_deliveries (
    id                  TEXT PRIMARY KEY,      -- del_<ULID>
    event_id            TEXT NOT NULL REFERENCES webhook_events(id),
    subscription_id     TEXT NOT NULL REFERENCES webhook_subscriptions(id),
    status              TEXT NOT NULL DEFAULT 'pending',
                        -- pending | delivering | delivered | failed | dlq
    url                 TEXT NOT NULL,         -- snapshot of URL at delivery time
    request_headers     JSONB,
    request_body        TEXT,
    response_status     INT,
    response_headers    JSONB,
    response_body       TEXT,                  -- first 1 KB only
    latency_ms          INT,
    attempt_number      INT NOT NULL DEFAULT 1,
    max_attempts        INT NOT NULL DEFAULT 10,
    next_retry_at       TIMESTAMPTZ,
    last_attempted_at   TIMESTAMPTZ,
    delivered_at        TIMESTAMPTZ,
    failed_at           TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_deliveries_event ON webhook_deliveries(event_id);
CREATE INDEX idx_deliveries_sub ON webhook_deliveries(subscription_id);
CREATE INDEX idx_deliveries_status ON webhook_deliveries(status);
CREATE INDEX idx_deliveries_retry ON webhook_deliveries(next_retry_at)
    WHERE status = 'pending' OR status = 'failed';

-- Processed inbound events (idempotency / dedup)
CREATE TABLE webhook_inbound_events (
    provider        TEXT NOT NULL,
    event_id        TEXT NOT NULL,
    processed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (provider, event_id)
);
CREATE INDEX idx_inbound_events_expiry ON webhook_inbound_events(processed_at);
-- Prune: DELETE FROM webhook_inbound_events WHERE processed_at < NOW() - INTERVAL '72 hours';

-- Dead letter queue
CREATE TABLE webhook_dead_letter_queue (
    id                  TEXT PRIMARY KEY,      -- dlq_<ULID>
    delivery_id         TEXT NOT NULL REFERENCES webhook_deliveries(id),
    subscription_id     TEXT NOT NULL REFERENCES webhook_subscriptions(id),
    event_id            TEXT NOT NULL REFERENCES webhook_events(id),
    event_payload       JSONB NOT NULL,
    last_status_code    INT,
    last_response_body  TEXT,
    total_attempts      INT NOT NULL,
    reason              TEXT NOT NULL,         -- MAX_RETRIES_EXHAUSTED | CIRCUIT_OPEN | ENDPOINT_GONE
    replayed            BOOLEAN NOT NULL DEFAULT FALSE,
    replayed_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at          TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 days')
);
CREATE INDEX idx_dlq_sub ON webhook_dead_letter_queue(subscription_id);
CREATE INDEX idx_dlq_expires ON webhook_dead_letter_queue(expires_at);
```

### Step 9: Webhook Testing Tools
Design tools for consumers to test and debug their integrations:

```
TESTING TOOLS:

1. TEST PING EVENT:
   POST /api/v1/webhooks/:id/test
   → Sends a synthetic event with type "webhook.test" to the endpoint
   → Returns delivery result immediately (synchronous, no retry)
   → Response:
   {
     "success": true,
     "delivery": {
       "status_code": 200,
       "latency_ms": 145,
       "response_body": "OK"
     }
   }

2. DELIVERY LOG INSPECTOR:
   GET /api/v1/webhooks/:id/deliveries
   → Paginated list of all delivery attempts with status, latency, response
   → Filter: ?status=failed&event_type=order.created&since=2025-07-01

3. REPLAY DELIVERY:
   POST /api/v1/webhooks/:id/deliveries/:did/retry
   → Re-delivers a specific event (resets retry counter)
   → Useful when consumer has fixed their endpoint

4. EVENT CATALOG:
   GET /api/v1/webhooks/event-types
   → Lists all available event types with descriptions and example payloads
   → Response:
   {
     "event_types": [
       {
         "type": "order.created",
         "description": "Fired when a new order is placed",
         "example_payload": { ... }
       }
     ]
   }

5. WEBHOOK SIMULATOR (CLI):
   # Simulate sending a webhook locally for development
   curl -X POST http://localhost:3000/webhook/receiver \
     -H "Content-Type: application/json" \
     -H "X-Webhook-Signature: $(echo -n '{"type":"order.created"}' | \
        openssl dgst -sha256 -hmac 'your_secret' | cut -d' ' -f2)" \
     -H "X-Webhook-Timestamp: $(date +%s)" \
     -d '{"type":"order.created","data":{"object":{"id":"ord_test"}}}'

6. WEBHOOK ENDPOINT VALIDATOR:
   POST /api/v1/webhooks/validate-url
   { "url": "https://example.com/webhook" }
   → Checks: HTTPS, resolves to public IP, responds within 5s, returns 2xx
   → Response: { "valid": true, "checks": { "https": true, "public_ip": true, ... } }
```

### Step 10: Monitoring & Observability

```
MONITORING DASHBOARD:

KEY METRICS:
┌───────────────────────────────────────────────────────────────────┐
│  Metric                           │  Target          │  Alert     │
├───────────────────────────────────┼──────────────────┼────────────┤
│  Delivery success rate            │  > 99%           │  < 95%     │
│  First-attempt success rate       │  > 95%           │  < 90%     │
│  p50 delivery latency             │  < 500ms         │  > 2s      │
│  p99 delivery latency             │  < 5s            │  > 15s     │
│  Events pending delivery          │  < 1,000         │  > 10,000  │
│  DLQ entries (24h)                │  < 10            │  > 100     │
│  Circuit breakers open            │  0               │  > 3       │
│  Disabled subscriptions           │  0               │  > 5       │
│  Retry queue depth                │  < 500           │  > 5,000   │
│  Events emitted per second        │  (baseline)      │  > 2x      │
└───────────────────────────────────┴──────────────────┴────────────┘

ALERTS:
- Delivery success rate drops below 95% (15-min window)
- DLQ receives > 100 entries in 1 hour
- Circuit breaker opens for any subscription
- Retry queue depth exceeds 5,000
- Any subscription auto-disabled
- Signing secret approaching 90-day rotation deadline

STRUCTURED LOG FORMAT:
{
  "level": "info",
  "event": "webhook.delivered",
  "delivery_id": "del_01HZ3...",
  "subscription_id": "wh_01HZ3...",
  "event_type": "order.created",
  "url": "https://example.com/webhook",
  "status_code": 200,
  "latency_ms": 145,
  "attempt": 1,
  "timestamp": "2025-07-15T14:32:00.000Z"
}

DELIVERY STATUS ENDPOINT (for consumers):
GET /api/v1/webhooks/:id/stats
{
  "subscription_id": "wh_01HZ3...",
  "period": "24h",
  "total_deliveries": 1542,
  "successful": 1530,
  "failed": 8,
  "pending_retry": 4,
  "in_dlq": 0,
  "success_rate": 0.9922,
  "avg_latency_ms": 230,
  "circuit_state": "closed"
}
```

### Step 11: Validation
Validate the webhook design against best practices:

```
WEBHOOK DESIGN VALIDATION:
┌──────────────────────────────────────────────────────────────┐
│  Check                                    │  Status          │
├──────────────────────────────────────────┼──────────────────┤
│  HMAC-SHA256 signatures on all deliveries │  PASS | FAIL     │
│  Constant-time signature comparison       │  PASS | FAIL     │
│  Replay prevention (timestamp tolerance)  │  PASS | FAIL     │
│  Idempotency keys / deduplication         │  PASS | FAIL     │
│  Exponential backoff with jitter          │  PASS | FAIL     │
│  Circuit breaker per endpoint             │  PASS | FAIL     │
│  Dead letter queue for exhausted retries  │  PASS | FAIL     │
│  HTTPS-only webhook URLs                  │  PASS | FAIL     │
│  SSRF prevention (private IP blocking)    │  PASS | FAIL     │
│  Payload size limit enforced              │  PASS | FAIL     │
│  Signing secret rotation support          │  PASS | FAIL     │
│  No sensitive data in payloads            │  PASS | FAIL     │
│  Event type naming consistency            │  PASS | FAIL     │
│  Delivery logging and observability       │  PASS | FAIL     │
│  Consumer testing tools (ping, replay)    │  PASS | FAIL     │
│  Rate limiting on registration API        │  PASS | FAIL     │
│  Subscription validation (URL check)      │  PASS | FAIL     │
│  Audit trail for subscription changes     │  PASS | FAIL     │
└──────────────────────────────────────────┴──────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 12: Artifacts & Completion

```
WEBHOOK DESIGN COMPLETE:

Artifacts:
- Database migration: migrations/<timestamp>_create_webhook_tables.sql
- Event catalog: docs/webhooks/event-types.md
- Integration guide: docs/webhooks/integration-guide.md
- OpenAPI spec: docs/api/<service>-webhooks-openapi.yaml
- Monitoring dashboard config: infra/monitoring/webhook-dashboard.json

Components:
- Inbound handler with HMAC-SHA256 verification
- Outbound delivery pipeline with retry and circuit breaker
- Subscription management API (<N> endpoints)
- Dead letter queue with replay capability
- Event catalog with <M> event types

Security:
- HMAC-SHA256 signing with dual-secret rotation
- SSRF prevention, HTTPS-only, replay protection
- Constant-time signature comparison

Next steps:
-> /godmode:api — Design the full API that emits these events
-> /godmode:queue — Set up the message queue for delivery workers
-> /godmode:event — Design the event sourcing architecture
-> /godmode:monitor — Set up the monitoring dashboard
-> /godmode:loadtest — Load test the delivery pipeline
```

Commit: `"webhook: <service> — inbound/outbound pipeline, <M> event types, delivery + retry + DLQ"`

## Key Behaviors

1. **Sign everything.** Every outbound delivery is signed with HMAC-SHA256. No exceptions. No "we'll add it later."
2. **Retry with backoff.** Failures are normal. Exponential backoff with jitter prevents thundering herds. 10 retries over 3 days is the standard.
3. **Circuit break bad endpoints.** If a consumer's endpoint is consistently failing, stop hammering it. Open the circuit, notify them, and queue events for later.
4. **Dead letter nothing silently.** When retries are exhausted, events go to a DLQ — never discarded. Provide replay tools so nothing is permanently lost.
5. **Verify on receive.** Every inbound webhook must be signature-verified before processing. Raw bytes, constant-time comparison, timestamp tolerance.
6. **Idempotency is mandatory.** Both inbound (dedup by event ID) and outbound (consumers may receive duplicates). Design handlers to be safe to re-execute.
7. **HTTPS only.** Never deliver webhooks over plain HTTP. Block private IPs to prevent SSRF.
8. **Test tools are not optional.** Consumers need ping endpoints, delivery logs, and replay buttons. Without them, integration debugging is a nightmare.

## Example Usage

### Setting up outbound webhooks
```
User: /godmode:webhook Add webhook support to our e-commerce API

WEBHOOK: Starting discovery...

WEBHOOK DISCOVERY:
Project: E-commerce API
Direction: Outbound
Events: order.created, order.updated, order.cancelled, payment.completed, payment.failed,
        shipment.created, shipment.delivered, refund.issued
Consumers: Partner integrations, merchant dashboards, fulfillment services
Volume: ~50 events/sec peak, ~2M events/day
Delivery SLA: < 30 seconds
Auth: HMAC-SHA256

Designing event catalog... 8 event types
Designing payload envelope... standardized
Designing subscription API... 11 endpoints
Designing delivery pipeline... retry + circuit breaker + DLQ
Designing database schema... 5 tables
Setting up monitoring... 10 key metrics

WEBHOOK DESIGN COMPLETE — 8 event types, 11 API endpoints
All 18 validation checks PASS.
```

### Adding inbound webhook handling
```
User: /godmode:webhook Handle Stripe webhooks in our payment service

WEBHOOK: Starting discovery...

WEBHOOK DISCOVERY:
Project: Payment Service — Stripe integration
Direction: Inbound
Provider: Stripe
Events: payment_intent.succeeded, payment_intent.payment_failed,
        charge.refunded, customer.subscription.updated

Implementing:
- Signature verification (Stripe-Signature header, HMAC-SHA256)
- Timestamp tolerance (5 minutes)
- Idempotency (event ID dedup in Redis, 72h TTL)
- Event routing to handlers
- Idempotent processing with DB transactions

Generated: src/webhooks/stripe-handler.ts
Generated: src/webhooks/verify-signature.ts
Generated: tests/webhooks/stripe-handler.test.ts

All 18 validation checks PASS.
```

### Debugging webhook delivery issues
```
User: /godmode:webhook Our webhook consumers are reporting missed events

WEBHOOK: Investigating delivery pipeline...

FINDINGS:
1. Circuit breaker OPEN for 3 subscriptions (consumer endpoints returning 503)
2. DLQ has 847 entries from the last 24 hours (normal: < 10)
3. Retry queue depth: 12,400 (normal: < 500)
4. Root cause: deployment at 14:00 UTC broke 3 consumer endpoints

RECOMMENDATIONS:
1. Contact affected consumers — their endpoints need fixes
2. Replay DLQ entries once endpoints are healthy
3. Review circuit breaker thresholds (currently too aggressive)
4. Add consumer health check before bulk replay
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full webhook design workflow (inbound + outbound) |
| `--inbound` | Design inbound webhook handling only |
| `--outbound` | Design outbound webhook delivery only |
| `--provider <name>` | Inbound: configure for specific provider (stripe, github, twilio, etc.) |
| `--events` | Design event catalog and payload format only |
| `--schema` | Generate database schema only |
| `--security` | Security audit of existing webhook implementation |
| `--test` | Generate webhook testing tools and simulator |
| `--monitor` | Set up monitoring and alerting only |
| `--rotate` | Implement signing secret rotation |
| `--debug` | Investigate delivery issues (DLQ, circuit state, retry queue) |

## Anti-Patterns

- **Do NOT deliver webhooks synchronously in the request path.** Webhook delivery must be async. The user's API request should not block on delivering events to third-party endpoints.
- **Do NOT retry on 4xx errors (except 408/429).** A 400 means your payload is wrong. A 404 means the endpoint is gone. Retrying will not fix it — fix the payload or remove the subscription.
- **Do NOT use simple string comparison for signatures.** `signature == expected` leaks timing information. Always use constant-time comparison (`hmac.compare_digest`, `crypto.timingSafeEqual`).
- **Do NOT parse the body before verifying the signature.** Signature must be computed over the raw bytes. Parsing and re-serializing JSON can change field order, whitespace, or encoding.
- **Do NOT store webhook secrets in plain text.** Encrypt at rest. The secret is shown once at creation time and never again via the API.
- **Do NOT allow HTTP webhook URLs in production.** HTTPS only. No exceptions. No "we'll enforce it later."
- **Do NOT skip SSRF checks on webhook URLs.** Attackers will register `http://169.254.169.254/latest/meta-data/` as a webhook URL. Block all private and reserved IP ranges.
- **Do NOT discard failed events silently.** Every event that cannot be delivered must end up in a dead letter queue. Silent data loss erodes trust.
- **Do NOT retry without jitter.** Thousands of retries firing at the exact same second creates a thundering herd. Add random jitter to every retry delay.
- **Do NOT assume consumers handle duplicates.** Document that delivery is at-least-once. Tell consumers to implement idempotency. But also minimize unnecessary duplicates.
