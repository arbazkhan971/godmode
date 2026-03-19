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
    components/    <N> components
    composables/   <N> composables
    stores/        <N> Pinia stores
    views/         <N> route views
    router/        Router config
    assets/        Static assets
    utils/         Utility functions

Quality score: <HIGH / MEDIUM / LOW>
Issues detected: <N>
```

If starting fresh, ask: "What are you building? Do you need SSR (Nuxt) or is a SPA sufficient?"

### Step 2: API Style Decision — Composition vs Options

Guide the decision between Composition API and Options API:

```
API STYLE DECISION:
┌──────────────────────────────────────────────────────────────────────────┐
│  Factor                 │  Composition API       │  Options API          │
├─────────────────────────┼────────────────────────┼───────────────────────┤
│  Vue version            │  Vue 3 (native)        │  Vue 2 & 3            │
│  TypeScript support     │  Excellent (inferred)  │  Requires decorators  │
│  Logic reuse            │  Composables (natural) │  Mixins (fragile)     │
│  Code organization      │  By feature/concern    │  By option type        │
│  Learning curve         │  Steeper initially     │  Gentler for beginners │
│  Bundle size            │  Tree-shakeable         │  Full runtime needed   │
│  Complex components     │  Scales well           │  Gets unwieldy         │
│  Small components       │  Works fine            │  Simpler syntax        │
└─────────────────────────┴────────────────────────┴───────────────────────┘

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
  cancel: []
}>()

// 3. Composables
const router = useRouter()
const userStore = useUserStore()
const { data, loading, error } = useAsyncData(() => fetchUser(props.userId))

// 4. Reactive state
const isEditing = ref(false)
const formData = ref<Partial<User>>({})

// 5. Computed properties
const displayName = computed(() =>
  `${data.value?.firstName} ${data.value?.lastName}`
)

// 6. Watchers
watch(() => props.userId, (newId) => {
  // Re-fetch when userId changes
  fetchUser(newId)
})

// 7. Methods
function startEditing() {
  isEditing.value = true
  formData.value = { ...data.value }
}

function saveChanges() {
  emit('save', formData.value as User)
  isEditing.value = false
}

// 8. Lifecycle hooks
onMounted(() => {
  // Analytics, DOM access, etc.
})
</script>

<template>
  <!-- Template uses flat, readable structure -->
</template>

<style scoped>
/* Component-scoped styles */
</style>
```

#### Composable Patterns
```typescript
// composables/useUser.ts — Composable naming: use<Feature>
import { ref, computed } from 'vue'
import type { User } from '@/types'

export function useUser(userId: MaybeRef<string>) {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const fullName = computed(() =>
    user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
  )

  async function fetch() {
    loading.value = true
    error.value = null
    try {
      user.value = await api.getUser(toValue(userId))
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  // Return reactive state + methods
  return { user, loading, error, fullName, fetch }
}
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
┌─────────────────────────────────────────────────────────────────────┐
│  Store              │  Purpose              │  Persistence          │
├─────────────────────┼───────────────────────┼───────────────────────┤
│  useAuthStore       │  Authentication state │  localStorage (token) │
│  useUserStore       │  User profile data    │  Session only         │
│  useCartStore       │  Shopping cart        │  localStorage         │
│  useNotifyStore     │  Toast notifications  │  Session only         │
│  useSettingsStore   │  User preferences     │  localStorage         │
└─────────────────────┴───────────────────────┴───────────────────────┘
```

#### Setup Store Pattern (Recommended)
```typescript
// stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

export const useAuthStore = defineStore('auth', () => {
  // State
  const token = ref<string | null>(localStorage.getItem('token'))
  const user = ref<User | null>(null)
  const loading = ref(false)

  // Getters (computed)
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'admin')

  // Actions
  async function login(credentials: LoginCredentials) {
    loading.value = true
    try {
      const response = await api.login(credentials)
      token.value = response.token
      user.value = response.user
      localStorage.setItem('token', response.token)
    } finally {
      loading.value = false
    }
  }

  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
    useRouter().push('/login')
  }

  return { token, user, loading, isAuthenticated, isAdmin, login, logout }
})
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
┌──────────────────────────────────────────────────────────────────────┐
│  Path                    │  Component       │  Guard         │ Meta │
├──────────────────────────┼──────────────────┼────────────────┼──────┤
│  /                       │  Home.vue        │  none          │      │
│  /login                  │  Login.vue       │  guest-only    │      │
│  /dashboard              │  Dashboard.vue   │  auth-required │      │
│  /users/:id              │  UserProfile.vue │  auth-required │      │
│  /admin/*                │  AdminLayout.vue │  admin-only    │ lazy │
│  /:pathMatch(.*)*        │  NotFound.vue    │  none          │      │
└──────────────────────────┴──────────────────┴────────────────┴──────┘
```

#### Router Setup
```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  scrollBehavior(to, from, savedPosition) {
    return savedPosition || { top: 0 }
  },
  routes: [
    {
      path: '/',
      component: () => import('@/layouts/DefaultLayout.vue'),
      children: [
        { path: '', name: 'home', component: () => import('@/views/Home.vue') },
        { path: 'about', name: 'about', component: () => import('@/views/About.vue') },
      ],
    },
    {
      path: '/auth',
      component: () => import('@/layouts/AuthLayout.vue'),
      meta: { guestOnly: true },
      children: [
        { path: 'login', name: 'login', component: () => import('@/views/Login.vue') },
        { path: 'register', name: 'register', component: () => import('@/views/Register.vue') },
      ],
    },
    {
      path: '/dashboard',
      component: () => import('@/layouts/DashboardLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        // Lazy-loaded dashboard routes
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/NotFound.vue'),
    },
  ],
})

// Navigation guards
router.beforeEach((to, from) => {
  const auth = useAuthStore()

  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  if (to.meta.guestOnly && auth.isAuthenticated) {
    return { name: 'home' }
  }
})

export default router
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
┌───────────────────────────────────────────────────────────────────────┐
│  Route Pattern         │  Strategy    │  Reason                       │
├────────────────────────┼──────────────┼───────────────────────────────┤
│  /                     │  SSG         │  Static marketing page        │
│  /blog/:slug           │  ISR (60s)   │  Content changes infrequently │
│  /dashboard            │  SPA         │  Auth-gated, dynamic data     │
│  /api/*                │  Server-only │  API routes                   │
│  /products/:id         │  SSR         │  SEO-critical, dynamic data   │
└────────────────────────┴──────────────┴───────────────────────────────┘
```

#### Nuxt Configuration
```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  // Hybrid rendering — per-route strategy
  routeRules: {
    '/': { prerender: true },                     // SSG at build time
    '/blog/**': { isr: 60 },                      // ISR — revalidate every 60s
    '/dashboard/**': { ssr: false },              // SPA — client-only
    '/api/**': { cors: true, headers: { 'cache-control': 'no-store' } },
  },

  // Modules
  modules: [
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
    '@nuxt/image',
    '@nuxt/fonts',
  ],

  // Runtime config (environment variables)
  runtimeConfig: {
    secretKey: process.env.SECRET_KEY,        // Server-only
    public: {
      apiBase: process.env.API_BASE || '/api', // Client + server
    },
  },

  // TypeScript
  typescript: {
    strict: true,
    typeCheck: true,
  },

  // Experimental features
  experimental: {
    typedPages: true,
  },
})
```

#### Nuxt Data Fetching Patterns
```vue
<script setup lang="ts">
// useAsyncData — cached, deduplicated, SSR-friendly
const { data: posts, pending, error, refresh } = await useAsyncData(
  'posts',
  () => $fetch('/api/posts'),
  {
    transform: (data) => data.map(normalizePost),
    watch: [page],           // Re-fetch when page ref changes
    default: () => [],       // Default value while loading
  }
)

// useFetch — shorthand for useAsyncData + $fetch
const { data: user } = await useFetch(`/api/users/${route.params.id}`, {
  key: `user-${route.params.id}`,
  pick: ['id', 'name', 'email'],  // Only include these fields (smaller payload)
})

// Server-only data (never sent to client bundle)
const { data: analytics } = await useAsyncData('analytics', () => {
  // This runs only on server
  return fetchAnalytics()
}, { server: true, lazy: true })
```

Rules for Nuxt:
- **Choose rendering strategy per route** — not one strategy for the entire app
- **Use `useAsyncData` over `useFetch`** when you need transforms or custom keys
- **Always provide keys** — prevents duplicate fetches and enables proper caching
- **Use `$fetch` in API routes** — not `axios` or `fetch`, to get auto-typed responses
- **Runtime config over hardcoded values** — access env vars via `useRuntimeConfig()`
- **Auto-imports are fine** — Nuxt auto-imports Vue APIs, composables, and components; don't fight it
- **Server routes in `server/api/`** — use Nitro's file-based API routing

### Step 7: Vite Configuration Optimization
Optimize the Vite build configuration:

```
VITE OPTIMIZATION AUDIT:
┌────────────────────────────────────────────────────────────────────────┐
│  Area                    │  Current          │  Optimized              │
├──────────────────────────┼───────────────────┼─────────────────────────┤
│  Dev server startup      │  <N>ms            │  Target: < 500ms       │
│  HMR update              │  <N>ms            │  Target: < 100ms       │
│  Production build        │  <N>s             │  Target: < 30s         │
│  Bundle size (gzipped)   │  <N> KB           │  Target: < 200 KB      │
│  Chunk splitting         │  <strategy>       │  Manual + dynamic      │
│  Pre-bundling            │  <auto / manual>  │  Explicit dependencies │
│  Source maps             │  <on / off>       │  hidden-source-map     │
└──────────────────────────┴───────────────────┴─────────────────────────┘
```

```typescript
// vite.config.ts — Production-optimized
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],

  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },

  // Dependency pre-bundling
  optimizeDeps: {
    include: ['vue', 'vue-router', 'pinia', '@vueuse/core'],
    exclude: ['your-local-package'],
  },

  build: {
    // Chunk splitting strategy
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-vue': ['vue', 'vue-router', 'pinia'],
          'vendor-ui': ['@headlessui/vue', '@heroicons/vue'],
        },
      },
    },
    // Target modern browsers
    target: 'es2020',
    // Generate compressed size report
    reportCompressedSize: true,
    // CSS code splitting
    cssCodeSplit: true,
    // Source maps for production debugging
    sourcemap: 'hidden',
  },

  // Dev server
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
})
```

Rules:
- **Pre-bundle heavy dependencies** — list in `optimizeDeps.include` to speed up dev startup
- **Manual chunks for vendors** — split Vue ecosystem and UI library into separate chunks
- **Target modern browsers** — `es2020` unless you need IE11 (you don't)
- **CSS code splitting** — enabled by default, keep it on
- **Analyze bundle** — use `rollup-plugin-visualizer` to find bloat
- **Proxy API in dev** — avoid CORS issues with Vite's built-in proxy

### Step 8: Testing with Vitest and Vue Test Utils
Set up and write comprehensive tests:

```
TESTING SETUP:
Framework: Vitest (recommended) | Jest
Component testing: @vue/test-utils
E2E: Playwright | Cypress
Coverage target: > 80% (statements), > 70% (branches)
```

#### Vitest Configuration
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      include: ['src/**/*.{ts,vue}'],
      exclude: ['src/**/*.d.ts', 'src/main.ts'],
      thresholds: {
        statements: 80,
        branches: 70,
        functions: 80,
        lines: 80,
      },
    },
    css: { modules: { classNameStrategy: 'non-scoped' } },
  },
})
```

#### Component Testing Patterns
```typescript
// tests/components/UserCard.test.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import UserCard from '@/components/UserCard.vue'

describe('UserCard', () => {
  function createWrapper(props = {}) {
    return mount(UserCard, {
      props: {
        user: { id: '1', name: 'Jane', email: 'jane@test.com' },
        ...props,
      },
      global: {
        plugins: [createTestingPinia({ createSpy: vi.fn })],
        stubs: { RouterLink: true },
      },
    })
  }

  it('renders user name and email', () => {
    const wrapper = createWrapper()
    expect(wrapper.text()).toContain('Jane')
    expect(wrapper.text()).toContain('jane@test.com')
  })

  it('emits edit event when edit button is clicked', async () => {
    const wrapper = createWrapper()
    await wrapper.find('[data-testid="edit-btn"]').trigger('click')
    expect(wrapper.emitted('edit')).toHaveLength(1)
    expect(wrapper.emitted('edit')![0]).toEqual([{ id: '1' }])
  })

  it('shows admin badge when user is admin', () => {
    const wrapper = createWrapper({
      user: { id: '1', name: 'Jane', email: 'jane@test.com', role: 'admin' },
    })
    expect(wrapper.find('[data-testid="admin-badge"]').exists()).toBe(true)
  })
})
```

#### Composable Testing
```typescript
// tests/composables/useUser.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { useUser } from '@/composables/useUser'
import { flushPromises } from '@vue/test-utils'

vi.mock('@/api', () => ({
  getUser: vi.fn(),
}))

describe('useUser', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('fetches user and exposes reactive state', async () => {
    const mockUser = { id: '1', firstName: 'Jane', lastName: 'Doe' }
    vi.mocked(api.getUser).mockResolvedValue(mockUser)

    const { user, loading, fullName, fetch } = useUser('1')

    expect(loading.value).toBe(false)
    fetch()
    expect(loading.value).toBe(true)

    await flushPromises()

    expect(user.value).toEqual(mockUser)
    expect(fullName.value).toBe('Jane Doe')
    expect(loading.value).toBe(false)
  })

  it('handles fetch errors', async () => {
    vi.mocked(api.getUser).mockRejectedValue(new Error('Network error'))

    const { error, fetch } = useUser('1')
    await fetch()

    expect(error.value).toBeInstanceOf(Error)
    expect(error.value!.message).toBe('Network error')
  })
})
```

#### Pinia Store Testing
```typescript
// tests/stores/auth.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '@/stores/auth'

describe('useAuthStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('starts unauthenticated', () => {
    const store = useAuthStore()
    expect(store.isAuthenticated).toBe(false)
  })

  it('authenticates on successful login', async () => {
    const store = useAuthStore()
    await store.login({ email: 'jane@test.com', password: 'secret' })

    expect(store.isAuthenticated).toBe(true)
    expect(store.user).toBeTruthy()
    expect(store.token).toBeTruthy()
  })

  it('clears state on logout', async () => {
    const store = useAuthStore()
    await store.login({ email: 'jane@test.com', password: 'secret' })
    store.logout()

    expect(store.isAuthenticated).toBe(false)
    expect(store.user).toBeNull()
    expect(store.token).toBeNull()
  })
})
```

### Step 9: Validation
Validate the Vue application against best practices:

```
VUE APPLICATION AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  Check                                  │  Status            │
├─────────────────────────────────────────┼────────────────────┤
│  API style consistency (Comp/Options)   │  PASS | FAIL       │
│  <script setup> used where possible     │  PASS | FAIL       │
│  TypeScript strict mode enabled         │  PASS | FAIL       │
│  Composables follow use* convention     │  PASS | FAIL       │
│  Pinia stores use setup syntax          │  PASS | FAIL       │
│  Route components lazy-loaded           │  PASS | FAIL       │
│  Navigation guards centralized          │  PASS | FAIL       │
│  Props typed with defineProps<T>        │  PASS | FAIL       │
│  Emits typed with defineEmits<T>        │  PASS | FAIL       │
│  No direct DOM manipulation             │  PASS | FAIL       │
│  No v-html with user input              │  PASS | FAIL       │
│  Key attribute on v-for loops           │  PASS | FAIL       │
│  Error boundaries on async components   │  PASS | FAIL       │
│  Test coverage meets thresholds         │  PASS | FAIL       │
│  Bundle size within budget              │  PASS | FAIL       │
│  No unused components or imports        │  PASS | FAIL       │
│  Accessibility attributes present       │  PASS | FAIL       │
└─────────────────────────────────────────┴────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Deliverables & Handoff
Generate the project artifacts:

```
VUE PROJECT COMPLETE:

Artifacts:
- Project structure: <scaffolded / audited>
- Components: <N> components (<Composition API / Options API>)
- Stores: <N> Pinia stores
- Routes: <N> routes (<lazy-loaded / eager>)
- Composables: <N> reusable composables
- Tests: <N> test files, <M>% coverage
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:tailwind — Set up Tailwind CSS styling
-> /godmode:a11y — Accessibility audit
-> /godmode:e2e — End-to-end testing with Playwright
-> /godmode:build — Implement features
-> /godmode:ship — Deploy the application
```

Commit: `"vue: <project> — <N> components, <M> stores, <Composition API | Options API>"`

## Key Behaviors

1. **Composition API by default.** New Vue 3 projects use `<script setup>` with Composition API. Options API only for Vue 2 maintenance or explicit team preference.
2. **Composables over mixins.** Logic reuse happens through composables, never mixins. Mixins are a legacy pattern with name collision and implicit dependency problems.
3. **Pinia over Vuex.** Pinia is the official Vue 3 state management solution. Vuex is legacy. Setup stores for TypeScript projects.
4. **Lazy-load everything.** Route components, heavy libraries, below-fold content. Vite makes code splitting trivial.
5. **Type everything.** Props, emits, store state, composable returns, route params. TypeScript catches bugs that tests miss.
6. **Test composables independently.** Composables are pure logic; test them without mounting components. Test components for rendering and interaction.
7. **Choose rendering strategy per route.** Nuxt hybrid rendering lets you SSG marketing pages, SSR product pages, and SPA dashboards in one app.

## Example Usage

### Building a new Vue 3 SPA
```
User: /godmode:vue Build a task management app with authentication

Vue: Starting project assessment...

VUE PROJECT ASSESSMENT:
Vue version: 3.x (new project)
Build tool: Vite
API style: Composition API (<script setup>)
State management: Pinia
Router: Vue Router 4
TypeScript: yes (strict)

Scaffolding project structure...
Creating stores: useAuthStore, useTaskStore, useNotifyStore
Creating composables: useAuth, useTasks, usePagination, useForm
Creating views: Login, Register, Dashboard, TaskList, TaskDetail
Setting up router with auth guards...
Setting up Vitest with coverage thresholds...

14 components, 3 stores, 5 composables, 8 routes
```

### Migrating Options API to Composition API
```
User: /godmode:vue Migrate our components from Options API to Composition API

Vue: Scanning components...

Found 32 components using Options API
Migration complexity:
  - 18 simple (data + methods only) — auto-migratable
  - 10 moderate (mixins, watchers, lifecycle hooks)
  - 4 complex (render functions, $refs, $emit patterns)

Starting migration:
  1. Replace mixins with composables
  2. Convert data/computed/methods to ref/computed/functions
  3. Replace lifecycle hooks with Composition API equivalents
  4. Add TypeScript types to all props and emits
  5. Test each migrated component
```

### Setting up Nuxt 3 with hybrid rendering
```
User: /godmode:vue Set up a Nuxt 3 project with SSR for product pages and SPA for dashboard

Vue: Configuring Nuxt 3 hybrid rendering...

NUXT RENDERING STRATEGY:
/                  -> SSG (prerendered at build time)
/products/:id      -> SSR (SEO-critical, dynamic data)
/blog/:slug        -> ISR (revalidate every 60 seconds)
/dashboard/**      -> SPA (auth-gated, client-only)
/api/**            -> Server routes (Nitro)

Configuring routeRules...
Setting up Pinia with Nuxt plugin...
Configuring useAsyncData patterns...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Vue project assessment and setup |
| `--audit` | Audit existing Vue project against best practices |
| `--migrate` | Migrate Options API to Composition API |
| `--nuxt` | Set up or configure Nuxt 3 |
| `--pinia` | Design and implement Pinia stores |
| `--router` | Design and implement Vue Router configuration |
| `--vite` | Optimize Vite configuration |
| `--test` | Set up Vitest and write component tests |
| `--composable <name>` | Generate a new composable with tests |
| `--component <name>` | Generate a new component with tests and story |
| `--upgrade` | Upgrade Vue 2 to Vue 3 migration guide |

## Anti-Patterns

- **Do NOT use mixins in Vue 3.** Use composables. Mixins cause name collisions, implicit dependencies, and untraceable data flow.
- **Do NOT use Vuex in new projects.** Pinia is the official recommendation. It has better TypeScript support, simpler API, and smaller bundle.
- **Do NOT use `this` in `<script setup>`.** There is no `this`. Use refs, computed, and imported functions.
- **Do NOT mutate props.** Props are read-only. Use `emit` to notify the parent, or use a local ref copy.
- **Do NOT skip `key` on `v-for`.** Missing keys cause subtle reactivity bugs and broken animations.
- **Do NOT use `v-html` with user input.** It creates XSS vulnerabilities. Sanitize first, or use text interpolation.
- **Do NOT eager-load all routes.** Lazy-load with dynamic `import()`. Every route loaded upfront is bundle bloat users pay for.
- **Do NOT put business logic in components.** Extract to composables. Components handle rendering; composables handle logic.
- **Do NOT ignore TypeScript errors.** Fix them. `// @ts-ignore` in a Vue component is a ticking time bomb.
- **Do NOT use `reactive()` for primitives.** Use `ref()` for primitives and simple values. `reactive()` is for objects when you want deep reactivity without `.value`.
