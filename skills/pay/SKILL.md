---
name: pay
description: |
  Payment and billing integration skill. Activates when user needs to implement payment processing, subscription billing, invoicing, or tax calculation. Covers payment gateway integration (Stripe, PayPal, Braintree), subscription and recurring billing design, invoice generation, tax calculation (VAT, sales tax), PCI-DSS compliance, and webhook handling for payment events. Triggers on: /godmode:pay, "integrate Stripe", "subscription billing", "payment processing", "invoice system", "PCI compliance", "tax calculation", or when building e-commerce or SaaS billing features.
---

# Pay — Payment & Billing Integration

## When to Activate
- User invokes `/godmode:pay`
- User says "integrate Stripe", "payment processing", "accept payments"
- User says "subscription billing", "recurring charges", "metered billing"
- User says "generate invoices", "tax calculation", "VAT handling"
- User says "PCI compliance", "payment security", "tokenize cards"
- User says "payment webhooks", "charge failed", "subscription canceled"
- Building e-commerce checkout, SaaS billing, or marketplace payments

## Workflow

### Step 1: Payment Requirements Discovery
Identify the billing model and compliance requirements:

```
PAYMENT REQUIREMENTS:
┌──────────────────────────────────────────────────────────┐
│  Business Model:                                          │
│    Type: <one-time | subscription | metered | marketplace>│
│    Currency: <primary currency, multi-currency?>          │
│    Price range: <min to max transaction>                   │
│    Volume: <transactions/month>                           │
│                                                           │
│  Payment Methods:                                         │
│    Credit/Debit cards: <Visa, MC, Amex>                   │
│    Digital wallets: <Apple Pay, Google Pay>                │
│    Bank transfers: <ACH, SEPA, wire>                      │
│    Buy-now-pay-later: <Klarna, Affirm, Afterpay>          │
│    Regional: <iDEAL, Bancontact, PIX, UPI>                │
│                                                           │
│  Subscription Details (if applicable):                    │
│    Plans: <list of plan names and prices>                  │
│    Billing cycle: <monthly | annual | both>                │
│    Trial period: <N days>                                  │
│    Proration: <on upgrade/downgrade>                       │
│    Metered components: <usage-based items>                 │
│                                                           │
│  Tax Requirements:                                        │
│    US sales tax: <states with nexus>                       │
│    EU VAT: <B2C reverse charge, MOSS/OSS>                  │
│    Tax-exempt customers: <supported?>                      │
│    Tax IDs: <collection required?>                         │
│                                                           │
│  Compliance:                                              │
│    PCI-DSS level: <1 | 2 | 3 | 4>                         │
│    Data residency: <regions>                               │
│    Refund policy: <full | partial | time-limited>          │
│    Dispute handling: <process>                             │
└──────────────────────────────────────────────────────────┘
```

### Step 2: Payment Gateway Integration
Set up the payment processor:

#### Stripe Integration (Recommended)
```typescript
// Server-side: Create payment intent
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-12-18.acacia',
  typescript: true,
});

// One-time payment
async function createPaymentIntent(
  amount: number,          // Amount in smallest currency unit (cents)
  currency: string,
  customerId: string,
  metadata: Record<string, string>,
): Promise<Stripe.PaymentIntent> {
  return stripe.paymentIntents.create({
    amount,
    currency,
    customer: customerId,
    automatic_payment_methods: { enabled: true },
    metadata: {
      ...metadata,
      internal_order_id: metadata.orderId,
    },
    idempotency_key: `pi_${metadata.orderId}`,  // Prevent duplicate charges
  });
}

// Client-side: Confirm payment
// Uses Stripe.js Elements for PCI-compliant card collection
// Card numbers NEVER touch your server
```

```
PAYMENT FLOW (Stripe):
┌────────┐     ┌──────────┐     ┌──────────┐
│ Client │     │ Server   │     │ Stripe   │
└───┬────┘     └────┬─────┘     └────┬─────┘
    │               │                │
    │ 1. Checkout   │                │
    │   initiated   │                │
    ├──────────────>│                │
    │               │                │
    │               │ 2. Create      │
    │               │  PaymentIntent │
    │               ├───────────────>│
    │               │                │
    │               │ 3. Return      │
    │               │  client_secret │
    │               │<───────────────┤
    │               │                │
    │ 4. Return     │                │
    │  client_secret│                │
    │<──────────────┤                │
    │               │                │
    │ 5. Collect card│               │
    │  via Elements  │               │
    │  (PCI-safe)    │               │
    │               │                │
    │ 6. Confirm     │               │
    │  payment       │               │
    ├────────────────────────────────>
    │               │                │
    │               │ 7. Webhook:    │
    │               │  payment_intent│
    │               │  .succeeded    │
    │               │<───────────────┤
    │               │                │
    │               │ 8. Fulfill     │
    │               │  order         │
    │               │                │
    │ 9. Confirmation                │
    │<──────────────┤                │
    └───────────────┘                │
```

#### PayPal Integration
```
PAYPAL INTEGRATION:
┌──────────────────────────────────────────────────────────┐
│  Mode: Server-side (Orders API v2)                        │
│                                                           │
│  1. Create Order                                          │
│     POST /v2/checkout/orders                              │
│     -> Returns order ID                                   │
│                                                           │
│  2. Client approves via PayPal JS SDK                     │
│     paypal.Buttons({ createOrder, onApprove })            │
│     -> User authorizes in PayPal popup                    │
│                                                           │
│  3. Capture Payment                                       │
│     POST /v2/checkout/orders/{id}/capture                 │
│     -> Returns capture details                            │
│                                                           │
│  Webhook events:                                          │
│     PAYMENT.CAPTURE.COMPLETED                             │
│     PAYMENT.CAPTURE.DENIED                                │
│     PAYMENT.CAPTURE.REFUNDED                              │
│                                                           │
│  Important:                                               │
│  - Always capture server-side (never trust client)        │
│  - Verify webhook signatures                              │
│  - Handle pending payments (e-check can take days)        │
└──────────────────────────────────────────────────────────┘
```

### Step 3: Subscription Billing Design
Implement recurring billing with plan management:

```
SUBSCRIPTION ARCHITECTURE:
┌──────────────────────────────────────────────────────────┐
│  Plans:                                                   │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Plan      │ Monthly │ Annual   │ Features          │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Free      │ $0      │ $0       │ 1 user, 1 GB     │  │
│  │  Starter   │ $19     │ $190     │ 5 users, 10 GB   │  │
│  │  Pro       │ $49     │ $490     │ 25 users, 100 GB │  │
│  │  Enterprise│ Custom  │ Custom   │ Unlimited         │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Billing Events:                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Event                │ Action                      │  │
│  │  ────────────────────────────────────────────────  │  │
│  │  Subscription created │ Provision features           │  │
│  │  Payment succeeded    │ Extend access, send receipt  │  │
│  │  Payment failed       │ Retry (3x), notify customer  │  │
│  │  Subscription updated │ Prorate, adjust features     │  │
│  │  Trial ending         │ Notify 3 days before         │  │
│  │  Subscription canceled│ Access until period end       │  │
│  │  Subscription expired │ Downgrade to free tier       │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Dunning (Failed Payment Recovery):                       │
│  Day 0: Payment fails -> Retry immediately                │
│  Day 3: Second retry -> Email: "Update payment method"    │
│  Day 7: Third retry -> Email: "Account at risk"           │
│  Day 14: Final notice -> Email: "Last chance"             │
│  Day 21: Subscription canceled -> Downgrade to free       │
└──────────────────────────────────────────────────────────┘
```

```typescript
// Stripe subscription management
async function createSubscription(
  customerId: string,
  priceId: string,
  options: {
    trialDays?: number;
    couponId?: string;
    metadata?: Record<string, string>;
  },
): Promise<Stripe.Subscription> {
  const params: Stripe.SubscriptionCreateParams = {
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: 'default_incomplete',
    payment_settings: {
      save_default_payment_method: 'on_subscription',
    },
    expand: ['latest_invoice.payment_intent'],
    metadata: options.metadata,
  };

  if (options.trialDays) {
    params.trial_period_days = options.trialDays;
  }
  if (options.couponId) {
    params.coupon = options.couponId;
  }

  return stripe.subscriptions.create(params);
}

// Plan change with proration
async function changeSubscriptionPlan(
  subscriptionId: string,
  newPriceId: string,
): Promise<Stripe.Subscription> {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId);

  return stripe.subscriptions.update(subscriptionId, {
    items: [{
      id: subscription.items.data[0].id,
      price: newPriceId,
    }],
    proration_behavior: 'always_invoice',  // Charge/credit immediately
  });
}

// Metered usage reporting
async function reportUsage(
  subscriptionItemId: string,
  quantity: number,
  timestamp: number,
): Promise<Stripe.UsageRecord> {
  return stripe.subscriptionItems.createUsageRecord(
    subscriptionItemId,
    {
      quantity,
      timestamp,
      action: 'increment',  // Add to current period total
    },
    { idempotencyKey: `usage_${subscriptionItemId}_${timestamp}` },
  );
}
```

### Step 4: Invoice Generation
Design the invoicing system:

```
INVOICE SYSTEM:
┌──────────────────────────────────────────────────────────┐
│  Invoice Lifecycle:                                       │
│  DRAFT -> OPEN -> PAID | VOID | UNCOLLECTIBLE            │
│                                                           │
│  Invoice Contents:                                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │  INVOICE #INV-2026-001234                           │  │
│  │                                                      │  │
│  │  From: <company name, address, tax ID>               │  │
│  │  To: <customer name, address, tax ID>                │  │
│  │  Date: <issue date>                                  │  │
│  │  Due: <due date>                                     │  │
│  │                                                      │  │
│  │  Line Items:                                         │  │
│  │  Description          │ Qty │ Unit Price │ Amount    │  │
│  │  ──────────────────────────────────────────────────  │  │
│  │  Pro Plan (Mar 2026)  │ 1   │ $49.00     │ $49.00   │  │
│  │  Extra storage (50GB) │ 50  │ $0.10      │ $5.00    │  │
│  │  API calls (overage)  │ 12K │ $0.001     │ $12.00   │  │
│  │                                                      │  │
│  │  Subtotal:                           $66.00          │  │
│  │  Tax (VAT 20%):                      $13.20          │  │
│  │  Discount (annual -17%):            -$11.22          │  │
│  │  Total:                              $67.98          │  │
│  │                                                      │  │
│  │  Payment: Visa ending 4242                           │  │
│  │  Status: PAID on 2026-03-01                          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Storage:                                                 │
│  - Invoice data in database (structured)                  │
│  - PDF generated on demand or at finalization             │
│  - Stored in S3 for permanent record                      │
│  - Accessible via customer portal                         │
│                                                           │
│  Numbering:                                               │
│  Format: INV-{YYYY}-{sequential 6-digit}                  │
│  Sequential, never reused, no gaps (audit requirement)    │
│  Region prefix for multi-entity: US-INV, EU-INV           │
└──────────────────────────────────────────────────────────┘
```

### Step 5: Tax Calculation
Handle sales tax and VAT:

```
TAX CALCULATION:
┌──────────────────────────────────────────────────────────┐
│  US Sales Tax:                                            │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Nexus states: <list of states where you have nexus>│  │
│  │  Tax provider: Stripe Tax | TaxJar | Avalara        │  │
│  │                                                      │  │
│  │  Rules:                                              │  │
│  │  - Physical nexus: office, employees, warehouse      │  │
│  │  - Economic nexus: $100K revenue or 200 transactions │  │
│  │    in a state                                        │  │
│  │  - SaaS taxability varies by state                   │  │
│  │  - Some states exempt digital goods                  │  │
│  │  - Tax-exempt customers: require W-9 or exemption    │  │
│  │    certificate                                       │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  EU VAT:                                                  │
│  ┌────────────────────────────────────────────────────┐  │
│  │  B2C (business to consumer):                         │  │
│  │  - Charge VAT at customer's country rate             │  │
│  │  - Use OSS (One Stop Shop) for EU-wide filing        │  │
│  │  - Rates: 17-27% depending on country                │  │
│  │                                                      │  │
│  │  B2B (business to business):                         │  │
│  │  - Collect and validate VAT ID (VIES check)          │  │
│  │  - Reverse charge: 0% VAT, customer self-assesses    │  │
│  │  - Invoice must state "Reverse charge applies"       │  │
│  │                                                      │  │
│  │  Digital services:                                   │  │
│  │  - Always taxable in EU                              │  │
│  │  - Customer location determines rate                 │  │
│  │  - Two pieces of evidence for location (IP, billing) │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Implementation:                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │  // Stripe Tax (recommended for Stripe users)        │  │
│  │  const session = await stripe.checkout.sessions      │  │
│  │    .create({                                         │  │
│  │      automatic_tax: { enabled: true },               │  │
│  │      customer_update: {                              │  │
│  │        address: 'auto',                              │  │
│  │      },                                              │  │
│  │      // ... other params                             │  │
│  │    });                                               │  │
│  │                                                      │  │
│  │  // Tax ID collection                                │  │
│  │  await stripe.customers.createTaxId(customerId, {    │  │
│  │    type: 'eu_vat',                                   │  │
│  │    value: 'DE123456789',                             │  │
│  │  });                                                 │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### Step 6: PCI-DSS Compliance
Ensure payment handling meets security standards:

```
PCI-DSS COMPLIANCE:
┌──────────────────────────────────────────────────────────┐
│  Level: SAQ-A (recommended — card data never touches      │
│         your server)                                      │
│                                                           │
│  Architecture (SAQ-A Eligible):                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Client (browser)                                    │  │
│  │    │                                                 │  │
│  │    ├── Stripe.js / Elements (card input iframe)      │  │
│  │    │     Card data goes directly to Stripe           │  │
│  │    │     Your server NEVER sees card numbers          │  │
│  │    │                                                 │  │
│  │    ├── Your Server                                   │  │
│  │    │     Receives: token / PaymentMethod ID           │  │
│  │    │     Receives: PaymentIntent client_secret        │  │
│  │    │     NEVER receives: card number, CVC, expiry    │  │
│  │    │                                                 │  │
│  │    └── Stripe API                                    │  │
│  │          Handles: card storage, tokenization          │  │
│  │          Handles: 3D Secure authentication            │  │
│  │          Handles: PCI-compliant vault                 │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Security Checklist:                                      │
│  [x] Card data collected via Stripe.js iframe (never      │
│      touches your DOM)                                    │
│  [x] API keys stored in secrets manager (not in code)     │
│  [x] Webhook signatures verified on every event           │
│  [x] HTTPS on all pages (not just checkout)               │
│  [x] Stripe secret key restricted to server-side only     │
│  [x] Publishable key restricted by domain                 │
│  [x] No card data in logs, error messages, or analytics   │
│  [x] Idempotency keys on all write operations             │
│  [x] 3D Secure enabled for SCA compliance (EU)            │
│  [x] Customer portal for self-service card updates        │
│                                                           │
│  What NOT to do:                                          │
│  [!] NEVER log request bodies on payment endpoints        │
│  [!] NEVER store raw card numbers anywhere                │
│  [!] NEVER transmit card data to your server              │
│  [!] NEVER disable Stripe.js CSP requirements             │
│  [!] NEVER use test API keys in production                │
└──────────────────────────────────────────────────────────┘
```

### Step 7: Webhook Handling
Process payment events reliably:

```typescript
// Webhook handler with signature verification
import { Request, Response } from 'express';

async function handleStripeWebhook(req: Request, res: Response) {
  const sig = req.headers['stripe-signature'] as string;
  let event: Stripe.Event;

  // CRITICAL: Verify webhook signature before processing
  try {
    event = stripe.webhooks.constructEvent(
      req.body,                          // Raw body (not parsed JSON)
      sig,
      process.env.STRIPE_WEBHOOK_SECRET,
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send('Invalid signature');
  }

  // Idempotency: check if we already processed this event
  const processed = await db.webhookEvents.findByEventId(event.id);
  if (processed) {
    return res.status(200).json({ received: true, duplicate: true });
  }

  // Process event in a transaction
  try {
    await db.transaction(async (tx) => {
      // Record the event before processing
      await tx.webhookEvents.create({
        eventId: event.id,
        type: event.type,
        data: event.data,
        processedAt: new Date(),
      });

      switch (event.type) {
        case 'payment_intent.succeeded':
          await handlePaymentSucceeded(tx, event.data.object);
          break;
        case 'payment_intent.payment_failed':
          await handlePaymentFailed(tx, event.data.object);
          break;
        case 'customer.subscription.created':
          await handleSubscriptionCreated(tx, event.data.object);
          break;
        case 'customer.subscription.updated':
          await handleSubscriptionUpdated(tx, event.data.object);
          break;
        case 'customer.subscription.deleted':
          await handleSubscriptionCanceled(tx, event.data.object);
          break;
        case 'invoice.payment_succeeded':
          await handleInvoicePaid(tx, event.data.object);
          break;
        case 'invoice.payment_failed':
          await handleInvoicePaymentFailed(tx, event.data.object);
          break;
        case 'customer.tax_id.created':
          await handleTaxIdCreated(tx, event.data.object);
          break;
        case 'charge.dispute.created':
          await handleDisputeCreated(tx, event.data.object);
          break;
        default:
          console.log(`Unhandled event type: ${event.type}`);
      }
    });

    res.status(200).json({ received: true });
  } catch (err) {
    console.error(`Error processing webhook ${event.id}:`, err);
    // Return 500 so Stripe retries the webhook
    res.status(500).json({ error: 'Processing failed' });
  }
}
```

```
WEBHOOK RELIABILITY:
┌──────────────────────────────────────────────────────────┐
│  Stripe Webhook Retry Schedule:                           │
│  Attempt 1: Immediate                                     │
│  Attempt 2: 1 hour                                        │
│  Attempt 3: 2 hours                                       │
│  Attempt 4: 4 hours                                       │
│  Attempt 5: 8 hours                                       │
│  ... up to 3 days, then disabled                          │
│                                                           │
│  Your Responsibilities:                                   │
│  1. Return 200 within 30 seconds (process async if slow)  │
│  2. Handle duplicate events (idempotency)                 │
│  3. Handle out-of-order events (check timestamps)         │
│  4. Store raw events for debugging and replay             │
│  5. Alert on consistent failures (> 3 retries)            │
│  6. Reconcile daily: compare Stripe records with your DB  │
│                                                           │
│  Event Processing Pattern:                                │
│  1. Verify signature                                      │
│  2. Check idempotency (skip if already processed)         │
│  3. Process in database transaction                       │
│  4. Return 200 (even if business logic fails — log error) │
│  5. Heavy work goes to async queue (email, PDF gen, etc.) │
└──────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Report
```
1. Save payment integration files:
   - Payment service: `src/services/payment/` or `src/lib/billing/`
   - Webhook handler: `src/api/webhooks/stripe.ts`
   - Subscription logic: `src/services/subscription/`
   - Invoice templates: `src/templates/invoice/`
   - Tax configuration: `src/config/tax.ts`
2. Commit: "pay: <description> — <components implemented>"
3. If Stripe integration: "pay: Stripe integration — checkout, subscriptions, webhooks"
4. If tax setup: "pay: tax calculation — US sales tax + EU VAT via Stripe Tax"
```

## Key Behaviors

1. **Card data never touches your server.** Use Stripe.js Elements, PayPal JS SDK, or equivalent client-side tokenization. This keeps you at PCI SAQ-A level, the simplest compliance tier.
2. **Webhooks are the source of truth.** Never rely on client-side confirmation for payment success. The webhook tells you definitively whether money moved. Fulfill orders from webhooks, not from redirect callbacks.
3. **Idempotency on every write.** Payment APIs must handle retries safely. Use idempotency keys on all Stripe API calls. Check for duplicate webhook events before processing.
4. **Test with real scenarios.** Use Stripe test mode with specific card numbers to simulate declines, 3D Secure, disputes, and failures. Test the unhappy paths, not just the happy path.
5. **Handle failed payments gracefully.** Implement dunning with escalating notifications. Give customers time and easy ways to update their payment method before canceling.
6. **Tax is not optional.** If you sell to customers in taxable jurisdictions, you must collect and remit tax. Use Stripe Tax, TaxJar, or Avalara — do not try to calculate tax yourself.
7. **Reconcile daily.** Compare your database records with the payment provider's records daily. Discrepancies indicate bugs, missed webhooks, or fraud.
8. **Log payment events, not payment data.** Log event IDs, amounts, and outcomes. Never log card numbers, CVCs, or full bank account numbers.

## Example Usage

### Setting up Stripe for a SaaS product
```
User: /godmode:pay Set up Stripe billing for our SaaS with monthly/annual plans

Pay: Analyzing requirements...

Product: SaaS application
Plans: Free, Starter ($19/mo), Pro ($49/mo), Enterprise (custom)
Annual discount: ~17% (2 months free)
Trial: 14 days on Starter and Pro

Implementation plan:
  1. Stripe Products & Prices (4 products, 6 prices)
  2. Customer creation with billing address
  3. Checkout Session for new subscriptions
  4. Customer portal for self-service management
  5. Webhook handler for 9 event types
  6. Dunning flow for failed payments
  7. Usage metering for overage billing

Files created:
  src/services/billing/stripe-client.ts — Stripe SDK setup
  src/services/billing/subscriptions.ts — Subscription CRUD
  src/services/billing/webhooks.ts — Webhook handler
  src/services/billing/dunning.ts — Failed payment recovery
  src/api/routes/billing.ts — API routes
  src/api/webhooks/stripe.ts — Webhook endpoint

Tax: Stripe Tax enabled (automatic US + EU calculation)
PCI: SAQ-A compliant (Stripe.js Elements, no card data on server)

Next: `/godmode:test` to write billing integration tests
```

### Handling a payment dispute
```
User: /godmode:pay We received a chargeback, how do we handle it?

Pay: Investigating dispute...

Dispute details:
  Charge: ch_1234567890
  Amount: $49.00
  Reason: fraudulent
  Evidence due: 2026-04-02

Response plan:
  1. Gather evidence:
     - Customer email address and IP at time of purchase
     - Delivery proof (access logs showing usage)
     - Customer service correspondence
     - Refund policy the customer agreed to
     - Invoice and receipt

  2. Submit via Stripe Dashboard or API:
     stripe.disputes.update('dp_123', {
       evidence: {
         customer_email_address: 'user@example.com',
         product_description: 'SaaS Pro Plan subscription',
         access_activity_log: accessLogUrl,
         customer_communication: emailThreadUrl,
         refund_policy: refundPolicyUrl,
       },
     });

  3. Prevention measures:
     - Enable 3D Secure for high-risk transactions
     - Implement Radar fraud detection rules
     - Add receipt emails immediately after charge
     - Log IP and device fingerprint at checkout
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full payment system design and implementation |
| `--checkout` | One-time payment checkout flow only |
| `--subscription` | Subscription billing design only |
| `--invoice` | Invoice generation system only |
| `--tax` | Tax calculation setup only |
| `--webhooks` | Webhook handler implementation only |
| `--pci` | PCI compliance audit and recommendations |
| `--migrate` | Migrate between payment providers |
| `--provider <name>` | Use specific provider (stripe, paypal, braintree) |
| `--dunning` | Failed payment recovery flow only |
| `--reconcile` | Payment reconciliation check |

## HARD RULES

1. **NEVER process card numbers on your server.** Use client-side tokenization (Stripe.js Elements, PayPal JS SDK). This is PCI SAQ-A. Violating this moves you to SAQ-D.
2. **NEVER fulfill orders from client-side redirects.** Redirects can be faked. Always fulfill from webhook events, which are cryptographically signed.
3. **NEVER skip idempotency keys on payment write operations.** Every `create`, `capture`, `refund`, and `charge` call must include an idempotency key.
4. **NEVER calculate tax yourself.** Use Stripe Tax, TaxJar, or Avalara. Tax rules change constantly across thousands of jurisdictions.
5. **NEVER store API keys in code or environment files committed to git.** Use a secrets manager. Rotate immediately if exposed.
6. **NEVER send payment amounts as client-side parameters.** The price must come from your server-side product catalog.
7. **NEVER log card numbers, CVCs, or full bank account numbers.** Log event IDs, amounts, and outcomes only.
8. **ALWAYS verify webhook signatures before processing any event.** An unverified webhook is an attack vector.
9. **ALWAYS test with provider test mode.** Use Stripe test card numbers (4242..., 4000000000000002 for decline) to verify all paths.

## Auto-Detection

Before implementing payment integration, detect existing setup:

```
AUTO-DETECT SEQUENCE:
1. Detect payment provider:
   - grep for "stripe" in package.json / requirements.txt / go.mod → Stripe
   - grep for "paypal" / "braintree" / "adyen" similarly
   - ls .env* and grep for STRIPE_SECRET_KEY, PAYPAL_CLIENT_ID, etc.

2. Detect existing integration:
   - grep for "PaymentIntent\|checkout.sessions\|subscriptions" → Stripe API usage
   - grep for "webhook\|stripe-signature" → webhook handler exists
   - grep for "createCustomer\|createSubscription" → subscription billing

3. Detect billing model:
   - ls src/services/billing* src/services/payment* src/lib/stripe* → existing billing code
   - grep for "subscription\|recurring\|plan\|tier" → subscription model
   - grep for "invoice\|receipt\|charge" → one-time or invoicing model

4. Detect tax configuration:
   - grep for "automatic_tax\|tax_id\|TaxJar\|Avalara" → tax handling
   - grep for "vat\|VAT\|sales_tax" → tax awareness

5. Output: PAYMENT REQUIREMENTS table auto-populated from detection.
```

## Explicit Loop Protocol

Payment integration involves iterative setup and verification:

```
current_iteration = 0
components = [gateway_setup, checkout_flow, webhook_handler,
              subscription_billing, tax_config, pci_audit, reconciliation]

WHILE components is not empty AND current_iteration < 10:
    current_iteration += 1
    component = components.pop(0)

    1. IMPLEMENT component (create service, route, webhook handler)
    2. TEST with provider's test mode:
       - Successful payment (test card 4242...)
       - Declined payment (test card 4000000000000002)
       - 3D Secure flow (test card 4000000000003220)
       - Webhook delivery (stripe listen --forward-to localhost)
    3. VERIFY idempotency: duplicate request produces same result
    4. VERIFY security: no card data in logs, signatures checked
    5. IF test fails:
        components.append(component)  # retry
    6. REPORT: "Component {component}: {DONE|RETRY} -- iteration {current_iteration}"

OUTPUT: Full payment integration with all components tested.
```

## Multi-Agent Dispatch

For full billing system implementation, dispatch parallel agents:

```
MULTI-AGENT PAYMENT SETUP:
Dispatch 3 agents in parallel worktrees.

Agent 1 (worktree: pay-core):
  - Set up Stripe client and customer management
  - Implement PaymentIntent creation for one-time charges
  - Build checkout session flow with Elements
  - Implement refund handling

Agent 2 (worktree: pay-subscriptions):
  - Create subscription plans and prices in Stripe
  - Implement subscription CRUD (create, update, cancel)
  - Build plan change with proration
  - Implement dunning flow for failed payments

Agent 3 (worktree: pay-webhooks):
  - Build webhook endpoint with signature verification
  - Implement idempotent event processing
  - Handle all subscription lifecycle events
  - Set up daily reconciliation job

MERGE ORDER: core -> subscriptions -> webhooks
CONFLICT ZONES: Stripe client initialization, customer model, billing routes
```

## Anti-Patterns

- **Do NOT process card numbers on your server.** Use client-side tokenization (Stripe.js, PayPal JS SDK). Handling raw card data moves you from SAQ-A to SAQ-D, a dramatically harder compliance burden.
- **Do NOT fulfill orders from client-side redirects.** The redirect URL can be faked. Always fulfill from webhook events, which are cryptographically signed by the payment provider.
- **Do NOT skip idempotency keys.** Without idempotency keys, retried API calls can create duplicate charges. Every payment write operation must include an idempotency key.
- **Do NOT calculate tax yourself.** Tax rules change constantly and vary by jurisdiction, product type, and customer type. Use a tax service (Stripe Tax, TaxJar, Avalara).
- **Do NOT store payment provider API keys in code.** Use a secrets manager. Rotate keys if they are ever exposed. Restrict test keys to test environments and live keys to production.
- **Do NOT ignore failed webhooks.** Set up alerts for webhook delivery failures. Implement daily reconciliation to catch missed events. Stripe's retry schedule is not infinite.
- **Do NOT allow subscription downgrades without checking usage.** If the customer is using 50 GB on the Pro plan, do not let them downgrade to Starter (10 GB) without resolving the overage.
- **Do NOT send payment amounts as client-side parameters.** The price must be determined server-side from your product catalog. Client-supplied amounts can be manipulated.
