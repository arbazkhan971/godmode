# Vercel / Next.js Developer Guide

How to use Godmode's full skill set to build, deploy, and optimize full-stack Next.js applications on Vercel.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Vercel via vercel.json, next.config.js, or .vercel/ directory
```

### Example `.godmode/config.yaml`
```yaml
platform: vercel
framework: nextjs                # or remix, nuxt, sveltekit, astro
deploy_target: vercel
test_command: npm test
lint_command: npx next lint
build_command: npx next build
verify_command: curl -s -o /dev/null -w '%{http_code}' https://my-app.vercel.app/api/health
edge_runtime: true               # enable Edge Runtime guidance
```

---

## Full-Stack Next.js with Godmode

### Skill-to-Feature Mapping

| Next.js Feature | Godmode Skills | How They Work Together |
|-----------------|---------------|----------------------|
| **App Router** | `scaffold`, `plan`, `build` | `/godmode:scaffold` generates route groups, layouts, loading states, and error boundaries using the App Router conventions. `/godmode:plan` decomposes features into server components, client components, and API routes. |
| **Server Components** | `build`, `optimize`, `review` | `/godmode:build` implements React Server Components with proper data fetching patterns. `/godmode:optimize` ensures minimal client-side JavaScript by maximizing server component usage. `/godmode:review` checks for accidental client bundle bloat. |
| **Server Actions** | `build`, `secure`, `test` | `/godmode:build` creates type-safe server actions with Zod validation. `/godmode:secure` audits server actions for authorization checks and input validation. `/godmode:test` writes tests for server action logic. |
| **Route Handlers** | `api`, `build`, `test` | `/godmode:api` designs RESTful route handlers with proper HTTP methods, status codes, and error handling. `/godmode:build` implements handlers with streaming responses. `/godmode:test` writes integration tests for route handlers. |
| **Middleware** | `build`, `secure`, `optimize` | `/godmode:build` creates Edge Middleware for auth checks, redirects, A/B testing, and geolocation routing. `/godmode:secure` ensures middleware runs auth validation before page rendering. `/godmode:optimize` keeps middleware lightweight for sub-millisecond execution. |

### Data Fetching Patterns

```bash
/godmode:think "Design data fetching strategy for Next.js e-commerce app"

# Godmode recommends per-route strategy:
# - Product catalog:   ISR with 60s revalidation (semi-static, high traffic)
# - Product detail:    ISR with on-demand revalidation via webhook
# - Shopping cart:     Client-side with SWR/React Query (user-specific, real-time)
# - Checkout:          Server Component with no-store (always fresh)
# - Admin dashboard:   Server Component with dynamic rendering
# - Marketing pages:   Static generation at build time
```

---

## Edge Functions

### Edge Runtime with Godmode

```bash
/godmode:build "Create Edge middleware for geo-based routing and A/B testing"

# Godmode produces:
# - middleware.ts with Edge Runtime
# - Geolocation-based content routing
# - Cookie-based A/B test bucketing
# - Rate limiting with Edge Config
# - Bot detection and blocking
```

### Edge Function Patterns

| Pattern | Use Case | Godmode Implementation |
|---------|----------|----------------------|
| **Auth Gate** | Protect routes at the edge | Middleware validates JWT, redirects to login if invalid. No origin round-trip for unauthorized requests. |
| **A/B Testing** | Feature flag evaluation at edge | Middleware reads experiment config from Edge Config, assigns user to variant via cookie, rewrites to variant page. |
| **Geolocation** | Region-specific content | Middleware reads `request.geo`, sets locale cookie, rewrites to localized content path. |
| **Rate Limiting** | API protection | Middleware tracks request counts in Vercel KV, returns 429 when threshold exceeded. |
| **Bot Protection** | Block scrapers | Middleware checks User-Agent, challenge suspicious requests, allow verified bots (Googlebot, etc.). |

### Edge vs. Serverless Decision

```bash
/godmode:optimize "Analyze which functions should run at edge vs. serverless"

# Godmode decision matrix:
# ┌──────────────────────┬──────────────┬──────────────┐
# │ Criteria             │ Edge Runtime │ Node Runtime │
# ├──────────────────────┼──────────────┼──────────────┤
# │ Cold start           │ ~0ms         │ 250ms+       │
# │ Execution limit      │ 25ms (hobby) │ 60s          │
# │ Max size             │ 1MB          │ 50MB         │
# │ Node APIs            │ Subset       │ Full         │
# │ npm packages         │ Edge-compat  │ All          │
# │ Database access      │ HTTP-based   │ TCP/HTTP     │
# │ Global distribution  │ All regions  │ 1 region     │
# └──────────────────────┴──────────────┴──────────────┘
```

---

## Serverless Functions

### API Design with `/godmode:api`

```bash
/godmode:api "Design REST API routes for SaaS application"

# Godmode produces:
# - app/api/auth/[...nextauth]/route.ts   — NextAuth.js handlers
# - app/api/users/route.ts                — GET (list), POST (create)
# - app/api/users/[id]/route.ts           — GET, PATCH, DELETE
# - app/api/webhooks/stripe/route.ts      — Stripe webhook handler
# - app/api/cron/daily-digest/route.ts    — Cron job (vercel.json scheduled)
# - lib/api/middleware.ts                  — Auth, rate limit, error handling
# - lib/api/validation.ts                 — Zod schemas for request bodies
```

### Serverless Optimization

```bash
/godmode:optimize "Reduce serverless cold starts and execution time"

# Godmode checks:
# - Bundle size per route (target < 1MB compressed)
# - Dynamic imports to reduce initial load
# - Connection pooling for databases (Prisma Data Proxy, Neon serverless driver)
# - Caching headers for cacheable responses
# - Edge Runtime eligibility for lightweight handlers
# - Streaming responses for large payloads
```

---

## ISR (Incremental Static Regeneration)

### ISR Patterns

```bash
/godmode:optimize "Implement ISR strategy for content-heavy application"

# Godmode produces:
# - Time-based ISR:
#     export const revalidate = 60  // revalidate every 60 seconds
#
# - On-demand ISR:
#     app/api/revalidate/route.ts  // webhook endpoint
#     revalidatePath('/blog/[slug]')
#     revalidateTag('blog-posts')
#
# - Tag-based revalidation:
#     fetch(url, { next: { tags: ['blog-posts'] } })
#     // CMS webhook triggers revalidateTag('blog-posts')
```

### ISR Decision Matrix

| Content Type | Strategy | Revalidation | Godmode Config |
|-------------|----------|-------------|----------------|
| Marketing pages | Static | On deploy | `export const dynamic = 'force-static'` |
| Blog posts | ISR | On-demand via CMS webhook | `revalidateTag('posts')` on webhook |
| Product pages | ISR | Time-based (60s) + on-demand | `revalidate = 60` + webhook |
| User dashboard | Dynamic | No cache | `export const dynamic = 'force-dynamic'` |
| API responses | Stale-while-revalidate | CDN cache | `Cache-Control: s-maxage=60, stale-while-revalidate=300` |

---

## Vercel Deployment with `/godmode:deploy`

### Deployment Workflow

```bash
/godmode:deploy --target vercel

# Godmode handles:
# 1. Pre-deploy checks:
#    - Build succeeds locally (next build)
#    - All tests pass
#    - TypeScript compiles with no errors
#    - Lint passes with zero warnings
#    - Bundle size within budget
#
# 2. Deployment:
#    - Preview deployment for PRs
#    - Production deployment on merge to main
#    - Automatic rollback on failed health check
#
# 3. Post-deploy verification:
#    - Smoke tests against preview/production URL
#    - Lighthouse CI performance check
#    - Core Web Vitals validation
```

### Environment Configuration

```bash
/godmode:config "Manage Vercel environment variables and feature flags"

# Godmode manages:
# - Environment variables per deployment target (Production, Preview, Development)
# - Edge Config for feature flags and A/B tests
# - Vercel KV for rate limiting and session data
# - Vercel Postgres for application data
# - Vercel Blob for file storage
```

### Preview Deployments

```bash
/godmode:deploy "Configure preview deployment strategy"

# Godmode produces:
# - vercel.json with git integration settings
# - Preview deployments for every PR
# - Comment bot with deployment URL on PR
# - Protected production branch (main only)
# - Deployment protection with Vercel Authentication
```

### Monorepo Deployment

```bash
/godmode:deploy "Configure Vercel monorepo with Turborepo"

# Godmode produces:
# - turbo.json with pipeline configuration
# - vercel.json per deployable app
# - Shared packages (ui, config, tsconfig)
# - Remote caching with Vercel
# - Filtered builds (only deploy changed apps)
```

---

## Performance Optimization

### Core Web Vitals with `/godmode:webperf`

```bash
/godmode:webperf "Optimize Core Web Vitals for Next.js application"

# Godmode analyzes and optimizes:
# ┌──────────┬───────────────────────────────────────────────────┐
# │ Metric   │ Optimization                                     │
# ├──────────┼───────────────────────────────────────────────────┤
# │ LCP      │ next/image with priority, preload critical fonts, │
# │          │ streaming SSR, server component data fetching     │
# ├──────────┼───────────────────────────────────────────────────┤
# │ FID/INP  │ Minimize client JS, React.lazy for heavy         │
# │          │ components, useTransition for non-urgent updates  │
# ├──────────┼───────────────────────────────────────────────────┤
# │ CLS      │ Explicit image dimensions, font-display: swap    │
# │          │ with size-adjust, skeleton loaders                │
# └──────────┴───────────────────────────────────────────────────┘
```

### Bundle Analysis

```bash
/godmode:optimize "Analyze and reduce Next.js bundle size"

# Godmode checks:
# - @next/bundle-analyzer output per route
# - Shared chunks that should be split
# - Large dependencies with lighter alternatives
# - Tree-shaking effectiveness
# - Dynamic imports for below-fold components
# - next/dynamic with ssr: false for client-only libraries
```

### Image Optimization

```bash
/godmode:optimize "Optimize images for Next.js application"

# Godmode produces:
# - next/image component usage with proper sizing
# - Responsive image srcsets via sizes prop
# - Priority loading for above-fold images
# - Lazy loading for below-fold images
# - Blur placeholder data URLs for perceived performance
# - Remote image domain configuration in next.config.js
```

### Caching Strategy

```bash
/godmode:optimize "Design caching strategy for Vercel deployment"

# Godmode produces:
# ┌─────────────────┬────────────────────────────────────────────┐
# │ Cache Layer      │ Strategy                                  │
# ├─────────────────┼────────────────────────────────────────────┤
# │ Vercel Edge      │ Full-route cache for ISR pages            │
# │ Data Cache       │ fetch() cache with revalidation tags      │
# │ Router Cache     │ Client-side cache for navigation          │
# │ React Cache      │ Request-level deduplication               │
# │ CDN Headers      │ s-maxage + stale-while-revalidate         │
# │ Browser Cache    │ Immutable hashed assets, versioned APIs   │
# └─────────────────┴────────────────────────────────────────────┘
```

---

## Testing on Vercel

```bash
/godmode:test "Set up testing strategy for Next.js App Router"
```

| Test Type | Tool | What Godmode Generates |
|-----------|------|----------------------|
| **Unit** | Vitest / Jest | Tests for server actions, utility functions, and hooks |
| **Component** | React Testing Library | Tests for server and client components with proper mocking |
| **Integration** | Playwright | Tests for full page flows including navigation and data fetching |
| **E2E** | Playwright | Tests against preview deployments on Vercel |
| **Visual** | Playwright + Percy | Screenshot tests for UI components across viewports |
| **Performance** | Lighthouse CI | Core Web Vitals assertions in CI pipeline |

---

## Security on Vercel

```bash
/godmode:secure "Security audit for Next.js application on Vercel"
```

**What Godmode checks:**
- Server actions validate authorization and input (Zod schemas)
- Route handlers check authentication before processing
- Middleware enforces CSP, CORS, and security headers
- Environment variables not leaked to client bundle (no `NEXT_PUBLIC_` for secrets)
- API routes protected against CSRF
- File uploads validated for type and size
- Rate limiting on authentication endpoints
- Vercel Firewall rules configured

---

## Quick Reference

| Task | Command |
|------|---------|
| Scaffold Next.js feature | `/godmode:scaffold "App Router route for <feature>"` |
| Deploy to Vercel | `/godmode:deploy --target vercel` |
| Optimize performance | `/godmode:webperf "Core Web Vitals for <route>"` |
| Bundle analysis | `/godmode:optimize "Reduce bundle size"` |
| Security audit | `/godmode:secure "Next.js security review"` |
| API design | `/godmode:api "Route handlers for <feature>"` |
| Testing strategy | `/godmode:test "Next.js App Router tests"` |
| ISR configuration | `/godmode:optimize "ISR strategy for <content>"` |
| Edge functions | `/godmode:build "Edge middleware for <pattern>"` |
| Monorepo setup | `/godmode:infra "Turborepo + Vercel monorepo"` |
