---
name: react
description: |
  React architecture skill. Activates when building, refactoring, or optimizing React applications. Covers component architecture, state management strategy, performance optimization, React Server Components, concurrent features, and testing with React Testing Library. Triggers on: /godmode:react, "React", "component architecture", "state management", "React performance", "hooks", "Server Components".
---

# React — React Architecture

## When to Activate
- User invokes `/godmode:react`
- User says "React app", "component architecture", "state management"
- User mentions "React performance", "re-renders", "memo", "useMemo"
- User asks about "hooks", "Server Components", "Suspense", "React Testing Library"

## Workflow

### Step 1: Project Assessment
```
REACT ASSESSMENT:
Project: <name> | Framework: <Next.js | Remix | Vite | CRA>
React version: <18, 19+> | Rendering: <SPA | SSR | SSG | hybrid>
Scale: <component count, team size>
Pain points: <re-renders, prop drilling, testing gaps, bundle size>
```

### Step 2: Component Architecture
**Composition (default):** Small focused components, slot pattern for layouts.
**Custom Hooks:** Extract stateful logic (useDebounce, useMediaQuery, useLocalStorage).
**Render Props:** When parent controls rendering.
**HOCs:** Cross-cutting concerns. Prefer hooks for new code.

Hierarchy: Pages (routes, data) -> Features (business logic) -> UI Components (reusable) -> Primitives (atoms).

Rules: One thing per component. Small props interface. Composition > configuration. Feature folders > tech folders.

### Step 3: State Management

| State Type | Solution |
|--|--|
| Server/async (API) | TanStack Query / SWR |
| URL (params, filters) | useSearchParams / nuqs |
| Form | React Hook Form + Zod |
| Local UI | useState / useReducer |
| Shared UI | Zustand or Jotai |
| Complex global | Zustand or Redux Toolkit |

### Step 4: Performance
1. **React.memo** — only with measured evidence
2. **useMemo** — only for expensive computations (>1ms)
3. **useCallback** — only when passed to memo'd child
4. **Code splitting** — lazy() + Suspense at route level
5. **Virtualization** — @tanstack/react-virtual for 100+ items
6. **Suspense** — for data fetching

GOLDEN RULE: Measure before optimizing. Use React DevTools Profiler.

### Step 5: Server Components & Concurrent Features
RSC: server-only, zero client JS, direct DB access, streaming with Suspense.
useTransition: non-urgent state updates. useDeferredValue: defer expensive re-renders.

### Step 6: Testing
Pyramid: E2E (Playwright, few) -> Integration (RTL, many) -> Unit (Vitest).
Query: getByRole > getByLabelText > getByText > getByTestId (last resort).
Rules: Test behavior not implementation. userEvent > fireEvent. MSW for API mocking. No snapshot tests on complex components.

### Step 7: Validation
```
REACT AUDIT:
- Composition over prop drilling: PASS | FAIL
- Custom hooks for reusable logic: PASS | FAIL
- State management per category: PASS | FAIL
- memo/useMemo with evidence: PASS | FAIL
- Code splitting at route level: PASS | FAIL
- Error boundaries: PASS | FAIL
- Tests with accessible queries: PASS | FAIL
- TypeScript strict: PASS | FAIL
VERDICT: <PASS | NEEDS REVISION>
```

## Key Behaviors

1. **Composition over configuration.** Small components > many props.
2. **Hooks for logic, components for UI.**
3. **Right tool for right state.** Server=Query, URL=params, Form=RHF, UI=useState, Shared=Zustand.
4. **Measure before optimizing.**
5. **Test behavior, not implementation.**
6. **Server Components when possible.**
7. **Feature folders over tech folders.**

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full architecture workflow |
| `--audit` | Audit existing project |
| `--state` | State management strategy |
| `--perf` | Performance analysis |
| `--test` | Testing strategy |
| `--hooks` | Custom hook library |
| `--rsc` | Server Components guide |

## HARD RULES

1. NEVER use `any`. Use `unknown` + type guard.
2. NEVER put business logic in components.
3. NEVER use useEffect for derived state.
4. NEVER add memo without Profiler evidence.
5. NEVER test implementation details.
6. NEVER use index as key for reorderable lists.
7. NEVER prop-drill past 2 levels.
8. ALWAYS run `tsc --noEmit` after changes.
9. ALWAYS query by role first in tests.
10. ALWAYS colocate component + hook + test in feature folders.

## Output Format

```
REACT COMPLETE:
Project: <name> | Components: <N> across <M> features
State: <approach per category>
Tests: <N> patterns | Audit: <PASS | NEEDS REVISION>
```

## Auto-Detection

```
1. package.json: react version, framework
2. State: zustand, jotai, redux, react-query
3. Styling: tailwind, styled-components, CSS modules
4. Testing: vitest, jest, @testing-library/react
```

## Platform Fallback
Run tasks sequentially with branch isolation if Agent() unavailable.

## Error Recovery
| Failure | Action |
|--|--|
| Infinite re-render loop | Check `useEffect` dependency arrays. Look for objects/arrays created inline as deps. Use `useMemo`/`useCallback` to stabilize references. |
| State update on unmounted component | Use cleanup function in `useEffect`. Check for async operations that complete after unmount. Use `AbortController` for fetch. |
| Hydration mismatch (SSR) | Ensure server and client render identical output. Avoid `Date.now()`, `Math.random()`, or `window` during SSR. Use `useEffect` for client-only code. |
| Bundle size too large | Run `npx @next/bundle-analyzer` or `source-map-explorer`. Lazy-load routes with `React.lazy`. Check for unnecessary dependencies. |

## Success Criteria
1. `tsc --noEmit` passes with zero errors.
2. All existing tests pass (`npx vitest run` or `npm test`).
3. No `useEffect` with missing dependency array items (eslint `react-hooks/exhaustive-deps` clean).
4. All route components lazy-loaded with `React.lazy` or Next.js dynamic imports.

## TSV Logging
Append to `.godmode/react-results.tsv`:
```
timestamp	action	components_count	hooks_count	test_status	build_status	notes
```
One row per invocation. Never overwrite previous rows.

## Keep/Discard Discipline
```
After EACH React change:
  KEEP if: tsc passes AND tests pass AND no new ESLint warnings AND bundle size stable
  DISCARD if: type errors OR test failures OR hooks rules violated OR bundle size regressed
  On discard: revert. Fix type errors or hook dependencies before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - tsc --noEmit exits 0
  - All tests pass
  - No ESLint react-hooks warnings
  - Bundle size within budget
```
