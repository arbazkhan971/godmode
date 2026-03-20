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
- Application needs to send emails (welcome, reset password, receipts)
- Building a notification system (email + push + SMS + in-app)

## Workflow

### Step 1: Notification Requirements Discovery
Identify all communication channels and use cases:

```
NOTIFICATION REQUIREMENTS:
┌──────────────────────────────────────────────────────────┐
│  Channels:                                                │
│    Email: <transactional | marketing | both>               │
│    Push: <web push | mobile push | both>                   │
│    SMS: <OTP only | alerts | marketing>                    │
│    In-app: <toast | notification center | both>            │
│                                                           │
│  Email Types:                                             │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Category        │ Priority │ Examples              │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Authentication  │ Critical │ Email verify, 2FA,    │  │
│  │                  │          │ password reset         │  │
│  │  Transactional   │ High     │ Order confirm, receipt,│  │
│  │                  │          │ shipping, invoice      │  │
│  │  Product         │ Medium   │ Usage alerts, feature  │  │
│  │                  │          │ announcements          │  │
│  │  Marketing       │ Low      │ Newsletter, promotions,│  │
│  │                  │          │ re-engagement          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Volume:                                                  │
│    Transactional: <N emails/day>                           │
│    Marketing: <N emails/month>                             │
│    SMS: <N messages/month>                                 │
│    Push: <N notifications/day>                             │
│                                                           │
│  Compliance:                                              │
│    CAN-SPAM: <required for US marketing>                   │
│    GDPR: <consent management, unsubscribe>                 │
│    CASL: <required for Canadian recipients>                 │
│    Unsubscribe: <one-click, preference center>             │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Email Service Integration
Set up the email delivery provider:

#### Provider Comparison
```
EMAIL SERVICE COMPARISON:
┌──────────────────────────────────────────────────────────┐
│  Feature      │ SendGrid  │ SES      │ Postmark │ Resend │
│  ─────────────────────────────────────────────────────── │
│  Best for     │ Full-feat │ Volume   │ Transact │ Dev-DX │
│  Pricing      │ Per-plan  │ $0.10/1K │ Per-msg  │ Per-msg│
│  Free tier    │ 100/day   │ 62K/mo*  │ 100/mo   │ 3K/mo  │
│  Deliverabil. │ Good      │ Good     │ Excellent│ Good   │
│  API DX       │ Good      │ Moderate │ Good     │ Great  │
│  Templates    │ Yes       │ SES v2   │ Yes      │ React  │
│  Webhooks     │ Yes       │ SNS      │ Yes      │ Yes    │
│  Marketing    │ Yes       │ No       │ No       │ No     │
│  Analytics    │ Advanced  │ Basic    │ Good     │ Basic  │
│  Dedicated IP │ Pro plan  │ Yes      │ Yes      │ No     │
│  * SES free tier requires EC2 origin                      │
└──────────────────────────────────────────────────────────┘

RECOMMENDATION:
- Startups/developer-focused: Resend (best DX, React Email support)
- High-volume transactional: Postmark (best deliverability)
- Full marketing + transactional: SendGrid (most features)
- AWS-native / high-volume / cost-sensitive: SES (cheapest at scale)
```

#### Resend Integration (Modern DX)
```typescript
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

// Send transactional email
async function sendTransactionalEmail(
  to: string,
  subject: string,
  react: React.ReactElement,    // React Email component
  options?: { replyTo?: string; tags?: { name: string; value: string }[] },
): Promise<string> {
  const { data, error } = await resend.emails.send({
    from: 'MyApp <noreply@notifications.myapp.com>',
    to,
    subject,
    react,                        // React component rendered to HTML
    tags: options?.tags,
    headers: {
      'X-Entity-Ref-ID': crypto.randomUUID(),  // Prevent threading
    },
  });

  if (error) {
    throw new EmailDeliveryError(error.message, { to, subject });
  }

  return data.id;
}
```

#### AWS SES Integration (High Volume)
```typescript
import { SESv2Client, SendEmailCommand } from '@aws-sdk/client-sesv2';

const ses = new SESv2Client({ region: process.env.AWS_REGION });

async function sendSESEmail(
  to: string,
  subject: string,
  htmlBody: string,
  textBody: string,
  configSet: string = 'transactional',
): Promise<string> {
  const command = new SendEmailCommand({
    FromEmailAddress: 'MyApp <noreply@notifications.myapp.com>',
    Destination: { ToAddresses: [to] },
    Content: {
      Simple: {
        Subject: { Data: subject, Charset: 'UTF-8' },
        Body: {
          Html: { Data: htmlBody, Charset: 'UTF-8' },
          Text: { Data: textBody, Charset: 'UTF-8' },
        },
      },
    },
    ConfigurationSetName: configSet,
    EmailTags: [
      { Name: 'category', Value: 'transactional' },
      { Name: 'environment', Value: process.env.NODE_ENV },
    ],
  });

  const result = await ses.send(command);
  return result.MessageId;
}
```

### Step 3: Email Template Design
Build maintainable, responsive email templates:

#### React Email (Recommended for Modern Projects)
```typescript
// emails/welcome.tsx
import {
  Body, Container, Head, Heading, Html, Img, Link,
  Preview, Section, Text, Button, Hr,
} from '@react-email/components';

interface WelcomeEmailProps {
  userName: string;
  verifyUrl: string;
}

export function WelcomeEmail({ userName, verifyUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Welcome to MyApp — verify your email to get started</Preview>
      <Body style={main}>
        <Container style={container}>
          <Img src="https://myapp.com/logo.png" width={120} height={40} alt="MyApp" />
          <Heading style={h1}>Welcome, {userName}!</Heading>
          <Text style={text}>
            Thanks for signing up. Please verify your email address to
            activate your account and get started.
          </Text>
          <Section style={buttonContainer}>
            <Button style={button} href={verifyUrl}>
              Verify Email Address
            </Button>
          </Section>
          <Text style={secondaryText}>
            This link expires in 24 hours. If you did not create an account,
            you can safely ignore this email.
          </Text>
          <Hr style={hr} />
          <Text style={footer}>
            MyApp, Inc. · 123 Main St · San Francisco, CA 94105
          </Text>
        </Container>
      </Body>
    </Html>
  );
}

const main = { backgroundColor: '#f6f9fc', fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif' };
const container = { backgroundColor: '#ffffff', margin: '0 auto', padding: '40px 20px', maxWidth: '560px' };
const h1 = { color: '#1a1a1a', fontSize: '24px', fontWeight: '600', margin: '30px 0 15px' };
const text = { color: '#4a4a4a', fontSize: '16px', lineHeight: '26px' };
const secondaryText = { color: '#898989', fontSize: '14px', lineHeight: '22px' };
const buttonContainer = { textAlign: 'center' as const, margin: '30px 0' };
const button = { backgroundColor: '#5469d4', borderRadius: '5px', color: '#fff', fontSize: '16px', fontWeight: '600', textDecoration: 'none', textAlign: 'center' as const, padding: '12px 24px' };
const hr = { borderColor: '#e6ebf1', margin: '30px 0' };
const footer = { color: '#8898aa', fontSize: '12px', lineHeight: '16px' };
```

#### MJML (Cross-Client Compatibility)
```
MJML TEMPLATE STRUCTURE:
┌──────────────────────────────────────────────────────────┐
│  emails/                                                  │
│    templates/                                             │
│      _layout.mjml          — Shared header/footer         │
│      welcome.mjml          — Welcome email                │
│      password-reset.mjml   — Password reset               │
│      order-confirm.mjml    — Order confirmation            │
│      invoice.mjml          — Invoice email                 │
│    partials/                                              │
│      _header.mjml          — Reusable header              │
│      _footer.mjml          — Reusable footer              │
│      _button.mjml          — Reusable CTA button          │
│    compiled/                                              │
│      *.html                — Pre-compiled HTML output     │
│                                                           │
│  Build: mjml emails/templates/*.mjml -o emails/compiled/  │
│  Preview: mjml --watch (live reload in browser)           │
│                                                           │
│  Benefits of MJML:                                        │
│  - Compiles to battle-tested HTML that works in Outlook   │
│  - Responsive by default (mobile-first design)            │
│  - Component-based (mj-section, mj-column, mj-button)    │
│  - Handles email client quirks (Gmail, Yahoo, Apple Mail) │
└──────────────────────────────────────────────────────────┘
```

#### Email Design Best Practices
```
EMAIL DESIGN CHECKLIST:
┌──────────────────────────────────────────────────────────┐
│  Layout:                                                  │
│  [x] Single column for mobile compatibility               │
│  [x] Max width 600px                                      │
│  [x] Large tap targets (min 44x44px)                      │
│  [x] Preheader text (preview in inbox list)               │
│                                                           │
│  Content:                                                 │
│  [x] Plain text version for every HTML email              │
│  [x] Alt text on all images                               │
│  [x] Email makes sense with images disabled               │
│  [x] Unsubscribe link visible (not hidden in tiny text)   │
│  [x] Physical mailing address included (CAN-SPAM)         │
│                                                           │
│  Technical:                                               │
│  [x] Inline CSS (many clients strip <style> tags)         │
│  [x] Table-based layout (Outlook needs tables)            │
│  [x] No JavaScript (stripped by all clients)              │
│  [x] Web-safe fonts with fallbacks                        │
│  [x] Images hosted on CDN (not embedded base64)           │
│  [x] Links use https:// (not protocol-relative)           │
│  [x] Test in Litmus or Email on Acid                      │
│                                                           │
│  Deliverability:                                          │
│  [x] From address matches authenticated domain            │
│  [x] Reply-to set to monitored address                    │
│  [x] List-Unsubscribe header present                      │
│  [x] Text-to-image ratio > 60% text                       │
│  [x] No URL shorteners (trigger spam filters)             │
│  [x] Consistent sending domain and IP                     │
└──────────────────────────────────────────────────────────┘
```

### Step 4: Notification System Architecture
Design multi-channel notification delivery:

```
NOTIFICATION ARCHITECTURE:
┌──────────────────────────────────────────────────────────────┐
│                                                               │
│  ┌──────────┐    ┌──────────────┐    ┌───────────────────┐  │
│  │ Trigger  │───>│ Notification │───>│ Channel Router    │  │
│  │ (event)  │    │ Service      │    │                   │  │
│  └──────────┘    └──────────────┘    └───────┬───────────┘  │
│                        │                      │              │
│                   ┌────┴────┐          ┌──────┴──────┐      │
│                   │ User    │          │             │      │
│                   │ Prefs   │     ┌────┴───┐  ┌─────┴───┐  │
│                   │ Check   │     │ Email  │  │  Push   │  │
│                   └─────────┘     │ Queue  │  │  Queue  │  │
│                                   └────┬───┘  └────┬────┘  │
│                                        │           │        │
│                                   ┌────┴───┐  ┌────┴────┐  │
│                                   │SendGrid│  │ FCM/APNs│  │
│                                   │SES/etc │  │ Web Push│  │
│                                   └────────┘  └─────────┘  │
│                                                              │
│                                   ┌────────┐  ┌─────────┐  │
│                                   │  SMS   │  │  In-App  │  │
│                                   │  Queue │  │  Queue   │  │
│                                   └────┬───┘  └────┬────┘  │
│                                        │           │        │
│                                   ┌────┴───┐  ┌────┴────┐  │
│                                   │ Twilio │  │WebSocket│  │
│                                   │ SNS    │  │ SSE     │  │
│                                   └────────┘  └─────────┘  │
└──────────────────────────────────────────────────────────────┘

NOTIFICATION TYPES AND CHANNELS:
┌──────────────────────────────────────────────────────────┐
│  Event                │ Email │ Push │ SMS  │ In-App    │
│  ─────────────────────────────────────────────────────── │
│  Email verification   │ YES   │ --   │ --   │ --        │
│  Password reset       │ YES   │ --   │ --   │ --        │
│  Login from new device│ YES   │ YES  │ OPT  │ YES       │
│  Order confirmed      │ YES   │ YES  │ --   │ YES       │
│  Payment failed       │ YES   │ YES  │ YES  │ YES       │
│  Comment on your post │ OPT   │ YES  │ --   │ YES       │
│  New follower         │ OPT   │ OPT  │ --   │ YES       │
│  Weekly digest        │ OPT   │ --   │ --   │ --        │
│  Marketing promo      │ OPT   │ --   │ --   │ --        │
│                                                           │
│  YES = Always sent   OPT = User preference   -- = Never  │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Notification service
interface NotificationPayload {
  userId: string;
  type: NotificationType;
  data: Record<string, unknown>;
  channels?: Channel[];       // Override default channels
  priority?: 'critical' | 'high' | 'normal' | 'low';
}

async function sendNotification(payload: NotificationPayload): Promise<void> {
  const { userId, type, data, priority = 'normal' } = payload;

  // 1. Get notification config for this type
  const config = NOTIFICATION_CONFIG[type];

  // 2. Get user preferences
  const userPrefs = await getUserNotificationPreferences(userId);
  const user = await getUserById(userId);

  // 3. Determine channels (config defaults, filtered by user prefs)
  const channels = (payload.channels ?? config.defaultChannels)
    .filter(ch => {
      if (config.required.includes(ch)) return true;  // Cannot opt out
      return userPrefs[type]?.[ch] !== false;           // User preference
    });

  // 4. Rate limit non-critical notifications
  if (priority !== 'critical') {
    const recentCount = await getRecentNotificationCount(userId, '1h');
    if (recentCount > MAX_NOTIFICATIONS_PER_HOUR) {
      await queueForDigest(userId, type, data);
      return;
    }
  }

  // 5. Dispatch to each channel
  const dispatches = channels.map(channel => {
    switch (channel) {
      case 'email':
        return emailQueue.add({ userId, type, data, template: config.emailTemplate });
      case 'push':
        return pushQueue.add({ userId, type, data, title: config.pushTitle(data), body: config.pushBody(data) });
      case 'sms':
        return smsQueue.add({ userId, type, data, message: config.smsMessage(data) });
      case 'in_app':
        return inAppQueue.add({ userId, type, data });
    }
  });

  await Promise.allSettled(dispatches);

  // 6. Record notification sent
  await db.notifications.create({
    userId,
    type,
    channels,
    data,
    sentAt: new Date(),
  });
}
```

### Step 5: Delivery Tracking and Bounce Handling
Monitor email health and handle failures:

```
DELIVERY TRACKING:
┌──────────────────────────────────────────────────────────┐
│  Email Lifecycle:                                         │
│  QUEUED -> SENT -> DELIVERED -> OPENED -> CLICKED          │
│                └-> BOUNCED (hard/soft)                     │
│                └-> DEFERRED (retry)                        │
│                └-> DROPPED (suppression list)              │
│                └-> SPAM (complaint)                        │
│                                                           │
│  Metrics Dashboard:                                       │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Metric              │ Current │ Target │ Alert     │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Delivery rate       │ 98.5%   │ > 97%  │ < 95%    │  │
│  │  Open rate (trans.)  │ 62%     │ > 50%  │ < 40%    │  │
│  │  Click rate (trans.) │ 25%     │ > 15%  │ < 10%    │  │
│  │  Bounce rate         │ 1.2%    │ < 2%   │ > 3%     │  │
│  │  Spam complaint rate │ 0.02%   │ < 0.1% │ > 0.3%   │  │
│  │  Unsubscribe rate    │ 0.5%    │ < 1%   │ > 2%     │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Critical Thresholds:                                     │
│  Spam complaint > 0.1%: ISPs will throttle or block you   │
│  Bounce rate > 5%: Sending reputation degraded            │
│  Delivery rate < 90%: Investigate immediately             │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Bounce and complaint handler (webhook)
async function handleEmailEvent(event: EmailWebhookEvent): Promise<void> {
  switch (event.type) {
    case 'bounce': {
      if (event.bounceType === 'hard') {
        // Permanent failure — address does not exist
        await db.emailAddresses.update(event.email, {
          status: 'invalid',
          invalidReason: 'hard_bounce',
          invalidAt: new Date(),
        });
        // Add to suppression list — never email again
        await suppressionList.add(event.email, 'hard_bounce');
        console.warn(`Hard bounce: ${event.email} — added to suppression list`);
      } else {
        // Soft bounce — temporary issue (mailbox full, server down)
        await db.emailEvents.create({
          email: event.email,
          type: 'soft_bounce',
          reason: event.reason,
          timestamp: new Date(),
        });
        // After 3 soft bounces in 30 days, treat as hard bounce
        const recentBounces = await db.emailEvents.count({
          email: event.email,
          type: 'soft_bounce',
          after: daysAgo(30),
        });
        if (recentBounces >= 3) {
          await suppressionList.add(event.email, 'repeated_soft_bounce');
        }
      }
      break;
    }

    case 'complaint': {
      // User marked email as spam — this is serious
      await db.emailAddresses.update(event.email, {
        status: 'complained',
        complainedAt: new Date(),
      });
      await suppressionList.add(event.email, 'spam_complaint');
      // Unsubscribe from ALL marketing immediately
      await unsubscribeAll(event.email);
      // Alert the team
      await alertTeam('spam_complaint', {
        email: event.email,
        emailType: event.emailType,
        subject: event.subject,
      });
      break;
    }

    case 'unsubscribe': {
      await updateSubscriptionPreferences(event.email, {
        [event.category]: false,
      });
      break;
    }
  }
}
```

#### DNS Authentication for Deliverability
```
EMAIL DNS AUTHENTICATION:
┌──────────────────────────────────────────────────────────┐
│  SPF (Sender Policy Framework):                           │
│  Record: TXT @ "v=spf1 include:_spf.google.com           │
│          include:sendgrid.net include:amazonses.com ~all"  │
│  Purpose: Declares which servers can send on your behalf  │
│                                                           │
│  DKIM (DomainKeys Identified Mail):                       │
│  Record: TXT <selector>._domainkey                        │
│  Value: "v=DKIM1; k=rsa; p=<public-key>"                  │
│  Purpose: Cryptographic signature proving email is from you│
│                                                           │
│  DMARC (Domain-based Message Authentication):             │
│  Record: TXT _dmarc "v=DMARC1; p=reject;                  │
│          rua=mailto:dmarc@myapp.com;                       │
│          ruf=mailto:dmarc-forensic@myapp.com; pct=100"     │
│  Purpose: Policy for handling SPF/DKIM failures            │
│                                                           │
│  DMARC Policy Progression:                                │
│  Week 1-2: p=none (monitor only, collect reports)         │
│  Week 3-4: p=quarantine (suspicious goes to spam)         │
│  Week 5+:  p=reject (unauthorized email rejected)         │
│                                                           │
│  Return-Path / Bounce Domain:                             │
│  CNAME: bounces.myapp.com -> provider bounce domain       │
│  Purpose: Aligns bounce domain with From domain           │
│                                                           │
│  Subdomain Strategy:                                      │
│  notifications.myapp.com  — Transactional emails           │
│  marketing.myapp.com      — Marketing emails               │
│  Reason: Isolate reputation — marketing issues do not      │
│  affect transactional deliverability                       │
└──────────────────────────────────────────────────────────┘
```

### Step 6: Transactional vs Marketing Separation
Maintain sending reputation with isolated streams:

```
EMAIL STREAM SEPARATION:
┌──────────────────────────────────────────────────────────┐
│  TRANSACTIONAL STREAM                                     │
│  Domain: notifications.myapp.com                          │
│  IP: Dedicated IP (or shared transactional pool)          │
│  Provider: Postmark / SES (optimized for transactional)   │
│  Rate: Immediate delivery, no batching                    │
│  Content: Password resets, receipts, alerts                │
│  Unsubscribe: NOT required (service-essential emails)     │
│  Expected metrics: > 99% delivery, > 60% open rate        │
│                                                           │
│  MARKETING STREAM                                         │
│  Domain: marketing.myapp.com                              │
│  IP: Separate dedicated IP (warmed up gradually)          │
│  Provider: SendGrid / Mailchimp (marketing features)      │
│  Rate: Batched, throttled, scheduled                       │
│  Content: Newsletters, promotions, product updates         │
│  Unsubscribe: REQUIRED (CAN-SPAM, GDPR)                  │
│  Expected metrics: > 95% delivery, > 20% open rate        │
│                                                           │
│  Why separate?                                            │
│  - Marketing email gets more spam complaints               │
│  - Complaints on marketing domain do not tank your         │
│    transactional deliverability                            │
│  - Different warm-up schedules and sending patterns        │
│  - Different compliance requirements                       │
│  - Easier to debug deliverability issues per stream        │
└──────────────────────────────────────────────────────────┘

IP WARM-UP SCHEDULE (new dedicated IP):
┌──────────────────────────────────────────────────────────┐
│  Day  │ Volume/day │ Notes                                │
│  ─────────────────────────────────────────────────────── │
│  1-2  │ 50         │ Send to most engaged users only      │
│  3-4  │ 100        │ Monitor bounces closely               │
│  5-7  │ 500        │ Check spam folder placement           │
│  8-14 │ 2,000      │ Expand to active users                │
│  15-21│ 10,000     │ Monitor delivery rates                 │
│  22-30│ 50,000     │ Full volume if metrics are healthy     │
│  30+  │ Full       │ Maintain consistent daily volume       │
│                                                           │
│  Rules:                                                   │
│  - Never skip days during warm-up                         │
│  - Start with most engaged recipients                     │
│  - Stop immediately if bounce rate > 5%                    │
│  - Stop immediately if spam complaints > 0.1%             │
└──────────────────────────────────────────────────────────┘
```

### Step 7: Commit and Report
```
1. Save notification system files:
   - Email service: `src/services/email/` or `src/lib/notifications/`
   - Templates: `emails/` or `src/emails/` (React Email / MJML)
   - Notification service: `src/services/notifications/`
   - Webhook handler: `src/api/webhooks/email.ts`
   - Preference management: `src/services/preferences/`
2. Commit: "email: <description> — <components implemented>"
3. If email setup: "email: transactional email — Resend + React Email templates"
4. If notifications: "email: notification system — 4 channels, preference center"
```

## Key Behaviors

1. **Separate transactional and marketing streams.** Use different subdomains and ideally different providers or IPs. A marketing spam complaint must never affect password reset delivery.
2. **Authenticate your domain fully.** SPF, DKIM, and DMARC are non-negotiable. Without all three, your emails land in spam. Progress DMARC to p=reject within 30 days.
3. **Always send a plain text version.** Not all email clients render HTML. Screen readers rely on plain text. Some security-conscious users disable HTML email.
4. **Honor unsubscribe immediately.** Process unsubscribe requests synchronously. Do not batch them. CAN-SPAM requires honoring within 10 days; best practice is instant.
5. **Implement a suppression list.** Never email a hard-bounced or complained address again. Check the suppression list before every send. This protects your sender reputation.
6. **Rate-limit notifications per user.** No user should receive more than a reasonable number of notifications per hour. Batch excess into digest emails.
7. **Use queues for email sending.** Never send email synchronously in a request handler. Queue the email and return immediately. Retry on transient failures with exponential backoff.
8. **Monitor deliverability metrics daily.** Track delivery rate, bounce rate, spam complaint rate, and open rate. Alert immediately when metrics degrade.

## Example Usage

### Setting up transactional email
```
User: /godmode:email Set up transactional emails for our SaaS

Email: Analyzing requirements...

Application: SaaS product
Email types: Welcome, email verification, password reset,
  payment receipts, usage alerts
Volume: ~500 emails/day (growing)
Stack: Next.js + TypeScript

Recommendation: Resend (best DX for TypeScript/React projects)

Implementation:
  1. Resend account setup + domain verification
  2. DNS records (SPF, DKIM, DMARC) for notifications.myapp.com
  3. React Email templates (5 templates)
  4. Email service with queue (BullMQ)
  5. Webhook handler for bounces and complaints
  6. Suppression list management

Files created:
  src/lib/email/client.ts — Resend client wrapper
  src/lib/email/queue.ts — Email queue (BullMQ)
  src/lib/email/suppression.ts — Suppression list
  emails/welcome.tsx — Welcome email template
  emails/verify-email.tsx — Verification template
  emails/password-reset.tsx — Password reset template
  emails/payment-receipt.tsx — Payment receipt template
  emails/usage-alert.tsx — Usage alert template
  src/api/webhooks/resend.ts — Bounce/complaint handler

DNS records to add:
  TXT @ "v=spf1 include:resend.com ~all"
  CNAME resend._domainkey -> <provided by Resend>
  TXT _dmarc "v=DMARC1; p=none; rua=mailto:dmarc@myapp.com"

Next: Test in staging, then progress DMARC to p=reject in 30 days
```

### Building a multi-channel notification system
```
User: /godmode:email Build a notification system with email, push, SMS, and in-app

Email: Designing notification architecture...

Channels:
  Email: Resend (transactional) + SendGrid (marketing)
  Push: Firebase Cloud Messaging (web + mobile)
  SMS: Twilio (OTP + critical alerts only)
  In-app: WebSocket (real-time) + REST (notification center)

Architecture:
  Event bus (Redis Streams) -> Notification service
    -> User preference check
    -> Channel router
    -> Per-channel queues (BullMQ)
    -> Provider delivery
    -> Delivery tracking

Notification types: 12 types across 4 channels
Preference center: Per-type, per-channel opt-in/opt-out
Rate limiting: Max 10 notifications/hour (non-critical)
Digest: Hourly batch for low-priority notifications

Files created:
  src/services/notifications/service.ts — Core notification service
  src/services/notifications/channels/ — Channel implementations
  src/services/notifications/preferences.ts — User preferences
  src/services/notifications/digest.ts — Digest batching
  src/api/routes/notifications.ts — Notification center API
  src/api/ws/notifications.ts — WebSocket real-time

Estimated monthly cost:
  Resend: $20 (10K emails)
  SendGrid: Free tier (marketing)
  FCM: Free
  Twilio: $50 (1K SMS)
  Total: ~$70/month
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full notification system design and implementation |
| `--email` | Email service integration only |
| `--templates` | Email template design and generation only |
| `--push` | Push notification setup only |
| `--sms` | SMS notification setup only |
| `--inapp` | In-app notification system only |
| `--deliverability` | Email deliverability audit and fixes |
| `--provider <name>` | Use specific email provider (sendgrid, ses, postmark, resend) |
| `--dns` | Email DNS authentication setup (SPF, DKIM, DMARC) |
| `--preferences` | Notification preference center design only |
| `--digest` | Notification digest and batching only |

## HARD RULES

1. **Never send email synchronously in request handlers.** Email delivery can take seconds and fail transiently. Always queue the email and return the API response immediately.
2. **Never mix transactional and marketing email on the same domain/IP.** Marketing spam complaints destroy transactional deliverability. Use separate subdomains (notifications.myapp.com vs marketing.myapp.com).
3. **Never email a hard-bounced address again.** Check the suppression list before every send. Repeatedly emailing invalid addresses tanks your sender reputation.
4. **Never skip SPF, DKIM, and DMARC.** All three DNS authentication records are required. Without them, your emails land in spam. Progress DMARC to `p=reject` within 30 days.
5. **Never send notifications without checking user preferences.** Every non-critical notification must respect user opt-out. Over-notifying drives users to mark you as spam.

## Loop Protocol

```
notification_queue = detect_notification_types()  // e.g., [welcome, verify, reset, receipt, alert, digest]
current_iteration = 0

WHILE notification_queue is not empty:
  batch = notification_queue.take(3)
  current_iteration += 1

  FOR each notification_type in batch:
    1. Define channels (email, push, SMS, in-app) and priority
    2. Design email template (React Email or MJML)
    3. Implement send function with queue + retry logic
    4. Add plain-text fallback
    5. Test rendering across clients (Litmus or manual spot check)
    6. Verify suppression list check is in the send path

  Log: "Iteration {current_iteration}: implemented {batch.length} notification types, {notification_queue.remaining} remaining"

  IF notification_queue is empty:
    Verify DNS records (SPF, DKIM, DMARC)
    Set up bounce/complaint webhook handler
    BREAK
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (4 worktrees):

Agent 1 — "email-service":
  EnterWorktree("email-service")
  Set up email provider client (Resend, SES, Postmark, SendGrid)
  Implement email queue with retry and exponential backoff
  Build suppression list management
  ExitWorktree()

Agent 2 — "templates":
  EnterWorktree("templates")
  Create email templates for all notification types (React Email or MJML)
  Add plain-text versions for every HTML template
  Verify responsive design and client compatibility
  ExitWorktree()

Agent 3 — "delivery-tracking":
  EnterWorktree("delivery-tracking")
  Implement webhook handler for bounces, complaints, unsubscribes
  Build delivery metrics dashboard (delivery rate, bounce rate, open rate)
  Set up alerts for degraded deliverability
  ExitWorktree()

Agent 4 — "notification-system":
  EnterWorktree("notification-system")
  Build multi-channel notification service (email + push + SMS + in-app)
  Implement user preference center
  Add rate limiting and digest batching for low-priority notifications
  ExitWorktree()

MERGE: Combine all branches, verify end-to-end email delivery flow.
```

## Auto-Detection

```
AUTO-DETECT email/notification context:
  1. Check for existing email provider SDK: resend, @sendgrid/mail, aws-sdk ses, postmark
  2. Scan for email templates: emails/, src/emails/, templates/email/ directories
  3. Check for notification service: src/services/notifications/, src/lib/email/
  4. Detect queue system: bullmq, bull, @aws-sdk/client-sqs, amqplib
  5. Check DNS records (if domain known): dig TXT _dmarc.<domain>, dig TXT <domain> for SPF
  6. Scan for webhook endpoints: /webhooks/email, /api/webhooks/resend, /api/webhooks/sendgrid
  7. Check environment variables: RESEND_API_KEY, SENDGRID_API_KEY, AWS_SES_REGION

  USE detected context to:
    - Reuse existing email provider (don't switch providers unless asked)
    - Match existing template technology (React Email vs MJML vs raw HTML)
    - Identify missing components (no suppression list? no webhook handler?)
    - Prioritize gaps in email infrastructure
```

## Anti-Patterns

- **Do NOT send email synchronously in request handlers.** Email delivery can take seconds and fail transiently. Use a queue with retry logic. Return the API response immediately.
- **Do NOT mix transactional and marketing on the same domain/IP.** Marketing spam complaints destroy transactional deliverability. Isolate them completely.
- **Do NOT email hard-bounced addresses.** Repeatedly emailing invalid addresses tanks your sender reputation. Maintain and enforce a suppression list.
- **Do NOT skip SPF, DKIM, and DMARC.** Without email authentication, your emails go to spam. All three are required for reliable delivery.
- **Do NOT use noreply@domain.com as the only contact.** Users will reply to transactional emails with support questions. Monitor the reply-to address or route to support.
- **Do NOT send notifications without user preference checks.** Every non-critical notification must respect user preferences. Over-notifying drives users to unsubscribe or mark you as spam.
- **Do NOT embed images as base64 in email HTML.** Email clients often block base64 images. Host images on a CDN and reference them with absolute URLs.
- **Do NOT launch marketing email on a new IP at full volume.** Warm up gradually over 30 days. ISPs flag sudden high-volume senders as spam.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run email tasks sequentially: email service, then templates, then delivery tracking, then notification system.
- Use branch isolation per task: `git checkout -b godmode-email-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
