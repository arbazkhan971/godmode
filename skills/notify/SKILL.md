---
name: notify
description: Push notifications, SMS, in-app notifications, notification preferences, multi-channel delivery. Use when user mentions notifications, push notifications, SMS, Twilio, Firebase Cloud Messaging, OneSignal, in-app alerts.
---

# Notify — Multi-Channel Notification Systems

## When to Activate
- User invokes `/godmode:notify`
- User says "push notifications", "send notifications", "notification system"
- User says "SMS alerts", "Twilio", "text messages"
- User says "Firebase Cloud Messaging", "FCM", "APNs", "OneSignal"
- User says "in-app notifications", "notification center", "notification bell"
- User says "notification preferences", "unsubscribe", "quiet hours"
- User says "notification digest", "batching notifications"
- User says "Slack notifications", "webhook notifications"
- Application needs to notify users across multiple channels
- Building a notification center with real-time updates

## Workflow

### Step 1: Notification Architecture Discovery
Identify all channels, event types, and delivery requirements:

```
NOTIFICATION REQUIREMENTS:
┌──────────────────────────────────────────────────────────┐
│  Channels:                                                │
│    Push: <web push | mobile push | both>                  │
│    SMS: <OTP | transactional alerts | marketing>          │
│    Email: <transactional | marketing | both>              │
│    In-App: <toast | notification center | both>           │
│    Webhook: <Slack | Discord | custom HTTP>               │
│                                                           │
│  Provider Selection:                                      │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Channel   │ Provider         │ Fallback           │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Push (mob)│ FCM + APNs       │ OneSignal          │  │
│  │  Push (web)│ FCM / Web Push   │ OneSignal          │  │
│  │  SMS       │ Twilio           │ AWS SNS / Vonage   │  │
│  │  Email     │ SendGrid / Resend│ SES / Postmark     │  │
│  │  In-App    │ WebSocket / SSE  │ Polling             │  │
│  │  Webhook   │ Custom HTTP      │ Queue + retry       │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Notification Categories:                                 │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Category        │ Priority  │ Examples             │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Security        │ Critical  │ 2FA codes, login     │  │
│  │                  │           │ alerts, password chg  │  │
│  │  Transactional   │ High      │ Order updates, pay-  │  │
│  │                  │           │ ment confirms, ship   │  │
│  │  Social          │ Medium    │ Mentions, comments,   │  │
│  │                  │           │ follows, reactions     │  │
│  │  Product         │ Medium    │ Feature announce,     │  │
│  │                  │           │ usage alerts, tips     │  │
│  │  Marketing       │ Low       │ Promotions, digest,   │  │
│  │                  │           │ re-engagement          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Volume Estimates:                                        │
│    Push: <N notifications/day>                            │
│    SMS: <N messages/month>                                │
│    Email: <N emails/day>                                  │
│    In-App: <N per user/day>                               │
│    Webhook: <N calls/day>                                 │
│                                                           │
│  Requirements:                                            │
│    Real-time: <yes/no — WebSocket for instant delivery>   │
│    Quiet hours: <respect user timezone preferences>       │
│    Digest: <batch low-priority into periodic summary>     │
│    i18n: <notification localization needed>                │
│    Compliance: <TCPA for SMS, CAN-SPAM, GDPR consent>    │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Provider Selection and Integration
Choose and configure notification providers:

#### Provider Comparison — Push Notifications
```
PUSH NOTIFICATION PROVIDERS:
┌──────────────────────────────────────────────────────────┐
│  Feature      │ FCM       │ APNs     │ OneSignal│ Expo   │
│  ─────────────────────────────────────────────────────── │
│  Platform     │ Android+  │ iOS/macOS│ All      │ React  │
│               │ Web+iOS   │          │          │ Native │
│  Pricing      │ Free      │ Free     │ Freemium │ Free   │
│  Free tier    │ Unlimited │ Unlimited│ Unlimited│ Unlmtd │
│  Rich media   │ Yes       │ Yes      │ Yes      │ Yes    │
│  Segmentation │ Topics    │ --       │ Advanced │ Basic  │
│  Analytics    │ Basic     │ --       │ Advanced │ Basic  │
│  API DX       │ Good      │ Moderate │ Great    │ Great  │
│  Self-hosted  │ No        │ No       │ No       │ No     │
│  A/B testing  │ Yes       │ No       │ Yes      │ No     │
│                                                           │
│  RECOMMENDATION:                                          │
│  - Native apps: FCM (Android) + APNs (iOS) directly      │
│  - Cross-platform with analytics: OneSignal               │
│  - React Native / Expo: Expo Notifications                │
│  - Web-only: FCM or native Web Push API                   │
└──────────────────────────────────────────────────────────┘
```

#### Provider Comparison — SMS
```
SMS PROVIDER COMPARISON:
┌──────────────────────────────────────────────────────────┐
│  Feature      │ Twilio    │ AWS SNS  │ Vonage   │MessageB│
│  ─────────────────────────────────────────────────────── │
│  Pricing/SMS  │ $0.0079   │ $0.00645 │ $0.0068  │$0.004  │
│  Global reach │ 180+ ctry │ 200+ ctry│ 200+ ctry│200+ctry│
│  Short codes  │ Yes       │ No       │ Yes      │ Yes    │
│  MMS support  │ Yes       │ No       │ Yes      │ Yes    │
│  Verify/OTP   │ Built-in  │ SNS+Pin  │ Built-in │ Yes    │
│  API DX       │ Excellent │ Good     │ Good     │ Good   │
│  Deliverabil. │ Excellent │ Good     │ Good     │ Good   │
│  Compliance   │ Built-in  │ Manual   │ Built-in │ Yes    │
│                                                           │
│  RECOMMENDATION:                                          │
│  - Best overall DX + reliability: Twilio                  │
│  - AWS-native / cost-sensitive: AWS SNS                   │
│  - OTP only with simplicity: Twilio Verify                │
│  - High-volume marketing SMS: MessageBird                 │
└──────────────────────────────────────────────────────────┘
```

#### Firebase Cloud Messaging (Push)
```typescript
// Push notification service — FCM
import admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  }),
});

interface PushPayload {
  title: string;
  body: string;
  imageUrl?: string;
  data?: Record<string, string>;
  badge?: number;
  sound?: string;
  channelId?: string;          // Android notification channel
  collapseKey?: string;        // Replace previous notification
  priority?: 'high' | 'normal';
  ttl?: number;                // Time-to-live in seconds
}

async function sendPushNotification(
  tokens: string[],
  payload: PushPayload,
): Promise<{ successCount: number; failedTokens: string[] }> {
  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: payload.title,
      body: payload.body,
      imageUrl: payload.imageUrl,
    },
    data: payload.data,
    android: {
      priority: payload.priority === 'high' ? 'high' : 'normal',
      ttl: (payload.ttl ?? 3600) * 1000,
      collapseKey: payload.collapseKey,
      notification: {
        channelId: payload.channelId ?? 'default',
        sound: payload.sound ?? 'default',
        clickAction: 'OPEN_APP',
      },
    },
    apns: {
      headers: {
        'apns-priority': payload.priority === 'high' ? '10' : '5',
        'apns-collapse-id': payload.collapseKey,
      },
      payload: {
        aps: {
          badge: payload.badge,
          sound: payload.sound ?? 'default',
          'mutable-content': 1,       // Enable notification service extension
        },
      },
    },
    webpush: {
      headers: { TTL: String(payload.ttl ?? 3600), Urgency: payload.priority ?? 'normal' },
      notification: {
        icon: '/icons/notification-icon.png',
        badge: '/icons/badge-icon.png',
        requireInteraction: payload.priority === 'high',
      },
    },
  };

  const response = await admin.messaging().sendEachForMulticast(message);

  // Collect failed tokens for cleanup
  const failedTokens: string[] = [];
  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      const errorCode = resp.error?.code;
      // Token is invalid or unregistered — remove from database
      if (
        errorCode === 'messaging/invalid-registration-token' ||
        errorCode === 'messaging/registration-token-not-registered'
      ) {
        failedTokens.push(tokens[idx]);
      }
    }
  });

  // Clean up stale tokens
  if (failedTokens.length > 0) {
    await removeStaleDeviceTokens(failedTokens);
  }

  return { successCount: response.successCount, failedTokens };
}

async function removeStaleDeviceTokens(tokens: string[]): Promise<void> {
  await db.deviceTokens.deleteMany({
    where: { token: { in: tokens } },
  });
}
```

#### Twilio SMS Integration
```typescript
// SMS notification service — Twilio
import twilio from 'twilio';

const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN,
);

interface SMSPayload {
  to: string;              // E.164 format: +1234567890
  body: string;
  type: 'otp' | 'transactional' | 'marketing';
}

async function sendSMS(payload: SMSPayload): Promise<string> {
  // Compliance check — do not send marketing SMS without consent
  if (payload.type === 'marketing') {
    const consent = await checkSMSConsent(payload.to);
    if (!consent.granted) {
      throw new SMSComplianceError('No SMS marketing consent', { to: payload.to });
    }
  }

  // Check opt-out list
  const isOptedOut = await smsOptOutList.contains(payload.to);
  if (isOptedOut) {
    throw new SMSOptOutError('Recipient has opted out of SMS', { to: payload.to });
  }

  const message = await twilioClient.messages.create({
    to: payload.to,
    from: getFromNumber(payload.type),  // Different numbers for different types
    body: payload.body,
    statusCallback: `${process.env.BASE_URL}/api/webhooks/twilio/status`,
  });

  // Track delivery
  await db.smsMessages.create({
    sid: message.sid,
    to: payload.to,
    type: payload.type,
    status: 'queued',
    sentAt: new Date(),
  });

  return message.sid;
}

// Twilio Verify for OTP (recommended over custom OTP)
async function sendOTP(phone: string, channel: 'sms' | 'call' = 'sms'): Promise<string> {
  const verification = await twilioClient.verify.v2
    .services(process.env.TWILIO_VERIFY_SERVICE_SID!)
    .verifications.create({ to: phone, channel });

  return verification.sid;
}

async function verifyOTP(phone: string, code: string): Promise<boolean> {
  try {
    const check = await twilioClient.verify.v2
      .services(process.env.TWILIO_VERIFY_SERVICE_SID!)
      .verificationChecks.create({ to: phone, code });
    return check.status === 'approved';
  } catch {
    return false;
  }
}

function getFromNumber(type: string): string {
  // Use different origination numbers by type for compliance
  switch (type) {
    case 'otp':           return process.env.TWILIO_OTP_NUMBER!;
    case 'transactional': return process.env.TWILIO_TRANSACTIONAL_NUMBER!;
    case 'marketing':     return process.env.TWILIO_MARKETING_NUMBER!;  // Must be short code or 10DLC
    default:              return process.env.TWILIO_TRANSACTIONAL_NUMBER!;
  }
}
```

### Step 3: Multi-Channel Notification Service
Core service that routes notifications across all channels:

```
NOTIFICATION ROUTING ARCHITECTURE:
┌────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────┐    ┌──────────────┐    ┌───────────────────┐    │
│  │ App Event│───>│ Notification │───>│ Preference Check  │    │
│  │ Trigger  │    │ Service      │    │ + Quiet Hours     │    │
│  └──────────┘    └──────────────┘    └─────────┬─────────┘    │
│                                                 │              │
│                    ┌────────────────────────────┼──────┐       │
│                    │         Channel Router     │      │       │
│                    │                            │      │       │
│          ┌────────┴──┐  ┌──────┐  ┌──────┐  ┌─┴────┐ │       │
│          │   Push    │  │ SMS  │  │Email │  │In-App│ │       │
│          │   Queue   │  │Queue │  │Queue │  │Queue │ │       │
│          └─────┬─────┘  └──┬───┘  └──┬───┘  └──┬───┘ │       │
│                │           │         │          │      │       │
│          ┌─────┴─────┐ ┌──┴───┐ ┌───┴────┐ ┌──┴───┐  │       │
│          │FCM / APNs │ │Twilio│ │SendGrid│ │WebSkt│  │       │
│          │OneSignal  │ │ SNS  │ │Resend  │ │ SSE  │  │       │
│          └─────┬─────┘ └──┬───┘ └───┬────┘ └──┬───┘  │       │
│                │           │         │          │      │       │
│          ┌─────┴───────────┴─────────┴──────────┴───┐ │       │
│          │          Delivery Tracking                │ │       │
│          │  (status callbacks, read receipts, logs)  │ │       │
│          └───────────────────────────────────────────┘ │       │
│                                                        │       │
│          ┌──────────────────────┐  ┌──────────────┐   │       │
│          │  Slack / Discord     │  │ Custom       │   │       │
│          │  Webhook Queue       │  │ Webhook Queue│   │       │
│          └──────────┬───────────┘  └──────┬───────┘   │       │
│                     │                      │           │       │
│                     └───────────┬──────────┘           │       │
│                           ┌────┴─────┐                │       │
│                           │ HTTP POST│                │       │
│                           │ + Retry  │                │       │
│                           └──────────┘                │       │
└────────────────────────────────────────────────────────────────┘
```

```typescript
// Core notification service
type Channel = 'push' | 'sms' | 'email' | 'in_app' | 'slack' | 'webhook';
type Priority = 'critical' | 'high' | 'normal' | 'low';

interface NotificationType {
  name: string;
  category: 'security' | 'transactional' | 'social' | 'product' | 'marketing';
  defaultChannels: Channel[];
  requiredChannels: Channel[];    // User cannot opt out of these
  allowedChannels: Channel[];     // All channels this type can use
  templates: Partial<Record<Channel, string>>;
  priority: Priority;
  batchable: boolean;             // Can be included in digest
  collapseKey?: string;           // Group/replace similar notifications
}

// Notification type registry
const NOTIFICATION_TYPES: Record<string, NotificationType> = {
  'security.login_alert': {
    name: 'Login from new device',
    category: 'security',
    defaultChannels: ['push', 'email', 'in_app'],
    requiredChannels: ['email', 'in_app'],
    allowedChannels: ['push', 'sms', 'email', 'in_app'],
    templates: { email: 'login-alert', push: 'login-alert', sms: 'login-alert' },
    priority: 'critical',
    batchable: false,
  },
  'transactional.order_confirmed': {
    name: 'Order confirmed',
    category: 'transactional',
    defaultChannels: ['push', 'email', 'in_app'],
    requiredChannels: ['email'],
    allowedChannels: ['push', 'email', 'in_app'],
    templates: { email: 'order-confirmed', push: 'order-confirmed' },
    priority: 'high',
    batchable: false,
  },
  'social.new_comment': {
    name: 'New comment on your post',
    category: 'social',
    defaultChannels: ['push', 'in_app'],
    requiredChannels: [],
    allowedChannels: ['push', 'email', 'in_app'],
    templates: { email: 'new-comment', push: 'new-comment' },
    priority: 'normal',
    batchable: true,
    collapseKey: 'comments',
  },
  'social.new_follower': {
    name: 'New follower',
    category: 'social',
    defaultChannels: ['in_app'],
    requiredChannels: [],
    allowedChannels: ['push', 'email', 'in_app'],
    templates: { email: 'new-follower', push: 'new-follower' },
    priority: 'low',
    batchable: true,
    collapseKey: 'followers',
  },
  'product.usage_alert': {
    name: 'Usage limit approaching',
    category: 'product',
    defaultChannels: ['push', 'email', 'in_app'],
    requiredChannels: ['in_app'],
    allowedChannels: ['push', 'sms', 'email', 'in_app', 'slack'],
    templates: { email: 'usage-alert', push: 'usage-alert', sms: 'usage-alert' },
    priority: 'high',
    batchable: false,
  },
  'marketing.weekly_digest': {
    name: 'Weekly digest',
    category: 'marketing',
    defaultChannels: ['email'],
    requiredChannels: [],
    allowedChannels: ['email', 'in_app'],
    templates: { email: 'weekly-digest' },
    priority: 'low',
    batchable: false,
  },
};

interface SendNotificationInput {
  userId: string;
  type: string;                   // Key from NOTIFICATION_TYPES
  data: Record<string, unknown>;  // Template variables
  channels?: Channel[];           // Override default channels
  priority?: Priority;            // Override default priority
  scheduledFor?: Date;            // Delayed delivery
  idempotencyKey?: string;        // Prevent duplicate sends
}

class NotificationService {
  constructor(
    private readonly preferences: PreferenceService,
    private readonly pushProvider: PushProvider,
    private readonly smsProvider: SMSProvider,
    private readonly emailProvider: EmailProvider,
    private readonly inAppProvider: InAppProvider,
    private readonly webhookProvider: WebhookProvider,
    private readonly queue: NotificationQueue,
    private readonly db: Database,
  ) {}

  async send(input: SendNotificationInput): Promise<string> {
    const config = NOTIFICATION_TYPES[input.type];
    if (!config) throw new Error(`Unknown notification type: ${input.type}`);

    const notificationId = crypto.randomUUID();
    const priority = input.priority ?? config.priority;

    // 1. Idempotency check — prevent duplicate sends
    if (input.idempotencyKey) {
      const existing = await this.db.notifications.findByIdempotencyKey(input.idempotencyKey);
      if (existing) return existing.id;
    }

    // 2. Resolve target channels (defaults -> user overrides -> preference filter)
    const channels = await this.resolveChannels(input.userId, input.type, input.channels);

    // 3. Check quiet hours for non-critical notifications
    if (priority !== 'critical') {
      const inQuietHours = await this.isInQuietHours(input.userId);
      if (inQuietHours) {
        // Defer to end of quiet hours, but in-app is always allowed
        const deferredChannels = channels.filter(ch => ch !== 'in_app');
        const immediateChannels = channels.filter(ch => ch === 'in_app');

        if (deferredChannels.length > 0) {
          await this.scheduleAfterQuietHours(input.userId, {
            ...input,
            channels: deferredChannels,
            notificationId,
          });
        }

        // Only send in-app immediately during quiet hours
        if (immediateChannels.length > 0) {
          await this.dispatchToChannels(notificationId, input, immediateChannels, config);
        }

        return notificationId;
      }
    }

    // 4. Rate limiting for non-critical notifications
    if (priority !== 'critical' && config.batchable) {
      const recentCount = await this.getRecentNotificationCount(input.userId, '1h');
      if (recentCount > MAX_NOTIFICATIONS_PER_HOUR) {
        await this.addToDigest(input.userId, input.type, input.data, notificationId);
        return notificationId;
      }
    }

    // 5. Schedule for later if requested
    if (input.scheduledFor && input.scheduledFor > new Date()) {
      await this.queue.schedule(input.scheduledFor, { ...input, notificationId });
      return notificationId;
    }

    // 6. Dispatch to all resolved channels
    await this.dispatchToChannels(notificationId, input, channels, config);

    return notificationId;
  }

  private async resolveChannels(
    userId: string,
    type: string,
    overrideChannels?: Channel[],
  ): Promise<Channel[]> {
    const config = NOTIFICATION_TYPES[type];
    const prefs = await this.preferences.get(userId);

    const candidateChannels = overrideChannels ?? config.defaultChannels;

    return candidateChannels.filter(channel => {
      // Required channels cannot be opted out
      if (config.requiredChannels.includes(channel)) return true;
      // Must be in allowed channels list
      if (!config.allowedChannels.includes(channel)) return false;
      // Check user preference
      return prefs.isChannelEnabled(type, channel);
    });
  }

  private async dispatchToChannels(
    notificationId: string,
    input: SendNotificationInput,
    channels: Channel[],
    config: NotificationType,
  ): Promise<void> {
    // Record notification in database
    await this.db.notifications.create({
      id: notificationId,
      userId: input.userId,
      type: input.type,
      channels,
      data: input.data,
      priority: input.priority ?? config.priority,
      idempotencyKey: input.idempotencyKey,
      status: 'dispatching',
      createdAt: new Date(),
    });

    // Dispatch to each channel via queue
    const dispatches = channels.map(channel =>
      this.queue.add(`notify:${channel}`, {
        notificationId,
        userId: input.userId,
        type: input.type,
        channel,
        data: input.data,
        template: config.templates[channel],
        priority: input.priority ?? config.priority,
      }),
    );

    await Promise.allSettled(dispatches);
  }

  private async isInQuietHours(userId: string): Promise<boolean> {
    const prefs = await this.preferences.get(userId);
    if (!prefs.quietHours.enabled) return false;

    const userTz = prefs.timezone ?? 'UTC';
    const now = new Date();
    const userHour = getHourInTimezone(now, userTz);

    const { start, end } = prefs.quietHours; // e.g., { start: 22, end: 8 }
    if (start < end) {
      return userHour >= start && userHour < end;
    }
    // Wraps midnight: e.g., 22:00 - 08:00
    return userHour >= start || userHour < end;
  }

  private async getRecentNotificationCount(userId: string, window: string): Promise<number> {
    const since = new Date(Date.now() - parseDuration(window));
    return this.db.notifications.count({
      where: { userId, createdAt: { gte: since } },
    });
  }

  private async addToDigest(
    userId: string,
    type: string,
    data: Record<string, unknown>,
    notificationId: string,
  ): Promise<void> {
    await this.db.digestQueue.create({
      notificationId,
      userId,
      type,
      data,
      queuedAt: new Date(),
    });
  }
}

const MAX_NOTIFICATIONS_PER_HOUR = 15;
```

### Step 4: Notification Preference Management
User-controlled opt-in/opt-out per type and channel:

```
NOTIFICATION PREFERENCES SCHEMA:
┌──────────────────────────────────────────────────────────┐
│  User Preference Center UI:                               │
│                                                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Security Alerts                                    │  │
│  │    Login from new device   Push ■  Email ■  SMS □  │  │
│  │    Password changed        Push ■  Email ■  SMS □  │  │
│  │    (Security alerts cannot be fully disabled)       │  │
│  │                                                     │  │
│  │  Orders & Payments                                  │  │
│  │    Order updates           Push ■  Email ■  SMS □  │  │
│  │    Payment receipts        Push □  Email ■  SMS □  │  │
│  │    Shipping updates        Push ■  Email ■  SMS □  │  │
│  │                                                     │  │
│  │  Social                                             │  │
│  │    Comments & replies      Push ■  Email □  SMS □  │  │
│  │    New followers           Push □  Email □  SMS □  │  │
│  │    Mentions                Push ■  Email □  SMS □  │  │
│  │                                                     │  │
│  │  Product Updates                                    │  │
│  │    Feature announcements   Push □  Email ■  SMS □  │  │
│  │    Usage alerts            Push ■  Email ■  SMS □  │  │
│  │                                                     │  │
│  │  Marketing                                          │  │
│  │    Weekly digest           Push □  Email ■  SMS □  │  │
│  │    Promotions              Push □  Email □  SMS □  │  │
│  │                                                     │  │
│  │  ─────────────────────────────────────────────────  │  │
│  │  Global Settings                                    │  │
│  │    Quiet hours: 10:00 PM — 8:00 AM                 │  │
│  │    Timezone: America/New_York                       │  │
│  │    Digest frequency: Daily at 9:00 AM              │  │
│  │    Unsubscribe from all marketing  [Unsubscribe]   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  ■ = Enabled   □ = Disabled   (locked) = Cannot disable  │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Notification preference service
interface NotificationPreferences {
  userId: string;
  timezone: string;
  quietHours: {
    enabled: boolean;
    start: number;   // Hour in 24h format (e.g., 22 = 10 PM)
    end: number;     // Hour in 24h format (e.g., 8 = 8 AM)
  };
  digestFrequency: 'realtime' | 'hourly' | 'daily' | 'weekly';
  digestTime: string;  // HH:mm in user timezone
  channelPreferences: Record<string, Partial<Record<Channel, boolean>>>;
  // e.g., { 'social.new_comment': { push: true, email: false } }
  globalUnsubscribe: {
    marketing: boolean;      // Unsubscribe from all marketing
    allExceptSecurity: boolean;  // Nuclear option
  };
}

class PreferenceService {
  async get(userId: string): Promise<UserPreferences> {
    const stored = await this.db.notificationPreferences.findUnique({
      where: { userId },
    });

    // Merge stored preferences with defaults
    return new UserPreferences(stored ?? this.getDefaults());
  }

  async update(userId: string, updates: Partial<NotificationPreferences>): Promise<void> {
    // Validate: cannot disable required channels
    if (updates.channelPreferences) {
      for (const [type, channels] of Object.entries(updates.channelPreferences)) {
        const config = NOTIFICATION_TYPES[type];
        if (!config) continue;
        for (const [channel, enabled] of Object.entries(channels)) {
          if (!enabled && config.requiredChannels.includes(channel as Channel)) {
            throw new Error(`Cannot disable ${channel} for ${type} — it is a required channel`);
          }
        }
      }
    }

    await this.db.notificationPreferences.upsert({
      where: { userId },
      update: updates,
      create: { userId, ...this.getDefaults(), ...updates },
    });
  }

  // One-click unsubscribe handler (for email links)
  async handleUnsubscribe(token: string): Promise<void> {
    const { userId, type, channel } = await this.verifyUnsubscribeToken(token);

    if (type === 'all_marketing') {
      await this.update(userId, {
        globalUnsubscribe: { marketing: true, allExceptSecurity: false },
      });
    } else {
      await this.update(userId, {
        channelPreferences: { [type]: { [channel]: false } },
      });
    }

    // Log for compliance audit
    await this.db.unsubscribeLog.create({
      userId, type, channel, unsubscribedAt: new Date(), method: 'one_click',
    });
  }

  private getDefaults(): NotificationPreferences {
    return {
      userId: '',
      timezone: 'UTC',
      quietHours: { enabled: false, start: 22, end: 8 },
      digestFrequency: 'daily',
      digestTime: '09:00',
      channelPreferences: {},
      globalUnsubscribe: { marketing: false, allExceptSecurity: false },
    };
  }
}
```

### Step 5: Database Schema — Notification Center
Persistent storage for notification center and delivery tracking:

```sql
-- Notification center database schema

-- Core notifications table
CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(100) NOT NULL,           -- e.g., 'social.new_comment'
    category        VARCHAR(50) NOT NULL,            -- 'security', 'transactional', 'social', 'product', 'marketing'
    priority        VARCHAR(20) NOT NULL DEFAULT 'normal',
    title           TEXT NOT NULL,
    body            TEXT NOT NULL,
    image_url       TEXT,
    action_url      TEXT,                            -- Deep link or URL on click
    data            JSONB DEFAULT '{}',              -- Arbitrary payload
    channels        TEXT[] NOT NULL DEFAULT '{}',    -- Channels sent to
    idempotency_key VARCHAR(255) UNIQUE,
    read_at         TIMESTAMPTZ,
    seen_at         TIMESTAMPTZ,                     -- Appeared in feed (not necessarily read)
    archived_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Indexes for notification center queries
    CONSTRAINT valid_priority CHECK (priority IN ('critical', 'high', 'normal', 'low'))
);

CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_user_category ON notifications(user_id, category, created_at DESC);
CREATE INDEX idx_notifications_idempotency ON notifications(idempotency_key) WHERE idempotency_key IS NOT NULL;

-- Delivery tracking per channel
CREATE TABLE notification_deliveries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    channel         VARCHAR(20) NOT NULL,            -- 'push', 'sms', 'email', 'in_app', 'webhook'
    provider        VARCHAR(50) NOT NULL,            -- 'fcm', 'apns', 'twilio', 'sendgrid', etc.
    provider_id     VARCHAR(255),                    -- Provider's message ID
    status          VARCHAR(30) NOT NULL DEFAULT 'pending',
    -- pending -> queued -> sent -> delivered -> read / failed / bounced
    error_message   TEXT,
    attempts        INTEGER NOT NULL DEFAULT 0,
    delivered_at    TIMESTAMPTZ,
    read_at         TIMESTAMPTZ,
    failed_at       TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT valid_channel CHECK (channel IN ('push', 'sms', 'email', 'in_app', 'webhook', 'slack')),
    CONSTRAINT valid_status CHECK (status IN ('pending', 'queued', 'sent', 'delivered', 'read', 'failed', 'bounced'))
);

CREATE INDEX idx_deliveries_notification ON notification_deliveries(notification_id);
CREATE INDEX idx_deliveries_status ON notification_deliveries(status, created_at);

-- Device tokens for push notifications
CREATE TABLE device_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL UNIQUE,
    platform    VARCHAR(20) NOT NULL,    -- 'ios', 'android', 'web'
    device_name VARCHAR(100),
    app_version VARCHAR(20),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_device_tokens_user ON device_tokens(user_id) WHERE is_active = TRUE;

-- User notification preferences
CREATE TABLE notification_preferences (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    timezone            VARCHAR(50) NOT NULL DEFAULT 'UTC',
    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    quiet_hours_start   INTEGER DEFAULT 22,          -- Hour (0-23)
    quiet_hours_end     INTEGER DEFAULT 8,           -- Hour (0-23)
    digest_frequency    VARCHAR(20) NOT NULL DEFAULT 'daily',
    digest_time         TIME NOT NULL DEFAULT '09:00',
    channel_prefs       JSONB NOT NULL DEFAULT '{}', -- Per-type, per-channel preferences
    global_marketing_unsub BOOLEAN NOT NULL DEFAULT FALSE,
    global_all_unsub       BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Unsubscribe audit log (compliance)
CREATE TABLE unsubscribe_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(100) NOT NULL,  -- Notification type or 'all_marketing'
    channel         VARCHAR(20),
    method          VARCHAR(30) NOT NULL,   -- 'one_click', 'preference_center', 'api', 'reply'
    unsubscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_unsub_log_user ON unsubscribe_log(user_id, unsubscribed_at DESC);

-- Digest queue for batched notifications
CREATE TABLE digest_queue (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(100) NOT NULL,
    data            JSONB NOT NULL DEFAULT '{}',
    queued_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_in_digest  BOOLEAN NOT NULL DEFAULT FALSE,
    digest_sent_at  TIMESTAMPTZ
);

CREATE INDEX idx_digest_queue_user_pending ON digest_queue(user_id, queued_at) WHERE sent_in_digest = FALSE;
```

### Step 6: Real-Time In-App Notifications via WebSocket
Live notification delivery for the notification center:

```typescript
// WebSocket notification gateway
import { WebSocketServer, WebSocket } from 'ws';
import { verifyToken } from '../auth/jwt';

interface ConnectedClient {
  ws: WebSocket;
  userId: string;
  connectedAt: Date;
  lastPing: Date;
}

class NotificationGateway {
  private clients = new Map<string, Set<ConnectedClient>>();  // userId -> connections
  private wss: WebSocketServer;

  constructor(server: http.Server) {
    this.wss = new WebSocketServer({ server, path: '/ws/notifications' });

    this.wss.on('connection', async (ws, req) => {
      try {
        // Authenticate via query param or first message
        const token = new URL(req.url!, `http://${req.headers.host}`).searchParams.get('token');
        if (!token) { ws.close(4001, 'Authentication required'); return; }

        const payload = await verifyToken(token);
        const userId = payload.sub;

        const client: ConnectedClient = { ws, userId, connectedAt: new Date(), lastPing: new Date() };

        // Track connection
        if (!this.clients.has(userId)) this.clients.set(userId, new Set());
        this.clients.get(userId)!.add(client);

        // Send unread count on connect
        const unreadCount = await this.getUnreadCount(userId);
        ws.send(JSON.stringify({ type: 'init', unreadCount }));

        ws.on('message', (raw) => this.handleMessage(client, raw.toString()));
        ws.on('close', () => this.handleDisconnect(client));
        ws.on('pong', () => { client.lastPing = new Date(); });

      } catch (err) {
        ws.close(4001, 'Authentication failed');
      }
    });

    // Heartbeat to detect stale connections
    setInterval(() => this.pingAll(), 30_000);
  }

  // Push a notification to a user in real time
  async pushToUser(userId: string, notification: InAppNotification): Promise<void> {
    const connections = this.clients.get(userId);
    if (!connections || connections.size === 0) return;  // User not connected

    const payload = JSON.stringify({
      type: 'notification',
      notification: {
        id: notification.id,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        imageUrl: notification.imageUrl,
        actionUrl: notification.actionUrl,
        createdAt: notification.createdAt.toISOString(),
      },
    });

    for (const client of connections) {
      if (client.ws.readyState === WebSocket.OPEN) {
        client.ws.send(payload);
      }
    }
  }

  // Update badge count across all user devices
  async updateBadge(userId: string): Promise<void> {
    const unreadCount = await this.getUnreadCount(userId);
    const connections = this.clients.get(userId);
    if (!connections) return;

    const payload = JSON.stringify({ type: 'badge', unreadCount });
    for (const client of connections) {
      if (client.ws.readyState === WebSocket.OPEN) {
        client.ws.send(payload);
      }
    }
  }

  private handleMessage(client: ConnectedClient, raw: string): void {
    try {
      const msg = JSON.parse(raw);
      switch (msg.type) {
        case 'mark_read':
          this.markAsRead(client.userId, msg.notificationId);
          break;
        case 'mark_all_read':
          this.markAllAsRead(client.userId);
          break;
        case 'archive':
          this.archiveNotification(client.userId, msg.notificationId);
          break;
      }
    } catch { /* ignore malformed messages */ }
  }

  private handleDisconnect(client: ConnectedClient): void {
    const connections = this.clients.get(client.userId);
    if (connections) {
      connections.delete(client);
      if (connections.size === 0) this.clients.delete(client.userId);
    }
  }

  private pingAll(): void {
    const staleThreshold = Date.now() - 60_000;
    for (const [userId, connections] of this.clients) {
      for (const client of connections) {
        if (client.lastPing.getTime() < staleThreshold) {
          client.ws.terminate();
          connections.delete(client);
        } else {
          client.ws.ping();
        }
      }
      if (connections.size === 0) this.clients.delete(userId);
    }
  }

  private async getUnreadCount(userId: string): Promise<number> {
    return db.notifications.count({
      where: { userId, readAt: null, archivedAt: null },
    });
  }

  private async markAsRead(userId: string, notificationId: string): Promise<void> {
    await db.notifications.update({
      where: { id: notificationId, userId },
      data: { readAt: new Date() },
    });
    await this.updateBadge(userId);
  }

  private async markAllAsRead(userId: string): Promise<void> {
    await db.notifications.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
    await this.updateBadge(userId);
  }

  private async archiveNotification(userId: string, notificationId: string): Promise<void> {
    await db.notifications.update({
      where: { id: notificationId, userId },
      data: { archivedAt: new Date() },
    });
  }
}
```

### Step 7: Notification Center REST API
API endpoints for the notification center UI:

```typescript
// Notification center API routes
import { Router } from 'express';

const router = Router();

// GET /api/notifications — Paginated notification feed
router.get('/notifications', auth, async (req, res) => {
  const { cursor, limit = 20, category, unreadOnly } = req.query;

  const where: any = { userId: req.user.id, archivedAt: null };
  if (category) where.category = category;
  if (unreadOnly === 'true') where.readAt = null;
  if (cursor) where.createdAt = { lt: new Date(cursor as string) };

  const notifications = await db.notifications.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    take: Number(limit) + 1,
  });

  const hasMore = notifications.length > Number(limit);
  if (hasMore) notifications.pop();

  res.json({
    notifications,
    cursor: notifications.length > 0
      ? notifications[notifications.length - 1].createdAt.toISOString()
      : null,
    hasMore,
  });
});

// GET /api/notifications/unread-count
router.get('/notifications/unread-count', auth, async (req, res) => {
  const count = await db.notifications.count({
    where: { userId: req.user.id, readAt: null, archivedAt: null },
  });
  res.json({ count });
});

// PATCH /api/notifications/:id/read
router.patch('/notifications/:id/read', auth, async (req, res) => {
  await db.notifications.update({
    where: { id: req.params.id, userId: req.user.id },
    data: { readAt: new Date() },
  });
  res.json({ success: true });
});

// POST /api/notifications/mark-all-read
router.post('/notifications/mark-all-read', auth, async (req, res) => {
  await db.notifications.updateMany({
    where: { userId: req.user.id, readAt: null },
    data: { readAt: new Date() },
  });
  res.json({ success: true });
});

// DELETE /api/notifications/:id — Archive notification
router.delete('/notifications/:id', auth, async (req, res) => {
  await db.notifications.update({
    where: { id: req.params.id, userId: req.user.id },
    data: { archivedAt: new Date() },
  });
  res.json({ success: true });
});

// GET /api/notifications/preferences
router.get('/notifications/preferences', auth, async (req, res) => {
  const prefs = await preferenceService.get(req.user.id);
  res.json(prefs);
});

// PUT /api/notifications/preferences
router.put('/notifications/preferences', auth, async (req, res) => {
  await preferenceService.update(req.user.id, req.body);
  res.json({ success: true });
});

// POST /api/notifications/unsubscribe — One-click unsubscribe
router.post('/notifications/unsubscribe', async (req, res) => {
  const { token } = req.body;
  await preferenceService.handleUnsubscribe(token);
  res.json({ success: true });
});
```

### Step 8: Batching and Digest Strategy
Aggregate low-priority notifications into periodic summaries:

```
DIGEST STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Digest Types:                                            │
│                                                           │
│  Immediate:                                               │
│    critical/high priority — always sent in real-time      │
│                                                           │
│  Hourly Digest:                                           │
│    Collapse similar notifications in the last hour:       │
│    "John and 4 others commented on your post"             │
│    "You have 12 new followers"                            │
│                                                           │
│  Daily Digest (default):                                  │
│    Summary email at user's preferred time:                │
│    - Social activity summary                              │
│    - Product updates                                      │
│    - Marketing content                                    │
│                                                           │
│  Weekly Digest:                                           │
│    Comprehensive weekly summary for low-engagement users  │
│                                                           │
│  Batching Rules:                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Trigger                     │ Action              │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  > 15 notifs/hour            │ Batch into digest   │  │
│  │  Same collapseKey within 5m  │ Merge/replace       │  │
│  │  User in quiet hours         │ Defer to end        │  │
│  │  Low priority + batchable    │ Add to next digest  │  │
│  │  Critical priority           │ Always immediate    │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Digest worker — runs on cron schedule
class DigestWorker {
  // Run every hour (for hourly digests) and at scheduled times (for daily/weekly)
  async processDigests(): Promise<void> {
    const usersWithPendingDigests = await db.digestQueue.findMany({
      where: { sentInDigest: false },
      select: { userId: true },
      distinct: ['userId'],
    });

    for (const { userId } of usersWithPendingDigests) {
      const prefs = await preferenceService.get(userId);

      // Check if it is time to send this user's digest
      if (!this.isDigestTime(prefs)) continue;

      const pendingItems = await db.digestQueue.findMany({
        where: { userId, sentInDigest: false },
        orderBy: { queuedAt: 'asc' },
      });

      if (pendingItems.length === 0) continue;

      // Group by type and collapse
      const grouped = this.groupAndCollapse(pendingItems);

      // Send digest email
      await emailProvider.send({
        to: userId,
        template: 'notification-digest',
        data: {
          groups: grouped,
          totalCount: pendingItems.length,
          period: prefs.digestFrequency,
        },
      });

      // Send digest as in-app notification
      await inAppProvider.send({
        userId,
        type: 'system.digest',
        title: `You have ${pendingItems.length} notifications`,
        body: this.formatDigestSummary(grouped),
      });

      // Mark as sent
      await db.digestQueue.updateMany({
        where: { id: { in: pendingItems.map(i => i.id) } },
        data: { sentInDigest: true, digestSentAt: new Date() },
      });
    }
  }

  private groupAndCollapse(items: DigestItem[]): DigestGroup[] {
    const groups = new Map<string, DigestItem[]>();
    for (const item of items) {
      const key = item.type;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(item);
    }

    return Array.from(groups.entries()).map(([type, items]) => ({
      type,
      typeName: NOTIFICATION_TYPES[type]?.name ?? type,
      count: items.length,
      items: items.slice(0, 5),       // Show up to 5 per group
      hasMore: items.length > 5,
    }));
  }

  private isDigestTime(prefs: NotificationPreferences): boolean {
    const userHour = getHourInTimezone(new Date(), prefs.timezone);
    const [digestHour] = prefs.digestTime.split(':').map(Number);

    switch (prefs.digestFrequency) {
      case 'hourly': return true;  // Always ready
      case 'daily':  return userHour === digestHour;
      case 'weekly': return userHour === digestHour && new Date().getDay() === 1;  // Monday
      default:       return false;
    }
  }

  private formatDigestSummary(groups: DigestGroup[]): string {
    return groups.map(g => `${g.count} ${g.typeName}`).join(', ');
  }
}
```

### Step 9: Template Management
Centralized notification templates across all channels:

```typescript
// Notification template system
interface NotificationTemplate {
  id: string;
  channels: {
    push?: { title: string; body: string; imageUrl?: string };
    sms?: { body: string };
    email?: { subject: string; templateId: string };
    in_app?: { title: string; body: string; actionUrl?: string; imageUrl?: string };
    slack?: { text: string; blocks?: SlackBlock[] };
  };
}

// Template with variable interpolation
const templates: Record<string, NotificationTemplate> = {
  'order-confirmed': {
    id: 'order-confirmed',
    channels: {
      push: {
        title: 'Order Confirmed!',
        body: 'Your order #{{orderId}} for {{totalFormatted}} has been confirmed.',
      },
      sms: {
        body: 'MyApp: Order #{{orderId}} confirmed — {{totalFormatted}}. Track at {{trackingUrl}}',
      },
      email: {
        subject: 'Order Confirmed — #{{orderId}}',
        templateId: 'order-confirmed',  // React Email or provider template
      },
      in_app: {
        title: 'Order Confirmed',
        body: 'Your order #{{orderId}} for {{totalFormatted}} is confirmed and being prepared.',
        actionUrl: '/orders/{{orderId}}',
        imageUrl: '{{firstItemImage}}',
      },
      slack: {
        text: 'New order #{{orderId}} — {{totalFormatted}} from {{customerName}}',
      },
    },
  },
  'login-alert': {
    id: 'login-alert',
    channels: {
      push: {
        title: 'New Login Detected',
        body: 'Login from {{deviceName}} in {{location}}. Was this you?',
      },
      sms: {
        body: 'MyApp security: New login from {{location}} on {{deviceName}}. Not you? Secure your account: {{secureUrl}}',
      },
      email: {
        subject: 'New login to your account',
        templateId: 'login-alert',
      },
      in_app: {
        title: 'New Login Detected',
        body: 'Someone signed in from {{deviceName}} in {{location}} at {{loginTime}}.',
        actionUrl: '/settings/security',
      },
    },
  },
};

function renderTemplate(
  template: string,
  data: Record<string, unknown>,
): string {
  return template.replace(/\{\{(\w+)\}\}/g, (_, key) => {
    return String(data[key] ?? '');
  });
}

// Render all channels for a notification type
function renderNotification(
  templateId: string,
  channel: Channel,
  data: Record<string, unknown>,
): Record<string, string> {
  const template = templates[templateId];
  if (!template) throw new Error(`Template not found: ${templateId}`);

  const channelTemplate = template.channels[channel];
  if (!channelTemplate) throw new Error(`No ${channel} template for ${templateId}`);

  const rendered: Record<string, string> = {};
  for (const [key, value] of Object.entries(channelTemplate)) {
    rendered[key] = typeof value === 'string' ? renderTemplate(value, data) : value;
  }
  return rendered;
}
```

### Step 10: Delivery Tracking and Analytics
Monitor notification health across all channels:

```
DELIVERY TRACKING DASHBOARD:
┌──────────────────────────────────────────────────────────┐
│  Channel Metrics (last 24h):                              │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Channel │ Sent    │ Delivered │ Rate   │ Failed   │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Push    │ 45,200  │ 43,100   │ 95.4%  │ 2,100    │  │
│  │  SMS     │ 1,200   │ 1,180    │ 98.3%  │ 20       │  │
│  │  Email   │ 12,500  │ 12,200   │ 97.6%  │ 300      │  │
│  │  In-App  │ 38,000  │ 38,000   │ 100%   │ 0        │  │
│  │  Webhook │ 5,400   │ 5,350    │ 99.1%  │ 50       │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Push Notification Metrics:                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Metric              │ Value   │ Target  │ Alert   │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Delivery rate       │ 95.4%   │ > 93%   │ < 90%  │  │
│  │  Tap rate            │ 8.2%    │ > 5%    │ < 3%   │  │
│  │  Opt-out rate        │ 0.3%    │ < 1%    │ > 2%   │  │
│  │  Stale tokens        │ 4.1%    │ < 5%    │ > 10%  │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  SMS Metrics:                                             │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Metric              │ Value   │ Target  │ Alert   │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Delivery rate       │ 98.3%   │ > 97%   │ < 95%  │  │
│  │  OTP success rate    │ 92.1%   │ > 90%   │ < 85%  │  │
│  │  Opt-out rate        │ 0.8%    │ < 1%    │ > 2%   │  │
│  │  Cost per message    │ $0.008  │ --      │ > $0.02│  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Alert Conditions:                                        │
│  - Push delivery < 90%: Check FCM/APNs status + tokens   │
│  - SMS delivery < 95%: Check Twilio account + compliance  │
│  - Opt-out spike > 2%: Review notification frequency      │
│  - Stale tokens > 10%: Run token cleanup job              │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Delivery status webhook handlers
async function handleTwilioStatusCallback(req: Request): Promise<void> {
  const { MessageSid, MessageStatus, ErrorCode } = req.body;

  await db.notificationDeliveries.update({
    where: { providerId: MessageSid },
    data: {
      status: mapTwilioStatus(MessageStatus),
      errorMessage: ErrorCode ? `Twilio error: ${ErrorCode}` : null,
      deliveredAt: MessageStatus === 'delivered' ? new Date() : undefined,
      failedAt: ['failed', 'undelivered'].includes(MessageStatus) ? new Date() : undefined,
      updatedAt: new Date(),
    },
  });

  // Handle permanent failures
  if (MessageStatus === 'undelivered' && isPhoneInvalid(ErrorCode)) {
    await db.phoneNumbers.update({
      where: { phone: req.body.To },
      data: { status: 'invalid', invalidAt: new Date() },
    });
  }
}

function mapTwilioStatus(status: string): string {
  const map: Record<string, string> = {
    queued: 'queued', sent: 'sent', delivered: 'delivered',
    failed: 'failed', undelivered: 'failed',
  };
  return map[status] ?? 'pending';
}

// FCM delivery receipt processing
async function processFCMDeliveryReceipts(): Promise<void> {
  // FCM does not provide delivery receipts by default
  // Use Firebase Analytics or implement read receipts in-app
  // For accurate delivery tracking, use OneSignal which provides delivery stats
}
```

### Step 11: Commit and Report
```
1. Save notification system files:
   - Notification service: src/services/notifications/service.ts
   - Push provider: src/services/notifications/channels/push.ts
   - SMS provider: src/services/notifications/channels/sms.ts
   - In-app gateway: src/services/notifications/channels/in-app.ts
   - Webhook provider: src/services/notifications/channels/webhook.ts
   - Preferences: src/services/notifications/preferences.ts
   - Digest worker: src/services/notifications/digest.ts
   - Templates: src/services/notifications/templates.ts
   - Notification center API: src/api/routes/notifications.ts
   - WebSocket gateway: src/api/ws/notifications.ts
   - Database migration: src/db/migrations/xxx_create_notifications.sql
   - Status webhooks: src/api/webhooks/twilio.ts
2. Commit: "notify: <description> — <components implemented>"
3. If push only: "notify: push notifications — FCM + APNs with token management"
4. If full system: "notify: multi-channel system — push, SMS, in-app, webhooks, preference center"
```

## Key Behaviors

1. **Route through a central notification service.** Never send push/SMS/email directly from business logic. Every notification goes through the notification service which handles preferences, quiet hours, rate limiting, and delivery tracking.
2. **Respect user preferences absolutely.** Every non-security notification must check user preferences before sending. Required channels (security alerts) are the only exception. Violating user preferences destroys trust and increases opt-outs.
3. **Clean up stale push tokens aggressively.** Invalid FCM/APNs tokens waste quota and skew metrics. Remove tokens immediately on InvalidRegistration errors. Run periodic cleanup for tokens unused in 30+ days.
4. **Implement quiet hours with timezone awareness.** Store user timezone. Check quiet hours before every non-critical send. Defer notifications to the end of the quiet window. In-app notifications are always allowed during quiet hours.
5. **Use separate queues per channel.** Push, SMS, email, and webhook deliveries should be independent queues. A Twilio outage must not block push notification delivery. Process and retry each channel independently.
6. **Collapse duplicate notifications.** Use collapseKey to group similar notifications (e.g., "5 people liked your post" instead of 5 separate notifications). Set TTL so stale notifications expire rather than arriving late.
7. **Batch aggressively for low-priority notifications.** Social and marketing notifications should batch into digests when volume is high. Nobody wants 50 individual "new follower" push notifications.
8. **Track delivery end-to-end.** Record every notification attempt, status update, and failure. Monitor delivery rates per channel per provider. Alert when rates degrade.
9. **Use idempotency keys for every notification.** Prevent duplicate sends from retries, race conditions, or event replays. Check idempotency key before processing.
10. **Comply with SMS regulations.** TCPA requires prior express consent for marketing SMS. Always provide opt-out instructions. Use 10DLC or short codes for A2P messaging. Never send SMS marketing without explicit consent.

## Example Usage

### Setting up push notifications
```
User: /godmode:notify Set up push notifications for our mobile app

Notify: Analyzing push notification requirements...

Platform: iOS + Android (React Native)
Provider: Firebase Cloud Messaging (cross-platform)
Features: Rich notifications, badge count, deep linking

Implementation:
  1. FCM project setup + service account credentials
  2. Device token registration and management
  3. Push notification service with multicast support
  4. Stale token cleanup worker
  5. Notification channel configuration (Android)
  6. Rich notification support (images, actions)

Files created:
  src/services/notifications/channels/push.ts — FCM integration
  src/services/notifications/tokens.ts — Device token management
  src/workers/cleanup-stale-tokens.ts — Token cleanup cron
  src/api/routes/device-tokens.ts — Token registration API

Next: Set up notification preferences and in-app notification center
```

### Building a complete notification system
```
User: /godmode:notify Build a full notification system with push, SMS, email, and in-app

Notify: Designing multi-channel notification architecture...

Channels:
  Push: Firebase Cloud Messaging (iOS + Android + Web)
  SMS: Twilio (OTP + critical alerts)
  Email: Resend (transactional) + SendGrid (marketing)
  In-App: WebSocket (real-time) + REST (notification center)
  Webhook: Slack integration for team notifications

Architecture:
  Event trigger -> Notification service
    -> Preference check + quiet hours
    -> Channel router
    -> Per-channel queues (BullMQ)
    -> Provider delivery
    -> Delivery tracking

Notification types: 14 types across 5 channels
Preference center: Per-type, per-channel opt-in/opt-out
Rate limiting: Max 15 notifications/hour (non-critical)
Quiet hours: Timezone-aware, configurable per user
Digest: Hourly/daily/weekly batching for low-priority
Templates: Centralized with per-channel rendering

Files created:
  src/services/notifications/service.ts — Core notification service
  src/services/notifications/channels/ — Channel implementations (4 files)
  src/services/notifications/preferences.ts — User preferences
  src/services/notifications/templates.ts — Template management
  src/services/notifications/digest.ts — Digest batching worker
  src/api/routes/notifications.ts — Notification center API
  src/api/ws/notifications.ts — WebSocket real-time gateway
  src/db/migrations/xxx_create_notifications.sql — Database schema

Estimated monthly cost (10K users):
  FCM: Free
  Twilio (500 SMS): $4
  Resend (5K emails): $20
  SendGrid (marketing): Free tier
  Total: ~$24/month
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full multi-channel notification system design and implementation |
| `--push` | Push notification setup only (FCM, APNs, OneSignal) |
| `--sms` | SMS notification setup only (Twilio, OTP) |
| `--inapp` | In-app notification center only (WebSocket + REST) |
| `--webhook` | Webhook/Slack notification integration only |
| `--preferences` | Notification preference center design only |
| `--digest` | Notification batching and digest system only |
| `--templates` | Notification template management only |
| `--tracking` | Delivery tracking and analytics only |
| `--provider <name>` | Use specific provider (fcm, onesignal, twilio, sns) |
| `--quiet-hours` | Quiet hours implementation only |
| `--schema` | Database schema for notification center only |

## HARD RULES

1. NEVER send notifications without checking user preferences first. Ignoring opt-outs violates trust and may violate CAN-SPAM, TCPA, or GDPR consent requirements.
2. NEVER send SMS without explicit opt-in consent. TCPA fines are $500-$1,500 per message. Marketing SMS requires prior express written consent.
3. NEVER hardcode provider credentials or API keys. Use environment variables or a secrets manager. Rotate keys on a schedule.
4. ALWAYS implement idempotency keys for every notification dispatch. Duplicate sends erode user trust faster than missing sends.
5. ALWAYS enforce rate limits per user per channel. A bug in a loop can send 10,000 emails in seconds. Cap hourly sends and alert on anomalies.
6. NEVER send push notifications without handling stale tokens. Check provider error codes (FCM: `messaging/registration-token-not-registered`, APNs: HTTP 410) and remove invalid tokens immediately.
7. ALWAYS queue notifications asynchronously. Synchronous sends block the request path. Use a job queue (BullMQ, SQS, Pub/Sub) with retry and dead-letter handling.
8. NEVER serve notification content without sanitizing user-generated data. Templates that interpolate user input are XSS vectors in email and web push payloads.

## Auto-Detection

Before implementing, detect existing notification infrastructure:

```bash
# Detect existing notification providers
echo "=== Notification Providers ==="
grep -r "sendgrid\|ses\.\|nodemailer\|postmark\|mailgun" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
grep -r "twilio\|vonage\|nexmo\|plivo" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
grep -r "firebase.*messaging\|onesignal\|web-push\|fcm" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5

# Detect notification service patterns
echo "=== Notification Service ==="
grep -r "NotificationService\|notification_service\|notify(" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5

# Detect preference storage
echo "=== User Preferences ==="
grep -r "notification.*pref\|channel.*pref\|opt.out\|unsubscribe" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5

# Detect queue infrastructure
echo "=== Queue Infrastructure ==="
grep -r "bullmq\|bull\|sqs\|pub.sub\|rabbitmq\|celery" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5

# Detect templates
echo "=== Templates ==="
find . -path "*/templates/*" -name "*.html" -o -name "*.hbs" -o -name "*.mjml" 2>/dev/null | head -5
find . -path "*/notifications/*" -name "*.ts" -o -name "*.js" 2>/dev/null | head -5
```

## Anti-Patterns

- **Do NOT send notifications directly from business logic.** Always go through the notification service. Direct sends bypass preferences, quiet hours, rate limiting, and tracking. The notification service is the single source of truth.
- **Do NOT ignore stale push tokens.** Invalid tokens accumulate fast. FCM and APNs return specific error codes for invalid tokens. Handle them immediately. Stale tokens waste resources and skew delivery metrics.
- **Do NOT send SMS without opt-in consent.** TCPA violations carry fines of $500-$1,500 per message. Marketing SMS requires prior express written consent. Even transactional SMS needs prior express consent.
- **Do NOT treat all notifications as equal priority.** Security alerts must always be delivered immediately. Marketing can be batched. Without priority levels, users get notification fatigue and disable everything.
- **Do NOT skip idempotency checks.** Event systems can replay. Queues can retry. Without idempotency keys, users receive duplicate notifications — the fastest way to lose trust.
- **Do NOT batch security notifications.** Login alerts, 2FA codes, and password reset notifications must be immediate. Never put security notifications in a digest queue. They are time-sensitive and safety-critical.
- **Do NOT ignore timezone in quiet hours.** A quiet-hours check that uses server time instead of user timezone is worse than no quiet hours at all. Always store and use the user's timezone.
- **Do NOT use a single queue for all channels.** If your SMS provider has an outage, it must not block push notifications. Use separate queues per channel with independent retry logic and circuit breakers.
