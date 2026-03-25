---
name: pay
description: Payment and billing integration -- Stripe,
  subscriptions, invoicing, tax, PCI compliance.
---

## Activate When
- `/godmode:pay`, "integrate Stripe", "accept payments"
- "subscription billing", "recurring charges"
- "invoice system", "tax calculation", "PCI compliance"

## Workflow

### 1. Requirements
```bash
grep -r "stripe\|paypal\|braintree" \
  package.json requirements.txt 2>/dev/null
```
```
Model: one-time | subscription | metered | marketplace
Currency: <primary, multi-currency?>
Methods: cards, wallets, bank, BNPL
Tax: US sales tax | EU VAT | provider (Stripe Tax)
Compliance: PCI-DSS level, refund policy
```

### 2. Stripe Integration
```typescript
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
const pi = await stripe.paymentIntents.create({
  amount, currency, customer: customerId,
  automatic_payment_methods: { enabled: true },
  metadata, idempotency_key: `pi_${orderId}`,
});
```
Flow: Client initiates -> Server creates PaymentIntent
-> Returns client_secret -> Client uses Elements
(card data NEVER touches server) -> Confirms ->
Webhook: payment_intent.succeeded -> Fulfill order.

IF PayPal: Orders API v2, capture server-side.
Always verify webhook signatures.

### 3. Subscription Billing
```
Events & Actions:
  Created -> provision features
  Payment succeeded -> extend access, receipt
  Payment failed -> retry 3x with dunning
  Updated -> prorate, adjust features
  Canceled -> access until period end, downgrade

Dunning schedule:
  Day 0: retry immediately
  Day 3: email "Update payment"
  Day 7: email "Account at risk"
  Day 14: email "Last chance"
  Day 21: cancel, downgrade to free
```

### 4. Invoice System
Lifecycle: DRAFT -> OPEN -> PAID | VOID.
Format: INV-{YYYY}-{sequential}.
Store in DB + PDF in S3. Include line items, subtotal,
tax, discounts, total.

### 5. Tax Calculation
Use Stripe Tax, TaxJar, or Avalara -- NEVER calculate
tax yourself. US: nexus ($100K/200 txns). EU VAT:
B2C = customer-country rate; B2B = reverse charge
with VIES-validated VAT ID.

### 6. PCI-DSS Compliance
Target SAQ-A: card data via Stripe.js iframe, never
touches server. HTTPS everywhere, API keys in secrets
manager, webhook signatures verified, no card data in
logs, idempotency keys on all writes.

### 7. Webhook Handling
```typescript
const event = stripe.webhooks.constructEvent(
  req.body, req.headers['stripe-signature'],
  process.env.STRIPE_WEBHOOK_SECRET
);
// Check idempotency by event.id
// Process in DB transaction
res.status(200).json({ received: true });
```
Return 200 within 30s. Process async if slow.
Store raw events. Reconcile daily.

## Quality Targets
- Processing latency: <500ms round-trip
- Transaction consistency: >99% no double-charge
- PII in logs: <1 cardholder data field

## Hard Rules
1. NEVER process card numbers on your server.
2. NEVER fulfill from client-side redirects.
3. NEVER skip idempotency keys on payment writes.
4. NEVER calculate tax yourself.
5. NEVER store API keys in code.
6. NEVER send amounts as client-side params.
7. ALWAYS verify webhook signatures.

## TSV Logging
Append `.godmode/pay-results.tsv`:
```
timestamp	component	provider	status	details
```

## Keep/Discard
```
KEEP if: webhook verification passes AND idempotency
  on all writes AND no card data touches server.
DISCARD if: verification missing OR duplicate charges
  OR PCI scope expanded.
```

## Stop Conditions
```
STOP when ALL of:
  - Webhook signatures verified
  - Idempotency keys on all writes
  - Event replay = zero duplicate side effects
  - SAQ-A compliant
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| API key missing | Print env var names, link dashboard |
| Webhook sig fails | Verify secret, use stripe listen |
| Payment fails | Map error codes to user messages |
| Duplicate charges | Check idempotency, refund dupes |
| Tax calc fails | Verify provider credentials |
