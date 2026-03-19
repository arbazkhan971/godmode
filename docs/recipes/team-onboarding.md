# Recipe: Onboarding New Developers

> From "day 1" to "productive contributor." A complete Godmode workflow for getting new team members up to speed fast.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `onboard → learn → pair → docs → scaffold` |
| **Timeline** | 5 days (1 business week) |
| **Team size** | 1 new developer + 1 buddy |
| **Example project** | "PaymentPlatform" — a fintech platform with 150K lines across 12 microservices |

---

## The Scenario

A new developer (Alex) is joining your team:
- Senior engineer, but new to this codebase
- The system: 12 microservices, event-driven architecture, Kubernetes deployment
- Languages: TypeScript (backend), React (frontend), Go (data pipeline)
- No comprehensive documentation (tribal knowledge in senior engineers' heads)
- Previous onboarding attempts took 4-6 weeks to reach first meaningful contribution

Your goal: Alex ships a meaningful feature by end of week 1.

---

## Day 1: Understand the System

### Step 1: Onboard — Automated Codebase Tour

```
> /godmode:onboard

Godmode: Scanning codebase...

══════════════════════════════════════════════
PAYMENTPLATFORM — CODEBASE OVERVIEW
══════════════════════════════════════════════

Architecture: Event-driven microservices
Size: 148,392 lines across 12 services
Languages: TypeScript (72%), Go (18%), React/TSX (10%)
Infrastructure: Kubernetes on AWS EKS

SERVICES:
  1. api-gateway        — Kong gateway, routes external requests
  2. auth-service       — JWT auth, OAuth2, MFA (TypeScript)
  3. user-service       — User profiles, KYC verification (TypeScript)
  4. payment-service    — Payment processing, Stripe integration (TypeScript)
  5. ledger-service     — Double-entry accounting ledger (TypeScript)
  6. notification-svc   — Email, SMS, push notifications (TypeScript)
  7. risk-service       — Fraud detection, risk scoring (Go)
  8. compliance-svc     — AML/KYC checks, regulatory reporting (Go)
  9. analytics-pipeline — Event processing, metrics (Go)
  10. admin-dashboard   — Internal admin UI (React)
  11. merchant-portal   — Merchant-facing UI (React)
  12. webhook-service   — Outbound webhook delivery (TypeScript)

COMMUNICATION:
  Sync: gRPC between services (protobuf definitions in /proto/)
  Async: Kafka topics for events (payment.created, user.verified, etc.)
  External: REST API via api-gateway

DATABASE:
  PostgreSQL: auth, user, payment, ledger (each service has own DB)
  Redis: Session cache, rate limiting
  Elasticsearch: Search, analytics

KEY PATTERNS:
  - CQRS: Separate read/write models in payment-service and ledger-service
  - Event sourcing: Ledger entries are immutable events
  - Saga pattern: Multi-service transactions (payment → risk → ledger)
  - Circuit breaker: All inter-service calls use resilience patterns

ENTRY POINTS (start reading here):
  1. api-gateway/kong.yml — See all external routes
  2. payment-service/src/sagas/payment-saga.ts — Core business flow
  3. proto/payment/v1/payment.proto — Service contract definitions
  4. deploy/k8s/base/ — Kubernetes manifests for all services

Saved: docs/onboarding/paymentplatform-overview.md
```

### Step 2: Onboard — Architecture Deep Dive

```
> /godmode:onboard --deep-dive payment-service

Godmode: Deep-diving into payment-service...

══════════════════════════════════════════════
PAYMENT-SERVICE — ARCHITECTURE WALKTHROUGH
══════════════════════════════════════════════

Purpose: Process payments from merchants, integrate with Stripe, manage
payment lifecycle (created → processing → completed/failed)

Directory structure:
  payment-service/
  ├── src/
  │   ├── controllers/    — gRPC + REST endpoint handlers
  │   ├── sagas/          — Multi-step payment orchestration
  │   │   ├── payment-saga.ts        — THE core flow (start here)
  │   │   ├── refund-saga.ts         — Refund processing
  │   │   └── payout-saga.ts         — Merchant payouts
  │   ├── services/       — Business logic
  │   │   ├── payment.service.ts     — Payment CRUD + state machine
  │   │   ├── stripe.service.ts      — Stripe API integration
  │   │   └── webhook.service.ts     — Stripe webhook handling
  │   ├── models/         — Database entities (Prisma)
  │   ├── events/         — Kafka event producers
  │   ├── consumers/      — Kafka event consumers
  │   └── utils/          — Helpers, error types
  ├── tests/
  │   ├── unit/           — 89 unit tests
  │   ├── integration/    — 34 integration tests
  │   └── e2e/            — 12 end-to-end tests
  └── proto/              — gRPC service definitions

PAYMENT FLOW (the most important thing to understand):

  1. Merchant calls POST /api/payments (via api-gateway)
  2. api-gateway routes to payment-service
  3. payment-saga.ts orchestrates:
     a. Create payment record (status: CREATED)
     b. Call risk-service for fraud check (gRPC)
        → If REJECTED: fail payment, notify merchant
        → If APPROVED: continue
     c. Call Stripe to create PaymentIntent
     d. Update payment record (status: PROCESSING)
     e. Emit payment.processing event to Kafka
     f. Wait for Stripe webhook (payment_intent.succeeded)
     g. Update payment record (status: COMPLETED)
     h. Call ledger-service to record transaction
     i. Emit payment.completed event to Kafka
     j. Trigger notification to merchant

STATE MACHINE:
  CREATED → PROCESSING → COMPLETED
                       → FAILED
                       → REFUNDED (after COMPLETED)

CODE TOUR (read in this order):
  1. proto/payment/v1/payment.proto — understand the data model
  2. src/sagas/payment-saga.ts — the core orchestration
  3. src/services/payment.service.ts — business logic
  4. src/services/stripe.service.ts — external integration
  5. src/events/producers.ts — what events are emitted
  6. tests/e2e/payment.e2e.test.ts — see the flow end-to-end

Saved: docs/onboarding/payment-service-walkthrough.md
```

### Step 3: Learn — Interactive Codebase Q&A

```
> /godmode:learn

Godmode: Interactive learning mode activated. Ask me anything about this
codebase. I'll answer with specific file references and code examples.

> How does the payment saga handle failures? What if Stripe is down?

Godmode: Great question. The payment saga uses a compensating transaction
pattern for failure handling.

File: payment-service/src/sagas/payment-saga.ts (lines 78-112)

The saga has explicit compensation steps:
  - If risk check fails: Mark payment as REJECTED, notify merchant
  - If Stripe call fails: Retry 3 times with exponential backoff
    (see src/utils/retry.ts), then mark as FAILED
  - If Stripe succeeds but ledger call fails: The ledger consumer
    retries from Kafka (at-least-once delivery), so payment.completed
    events are replayed until ledger confirms recording

Circuit breaker (src/utils/circuit-breaker.ts):
  - If Stripe fails 5 times in 60 seconds, circuit opens
  - All new payments queued to Kafka for later processing
  - Circuit half-opens every 30 seconds to test recovery

This means: if Stripe is down for 5 minutes, payments are queued
and processed automatically when Stripe recovers. No data loss.

> What about idempotency? Can a payment be processed twice?

Godmode: Idempotency is handled via a client-supplied idempotency key.

File: payment-service/src/middleware/idempotency.ts

Every POST /api/payments requires an Idempotency-Key header.
The middleware:
  1. Checks Redis for the key
  2. If found: returns the cached response (no re-processing)
  3. If not found: processes normally, caches response in Redis (24h TTL)

The Stripe call also uses Stripe's built-in idempotency (forwarding the
same key to PaymentIntent creation).

> Where are the Kafka topic definitions?

Godmode: Topic definitions are in two places:

1. Protobuf event schemas:
   proto/events/v1/payment_events.proto — defines event message types

2. Topic configuration:
   infrastructure/kafka/topics.yaml — topic names, partitions, retention

3. Producer code:
   payment-service/src/events/producers.ts — where events are emitted

Topics used by payment-service:
  - payment.created (produced)
  - payment.processing (produced)
  - payment.completed (produced)
  - payment.failed (produced)
  - risk.check.completed (consumed)
```

---

## Day 2: Set Up and First Contribution

### Step 4: Scaffold — Generate Development Environment

```
> /godmode:scaffold --dev-environment

Godmode: Setting up local development environment...

LOCAL DEV SETUP:

1. Docker Compose (all services):
   File: docker-compose.dev.yml
   Services: all 12 services + PostgreSQL + Redis + Kafka + Elasticsearch
   Command: docker compose -f docker-compose.dev.yml up

2. Service-specific development:
   File: payment-service/Makefile
   Commands:
     make dev        — start with hot reload
     make test       — run unit tests
     make test-int   — run integration tests (needs Docker deps)
     make test-e2e   — run end-to-end tests
     make proto      — regenerate protobuf stubs
     make lint       — run linter

3. Seed data:
   File: scripts/seed-dev-data.ts
   Creates: 10 test merchants, 100 test payments, sample Kafka events
   Command: make seed

4. Environment variables:
   File: .env.example → .env (copied and configured)
   Stripe test keys pre-configured
   All service URLs pointing to Docker Compose

DEV ENVIRONMENT READY:
  ✓ All 12 services running locally
  ✓ Database seeded with test data
  ✓ Kafka topics created
  ✓ Test payment flow working end-to-end
```

### Step 5: Pair — First Feature with Buddy

Alex's first task: Add a payment retry button to the merchant portal.

```
> /godmode:pair --role navigator

Godmode: Pair programming mode activated.
Role: I am the navigator (guiding), Alex is the driver (coding).

TASK: Add "Retry Payment" button for failed payments in merchant portal

Navigator guidance:

Step 1: Understand the existing UI
  Look at: merchant-portal/src/pages/payments/PaymentDetail.tsx
  This page shows payment details. The status badge is at line 45.
  For FAILED payments, we want to add a "Retry" button next to the status.

Step 2: Understand the retry API
  Look at: payment-service/src/controllers/payment.controller.ts
  There is already a POST /api/payments/:id/retry endpoint (line 89).
  It creates a new payment with the same parameters as the failed one.
  Returns 201 with the new payment object.

Step 3: Plan the changes
  Files to modify:
    1. merchant-portal/src/pages/payments/PaymentDetail.tsx — add button
    2. merchant-portal/src/api/payments.ts — add retry API call
    3. merchant-portal/src/pages/payments/PaymentDetail.test.tsx — add test

  Let Alex write the code. I'll review as they go.

> [Alex writes the code]

Navigator feedback:
  ✓ Good: Used the existing Button component from the design system
  ✓ Good: Added loading state while retry is in progress
  ⚠ Suggestion: Add error handling for the retry call (show toast on failure)
  ⚠ Suggestion: Disable the button after clicking to prevent double-retry
  ✓ Good: Test covers both the button visibility and the click behavior

> [Alex addresses feedback]

PAIR SESSION COMPLETE:
  Files changed: 3
  Tests: 2 new tests, all passing
  Time: 45 minutes
  Commit: "feat: add retry button for failed payments in merchant portal"
```

---

## Day 3: Deepen Understanding

### Step 6: Onboard — Domain-Specific Knowledge

```
> /godmode:onboard --domain payments

Godmode: Payment domain deep-dive...

PAYMENT DOMAIN KNOWLEDGE:

Key concepts (that new engineers often misunderstand):
  1. Authorization vs. Capture
     - Authorization: "Can this card pay $50?" (holds funds)
     - Capture: "Actually charge the $50" (moves funds)
     - Our system does auth+capture in one step (for simplicity)

  2. Payment states are FINAL
     - COMPLETED payments cannot become FAILED
     - Refunds create a NEW transaction, not a state change
     - This is a regulatory requirement (audit trail)

  3. Idempotency is non-negotiable
     - Network issues cause duplicate requests
     - Without idempotency keys, customers get charged twice
     - Every payment mutation requires an idempotency key

  4. Money is stored as integers (cents)
     - $10.50 is stored as 1050
     - NEVER use floating point for money
     - Currency code is always stored alongside amount

  5. Stripe webhooks are the source of truth
     - Our DB status is "optimistic" — we update on webhook confirmation
     - Webhook delivery can be delayed (up to 24 hours in extreme cases)
     - Webhooks can arrive out of order — handle state transitions carefully

Regulatory context:
  - PCI DSS: We never store card numbers (Stripe handles it)
  - PSD2/SCA: European payments require 3D Secure (handled by Stripe)
  - KYC/AML: Merchant verification before processing payments

Common gotchas:
  - Stripe test mode vs. live mode: different API keys, different webhooks
  - Currency conversion happens at Stripe, not in our system
  - Refund window is 180 days for Visa/Mastercard, 120 for Amex
```

### Step 7: Learn — Test-Driven Exploration

```
> /godmode:learn --through-tests

Godmode: Learning through the test suite...

TEST EXPLORATION:

Running: payment-service/tests/e2e/payment.e2e.test.ts

Test 1: "should process a payment end-to-end"
  Shows: The complete happy path
  Key insight: Payment goes through CREATED → PROCESSING → COMPLETED
  Read this test first to understand the full flow.

Test 2: "should reject payment when risk score is too high"
  Shows: How the risk service integration works
  Key insight: Risk service returns a score, threshold is configurable

Test 3: "should handle Stripe webhook for successful payment"
  Shows: How webhooks update payment status
  Key insight: Webhook signature verification happens in middleware

Test 4: "should retry failed payment with same idempotency semantics"
  Shows: The retry logic Alex just built the UI for
  Key insight: Retry creates a NEW payment, links to original via parent_id

Test 5: "should compensate when ledger write fails"
  Shows: The saga compensation pattern
  Key insight: Kafka consumer retries on ledger failure, eventual consistency

SUGGESTED READING ORDER:
  1. e2e tests (understand the flows)
  2. integration tests (understand the service boundaries)
  3. unit tests (understand the business rules)

Total test suite: 135 tests across 3 services explored
```

---

## Day 4: Independent Work

### Step 8: Docs — Fill Documentation Gaps

Alex noticed missing documentation during onboarding. Use this as a contribution:

```
> /godmode:docs --audit payment-service

Godmode: Auditing documentation for payment-service...

DOCUMENTATION AUDIT:

Existing docs:
  ✓ README.md — basic setup instructions
  ✓ proto/ — gRPC service definitions (self-documenting)
  ✗ No architecture decision records
  ✗ No runbook for production issues
  ✗ No API guide beyond protobuf definitions
  ✗ No onboarding guide for this service
  ✗ No data flow diagrams

Documentation gaps (by priority):
  1. Payment flow diagram (visual, helps all new engineers)
  2. Runbook: common production issues and resolutions
  3. ADR: why event sourcing for the ledger
  4. ADR: why Stripe over Adyen/Braintree
  5. API guide: REST endpoint reference with examples

> /godmode:docs --generate runbook

Godmode: Generating runbook from codebase analysis...

PAYMENT-SERVICE RUNBOOK:

Scenario 1: Payment stuck in PROCESSING
  Symptoms: payment.processing event emitted, no completion after 30 min
  Likely cause: Stripe webhook not received
  Resolution:
    1. Check Stripe dashboard for PaymentIntent status
    2. If succeeded: manually trigger webhook reconciliation
       curl -X POST /internal/reconcile-payment/:id
    3. If still processing: wait for Stripe (can take up to 7 days for
       bank transfers)

Scenario 2: High error rate on payment creation
  Symptoms: 5xx errors on POST /api/payments
  Common causes:
    a. Stripe API outage → check status.stripe.com
    b. Risk service down → check risk-service pods
    c. Database connection exhaustion → check connection pool metrics
  Resolution: Check circuit breaker state at /internal/health/detailed

[... 8 more scenarios ...]

Saved: docs/runbooks/payment-service-runbook.md
Commit: "docs: payment service runbook — 10 production scenarios"
```

### Step 9: Scaffold — Generate a New Feature

Alex's second feature: Add payment receipt emails.

```
> /godmode:scaffold --template event-consumer

Godmode: Generating event consumer scaffold...

SCAFFOLD: Payment Receipt Email Consumer

Based on existing patterns in notification-svc, generating:

Files created:
  notification-svc/src/consumers/payment-receipt.consumer.ts
    — Kafka consumer for payment.completed events
    — Template matching existing email consumers
    — Automatic retry with dead letter queue

  notification-svc/src/templates/payment-receipt.html
    — Email template with payment details
    — Matches existing template style

  notification-svc/tests/unit/payment-receipt.consumer.test.ts
    — Unit tests matching existing test patterns
    — 6 tests: happy path, missing data, template rendering, retry, DLQ

  notification-svc/tests/integration/payment-receipt.test.ts
    — Integration test with Kafka test container

Pattern matched: notification-svc/src/consumers/welcome-email.consumer.ts
  (used as reference for code style, error handling, logging patterns)

Commit: "scaffold: payment receipt email consumer (from pattern)"
```

---

## Day 5: Ship Something Meaningful

### Step 10: Build + Review + Ship

```
> /godmode:build --continue

Godmode: Completing payment receipt feature...

Remaining tasks:
  Task 1: Connect receipt data to email template (merge scaffold + logic)
  Task 2: Add merchant branding to receipt (logo, colors from merchant profile)
  Task 3: Add receipt PDF attachment (reuse existing PDF generator)

[builds tasks with TDD]

BUILD COMPLETE: 3 tasks, 8 new tests, all passing.

> /godmode:review

REVIEW REPORT:
  Overall: 8.5/10
  MUST FIX: 0
  SHOULD FIX: 1 (add sender email configuration to environment variables)
  NICE TO HAVE: 1 (consider making receipt template customizable per merchant)
  Verdict: APPROVED with minor suggestion

> /godmode:ship --pr

PR #234 created: "feat: payment receipt emails on successful payment"
CI: ✓ All checks passing
Reviewers: @buddy, @tech-lead
```

---

## Onboarding Week Timeline

| Day | Focus | Skills Used | Output |
|-----|-------|-------------|--------|
| 1 | Understand | onboard, learn | Architecture knowledge, code tour |
| 2 | Set up + first PR | scaffold, pair | Dev environment, retry button feature |
| 3 | Deepen | onboard, learn | Domain expertise, test exploration |
| 4 | Document + scaffold | docs, scaffold | Runbook, feature scaffold |
| 5 | Ship | build, review, ship | Payment receipt feature PR |

---

## Knowledge Transfer Patterns

### Pattern 1: Automated Codebase Tour

```
/godmode:onboard                         # Full system overview
/godmode:onboard --deep-dive <service>   # Service-specific walkthrough
/godmode:onboard --domain <domain>       # Domain knowledge transfer
```

Best for: Day 1. Gives new engineers a structured understanding of the system without relying on a senior engineer's time.

### Pattern 2: Interactive Q&A

```
/godmode:learn                           # Ask questions, get code references
/godmode:learn --through-tests           # Understand system via test suite
```

Best for: Day 1-3. New engineers always have questions. Learn mode gives instant, accurate answers with file references.

### Pattern 3: Pair Programming

```
/godmode:pair --role navigator           # AI guides, human codes
/godmode:pair --role driver              # AI codes, human guides
```

Best for: Day 2-3. First feature implementation with structured guidance. The navigator role teaches patterns while the new engineer writes code.

### Pattern 4: Documentation as Learning

```
/godmode:docs --audit <service>          # Find doc gaps
/godmode:docs --generate runbook         # Generate missing docs
```

Best for: Day 3-4. Writing documentation forces understanding. The new engineer learns by documenting, and the team gets better docs.

### Pattern 5: Pattern-Based Scaffolding

```
/godmode:scaffold --template <pattern>   # Generate from existing patterns
```

Best for: Day 4-5. Ensures the new engineer follows existing code patterns. The scaffold teaches conventions while producing working code.

---

## Measuring Onboarding Success

| Metric | Traditional | With Godmode | Improvement |
|--------|-------------|-------------|-------------|
| Time to first PR | 5-8 days | 2 days | 60-75% faster |
| Time to first feature | 3-4 weeks | 5 days | 75-80% faster |
| Senior engineer time spent | 20+ hours | 4-6 hours | 70-80% less |
| Documentation gaps filled | 0 | 3-5 documents | Net positive |
| Confidence level (self-rated) | 3/10 at week 1 | 7/10 at week 1 | 2.3x higher |
| Codebase familiarity | 10% at week 1 | 40% at week 1 | 4x better |

---

## Onboarding Checklist

```markdown
## New Engineer Onboarding — Week 1

### Day 1: Understand
- [ ] Run /godmode:onboard — read generated overview
- [ ] Run /godmode:onboard --deep-dive on 2-3 key services
- [ ] Use /godmode:learn to ask 10+ questions about the codebase
- [ ] Read top 5 e2e tests to understand core flows
- [ ] Identify 1 area that confused you (we'll fix the docs)

### Day 2: Set Up and First PR
- [ ] Run /godmode:scaffold --dev-environment
- [ ] Verify all services run locally
- [ ] Pick a small task from the onboarding backlog
- [ ] Use /godmode:pair with buddy for first implementation
- [ ] Submit first PR (can be tiny — it's about the process)

### Day 3: Deepen
- [ ] Run /godmode:onboard --domain on your team's domain
- [ ] Run /godmode:learn --through-tests on 2 services
- [ ] Attend team standup (you should understand 60%+ now)
- [ ] Ask questions about anything that is still unclear

### Day 4: Document and Build
- [ ] Run /godmode:docs --audit on a service you now understand
- [ ] Write/generate 1 piece of missing documentation
- [ ] Run /godmode:scaffold for your first feature
- [ ] Start implementing with TDD

### Day 5: Ship
- [ ] Complete your feature with /godmode:build
- [ ] Run /godmode:review on your own code
- [ ] Submit PR with /godmode:ship --pr
- [ ] Retrospective: What worked? What's still confusing?
```

---

## Custom Chain for Onboarding

```yaml
# .godmode/chains.yaml
chains:
  onboard-new-engineer:
    description: "Week 1 onboarding for new team members"
    steps:
      - onboard
      - learn
      - scaffold:
          args: "--dev-environment"
      - pair
      - docs:
          args: "--audit"
      - scaffold:
          args: "--template from-pattern"
      - build
      - review
      - ship

  onboard-quick:
    description: "Quick onboarding for contractor or short-term contributor"
    steps:
      - onboard
      - learn
      - scaffold:
          args: "--dev-environment"
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Full-Stack Feature Recipe](fullstack-feature.md) — After onboarding, build a full feature
- [Greenfield SaaS Recipe](greenfield-saas.md) — When there is no codebase to onboard to
- [Legacy Modernization Recipe](legacy-modernization.md) — Onboarding to a legacy system
