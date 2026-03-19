# /godmode:pay

Implement payment processing, subscription billing, invoicing, and tax calculation. Integrates payment gateways with PCI-DSS compliance and reliable webhook handling for all payment events.

## Usage

```
/godmode:pay                            # Full payment system design and implementation
/godmode:pay --checkout                 # One-time payment checkout flow
/godmode:pay --subscription             # Subscription billing design
/godmode:pay --invoice                  # Invoice generation system
/godmode:pay --tax                      # Tax calculation setup (VAT, sales tax)
/godmode:pay --webhooks                 # Webhook handler implementation
/godmode:pay --pci                      # PCI compliance audit and recommendations
/godmode:pay --migrate                  # Migrate between payment providers
/godmode:pay --provider stripe          # Use specific provider (stripe, paypal, braintree)
/godmode:pay --dunning                  # Failed payment recovery flow
/godmode:pay --reconcile                # Payment reconciliation check
```

## What It Does

1. Discovers payment requirements (business model, currencies, tax jurisdictions)
2. Integrates payment gateway (Stripe, PayPal, Braintree) with PCI-safe architecture
3. Designs subscription billing with plans, trials, proration, and metered usage
4. Builds invoice generation system with sequential numbering and PDF output
5. Configures tax calculation (US sales tax, EU VAT, B2B reverse charge)
6. Ensures PCI-DSS compliance (SAQ-A via client-side tokenization)
7. Implements webhook handling with signature verification and idempotency
8. Designs dunning flow for failed payment recovery

## Output
- Payment integration with gateway setup
- Subscription management with plan lifecycle
- Invoice system with tax calculation
- Webhook handler for all payment events
- PCI compliance checklist and architecture
- Commit: `"pay: <description> — <components implemented>"`

## Next Step
After payment setup: `/godmode:test` to write billing integration tests, or `/godmode:secure` to audit payment security.

## Examples

```
/godmode:pay --subscription --provider stripe   # SaaS billing with Stripe
/godmode:pay --tax                              # Set up VAT and sales tax
/godmode:pay --pci                              # PCI compliance audit
/godmode:pay --webhooks                         # Implement Stripe webhooks
```
