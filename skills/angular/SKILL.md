---
name: angular
description: |
  Angular architecture skill. Activates when user needs to build, architect, or optimize Angular applications. Covers
    module architecture vs standalone components, RxJS patterns, state management (NgRx, Signals), dependency
    injection, lazy loading, Angular CLI optimization, and testing with Jasmine/Karma and Jest. Triggers on:
    /godmode:angular, "build an Angular app", "Angular component", "NgRx store", "Angular signals", or when the
    orchestrator detects Angular-related work.
---

# Angular — Angular Architecture

## Activate When
- User invokes `/godmode:angular`
- User says "build an Angular app", "Angular component", "NgRx", "Angular signals", "RxJS"
- User says "standalone components", "Angular modules", "lazy loading"
- When creating or scaffolding an Angular application
- When `/godmode:plan` or `/godmode:review` identifies Angular work

## Workflow

### Step 1: Project Discovery
```
ANGULAR PROJECT ASSESSMENT:
Angular version: <14-18+>
Architecture: <NgModule | Standalone | Mixed>
State: <NgRx | Signals | Services | NGXS | none>
Routing: <Lazy-loaded modules | Standalone routes | eager>
UI: <Angular Material | PrimeNG | ng-bootstrap | custom>
Testing: <Jasmine+Karma | Jest | Vitest>
Build: <Angular CLI esbuild | Nx | custom>
SSR: <Angular SSR v17+ | Universal | none>
TypeScript strict: <yes | no>
```

If starting fresh, ask: "What are you building? SSR needed? Scale (enterprise vs small)?"

### Step 2: NgModules vs Standalone

```
DECISION:
  NgModules: All versions, high boilerplate, module imports, loadChildren, well-established enterprise
  Standalone: 14+ (mature 17+), low boilerplate, component imports, loadComponent, better tree-shaking

RULES:
- New projects Angular 17+: default to standalone
- Existing NgModule projects: migrate incrementally with standalone: true
- Mixed is acceptable during migration — establish timeline to complete
```

### Step 3: Component Architecture

Use `OnPush` change detection on all components. Signal-based inputs/outputs on Angular 17+. Smart vs
presentational split. One component per file. Consistent selector prefix.

Standalone pattern (Angular 17+): `@Component({ standalone: true, imports: [...], changeDetection: OnPush })`
with `input()`, `output()`, `computed()`, `inject()`.

NgModule pattern (legacy): `@Component({ changeDetection: OnPush })` with `@Input()`, `@Output()`, `EventEmitter`.

### Step 4: RxJS & State Management

```
RXJS PATTERNS:
  switchMap (search/nav), concatMap (sequential mutations), forkJoin (parallel+all),
  combineLatest (merge reactive), debounceTime (search-as-you-type),
  distinctUntilChanged (filter unchanged), shareReplay(1) (cache), retry(3),
  takeUntilDestroyed (auto-unsubscribe)

STATE MANAGEMENT DECISION:
  Signals → component/local state (low complexity)
  Services + RxJS → shared state, medium apps
  NgRx → large enterprise, complex async flows, time-travel debugging
  NgRx SignalStore → feature stores, simpler NgRx

RULE: Start with Signals. Escalate to Services+RxJS for shared state.
Only NgRx for complex async flows or strict unidirectional requirements.
```

### Step 5: Dependency Injection

```
inject() over constructor injection (cleaner, works in functions)
providedIn: 'root' for singletons (tree-shakeable)
Component-level providers for scoped services
InjectionTokens for configuration (never inject plain strings)
Abstract classes as interfaces (Angular DI works with abstract classes, not TS interfaces)
```

### Step 6: Lazy Loading & Performance

```
LAZY LOADING: Every feature route uses loadChildren or loadComponent. Eager only for shell.
Standalone routes: loadComponent: () => import('./feature.component').then(m => m.Component)

SELECTIVE PRELOADING: route.data['preload'] ? load() : EMPTY

PERFORMANCE AUDIT:
[ ] OnPush on all components          [ ] Lazy loading for feature routes
[ ] trackBy on all *ngFor / @for      [ ] Signals for local state
[ ] No subscriptions without cleanup  [ ] Bundle budget configured
[ ] NgOptimizedImage for images       [ ] SSR/prerendering for public routes
[ ] Zoneless evaluated                [ ] No unnecessary re-renders
```

### Step 7: Build Optimization

Use `@angular-devkit/build-angular:application` (esbuild). Budget: initial 500kB warning, 1MB error. Source
maps off in prod. Named chunks off in prod.

### Step 8: Testing

```
STRATEGY: Unit (Jest/Jasmine, >80%), Component (TestBed+Jest, all smart), Integration (service+store), E2E (Playwright)
RULES: jest-preset-angular for Jest, setInput() for signal inputs, httpMock.verify() in afterEach,
  provideMockActions+provideMockStore for NgRx, explicit change detection for OnPush.
THRESHOLDS: statements 80%, branches 70%, functions 80%, lines 80%
```

### Step 9: Validation
```
ANGULAR AUDIT:
[ ] OnPush on all components           [ ] Standalone (if 17+)
[ ] Signal inputs/outputs (if 17+)     [ ] inject() over constructors
[ ] Lazy loading all feature routes    [ ] trackBy on all ngFor/@for
[ ] No subscriptions without cleanup   [ ] TypeScript strict mode
[ ] Bundle budgets configured          [ ] Core/shared/feature separation
[ ] No circular dependencies           [ ] Smart vs presentational split
[ ] HTTP interceptors for cross-cutting [ ] Global error handler
[ ] Test coverage meets thresholds     [ ] No console.log in production
VERDICT: PASS | NEEDS REVISION
```

### Step 10: Deliverables
```
ANGULAR COMPLETE:
Components: <N> (OnPush: <M>%), Services: <N>, Routes: <N> (<N> lazy)
State: <Signals|NgRx|Services>, Tests: <N> files, <M>% coverage
Audit: PASS | NEEDS REVISION
```
Commit: `"angular: <project> — <N> components, <architecture>, <state management>"`

## Key Behaviors

1. **Standalone by default.** New 17+ projects use standalone. NgModules are legacy; migrate incrementally.
2. **Signals for local, NgRx for global.** Don't use NgRx for a counter. Don't use signals for complex async.
3. **OnPush everything.** No exceptions. Fix reactivity at source.
4. **Unsubscribe from everything.** `takeUntilDestroyed()`, async pipe, or DestroyRef.
5. **inject() over constructors.** Cleaner, works in functions, Angular-recommended.
6. **Lazy-load all features.** Eager only for the shell.
7. **Type everything strictly.** Strict mode, interfaces, generics. No `any`.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full project assessment and setup |
| `--audit` | Audit against best practices |
| `--standalone` | Migrate to standalone |
| `--ngrx` | Design NgRx store |
| `--signals` | Migrate to signal-based inputs/outputs |
| `--routing` | Routing with lazy loading |
| `--perf` | Performance audit |
| `--test` | Set up Jest and write tests |
| `--upgrade <from> <to>` | Version migration guide |
| `--ssr` | Set up Angular SSR |

## Auto-Detection
```
Detect: @angular/core version, .module.ts count vs standalone:true count,
@ngrx/store or signal(), angular.json/nx.json, jest/karma, @angular/ssr,
UI library, tsconfig strict mode.
```

## HARD RULES

Never ask to continue. Loop autonomously until
`ng build` and `ng test` pass with 0 errors.

```bash
# Build and test Angular project
ng build --configuration production
ng test --no-watch --code-coverage
npx ng lint
```

IF bundle size > 500kB initial: investigate lazy loading gaps.
WHEN `ng test` coverage < 80%: add tests before shipping.
IF `ng build` produces > 0 errors: fix types first, then templates.

1. EVERY component: OnPush change detection. No Default.
2. No `any` types in application code.
3. All subscriptions: cleanup via takeUntilDestroyed(), async pipe, or explicit unsubscribe.
4. No nested subscriptions (use RxJS operators).
5. All feature routes: lazy-loaded.
6. No direct DOM manipulation (no jQuery, no document.querySelector).
7. TypeScript strict mode enabled.

## Output Format
```
ANGULAR RESULT:
Action: <scaffold|component|service|optimize|audit|upgrade>
Components: <N>, Services: <N>, Angular: <version>, Standalone: <yes|no|mixed>
Tests: <passing|failing|skipped>, Build: <passing|failing>
```

## TSV Logging
Append to `.godmode/angular.tsv`:
`timestamp	project	action	components_count	services_count	modules_count	tests_status	build_status	notes`

## Success Criteria
1. `ng build` zero errors. 2. `ng test` passes. 3. All OnPush. 4. No `any`. 5. All subscriptions cleaned up.
6. No nested subscriptions. 7. All features lazy-loaded. 8. No direct DOM manipulation. 9. Strict TypeScript.
10. All services use proper injection.

<!-- tier-3 -->

## Error Recovery
```
ng build fails → fix type errors first (cascade to templates), check circular deps, verify imports.
Tests fail → check TestBed providers/imports, mock interfaces, async test patterns, OnPush detection.
ExpressionChangedAfterChecked → move to ngOnInit or use signals, verify markForCheck/async pipe.
NullInjectorError → add provider, use forwardRef() for circular deps.
RxJS leaks → add takeUntilDestroyed(), replace .subscribe() with async pipe, shareReplay({refCount:true}).
```

## Keep/Discard Discipline
```
KEEP if build passes AND tests pass AND no Default change detection AND no any types.
DISCARD if build fails OR tests fail OR Default change detection introduced.
```

## Stop Conditions
```
STOP when: ng build+test pass AND all OnPush AND all lazy-loaded AND zero any types
  AND all subscriptions cleaned up AND strict TypeScript
  OR user requests stop OR max 10 iterations
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Use `git stash` instead of worktrees. See
`adapters/shared/sequential-dispatch.md`.
