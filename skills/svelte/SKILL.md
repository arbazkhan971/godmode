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
  ...
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
  ...
```

Decision guide:
```
REACTIVITY MODEL DECISION:
| Factor | Runes (Svelte 5) | Legacy (Svelte 4) |
|--|--|--|
| Explicitness | Explicit ($state) | Implicit (let) |
| Computed values | $derived (clear) | $: (ambiguous) |
| Side effects | $effect (dedicated) | $: (overloaded) |
| Props | $props() (typed) | export let (basic) |
| Fine-grained | Yes (signal-based) | Component-level |
  ...
```

### Step 3: Svelte Stores
Design state management with stores:

#### Svelte 5 — Shared State with Runes
```typescript
// lib/stores/cart.svelte.ts
import type { CartItem, Product } from '$lib/types';

class CartStore {
 items = $state<CartItem[]>([]);

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
  ...
```
#### Load Functions
```typescript
// routes/blog/[slug]/+page.server.ts
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { db } from '$lib/server/database';

export const load: PageServerLoad = async ({ params, locals, depends }) => {
```

```typescript
// routes/dashboard/+layout.server.ts — Auth guard via layout load
import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
 if (!locals.user) {
```
#### Form Actions
```typescript
// routes/blog/[slug]/+page.server.ts
import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { db } from '$lib/server/database';

export const load: PageServerLoad = async ({ params }) => {
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
| Route | Strategy | Reason |
|--|--|--|
| / | Prerender | Static content, fast load |
| /about, /pricing | Prerender | Marketing pages, SEO |
| /blog/[slug] | SSR + cache | Dynamic, SEO-critical |
| /dashboard/** | CSR (ssr:false) | Auth-gated, no SEO need |
| /api/** | Server-only | API endpoints |
  ...
```
#### Per-Route Configuration
```typescript
// routes/(marketing)/about/+page.ts
// Prerender at build time
export const prerender = true;

// routes/dashboard/+layout.ts
// Disable SSR for dashboard (client-only rendering)
```

### Step 6: Adapter Configuration
Configure the deployment adapter:

```
ADAPTER SELECTION:
| Platform | Adapter | Notes |
|--|--|--|
| Vercel | @sveltejs/adapter-vercel | Edge/Serverless |
| Cloudflare | @sveltejs/adapter-cloudflare | Workers/Pages |
| Netlify | @sveltejs/adapter-netlify | Functions + CDN |
| Node.js | @sveltejs/adapter-node | Express/Fastify host |
| Static (SPA) | @sveltejs/adapter-static | GitHub Pages, S3 |
  ...
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
  ...
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
```

### Step 9: Validation
Validate the Svelte application against best practices:

```
SVELTE APPLICATION AUDIT:
| Check | Status |
|--|--|
| Svelte 5 runes used (if applicable) | PASS | FAIL | N/A |
| TypeScript enabled and strict | PASS | FAIL |
| Server load functions for data fetching | PASS | FAIL |
| Form actions for mutations | PASS | FAIL |
| Progressive enhancement (use:enhance) | PASS | FAIL |
  ...
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
  ...
```
Commit: `"svelte: <project> — <N> routes, <N> components, <SvelteKit | Svelte>, <adapter>"`

## Key Behaviors

1. **SvelteKit by default.** Unless building a widget or embedded component, use SvelteKit. It handles routing, SSR, data loading, and deployment out of the box.
2. **Runes for Svelte 5.** New Svelte 5 projects use runes (`$state`, `$derived`, `$effect`). They are more explicit, more powerful, and the future of Svelte.
3. **Load functions, not fetch-in-component.** Data fetching belongs in `+page.server.ts` load functions, not in `onMount`. Load functions run on the server, are type-safe, and handle errors properly.
4. **Form actions over API routes.** For mutations (create, update, delete), use form actions with `use:enhance`. They work without JavaScript and are progressively enhanced.
## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full Svelte/SvelteKit project assessment and setup |
| `--audit` | Audit existing Svelte project against best practices |
| `--migrate` | Migrate Svelte 4 to Svelte 5 runes |

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
  ...
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
## Error Recovery
| Failure | Action |
|--|--|
| `svelte-check` type errors | Read errors line by line. Fix prop type mismatches and missing types first. Re-run after each batch of fixes. |
| Hydration mismatch | Wrap browser-only code in `{#if browser}` or `onMount`. Check for `Date.now()` or `Math.random()` in SSR. |
| Load function errors | Verify `+page.server.ts` vs `+page.ts` placement. Ensure `error()` and `redirect()` are thrown, not returned. Await `parent()` calls. |
| `$:` reactive statements in Svelte 5 | Replace with runes: `$state` for state, `$derived` for computed, `$effect` for side effects. |
  ...
