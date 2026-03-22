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

## Auto-Detection

Run this sequence at skill start to determine project context:

```bash
# Detect Svelte presence and version
cat package.json 2>/dev/null | grep -E '"svelte"|"@sveltejs/kit"'

# Detect SvelteKit vs standalone
ls svelte.config.js svelte.config.ts 2>/dev/null

# Detect Svelte version (4 vs 5)
cat node_modules/svelte/package.json 2>/dev/null | grep '"version"'

# Detect reactivity model (runes vs legacy)
grep -rl '\$state\|\$derived\|\$effect\|\$props' src/ 2>/dev/null | head -5
grep -rl '\$:' src/ 2>/dev/null | head -5

# Detect state management
grep -r "writable\|readable\|derived" src/ 2>/dev/null | head -5

# Detect adapter
grep -E "adapter-(auto|node|static|vercel|cloudflare|netlify)" svelte.config.* 2>/dev/null

# Detect CSS approach
grep -E "tailwindcss|unocss|scss|sass" package.json 2>/dev/null

# Detect testing
grep -E "vitest|playwright|@testing-library/svelte" package.json 2>/dev/null

# Detect TypeScript
ls src/app.d.ts tsconfig.json 2>/dev/null

# Detect UI library
grep -E "skeleton|daisyui|melt-ui|bits-ui" package.json 2>/dev/null
```

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
 components/ Reusable components
 stores/ Svelte stores
 utils/ Utility functions
 server/ Server-only modules
 routes/ SvelteKit file-based routes
 params/ Route param matchers
 hooks.server.ts Server hooks
 hooks.client.ts Client hooks
 app.html HTML template
 app.d.ts App-level types

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
 items.push(item); // Direct mutation works with $state
 }
</script>

<h1>{title}</h1>
<p>{subtitle}</p>
<p>Count: {count} (doubled: {doubled})</p>
<button onclick={increment}>Increment</button>
```


Decision guide:
```
REACTIVITY MODEL DECISION:
┌────────────────────────────────────────────────────────────────────────┐
│ Factor │ Runes (Svelte 5) │ Legacy (Svelte 4) │
├─────────────────────────┼─────────────────────────┼────────────────────┤
│ Explicitness │ Explicit ($state) │ Implicit (let) │
│ Computed values │ $derived (clear) │ $: (ambiguous) │
│ Side effects │ $effect (dedicated) │ $: (overloaded) │
│ Props │ $props() (typed) │ export let (basic)│
│ Fine-grained │ Yes (signal-based) │ Component-level │
│.svelte.ts files │ Reactive outside comps │ Components only │
│ Migration │ Incremental (per file) │ N/A │
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
├── +layout.svelte Root layout (nav, footer)
├── +layout.server.ts Root layout data (session, user)
├── +page.svelte Home page (/)
├── +page.server.ts Home page data loader
├── +error.svelte Error page
├── auth/
│ ├── login/
│ │ ├── +page.svelte Login form
│ │ └── +page.server.ts Login form action + load
│ └── register/
│ ├── +page.svelte Register form
│ └── +page.server.ts Register form action
├── dashboard/
│ ├── +layout.svelte Dashboard layout (sidebar)
│ ├── +layout.server.ts Auth guard + user data
│ ├── +page.svelte Dashboard home
│ └── settings/
│ └── +page.svelte Settings page
├── blog/
│ ├── +page.svelte Blog list
│ ├── +page.server.ts Blog list loader
│ └── [slug]/
│ ├── +page.svelte Blog post
│ └── +page.server.ts Blog post loader
├── api/
│ └── health/
│ └── +server.ts API endpoint
└── (marketing)/
 ├── about/
 │ └── +page.svelte About page
 └── pricing/
 └── +page.svelte Pricing page
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
│ Route │ Strategy │ Reason │
├────────────────────────┼───────────────┼─────────────────────────────┤
│ / │ Prerender │ Static content, fast load │
│ /about, /pricing │ Prerender │ Marketing pages, SEO │
│ /blog/[slug] │ SSR + cache │ Dynamic, SEO-critical │
│ /dashboard/** │ CSR (ssr:false)│ Auth-gated, no SEO need │
│ /api/** │ Server-only │ API endpoints │
│ /products/[id] │ SSR │ Dynamic, SEO-critical │
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


### Step 6: Adapter Configuration
Configure the deployment adapter:

```
ADAPTER SELECTION:
┌──────────────────────────────────────────────────────────────────────┐
│ Platform │ Adapter │ Notes │
├──────────────────┼───────────────────────────┼───────────────────────┤
│ Vercel │ @sveltejs/adapter-vercel │ Edge/Serverless │
│ Cloudflare │ @sveltejs/adapter-cloudflare │ Workers/Pages │
│ Netlify │ @sveltejs/adapter-netlify│ Functions + CDN │
│ Node.js │ @sveltejs/adapter-node │ Express/Fastify host │
│ Static (SPA) │ @sveltejs/adapter-static │ GitHub Pages, S3 │
│ Auto-detect │ @sveltejs/adapter-auto │ Detects platform │
│ Bun │ svelte-adapter-bun │ Bun runtime │
└──────────────────┴───────────────────────────┴───────────────────────┘
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



### Step 8: Testing
Set up testing with Vitest and Playwright:

```
TESTING SETUP:
Unit/Component: Vitest + @testing-library/svelte
E2E: Playwright
Coverage target: > 80% statements, > 70% branches
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


### Step 9: Validation
Validate the Svelte application against best practices:

```
SVELTE APPLICATION AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│ Check │ Status │
├───────────────────────────────────────────┼──────────────────────┤
│ Svelte 5 runes used (if applicable) │ PASS | FAIL | N/A │
│ TypeScript enabled and strict │ PASS | FAIL │
│ Server load functions for data fetching │ PASS | FAIL │
│ Form actions for mutations │ PASS | FAIL │
│ Progressive enhancement (use:enhance) │ PASS | FAIL │
│ Rendering strategy per route │ PASS | FAIL │
│ Adapter configured for target platform │ PASS | FAIL │
│ Error pages defined (+error.svelte) │ PASS | FAIL │
│ Hooks for auth/logging │ PASS | FAIL │
│ Stores/state well-organized │ PASS | FAIL │
│ No $effect for derived state (use $derived)│ PASS | FAIL │
│ No fetch in components (use load) │ PASS | FAIL │
│ Accessibility attributes present │ PASS | FAIL │
│ Test coverage meets thresholds │ PASS | FAIL │
│ Bundle size within budget │ PASS | FAIL │
│ No unused imports or components │ PASS | FAIL │
│ Security headers configured (CSP) │ PASS | FAIL │
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

## Keep/Discard Discipline
Each change either advances the branch or gets reverted.
- **KEEP**: `svelte-check` passes, `vite build` succeeds, all existing tests pass.
- **DISCARD**: Type errors, build failures, or hydration mismatches introduced. Revert immediately.
- **CRASH**: Build or SSR failure. If fixable in one step (missing import, wrong adapter config), fix and retry. Otherwise revert.
- Log every action to `.godmode/svelte.tsv` with status.

## Stop Conditions
- `svelte-check` passes with zero errors.
- `vite build` completes without errors.
- No `$:` reactive statements in Svelte 5 projects (runes only).
- All `{#each}` blocks have a unique key expression.
- No secrets in `+page.ts` files (only in `+page.server.ts` or `+server.ts`).

## HARD RULES

1. **NEVER fetch data in `onMount`.** Use SvelteKit load functions. They run on the server, handle errors, are type-safe, and prevent waterfalls.
2. **NEVER create API routes for form submissions.** Use form actions with `use:enhance`. They are simpler, progressively enhanced, and handle validation natively.
3. **NEVER use `$effect` for derived state.** Use `$derived` or `$derived.by()`. Effects are for side effects only.
4. **NEVER put server secrets in `+page.ts`.** Use `+page.server.ts` for anything that touches secrets, databases, or private APIs.
5. **NEVER use `document` or `window` without guards.** Check `browser` from `$app/environment` or use `onMount` for client-only code.
6. **NEVER create global mutable state in modules.** Server-rendered pages share module scope across requests. Use stores or context.
7. **ALWAYS add `use:enhance` to forms.** Without it, every form submission causes a full page reload.
8. **ALWAYS use Svelte 5 runes for new projects.** Runes (`$state`, `$derived`, `$effect`) are more explicit, more powerful, and the future of Svelte.

## Output Format

End every Svelte skill invocation with this summary block:

```
SVELTE RESULT:
Action: <scaffold | component | route | store | optimize | test | audit | upgrade>
Components created/modified: <N>
Routes created/modified: <N>
Svelte version: <4 | 5>
Reactivity model: <runes | legacy | mixed>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Append one TSV row to `.godmode/svelte.tsv` after each invocation:

```
timestamp	project	action	components_count	routes_count	stores_count	tests_status	build_status	notes
```

Field definitions:
- `timestamp`: ISO-8601 UTC
- `project`: directory name from `basename $(pwd)`
- `action`: scaffold | component | route | store | optimize | test | audit | upgrade
- `components_count`: number of components created or modified
- `routes_count`: number of routes created or modified
- `stores_count`: number of stores created or modified
- `tests_status`: passing | failing | skipped | none
- `build_status`: passing | failing | not-checked
- `notes`: free-text, max 120 chars, no tabs

If `.godmode/` does not exist, create it and add `.godmode/` to `.gitignore` if not already present.

## Success Criteria

Every Svelte skill invocation must pass ALL of these checks before reporting success:

1. `svelte-check` passes with zero errors (run `npx svelte-check --tsconfig./tsconfig.json`)
2. `vite build` completes without errors
3. No `$:` reactive statements in Svelte 5 projects (use runes instead)
4. All `{#each}` blocks have a unique key expression
5. No `document` or `window` access without `browser` guard or `onMount`
6. No secrets in `+page.ts` files (only in `+page.server.ts` or `+server.ts`)
7. All form elements use `use:enhance` for progressive enhancement
8. Tests pass if test suite exists (`npx vitest run`)
9. No module-level mutable state in server-rendered pages
10. All load functions return typed data (TypeScript projects)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.
IF svelte-check fails:
 1. Read the error output line by line
 2. Fix type errors: add missing types, fix prop type mismatches
 3. Fix a11y warnings: add aria labels, alt text, role attributes
 4. Re-run svelte-check after each batch of fixes
 5. IF error is in a dependency → check that dependency version is compatible with Svelte version

IF vite build fails:
 1. Check for missing imports or circular dependencies
 2. Verify adapter configuration in svelte.config.js matches deployment target
 3. Check that server-only imports are not used in client code
 4. Verify all environment variables use $env/static or $env/dynamic correctly
 5. Run `vite build 2>&1 | head -50` and fix the first error

IF hydration mismatch occurs:
 1. Check for browser-only code running during SSR
 2. Wrap client-only code in `{#if browser}` blocks or `onMount`
 3. Verify no random/date values are generated during SSR without consistent seeding
 4. Check that stores are not shared across requests (use context instead)

IF load function errors:
 1. Verify +page.server.ts vs +page.ts placement (server secrets must be in.server)
 2. Check that error() and redirect() are thrown, not returned
 3. Verify parent() calls are awaited in nested layouts
 4. Check that invalidateAll() or invalidate() is called after mutations

IF test failures:
 1. Verify @testing-library/svelte version matches Svelte version
 2. Check that component props match expected types
 3. Verify async state changes are wrapped in act() or waitFor()
 4. Check that mocked stores use the correct writable/readable interface
```
