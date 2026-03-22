---
name: angular
description: |
  Angular architecture skill. Activates when user needs to build, architect, or optimize Angular applications. Covers module architecture vs standalone components, RxJS patterns, state management (NgRx, Signals), dependency injection, lazy loading, Angular CLI optimization, and testing with Jasmine/Karma and Jest. Triggers on: /godmode:angular, "build an Angular app", "Angular component", "NgRx store", "Angular signals", or when the orchestrator detects Angular-related work.
---

# Angular — Angular Architecture

## When to Activate
- User invokes `/godmode:angular`
- User says "build an Angular app", "Angular component", "Angular project"
- User mentions "NgRx", "Angular signals", "RxJS", "dependency injection"
- User says "standalone components", "Angular modules", "lazy loading"
- When creating or scaffolding an Angular application
- When `/godmode:plan` identifies Angular tasks
- When `/godmode:review` flags Angular-specific patterns

## Workflow

### Step 1: Project Discovery & Assessment
Survey the existing project or determine new project requirements:

```
ANGULAR PROJECT ASSESSMENT:
Angular version: <14 / 15 / 16 / 17 / 18+>
Architecture: <NgModule-based / Standalone / Mixed>
State management: <NgRx / Signals / Services / NGXS / Akita / none>
Routing: <Lazy-loaded modules / Standalone routes / eager>
UI library: <Angular Material / PrimeNG / ng-bootstrap / Taiga UI / custom / none>
CSS approach: <SCSS / CSS / Tailwind / Angular CDK>
Testing: <Jasmine+Karma / Jest / Vitest / none>
Build system: <Angular CLI (esbuild) / Nx / custom>
SSR: <Angular Universal / Angular SSR (v17+) / none>
TypeScript: strict mode <yes / no>
Component count: <N>
Module count: <N> (if NgModule-based)

Directory structure:
  src/app/
    core/           Core module (singleton services, guards, interceptors)
    shared/         Shared module (common components, directives, pipes)
    features/       Feature modules (domain-specific)
    layouts/        Layout components
    models/         Interfaces and types
    store/          State management (NgRx / Signals)

Quality score: <HIGH / MEDIUM / LOW>
Issues detected: <N>
```

If starting fresh, ask: "What are you building? Do you need SSR? What scale (enterprise vs small app)?"

### Step 2: Architecture Decision — NgModules vs Standalone

Guide the decision between module-based and standalone architecture:

```
ARCHITECTURE DECISION:
┌────────────────────────────────────────────────────────────────────────┐
│  Factor                   │  NgModules              │  Standalone      │
├───────────────────────────┼─────────────────────────┼──────────────────┤
│  Angular version          │  All versions           │  14+ (mature 17+)│
│  Boilerplate              │  High (module per feat)  │  Low              │
│  Dependency management    │  Module imports array   │  Component imports │
│  Lazy loading             │  loadChildren (module)   │  loadComponent    │
│  Tree-shaking             │  Limited by module scope │  Better per-comp  │
│  Migration path           │  Legacy, still supported │  Future direction │
│  Learning curve           │  Steeper (module system) │  Simpler          │
│  Enterprise conventions   │  Well-established        │  Emerging         │
│  Testing                  │  TestBed with imports    │  Simpler setup    │
└───────────────────────────┴─────────────────────────┴──────────────────┘

RECOMMENDATION: <Standalone (Angular 17+) | NgModules (existing large apps)>
JUSTIFICATION: <reason based on project context>
```

Rules:
- **New projects on Angular 17+:** Default to standalone components
- **Existing NgModule projects:** Do not rewrite; migrate incrementally with `standalone: true`
- **Enterprise with strict conventions:** NgModules still valid; standalone migration can be gradual
- **Mixed is acceptable during migration** — but establish a timeline to complete

### Step 3: Component Architecture
Design components following Angular best practices:

#### Standalone Component Pattern (Angular 17+)
```typescript
// features/user/user-profile.component.ts
import { Component, input, output, computed, inject, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { UserService } from '@core/services/user.service';
import { AvatarComponent } from '@shared/components/avatar/avatar.component';
import type { User } from '@models/user.model';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [CommonModule, RouterLink, AvatarComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="user-profile">
      <app-avatar [src]="user().avatar" [alt]="displayName()" />
      <h2>{{ displayName() }}</h2>
      <p>{{ user().email }}</p>
      @if (editable()) {
        <button (click)="edit.emit(user())">Edit Profile</button>
      }
    </div>
  `,
  styleUrl: './user-profile.component.scss',
})
export class UserProfileComponent {
  // Signal-based inputs (Angular 17+)
  user = input.required<User>();
  editable = input(false);

  // Signal-based outputs
  edit = output<User>();

  // Computed signals
  displayName = computed(() =>
    `${this.user().firstName} ${this.user().lastName}`
  );

  // Dependency injection
  private userService = inject(UserService);
}
```

#### NgModule Component Pattern (Legacy/Existing)
```typescript
// features/user/user-profile/user-profile.component.ts
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import type { User } from '@models/user.model';

@Component({
  selector: 'app-user-profile',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './user-profile.component.html',
  styleUrls: ['./user-profile.component.scss'],
})
export class UserProfileComponent {
  @Input({ required: true }) user!: User;
  @Input() editable = false;
  @Output() edit = new EventEmitter<User>();

  get displayName(): string {
    return `${this.user.firstName} ${this.user.lastName}`;
  }
}
```

Rules:
- **Always use `OnPush` change detection** — prevents unnecessary re-renders
- **Signal-based inputs/outputs on Angular 17+** — better performance, simpler reactivity
- **Smart vs presentational components** — smart components inject services and manage state; presentational components receive data via inputs and emit events
- **One component per file** — no multi-component files
- **Selector prefix** — use project prefix (`app-`, `my-`) consistently

### Step 4: RxJS Patterns & State Management

#### RxJS Best Practices
```typescript
// services/data.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, catchError, retry, shareReplay, switchMap, map, EMPTY } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class DataService {
  private http = inject(HttpClient);
  private refreshTrigger$ = new BehaviorSubject<void>(undefined);

  // Cached, shared observable — multiple subscribers share one HTTP call
  readonly items$ = this.refreshTrigger$.pipe(
    switchMap(() => this.http.get<Item[]>('/api/items')),
    retry({ count: 2, delay: 1000 }),
    catchError((err) => {
      console.error('Failed to fetch items:', err);
      return EMPTY;
    }),
    shareReplay({ bufferSize: 1, refCount: true }),
  );

  readonly itemCount$ = this.items$.pipe(
    map(items => items.length),
  );

  refresh(): void {
    this.refreshTrigger$.next();
  }
}
```

#### Common RxJS Patterns
```
RXJS PATTERN GUIDE:
┌──────────────────────────────────────────────────────────────────────┐
│  Pattern                 │  Operator          │  Use Case             │
├──────────────────────────┼────────────────────┼───────────────────────┤
│  Switch to latest        │  switchMap         │  Search, navigation   │
│  Queue requests          │  concatMap         │  Sequential mutations │
│  Parallel + all          │  forkJoin          │  Load multiple APIs   │
│  Parallel + any          │  combineLatest     │  Merge reactive data  │
│  Debounce input          │  debounceTime      │  Search-as-you-type   │
│  Prevent duplicates      │  distinctUntilChanged │ Filter unchanged   │
│  Cache result            │  shareReplay(1)    │  Shared API response  │
│  Retry on failure        │  retry(3)          │  Transient errors     │
│  Timeout                 │  timeout(5000)     │  Slow API protection  │
│  Take until destroyed    │  takeUntilDestroyed│  Auto-unsubscribe     │
└──────────────────────────┴────────────────────┴───────────────────────┘
```

#### Angular Signals (Angular 17+) — Preferred for Component State
```typescript
import { Component, signal, computed, effect } from '@angular/core';

@Component({ /* ... */ })
export class DashboardComponent {
  // Writable signals
  count = signal(0);
  filter = signal<'all' | 'active' | 'done'>('all');

  // Computed signals (derived state)
  doubleCount = computed(() => this.count() * 2);
  filteredItems = computed(() => {
    const items = this.items();
    const f = this.filter();
    return f === 'all' ? items : items.filter(i => i.status === f);
  });

  // Effects (side effects on signal changes)
  logger = effect(() => {
    console.log(`Count changed to: ${this.count()}`);
  });

  increment() {
    this.count.update(c => c + 1);
  }
}
```

#### NgRx Store Pattern (Large-Scale State)
```
NGRX STORE ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────────┐
│  Feature Store       │  Purpose                │  Entity Adapter?   │
├──────────────────────┼─────────────────────────┼────────────────────┤
│  auth                │  Authentication state   │  No                │
│  users               │  User collection        │  Yes               │
│  products            │  Product catalog        │  Yes               │
│  cart                │  Shopping cart           │  No                │
│  ui                  │  UI state (modals, etc) │  No                │
└──────────────────────┴─────────────────────────┴────────────────────┘
```

```typescript
// store/products/products.actions.ts
import { createActionGroup, emptyProps, props } from '@ngrx/store';
import type { Product } from '@models/product.model';

export const ProductActions = createActionGroup({
  source: 'Products',
  events: {
    'Load Products': emptyProps(),
    'Load Products Success': props<{ products: Product[] }>(),
    'Load Products Failure': props<{ error: string }>(),
    'Select Product': props<{ productId: string }>(),
  },
});

// store/products/products.reducer.ts
import { createReducer, on } from '@ngrx/store';
import { createEntityAdapter, EntityState } from '@ngrx/entity';
import { ProductActions } from './products.actions';
import type { Product } from '@models/product.model';

export interface ProductsState extends EntityState<Product> {
  loading: boolean;
  error: string | null;
  selectedId: string | null;
}

const adapter = createEntityAdapter<Product>();
const initialState: ProductsState = adapter.getInitialState({
  loading: false,
  error: null,
  selectedId: null,
});

export const productsReducer = createReducer(
  initialState,
  on(ProductActions.loadProducts, (state) => ({ ...state, loading: true, error: null })),
  on(ProductActions.loadProductsSuccess, (state, { products }) =>
    adapter.setAll(products, { ...state, loading: false })
  ),
  on(ProductActions.loadProductsFailure, (state, { error }) =>
    ({ ...state, loading: false, error })
  ),
  on(ProductActions.selectProduct, (state, { productId }) =>
    ({ ...state, selectedId: productId })
  ),
);

// store/products/products.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { createEntityAdapter } from '@ngrx/entity';

const selectProductsState = createFeatureSelector<ProductsState>('products');
const { selectAll, selectEntities } = createEntityAdapter<Product>().getSelectors();

export const selectAllProducts = createSelector(selectProductsState, selectAll);
export const selectProductsLoading = createSelector(selectProductsState, (s) => s.loading);
export const selectSelectedProduct = createSelector(
  selectProductsState,
  (state) => state.selectedId ? selectEntities(state)[state.selectedId] ?? null : null,
);

// store/products/products.effects.ts
import { Injectable, inject } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { switchMap, map, catchError, of } from 'rxjs';
import { ProductActions } from './products.actions';
import { ProductService } from '@core/services/product.service';

@Injectable()
export class ProductEffects {
  private actions$ = inject(Actions);
  private productService = inject(ProductService);

  loadProducts$ = createEffect(() =>
    this.actions$.pipe(
      ofType(ProductActions.loadProducts),
      switchMap(() =>
        this.productService.getAll().pipe(
          map((products) => ProductActions.loadProductsSuccess({ products })),
          catchError((error) => of(ProductActions.loadProductsFailure({ error: error.message }))),
        )
      ),
    )
  );
}
```

Decision guide for state management:

```
STATE MANAGEMENT DECISION:
┌────────────────────────────────────────────────────────────────────────┐
│  Approach          │  Best For                    │  Complexity        │
├────────────────────┼──────────────────────────────┼────────────────────┤
│  Signals           │  Component/local state       │  Low               │
│  Services + RxJS   │  Shared state, medium apps   │  Medium            │
│  NgRx              │  Large enterprise apps        │  High              │
│  NgRx SignalStore  │  Feature stores, simpler NgRx │  Medium            │
│  NGXS              │  Teams preferring less boiler │  Medium            │
└────────────────────┴──────────────────────────────┴────────────────────┘

RULE: Start with Signals for local state. Escalate to Services+RxJS for shared
state. Only introduce NgRx when you have complex async flows, time-travel
debugging needs, or strict unidirectional data flow requirements.
```

### Step 5: Dependency Injection Patterns
Design the DI architecture:

```typescript
// Singleton service (providedIn: 'root') — one instance for entire app
@Injectable({ providedIn: 'root' })
export class AuthService { }

// Feature-scoped service — one instance per feature
@Injectable()  // Provided in feature module or route
export class FeatureDataService { }

// Component-scoped service — one instance per component
@Component({
  providers: [FormValidationService],  // New instance per component
})
export class FormComponent { }
```

#### Injection Token Pattern
```typescript
// tokens/api-config.token.ts
import { InjectionToken } from '@angular/core';

export interface ApiConfig {
  baseUrl: string;
  timeout: number;
  retries: number;
}

export const API_CONFIG = new InjectionToken<ApiConfig>('API_CONFIG');

// app.config.ts (standalone) or app.module.ts
export const appConfig: ApplicationConfig = {
  providers: [
    { provide: API_CONFIG, useValue: { baseUrl: '/api', timeout: 5000, retries: 3 } },
  ],
};

// Usage in service
@Injectable({ providedIn: 'root' })
export class ApiService {
  private config = inject(API_CONFIG);
}
```

Rules:
- **Use `inject()` over constructor injection** — cleaner syntax, works in functions
- **`providedIn: 'root'` for singletons** — tree-shakeable, no module registration needed
- **Component-level providers for scoped services** — form handlers, local state
- **InjectionTokens for configuration** — never inject plain strings or objects directly
- **Abstract classes as interfaces** — Angular DI works with abstract classes, not TypeScript interfaces

### Step 6: Lazy Loading & Performance
Design lazy loading strategy:

```
LAZY LOADING ARCHITECTURE:
┌──────────────────────────────────────────────────────────────────────┐
│  Route                   │  Loading Strategy     │  Preload?         │
├──────────────────────────┼───────────────────────┼───────────────────┤
│  /                       │  Eager (in main chunk)│  N/A              │
│  /auth/*                 │  Lazy (separate chunk)│  No               │
│  /dashboard/*            │  Lazy                 │  Yes (preload)    │
│  /admin/*                │  Lazy                 │  No (low traffic) │
│  /reports/*              │  Lazy                 │  No               │
└──────────────────────────┴───────────────────────┴───────────────────┘
```

#### Standalone Lazy Routes (Angular 17+)
```typescript
// app.routes.ts
import { Routes } from '@angular/router';
import { authGuard } from '@core/guards/auth.guard';

export const routes: Routes = [
  { path: '', loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent) },
  {
    path: 'auth',
    loadChildren: () => import('./features/auth/auth.routes').then(m => m.AUTH_ROUTES),
  },
  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadChildren: () => import('./features/dashboard/dashboard.routes').then(m => m.DASHBOARD_ROUTES),
    data: { preload: true },
  },
  {
    path: 'admin',
    canActivate: [authGuard, adminGuard],
    loadChildren: () => import('./features/admin/admin.routes').then(m => m.ADMIN_ROUTES),
  },
  { path: '**', loadComponent: () => import('./features/not-found/not-found.component').then(m => m.NotFoundComponent) },
];
```

#### Preloading Strategy
```typescript
// core/strategies/selective-preload.strategy.ts
import { PreloadingStrategy, Route } from '@angular/router';
import { Observable, of, EMPTY } from 'rxjs';

export class SelectivePreloadStrategy implements PreloadingStrategy {
  preload(route: Route, load: () => Observable<any>): Observable<any> {
    return route.data?.['preload'] ? load() : EMPTY;
  }
}

// app.config.ts
provideRouter(routes, withPreloading(SelectivePreloadStrategy))
```

#### Performance Optimization Checklist
```
ANGULAR PERFORMANCE AUDIT:
┌────────────────────────────────────────────────────────────────────┐
│  Optimization                         │  Status                   │
├───────────────────────────────────────┼───────────────────────────┤
│  OnPush change detection on all       │  PASS | FAIL              │
│  Lazy loading for feature routes      │  PASS | FAIL              │
│  trackBy on all *ngFor / @for         │  PASS | FAIL              │
│  Signals used for local state         │  PASS | FAIL              │
│  No subscriptions without unsubscribe │  PASS | FAIL              │
│  Bundle budget configured             │  PASS | FAIL              │
│  Image optimization (NgOptimizedImage)│  PASS | FAIL              │
│  SSR/prerendering where appropriate   │  PASS | FAIL              │
│  Zone.js-less (zoneless) evaluated    │  PASS | FAIL | N/A        │
│  No unnecessary re-renders            │  PASS | FAIL              │
│  Web workers for heavy computation    │  PASS | FAIL | N/A        │
│  Service worker for caching           │  PASS | FAIL | N/A        │
└───────────────────────────────────────┴───────────────────────────┘
```

### Step 7: Angular CLI & Build Optimization
Configure the CLI for production quality:

```json
// angular.json — key build optimizations
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:application",
          "options": {
            "outputPath": "dist/my-app",
            "index": "src/index.html",
            "browser": "src/main.ts",
            "tsConfig": "tsconfig.app.json",
            "assets": ["src/favicon.ico", "src/assets"],
            "styles": ["src/styles.scss"],
            "scripts": []
          },
          "configurations": {
            "production": {
              "budgets": [
                { "type": "initial", "maximumWarning": "500kB", "maximumError": "1MB" },
                { "type": "anyComponentStyle", "maximumWarning": "4kB", "maximumError": "8kB" }
              ],
              "outputHashing": "all",
              "sourceMap": false,
              "namedChunks": false,
              "extractLicenses": true,
              "optimization": true
            },
            "development": {
              "optimization": false,
              "extractLicenses": false,
              "sourceMap": true
            }
          },
          "defaultConfiguration": "production"
        }
      }
    }
  }
}
```

Rules:
- **Budget enforcement** — set initial bundle budget (500kB warning, 1MB error) and fail CI on violations
- **esbuild builder** — use `@angular-devkit/build-angular:application` (esbuild) over the legacy webpack builder
- **Source maps off in prod** — unless you use error tracking that needs them
- **Named chunks off in prod** — prevents route names leaking into production bundles

### Step 8: Testing with Jasmine/Karma and Jest

```
TESTING STRATEGY:
┌──────────────────────────────────────────────────────────────────────┐
│  Layer           │  Framework        │  Coverage Target             │
├──────────────────┼───────────────────┼──────────────────────────────┤
│  Unit tests      │  Jest or Jasmine  │  > 80% statements            │
│  Component tests │  TestBed + Jest   │  All smart components        │
│  Integration     │  TestBed          │  Service + store flows       │
│  E2E             │  Playwright       │  Critical user journeys      │
└──────────────────┴───────────────────┴──────────────────────────────┘

KEY TESTING RULES:
- Use jest-preset-angular for Jest setup (faster than Karma)
- Standalone components: import the component directly in TestBed.configureTestingModule
- Set inputs with fixture.componentRef.setInput() (signal inputs, Angular 17+)
- Always call httpMock.verify() in afterEach for HTTP tests
- NgRx effects: use provideMockActions + provideMockStore
- OnPush components: trigger change detection explicitly in tests
- Coverage thresholds: statements 80%, branches 70%, functions 80%, lines 80%
```

### Step 9: Validation
Validate the Angular application against best practices:

```
ANGULAR APPLICATION AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                                    │  Status              │
├───────────────────────────────────────────┼──────────────────────┤
│  OnPush change detection on all comps     │  PASS | FAIL         │
│  Standalone components (if Angular 17+)   │  PASS | FAIL | N/A   │
│  Signal inputs/outputs (if Angular 17+)   │  PASS | FAIL | N/A   │
│  inject() over constructor injection      │  PASS | FAIL         │
│  Lazy loading for all feature routes      │  PASS | FAIL         │
│  trackBy on all ngFor / @for             │  PASS | FAIL         │
│  No manual subscriptions without cleanup  │  PASS | FAIL         │
│  takeUntilDestroyed or async pipe used    │  PASS | FAIL         │
│  TypeScript strict mode enabled           │  PASS | FAIL         │
│  Bundle budgets configured                │  PASS | FAIL         │
│  Core/shared/feature module separation    │  PASS | FAIL         │
│  No circular dependencies                 │  PASS | FAIL         │
│  Smart vs presentational component split  │  PASS | FAIL         │
│  HTTP interceptors for cross-cutting      │  PASS | FAIL         │
│  Error handling (global error handler)    │  PASS | FAIL         │
│  Test coverage meets thresholds           │  PASS | FAIL         │
│  No console.log in production code        │  PASS | FAIL         │
└───────────────────────────────────────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Deliverables & Handoff
Generate the project artifacts:

```
ANGULAR PROJECT COMPLETE:

Artifacts:
- Architecture: <Standalone | NgModule>
- Components: <N> components (OnPush: <M>%)
- Services: <N> services
- Routes: <N> routes (<N> lazy-loaded)
- State management: <Signals | NgRx | Services>
- Guards: <N> route guards
- Interceptors: <N> HTTP interceptors
- Tests: <N> test files, <M>% coverage
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:tailwind — Set up Tailwind CSS styling
-> /godmode:a11y — Accessibility audit
-> /godmode:e2e — End-to-end testing with Playwright
-> /godmode:build — Implement features
-> /godmode:ship — Deploy the application
```

Commit: `"angular: <project> — <N> components, <architecture>, <state management>"`

## Key Behaviors

1. **Standalone by default.** New Angular 17+ projects use standalone components. NgModules are legacy; migrate incrementally.
2. **Signals for local state, NgRx for global state.** Don't use NgRx for a counter. Don't use signals for complex async flows across features.
3. **OnPush everything.** Every component uses `ChangeDetectionStrategy.OnPush`. No exceptions. Fix reactivity issues at the source, not by relaxing change detection.
4. **Unsubscribe from everything.** Use `takeUntilDestroyed()`, `async` pipe, or `DestroyRef`. Memory leaks from RxJS subscriptions are the most common Angular bug.
5. **inject() over constructors.** The `inject()` function is cleaner, works in functions, and is the Angular team's recommended approach.
6. **Lazy-load all features.** Every feature route uses `loadChildren` or `loadComponent`. Eager loading is only for the shell.
7. **Type everything strictly.** Enable TypeScript strict mode. Use interfaces for data shapes. Use generics in services. No `any`.

## Example Usage

### Building a new Angular app
```
User: /godmode:angular Build an e-commerce app with product catalog and cart

Angular: Starting project assessment...

ANGULAR PROJECT ASSESSMENT:
Angular version: 18 (latest)
Architecture: Standalone components
State management: NgRx SignalStore (product catalog) + Signals (cart)
Routing: Lazy-loaded standalone routes

Scaffolding:
  Features: home, products, cart, checkout, auth, admin
  Services: AuthService, ProductService, CartService, OrderService
  Guards: authGuard, adminGuard
  Interceptors: authInterceptor, errorInterceptor

32 components, 6 services, 2 guards, 2 interceptors
All OnPush, all lazy-loaded, all typed
```

### Migrating to standalone components
```
User: /godmode:angular Migrate our NgModule app to standalone components

Angular: Scanning modules...

Found 8 NgModules with 45 components
Migration plan:
  Phase 1: Mark leaf components as standalone (28 components)
  Phase 2: Convert shared module exports to standalone (12 components)
  Phase 3: Convert feature modules to route files (5 modules)
  Phase 4: Remove AppModule, use bootstrapApplication
  Phase 5: Clean up empty module files

Estimated effort: 4-6 hours
Starting with Phase 1...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Angular project assessment and setup |
| `--audit` | Audit existing Angular project against best practices |
| `--standalone` | Migrate NgModules to standalone components |
| `--ngrx` | Design and implement NgRx store |
| `--signals` | Migrate to signal-based inputs/outputs/state |
| `--routing` | Design and implement routing with lazy loading |
| `--di` | Review dependency injection architecture |
| `--perf` | Angular-specific performance audit |
| `--test` | Set up Jest and write component/service tests |
| `--generate <type> <name>` | Generate component/service/guard with tests |
| `--upgrade <from> <to>` | Upgrade Angular version migration guide |
| `--ssr` | Set up Angular SSR (v17+ or Universal) |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Angular version: @angular/core in package.json (<14 legacy, 14-16 mixed, 17+ standalone)
2. Architecture: count .module.ts (NgModule) vs standalone: true (Standalone)
3. State: @ngrx/store (NgRx), @ngxs/store (NGXS), signal() (Signals)
4. Build: angular.json (CLI), nx.json (Nx), builder type (esbuild vs webpack)
5. Testing: jest-preset-angular (Jest), karma.conf.js (Karma), playwright/cypress (E2E)
6. SSR: @angular/ssr or @nguniversal
7. UI library: @angular/material, primeng, ng-bootstrap, @taiga-ui
8. TypeScript: tsconfig.json strict mode
```

## Output Format

End every Angular skill invocation with this summary block:

```
ANGULAR RESULT:
Action: <scaffold | component | service | module | optimize | test | audit | upgrade>
Components created/modified: <N>
Services created/modified: <N>
Angular version: <N>
Standalone: <yes | no | mixed>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Append one TSV row to `.godmode/angular.tsv` after each invocation:

```
timestamp	project	action	components_count	services_count	modules_count	tests_status	build_status	notes
```

## Success Criteria

Every Angular skill invocation must pass ALL of these checks before reporting success:

1. `ng build` completes with zero errors
2. `ng test --no-watch --browsers=ChromeHeadless` passes (if test suite exists)
3. No components using default change detection (all must use `OnPush`)
4. No `any` types in application code
5. All subscriptions have cleanup via `takeUntilDestroyed()`, `async` pipe, or explicit unsubscribe
6. No nested subscriptions (use RxJS operators instead)
7. All feature routes are lazy-loaded with `loadChildren` or `loadComponent`
8. No direct DOM manipulation (no jQuery, no `document.querySelector`)
9. Strict TypeScript enabled in `tsconfig.json`
10. All services use constructor injection (no `@Autowired` on fields)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

When errors occur, follow these remediation steps:

```
IF ng build fails:
  1. Read the full error output
  2. Fix type errors first (these cascade into template errors)
  3. Fix template binding errors (property does not exist on component)
  4. Check for circular dependency warnings and break cycles with injection tokens
  5. Verify all imports are correct (standalone components must import dependencies)

IF tests fail:
  1. Check that TestBed is configured with all required providers and imports
  2. Verify mocks match the interface of the real service
  3. Check async tests use fakeAsync/tick or waitForAsync
  4. Verify HttpClientTestingModule is imported for HTTP tests
  5. Check that OnPush components have change detection triggered in tests

IF runtime errors (change detection):
  1. ExpressionChangedAfterItHasBeenCheckedError → move logic to ngOnInit or use signals
  2. Verify OnPush components call markForCheck() or use async pipe
  3. Check that state mutations happen inside NgZone

IF dependency injection errors:
  1. NullInjectorError → add missing provider to component, module, or root
  2. Circular dependency → use forwardRef() or restructure service dependencies
  3. Check providedIn: 'root' vs module-level providers

IF RxJS memory leaks:
  1. Add takeUntilDestroyed() to all manual subscriptions
  2. Replace .subscribe() in templates with async pipe
  3. Use shareReplay({ bufferSize: 1, refCount: true }) for shared observables
```

## Keep/Discard Discipline
```
After EACH Angular architecture change:
  1. MEASURE: Run ng build AND ng test --no-watch --browsers=ChromeHeadless.
  2. COMPARE: Does the build pass with zero errors? Do all tests pass?
  3. DECIDE:
     - KEEP if build passes AND tests pass AND no Default change detection AND no any types.
     - DISCARD if build fails OR tests fail OR new Default change detection introduced.
  4. COMMIT kept changes. Revert discarded changes before the next iteration.

Never keep a component that uses Default change detection.
Never keep a subscription without cleanup (takeUntilDestroyed or async pipe).
```

## Stop Conditions
```
STOP when ANY of these are true:
  - ng build passes AND ng test passes AND all components use OnPush AND all routes lazy-loaded
  - Zero any types AND all subscriptions have cleanup AND strict TypeScript enabled
  - User explicitly requests stop
  - Max iterations (10) reached
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Replace `Agent("task")` → run the task inline in the current conversation
- Replace `EnterWorktree` → use `git stash` + work in current directory
- Replace `TodoWrite` → track progress with numbered comments in chat
- All Angular conventions, patterns, and quality checks still apply identically
