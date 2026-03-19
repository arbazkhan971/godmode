# Recipe: Building a SaaS from Scratch

> From blank directory to paying customers. A complete Godmode workflow for greenfield SaaS development.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `think → architect → schema → api → auth → build → test → review → deploy → observe → ship` |
| **Timeline** | Day 1 to production launch |
| **Team size** | 1-4 developers |
| **Example project** | "InvoiceFlow" — an invoicing SaaS for freelancers |

---

## Prerequisites

- Node.js / Python / Go environment configured
- Cloud provider account (AWS, GCP, or Azure)
- Database provisioned (PostgreSQL recommended)
- Godmode installed and configured

---

## Phase 1: Ideation and Design (Day 1)

### Step 1: Think — Define the Product

```
> /godmode:think I want to build InvoiceFlow, a SaaS for freelancers to
  create, send, and track invoices. Core features: invoice creation with
  templates, PDF generation, email delivery, payment tracking, recurring
  invoices, and a dashboard with revenue analytics.

Godmode: Researching problem space...

CODEBASE CONTEXT:
- Greenfield project — no existing code
- No framework detected

Three questions before I write the spec:
1. Who is the primary user persona? (Solo freelancer vs. small agency?)
2. Payment processing: Stripe, or do you want to support multiple gateways?
3. Multi-tenancy model: database-per-tenant or shared schema with tenant_id?

> Solo freelancers. Stripe only for now. Shared schema with tenant_id.

Godmode: Writing spec...
Saved: docs/specs/invoiceflow-mvp.md
Commit: "spec: InvoiceFlow MVP — invoicing SaaS for freelancers"
```

**What you get:** A detailed specification covering user stories, data model sketch, API surface, and non-functional requirements.

### Step 2: Architect — Design the System

```
> /godmode:architect

Godmode: Reading spec... Analyzing requirements...

ARCHITECTURE CONTEXT:
System: InvoiceFlow — invoicing SaaS
Stage: greenfield
Scale expectations: 1K users year 1, 50K year 3
Deployment: AWS

PATTERN EVALUATION:

Pattern A: Modular Monolith (Node.js/Express + PostgreSQL)
  Pros: Fast to build, simple deployment, easy debugging
  Cons: Harder to scale individual components later
  Fit: ★★★★★ (ideal for early-stage SaaS)

Pattern B: Serverless (Lambda + API Gateway + DynamoDB)
  Pros: Zero idle cost, auto-scaling
  Cons: Cold starts, vendor lock-in, harder local dev
  Fit: ★★★☆☆

Pattern C: Microservices (ECS + PostgreSQL)
  Pros: Independent scaling, team autonomy
  Cons: Massive overhead for a small team, premature
  Fit: ★★☆☆☆

RECOMMENDATION: Pattern A — Modular Monolith
Reason: Fastest path to market for a 1-4 person team. You can extract
services later when you hit actual scaling pain points.

Saved: docs/architecture/invoiceflow-architecture.md
Saved: docs/adr/001-modular-monolith.md
```

### Step 3: Schema — Design the Database

```
> /godmode:schema

Godmode: Reading architecture doc... Designing schema...

SCHEMA DESIGN:

Tables:
  tenants         — id, name, subdomain, plan, stripe_customer_id
  users           — id, tenant_id, email, password_hash, role
  clients         — id, tenant_id, name, email, address, tax_id
  invoices        — id, tenant_id, client_id, number, status, due_date, total
  invoice_items   — id, invoice_id, description, quantity, unit_price, tax_rate
  payments        — id, invoice_id, amount, stripe_payment_id, paid_at
  templates       — id, tenant_id, name, html_content, is_default
  recurring_rules — id, invoice_id, frequency, next_run_at, active

Indexes:
  invoices(tenant_id, status) — dashboard queries
  invoices(tenant_id, due_date) — overdue invoice alerts
  payments(invoice_id) — payment lookup
  recurring_rules(next_run_at, active) — cron job queries

Saved: docs/specs/invoiceflow-schema.md
Generated: migrations/001_initial_schema.sql
Commit: "schema: InvoiceFlow initial database design — 8 tables"
```

---

## Phase 2: API and Auth Foundation (Day 2-3)

### Step 4: API — Design the Endpoints

```
> /godmode:api --type rest

Godmode: Reading spec and schema... Designing API...

API DESIGN: InvoiceFlow REST API v1

Authentication: Bearer token (JWT)
Base URL: /api/v1

Endpoints:
  POST   /auth/register          — tenant signup
  POST   /auth/login             — get JWT
  POST   /auth/refresh           — refresh JWT

  GET    /clients                — list clients (paginated)
  POST   /clients                — create client
  GET    /clients/:id            — get client
  PUT    /clients/:id            — update client
  DELETE /clients/:id            — soft delete client

  GET    /invoices               — list invoices (filterable by status)
  POST   /invoices               — create invoice
  GET    /invoices/:id           — get invoice with items
  PUT    /invoices/:id           — update invoice (draft only)
  POST   /invoices/:id/send      — send invoice via email
  POST   /invoices/:id/void      — void an invoice
  GET    /invoices/:id/pdf       — generate PDF

  POST   /invoices/:id/payments  — record payment
  GET    /invoices/:id/payments  — list payments

  GET    /dashboard/stats        — revenue summary
  GET    /dashboard/overdue      — overdue invoices

  GET    /templates              — list templates
  POST   /templates              — create template

  POST   /recurring              — create recurring rule
  GET    /recurring              — list recurring rules

Saved: docs/api/openapi.yaml
Commit: "api: InvoiceFlow REST API design — 20 endpoints"
```

### Step 5: Auth — Implement Authentication

```
> /godmode:auth

Godmode: Reading API spec... Implementing auth...

AUTH IMPLEMENTATION:
Strategy: JWT with refresh tokens
Password: bcrypt (cost factor 12)
Session: Access token (15 min) + Refresh token (7 days)
Multi-tenancy: tenant_id embedded in JWT claims

Files created:
  src/middleware/auth.ts          — JWT verification middleware
  src/middleware/tenant.ts        — tenant isolation middleware
  src/services/auth.service.ts   — login, register, refresh
  src/utils/jwt.ts               — token generation/verification
  tests/auth.test.ts             — 14 auth tests

Security measures:
  ✓ Rate limiting on /auth/* endpoints (5 req/min)
  ✓ Password strength validation (zxcvbn)
  ✓ Refresh token rotation on use
  ✓ tenant_id check on every data query
  ✓ CORS configured for SaaS subdomains

Commit: "feat: JWT auth with multi-tenant isolation"
Commit: "test: auth service — 14 tests covering login, register, refresh, tenant isolation"
```

---

## Phase 3: Core Implementation (Day 3-7)

### Step 6: Plan — Break Down the Build

```
> /godmode:plan

Godmode: Reading spec, schema, and API design...

IMPLEMENTATION PLAN: 28 tasks in 5 phases

Phase 1: Data Layer (Tasks 1-6)
  Task 1: Prisma schema + migration runner
  Task 2: Client CRUD service
  Task 3: Invoice CRUD service with line items
  Task 4: Payment recording service
  Task 5: Template management service
  Task 6: Recurring invoice service

Phase 2: API Layer (Tasks 7-14)
  Task 7: Client endpoints + validation
  Task 8: Invoice endpoints + validation
  Task 9: Invoice send endpoint (email integration)
  Task 10: Invoice PDF generation endpoint
  Task 11: Payment endpoints
  Task 12: Template endpoints
  Task 13: Recurring rule endpoints
  Task 14: Dashboard stats endpoints

Phase 3: Business Logic (Tasks 15-20)
  Task 15: Invoice numbering system (per-tenant sequential)
  Task 16: Invoice state machine (draft → sent → paid → void)
  Task 17: Overdue invoice detection + notifications
  Task 18: Recurring invoice cron job
  Task 19: Stripe webhook handler
  Task 20: Revenue analytics aggregation

Phase 4: Integration (Tasks 21-25)
  Task 21: Email service (SendGrid/SES)
  Task 22: PDF generation (Puppeteer/wkhtmltopdf)
  Task 23: Stripe payment link generation
  Task 24: File storage for PDF archival (S3)
  Task 25: Webhook delivery for integrations

Phase 5: Polish (Tasks 26-28)
  Task 26: API rate limiting per tenant/plan
  Task 27: Request logging and audit trail
  Task 28: Health check and readiness endpoints

Branch: feat/invoiceflow-core
Saved: docs/plans/invoiceflow-core-plan.md
```

### Step 7: Build — Execute the Plan

```
> /godmode:build

Godmode: Starting execution...

Phase 1: Data Layer
  Task 1: RED → GREEN → REFACTOR → COMMIT ✓
  Task 2: RED → GREEN → REFACTOR → COMMIT ✓
  Task 3: RED → GREEN → REFACTOR → COMMIT ✓
  Task 4: RED → GREEN → REFACTOR → COMMIT ✓
  Task 5: RED → GREEN → REFACTOR → COMMIT ✓
  Task 6: RED → GREEN → REFACTOR → COMMIT ✓

Phase 2: API Layer
  [continues through all 28 tasks with TDD]

Phase 2 review:
  ✓ Tests: 87 new, all passing
  ✓ Lint: clean
  ✓ Type check: clean
  ✓ Coverage: 91%

BUILD COMPLETE: 28 tasks, 87 tests, all green.
```

### Step 8: Test — Fill Coverage Gaps

```
> /godmode:test --coverage-target 95

Godmode: Analyzing coverage report...

COVERAGE ANALYSIS:
Current: 91% (lines)
Target: 95%
Gap: 4% (37 uncovered lines)

Uncovered areas:
  1. Invoice state transitions — edge cases (void already-paid)
  2. Stripe webhook signature verification failure path
  3. Recurring invoice — skip weekends logic
  4. PDF generation — timeout handling
  5. Concurrent payment recording race condition

Writing tests...

Tests added: 18 new tests
Coverage: 91% → 96.2% ✓ TARGET MET

Commit: "test: fill coverage gaps — invoice states, webhooks, recurring, PDF timeout"
```

---

## Phase 4: Quality Gates (Day 7-8)

### Step 9: Review — Code Review

```
> /godmode:review

Godmode: Running 2-stage review...

STAGE 1: Automated checks
  ✓ Lint: clean
  ✓ Types: clean
  ✓ Tests: 105/105 passing
  ✓ Coverage: 96.2%
  ✓ Dependencies: no known vulnerabilities
  ✓ Bundle size: N/A (backend)

STAGE 2: Agent review

REVIEW REPORT:
Overall: 8.7/10

MUST FIX (0 items): None

SHOULD FIX (3 items):
  1. Invoice PDF generation holds a Puppeteer browser instance open.
     Consider a browser pool or serverless function.
  2. Dashboard stats query does a full table scan on invoices.
     Add a materialized view or cache for tenants with 1K+ invoices.
  3. No request ID in logs — add correlation IDs for debugging.

NICE TO HAVE (2 items):
  1. Consider adding OpenTelemetry spans around Stripe API calls.
  2. Invoice number format could be configurable per tenant.

Verdict: APPROVED with suggestions
```

### Step 10: Secure — Security Audit

```
> /godmode:secure

Godmode: Running STRIDE + OWASP audit...

SECURITY AUDIT:

STRIDE Analysis:
  Spoofing:         ✓ PASS — JWT validation on all routes
  Tampering:        ✓ PASS — Input validation, parameterized queries
  Repudiation:      ⚠ WARN — Audit log exists but no immutable store
  Info Disclosure:  ✓ PASS — tenant_id isolation enforced
  DoS:              ✓ PASS — Rate limiting configured
  Elevation:        ✓ PASS — Role-based access checks

OWASP Top 10:
  A01 Broken Access Control:  ✓ tenant_id middleware prevents cross-tenant access
  A02 Crypto Failures:        ✓ bcrypt passwords, TLS enforced
  A03 Injection:              ✓ Prisma parameterized queries
  A04 Insecure Design:        ✓ State machine prevents invalid invoice transitions
  A05 Security Misconfig:     ⚠ CORS allows wildcard subdomain — tighten regex
  A06 Vulnerable Components:  ✓ No known CVEs in dependencies
  A07 Auth Failures:          ✓ Rate limiting, token rotation
  A08 Software Integrity:     ✓ Stripe webhook signature verified
  A09 Logging Failures:       ⚠ Auth failures not logged to SIEM
  A10 SSRF:                   ✓ No user-controlled URLs in server requests

FINDINGS:
  1. MEDIUM — CORS wildcard subdomain (*.invoiceflow.com) too broad
  2. LOW — Auth failures not forwarded to security monitoring
  3. LOW — Audit log stored in same database (not immutable)

Verdict: CONDITIONAL PASS — 1 MEDIUM, 2 LOW findings
```

```
> /godmode:fix --from-audit

Godmode: Fixing security findings...

Fix 1: Tightened CORS to explicit tenant subdomain pattern
Fix 2: Added auth failure logging to structured log output
Fix 3: Documented audit log immutability as future enhancement

All findings addressed.
Commit: "fix(security): tighten CORS, add auth failure logging"
```

---

## Phase 5: Deploy and Launch (Day 8-10)

### Step 11: Deploy — Infrastructure Setup

```
> /godmode:deploy --strategy blue-green --provider aws

Godmode: Generating deployment configuration...

DEPLOYMENT PLAN:
  Strategy: Blue-green with health check gate
  Provider: AWS (ECS Fargate + RDS + ElastiCache)
  Environments: staging, production

Files generated:
  infra/terraform/main.tf           — VPC, subnets, security groups
  infra/terraform/ecs.tf            — ECS cluster, task definition, ALB
  infra/terraform/rds.tf            — PostgreSQL RDS instance
  infra/terraform/elasticache.tf    — Redis for sessions/caching
  .github/workflows/deploy.yml      — CI/CD pipeline
  Dockerfile                        — Multi-stage production build

Deploy to staging:
  ✓ Infrastructure provisioned
  ✓ Database migrated
  ✓ Application deployed
  ✓ Health check: OK
  ✓ Smoke tests: 12/12 passing

Commit: "infra: AWS deployment — ECS, RDS, ElastiCache, CI/CD"
```

### Step 12: Observe — Add Monitoring

```
> /godmode:observe

Godmode: Setting up observability stack...

OBSERVABILITY SETUP:

Metrics (Prometheus + Grafana):
  - Request rate, latency (p50/p95/p99), error rate
  - Invoice creation rate, payment processing time
  - Database connection pool utilization
  - Stripe API latency and error rate

Logging (Structured JSON → CloudWatch):
  - Request/response logging with correlation IDs
  - Business events: invoice_created, payment_received, email_sent
  - Error logging with stack traces and context

Tracing (OpenTelemetry → X-Ray):
  - End-to-end request traces
  - Database query spans
  - External API call spans (Stripe, SendGrid)

Alerting:
  - Error rate > 1% for 5 minutes → PagerDuty
  - p99 latency > 2s for 10 minutes → Slack
  - Payment webhook failures → Slack + PagerDuty
  - Database connection pool > 80% → Slack

SLOs:
  - Availability: 99.9% (8.76 hours/year downtime budget)
  - Latency: p99 < 500ms for API endpoints
  - Invoice delivery: 99% of emails delivered within 60s

Saved: docs/runbooks/invoiceflow-observability.md
Commit: "observe: metrics, logging, tracing, alerting, SLOs"
```

### Step 13: Ship — Go to Production

```
> /godmode:ship --deploy production

Godmode: Starting 8-phase shipping workflow...

Phase 1: INVENTORY
  42 commits, 67 files changed
  Features: auth, invoices, payments, PDF, email, recurring, dashboard

Phase 2: CHECKLIST
  ✓ Tests: 105/105 passing
  ✓ Lint: clean
  ✓ Security audit: PASS
  ✓ Coverage: 96.2%
  ✓ No secrets in code
  ✓ Database migrations reviewed
  ✓ Rollback plan documented

Phase 3: PREPARE
  ✓ Docker image built and pushed
  ✓ Database backup created

Phase 4: DRY RUN
  ✓ Staging deployment verified
  ✓ Smoke tests: 12/12 passing
  ✓ Load test: handles 500 req/s

Phase 5: DEPLOY
  ✓ Blue-green deployment initiated
  ✓ New version health check: OK
  ✓ Traffic switched to new version

Phase 6: VERIFY
  ✓ Production health check: OK
  ✓ Smoke tests against production: 12/12
  ✓ First invoice created successfully

Phase 7: LOG
  Ship log: .godmode/ship-log.tsv
  Version: v1.0.0

Phase 8: MONITOR
  T+0:  ✓ Deployed
  T+5:  ✓ Error rate 0.00%, latency p99 120ms
  T+15: ✓ 3 invoices created by early users
  T+30: ✓ All clear. Production launch confirmed stable.

🚀 InvoiceFlow v1.0.0 is LIVE.
```

---

## Complete Timeline

| Day | Phase | Skills Used | Output |
|-----|-------|-------------|--------|
| 1 | Design | think, architect, schema | Spec, architecture, database schema |
| 2 | API/Auth | api, auth | OpenAPI spec, auth implementation |
| 3-6 | Build | plan, build | 28 tasks, 87 tests, full backend |
| 7 | Test | test | 18 additional tests, 96.2% coverage |
| 7-8 | Quality | review, secure, fix | Code review, security audit, fixes |
| 8-9 | Deploy | deploy, observe | AWS infrastructure, monitoring |
| 10 | Ship | ship | Production deployment, v1.0.0 |

---

## What Godmode Provided at Each Step

| Step | Without Godmode | With Godmode |
|------|----------------|-------------|
| Design | Whiteboard session, lost context | Persistent spec document, traceable decisions |
| Architecture | Senior engineer opinion | Structured pattern evaluation with trade-offs |
| Schema | Manual SQL writing | Generated migrations with indexes and constraints |
| API | Ad-hoc endpoint creation | Consistent OpenAPI spec with validation |
| Auth | Copy-paste from blog post | Battle-tested patterns with security best practices |
| Build | No TDD discipline | Enforced RED-GREEN-REFACTOR on every task |
| Test | "We'll add tests later" | 96.2% coverage with edge cases covered |
| Review | Missed issues | Systematic 2-stage review catching real problems |
| Security | Skipped entirely | STRIDE + OWASP audit with specific findings |
| Deploy | Manual server setup | Infrastructure as Code with blue-green deployment |
| Observe | Console.log debugging | Metrics, logging, tracing, alerting, SLOs |
| Ship | YOLO deploy | 8-phase process with rollback plan |

---

## Post-Launch: Iteration Loop

After launch, the daily workflow becomes:

```
# Feature work
/godmode:think "Add Stripe checkout for invoice payment links"
/godmode:plan
/godmode:build
/godmode:ship --pr

# Performance tuning
/godmode:optimize --goal "dashboard load time" --target "< 200ms"

# Bug fixes
/godmode:debug "User reports duplicate invoices"
/godmode:fix --from-debug
/godmode:ship --deploy production

# Weekly security check
/godmode:secure --quick
```

---

## Custom Chain for This Project

Save this to `.godmode/chains.yaml` to codify the workflow:

```yaml
chains:
  saas-feature:
    description: "Standard InvoiceFlow feature workflow"
    steps:
      - think
      - plan
      - build
      - test
      - review
      - secure:
          on_fail: fix
          retry: true
      - ship

  saas-hotfix:
    description: "Emergency production fix"
    steps:
      - debug
      - fix
      - verify
      - ship
```

Invoke with:
```
/godmode --chain saas-feature
/godmode --chain saas-hotfix
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [API Feature Example](../examples/api-feature.md) — Single feature walkthrough
- [Incident Response Recipe](incident-response.md) — When things break
