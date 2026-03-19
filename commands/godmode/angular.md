# /godmode:angular

Angular architecture mastery — standalone components vs NgModules, RxJS patterns, state management (NgRx, Signals), dependency injection, lazy loading, Angular CLI optimization, and testing with Jasmine/Karma and Jest. Build production-grade Angular applications with best practices.

## Usage

```
/godmode:angular                              # Full Angular project assessment and setup
/godmode:angular --audit                      # Audit existing Angular project
/godmode:angular --standalone                 # Migrate NgModules to standalone components
/godmode:angular --ngrx                       # Design and implement NgRx store
/godmode:angular --signals                    # Migrate to signal-based inputs/outputs
/godmode:angular --routing                    # Design routing with lazy loading
/godmode:angular --di                         # Review dependency injection architecture
/godmode:angular --perf                       # Angular-specific performance audit
/godmode:angular --test                       # Set up Jest and write tests
/godmode:angular --generate component UserCard # Generate component with tests
/godmode:angular --upgrade 16 18              # Version upgrade migration guide
/godmode:angular --ssr                        # Set up Angular SSR
```

## What It Does

1. Assesses project (Angular version, architecture, state management, build system)
2. Guides NgModules vs standalone components decision based on project context
3. Designs component architecture with OnPush change detection and signal inputs
4. Establishes RxJS patterns (switchMap, shareReplay, takeUntilDestroyed)
5. Configures state management (Signals for local, NgRx for global)
6. Sets up dependency injection with inject(), InjectionTokens, and proper scoping
7. Implements lazy loading with selective preloading strategy
8. Optimizes Angular CLI build (esbuild, budgets, source maps)
9. Configures testing with Jest, TestBed, and HttpTestingController
10. Validates against 17-point best practices checklist

## Output
- Project scaffold or audit report
- Standalone components with OnPush and signal I/O
- NgRx store with actions, reducer, selectors, effects, and tests
- Lazy-loaded routes with guards and preloading strategy
- Jest configuration with coverage thresholds
- Commit: `"angular: <project> — <N> components, <architecture>, <state management>"`

## Next Step
After setup: `/godmode:tailwind` for styling, `/godmode:a11y` for accessibility.
After building: `/godmode:e2e` for end-to-end testing.
When ready: `/godmode:ship` to deploy.

## Examples

```
/godmode:angular                              # Full assessment and scaffolding
/godmode:angular --standalone                 # Migrate to standalone components
/godmode:angular --ngrx                       # Set up NgRx store architecture
/godmode:angular --signals                    # Adopt Angular Signals
/godmode:angular --test                       # Set up Jest and write tests
```
