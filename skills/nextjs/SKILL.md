---
name: nextjs
description: |
  Next.js mastery skill. Activates when building, architecting, or optimizing Next.js applications. Covers App Router architecture (layouts, loading states, error boundaries), Server Components vs Client Components decision-making, data fetching patterns (server actions, revalidation, caching), middleware and route handlers, rendering strategies (ISR, SSG, SSR, streaming), and asset optimization (images, fonts, scripts). Every recommendation includes concrete code and performance rationale. Triggers on: /godmode:nextjs, "Next.js", "App Router", "Server Components", "server actions", "ISR", "SSG", "SSR", "next/image", "middleware".
---

# Next.js — Next.js Mastery

## When to Activate
- User invokes `/godmode:nextjs`
- User says "Next.js", "App Router", "Pages Router", "Server Components", "Client Components", "server actions"
- User asks about "ISR", "SSG", "SSR", "streaming", "revalidation", "next/image", "middleware"
- When `/godmode:plan` identifies a Next.js project or `/godmode:review` flags Next.js issues

## Workflow

### Step 1: Project Assessment
```
NEXT.JS PROJECT ASSESSMENT:
Project: <name and purpose>
Router: App Router | Pages Router | Migration
Version: <13, 14, 15+>
Rendering needs: <mostly static | mostly dynamic | mixed>
Data sources: <databases, APIs, CMS>
Auth model: <NextAuth, Clerk, Supabase Auth, custom>
Deployment target: <Vercel, self-hosted, Docker>
```

If unspecified, ask: "Are you using the App Router or Pages Router? What's your deployment target?"

### Step 2: App Router Architecture
```
app/
├── layout.tsx              # Root layout (metadata, providers, fonts)
├── loading.tsx / error.tsx / not-found.tsx / global-error.tsx
├── (marketing)/            # Route group — no URL segment
│   ├── layout.tsx, page.tsx (/), about/page.tsx, pricing/page.tsx
├── (app)/                  # Authenticated app group
│   ├── layout.tsx (sidebar, nav)
│   ├── dashboard/ (page, loading, error)
│   ├── [workspace]/ (dynamic segment, layout, [...slug]/)
├── api/ (route handlers: auth, webhooks, tRPC)
└── sitemap.ts
```

Rules: Route groups `(name)` organize without affecting URLs. Every segment can have `layout.tsx`, `loading.tsx`, `error.tsx`. `error.tsx` MUST be `'use client'`. `loading.tsx` creates automatic Suspense boundary. Use parallel routes `@slot` and intercepting routes `(.)` for modals.

### Step 3: Server vs Client Components

```
DECISION: Does this component need browser APIs, event handlers, useState/useEffect, useContext, or hooks using these?
  YES → 'use client'   NO → Keep as Server Component (default)

PATTERNS:
1. Push 'use client' to leaves — server page fetches data, passes to client interactive component
2. Composition with children — client wrapper receives server content as children
3. Context provider at boundary — 'use client' providers.tsx wraps children in server layout

ANTI-PATTERNS:
✗ 'use client' on page.tsx or layout.tsx — loses server-side data fetching, opts entire tree out
✗ Import server-only code in client components
✗ Pass non-serializable props (functions, classes) from server to client
```

### Step 4: Data Fetching Patterns

```
Pattern 1 — Server Component fetch (default): async function in component, deduplicated with cache()
Pattern 2 — Server Actions (mutations): 'use server', revalidatePath/revalidateTag, works in forms without JS
Pattern 3 — Revalidation: time-based (revalidate: N), on-demand (revalidatePath/revalidateTag), no-cache (cache: 'no-store')
Pattern 4 — Parallel: Promise.all for concurrent, Suspense boundaries for streaming

DECISION TABLE:
  Read data → Server Component async fetch
  Mutate data → Server Action
  Real-time → Client fetch + SWR/React Query
  User-specific → Server Component + cookies()
  Form submission → Server Action + useActionState
```

### Step 5: Middleware Design
Middleware runs at the Edge on every matched request. Keep it fast (auth redirects, A/B routing, geo detection). Use matcher to limit routes. Cannot modify response body. For complex auth, delegate to route handlers or server components.

### Step 6: Rendering Strategy

```
Static (SSG): Content rarely changes. Default, generateStaticParams().
ISR: Changes periodically. revalidate: <seconds>.
SSR: Every request needs fresh data. dynamic='force-dynamic', cookies(), headers().
Streaming SSR: Slow data sources. <Suspense> boundaries, loading.tsx.
Client: Highly interactive, real-time. 'use client' + SWR/React Query.

FLOW: Can it be static? → SSG. Refresh periodically? → ISR. Per-request? → SSR. Slow parts? → Streaming. Real-time? → Client in server shell.
```

### Step 7: Image, Font & Script Optimization

```
next/image: Use priority on LCP images only. Always provide sizes. Use fill for unknown dimensions. placeholder="blur".
next/font: Self-hosted automatically. Use variable for Tailwind. display: 'swap'.
next/script: beforeInteractive (theme, rare), afterInteractive (analytics, default), lazyOnload (widgets).
```

### Step 8: Route Handlers
Route handlers in `app/api/` for webhooks, external API consumption, streaming. Prefer Server Actions for mutations from your own UI. Supports GET/POST/PUT/PATCH/DELETE/HEAD/OPTIONS. GET is cached by default.

### Step 9: Validation Audit
```
NEXT.JS AUDIT:
[ ] App Router used                    [ ] 'use client' pushed to leaves
[ ] No 'use client' on pages/layouts   [ ] Server Actions for mutations
[ ] Parallel data fetching             [ ] Caching/revalidation strategy set
[ ] loading.tsx for slow routes        [ ] error.tsx for error boundaries
[ ] next/image for all images          [ ] next/font for fonts
[ ] Metadata API used (not manual <head>)  [ ] Bundle size analyzed
VERDICT: PASS | NEEDS REVISION
```

### Step 10: Deliverables
```
NEXT.JS COMPLETE:
Routes: <N> total (<SSG/ISR/SSR/Streaming counts>)
Components: <N> Server, <M> Client
Audit: PASS | NEEDS REVISION
```
Commit: `"nextjs: <project> — App Router architecture, <N> routes, <rendering strategy>"`

## Key Behaviors

1. **App Router first.** Always for new projects. Pages Router only for legacy.
2. **Server Components by default.** Push `'use client'` to smallest leaf.
3. **Fetch where you render.** Data fetching in the component that displays it.
4. **Cache aggressively, revalidate precisely.** ISR + cache tags. `no-store` is last resort.
5. **Streaming over waterfalls.** Suspense boundaries for slow content.
6. **Optimize critical path.** `priority` on LCP images, `next/font`, `afterInteractive` for analytics.
7. **Middleware is for routing, not logic.** Keep thin — auth redirects, A/B, geo.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full architecture workflow |
| `--audit` | Audit existing project |
| `--migrate` | Pages Router to App Router |
| `--routes` | Route structure only |
| `--data` | Data fetching strategy only |
| `--optimize` | Image, font, script, bundle optimization |
| `--middleware` | Middleware configuration |
| `--api` | Route handlers and API layer |
| `--deploy <target>` | Configure for deployment target |

## Auto-Detection
```
Detect: next.config.js/mjs/ts, app/ vs pages/ directory, page count, package.json "next" dep.
Warn: 'use client' on page.tsx/layout.tsx, useEffect+fetch in Server Component context.
```

## HARD RULES

1. NEVER add 'use client' to page.tsx or layout.tsx.
2. NEVER use useEffect+fetch when Server Component async fetch works.
3. NEVER create API routes to fetch data for your own UI. Server Components query directly.
4. EVERY route with data fetching MUST have loading.tsx.
5. ALWAYS use next/image with sizes prop for responsive images.
6. ALWAYS use Metadata API instead of manual `<head>` tags.
7. NEVER put heavy JavaScript in middleware. Keep under 1MB.
8. ALWAYS use parallel data fetching (Promise.all or Suspense).

## Iterative Route Build Protocol
```
FOR EACH route: create page + rendering strategy, implement data fetching + loading/error boundaries,
push 'use client' to leaves, audit. Every 5 routes: run build.
POST-LOOP: Full audit, report counts, measure build time + bundle size + Lighthouse.
```

## Multi-Agent Dispatch
```
Agent 1 — marketing-routes: (marketing)/ group, SSG/ISR, SEO metadata
Agent 2 — app-routes: (app)/ group, SSR + auth, Server Actions
Agent 3 — api-layer: route handlers, webhooks, tRPC/REST
Agent 4 — shared-components: UI, providers, image/font/script optimization
MERGE: Verify layouts, no 'use client' on pages, full build, Lighthouse.
```

## Output Format
```
NEXT.JS COMPLETE:
Project: <name>
Routes: <N> total (<N> SSG, <N> ISR, <N> SSR, <N> streaming)
Components: <N> Server, <M> Client
Audit: PASS | NEEDS REVISION
Duration: <time>
```

## TSV Logging
Append to `.godmode/nextjs-results.tsv`:
`timestamp	project	action	routes_count	server_components	client_components	audit_status	notes`

## Success Criteria
1. `next build` zero errors. 2. No 'use client' on page.tsx/layout.tsx. 3. loading.tsx on data routes. 4. error.tsx on dynamic routes. 5. next/image with sizes. 6. Metadata API. 7. No useEffect+fetch where Server Component works. 8. Parallel data fetching. 9. Audit PASS.

## Error Recovery
```
Build fails → fix TypeScript errors, missing imports, invalid metadata.
'use client' on page/layout → extract interactive elements to client component files.
Hydration mismatch → wrap browser-only code in useEffect or dynamic(ssr:false).
Server Action fails → check 'use server', verify serializable args, add try/catch.
Middleware redirect loops → check matcher exclusions, verify target not matching condition.
```

## Keep/Discard Discipline
```
KEEP if TTFB improved AND build passes AND no 'use client' on page/layout.
DISCARD if TTFB worsened OR build failed OR content freshness degraded.
Never measure TTFB in dev mode.
```

## Stop Conditions
```
STOP when: All routes TTFB < 200ms (p75) AND client JS < 150KB gzipped
  AND all 'use client' at leaf level AND rendering strategy matches data needs
  OR user requests stop OR max 8 iterations reached
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.
