---
name: svelte
description: >
  Svelte/SvelteKit mastery. Runes reactivity, stores,
  routing, form actions, SSR, adapter configuration.
---

# Svelte -- Svelte/SvelteKit Mastery

## Activate When
- `/godmode:svelte`, "Svelte app", "SvelteKit"
- "Svelte stores", "runes", "$state", "load functions"
- "form actions", "SvelteKit routing"

## Auto-Detection
```bash
cat package.json 2>/dev/null \
  | grep -E '"svelte"|"@sveltejs/kit"'
ls svelte.config.js svelte.config.ts 2>/dev/null
```

## Workflow

### Step 1: Project Assessment
```
Svelte version: <4 / 5>
Meta-framework: SvelteKit | standalone
Reactivity: Runes ($state) | Legacy ($:) | Mixed
State: Svelte stores | Runes | external
Routing: SvelteKit file-based | custom
CSS: Tailwind | UnoCSS | SCSS | scoped
```
IF starting fresh: "Need SSR? Use SvelteKit."

### Step 2: Reactivity Model
```
DECISION:
IF new project + Svelte 5: use Runes
IF existing Svelte 4: keep legacy unless migrating
IF mixed codebase: plan migration, don't stay mixed

| Factor        | Runes (Svelte 5) | Legacy (4)   |
|--------------|-----------------|-------------|
| Explicitness | $state (explicit)| let (implicit)|
| Computed     | $derived (clear) | $: (ambiguous)|
| Side effects | $effect          | $: (overloaded)|
| Props        | $props() (typed) | export let   |
| Granularity  | Signal-based     | Component    |
```

### Step 3: Stores
```
Svelte 5: reactive classes (.svelte.ts)
Svelte 4: writable/readable/derived stores
Rules:
  One store per domain (cart, auth, notifications)
  Expose minimal API (subscribe + methods)
  Derived stores for computed values
  Server-safe (no client state in global scope)
```

### Step 4: SvelteKit Routing
```
src/routes/
├── +layout.svelte        Root layout
├── +layout.server.ts     Root data (session)
├── +page.svelte          Home (/)
├── +page.server.ts       Home data loader
├── auth/login/+page.svelte
├── dashboard/+layout.server.ts  Auth guard
└── blog/[slug]/+page.server.ts  Dynamic
```
Rules:
- Server load for data (+page.server.ts)
- Layout load for shared data (session, user)
- Form actions for mutations (use:enhance)
- Auth guards in layout loads (redirect)
- Route groups `(name)` for URL-free grouping

### Step 5: Rendering Strategy
```
| Route           | Strategy  | Reason          |
|----------------|----------|----------------|
| /              | Prerender | Static, fast   |
| /about, /pricing| Prerender| Marketing, SEO |
| /blog/[slug]   | SSR+cache| Dynamic, SEO   |
| /dashboard/**  | CSR      | Auth-gated     |
| /api/**        | Server   | API endpoints  |
```
```typescript
// Prerender: export const prerender = true;
// CSR only: export const ssr = false;
```

### Step 6: Adapter Configuration
```
| Platform   | Adapter                       |
|-----------|------------------------------|
| Vercel    | @sveltejs/adapter-vercel      |
| Cloudflare| @sveltejs/adapter-cloudflare  |
| Node.js   | @sveltejs/adapter-node        |
| Static    | @sveltejs/adapter-static      |
```

### Step 7: Testing
```bash
# Run component tests
npx vitest run

# Run e2e tests
npx playwright test

# Check types
npx svelte-check --tsconfig ./tsconfig.json
```
Coverage target: >80% statements, >70% branches.

### Step 8: Validation
```
| Check                        | Status |
|------------------------------|--------|
| Svelte 5 runes used         | PASS   |
| TypeScript strict            | PASS   |
| Server load for data         | PASS   |
| Form actions for mutations   | PASS   |
| use:enhance on forms         | PASS   |
| No secrets in +page.ts       | PASS   |
| Each {#each} has unique key  | PASS   |
```

## Key Behaviors
1. **SvelteKit by default.** Routing, SSR, deploy.
2. **Runes for Svelte 5.** Explicit, powerful.
3. **Load functions, not fetch-in-component.**
4. **Form actions over API routes.** Progressive.
5. **Never ask to continue. Loop autonomously.**

<!-- tier-3 -->

## Quality Targets
- Initial JS per route: <50KB
- Component render: <100ms paint time
- Lighthouse score: >90 performance

## HARD RULES
1. NEVER fetch data in onMount. Use load functions.
2. NEVER create API routes for form submissions.
3. NEVER use $effect for derived state. Use $derived.
4. NEVER put secrets in +page.ts. Use +page.server.ts.
5. NEVER use document/window without browser guard.
6. NEVER create global mutable state in modules.
7. ALWAYS add use:enhance to forms.
8. ALWAYS use Svelte 5 runes for new projects.

## TSV Logging
Log to `.godmode/svelte.tsv`:
`timestamp\taction\tcomponents\troutes\tstores\ttests\tbuild`

## Output Format
```
SVELTE: {action}. Components: {N}. Routes: {N}.
Reactivity: {runes|legacy}. Build: {status}.
```

## Keep/Discard Discipline
```
KEEP if: svelte-check passes AND vite build succeeds
  AND all existing tests pass
DISCARD if: type errors OR build failures
  OR hydration mismatches. Revert immediately.
```

## Stop Conditions
```
STOP when:
  - svelte-check zero errors
  - vite build completes
  - No $: in Svelte 5 projects (runes only)
  - No secrets in +page.ts files
```
