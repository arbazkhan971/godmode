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
- Building e-commerce checkout, SaaS billing, or marketplace payments

## Workflow

### Step 1: Payment Requirements Discovery
Identify billing model and compliance requirements:

```
PAYMENT REQUIREMENTS:
  Business Model: <one-time | subscription | metered | marketplace>
  Currency: <primary currency, multi-currency?>
  Payment Methods: <cards, wallets, bank transfers, BNPL, regional>
  Subscription Details: <plans, billing cycle, trial, proration, metered>
  Tax: <US sales tax nexus states, EU VAT B2C/B2B, tax provider>
  Compliance: <PCI-DSS level, data residency, refund policy>
```

### Step 2: Payment Gateway Integration

#### Stripe Integration (Recommended)
```typescript
// Server-side: Create payment intent
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-12-18.acacia',
});

async function createPaymentIntent(amount: number, currency: string, customerId: string, metadata: Record<string, string>) {
  return stripe.paymentIntents.create({
    amount, currency, customer: customerId,
    automatic_payment_methods: { enabled: true },
    metadata, idempotency_key: `pi_${metadata.orderId}`,
  });
}
// Client uses Stripe.js Elements — card data NEVER touches your server
```

Flow: Client initiates checkout -> Server creates PaymentIntent -> Returns client_secret -> Client collects card via Elements (PCI-safe) -> Confirms payment -> Webhook: payment_intent.succeeded -> Fulfill order.

#### PayPal Integration
Use Orders API v2: Create Order -> Client approves via PayPal JS SDK -> Capture server-side. Always capture server-side, verify webhook signatures, handle pending e-check payments.

### Step 3: Subscription Billing
```
BILLING EVENTS & ACTIONS:
  Subscription created  -> Provision features
  Payment succeeded     -> Extend access, send receipt
  Payment failed        -> Retry 3x with dunning (day 0/3/7/14/21)
  Subscription updated  -> Prorate, adjust features
  Subscription canceled -> Access until period end, then downgrade

DUNNING SCHEDULE:
  Day 0: Retry immediately | Day 3: Email "Update payment"
  Day 7: Email "Account at risk" | Day 14: "Last chance"
  Day 21: Cancel, downgrade to free
```

Use `proration_behavior: 'always_invoice'` for plan changes. Report metered usage with `createUsageRecord` using idempotency keys.

### Step 4: Invoice System
Lifecycle: DRAFT -> OPEN -> PAID | VOID | UNCOLLECTIBLE. Format: INV-{YYYY}-{sequential}. Store in DB + PDF in S3. Include line items, subtotal, tax, discounts, total.

### Step 5: Tax Calculation
Use Stripe Tax, TaxJar, or Avalara — never calculate tax yourself. US: economic nexus ($100K/200 txns). EU VAT: B2C charge customer-country rate via OSS; B2B reverse charge with VIES-validated VAT ID. Enable `automatic_tax: { enabled: true }` on checkout sessions.

### Step 6: PCI-DSS Compliance
Target SAQ-A: card data collected via Stripe.js iframe, never touches your server/DOM. Security checklist: API keys in secrets manager, webhook signatures verified, HTTPS everywhere, no card data in logs, idempotency keys on all writes, 3D Secure for SCA compliance.

### Step 7: Webhook Handling
```typescript
async function handleStripeWebhook(req: Request, res: Response) {
  const event = stripe.webhooks.constructEvent(req.body, req.headers['stripe-signature'], process.env.STRIPE_WEBHOOK_SECRET);
  // Check idempotency by event.id, process in DB transaction
  // Handle: payment_intent.succeeded/failed, subscription.created/updated/deleted,
  //         invoice.payment_succeeded/failed, charge.dispute.created
  res.status(200).json({ received: true });
}
```

Return 200 within 30s, process async if slow. Store raw events. Reconcile daily. Stripe retries up to 3 days.

### Step 8: Commit and Report
```
Files: src/services/payment/, src/api/webhooks/stripe.ts, src/config/tax.ts
Commit: "pay: <description> — <components implemented>"
```

## Key Behaviors
1. **Card data never touches your server.** Use client-side tokenization (Stripe.js Elements). This keeps you at PCI SAQ-A.
2. **Webhooks are the source of truth.** Never rely on client-side confirmation. Fulfill orders from webhooks only.
3. **Idempotency on every write.** Use idempotency keys on all Stripe API calls and deduplicate webhook events by event.id.
4. **Tax is not optional.** Use a tax service — never calculate tax yourself.
5. **Reconcile daily.** Compare your DB with the payment provider's records.
6. **Log payment events, not payment data.** Never log card numbers, CVCs, or bank account numbers.

## Flags & Options

| Flag | Description |
|--|--|
| `--checkout` | One-time payment checkout flow only |
| `--subscription` | Subscription billing design only |
| `--tax` | Tax calculation setup only |
| `--webhooks` | Webhook handler implementation only |
| `--pci` | PCI compliance audit |
| `--provider <name>` | Use specific provider (stripe, paypal, braintree) |

## HARD RULES
1. **NEVER process card numbers on your server.** Use client-side tokenization.
2. **NEVER fulfill orders from client-side redirects.** Always fulfill from signed webhook events.
3. **NEVER skip idempotency keys** on payment write operations.
4. **NEVER calculate tax yourself.** Use Stripe Tax, TaxJar, or Avalara.
5. **NEVER store API keys in code.** Use a secrets manager.
6. **NEVER send payment amounts as client-side parameters.** Price from server-side catalog only.
7. **ALWAYS verify webhook signatures** before processing any event.

## Auto-Detection
```
1. Detect provider: grep package.json for stripe/paypal/braintree/adyen
2. Detect integration: grep for PaymentIntent, checkout.sessions, webhook, stripe-signature
3. Detect billing model: grep for subscription/recurring/plan/tier or invoice/charge
4. Detect tax: grep for automatic_tax, tax_id, TaxJar, Avalara
5. Output: auto-populated PAYMENT REQUIREMENTS table
```

## Explicit Loop Protocol
```
components = [gateway_setup, checkout_flow, webhook_handler, subscription_billing, tax_config, reconciliation]
FOR EACH component: IMPLEMENT -> TEST with provider test mode -> VERIFY idempotency + security -> REPORT status
```

## Multi-Agent Dispatch
```
Agent 1 (pay-core): Stripe client, PaymentIntent, checkout, refunds
Agent 2 (pay-subscriptions): Plans, subscription CRUD, proration, dunning
Agent 3 (pay-webhooks): Webhook endpoint, idempotent processing, reconciliation
MERGE ORDER: core -> subscriptions -> webhooks
```

## TSV Logging
Log to `.godmode/pay-results.tsv`: `STEP\tCOMPONENT\tPROVIDER\tSTATUS\tDETAILS`

## Success Criteria
1. Test-mode payment completes end-to-end (checkout -> webhook -> fulfillment).
2. Webhook endpoint verifies signatures and processes idempotently.
3. Subscription lifecycle works: create, upgrade with proration, cancel.
4. Failed payment triggers dunning flow.
5. No raw card data touches the server.
6. All API keys from environment variables.

## Error Recovery
| Failure | Action |
|--|--|
| Stripe API key missing | Print env var names, link to Stripe dashboard. |
| Webhook signature fails | Verify STRIPE_WEBHOOK_SECRET matches endpoint secret. Use `stripe listen` for local dev. |
| Payment intent fails | Map Stripe error codes to user-facing messages. |
| Duplicate charges | Check idempotency key implementation. Refund duplicates via API. |
| Tax calculation fails | Verify provider credentials and product tax codes. Fall back with alert. |

## Platform Fallback (Gemini CLI, OpenCode, Codex)
Run payment tasks sequentially. Branch per task: `git checkout -b godmode-pay-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `Pay: {provider} integrated. Webhooks: {N}/{M} handled. Idempotency: {yes|no}. SAQ-A: {compliant|gaps}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH payment integration change:
  KEEP if: webhook signature verification passes AND idempotency key on all writes AND no card data touches server
  DISCARD if: webhook verification missing OR duplicate charges possible OR PCI scope expanded
  On discard: revert immediately. Payment bugs are money bugs.
```

## Stop Conditions
```
STOP when ALL of:
  - Webhook signature verification on all endpoints
  - Idempotency keys on all payment write operations
  - Event replay produces zero duplicate side effects
  - SAQ-A compliance verified (no card data on server)
  - Daily reconciliation configured
```
