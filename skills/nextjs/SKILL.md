---
name: nextjs
description: Next.js mastery -- App Router, Server Components,
  data fetching, rendering strategies, optimization.
---

## Activate When
- `/godmode:nextjs`, "Next.js", "App Router"
- "Server Components", "server actions", "ISR"
- "SSG", "SSR", "next/image", "middleware"

## Workflow

### 1. Project Assessment
```bash
cat next.config.* 2>/dev/null
ls app/ pages/ 2>/dev/null
grep "next" package.json 2>/dev/null
```
```
Router: App Router | Pages Router | Migration
Version: 13 | 14 | 15+
Rendering: mostly static | mostly dynamic | mixed
Auth: NextAuth | Clerk | Supabase Auth | custom
Deploy: Vercel | self-hosted | Docker
```

### 2. App Router Architecture
```
app/
  layout.tsx          # Root (metadata, providers)
  loading.tsx / error.tsx / not-found.tsx
  (marketing)/        # Route group (no URL segment)
    page.tsx, about/, pricing/
  (app)/              # Authenticated app group
    layout.tsx (sidebar, nav)
    dashboard/ (page, loading, error)
    [workspace]/ (dynamic, [...slug]/)
  api/ (route handlers)
```
Route groups `(name)` organize without URL impact.
Every segment: layout, loading, error optional.
Mark `error.tsx` as `'use client'`.

### 3. Server vs Client Components
```
DECISION: needs browser APIs, event handlers,
  useState, useEffect, useContext?
  YES -> 'use client'
  NO  -> Server Component (default)

PATTERNS:
  Push 'use client' to leaf components
  Composition: client wrapper, server children
  Context provider at boundary

ANTI-PATTERNS:
  'use client' on page.tsx or layout.tsx
  Import server-only code in client components
  Non-serializable props server -> client
```

### 4. Data Fetching
- Server Component async fetch (default, deduplicated)
- Server Actions (mutations, `'use server'`)
- Revalidation: time-based, on-demand, no-cache
- Parallel: Promise.all + Suspense boundaries

Read data -> Server Component. Mutate -> Server Action.
Real-time -> Client fetch + SWR/React Query.

### 5. Rendering Strategy
```
SSG: static content. Default, generateStaticParams().
ISR: periodic refresh. revalidate: <seconds>.
SSR: fresh per request. force-dynamic, cookies().
Streaming: slow data. Suspense + loading.tsx.
Client: interactive/real-time. 'use client' + SWR.
```
IF can be static: SSG. IF periodic: ISR.
IF per-request: SSR. IF slow parts: Streaming.

### 6. Optimization
- next/image: `priority` on LCP only. Always `sizes`.
  `fill` for unknown dimensions. `placeholder="blur"`.
- next/font: self-hosted auto. `display: 'swap'`.
- next/script: afterInteractive (analytics, default).

### 7. Audit
```
[ ] App Router used
[ ] 'use client' pushed to leaves
[ ] No 'use client' on pages/layouts
[ ] Server Actions for mutations
[ ] Parallel data fetching
[ ] loading.tsx for data routes
[ ] error.tsx for dynamic routes
[ ] next/image with sizes prop
[ ] Metadata API (not manual <head>)
```

## Quality Targets
- Target: <200ms Time to First Byte (TTFB)
- Target: <100KB initial JS bundle per route
- Lighthouse performance score: >90

## Hard Rules
1. NEVER add 'use client' to page.tsx or layout.tsx.
2. NEVER useEffect+fetch when Server Component works.
3. NEVER create API routes for own UI data fetching.
4. EVERY data route MUST have loading.tsx.
5. ALWAYS use next/image with sizes prop.
6. ALWAYS use Metadata API (not manual `<head>`).
7. NEVER heavy JS in middleware (keep < 1MB).
8. ALWAYS parallel data fetching.

## TSV Logging
Append `.godmode/nextjs-results.tsv`:
```
timestamp	action	routes	server_components	client_components	audit	notes
```

## Keep/Discard
```
KEEP if: TTFB improved AND build passes
  AND no 'use client' on page/layout.
DISCARD if: TTFB worsened OR build failed.
Never measure TTFB in dev mode.
```

## Stop Conditions
```
STOP when ALL of:
  - All routes TTFB < 200ms (p75)
  - Client JS < 150KB gzipped
  - All 'use client' at leaf level
  - Rendering strategy matches data needs
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Build fails | Fix TS errors, missing imports |
| 'use client' on page | Extract interactive to leaf |
| Hydration mismatch | useEffect for client-only code |
| Server Action fails | Check 'use server', serializable args |
| Middleware loops | Check matcher exclusions |
