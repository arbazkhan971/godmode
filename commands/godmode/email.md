# /godmode:email

Build email delivery and multi-channel notification systems. Integrates email providers, designs responsive templates, architects notification routing across email, push, SMS, and in-app channels with deliverability monitoring and bounce handling.

## Usage

```
/godmode:email                          # Full notification system design
/godmode:email --email                  # Email service integration only
/godmode:email --templates              # Email template design and generation
/godmode:email --push                   # Push notification setup
/godmode:email --sms                    # SMS notification setup
/godmode:email --inapp                  # In-app notification system
/godmode:email --deliverability         # Email deliverability audit and fixes
/godmode:email --provider resend        # Use specific provider (sendgrid, ses, postmark, resend)
/godmode:email --dns                    # Email DNS authentication (SPF, DKIM, DMARC)
/godmode:email --preferences            # Notification preference center
/godmode:email --digest                 # Notification digest and batching
```

## What It Does

1. Discovers notification requirements (channels, types, volume, compliance)
2. Integrates email service (SendGrid, SES, Postmark, Resend) with domain verification
3. Designs responsive email templates (React Email or MJML) for all transactional emails
4. Architects multi-channel notification system (email, push, SMS, in-app)
5. Implements delivery tracking, bounce handling, and suppression lists
6. Configures email DNS authentication (SPF, DKIM, DMARC)
7. Separates transactional and marketing email streams
8. Builds notification preference center for user control

## Output
- Email service integration with provider setup
- Email templates for all transactional emails
- Multi-channel notification service with routing
- Bounce and complaint handler with suppression list
- DNS records for email authentication
- Deliverability metrics dashboard configuration
- Commit: `"email: <description> — <components implemented>"`

## Next Step
After email setup: `/godmode:test` to test email delivery and template rendering, or `/godmode:network` to configure DNS records for email authentication.

## Examples

```
/godmode:email --provider resend --templates    # Resend + React Email templates
/godmode:email --deliverability                 # Fix deliverability issues
/godmode:email --dns                            # Set up SPF, DKIM, DMARC
/godmode:email                                  # Full multi-channel notification system
```
