---
name: vue
description: |
 Vue.js mastery skill. Activates when user needs to build, architect, or optimize Vue.js applications. Covers Composition API vs Options API decision-making, Pinia state management, Vue Router configuration, Nuxt.js SSR/SSG patterns, Vite optimization, and testing with Vitest and Vue Test Utils. Triggers on: /godmode:vue, "build a Vue app", "Vue component", "Nuxt project", "Pinia store", or when the orchestrator detects Vue-related work.
---

# Vue — Vue.js Mastery

## When to Activate
- User invokes `/godmode:vue`
- User says "build a Vue app", "Vue component", "Vue project"
- User mentions "Composition API", "Options API", "Pinia", "Vue Router"
- User says "Nuxt project", "Nuxt SSR", "Nuxt SSG"
- When creating or scaffolding a Vue.js application
- When `/godmode:plan` identifies Vue.js tasks
- When `/godmode:review` flags Vue-specific patterns

## Auto-Detection

Run this sequence at skill start to determine project context:

```bash
# Detect Vue presence and version
cat package.json 2>/dev/null | grep -E '"vue"|"nuxt"|"@vue/"'

# Detect Vue version (2 vs 3)
cat node_modules/vue/package.json 2>/dev/null | grep '"version"'

```
## Workflow

### Step 1: Project Discovery & Assessment
Survey the existing project or determine new project requirements:

```
VUE PROJECT ASSESSMENT:
Vue version: <2.x / 3.x>
Build tool: <Vite / Webpack / Nuxt>
API style: <Composition API / Options API / Mixed>
State management: <Pinia / Vuex / none>
Router: <Vue Router / file-based (Nuxt) / none>
UI library: <Vuetify / PrimeVue / Quasar / Headless UI / custom / none>
CSS approach: <Tailwind / UnoCSS / SCSS / CSS Modules / scoped styles>
Testing: <Vitest / Jest / none>
TypeScript: <yes / no>
Meta-framework: <Nuxt 3 / none>
Component count: <N>

Directory structure:
 src/
```
If starting fresh, ask: "What are you building? Do you need SSR (Nuxt) or is a SPA sufficient?"

### Step 2: API Style Decision — Composition vs Options

Guide the decision between Composition API and Options API:

```
API STYLE DECISION:
| Factor | Composition API | Options API |
|--|--|--|
| Vue version | Vue 3 (native) | Vue 2 & 3 |
| TypeScript support | Excellent (inferred) | Requires decorators |
| Logic reuse | Composables (natural) | Mixins (fragile) |
| Code organization | By feature/concern | By option type |
| Learning curve | Steeper initially | Gentler for beginners |
| Bundle size | Tree-shakeable | Full runtime needed |
| Complex components | Scales well | Gets unwieldy |
| Small components | Works fine | Simpler syntax |

RECOMMENDATION: <Composition API | Options API>
JUSTIFICATION: <reason based on project context>
```
Rules:
- **New Vue 3 projects:** Default to Composition API with `<script setup>`
- **Existing Vue 2 projects:** Keep Options API unless migrating to Vue 3
- **Mixed codebases:** Establish migration plan — do not leave permanently mixed
- **Team experience:** If team is new to Vue, Options API for initial learning, then migrate

### Step 3: Composition API Patterns
When using Composition API, enforce these patterns:

#### Component Structure
```vue
<script setup lang="ts">
// 1. Imports (external, then internal)
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import type { User } from '@/types'

// 2. Props and emits
const props = defineProps<{
 userId: string
 editable?: boolean
}>()

const emit = defineEmits<{
 save: [user: User]
```

#### Composable Patterns
```typescript
// composables/useUser.ts — Composable naming: use<Feature>
import { ref, computed } from 'vue'
import type { User } from '@/types'

export function useUser(userId: MaybeRef<string>) {
 const user = ref<User | null>(null)
```

Rules for composables:
- Name with `use` prefix: `useAuth`, `useCart`, `usePagination`
- Accept `MaybeRef` arguments for flexibility
- Return reactive state (refs/computed) and methods
- Handle loading and error states internally
- Keep composables focused — one concern per composable
- Test composables independently from components

### Step 4: Pinia State Management
Design and implement Pinia stores:

```
PINIA STORE ARCHITECTURE:
| Store | Purpose | Persistence |
|--|--|--|
| useAuthStore | Authentication state | localStorage (token) |
| useUserStore | User profile data | Session only |
| useCartStore | Shopping cart | localStorage |
| useNotifyStore | Toast notifications | Session only |
| useSettingsStore | User preferences | localStorage |
```
#### Setup Store Pattern (Recommended)
```typescript
// stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

export const useAuthStore = defineStore('auth', () => {
```

Rules for Pinia:
- **Setup syntax** (Composition API style) for new stores — better TypeScript and composable integration
- **One store per domain** — not one mega-store
- **Stores can use other stores** — but avoid circular dependencies
- **Persist selectively** — only persist what needs to survive page refresh
- **Keep actions async-aware** — always handle loading/error states
- **Use `storeToRefs`** for destructuring to maintain reactivity

### Step 5: Vue Router Configuration
Design routing architecture:

```
ROUTE ARCHITECTURE:
| Path | Component | Guard | Meta |
|--|--|--|--|
| / | Home.vue | none |  |
| /login | Login.vue | guest-only |  |
| /dashboard | Dashboard.vue | auth-required |  |
| /users/:id | UserProfile.vue | auth-required |  |
| /admin/* | AdminLayout.vue | admin-only | lazy |
| /:pathMatch(.*)* | NotFound.vue | none |  |
```
#### Router Setup
```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
 history: createWebHistory(import.meta.env.BASE_URL),
```

Rules:
- **Lazy-load all route components** — use dynamic `import()` for code splitting
- **Use layouts** — shared layouts via nested routes, not repeated templates
- **Navigation guards** — centralize auth checks in global guards, not per-component
- **Typed route params** — use `defineProps` with router or typed `useRoute`
- **Scroll behavior** — always define, restore saved position for back navigation
- **404 catch-all** — always define a catch-all route last

### Step 6: Nuxt.js SSR/SSG Patterns
For projects using Nuxt 3:

```
NUXT RENDERING STRATEGY:
| Route Pattern | Strategy | Reason |
|--|--|--|
| / | SSG | Static marketing page |
| /blog/:slug | ISR (60s) | Content changes infrequently |
| /dashboard | SPA | Auth-gated, dynamic data |
| /api/* | Server-only | API routes |
| /products/:id | SSR | SEO-critical, dynamic data |
```
#### Nuxt Configuration
```typescript
// nuxt.config.ts
export default defineNuxtConfig({
 // Hybrid rendering — per-route strategy
 routeRules: {
 '/': { prerender: true }, // SSG at build time
 '/blog/**': { isr: 60 }, // ISR — revalidate every 60s
```

Rules for Nuxt:
- **Choose rendering strategy per route** — not one strategy for the entire app
- **Use `useAsyncData` over `useFetch`** when you need transforms or custom keys
- **Always provide keys** — prevents duplicate fetches and enables proper caching
- **Use `$fetch` in API routes** — not `axios` or `fetch`, to get auto-typed responses
- **Runtime config over hardcoded values** — access env vars via `useRuntimeConfig()`
- **Server routes in `server/api/`** — use Nitro's file-based API routing

### Step 7: Vite Optimization
- Pre-bundle heavy deps in `optimizeDeps.include`, manual chunks for vendors, target `es2020`, analyze with `rollup-plugin-visualizer`

### Step 8: Testing with Vitest and Vue Test Utils
Set up and write comprehensive tests:

```
TESTING SETUP:
Framework: Vitest (recommended) | Jest
Component testing: @vue/test-utils
E2E: Playwright | Cypress
Coverage target: > 80% (statements), > 70% (branches)
```
#### Component Testing Patterns
```typescript
// tests/components/UserCard.test.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import UserCard from '@/components/UserCard.vue'

```

### Step 9: Validation
Validate the Vue application against best practices:

```
VUE APPLICATION AUDIT:
| Check | Status |
|--|--|
| API style consistency (Comp/Options) | PASS | FAIL |
| <script setup> used where possible | PASS | FAIL |
| TypeScript strict mode enabled | PASS | FAIL |
| Composables follow use* convention | PASS | FAIL |
| Pinia stores use setup syntax | PASS | FAIL |
| Route components lazy-loaded | PASS | FAIL |
| Navigation guards centralized | PASS | FAIL |
| Props typed with defineProps<T> | PASS | FAIL |
| Emits typed with defineEmits<T> | PASS | FAIL |
| No direct DOM manipulation | PASS | FAIL |
| No v-html with user input | PASS | FAIL |
```
### Step 10: Deliverables & Handoff
Generate the project artifacts:

Commit: `"vue: <project> — <N> components, <M> stores, <Composition API | Options API>"`
Next: `/godmode:tailwind`, `/godmode:a11y`, `/godmode:e2e`, `/godmode:build`, `/godmode:ship`

## Key Behaviors

1. **Composition API by default.** New Vue 3 projects use `<script setup>` with Composition API. Options API only for Vue 2 maintenance or explicit team preference.
2. **Composables over mixins.** Logic reuse happens through composables, never mixins. Mixins are a legacy pattern with name collision and implicit dependency problems.
3. **Pinia over Vuex.** Pinia is the official Vue 3 state management solution. Vuex is legacy. Setup stores for TypeScript projects.
4. **Lazy-load everything.** Route components, heavy libraries, below-fold content. Vite makes code splitting trivial.
5. **Type everything.** Props, emits, store state, composable returns, route params. TypeScript catches bugs that tests miss.
6. **Test composables independently.** Composables are pure logic; test them without mounting components. Test components for rendering and interaction.
7. **Choose rendering strategy per route.** Nuxt hybrid rendering lets you SSG marketing pages, SSR product pages, and SPA dashboards in one app.
8. **On failure: git reset --hard HEAD~1.**
9. **Never ask to continue. Loop autonomously until all audit checks pass or budget exhausted.**

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full Vue project assessment and setup |
| `--audit` | Audit existing Vue project against best practices |
| `--migrate` | Migrate Options API to Composition API |

## TSV Logging

Append one row per invocation to `.godmode/vue-results.tsv`:

```
timestamp	project	action	components_count	stores_count	composables_count	audit_status	notes
```
IF `.godmode/` directory does not exist, create it.

## Success Criteria

A Vue skill invocation is successful when ALL of the following are true:

1. `npx vue-tsc --noEmit` passes with zero errors (or `npx tsc --noEmit` for non-Vue TS files).
2. All existing tests pass (`npx vitest run`).
3. No mixins used in Vue 3 projects.
4. All props typed with `defineProps<T>()` and emits typed with `defineEmits<T>()`.
5. All route components lazy-loaded with dynamic `import()`.
6. Every `v-for` has a `:key` attribute using a unique identifier (not index).
7. No `v-html` with unsanitized user input.
8. Pinia stores use setup syntax (Composition API style) in new projects.
9. The validation audit (Step 9) shows PASS on all applicable checks.

IF any criterion fails, fix before marking the invocation complete.

## Keep/Discard Discipline
Each change either advances the branch or gets reverted. No half-finished work remains.
- **KEEP**: `vue-tsc --noEmit` passes, all existing tests pass, audit checklist shows no regressions.
- **DISCARD**: Type errors introduced, test failures, or bundle size exceeds budget. Revert immediately.
- **CRASH**: Build or HMR failure after change. If fixable in one step, fix and retry. Otherwise revert.
- Log every action to `.godmode/vue-results.tsv` with status `keep`, `discard`, or `crash`.

## Stop Conditions
- All audit checks in Step 9 show PASS.
- `vue-tsc --noEmit` exits 0 and `vitest run` exits 0.
- Bundle size (gzipped) is within the project budget.
- No remaining v-for without :key, no v-html with unsanitized input, no mixins in Vue 3.

## HARD RULES

1. **NEVER use mixins in Vue 3.** Use composables. Mixins cause name collisions, implicit dependencies, and untraceable data flow.
2. **NEVER use Vuex in new projects.** Pinia is the official recommendation with better TypeScript support and simpler API.
3. **NEVER mutate props.** Props are read-only. Use `emit` to notify the parent, or use a local ref copy.
4. **NEVER skip `key` on `v-for`.** Missing keys cause subtle reactivity bugs and broken animations.
5. **NEVER use `v-html` with user input.** It creates XSS vulnerabilities. Sanitize first, or use text interpolation.
6. **ALWAYS lazy-load routes with dynamic `import()`.** Every route loaded upfront is bundle bloat users pay for.
7. **ALWAYS extract business logic to composables.** Components handle rendering; composables handle logic.
8. **NEVER use `reactive()` for primitives.** Use `ref()` for primitives. `reactive()` is for objects when you want deep reactivity without `.value`.

## Output Format
Print: `Vue: {action} complete. Components: {N}. Stores: {N}. Composables: {N}. vue-tsc: {pass|fail}. Status: {DONE|PARTIAL}.`

## Error Recovery
| Failure | Action |
|--|--|
| `vue-tsc` type errors | Read error output line by line. Fix prop type mismatches, missing generic args, and incorrect emit signatures first. Re-run after each batch. |
| HMR not reflecting changes | Check for circular imports in composables. Verify Vite config `optimizeDeps.include` lists heavy deps. Restart dev server as last resort. |
| Pinia store not reactive after destructure | Use `storeToRefs()` for state/getters. Direct destructure loses reactivity. Destructure actions directly. |
| Hydration mismatch (Nuxt) | Wrap browser-only code in `<ClientOnly>` or `onMounted`. Avoid `Date.now()` or `Math.random()` during SSR. |
