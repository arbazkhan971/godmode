# /godmode:svelte

Svelte and SvelteKit mastery — Svelte 5 runes reactivity, stores, SvelteKit routing with load functions and form actions, server-side rendering, prerendering, adapter configuration for different deployment platforms, and testing. Build production-grade Svelte applications with best practices.

## Usage

```
/godmode:svelte                              # Full Svelte/SvelteKit project assessment
/godmode:svelte --audit                      # Audit existing Svelte project
/godmode:svelte --migrate                    # Migrate Svelte 4 to Svelte 5 runes
/godmode:svelte --sveltekit                  # Set up or configure SvelteKit
/godmode:svelte --stores                     # Design and implement state management
/godmode:svelte --routing                    # Design SvelteKit routing with load functions
/godmode:svelte --actions                    # Implement form actions for mutations
/godmode:svelte --adapter vercel             # Configure deployment adapter
/godmode:svelte --ssr                        # Configure rendering strategy per route
/godmode:svelte --test                       # Set up Vitest and write tests
/godmode:svelte --component Card             # Generate a new component with tests
/godmode:svelte --hooks                      # Set up server/client hooks
```

## What It Does

1. Assesses project (Svelte version, SvelteKit, reactivity model, adapter, TypeScript)
2. Guides Svelte 5 runes vs legacy reactivity decision
3. Establishes component patterns with $state, $derived, $effect, $props
4. Designs state management (reactive classes for Svelte 5, stores for Svelte 4)
5. Configures SvelteKit file-based routing with load functions and layouts
6. Implements form actions with progressive enhancement (use:enhance)
7. Sets up rendering strategy per route (prerender, SSR, CSR)
8. Configures server hooks for auth, logging, and error handling
9. Selects and configures deployment adapter (Vercel, Cloudflare, Node, static)
10. Sets up testing with Vitest and @testing-library/svelte
11. Validates against 17-point best practices checklist

## Output
- Project scaffold or audit report
- SvelteKit routes with load functions and form actions
- Reactive stores or Svelte 5 reactive classes
- Server hooks for auth and error handling
- Adapter configuration for target platform
- Vitest setup with component and load function tests
- Commit: `"svelte: <project> — <N> routes, <N> components, <adapter>"`

## Next Step
After setup: `/godmode:tailwind` for styling, `/godmode:a11y` for accessibility.
After building: `/godmode:e2e` for end-to-end testing with Playwright.
When ready: `/godmode:ship` to deploy.

## Examples

```
/godmode:svelte                              # Full assessment and scaffolding
/godmode:svelte --sveltekit                  # Configure SvelteKit with routing
/godmode:svelte --migrate                    # Migrate Svelte 4 to Svelte 5 runes
/godmode:svelte --adapter cloudflare         # Configure Cloudflare adapter
/godmode:svelte --actions                    # Implement form actions
```
