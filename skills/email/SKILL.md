---
name: email
description: |
  Email and notification systems skill. SendGrid,
  SES, Postmark, Resend. Templates (MJML, React
  Email). Bounce handling, delivery tracking,
  DNS auth, stream separation.
  Triggers on: /godmode:email, "send emails",
  "notification system", "email templates".
---

# Email — Email & Notification Systems

## When to Activate
- User invokes `/godmode:email`
- User says "send emails", "email templates"
- User says "notification system", "push notifications"
- User says "bounce handling", "deliverability"
- Application needs email or notification infrastructure

## Workflow

### Step 1: Requirements Discovery

```bash
# Detect existing email infrastructure
grep -r "resend\|sendgrid\|aws-sdk.*ses\|postmark" \
  package.json pyproject.toml go.mod 2>/dev/null

# Find existing templates
find . -path ./node_modules -prune -o \
  -name "*.mjml" -o -name "*.email.tsx" \
  -o -path "*/emails/*" 2>/dev/null | head -20

# Check for queue system
grep -r "bullmq\|bull\|sqs\|celery" \
  package.json pyproject.toml 2>/dev/null
```

```
NOTIFICATION REQUIREMENTS:
  Channels: Email | Push | SMS | In-app
  Email types: Auth (critical) | Transactional (high)
    | Product (medium) | Marketing (low)
  Volume: Trans <N>/day, Marketing <N>/month
  Compliance: CAN-SPAM, GDPR, CASL

IF no queue system: add one (never send sync)
IF no provider: recommend based on needs
IF no DNS auth: set up SPF/DKIM/DMARC
```

### Step 2: Email Service Selection

```
| Feature     | SendGrid | SES    | Postmark | Resend |
|-------------|----------|--------|----------|--------|
| Best for    | Full feat| Volume | Transact | Dev DX |
| Free tier   | 100/day  | 62K/mo | 100/mo   | 3K/mo  |
| Delivery    | Good     | Good   | Excellent| Good   |
| Templates   | Yes      | SES v2 | Yes      | React  |

IF startup/dev-focused: Resend (best DX)
IF high-volume transactional: Postmark
IF full marketing + transactional: SendGrid
IF AWS-native / cost-sensitive: SES
```

### Step 3: Email Template Design

```
EMAIL DESIGN CHECKLIST:
  Layout: single column, max 600px, large tap targets
  Content: plain text version, alt text on images
  Legal: visible unsubscribe, physical address
  Technical: inline CSS, table layout (Outlook)
  Deliverability: authenticated from-address,
    List-Unsubscribe header, text:image > 60%

THRESHOLDS:
  Max email size: 100KB (incl. HTML + inline CSS)
  Image hosting: CDN only, no base64 in email
  Preheader text: 40-130 characters
```

### Step 4: Notification Architecture

```
FLOW:
  Event → Notification Service → User Prefs Check
    → Channel Router → Queue → Provider

CHANNEL MATRIX:
  Email verification: Email=YES
  Password reset: Email=YES
  Order confirmed: Email+Push+In-App=YES
  Payment failed: Email+Push+SMS+In-App=YES
  Comment on post: Push+In-App=YES, Email=OPT
  Marketing: Email=OPT only

THRESHOLDS:
  Rate limit: max 5 non-critical per user per hour
  Digest threshold: > 10 pending → batch to digest
  Queue retry: 3 attempts with exponential backoff
  Submission timeout: 30s per send attempt
```

### Step 5: Delivery Tracking & Bounces

```
LIFECYCLE: QUEUED→SENT→DELIVERED→OPENED→CLICKED
  └→ BOUNCED | DEFERRED | DROPPED | SPAM

KEY METRICS:
  Delivery rate: > 97%
  Open rate (transactional): > 50%
  Bounce rate: < 2%
  Spam complaint rate: < 0.1%
  Unsubscribe rate: < 1%

BOUNCE HANDLING:
  Hard bounce → suppression list, never email again
  Soft bounce → after 3 in 30 days, treat as hard
  Spam complaint → suppress all, alert team
```

### Step 6: DNS Authentication & Streams

```
DNS RECORDS (required):
  SPF: TXT "v=spf1 include:<provider> ~all"
  DKIM: TXT <selector>._domainkey with public key
  DMARC: TXT _dmarc "v=DMARC1; p=none"
    Progress: none → quarantine → reject (30 days)

STREAM SEPARATION:
  notifications.myapp.com — Transactional (dedicated IP)
  marketing.myapp.com — Marketing (separate IP)

IP WARM-UP SCHEDULE:
  50/day → 100 → 500 → 2K → 10K → 50K → full
  Duration: 30 days minimum
  IF bounce > 5% at any stage: pause and audit
  IF spam complaints > 0.1%: pause immediately
```

### Step 7: Commit
Commit: `"email: <description> — <components>"`

## Key Behaviors
1. **Separate transactional and marketing streams.**
2. **Authenticate domain fully.** SPF+DKIM+DMARC.
3. **Always send plain text version.**
4. **Honor unsubscribe immediately.** Synchronously.
5. **Suppression list before every send.**
6. **Queue all email sends.** Never synchronous.
7. **Monitor deliverability daily.**

## HARD RULES
1. Never send email synchronously in request handlers.
2. Never mix transactional/marketing on same domain.
3. Never email a hard-bounced address again.
4. Never skip SPF, DKIM, and DMARC.
5. Never send without checking user preferences.

## Auto-Detection
```
1. Provider SDK: resend, @sendgrid/mail, ses, postmark
2. Templates: emails/, src/emails/, *.mjml
3. Queue: bullmq, sqs, celery
4. DNS: check TXT records for SPF/DKIM/DMARC
```

## Output Format
```
Email: Provider={name}, Templates={N},
  Channels={N}. DNS: {status}.
  Queue: {system}. Verdict: {verdict}.
```

## TSV Logging
```
step	component	provider	status	details
```

## Keep/Discard Discipline
```
KEEP if: email lands in inbox AND template renders
  AND SPF/DKIM/DMARC pass
DISCARD if: lands in spam OR template breaks
  OR authentication fails
```

## Stop Conditions
```
STOP when: All notification types implemented
  AND SPF+DKIM+DMARC passing
  AND suppression list enforced
  AND bounce webhook active
  OR user requests stop
```

## Error Recovery
- API key missing: print env var name, link to docs.
- Template render error: validate with preview API.
- Webhook signature fails: check signing secret.
- Lands in spam: check DNS auth, sender reputation.
- Bounce rate > 5%: pause, audit suppression list.
