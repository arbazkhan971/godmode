---
name: nextjs
description: |
  Next.js mastery skill. Activates when building, architecting, or optimizing Next.js applications. Covers App Router architecture (layouts, loading states, error boundaries), Server Components vs Client Components decision-making, data fetching patterns (server actions, revalidation, caching), middleware and route handlers, rendering strategies (ISR, SSG, SSR, streaming), and asset optimization (images, fonts, scripts). Every recommendation includes concrete code and performance rationale. Triggers on: /godmode:nextjs, "Next.js", "App Router", "Server Components", "server actions", "ISR", "SSG", "SSR", "next/image", "middleware".
---

# Next.js — Next.js Mastery

## When to Activate
- User invokes `/godmode:nextjs`
- User says "Next.js", "build a Next.js app", "App Router", "Pages Router"
- User mentions "Server Components", "Client Components", "server actions"
- User asks about "ISR", "SSG", "SSR", "streaming", "revalidation"
- User mentions "next/image", "next/font", "next/script", "middleware"
- When `/godmode:plan` identifies a Next.js project
- When `/godmode:review` flags Next.js architecture issues

## Workflow

### Step 1: Project Assessment
Understand what the Next.js project needs before making any decisions:

```
NEXT.JS PROJECT ASSESSMENT:
Project: <name and purpose>
Router: App Router | Pages Router | Migration from Pages to App
Version: <Next.js version — 13, 14, 15+>
Rendering needs: <mostly static | mostly dynamic | mixed>
Data sources: <databases, APIs, CMS, external services>
Auth model: <NextAuth/Auth.js, Clerk, Supabase Auth, custom>
Deployment target: <Vercel, self-hosted, Docker, serverless>
Current pain points: <performance, complexity, data fetching, bundle size>
```

If the user hasn't specified, ask: "Are you using the App Router or Pages Router? What's your deployment target?"

### Step 2: App Router Architecture
Design the route structure using Next.js App Router conventions:

```
APP ROUTER ARCHITECTURE:
app/
├── layout.tsx              # Root layout — wraps entire app
│   ├── metadata            # Global metadata, viewport, icons
│   ├── providers           # Theme, auth, query client providers
│   └── fonts               # next/font initialization
├── loading.tsx             # Root loading UI (Suspense boundary)
├── error.tsx               # Root error boundary (client component)
├── not-found.tsx           # Global 404 page
├── global-error.tsx        # Catches root layout errors
│
├── (marketing)/            # Route group — no URL segment
│   ├── layout.tsx          # Marketing-specific layout
│   ├── page.tsx            # Home page (/)
│   ├── about/page.tsx      # /about
│   └── pricing/page.tsx    # /pricing
│
├── (app)/                  # Route group — authenticated app
│   ├── layout.tsx          # App layout with sidebar, nav
│   ├── dashboard/
│   │   ├── page.tsx        # /dashboard
│   │   ├── loading.tsx     # Dashboard skeleton
│   │   └── error.tsx       # Dashboard error boundary
│   ├── settings/
│   │   ├── page.tsx        # /settings
│   │   └── profile/
│   │       └── page.tsx    # /settings/profile
│   └── [workspace]/        # Dynamic segment
│       ├── page.tsx        # /[workspace]
│       ├── layout.tsx      # Workspace-scoped layout
│       └── [...slug]/      # Catch-all for nested routes
│           └── page.tsx
│
├── api/                    # Route Handlers (API routes)
│   ├── auth/[...nextauth]/
│   │   └── route.ts        # Auth.js catch-all
│   ├── webhooks/
│   │   └── stripe/
│   │       └── route.ts    # Webhook handler
│   └── trpc/[trpc]/
│       └── route.ts        # tRPC handler
│
└── sitemap.ts              # Dynamic sitemap generation
```

Rules:
- Route groups `(name)` organize without affecting URLs
- Every route segment can have its own `layout.tsx`, `loading.tsx`, `error.tsx`
- Layouts persist across navigations — do NOT put fetching logic in layouts that should refresh
- `loading.tsx` creates an automatic Suspense boundary
- `error.tsx` MUST be a client component (`'use client'`)
- Parallel routes `@slot` for simultaneous rendering of multiple pages
- Intercepting routes `(.)` `(..)` for modal patterns

### Step 3: Server Components vs Client Components
Apply the decision tree to determine component boundaries:

```
SERVER vs CLIENT COMPONENT DECISION TREE:

START: Does this component need...
│
├── Browser APIs (window, document, localStorage)?
│   └── YES → 'use client'
│
├── Event handlers (onClick, onChange, onSubmit)?
│   └── YES → 'use client'
│
├── React state (useState, useReducer)?
│   └── YES → 'use client'
│
├── React effects (useEffect, useLayoutEffect)?
│   └── YES → 'use client'
│
├── React context (useContext)?
│   └── YES → 'use client' (but consider provider pattern below)
│
├── Custom hooks that use any of the above?
│   └── YES → 'use client'
│
└── NONE of the above?
    └── Keep as Server Component (default)

COMPONENT BOUNDARY PATTERNS:

Pattern 1 — Push 'use client' to the leaves:
  // Server Component (page.tsx)
  export default async function Page() {
    const data = await getData()          // Server-side fetch
    return (
      <div>
        <h1>{data.title}</h1>             // Static — stays server
        <InteractiveChart data={data} />  // Client boundary here
      </div>
    )
  }

Pattern 2 — Composition with children:
  // Client Component (sidebar.tsx)
  'use client'
  export function Sidebar({ children }) {
    const [open, setOpen] = useState(true)
    return <aside className={open ? 'w-64' : 'w-16'}>{children}</aside>
  }
  // Server Component passes server content as children
  <Sidebar><ServerRenderedNav /></Sidebar>

Pattern 3 — Context provider at boundary:
  // providers.tsx ('use client')
  'use client'
  export function Providers({ children }) {
    return (
      <ThemeProvider><QueryProvider>{children}</QueryProvider></ThemeProvider>
    )
  }
  // layout.tsx (Server Component)
  export default function Layout({ children }) {
    return <Providers>{children}</Providers>
  }

ANTI-PATTERNS:
✗ Do NOT add 'use client' to page.tsx — you lose server-side data fetching
✗ Do NOT add 'use client' to layout.tsx — all children become client components
✗ Do NOT import server-only code in client components
✗ Do NOT pass non-serializable props (functions, classes) from server to client
```

### Step 4: Data Fetching Patterns
Design data fetching strategy based on the rendering needs:

```
DATA FETCHING PATTERNS:

Pattern 1 — Server Component fetch (RECOMMENDED default):
  // Fetch in the component that needs the data
  async function ProductPage({ params }) {
    const product = await db.product.findUnique({
      where: { id: params.id }
    })
    return <ProductDetails product={product} />
  }

  // Next.js deduplicates identical fetch() calls automatically
  // Use React cache() for non-fetch functions:
  const getUser = cache(async (id: string) => {
    return await db.user.findUnique({ where: { id } })
  })

Pattern 2 — Server Actions (mutations):
  // actions.ts
  'use server'
  export async function createPost(formData: FormData) {
    const title = formData.get('title')
    await db.post.create({ data: { title } })
    revalidatePath('/posts')              // Invalidate cache
    redirect('/posts')                     // Navigate after mutation
  }

  // Used in forms (works without JS):
  <form action={createPost}>
    <input name="title" />
    <button type="submit">Create</button>
  </form>

  // Used imperatively in client components:
  const [state, formAction] = useActionState(createPost, initialState)

Pattern 3 — Revalidation strategies:
  // Time-based revalidation (ISR):
  fetch(url, { next: { revalidate: 3600 } })  // Revalidate every hour

  // On-demand revalidation:
  revalidatePath('/posts')                // Revalidate specific path
  revalidateTag('posts')                  // Revalidate by cache tag
  fetch(url, { next: { tags: ['posts'] } })  // Tag a fetch for later invalidation

  // No caching:
  fetch(url, { cache: 'no-store' })       // Always fresh
  export const dynamic = 'force-dynamic'  // Entire route dynamic

Pattern 4 — Parallel data fetching:
  // GOOD — Parallel fetches
  async function Dashboard() {
    const [user, posts, analytics] = await Promise.all([
      getUser(),
      getPosts(),
      getAnalytics(),
    ])
    return <DashboardView user={user} posts={posts} analytics={analytics} />
  }

  // BETTER — Streaming with Suspense
  async function Dashboard() {
    const user = await getUser()  // Critical — await
    return (
      <>
        <Header user={user} />
        <Suspense fallback={<PostsSkeleton />}>
          <Posts />                {/* Streams in when ready */}
        </Suspense>
        <Suspense fallback={<AnalyticsSkeleton />}>
          <Analytics />           {/* Streams in independently */}
        </Suspense>
      </>
    )
  }

DATA FETCHING DECISION:
┌─────────────────────────────────────────────────────────────────┐
│ Need                          │ Pattern                         │
├───────────────────────────────┼─────────────────────────────────┤
│ Read data for display         │ Server Component async fetch    │
│ Mutate data (create/update)   │ Server Action                   │
│ Real-time updates             │ Client fetch + SWR/React Query  │
│ User-specific dynamic data    │ Server Component + cookies()    │
│ Expensive computation         │ Server Component + cache()      │
│ Third-party client SDK        │ Client Component                │
│ Form submission               │ Server Action + useActionState  │
└───────────────────────────────┴─────────────────────────────────┘
```

### Step 5: Middleware Design
Design middleware for cross-cutting concerns:

```
MIDDLEWARE DESIGN (middleware.ts at project root):

import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // PATTERN: Chain multiple middleware concerns
  const response = NextResponse.next()

  // 1. Authentication check
  const token = request.cookies.get('session')
  if (request.nextUrl.pathname.startsWith('/app') && !token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // 2. Geolocation-based routing
  const country = request.geo?.country || 'US'
  response.headers.set('x-user-country', country)

  // 3. A/B testing
  const bucket = request.cookies.get('ab-bucket')?.value
    || (Math.random() > 0.5 ? 'a' : 'b')
  response.cookies.set('ab-bucket', bucket)

  // 4. Rate limiting (check against edge KV store)
  // 5. Bot detection
  // 6. CSP headers

  return response
}

export const config = {
  matcher: [
    // Match all paths except static files and api routes that handle their own auth
    '/((?!_next/static|_next/image|favicon.ico|api/webhooks).*)',
  ],
}

MIDDLEWARE RULES:
- Runs on EVERY matched request (including prefetches)
- Runs at the Edge — limited API (no Node.js APIs, no database drivers)
- Keep it FAST — every millisecond adds to TTFB
- Use matcher to limit which routes trigger middleware
- Cannot modify the response body — only headers, cookies, redirects, rewrites
- For complex auth, delegate to route handlers or server components
```

### Step 6: Rendering Strategy Selection
Choose the right rendering strategy for each route:

```
RENDERING STRATEGY GUIDE:

┌─────────────────────────────────────────────────────────────────────────┐
│ Strategy   │ When to Use                     │ Config                   │
├────────────┼─────────────────────────────────┼──────────────────────────┤
│ Static     │ Content rarely changes          │ Default (no config)      │
│ (SSG)      │ Blog posts, docs, marketing     │ generateStaticParams()   │
│            │ pages, changelogs               │                          │
├────────────┼─────────────────────────────────┼──────────────────────────┤
│ ISR        │ Content changes periodically    │ revalidate: <seconds>    │
│            │ Product pages, listings,        │ fetch(..., { next:       │
│            │ category pages                  │   { revalidate: 3600 }}) │
├────────────┼─────────────────────────────────┼──────────────────────────┤
│ SSR        │ Every request needs fresh data  │ dynamic = 'force-dynamic'│
│            │ User dashboards, search results │ cookies(), headers()     │
│            │ personalized pages              │ searchParams usage       │
├────────────┼─────────────────────────────────┼──────────────────────────┤
│ Streaming  │ Page has slow data sources      │ <Suspense> boundaries    │
│ SSR        │ Dashboard with multiple widgets │ loading.tsx              │
│            │ Progressive page loads          │                          │
├────────────┼─────────────────────────────────┼──────────────────────────┤
│ Client     │ Highly interactive, real-time   │ 'use client' + SWR      │
│            │ Chat, collaborative editors,    │ or React Query           │
│            │ live dashboards                 │                          │
└────────────┴─────────────────────────────────┴──────────────────────────┘

DECISION FLOW:
1. Can this page be fully static? → SSG (generateStaticParams)
2. Can it be static but refresh periodically? → ISR (revalidate: N)
3. Does it need per-request data? → SSR (dynamic rendering)
4. Does it have slow parts? → Streaming SSR (Suspense boundaries)
5. Does it need real-time updates? → Client-side fetching within server shell
```

### Step 7: Image, Font & Script Optimization
Apply Next.js built-in optimization features:

```
IMAGE OPTIMIZATION (next/image):
  import Image from 'next/image'

  // Static import — automatic width/height, blur placeholder
  import heroImage from './hero.jpg'
  <Image src={heroImage} alt="Hero" placeholder="blur" priority />

  // Remote images — must specify dimensions
  <Image
    src="https://cdn.example.com/photo.jpg"
    alt="Photo"
    width={800}
    height={600}
    sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 800px"
    loading="lazy"          // Default — lazy load
  />

  // Fill mode — for unknown dimensions
  <div className="relative h-64 w-full">
    <Image src={url} alt="Cover" fill className="object-cover" />
  </div>

  Rules:
  - Use priority on LCP (Largest Contentful Paint) images only
  - Always provide sizes for responsive images
  - Use fill mode when dimensions are unknown
  - Configure remotePatterns in next.config.js for external images
  - Use placeholder="blur" for better perceived performance

FONT OPTIMIZATION (next/font):
  import { Inter, Roboto_Mono } from 'next/font/google'
  import localFont from 'next/font/local'

  const inter = Inter({
    subsets: ['latin'],
    display: 'swap',           // Avoid FOIT
    variable: '--font-inter',  // CSS variable for Tailwind
  })

  const mono = Roboto_Mono({
    subsets: ['latin'],
    variable: '--font-mono',
  })

  // In layout.tsx:
  <html className={`${inter.variable} ${mono.variable}`}>

  Rules:
  - Fonts are self-hosted automatically — zero layout shift
  - Use variable for Tailwind CSS integration
  - Use display: 'swap' to avoid invisible text during load
  - Preload only the subsets you need

SCRIPT OPTIMIZATION (next/script):
  import Script from 'next/script'

  // Analytics — load after page is interactive
  <Script
    src="https://analytics.example.com/script.js"
    strategy="afterInteractive"       // Default
  />

  // Third-party widget — load when idle
  <Script
    src="https://widget.example.com/embed.js"
    strategy="lazyOnload"             // Load during idle time
  />

  // Critical inline script — load before hydration
  <Script id="theme-check" strategy="beforeInteractive">
    {`document.documentElement.classList.toggle('dark',
      localStorage.getItem('theme') === 'dark')`}
  </Script>

  Strategy guide:
  - beforeInteractive: Theme detection, critical polyfills (rare)
  - afterInteractive: Analytics, tracking (default)
  - lazyOnload: Chat widgets, social embeds (anything non-critical)
  - worker: Offload to web worker (experimental)
```

### Step 8: Route Handlers & API Routes
Design route handlers for API endpoints:

```
ROUTE HANDLER PATTERNS (app/api/):

// Basic CRUD handler (app/api/posts/route.ts)
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const page = parseInt(searchParams.get('page') || '1')
  const posts = await db.post.findMany({
    skip: (page - 1) * 20,
    take: 20,
  })
  return NextResponse.json(posts)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const post = await db.post.create({ data: body })
  return NextResponse.json(post, { status: 201 })
}

// Dynamic route handler (app/api/posts/[id]/route.ts)
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const post = await db.post.findUnique({ where: { id: params.id } })
  if (!post) return NextResponse.json({ error: 'Not found' }, { status: 404 })
  return NextResponse.json(post)
}

// Streaming response
export async function GET() {
  const encoder = new TextEncoder()
  const stream = new ReadableStream({
    async start(controller) {
      for await (const chunk of generateData()) {
        controller.enqueue(encoder.encode(JSON.stringify(chunk) + '\n'))
      }
      controller.close()
    },
  })
  return new Response(stream, {
    headers: { 'Content-Type': 'application/x-ndjson' },
  })
}

// Webhook handler with raw body
export async function POST(request: NextRequest) {
  const rawBody = await request.text()
  const signature = request.headers.get('stripe-signature')!
  const event = stripe.webhooks.constructEvent(rawBody, signature, secret)
  // Process event...
  return NextResponse.json({ received: true })
}

RULES:
- Route handlers in app/api/ replace pages/api/ from Pages Router
- Prefer Server Actions for mutations from your own UI
- Use route handlers for: webhooks, external API consumption, streaming
- Route handlers support GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
- GET handlers are cached by default (same as page caching rules)
- Use NextRequest/NextResponse for full control over request/response
```

### Step 9: Validation & Best Practices Audit
Validate the Next.js project against best practices:

```
NEXT.JS BEST PRACTICES AUDIT:
┌──────────────────────────────────────────────────────────────────────┐
│  Check                                         │  Status             │
├────────────────────────────────────────────────┼─────────────────────┤
│  App Router used (not Pages Router)            │  PASS | FAIL | N/A  │
│  'use client' pushed to leaf components        │  PASS | FAIL        │
│  No 'use client' on pages or layouts           │  PASS | FAIL        │
│  Server Actions used for mutations             │  PASS | FAIL        │
│  Parallel data fetching (Promise.all/Suspense) │  PASS | FAIL        │
│  Appropriate caching/revalidation strategy     │  PASS | FAIL        │
│  loading.tsx for slow routes                   │  PASS | FAIL        │
│  error.tsx for error boundaries                │  PASS | FAIL        │
│  next/image for all images                     │  PASS | FAIL        │
│  next/font for font loading                    │  PASS | FAIL        │
│  next/script strategy set correctly            │  PASS | FAIL | N/A  │
│  Middleware matcher configured                 │  PASS | FAIL | N/A  │
│  generateStaticParams for static dynamic routes│  PASS | FAIL | N/A  │
│  Metadata API used (not manual <head>)         │  PASS | FAIL        │
│  No unnecessary client-side state              │  PASS | FAIL        │
│  Bundle size analyzed (no large client imports) │  PASS | FAIL        │
└────────────────────────────────────────────────┴─────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Deliverables
Generate the project artifacts:

```
NEXT.JS ARCHITECTURE COMPLETE:

Artifacts:
- Route structure: app/ directory with <N> routes
- Components: <N> Server Components, <M> Client Components
- Rendering: <SSG/ISR/SSR/Streaming> strategy per route
- Data fetching: Server Components + Server Actions
- Optimization: Images, fonts, scripts configured
- Audit: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:build — Implement the routes and components
-> /godmode:perf — Run Lighthouse and Core Web Vitals analysis
-> /godmode:deploy — Deploy to Vercel or self-hosted
-> /godmode:test — Write tests for server components and actions
```

Commit: `"nextjs: <project> — App Router architecture, <N> routes, <rendering strategy>"`

## Key Behaviors

1. **App Router first.** Always recommend App Router for new projects. Only use Pages Router for legacy compatibility.
2. **Server Components by default.** Every component is a Server Component unless it explicitly needs client interactivity. Push `'use client'` to the smallest possible leaf.
3. **Fetch where you render.** Data fetching happens in the component that displays the data, not in a parent that passes it down.
4. **Cache aggressively, revalidate precisely.** Use ISR and cache tags to serve fast while staying fresh. `no-store` is a last resort.
5. **Streaming over waterfalls.** Use Suspense boundaries to stream slow content. Never block the entire page on one slow query.
6. **Optimize the critical path.** `priority` on LCP images, `next/font` for zero layout shift, `afterInteractive` for analytics scripts.
7. **Middleware is for routing, not logic.** Keep middleware thin — auth redirects, A/B routing, geo detection. Business logic belongs in server components or route handlers.

## Example Usage

### Building a new Next.js app
```
User: /godmode:nextjs Build an e-commerce storefront

NEXT.JS: Starting project assessment...

ASSESSMENT:
Project: E-commerce storefront
Router: App Router (Next.js 14+)
Rendering: Mixed — SSG for products, SSR for cart/checkout
Data: Shopify Storefront API + PostgreSQL for user data
Auth: NextAuth.js with social login
Deploy: Vercel

ROUTE STRUCTURE:
app/
├── (marketing)/ — SSG
│   ├── page.tsx (home)
│   └── about/page.tsx
├── (shop)/ — ISR (revalidate: 3600)
│   ├── products/page.tsx (listing)
│   ├── products/[slug]/page.tsx (detail)
│   └── categories/[slug]/page.tsx
├── (checkout)/ — SSR (dynamic)
│   ├── cart/page.tsx
│   └── checkout/page.tsx
└── (account)/ — SSR (authenticated)
    ├── orders/page.tsx
    └── settings/page.tsx

Server Components: 12 | Client Components: 5 (cart widget, search, filters, checkout form, account menu)
```

### Migrating from Pages Router
```
User: /godmode:nextjs Migrate our app from Pages Router to App Router

NEXT.JS: Scanning existing pages/ directory...

Found: 23 pages, 8 API routes, 4 getServerSideProps, 6 getStaticProps

MIGRATION PLAN:
Phase 1: Create app/ alongside pages/ (both can coexist)
Phase 2: Migrate layouts (Header, Footer, Sidebar → layout.tsx)
Phase 3: Migrate static pages (getStaticProps → Server Components)
Phase 4: Migrate dynamic pages (getServerSideProps → Server Components)
Phase 5: Migrate API routes (pages/api/ → app/api/ route handlers)
Phase 6: Remove pages/ directory
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Next.js architecture workflow |
| `--audit` | Audit existing Next.js project for best practices |
| `--migrate` | Migrate from Pages Router to App Router |
| `--routes` | Design route structure only |
| `--data` | Design data fetching strategy only |
| `--optimize` | Run image, font, script, bundle optimization |
| `--middleware` | Design middleware configuration |
| `--api` | Design route handlers and API layer |
| `--deploy <target>` | Configure for deployment target (vercel, docker, standalone) |

## Auto-Detection

```
IF next.config.js OR next.config.mjs OR next.config.ts exists:
  DETECT framework = "Next.js"
  version = parse next version from package.json

  IF app/ directory exists:
    router = "App Router"
  ELSE IF pages/ directory exists:
    router = "Pages Router"
  IF app/ AND pages/ both exist:
    router = "Migration (both routers)"

  page_count = count page.tsx/page.js in app/ + count *.tsx/*.jsx in pages/
  SUGGEST "Next.js {version} ({router}) detected with {page_count} routes. Activate /godmode:nextjs?"

IF package.json contains "next" in dependencies:
  DETECT framework = "Next.js"
  IF NOT next.config exists:
    SUGGEST "Next.js dependency found but no config. Activate /godmode:nextjs for setup?"

ON code review:
  IF 'use client' found on page.tsx OR layout.tsx:
    WARN "Anti-pattern: 'use client' on page/layout. Activate /godmode:nextjs --audit?"
  IF useEffect + fetch pattern found in Server Component context:
    WARN "Unnecessary client-side fetch. Use Server Component fetch instead."
```

## Iterative Route Build Protocol

```
FOR EACH route in route_plan:
  1. CREATE route directory + page.tsx, determine rendering strategy (SSG/ISR/SSR/Streaming)
  2. IMPLEMENT data fetching, ADD loading.tsx + error.tsx boundaries
  3. PUSH 'use client' to smallest leaf components only
  4. AUDIT: no 'use client' on page/layout, no useEffect+fetch, next/image with sizes, Metadata API
  5. FIX issues before proceeding. Every 5 routes: run build to catch errors.

POST-LOOP: Full audit, report route counts, measure build time + bundle size + Lighthouse.
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (4 worktrees):
  Agent 1 — marketing-routes: (marketing)/ group, SSG/ISR, SEO metadata
  Agent 2 — app-routes: (app)/ group, SSR + auth middleware, Server Actions
  Agent 3 — api-layer: route handlers, webhooks, tRPC/REST
  Agent 4 — shared-components: UI components, providers, image/font/script optimization

MERGE: Verify layouts, no 'use client' on pages, full build, Lighthouse audit.
```

## HARD RULES

```
1. NEVER add 'use client' to page.tsx or layout.tsx.
   This opts the entire tree out of server rendering.
   Push client boundaries to the smallest leaf components.

2. NEVER use useEffect + fetch when a Server Component async fetch works.
   Server Components eliminate client-server waterfalls.

3. NEVER create API routes to fetch data for your own UI.
   Server Components can query databases directly.
   Route handlers are for external consumers and webhooks.

4. EVERY route with data fetching MUST have a loading.tsx.
   Users see a blank screen without loading UI.

5. ALWAYS use next/image with sizes prop for responsive images.
   Without sizes, Next.js cannot select the right image variant.

6. ALWAYS use the Metadata API (generateMetadata / metadata export)
   instead of manual <head> tags. It handles deduplication and streaming.

7. NEVER put heavy JavaScript in middleware.
   Middleware runs on every request at the Edge. Keep it under 1MB.

8. ALWAYS use parallel data fetching (Promise.all or Suspense boundaries).
   Sequential awaits create waterfall requests that block rendering.
```

## Output Format

Every Next.js skill invocation ends with a structured summary:

```
NEXT.JS COMPLETE:
Project: <name>
Routes: <N> total (<N> SSG, <N> ISR, <N> SSR, <N> streaming)
Components: <N> Server, <M> Client
Data: <fetching strategy>
Optimization: <images, fonts, scripts status>
Audit: <PASS | NEEDS REVISION>
Duration: <time spent>
```

Commit message: `"nextjs: <project> — <primary change>, <rendering strategy>"`

## TSV Logging

Append one row per Next.js skill invocation to `.godmode/nextjs-results.tsv`:

```
timestamp	project	action	routes_count	server_components	client_components	audit_status	notes
2024-01-15T10:30:00Z	storefront	architecture	18	12	5	PASS	App Router + ISR for products
2024-01-15T11:00:00Z	storefront	audit	18	12	5	NEEDS_REVISION	use client on layout.tsx found
```

Fields: `timestamp` (ISO 8601), `project`, `action` (architecture | audit | migrate | routes | data | optimize | middleware | api | deploy), `routes_count`, `server_components`, `client_components`, `audit_status` (PASS | NEEDS_REVISION | SKIPPED), `notes` (free text, no tabs).

IF `.godmode/` directory does not exist, create it. IF the TSV file does not exist, write the header row first.

## Success Criteria

A Next.js skill invocation is successful when ALL of the following are true:

1. `next build` completes with zero errors.
2. No `'use client'` directive on any `page.tsx` or `layout.tsx`.
3. Every route with data fetching has a corresponding `loading.tsx`.
4. Every route with dynamic content has an `error.tsx` boundary.
5. All images use `next/image` with `sizes` prop for responsive images.
6. Metadata uses the Metadata API (not manual `<head>` tags).
7. No `useEffect` + `fetch` patterns where Server Component fetch would work.
8. Parallel data fetching used (Promise.all or Suspense boundaries) — no sequential waterfalls.
9. The validation audit (Step 9) shows PASS on all applicable checks.

IF any criterion fails, fix before marking the invocation complete.

## Error Recovery

```
WHEN next build fails:
  1. Read the build error output.
  2. Common causes: TypeScript errors, missing imports, invalid metadata.
  3. Fix the error. Re-run next build. Repeat until clean.

WHEN 'use client' is on page.tsx or layout.tsx:
  1. Identify which interactive elements require client-side code.
  2. Extract those elements into separate client component files.
  3. Import client components into the server page/layout.
  4. Remove 'use client' from page.tsx/layout.tsx.

WHEN hydration mismatch errors appear:
  1. Identify the component causing the mismatch (browser console).
  2. Common causes: Date/time rendering, browser-only APIs, conditional rendering.
  3. Wrap browser-only code in useEffect or dynamic import with ssr: false.
  4. Verify mismatch is resolved in both dev and production builds.

WHEN Server Action fails:
  1. Check the server-side error logs (not just the client response).
  2. Verify the function has 'use server' directive.
  3. Verify all arguments are serializable (no functions, classes, or symbols).
  4. Add proper error handling with try/catch and return error state to the client.

WHEN middleware causes redirect loops:
  1. Check matcher configuration — ensure it excludes static assets and API routes.
  2. Verify redirect conditions don't match the redirect target URL.
  3. Add logging to middleware to trace the redirect chain.
  4. Fix the condition or add the target path to matcher exclusions.
```

## Keep/Discard Discipline
```
After EACH Next.js optimization:
  1. MEASURE: Run next build, measure TTFB per route, check hydration payload size.
  2. COMPARE: Is TTFB lower or equal? Is hydration payload smaller? Does build pass?
  3. DECIDE:
     - KEEP if TTFB improved AND build passes AND no 'use client' on page/layout.
     - DISCARD if TTFB worsened OR build failed OR content freshness degraded.
  4. COMMIT kept changes. Revert discarded changes before the next optimization.

Never keep a rendering strategy change that makes content unacceptably stale.
Never measure TTFB in dev mode — always use production build.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All routes TTFB < 200ms (p75) AND hydration < 100ms AND client JS < 150KB gzipped
  - All 'use client' at leaf level AND rendering strategy matches data characteristics per route
  - User explicitly requests stop
  - Max iterations (8) per phase reached
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run Next.js tasks sequentially: marketing routes, then app routes, then API layer.
- Use branch isolation per task: `git checkout -b godmode-nextjs-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
