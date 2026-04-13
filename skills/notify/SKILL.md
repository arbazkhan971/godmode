---
name: notify
description: Push notifications, SMS, in-app notifications,
  notification preferences, multi-channel delivery.
---

## Activate When
- `/godmode:notify`, "push notifications", "SMS alerts"
- "Twilio", "FCM", "APNs", "OneSignal", "in-app"
- "notification center", "notification preferences"
- "notification digest", "quiet hours"

## Workflow

### 1. Architecture Discovery
```bash
grep -r "sendgrid\|twilio\|firebase.*messaging" \
  --include="*.ts" --include="*.js" -l 2>/dev/null
grep -r "NotificationService\|notification_service" \
  --include="*.ts" --include="*.py" -l 2>/dev/null
```
```
Channels: Push | SMS | Email | In-App | Webhook
Categories & Priority:
  Security (critical): 2FA, login alerts, password
  Transactional (high): orders, payments, shipping
  Social (normal): mentions, comments -- batchable
  Marketing (low): promotions, digest -- batchable
```

### 2. Provider Selection
- Push: FCM (Android) + APNs (iOS). Cross-platform:
  OneSignal. Web: FCM or Web Push API.
- SMS: Twilio (best DX). AWS SNS (cost-sensitive).
  OTP: Twilio Verify.
- Email: SendGrid/Resend. Fallback: SES/Postmark.
- In-App: WebSocket/SSE. Fallback: polling.

### 3. Notification Service
```
Event -> Service -> Preference Check + Quiet Hours
  -> Channel Router -> Per-channel queues
  -> Provider delivery -> Delivery tracking
```
- `NotificationType`: defaultChannels, requiredChannels,
  allowedChannels, templates, priority, batchable
- Flow: idempotency check -> resolve channels via prefs
  -> quiet hours -> rate limit (>15/hour -> batch)
  -> dispatch per-channel queues

IF security notification: bypass quiet hours + prefs.
IF >15 notifications/hour to same user: batch them.

### 4. Preference Management
Per-type, per-channel toggles. Security alerts have
required channels (cannot disable). Global settings:
quiet hours (timezone-aware), digest frequency, unsub.

One-click unsubscribe handler for email compliance.

### 5. Database Schema
Core tables: notifications, notification_deliveries,
device_tokens, notification_preferences, digest_queue.
Key indexes: `(user_id, created_at DESC)`,
`(user_id, read_at) WHERE read_at IS NULL`.

### 6. Real-Time In-App (WebSocket)
- `/ws/notifications` with token auth
- Track connections per userId (multi-device)
- On connect: send unread count
- Heartbeat 30s, terminate stale after 60s

### 7. REST API
GET /notifications (cursor-paginated, filter),
GET /notifications/unread-count,
PATCH /notifications/:id/read,
POST /notifications/mark-all-read,
GET/PUT /notifications/preferences.

### 8. Batching & Digest
- Critical/high: always immediate
- >15/hour same user: batch
- Same collapseKey within 5m: merge
- Hourly: "John and 4 others commented"
- Daily: summary at user's preferred time
- Weekly: low-engagement users

### 9. Delivery Tracking
Track: sent -> delivered -> read / failed / bounced.
Alert on: push delivery <90%, SMS <95%,
opt-out spike >2%, stale tokens >10%.

## Hard Rules
1. NEVER send without checking preferences first.
2. NEVER send SMS without explicit opt-in (TCPA).
3. NEVER hardcode provider credentials.
4. ALWAYS use idempotency keys for every dispatch.
5. ALWAYS enforce rate limits per user per channel.
6. NEVER send push without handling stale tokens.
7. ALWAYS queue async with retry and DLQ.
8. NEVER serve unsanitized user-generated content.

## TSV Logging
Append `.godmode/notify.tsv`:
```
timestamp	component	channel	provider	status	details
```

## Keep/Discard
```
KEEP if: notification delivered AND preferences
  checked AND delivery status tracked.
DISCARD if: not received OR preferences bypassed
  OR duplicate sends.
```

## Stop Conditions
```
STOP when FIRST of:
  - All channels deliver with preference checks
  - Quiet hours enforced
  - Idempotency works
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Push token invalid | Remove on InvalidRegistration |
| SMS failed | Check error code, suppress invalid |
| WebSocket dropped | Auto-reconnect, fetch missed |
| Queue stalled | Check Redis/SQS, verify worker |
| Timezone missing | Fall back to UTC with warning |
