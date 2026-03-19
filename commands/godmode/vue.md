# /godmode:vue

Vue.js mastery — Composition API and Options API decision guidance, Pinia state management, Vue Router configuration, Nuxt.js SSR/SSG patterns, Vite optimization, and testing with Vitest and Vue Test Utils. Build production-grade Vue applications with best practices.

## Usage

```
/godmode:vue                             # Full Vue project assessment and setup
/godmode:vue --audit                     # Audit existing Vue project
/godmode:vue --migrate                   # Migrate Options API to Composition API
/godmode:vue --nuxt                      # Set up or configure Nuxt 3
/godmode:vue --pinia                     # Design and implement Pinia stores
/godmode:vue --router                    # Design Vue Router configuration
/godmode:vue --vite                      # Optimize Vite configuration
/godmode:vue --test                      # Set up Vitest and write tests
/godmode:vue --composable useAuth        # Generate composable with tests
/godmode:vue --component UserCard        # Generate component with tests
/godmode:vue --upgrade                   # Vue 2 to Vue 3 migration guide
```

## What It Does

1. Assesses project (Vue version, API style, state management, build tool, TypeScript)
2. Guides Composition API vs Options API decision based on project context
3. Establishes component structure with `<script setup>`, typed props/emits
4. Designs composable patterns for logic reuse (replacing mixins)
5. Configures Pinia stores with setup syntax and persistence
6. Sets up Vue Router with lazy loading, auth guards, and layouts
7. Configures Nuxt 3 hybrid rendering (SSG, SSR, ISR, SPA per route)
8. Optimizes Vite configuration (pre-bundling, chunk splitting, proxy)
9. Sets up Vitest with component testing, composable testing, and store testing
10. Validates against 17-point best practices checklist

## Output
- Project scaffold or audit report
- Composition API components with TypeScript
- Pinia stores with setup syntax
- Vue Router with lazy-loaded routes and guards
- Vitest configuration with coverage thresholds
- Commit: `"vue: <project> — <N> components, <M> stores, <API style>"`

## Next Step
After setup: `/godmode:tailwind` for styling, `/godmode:a11y` for accessibility.
After building: `/godmode:e2e` for end-to-end testing.
When ready: `/godmode:ship` to deploy.

## Examples

```
/godmode:vue                             # Full assessment and scaffolding
/godmode:vue --nuxt                      # Configure Nuxt 3 with hybrid rendering
/godmode:vue --migrate                   # Migrate from Options API to Composition API
/godmode:vue --pinia                     # Design Pinia store architecture
/godmode:vue --test                      # Set up Vitest and write tests
```
