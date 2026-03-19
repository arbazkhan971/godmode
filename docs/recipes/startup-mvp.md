# Recipe: Build an MVP in a Weekend

> From idea to deployed MVP using Godmode. Ship something real in 48 hours.

---

## Context

You have a startup idea and a weekend. You need a working product — not a prototype, not a wireframe, but something users can sign up for, use, and give feedback on. Godmode compresses the typical 2-4 week MVP sprint into a focused weekend by automating the tedious parts and keeping you on the critical path.

## The Chain

```
think → scaffold → schema → api → ui → auth → deploy → ship
```

## Technology Recommendations for Speed

Choose boring technology. The fastest path to an MVP is the stack with the fewest unknowns.

| Layer | Recommendation | Why |
|-------|---------------|-----|
| Frontend | Next.js (App Router) | Full-stack in one framework, Vercel deploys in seconds |
| Backend | Next.js API routes or Hono | No separate server to manage |
| Database | PostgreSQL via Supabase or Neon | Managed, free tier, instant provisioning |
| ORM | Prisma or Drizzle | Type-safe, fast schema iteration |
| Auth | NextAuth.js or Clerk | Drop-in authentication, OAuth in minutes |
| Payments | Stripe | If you need payments, nothing else is close |
| Hosting | Vercel or Railway | Git push to deploy, zero DevOps |
| Styling | Tailwind CSS + shadcn/ui | Pre-built components, no design skills needed |

**Alternative fast stacks:**
- **Python:** FastAPI + SQLAlchemy + Jinja2 + Railway
- **Rails:** Ruby on Rails + Heroku (the original MVP stack)
- **Go:** Go + HTMX + SQLite + Fly.io (for performance-critical MVPs)

---

## Session Transcript

### Phase 1: Think (Saturday Morning, 9:00 AM)

Define the problem, not the solution.

```
> /godmode:think I want to build a SaaS tool that helps freelancers
  track their time and generate invoices automatically. I want to
  ship an MVP this weekend.

Godmode: Researching the problem space...

One question: What's the single workflow a freelancer MUST complete
for this to be useful? Time tracking? Invoice generation? Client management?

> The core loop is: track time on a project → generate an invoice
  from tracked time → send it to the client.

Godmode: Focusing on the core loop. Here's the minimal spec...

MVP SCOPE:
  Core: Time tracking → Invoice generation → Send to client
  Users: Freelancers (single-user, no teams for MVP)
  Auth: Email/password + Google OAuth
  Monetization: Free for MVP (add Stripe later)

  IN SCOPE:
  - Start/stop timer on a project
  - Manual time entry
  - Project list with client assignment
  - Generate PDF invoice from tracked time
  - Send invoice via email
  - Dashboard showing hours this week

  OUT OF SCOPE (post-MVP):
  - Team features
  - Recurring invoices
  - Payment tracking
  - Expense tracking
  - Multiple currencies
  - Mobile app

Saved: docs/specs/time-tracker-mvp.md
Commit: "spec: time-tracker MVP — track time, generate invoices, send to clients"
```

**Time: 20 minutes.** The most important 20 minutes of the weekend.

### Phase 2: Scaffold (Saturday Morning, 9:30 AM)

Generate the project skeleton with production-ready defaults.

```
> /godmode:scaffold --stack nextjs --db postgres --auth nextauth

Godmode: Scaffolding project...

Created:
  /app                     # Next.js App Router pages
    /layout.tsx            # Root layout with providers
    /page.tsx              # Landing page
    /dashboard/page.tsx    # Main dashboard
    /api/                  # API routes
  /components              # Reusable UI components
    /ui/                   # shadcn/ui components
  /lib                     # Shared utilities
    /db.ts                 # Prisma client
    /auth.ts               # NextAuth config
  /prisma
    /schema.prisma         # Database schema
  /.env.example            # Environment variables template
  /tailwind.config.ts      # Tailwind configuration

Dependencies installed:
  next, react, prisma, @prisma/client, next-auth,
  tailwindcss, @radix-ui/*, lucide-react, zod

Dev server running: http://localhost:3000

Commit: "scaffold: Next.js + Prisma + NextAuth + Tailwind + shadcn"
```

**Time: 5 minutes.**

### Phase 3: Schema (Saturday Morning, 9:40 AM)

Design the database schema from the spec.

```
> /godmode:schema

Godmode: Reading spec... Designing schema...

SCHEMA DESIGN:
  User       — id, email, name, avatar, createdAt
  Client     — id, userId, name, email, address, rate
  Project    — id, userId, clientId, name, color, hourlyRate, archived
  TimeEntry  — id, userId, projectId, startedAt, stoppedAt, duration, note
  Invoice    — id, userId, clientId, number, status, issuedAt, dueAt, total
  InvoiceItem — id, invoiceId, timeEntryId, description, hours, rate, amount

Relationships:
  User 1:N Client, Project, TimeEntry, Invoice
  Client 1:N Project, Invoice
  Project 1:N TimeEntry
  Invoice 1:N InvoiceItem
  TimeEntry 1:1 InvoiceItem (optional)

Indexes:
  TimeEntry(userId, startedAt)   — dashboard queries
  Invoice(userId, status)        — invoice listing
  Project(userId, archived)      — active project list

Migration created and applied.

Commit: "schema: User, Client, Project, TimeEntry, Invoice models"
```

**Time: 10 minutes.**

### Phase 4: API (Saturday Morning, 10:00 AM)

Build the API endpoints from the schema.

```
> /godmode:api --type rest

Godmode: Reading schema... Designing API...

API DESIGN:
  POST   /api/timer/start         — Start timer on project
  POST   /api/timer/stop          — Stop current timer
  GET    /api/timer/current       — Get running timer
  POST   /api/time-entries        — Manual time entry
  GET    /api/time-entries        — List time entries (filterable)
  CRUD   /api/projects            — Project management
  CRUD   /api/clients             — Client management
  POST   /api/invoices/generate   — Generate invoice from time entries
  POST   /api/invoices/:id/send   — Send invoice via email
  GET    /api/invoices            — List invoices
  GET    /api/dashboard/summary   — Dashboard stats

Validation: Zod schemas for all inputs
Auth: NextAuth session check on all endpoints
Errors: Consistent error format with status codes

Implementing with TDD...
  10 endpoints created, 22 tests passing

Commit: "api: REST endpoints for timer, entries, projects, clients, invoices"
```

**Time: 30 minutes.**

### Phase 5: UI (Saturday Afternoon, 11:00 AM)

Build the user interface from the API.

```
> /godmode:ui

Godmode: Reading API spec... Building UI...

PAGES:
  /                — Landing page (marketing)
  /dashboard       — Timer + hours this week + recent activity
  /projects        — Project list with CRUD
  /clients         — Client list with CRUD
  /time            — Time entries table with filters
  /invoices        — Invoice list with status badges
  /invoices/new    — Invoice generator (select time entries → preview → send)

COMPONENTS:
  TimerWidget      — Start/stop button, running clock, project selector
  TimeEntryTable   — Sortable, filterable table of time entries
  InvoicePreview   — PDF-style preview of invoice before sending
  DashboardStats   — Hours this week, earnings, active projects

Using shadcn/ui: Button, Card, Table, Dialog, Select, Badge, Calendar

Building...
  7 pages, 12 components, responsive design
  Dark mode support via next-themes

Commit: "ui: dashboard, projects, clients, time entries, invoices"
```

**Time: 90 minutes.** This is the longest phase. The UI is what users see.

### Phase 6: Auth (Saturday Afternoon, 1:00 PM)

Add authentication and protect all routes.

```
> /godmode:auth

Godmode: Configuring authentication...

AUTH SETUP:
  Provider: NextAuth.js v5
  Methods: Email/password + Google OAuth
  Session: JWT (no database sessions for speed)
  Protection: Middleware on /dashboard/*, /api/*

  Pages created:
    /login        — Sign in form (email + Google button)
    /register     — Sign up form
    /auth/error   — Auth error page

  Middleware: src/middleware.ts
    - Redirects unauthenticated users to /login
    - Passes session to API routes

  Security:
    - CSRF protection (built into NextAuth)
    - Rate limiting on auth endpoints
    - Password hashing with bcrypt

Commit: "auth: NextAuth with email/password + Google OAuth"
```

**Time: 20 minutes.**

### Phase 7: Deploy (Saturday Afternoon, 2:00 PM)

Deploy to production.

```
> /godmode:deploy --target vercel

Godmode: Preparing deployment...

DEPLOYMENT:
  Platform: Vercel
  Database: Neon PostgreSQL (provisioned)
  Domain: timetracker.vercel.app (temporary)

  Environment variables set:
    DATABASE_URL          — Neon connection string
    NEXTAUTH_SECRET       — Generated secure random
    NEXTAUTH_URL          — https://timetracker.vercel.app
    GOOGLE_CLIENT_ID      — From .env.local
    GOOGLE_CLIENT_SECRET  — From .env.local

  Build: ✓ successful
  Deploy: ✓ live at https://timetracker.vercel.app

  Database migration applied to production.

Commit: "deploy: Vercel + Neon PostgreSQL configuration"
```

**Time: 15 minutes.**

### Phase 8: Ship (Saturday Afternoon, 2:30 PM)

Verify everything works in production.

```
> /godmode:ship --verify

Godmode: Running production verification...

PRODUCTION CHECKS:
  ✓ Landing page loads (< 1.5s)
  ✓ Registration flow works
  ✓ Login flow works (email + Google)
  ✓ Timer start/stop functional
  ✓ Manual time entry works
  ✓ Project CRUD works
  ✓ Client CRUD works
  ✓ Invoice generation works
  ✓ Invoice email sends (via Resend)
  ✓ Dashboard stats accurate
  ✓ Responsive on mobile viewport
  ✓ HTTPS working
  ✓ No console errors

SHIP STATUS: ✓ MVP IS LIVE
URL: https://timetracker.vercel.app

Total time: 5 hours 30 minutes
```

---

## Weekend Schedule

### Saturday

| Time | Phase | Duration | What |
|------|-------|----------|------|
| 9:00 | think | 20 min | Define MVP scope, write spec |
| 9:30 | scaffold | 5 min | Generate project skeleton |
| 9:40 | schema | 10 min | Design and apply database schema |
| 10:00 | api | 30 min | Build API endpoints with tests |
| 10:30 | Break | 30 min | Step away from the screen |
| 11:00 | ui | 90 min | Build all pages and components |
| 12:30 | Lunch | 30 min | Eat something real |
| 1:00 | auth | 20 min | Add authentication |
| 1:30 | deploy | 15 min | Deploy to production |
| 2:00 | ship | 30 min | Verify, fix issues, ship |
| 2:30 | Done | -- | MVP is live |

### Sunday

Use Sunday for what matters most: getting feedback, not adding features.

| Time | Activity | Godmode |
|------|----------|---------|
| Morning | Share with 5-10 potential users | -- |
| Afternoon | Collect feedback, prioritize | `/godmode:think` on feedback |
| Evening | Fix top 1-2 issues from feedback | `/godmode:fix` + `/godmode:ship` |

---

## Rules for Weekend MVPs

### 1. Cut scope ruthlessly
If a feature is not in the core loop (track time → invoice → send), it is out of scope. No exceptions. You can add it Monday.

### 2. Use managed services
Do not set up your own database server. Do not configure nginx. Do not write a custom auth system. Use Supabase, Clerk, Vercel, Railway. Pay the $0-20/month and save 8 hours.

### 3. Start with the hardest part
The hardest part is usually the core user workflow — in this case, the timer and invoice generation. Build that first. If the hard part doesn't work, the easy parts don't matter.

### 4. Deploy early, deploy often
Deploy after scaffold (Phase 2). Every subsequent phase deploys automatically via git push. You should be testing in production by Saturday afternoon.

### 5. Do not optimize
No caching. No CDN configuration. No database indexing beyond what Prisma creates. No performance profiling. The MVP serves 10 users. Optimization is a Week 2 problem.

### 6. Ship ugly
The landing page can be one screen. The dashboard can be plain. The invoice PDF can be basic. Ship it. Beautiful comes after useful.

---

## Extending the MVP (Week 2 and Beyond)

Once users are giving feedback, use Godmode to iterate:

```
# Add Stripe payments
/godmode:think "Add subscription billing with Stripe"
/godmode:plan → /godmode:build → /godmode:ship

# Improve performance after getting real users
/godmode:optimize --goal "reduce dashboard load time" --target "< 500ms"

# Add security before launch
/godmode:secure

# Add a mobile-friendly PWA
/godmode:think "Convert to PWA with offline time tracking"
```

---

## See Also

- [Getting Started](../getting-started.md) — First-time Godmode walkthrough
- [Skill Chains](../skill-chains.md) — All chain patterns
- [Building a Mobile App](mobile-app.md) — If you need native mobile
- [Building an API Gateway](api-gateway.md) — If your MVP is API-first
