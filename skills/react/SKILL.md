---
name: react
description: React architecture -- components, state,
  performance, Server Components, testing.
---

## Activate When
- `/godmode:react`, "React app", "component architecture"
- "state management", "React performance", "re-renders"
- "hooks", "Server Components", "React Testing Library"

## Workflow

### 1. Project Assessment
```bash
grep -E "react|zustand|jotai|redux|react-query" \
  package.json 2>/dev/null
grep -r "use client\|use server" \
  --include="*.tsx" -l 2>/dev/null | head -10
```
```
Framework: Next.js | Remix | Vite | CRA
React: 18 | 19+ | Rendering: SPA | SSR | SSG
Pain points: re-renders, prop drilling, bundle size
```

### 2. Component Architecture
**Composition (default):** small focused components,
slot pattern for layouts.
**Custom Hooks:** extract stateful logic (useDebounce,
useMediaQuery, useLocalStorage).
**Render Props:** when parent controls rendering.

Hierarchy: Pages -> Features -> UI Components -> Atoms.
Rules: one thing per component, small props, composition
over configuration, feature folders over tech folders.

### 3. State Management
| Type | Solution |
|--|--|
| Server/async (API) | TanStack Query / SWR |
| URL (params) | useSearchParams / nuqs |
| Form | React Hook Form + Zod |
| Local UI | useState / useReducer |
| Shared UI | Zustand or Jotai |
| Complex global | Zustand or Redux Toolkit |

IF bundle >500KB: enable code splitting.
IF re-renders >3 per interaction: add memoization.

### 4. Performance
1. React.memo: only with measured evidence
2. useMemo: only for expensive computations (>1ms)
3. useCallback: only when passed to memo'd child
4. Code splitting: lazy() + Suspense at route level
5. Virtualization: @tanstack/react-virtual for 100+ items
6. Suspense: for data fetching

GOLDEN RULE: measure before optimizing.
Use React DevTools Profiler.

### 5. Server Components & Concurrent
RSC: server-only, zero client JS, direct DB access.
useTransition: non-urgent state updates.
useDeferredValue: defer expensive re-renders.

### 6. Testing
Pyramid: E2E (Playwright) -> Integration (RTL) -> Unit.
Query priority: getByRole > getByLabelText > getByText
> getByTestId (last resort).
Rules: test behavior not implementation. userEvent >
fireEvent. MSW for API mocking.

### 7. Audit
```
[ ] Composition over prop drilling
[ ] Custom hooks for reusable logic
[ ] State management per category
[ ] memo/useMemo with evidence only
[ ] Code splitting at route level
[ ] Error boundaries
[ ] Tests with accessible queries
[ ] TypeScript strict
```

## Quality Targets
- Target: <16ms render cycle (60fps)
- Target: <100KB component bundle size per route
- Re-render count: 0 unnecessary re-renders detected by profiler

## Hard Rules
1. NEVER use `any`. Use `unknown` + type guard.
2. NEVER business logic in components.
3. NEVER useEffect for derived state.
4. NEVER memo without Profiler evidence.
5. NEVER test implementation details.
6. NEVER index as key for reorderable lists.
7. NEVER prop-drill past 2 levels.
8. ALWAYS `tsc --noEmit` after changes.
9. ALWAYS query by role first in tests.
10. ALWAYS colocate component + hook + test.

## TSV Logging
Append `.godmode/react-results.tsv`:
```
timestamp	action	components	hooks	test_status	build_status	notes
```

## Keep/Discard
```
KEEP if: tsc passes AND tests pass AND no new
  ESLint warnings AND bundle size stable.
DISCARD if: type errors OR test failures OR hooks
  rules violated OR bundle regressed.
```

## Stop Conditions
```
STOP when ALL of:
  - tsc --noEmit exits 0
  - All tests pass
  - No ESLint react-hooks warnings
  - Bundle within budget
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Infinite re-render | Check useEffect deps, stabilize refs |
| Hydration mismatch | useEffect for client-only code |
| Bundle too large | Analyze, lazy-load routes |
| State on unmounted | Cleanup in useEffect, AbortController |
