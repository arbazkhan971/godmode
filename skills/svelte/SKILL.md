---
name: svelte
description: |
  Svelte and SvelteKit mastery skill. Activates when user needs to build, architect, or optimize Svelte applications. Covers Svelte 5 runes reactivity, stores, SvelteKit routing with load functions and form actions, server-side rendering, prerendering, adapter configuration for different deployment platforms, and testing. Triggers on: /godmode:svelte, "build a Svelte app", "SvelteKit project", "Svelte component", "svelte store", or when the orchestrator detects Svelte-related work.
---

# Svelte — Svelte/SvelteKit Mastery

## When to Activate
- User invokes `/godmode:svelte`
- User says "build a Svelte app", "Svelte component", "SvelteKit project"
- User mentions "Svelte stores", "runes", "$state", "load functions"
- User says "form actions", "SvelteKit routing", "SvelteKit adapter"
- When creating or scaffolding a Svelte application
- When `/godmode:plan` identifies Svelte tasks
- When `/godmode:review` flags Svelte-specific patterns

## Workflow

### Step 1: Project Discovery & Assessment
Survey the existing project or determine new project requirements:

```
SVELTE PROJECT ASSESSMENT:
Svelte version: <4 / 5>
Meta-framework: <SvelteKit / standalone Svelte / none>
Reactivity model: <Runes (Svelte 5) / Legacy ($: reactive) / Mixed>
State management: <Svelte stores / Runes ($state) / external (Zustand) / none>
Routing: <SvelteKit file-based / custom / none>
UI library: <Skeleton / DaisyUI / Melt UI / Bits UI / custom / none>
CSS approach: <Tailwind / UnoCSS / SCSS / scoped styles>
Testing: <Vitest / Playwright / none>
TypeScript: <yes / no>
Adapter: <auto / node / static / vercel / cloudflare / netlify>
Component count: <N>
Route count: <N>

Directory structure:
  src/
    lib/
      components/    Reusable components
      stores/        Svelte stores
      utils/         Utility functions
      server/        Server-only modules
    routes/          SvelteKit file-based routes
    params/          Route param matchers
    hooks.server.ts  Server hooks
    hooks.client.ts  Client hooks
    app.html         HTML template
    app.d.ts         App-level types

Quality score: <HIGH / MEDIUM / LOW>
Issues detected: <N>
```

If starting fresh, ask: "What are you building? Do you need SSR (SvelteKit) or a client-only app?"

### Step 2: Svelte Reactivity Model
Guide the appropriate reactivity approach:

#### Svelte 5 Runes (Recommended)
```svelte
<script lang="ts">
  // $state — reactive state declaration
  let count = $state(0);
  let user = $state<User | null>(null);
  let items = $state<string[]>([]);

  // $derived — computed values (replaces $: reactive statements)
  let doubled = $derived(count * 2);
  let fullName = $derived(user ? `${user.firstName} ${user.lastName}` : '');
  let itemCount = $derived(items.length);

  // $derived.by — complex derived values
  let summary = $derived.by(() => {
    if (items.length === 0) return 'No items';
    if (items.length === 1) return '1 item';
    return `${items.length} items`;
  });

  // $effect — side effects (replaces $: reactive statements with side effects)
  $effect(() => {
    console.log(`Count changed to ${count}`);
    // Cleanup function (optional)
    return () => {
      console.log('Cleaning up previous effect');
    };
  });

  // $props — component props (replaces export let)
  interface Props {
    title: string;
    subtitle?: string;
    onSave: (data: FormData) => void;
  }
  let { title, subtitle = 'Default subtitle', onSave }: Props = $props();

  // $bindable — two-way bindable props
  let { value = $bindable('') }: { value: string } = $props();

  // Functions modify state directly
  function increment() {
    count++;
  }

  function addItem(item: string) {
    items.push(item);  // Direct mutation works with $state
  }
</script>

<h1>{title}</h1>
<p>{subtitle}</p>
<p>Count: {count} (doubled: {doubled})</p>
<button onclick={increment}>Increment</button>
```

#### Svelte 4 Legacy Reactivity
```svelte
<script lang="ts">
  // Reactive declarations
  export let title: string;
  export let subtitle: string = 'Default subtitle';

  let count = 0;

  // Reactive statements (computed)
  $: doubled = count * 2;
  $: summary = count === 0 ? 'No items' : `${count} items`;

  // Reactive statements (side effects)
  $: console.log(`Count changed to ${count}`);

  function increment() {
    count += 1;
  }
</script>
```

Decision guide:
```
REACTIVITY MODEL DECISION:
┌────────────────────────────────────────────────────────────────────────┐
│  Factor                 │  Runes (Svelte 5)       │  Legacy (Svelte 4) │
├─────────────────────────┼─────────────────────────┼────────────────────┤
│  Explicitness           │  Explicit ($state)      │  Implicit (let)    │
│  Computed values        │  $derived (clear)       │  $: (ambiguous)    │
│  Side effects           │  $effect (dedicated)    │  $: (overloaded)   │
│  Props                  │  $props() (typed)       │  export let (basic)│
│  Fine-grained           │  Yes (signal-based)     │  Component-level   │
│  .svelte.ts files       │  Reactive outside comps │  Components only   │
│  Migration              │  Incremental (per file) │  N/A               │
└─────────────────────────┴─────────────────────────┴────────────────────┘

RECOMMENDATION: Svelte 5 runes for new projects. Migrate existing Svelte 4
projects incrementally — runes and legacy syntax can coexist.
```

### Step 3: Svelte Stores
Design state management with stores:

#### Svelte 5 — Shared State with Runes
```typescript
// lib/stores/cart.svelte.ts
import type { CartItem, Product } from '$lib/types';

class CartStore {
  items = $state<CartItem[]>([]);

  total = $derived(
    this.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  );

  count = $derived(
    this.items.reduce((sum, item) => sum + item.quantity, 0)
  );

  isEmpty = $derived(this.items.length === 0);

  add(product: Product, quantity = 1) {
    const existing = this.items.find(i => i.productId === product.id);
    if (existing) {
      existing.quantity += quantity;
    } else {
      this.items.push({
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity,
      });
    }
  }

  remove(productId: string) {
    this.items = this.items.filter(i => i.productId !== productId);
  }

  clear() {
    this.items = [];
  }
}

export const cart = new CartStore();
```

#### Classic Svelte Stores (Svelte 4 / SvelteKit compatible)
```typescript
// lib/stores/auth.ts
import { writable, derived } from 'svelte/store';
import type { User } from '$lib/types';

function createAuthStore() {
  const { subscribe, set, update } = writable<{
    user: User | null;
    token: string | null;
    loading: boolean;
  }>({
    user: null,
    token: null,
    loading: false,
  });

  return {
    subscribe,
    login: async (credentials: LoginCredentials) => {
      update(s => ({ ...s, loading: true }));
      try {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          body: JSON.stringify(credentials),
          headers: { 'Content-Type': 'application/json' },
        });
        const data = await response.json();
        set({ user: data.user, token: data.token, loading: false });
      } catch {
        update(s => ({ ...s, loading: false }));
        throw new Error('Login failed');
      }
    },
    logout: () => {
      set({ user: null, token: null, loading: false });
    },
  };
}

export const auth = createAuthStore();

// Derived store
export const isAuthenticated = derived(auth, ($auth) => !!$auth.token);
export const isAdmin = derived(auth, ($auth) => $auth.user?.role === 'admin');
```

Rules for stores:
- **Svelte 5:** Use reactive classes (`.svelte.ts`) for shared state across components
- **Svelte 4/SvelteKit:** Use `writable`/`readable`/`derived` stores with custom methods
- **One store per domain** — `cart`, `auth`, `notifications`, not one mega-store
- **Expose minimal API** — consumers get subscribe + named methods, not raw set/update
- **Derived stores for computed values** — don't recompute in every component
- **Server-safe stores** — stores accessed during SSR must not hold client-specific state globally

### Step 4: SvelteKit Routing
Design the routing architecture with SvelteKit's file-based routing:

```
ROUTE ARCHITECTURE:
src/routes/
├── +layout.svelte           Root layout (nav, footer)
├── +layout.server.ts        Root layout data (session, user)
├── +page.svelte             Home page (/)
├── +page.server.ts          Home page data loader
├── +error.svelte            Error page
├── auth/
│   ├── login/
│   │   ├── +page.svelte     Login form
│   │   └── +page.server.ts  Login form action + load
│   └── register/
│       ├── +page.svelte     Register form
│       └── +page.server.ts  Register form action
├── dashboard/
│   ├── +layout.svelte       Dashboard layout (sidebar)
│   ├── +layout.server.ts    Auth guard + user data
│   ├── +page.svelte         Dashboard home
│   └── settings/
│       └── +page.svelte     Settings page
├── blog/
│   ├── +page.svelte         Blog list
│   ├── +page.server.ts      Blog list loader
│   └── [slug]/
│       ├── +page.svelte     Blog post
│       └── +page.server.ts  Blog post loader
├── api/
│   └── health/
│       └── +server.ts       API endpoint
└── (marketing)/
    ├── about/
    │   └── +page.svelte     About page
    └── pricing/
        └── +page.svelte     Pricing page
```

#### Load Functions
```typescript
// routes/blog/[slug]/+page.server.ts
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { db } from '$lib/server/database';

export const load: PageServerLoad = async ({ params, locals, depends }) => {
  // Declare dependency for invalidation
  depends('app:blog');

  const post = await db.post.findUnique({
    where: { slug: params.slug, published: true },
    include: { author: true, comments: { orderBy: { createdAt: 'desc' } } },
  });

  if (!post) {
    error(404, { message: 'Post not found' });
  }

  return {
    post,
    isAuthor: locals.user?.id === post.authorId,
  };
};
```

```typescript
// routes/dashboard/+layout.server.ts — Auth guard via layout load
import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
  if (!locals.user) {
    redirect(303, '/auth/login');
  }

  return {
    user: locals.user,
  };
};
```

#### Form Actions
```typescript
// routes/blog/[slug]/+page.server.ts
import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { db } from '$lib/server/database';

export const load: PageServerLoad = async ({ params }) => {
  const post = await db.post.findUnique({ where: { slug: params.slug } });
  if (!post) error(404, 'Not found');
  return { post };
};

export const actions: Actions = {
  // Named action: <form method="POST" action="?/addComment">
  addComment: async ({ request, params, locals }) => {
    if (!locals.user) {
      return fail(401, { message: 'Must be logged in' });
    }

    const formData = await request.formData();
    const body = formData.get('body')?.toString();

    if (!body || body.length < 3) {
      return fail(400, {
        body,
        errors: { body: 'Comment must be at least 3 characters' },
      });
    }

    await db.comment.create({
      data: {
        body,
        postSlug: params.slug,
        authorId: locals.user.id,
      },
    });

    return { success: true };
  },

  deleteComment: async ({ request, locals }) => {
    if (!locals.user) return fail(401, { message: 'Unauthorized' });

    const formData = await request.formData();
    const commentId = formData.get('commentId')?.toString();

    const comment = await db.comment.findUnique({ where: { id: commentId } });
    if (!comment || comment.authorId !== locals.user.id) {
      return fail(403, { message: 'Not allowed' });
    }

    await db.comment.delete({ where: { id: commentId } });
    return { success: true };
  },
};
```

#### Using Form Actions in Components
```svelte
<script lang="ts">
  import { enhance } from '$app/forms';
  import type { ActionData, PageData } from './$types';

  let { data, form }: { data: PageData; form: ActionData } = $props();
</script>

<h1>{data.post.title}</h1>

<!-- Progressive enhancement: works without JS, enhanced with JS -->
<form method="POST" action="?/addComment" use:enhance>
  <textarea
    name="body"
    value={form?.body ?? ''}
    placeholder="Add a comment..."
    class:error={form?.errors?.body}
  ></textarea>
  {#if form?.errors?.body}
    <p class="error">{form.errors.body}</p>
  {/if}
  <button type="submit">Post Comment</button>
</form>

{#if form?.success}
  <p class="success">Comment posted!</p>
{/if}

{#each data.post.comments as comment}
  <div class="comment">
    <p>{comment.body}</p>
    {#if data.isAuthor || comment.authorId === data.user?.id}
      <form method="POST" action="?/deleteComment" use:enhance>
        <input type="hidden" name="commentId" value={comment.id} />
        <button type="submit">Delete</button>
      </form>
    {/if}
  </div>
{/each}
```

Rules for SvelteKit routing:
- **Server load functions for data** — `+page.server.ts` for data that needs database/API access
- **Layout load for shared data** — session, user, navigation data loaded once in layout
- **Form actions for mutations** — progressive enhancement with `use:enhance`, no custom API routes needed
- **Auth guards in layout loads** — protect entire route groups by redirecting in layout server load
- **Route groups `(name)`** — group routes without affecting URL structure (marketing pages, admin pages)
- **Param matchers** — validate route params in `src/params/` for type-safe routing

### Step 5: Server-Side Rendering & Prerendering
Configure rendering strategies per route:

```
RENDERING STRATEGY:
┌──────────────────────────────────────────────────────────────────────┐
│  Route                 │  Strategy     │  Reason                     │
├────────────────────────┼───────────────┼─────────────────────────────┤
│  /                     │  Prerender    │  Static content, fast load  │
│  /about, /pricing      │  Prerender    │  Marketing pages, SEO       │
│  /blog/[slug]          │  SSR + cache  │  Dynamic, SEO-critical      │
│  /dashboard/**         │  CSR (ssr:false)│  Auth-gated, no SEO need │
│  /api/**               │  Server-only  │  API endpoints              │
│  /products/[id]        │  SSR          │  Dynamic, SEO-critical      │
└────────────────────────┴───────────────┴─────────────────────────────┘
```

#### Per-Route Configuration
```typescript
// routes/(marketing)/about/+page.ts
// Prerender at build time
export const prerender = true;

// routes/dashboard/+layout.ts
// Disable SSR for dashboard (client-only rendering)
export const ssr = false;

// routes/blog/[slug]/+page.server.ts
// SSR with cache headers
export const load: PageServerLoad = async ({ params, setHeaders }) => {
  const post = await getPost(params.slug);

  setHeaders({
    'Cache-Control': 'public, max-age=60, s-maxage=3600',
  });

  return { post };
};
```

#### SvelteKit Hooks
```typescript
// src/hooks.server.ts — Server hooks (auth, logging, etc.)
import type { Handle, HandleServerError } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';

const authHook: Handle = async ({ event, resolve }) => {
  const sessionToken = event.cookies.get('session');

  if (sessionToken) {
    const user = await verifySession(sessionToken);
    event.locals.user = user;
  }

  return resolve(event);
};

const loggingHook: Handle = async ({ event, resolve }) => {
  const start = performance.now();
  const response = await resolve(event);
  const duration = performance.now() - start;

  console.log(`${event.request.method} ${event.url.pathname} — ${duration.toFixed(0)}ms`);

  return response;
};

export const handle = sequence(authHook, loggingHook);

export const handleError: HandleServerError = async ({ error, event }) => {
  console.error(`Server error on ${event.url.pathname}:`, error);

  return {
    message: 'An unexpected error occurred',
    code: 'INTERNAL_ERROR',
  };
};
```

### Step 6: Adapter Configuration
Configure the deployment adapter:

```
ADAPTER SELECTION:
┌──────────────────────────────────────────────────────────────────────┐
│  Platform        │  Adapter                  │  Notes                │
├──────────────────┼───────────────────────────┼───────────────────────┤
│  Vercel          │  @sveltejs/adapter-vercel │  Edge/Serverless      │
│  Cloudflare      │  @sveltejs/adapter-cloudflare │  Workers/Pages   │
│  Netlify         │  @sveltejs/adapter-netlify│  Functions + CDN      │
│  Node.js         │  @sveltejs/adapter-node   │  Express/Fastify host │
│  Static (SPA)    │  @sveltejs/adapter-static │  GitHub Pages, S3     │
│  Auto-detect     │  @sveltejs/adapter-auto   │  Detects platform     │
│  Bun             │  svelte-adapter-bun       │  Bun runtime          │
└──────────────────┴───────────────────────────┴───────────────────────┘
```

```typescript
// svelte.config.js
import adapter from '@sveltejs/adapter-node'; // or adapter-vercel, adapter-static, etc.
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),

  kit: {
    adapter: adapter({
      // Node adapter options
      out: 'build',
      precompress: true,  // Generate .gz and .br files
      envPrefix: 'APP_',
    }),

    // Path aliases
    alias: {
      $components: 'src/lib/components',
      $stores: 'src/lib/stores',
      $utils: 'src/lib/utils',
    },

    // CSP configuration
    csp: {
      directives: {
        'script-src': ['self'],
        'style-src': ['self', 'unsafe-inline'],
      },
    },

    // Prerender configuration
    prerender: {
      handleMissingId: 'warn',
      handleHttpError: 'warn',
      entries: ['*'],  // Crawl all links
    },
  },
};

export default config;
```

Platform-specific configuration:

```typescript
// Vercel — Edge functions for specific routes
// routes/api/fast/+server.ts
export const config = {
  runtime: 'edge',
  regions: ['iad1'],  // US East
};

// Cloudflare — Access KV, D1, R2 via platform
// routes/api/data/+server.ts
export const load: PageServerLoad = async ({ platform }) => {
  const value = await platform.env.MY_KV.get('key');
  return { value };
};
```

### Step 7: Component Patterns
Establish reusable component patterns:

#### Snippet Pattern (Svelte 5 — replaces slots)
```svelte
<!-- lib/components/Card.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    title: string;
    header?: Snippet;
    children: Snippet;
    footer?: Snippet;
  }

  let { title, header, children, footer }: Props = $props();
</script>

<div class="card">
  {#if header}
    <div class="card-header">{@render header()}</div>
  {:else}
    <div class="card-header"><h3>{title}</h3></div>
  {/if}

  <div class="card-body">
    {@render children()}
  </div>

  {#if footer}
    <div class="card-footer">{@render footer()}</div>
  {/if}
</div>
```

#### Usage
```svelte
<Card title="User Profile">
  <p>Main content goes here.</p>

  {#snippet footer()}
    <button>Save Changes</button>
  {/snippet}
</Card>
```

#### Transition Pattern
```svelte
<script lang="ts">
  import { fade, fly, slide } from 'svelte/transition';
  import { quintOut } from 'svelte/easing';

  let visible = $state(true);
</script>

{#if visible}
  <div transition:fade={{ duration: 200 }}>
    Fades in and out
  </div>

  <div in:fly={{ y: 20, duration: 300, easing: quintOut }} out:fade>
    Flies in, fades out
  </div>
{/if}

<!-- List transitions -->
{#each items as item (item.id)}
  <div animate:flip={{ duration: 300 }} transition:slide>
    {item.name}
  </div>
{/each}
```

### Step 8: Testing
Set up testing with Vitest and Playwright:

```
TESTING SETUP:
Unit/Component: Vitest + @testing-library/svelte
E2E: Playwright
Coverage target: > 80% statements, > 70% branches
```

#### Vitest Configuration
```typescript
// vite.config.ts
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [sveltekit()],
  test: {
    include: ['src/**/*.test.ts'],
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/lib/**/*.{ts,svelte}'],
      thresholds: {
        statements: 80,
        branches: 70,
      },
    },
  },
});
```

#### Component Testing
```typescript
// lib/components/Counter.test.ts
import { describe, it, expect } from 'vitest';
import { render, fireEvent } from '@testing-library/svelte';
import Counter from './Counter.svelte';

describe('Counter', () => {
  it('renders initial count', () => {
    const { getByText } = render(Counter, { props: { initial: 5 } });
    expect(getByText('Count: 5')).toBeTruthy();
  });

  it('increments on click', async () => {
    const { getByText, getByRole } = render(Counter, { props: { initial: 0 } });

    const button = getByRole('button', { name: 'Increment' });
    await fireEvent.click(button);

    expect(getByText('Count: 1')).toBeTruthy();
  });

  it('does not go below zero when min is set', async () => {
    const { getByText, getByRole } = render(Counter, {
      props: { initial: 0, min: 0 },
    });

    const button = getByRole('button', { name: 'Decrement' });
    await fireEvent.click(button);

    expect(getByText('Count: 0')).toBeTruthy();
  });
});
```

#### Load Function Testing
```typescript
// routes/blog/[slug]/page.server.test.ts
import { describe, it, expect, vi } from 'vitest';
import { load } from './+page.server';

vi.mock('$lib/server/database', () => ({
  db: {
    post: {
      findUnique: vi.fn(),
    },
  },
}));

describe('blog post load function', () => {
  it('returns post data for valid slug', async () => {
    const mockPost = { slug: 'test', title: 'Test Post', content: '...' };
    vi.mocked(db.post.findUnique).mockResolvedValue(mockPost);

    const result = await load({
      params: { slug: 'test' },
      locals: { user: null },
      depends: vi.fn(),
    } as any);

    expect(result.post).toEqual(mockPost);
  });

  it('throws 404 for missing slug', async () => {
    vi.mocked(db.post.findUnique).mockResolvedValue(null);

    await expect(
      load({ params: { slug: 'nonexistent' }, locals: {}, depends: vi.fn() } as any)
    ).rejects.toThrow();
  });
});
```

### Step 9: Validation
Validate the Svelte application against best practices:

```
SVELTE APPLICATION AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                                    │  Status              │
├───────────────────────────────────────────┼──────────────────────┤
│  Svelte 5 runes used (if applicable)     │  PASS | FAIL | N/A   │
│  TypeScript enabled and strict            │  PASS | FAIL         │
│  Server load functions for data fetching  │  PASS | FAIL         │
│  Form actions for mutations               │  PASS | FAIL         │
│  Progressive enhancement (use:enhance)    │  PASS | FAIL         │
│  Rendering strategy per route             │  PASS | FAIL         │
│  Adapter configured for target platform   │  PASS | FAIL         │
│  Error pages defined (+error.svelte)      │  PASS | FAIL         │
│  Hooks for auth/logging                   │  PASS | FAIL         │
│  Stores/state well-organized              │  PASS | FAIL         │
│  No $effect for derived state (use $derived)│ PASS | FAIL        │
│  No fetch in components (use load)        │  PASS | FAIL         │
│  Accessibility attributes present         │  PASS | FAIL         │
│  Test coverage meets thresholds           │  PASS | FAIL         │
│  Bundle size within budget                │  PASS | FAIL         │
│  No unused imports or components          │  PASS | FAIL         │
│  Security headers configured (CSP)        │  PASS | FAIL         │
└───────────────────────────────────────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Deliverables & Handoff
Generate the project artifacts:

```
SVELTE PROJECT COMPLETE:

Artifacts:
- Framework: <SvelteKit / Svelte standalone>
- Svelte version: <4 / 5>
- Components: <N> components
- Routes: <N> routes (<N> prerendered, <N> SSR, <N> CSR)
- Stores: <N> stores
- Form actions: <N> actions
- Load functions: <N> server loaders
- Adapter: <platform>
- Tests: <N> test files, <M>% coverage
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:tailwind — Set up Tailwind CSS styling
-> /godmode:a11y — Accessibility audit
-> /godmode:e2e — End-to-end testing with Playwright
-> /godmode:build — Implement features
-> /godmode:ship — Deploy the application
```

Commit: `"svelte: <project> — <N> routes, <N> components, <SvelteKit | Svelte>, <adapter>"`

## Key Behaviors

1. **SvelteKit by default.** Unless building a widget or embedded component, use SvelteKit. It handles routing, SSR, data loading, and deployment out of the box.
2. **Runes for Svelte 5.** New Svelte 5 projects use runes (`$state`, `$derived`, `$effect`). They are more explicit, more powerful, and the future of Svelte.
3. **Load functions, not fetch-in-component.** Data fetching belongs in `+page.server.ts` load functions, not in `onMount`. Load functions run on the server, are type-safe, and handle errors properly.
4. **Form actions over API routes.** For mutations (create, update, delete), use form actions with `use:enhance`. They work without JavaScript and are progressively enhanced.
5. **Progressive enhancement is free.** SvelteKit forms work without JavaScript by default. Adding `use:enhance` makes them better with JavaScript. Do not break this.
6. **Prerender what you can.** Static pages should be prerendered at build time. Dynamic pages should be SSR with cache headers. Only client-render what truly cannot be server-rendered.
7. **Choose the right adapter.** Match the adapter to your deployment target. `adapter-auto` works for CI detection, but explicit adapters give you platform-specific features.

## Example Usage

### Building a new SvelteKit app
```
User: /godmode:svelte Build a blog with authentication and comments

Svelte: Starting project assessment...

SVELTE PROJECT ASSESSMENT:
Svelte version: 5
Meta-framework: SvelteKit
Reactivity: Runes ($state, $derived, $effect)
State management: Svelte 5 reactive classes
Adapter: adapter-node (Docker deployment)

Scaffolding:
  Routes: /, /auth/login, /auth/register, /blog, /blog/[slug], /dashboard
  Load functions: 6 server loaders
  Form actions: login, register, addComment, deleteComment, createPost
  Hooks: auth session verification, error logging
  Components: Nav, Footer, PostCard, CommentForm, AuthForm

Rendering strategy:
  / -> Prerendered (static)
  /blog -> SSR with 60s cache
  /blog/[slug] -> SSR with 5min cache
  /dashboard -> CSR (ssr: false)
```

### Migrating Svelte 4 to Svelte 5
```
User: /godmode:svelte Migrate our app from Svelte 4 to Svelte 5 runes

Svelte: Scanning components...

Found 24 components using legacy reactivity
Migration plan:
  Phase 1: Update svelte.config.js for Svelte 5
  Phase 2: Migrate reactive declarations ($:) to $derived (18 files)
  Phase 3: Migrate reactive statements with effects to $effect (8 files)
  Phase 4: Migrate export let to $props (24 files)
  Phase 5: Migrate slots to snippets (12 files)
  Phase 6: Migrate stores to reactive classes where appropriate (6 stores)

Note: Runes and legacy can coexist — migrate incrementally per file.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Svelte/SvelteKit project assessment and setup |
| `--audit` | Audit existing Svelte project against best practices |
| `--migrate` | Migrate Svelte 4 to Svelte 5 runes |
| `--sveltekit` | Set up or configure SvelteKit |
| `--stores` | Design and implement state management |
| `--routing` | Design SvelteKit routing with load functions |
| `--actions` | Implement form actions for mutations |
| `--adapter <platform>` | Configure deployment adapter |
| `--ssr` | Configure rendering strategy per route |
| `--test` | Set up Vitest and write component tests |
| `--component <name>` | Generate a new component with tests |
| `--hooks` | Set up server/client hooks |

## Anti-Patterns

- **Do NOT fetch data in `onMount`.** Use SvelteKit load functions. They run on the server, handle errors, are type-safe, and prevent waterfalls.
- **Do NOT create API routes for form submissions.** Use form actions. They are simpler, progressively enhanced, and handle validation natively.
- **Do NOT use `$effect` for derived state.** Use `$derived` or `$derived.by()`. Effects are for side effects (logging, DOM manipulation, external systems), not computation.
- **Do NOT put server secrets in `+page.ts`.** Use `+page.server.ts` for anything that touches secrets, databases, or private APIs. `+page.ts` runs on both client and server.
- **Do NOT fight SvelteKit's conventions.** File-based routing, load functions, form actions, hooks — these patterns exist for good reasons. Working against them creates maintenance burden.
- **Do NOT use `document` or `window` without guards.** SvelteKit runs on the server. Check `browser` from `$app/environment` or use `onMount` for client-only code.
- **Do NOT create global mutable state in modules.** Server-rendered pages share module scope across requests. Use stores or context for per-request state.
- **Do NOT skip `use:enhance` on forms.** Without it, every form submission causes a full page reload. Progressive enhancement is a one-line addition.
- **Do NOT manually manage subscriptions.** In Svelte templates, store auto-subscription (`$store`) handles cleanup. In Svelte 5, `$effect` handles cleanup via its return function.
