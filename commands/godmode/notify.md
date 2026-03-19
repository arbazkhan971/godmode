# /godmode:notify

Build multi-channel notification systems with push, SMS, email, in-app, and webhook delivery. Integrates FCM, APNs, Twilio, OneSignal, and WebSocket for real-time notifications with user preference management, quiet hours, digest batching, and delivery tracking.

## Usage

```
/godmode:notify                          # Full multi-channel notification system
/godmode:notify --push                   # Push notification setup (FCM, APNs, OneSignal)
/godmode:notify --sms                    # SMS notification setup (Twilio, OTP)
/godmode:notify --inapp                  # In-app notification center (WebSocket + REST)
/godmode:notify --webhook                # Webhook/Slack notification integration
/godmode:notify --preferences            # Notification preference center
/godmode:notify --digest                 # Notification batching and digest system
/godmode:notify --templates              # Notification template management
/godmode:notify --tracking               # Delivery tracking and analytics
/godmode:notify --provider fcm           # Use specific provider (fcm, onesignal, twilio, sns)
/godmode:notify --quiet-hours            # Quiet hours implementation
/godmode:notify --schema                 # Database schema for notification center
```

## What It Does

1. Discovers notification requirements (channels, event types, volume, compliance)
2. Selects and integrates providers (FCM, APNs, Twilio, OneSignal, SendGrid)
3. Architects multi-channel routing (push, SMS, email, in-app, Slack/webhook)
4. Builds notification preference center with per-type, per-channel controls
5. Implements quiet hours with timezone awareness
6. Designs batching and digest strategies for low-priority notifications
7. Creates notification center database schema with delivery tracking
8. Sets up real-time in-app notifications via WebSocket
9. Implements template management across all channels
10. Configures delivery tracking, analytics, and alerting

## Output
- Multi-channel notification service with routing and preference checks
- Push notification integration (FCM/APNs) with token management
- SMS integration (Twilio) with OTP and compliance handling
- Real-time in-app notification center (WebSocket + REST API)
- User preference center with quiet hours and digest settings
- Database schema for notifications, deliveries, preferences, and device tokens
- Delivery tracking with per-channel metrics and alerting
- Commit: `"notify: <description> — <components implemented>"`

## Next Step
After notification setup: `/godmode:test` to test notification delivery across channels, or `/godmode:queue` to configure the notification queue workers and retry logic.

## Examples

```
/godmode:notify --push --provider fcm    # FCM push notifications for mobile app
/godmode:notify --sms --provider twilio  # Twilio SMS with OTP verification
/godmode:notify --inapp --preferences    # In-app notifications with preference center
/godmode:notify                          # Full multi-channel notification system
```
