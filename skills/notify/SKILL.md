---
name: notify
description: Push notifications, SMS, in-app notifications, notification preferences, multi-channel delivery. Use when user mentions notifications, push notifications, SMS, Twilio, Firebase Cloud Messaging, OneSignal, in-app alerts.
---

# Notify — Multi-Channel Notification Systems

## When to Activate
- User invokes `/godmode:notify`
- User says "push notifications", "SMS alerts", "Twilio", "FCM", "APNs", "OneSignal"
- User says "in-app notifications", "notification center", "notification preferences"
- User says "notification digest", "batching notifications", "quiet hours"
- Application needs multi-channel notification delivery

## Workflow

### Step 1: Notification Architecture Discovery
Identify channels, event types, and delivery requirements:

```
NOTIFICATION REQUIREMENTS:
Channels: Push (web/mobile) | SMS (OTP/transactional) | Email | In-App (toast/center) | Webhook (Slack/Discord)

Provider Selection:
  Push (mobile): FCM + APNs, fallback OneSignal
  Push (web): FCM / Web Push API
  SMS: Twilio, fallback AWS SNS / Vonage
  Email: SendGrid / Resend, fallback SES / Postmark
  In-App: WebSocket / SSE, fallback Polling
  Webhook: Custom HTTP + Queue + retry

Categories & Priority:
  Security (critical): 2FA codes, login alerts, password changes
  Transactional (high): Order updates, payment confirms, shipping
  Social (normal): Mentions, comments, follows — batchable
  Product (normal): Feature announcements, usage alerts
  Marketing (low): Promotions, digest, re-engagement — batchable

Requirements: real-time delivery, quiet hours (timezone-aware), digest batching, i18n, compliance (TCPA/CAN-SPAM/GDPR)
```

### Step 2: Provider Selection

- **Push**: Native apps use FCM (Android) + APNs (iOS) directly. Cross-platform with analytics: OneSignal. React Native/Expo: Expo Notifications. Web-only: FCM or native Web Push API.
- **SMS**: Best DX + reliability: Twilio. AWS-native/cost-sensitive: AWS SNS. OTP with simplicity: Twilio Verify. High-volume marketing: MessageBird.
- **FCM setup**: `firebase-admin` SDK, `sendEachForMulticast`, handle `InvalidRegistration` / `registration-token-not-registered` errors by removing stale tokens immediately.
- **Twilio SMS**: Check marketing consent before send, check opt-out list, use separate origination numbers per type (OTP/transactional/marketing). Use Twilio Verify for OTP.

### Step 3: Multi-Channel Notification Service
Core service routes notifications across all channels:

```
ROUTING: Event trigger → Notification Service → Preference Check + Quiet Hours → Channel Router → Per-channel queues → Provider delivery → Delivery tracking
```

Key design:
- `NotificationType` defines: `defaultChannels`, `requiredChannels` (user cannot opt out), `allowedChannels`, `templates`, `priority`, `batchable`, `collapseKey`
- `NotificationService.send()` flow: idempotency check → resolve channels via preferences → quiet hours check (defer non-critical, allow in-app) → rate limit check (batch if >15/hour) → schedule if future → dispatch to per-channel queues
- `resolveChannels()`: required channels always included, filter by allowed + user preferences
- `dispatchToChannels()`: record in DB, enqueue per channel via `notify:{channel}` queue

### Step 4: Notification Preference Management
User-controlled opt-in/opt-out per type and channel:

- Per-type, per-channel toggles (e.g., `social.new_comment: { push: true, email: false }`)
- Security alerts have required channels that cannot be disabled
- Global settings: quiet hours (start/end hour, timezone), digest frequency (realtime/hourly/daily/weekly), unsubscribe-all-marketing
- One-click unsubscribe handler for email links — log for compliance audit
- Validate: cannot disable required channels on update

### Step 5: Database Schema

Core tables: `notifications` (id, user_id, type, category, priority, title, body, action_url, data, channels, idempotency_key, read_at, seen_at, archived_at, created_at), `notification_deliveries` (notification_id, channel, provider, provider_id, status, attempts, delivered_at, failed_at), `device_tokens` (user_id, token, platform, is_active), `notification_preferences` (user_id, timezone, quiet_hours, digest_frequency, channel_prefs, global_unsub), `unsubscribe_log` (audit), `digest_queue` (pending batched notifications).

Key indexes: `(user_id, created_at DESC)`, `(user_id, read_at) WHERE read_at IS NULL`, `(idempotency_key) WHERE NOT NULL`.

### Step 6: Real-Time In-App Notifications via WebSocket

- WebSocket gateway at `/ws/notifications` — authenticate via token query param
- Track connections per userId (support multiple devices)
- On connect: send unread count
- `pushToUser()`: send notification payload to all open connections
- `updateBadge()`: broadcast unread count changes
- Handle messages: `mark_read`, `mark_all_read`, `archive`
- Heartbeat every 30s, terminate stale connections (no pong in 60s)

### Step 7: Notification Center REST API

Endpoints: `GET /notifications` (cursor-paginated feed, filter by category/unread), `GET /notifications/unread-count`, `PATCH /notifications/:id/read`, `POST /notifications/mark-all-read`, `DELETE /notifications/:id` (archive), `GET /notifications/preferences`, `PUT /notifications/preferences`, `POST /notifications/unsubscribe`.

### Step 8: Batching and Digest Strategy

- Critical/high: always immediate
- Hourly digest: collapse similar ("John and 4 others commented")
- Daily digest (default): summary email at user's preferred time
- Weekly digest: for low-engagement users
- Batching rules: >15 notifs/hour → batch; same collapseKey within 5m → merge; quiet hours → defer; low priority + batchable → next digest; critical → always immediate
- Digest worker: runs on cron, checks user's digest time in their timezone, groups by type, sends email + in-app summary, marks as sent

### Step 9: Template Management

- Per-channel templates with `{{variable}}` interpolation
- Each notification type has templates for push, sms, email, in_app, slack
- `renderTemplate()` replaces `{{key}}` with data values
- Centralized template registry keyed by template ID

### Step 10: Delivery Tracking

- Track per-channel: sent → delivered → read / failed / bounced
- Twilio status callback webhook: map MessageStatus to internal status, handle permanent failures (invalid phone)
- Monitor: delivery rate, tap rate, opt-out rate, stale tokens per channel
- Alert on: push delivery <90%, SMS delivery <95%, opt-out spike >2%, stale tokens >10%

### Step 11: Commit and Report
```
Commit: "notify: <description> — <components implemented>"
Files: service.ts, channels/ (push, sms, in-app, webhook), preferences.ts, digest.ts, templates.ts, routes/notifications.ts, ws/notifications.ts, migration, webhooks
```

## Key Behaviors

1. **Route through a central notification service.** Never send push/SMS/email directly from business logic.
2. **Respect user preferences absolutely.** Required channels (security) are the only exception.
3. **Clean up stale push tokens aggressively.** Remove on InvalidRegistration errors; periodic cleanup for 30+ day unused tokens.
4. **Implement quiet hours with timezone awareness.** In-app always allowed during quiet hours.
5. **Use separate queues per channel.** A Twilio outage must not block push delivery.
6. **Collapse duplicate notifications.** Use collapseKey to group similar notifications.
7. **Batch aggressively for low-priority.** Nobody wants 50 individual "new follower" push notifications.
8. **Track delivery end-to-end.** Record every attempt, status update, and failure.
9. **Use idempotency keys for every notification.** Prevent duplicate sends from retries.
10. **Comply with SMS regulations.** TCPA requires prior express consent for marketing SMS. Always provide opt-out.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full multi-channel notification system |
| `--push` | Push notification setup only (FCM, APNs, OneSignal) |
| `--sms` | SMS notification setup only (Twilio, OTP) |
| `--inapp` | In-app notification center only (WebSocket + REST) |
| `--webhook` | Webhook/Slack integration only |
| `--preferences` | Notification preference center only |
| `--digest` | Batching and digest system only |
| `--tracking` | Delivery tracking and analytics only |

## HARD RULES

1. NEVER send notifications without checking user preferences first.
2. NEVER send SMS without explicit opt-in consent. TCPA fines are $500-$1,500 per message.
3. NEVER hardcode provider credentials. Use environment variables or secrets manager.
4. ALWAYS implement idempotency keys for every notification dispatch.
5. ALWAYS enforce rate limits per user per channel. Cap hourly sends and alert on anomalies.
6. NEVER send push notifications without handling stale tokens.
7. ALWAYS queue notifications asynchronously via a job queue with retry and DLQ.
8. NEVER serve notification content without sanitizing user-generated data.

## Auto-Detection

```bash
grep -r "sendgrid\|twilio\|firebase.*messaging\|onesignal" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
grep -r "NotificationService\|notification_service" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
grep -r "bullmq\|bull\|sqs\|pub.sub\|rabbitmq\|celery" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
```

## TSV Logging
```
STEP	COMPONENT	CHANNEL	PROVIDER	STATUS	DETAILS
1	notification-service	-	-	created	central dispatcher with priority routing and dedup
2	push	mobile	fcm	created	FCM integration with token management
3	sms	transactional	twilio	created	OTP + alerts via Twilio
4	in-app	websocket	-	created	real-time notification center with read/unread
5	preferences	-	db	created	per-user per-category per-channel preference storage
6	quiet-hours	-	db	created	timezone-aware quiet hours
```
Print: `Notifications: {N} channels ({list}). Providers: {providers}. Preferences: {yes/no}. Quiet hours: {yes/no}. Delivery tracking: {yes/no}.`

## Success Criteria
1. Notification service routes to correct channels based on category and user preferences.
2. Each channel delivers successfully (push token valid, SMS received, in-app displayed).
3. User preferences checked before every non-security notification.
4. Quiet hours block non-critical notifications (timezone-aware).
5. Security notifications bypass quiet hours and preferences — always immediate.
6. Idempotency prevents duplicates on event replay or queue retry.
7. Failed deliveries retried with exponential backoff; permanently failed tokens cleaned up.
8. Delivery status tracked and queryable.

## Error Recovery
- **Push token invalid**: Remove token immediately on `InvalidRegistration`/`Unregistered`. Do not retry.
- **SMS delivery failed**: Check Twilio error code. `30003`=unreachable, `30005`=unknown phone. Mark invalid numbers in suppression list.
- **WebSocket dropped**: Client auto-reconnects with backoff. Fetch missed notifications on reconnect.
- **Queue not processing**: Check Redis/SQS connection, verify worker running, check DLQ depth.
- **Timezone missing**: Fall back to UTC with warning. Never block delivery for missing timezone.
- **Provider rate limited**: Implement per-channel rate limiting below provider limits. Use batch APIs.

## Iteration Protocol
```
WHILE notification system is incomplete:
  1. REVIEW current state
  2. IMPLEMENT next channel/component
  3. TEST end-to-end delivery
  4. VERIFY preferences respected, quiet hours honored
  IF pass: commit, next channel | IF fail: fix (max 3 attempts)
STOP: all channels deliver, preferences work, quiet hours enforced, tracking active
```

## Keep/Discard Discipline
```
KEEP if: notification delivered, preferences checked, delivery status tracked
DISCARD if: not received OR preferences bypassed OR duplicate sends
```

## Stop Conditions
```
STOP when: all channels deliver with preference checks, quiet hours enforced, idempotency works, or user stops
DO NOT STOP just because: digest batching incomplete or analytics dashboards missing
```

## Anti-Patterns
- Do NOT send notifications directly from business logic — always route through the service.
- Do NOT batch security notifications — send login alerts, 2FA, password resets immediately.
- Do NOT ignore timezone in quiet hours — server time instead of user timezone is worse than none.
- Do NOT use a single queue for all channels — provider outage must not block other channels.

## Multi-Agent Dispatch
```
Agent 1 (notify-core): Central service, idempotency, preferences
Agent 2 (notify-channels): Push (FCM/APNs), SMS (Twilio), In-app (WebSocket)
Agent 3 (notify-ops): Delivery tracking, quiet hours, digest/batching, per-channel queues
MERGE: core → channels → ops
```

## Platform Fallback
Run sequentially: core service → channels → preferences → tracking. Branch per task.

## Output Format
Print: `Notify: {channels} configured. Preferences: {enforced|missing}. Quiet hours: {active|inactive}. Idempotent: {yes|no}. Status: {DONE|PARTIAL}.`
