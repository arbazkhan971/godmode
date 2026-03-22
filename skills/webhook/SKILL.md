---
name: webhook
description: Webhook design, delivery, retry strategies, HMAC verification, event subscriptions. Use when user mentions webhooks, event delivery, callback URLs, webhook signatures, webhook retry.
---

# Webhook — Design, Delivery & Security

## When to Activate
- User invokes `/godmode:webhook`
- User says "set up webhooks", "webhook delivery", "verify webhook signature"
- User says "retry failed webhooks", "dead letter queue", "event notifications"
- When API design needs to notify external systems

## Workflow

### Step 1: Discovery
```
WEBHOOK DISCOVERY:
Direction: Inbound | Outbound | Both
Events: <list event types>  Consumers/Producers: <who>
Volume: <events/sec, daily total>  Latency SLA: <max delay>
Delivery guarantee: At-least-once | Best-effort
Auth: HMAC-SHA256 | mTLS | bearer token
```

### Step 2: Event & Payload Design
Naming: `<resource>.<past_tense_verb>` (e.g., order.created, payment.completed).

```json
{
  "id": "evt_<ULID>", "type": "order.created", "api_version": "2025-01-15",
  "created_at": "2025-07-15T14:32:00.000Z",
  "data": { "object": { ... }, "previous_attributes": {} },
  "livemode": true
}
```
Rules: unique ID, ISO 8601 UTC, monetary values in cents, no PII/secrets, max 64KB payload.

### Step 3: Inbound Webhook Handling
```
HANDLER PATTERN:
1. Verify HMAC-SHA256 signature (raw bytes, constant-time comparison) -> 401 if invalid
2. Check timestamp tolerance (5 min window) -> 403 if stale
3. Check idempotency (event ID seen?) -> 200 if duplicate
4. Parse payload, route to handler, process in transaction
5. Mark event processed, return 200 within 5s (offload heavy work to queue)
```

SSRF prevention: resolve DNS before connecting, block private IPs (127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16, ::1). Re-check on every retry.

### Step 4: Outbound Delivery System
```
Event Source -> Webhook Dispatcher -> Delivery Worker -> Consumer Endpoint
                Delivery Log          Retry Queue (exp backoff)
                                          |
                                     Dead Letter Queue
```

#### Retry Strategy — Exponential Backoff with Jitter
10 attempts over ~3 days: immediate, 10s, 30s, 1min, 5min, 15min, 1hr, 4hr, 8hr, 24hr. Add random jitter (0.5x-1.5x). Retry on: 5xx, 408, 429, timeout, DNS failure. Do NOT retry on: 4xx (except 408/429). Honor Retry-After header.

#### Circuit Breaker — Per Endpoint
CLOSED -> 5 consecutive failures -> OPEN (queue events, alert owner) -> 30 min -> HALF-OPEN (test one) -> 2 successes -> CLOSED. Auto-disable after 72 hours open.

#### Dead Letter Queue
Events after max retries or prolonged circuit break. 30-day retention. Provide replay (single/bulk), export, purge via API.

### Step 5: Subscription API
```
POST/GET    /api/v1/webhooks           — Create/list subscriptions
GET/PATCH   /api/v1/webhooks/:id       — Get/update subscription
DELETE      /api/v1/webhooks/:id       — Delete
POST        /api/v1/webhooks/:id/test  — Send test ping
POST        /api/v1/webhooks/:id/rotate — Rotate secret
GET         /api/v1/webhooks/:id/deliveries — List delivery attempts
```
Validation: HTTPS only, public IP only, max 100 events per sub, max 20 subs per account. Event filtering: `["*"]`, `["order.*"]`, or specific types.

### Step 6: Secret Rotation
Dual-secret zero-downtime rotation: Phase 1 (sign with both), Phase 2 (grace 24-72h), Phase 3 (revoke old). Secret shown ONCE at creation. Recommend 90-day rotation.

### Step 7: Security Checklist
HMAC-SHA256 on all deliveries, constant-time comparison, timestamp replay prevention, HTTPS only, SSRF block, payload size limit (64KB), rate limiting on registration, secret rotation, no sensitive data in payloads, audit logging.

### Step 8: Database Schema
Tables: `webhook_subscriptions` (id, account, url, events, secrets, circuit state), `webhook_events` (id, type, data), `webhook_deliveries` (id, event_id, sub_id, status, attempts, response), `webhook_inbound_events` (provider, event_id — dedup), `webhook_dead_letter_queue` (delivery details, reason, replay status).

### Step 9: Testing Tools
Test ping, delivery log inspector, manual replay, event catalog with examples, webhook simulator (curl), endpoint validator (HTTPS, public IP, responds in 5s).

### Step 10: Monitoring
Key metrics: delivery success rate (>99%), first-attempt success (>95%), p50/p99 latency, pending events, DLQ entries, open circuit breakers, retry queue depth. Alert on drops below thresholds.

### Step 11: Validation
Check all: HMAC signatures, constant-time comparison, replay prevention, idempotency, backoff with jitter, circuit breaker, DLQ, HTTPS-only, SSRF prevention, payload limit, secret rotation, no PII, event naming, delivery logging, testing tools, rate limiting, audit trail.

## Key Behaviors
1. **Sign everything.** HMAC-SHA256 on every outbound delivery.
2. **Retry with backoff and jitter.** 10 retries over 3 days.
3. **Circuit break bad endpoints.** Stop hammering, notify, queue for later.
4. **Dead letter nothing silently.** DLQ with replay tools.
5. **Verify on receive.** Raw bytes, constant-time, timestamp tolerance.
6. **Idempotency is mandatory.** Both inbound (dedup) and outbound.
7. **HTTPS only.** Block private IPs (SSRF).

## Flags & Options

| Flag | Description |
|--|--|
| `--inbound` | Inbound handling only |
| `--outbound` | Outbound delivery only |
| `--provider <name>` | Configure for specific provider (stripe, github, etc.) |
| `--security` | Security audit |
| `--debug` | Investigate delivery issues |

## HARD RULES
1. **NEVER deliver webhooks synchronously** in the request path.
2. **NEVER retry on 4xx** (except 408/429).
3. **NEVER use simple string comparison** for signatures. Constant-time only.
4. **NEVER parse body before verifying signature.** Raw bytes.
5. **NEVER allow HTTP webhook URLs** in production.
6. **NEVER skip SSRF checks.**
7. **ALWAYS send failed events to DLQ.** No silent data loss.
8. **ALWAYS add jitter to retry delays.**

## Auto-Detection
```
Check for: svix/standardwebhooks libs, hmac/crypto verification in handlers,
webhook tables in migrations, queue integration (BullMQ, Celery, SQS),
webhook endpoints in routes, inbound handlers (stripe/github/twilio)
```

## Multi-Agent Dispatch
```
Agent 1 (webhook-outbound): Payload schemas, delivery, HMAC, retry + circuit breaker
Agent 2 (webhook-inbound): Signature verification, secret management, SSRF protection
Agent 3 (webhook-infra): DB schema, subscription API, monitoring, tests
MERGE: outbound + inbound -> infra rebases onto both
```

## TSV Logging
Log to `.godmode/webhook-results.tsv`: `timestamp\tproject\tdirection\tevent_types\tdelivery_method\tretry_strategy\tdlq_configured\tssrf_protection\tcommit_sha`

## Success Criteria
- HMAC signature on every outbound payload
- Signature verified before processing inbound
- Constant-time comparison, raw body for signature
- HTTPS-only, SSRF protection
- Async delivery via queue
- Exponential backoff with jitter, DLQ, circuit breaker
- Secret rotation without downtime

## Error Recovery
1. **Signature fails inbound:** Check raw body (not re-serialized), verify secret, check algorithm.
2. **Outbound consistently failing:** Check circuit state, verify URL/DNS/TLS, notify owner.
3. **DLQ growing:** Analyze failure patterns, disable permanently-down endpoints, fix then replay.
4. **SSRF attempt:** Block, log, verify blocklist covers all private ranges.
5. **Queue backed up:** Scale workers, add per-destination concurrency limits.

## Keep/Discard Discipline
KEEP: webhook delivery succeeds AND retry logic works AND idempotency verified.
DISCARD: delivery fails after max retries OR duplicate processing detected. Revert: `git reset --hard HEAD~1`.

## Stop Conditions
1. All webhook endpoints verified reliable (retry + idempotency + timeout)
2. Budget exhausted (max iterations reached)
3. Diminishing returns (3 consecutive iterations < 1% improvement)
4. Stuck (>5 consecutive discards)

## Output Format
Webhook: {endpoints_audited} endpoints, {issues_found} issues -> {issues_fixed} fixed. Status: {DONE|PARTIAL}.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-webhook-{task}`. See `adapters/shared/sequential-dispatch.md`.
