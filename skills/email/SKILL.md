---
name: email
description: |
  Email and notification systems skill. Activates when user needs to build email delivery, notification systems, or communication infrastructure. Covers email service integration (SendGrid, SES, Postmark, Resend), email template design (MJML, React Email), notification system architecture (email, push, SMS, in-app), delivery tracking and bounce handling, and transactional vs marketing email separation. Triggers on: /godmode:email, "send emails", "notification system", "email templates", "push notifications", "bounce handling", or when building user communication features.
---

# Email — Email & Notification Systems

## When to Activate
- User invokes `/godmode:email`
- User says "send emails", "email templates", "transactional email"
- User says "notification system", "push notifications", "SMS alerts"
- User says "bounce handling", "delivery tracking", "email deliverability"
- User says "email service", "SendGrid", "SES", "Postmark", "Resend"
- Application needs to send emails or build a notification system

## Workflow

### Step 1: Notification Requirements Discovery
Identify channels, email types, volume, and compliance needs:

```
NOTIFICATION REQUIREMENTS:
Channels: Email (transactional|marketing|both), Push (web|mobile|both), SMS, In-app
Email categories: Authentication (critical), Transactional (high), Product (medium), Marketing (low)
Volume: Transactional <N>/day, Marketing <N>/month, SMS <N>/month, Push <N>/day
Compliance: CAN-SPAM, GDPR, CASL, one-click unsubscribe
```

### Step 2: Email Service Integration

```
EMAIL SERVICE COMPARISON:
┌──────────┬───────────┬──────────┬──────────┬────────┐
│ Feature  │ SendGrid  │ SES      │ Postmark │ Resend │
├──────────┼───────────┼──────────┼──────────┼────────┤
│ Best for │ Full-feat │ Volume   │ Transact │ Dev-DX │
│ Free tier│ 100/day   │ 62K/mo*  │ 100/mo   │ 3K/mo  │
│ Deliver. │ Good      │ Good     │ Excellent│ Good   │
│ Templates│ Yes       │ SES v2   │ Yes      │ React  │
│ Marketing│ Yes       │ No       │ No       │ No     │
└──────────┴───────────┴──────────┴──────────┴────────┘

RECOMMENDATION:
- Startups/developer-focused: Resend (best DX, React Email)
- High-volume transactional: Postmark (best deliverability)
- Full marketing + transactional: SendGrid (most features)
- AWS-native / cost-sensitive: SES (cheapest at scale)
```

Integration: use provider SDK, send with `from`, `to`, `subject`, `react`/`html`, `tags`, idempotency header. Queue all sends (never synchronous in request handlers).

### Step 3: Email Template Design

Use React Email (recommended for modern projects) or MJML (cross-client compatibility).

```
EMAIL DESIGN CHECKLIST:
Layout: Single column, max 600px, large tap targets, preheader text
Content: Plain text version, alt text on images, visible unsubscribe, physical address (CAN-SPAM)
Technical: Inline CSS, table-based layout (Outlook), no JavaScript, web-safe fonts, CDN-hosted images
Deliverability: Authenticated from-address, List-Unsubscribe header, text-to-image ratio > 60%, no URL shorteners
```

### Step 4: Notification System Architecture

```
NOTIFICATION FLOW:
Trigger (event) → Notification Service → User Prefs Check → Channel Router
  → Email Queue → SendGrid/SES/Postmark/Resend
  → Push Queue → FCM/APNs/Web Push
  → SMS Queue → Twilio/SNS
  → In-App Queue → WebSocket/SSE

CHANNEL MATRIX (per event type):
  Email verification: Email=YES
  Password reset: Email=YES
  Order confirmed: Email=YES, Push=YES, In-App=YES
  Payment failed: Email=YES, Push=YES, SMS=YES, In-App=YES
  Comment on post: Email=OPT, Push=YES, In-App=YES
  Marketing promo: Email=OPT
  YES=always, OPT=user preference, --=never
```

Rate-limit non-critical notifications per user. Batch excess into digest emails.

### Step 5: Delivery Tracking and Bounce Handling

```
EMAIL LIFECYCLE: QUEUED → SENT → DELIVERED → OPENED → CLICKED
  └→ BOUNCED (hard/soft) | DEFERRED | DROPPED | SPAM

KEY METRICS:
  Delivery rate > 97%, Open rate (trans.) > 50%, Bounce rate < 2%
  Spam complaint rate < 0.1%, Unsubscribe rate < 1%

BOUNCE HANDLING:
  Hard bounce → add to suppression list, never email again
  Soft bounce → track; after 3 in 30 days, treat as hard bounce
  Spam complaint → suppress all, unsubscribe from marketing, alert team
```

### Step 6: DNS Authentication & Stream Separation

```
DNS RECORDS (required):
  SPF: TXT @ "v=spf1 include:<provider> ~all"
  DKIM: TXT <selector>._domainkey with public key
  DMARC: TXT _dmarc "v=DMARC1; p=none → quarantine → reject (30-day progression)"

STREAM SEPARATION:
  notifications.myapp.com — Transactional (dedicated IP, immediate, > 99% delivery)
  marketing.myapp.com — Marketing (separate IP, batched, CAN-SPAM required)
  Why: Marketing spam complaints must not affect transactional deliverability

IP WARM-UP: 50/day → 100 → 500 → 2K → 10K → 50K → full (over 30 days)
  Stop if bounce > 5% or spam complaints > 0.1%
```

### Step 7: Commit and Report
Save email service, templates, notification service, webhook handler, preference management. Commit: `"email: <description> — <components implemented>"`

## Key Behaviors

1. **Separate transactional and marketing streams.** Different subdomains and IPs. Marketing complaints must never affect password reset delivery.
2. **Authenticate your domain fully.** SPF, DKIM, DMARC non-negotiable. Progress DMARC to p=reject within 30 days.
3. **Always send a plain text version.** Screen readers and security-conscious users rely on it.
4. **Honor unsubscribe immediately.** Process synchronously, not batched.
5. **Implement a suppression list.** Check before every send. Never email hard-bounced addresses.
6. **Use queues for email sending.** Never synchronous in request handlers. Retry with exponential backoff.
7. **Monitor deliverability metrics daily.** Alert when metrics degrade.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full notification system design and implementation |
| `--email` | Email service integration only |
| `--templates` | Email template design only |
| `--push` | Push notification setup only |
| `--sms` | SMS notification setup only |
| `--inapp` | In-app notification system only |
| `--deliverability` | Email deliverability audit and fixes |
| `--provider <name>` | Use specific provider (sendgrid, ses, postmark, resend) |
| `--dns` | Email DNS authentication setup |
| `--preferences` | Notification preference center design |

## HARD RULES

1. **Never send email synchronously in request handlers.** Always queue and return immediately.
2. **Never mix transactional and marketing on same domain/IP.** Use separate subdomains.
3. **Never email a hard-bounced address again.** Check suppression list before every send.
4. **Never skip SPF, DKIM, and DMARC.** All three required. Progress DMARC to p=reject.
5. **Never send notifications without checking user preferences.** Every non-critical notification must respect opt-out.

## Auto-Detection

```
Check for: existing email provider SDK (resend, @sendgrid/mail, aws-sdk ses, postmark),
email templates (emails/, src/emails/), notification service, queue system (bullmq, sqs),
DNS records, webhook endpoints, environment variables.
Reuse existing provider. Match existing template tech. Identify gaps.
```

## Loop Protocol

```
FOR each notification_type in detected_types (batches of 3):
  1. Define channels and priority
  2. Design email template (React Email or MJML)
  3. Implement send function with queue + retry
  4. Add plain-text fallback, verify suppression check
POST-LOOP: Verify DNS records, set up bounce/complaint webhook
```

## Multi-Agent Dispatch
```
Agent 1 (email-service): Provider client, queue with retry, suppression list
Agent 2 (templates): Email templates, plain-text versions, responsive design
Agent 3 (delivery-tracking): Bounce/complaint webhooks, delivery metrics, alerts
Agent 4 (notification-system): Multi-channel service, preference center, rate limiting
MERGE: Combine → end-to-end delivery test
```

## Output Format
```
EMAIL SYSTEM COMPLETE:
Provider: <name>, Templates: <N>, Channels: <N>
Queue: <system>, Suppression: YES/NO
DNS: SPF/DKIM/DMARC <status>
Delivery tracking: <webhook endpoint>
Verdict: PASS | NEEDS REVISION
```

## TSV Logging
Append to `.godmode/email-results.tsv`: `STEP\tCOMPONENT\tPROVIDER\tSTATUS\tDETAILS`

## Success Criteria
1. `email.send()` works end-to-end (test email received)
2. At least one template renders correctly with dynamic data
3. Webhook endpoint receives delivery status events
4. Suppression list exists with auto-add on hard bounce
5. Email sending is async (queued)
6. SPF, DKIM, DMARC documented or verified
7. All new code has tests

## Error Recovery
| Failure | Action |
|---------|--------|
| API key missing | Print env var name, link to dashboard, verify with curl |
| Template render error | Validate with preview API, fix syntax |
| Webhook signature fails | Check signing secret, test with provider's test event |
| Email lands in spam | Check SPF/DKIM/DMARC, sender reputation, from-domain |
| Queue not processing | Verify connection, check worker status, inspect DLQ |
| Bounce rate > 5% | Pause sending, audit suppression list, check list hygiene |

## Keep/Discard Discipline
```
KEEP if: email lands in inbox AND template renders AND SPF/DKIM/DMARC pass
DISCARD if: email lands in spam OR template breaks OR authentication fails
```

## Stop Conditions
```
STOP when: All notification types implemented with templates and queue-based delivery
  AND SPF+DKIM+DMARC passing AND suppression list enforced AND bounce webhook active
  OR user requests stop
```

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.

