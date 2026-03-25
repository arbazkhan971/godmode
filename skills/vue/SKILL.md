---
name: vue
description: >
  Vue.js mastery. Composition API, Pinia, Vue Router,
  Nuxt SSR/SSG, Vite optimization, testing.
---

# Vue -- Vue.js Mastery

## Activate When
- `/godmode:vue`, "Vue app", "Vue component"
- "Composition API", "Pinia", "Vue Router"
- "Nuxt project", "Nuxt SSR", "Nuxt SSG"

## Auto-Detection
```bash
cat package.json 2>/dev/null \
  | grep -E '"vue"|"nuxt"|"@vue/"'
cat node_modules/vue/package.json 2>/dev/null \
  | grep '"version"'
```

## Workflow

### Step 1: Project Assessment
```
Vue version: <2.x / 3.x>
Build tool: Vite | Webpack | Nuxt
API style: Composition | Options | Mixed
State: Pinia | Vuex | none
Router: Vue Router | file-based (Nuxt)
CSS: Tailwind | UnoCSS | SCSS | scoped
TypeScript: yes | no
Meta-framework: Nuxt 3 | none
```
IF starting fresh: "Need SSR? Use Nuxt."

### Step 2: API Style Decision
```
| Factor       | Composition API  | Options API  |
|-------------|-----------------|-------------|
| Vue version | Vue 3 (native)  | Vue 2 & 3   |
| TypeScript  | Excellent       | Requires decorators|
| Logic reuse | Composables     | Mixins (fragile)|
| Organization| By feature      | By option type|
| Bundle      | Tree-shakeable  | Full runtime |
| Complex comp| Scales well     | Gets unwieldy|

IF new Vue 3 project: Composition API + <script setup>
IF existing Vue 2: keep Options unless migrating
IF mixed codebase: plan migration, don't stay mixed
WHEN team is new to Vue: Options first, then migrate
```

### Step 3: Composition API Patterns
```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import type { User } from '@/types'

const props = defineProps<{ userId: string }>()
const emit = defineEmits<{ save: [user: User] }>()
</script>
```
Composable rules:
- Name with `use` prefix: useAuth, useCart
- Accept MaybeRef arguments for flexibility
- Return reactive state (refs/computed) + methods
- Handle loading and error states internally
- Test composables independently from components

### Step 4: Pinia State Management
```
| Store         | Purpose        | Persistence  |
|--------------|---------------|-------------|
| useAuthStore | Authentication| localStorage |
| useUserStore | User profile  | Session only |
| useCartStore | Shopping cart | localStorage |
```
Rules:
- Setup syntax (Composition API) for new stores
- One store per domain, not mega-store
- Persist selectively (only what survives refresh)
- Use storeToRefs for destructuring reactivity

### Step 5: Vue Router
```
| Path           | Component  | Guard        |
|---------------|-----------|-------------|
| /             | Home.vue  | none         |
| /dashboard    | Dashboard | auth-required|
| /admin/*      | Admin     | admin-only   |
| /:pathMatch(*)| NotFound  | none         |
```
Rules:
- Lazy-load all route components (dynamic import)
- Centralize auth in global guards, not per-component
- Always define scroll behavior and 404 catch-all

### Step 6: Nuxt Rendering Strategy
```
| Route          | Strategy | Reason         |
|---------------|---------|---------------|
| /             | SSG     | Static, fast   |
| /blog/:slug   | ISR 60s | Content, SEO   |
| /dashboard    | SPA     | Auth-gated     |
| /products/:id | SSR     | Dynamic, SEO   |
```
```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  routeRules: {
    '/': { prerender: true },
    '/blog/**': { isr: 60 },
    '/dashboard/**': { ssr: false },
  }
})
```
Rules:
- Choose rendering per route, not whole app
- useAsyncData over useFetch for transforms
- Always provide keys (prevent duplicate fetches)
- Runtime config over hardcoded values

### Step 7: Testing
```bash
# Run unit/component tests
npx vitest run

# Run e2e tests
npx playwright test

# Type check
npx vue-tsc --noEmit
```
Coverage target: >80% statements, >70% branches.

### Step 8: Validation
```
| Check                          | Status |
|-------------------------------|--------|
| API style consistent          | PASS   |
| <script setup> used           | PASS   |
| TypeScript strict             | PASS   |
| Composables use* convention   | PASS   |
| Pinia setup syntax            | PASS   |
| Routes lazy-loaded            | PASS   |
| Props typed (defineProps<T>)  | PASS   |
| Emits typed (defineEmits<T>) | PASS   |
| No v-html with user input    | PASS   |
| Every v-for has :key          | PASS   |
```

## Key Behaviors
1. **Composition API by default** for Vue 3.
2. **Composables over mixins.** Always.
3. **Pinia over Vuex.** Official Vue 3 solution.
4. **Lazy-load everything.** Routes, heavy libs.
5. **Type everything.** Props, emits, stores.
6. **Choose rendering per route** (Nuxt hybrid).
7. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER use mixins in Vue 3. Use composables.
2. NEVER use Vuex in new projects. Use Pinia.
3. NEVER mutate props. Emit to parent.
4. NEVER skip :key on v-for.
5. NEVER use v-html with unsanitized user input.
6. ALWAYS lazy-load routes with dynamic import().
7. ALWAYS extract logic to composables.
8. NEVER use reactive() for primitives. Use ref().

## TSV Logging
Log to `.godmode/vue-results.tsv`:
`timestamp\taction\tcomponents\tstores\tcomposables\tstatus`

## Output Format
Print: `Vue: {action}. Components: {N}. Stores: {N}. vue-tsc: {status}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
KEEP if: vue-tsc passes AND tests pass
  AND audit shows no regressions
DISCARD if: type errors OR test failures
  OR bundle exceeds budget. Revert immediately.
```

## Stop Conditions
```
STOP when:
  - All audit checks PASS
  - vue-tsc --noEmit exits 0
  - vitest run exits 0
  - No v-for without :key, no v-html, no mixins
```
