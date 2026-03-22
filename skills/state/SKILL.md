---
name: state
description: |
  State management design and implementation skill. Activates when a developer needs to design, implement, or refactor application state architecture. Covers frontend state (Redux, Zustand, Jotai, MobX, Pinia, Signals), server state (React Query, SWR, Apollo Client), state machines (XState, Robot), optimistic updates, cache synchronization, and state persistence/hydration. Triggers on: /godmode:state, "manage state", "state management", "global state", "server cache", "optimistic update", "state machine", or when application state patterns need architectural guidance.
---

# State -- State Management Design & Implementation

## When to Activate
- User invokes `/godmode:state`
- User says "manage state," "global state," "where should I put this state?"
- User asks about Redux, Zustand, Jotai, MobX, Pinia, Signals, or any state library
- User needs server state management (React Query, SWR, Apollo Client, RTK Query)
- User wants to design a state machine (XState, Robot)
- User needs optimistic updates, cache invalidation, or cache synchronization
- User asks about state persistence, hydration, or SSR state transfer
- User encounters stale state, race conditions, or state synchronization bugs
- Godmode orchestrator detects state management patterns that need improvement

## Workflow

### Step 1: Audit Current State Architecture

Identify the project's current state management approach, framework, and pain points:

```
STATE AUDIT:
Framework:          <React | Vue | Svelte | Angular | Solid | Qwik | Vanilla>
State libraries:    <Redux | Zustand | Jotai | MobX | Pinia | Signals | Context | None>
Server state:       <React Query | SWR | Apollo Client | RTK Query | None>
State machines:     <XState | Robot | Custom | None>
Routing state:      <URL params | search params | hash | none>
Form state:         <React Hook Form | Formik | Vuelidate | Custom | Unmanaged>
Persistence:        <localStorage | sessionStorage | IndexedDB | cookies | none>
SSR hydration:      <yes | no | partial>
Pain points:        <prop drilling | stale data | race conditions | over-rendering | complexity>
```

Scan the codebase for state patterns:
```bash
# Detect state management libraries
grep -r "from 'redux\|from 'zustand\|from 'jotai\|from 'mobx\|from '@tanstack/react-query\|from 'swr\|from 'xstate\|from '@apollo/client\|from 'pinia\|from '@preact/signals\|from '@angular/signals" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.vue" -l

# Count state-related files
find src/ -name "*.store.*" -o -name "*.slice.*" -o -name "*.atom.*" -o -name "*.machine.*" -o -name "*Store.*" -o -name "*Context.*" | wc -l

# ... (condensed)
```

### Step 2: Classify State by Category

All application state falls into one of these categories. Correct classification drives correct tool selection:

```
STATE CLASSIFICATION:
+-------------------+------------------+----------------------------------+----------------------------+
| Category          | Lifetime         | Examples                         | Recommended Tool           |
+-------------------+------------------+----------------------------------+----------------------------+
| Server state      | Cache lifetime   | API data, user profiles,         | React Query, SWR,          |
|                   |                  | product listings, search results | Apollo Client, RTK Query   |
+-------------------+------------------+----------------------------------+----------------------------+
| Client state      | Session/tab      | UI toggles, sidebar open/close,  | Zustand, Jotai, Signals,   |
| (UI)              |                  | active tab, modal visibility     | useState, Pinia            |
+-------------------+------------------+----------------------------------+----------------------------+
| Client state      | Session/tab      | Shopping cart, form wizard,       | Zustand, Redux, MobX,      |
| (Domain)          |                  | multi-step workflow, selections  | Pinia                      |
+-------------------+------------------+----------------------------------+----------------------------+
| Form state        | Component mount  | Input values, validation errors, | React Hook Form, Formik,   |
|                   |                  | dirty/touched tracking           | Vuelidate, native          |
```

**Key rule:** If data comes from a server, it is server state. Do NOT put it in Redux/Zustand/Pinia. Use a server-state tool (React Query, SWR, Apollo). This single distinction eliminates 80% of state management complexity.

### Step 3: Select State Management Solution

#### 3a: Frontend State Library Selection

```
FRONTEND STATE DECISION MATRIX:
+---------------+----------+--------+----------+--------+---------+----------+
| Criteria      | Redux TK | Zustand| Jotai    | MobX   | Pinia   | Signals  |
+---------------+----------+--------+----------+--------+---------+----------+
| Bundle size   | ~11KB    | ~1KB   | ~2KB     | ~16KB  | ~2KB    | ~1KB     |
| Boilerplate   | Medium   | Low    | Low      | Low    | Low     | Low      |
| DevTools      | Excellent| Good   | Good     | Good   | Excellent| Minimal |
| TypeScript    | Excellent| Excellent| Excellent| Good  | Excellent| Excellent|
| SSR support   | Good     | Good   | Good     | Fair   | Excellent| Good    |
| Learning curve| Steep    | Gentle | Gentle   | Medium | Gentle  | Gentle   |
| Best for      | Large    | Medium | Atomic   | Complex| Vue     | Fine-    |
|               | teams    | apps   | state    | domain | apps    | grained  |
+---------------+----------+--------+----------+--------+---------+----------+

RECOMMENDATION:
```

#### 3b: Server State Library Selection

```
SERVER STATE DECISION MATRIX:
+------------------+-------------+--------+--------------+----------+
| Criteria         | React Query | SWR    | Apollo Client| RTK Query|
+------------------+-------------+--------+--------------+----------+
| Protocol         | Any (REST,  | Any    | GraphQL      | Any      |
|                  | GraphQL)    |        | (primary)    |          |
+------------------+-------------+--------+--------------+----------+
| Cache control    | Fine-grained| Basic  | Normalized   | Tag-based|
| Devtools         | Excellent   | None   | Excellent    | Good     |
| Optimistic UI    | Built-in    | Manual | Built-in     | Built-in |
| Offline support  | Plugin      | Manual | Built-in     | Manual   |
| SSR/SSG          | Excellent   | Good   | Excellent    | Good     |
| Bundle size      | ~12KB       | ~4KB   | ~33KB        | ~11KB    |
| Best for         | REST APIs   | Simple | GraphQL      | Redux    |
|                  |             | fetch  | APIs         | users    |
```

### Step 4: Design State Architecture

#### 4a: Store Structure Design

For the selected library, design the store structure:

```
STORE ARCHITECTURE:
Root:
├── server state (React Query / SWR / Apollo)
│   ├── ['users', userId]          # User profile cache
│   ├── ['products', filters]      # Product listing cache
│   ├── ['orders', { page, limit }] # Paginated order cache
│   └── ['notifications']          # Notification feed cache
│
├── client state (Zustand / Redux / Jotai)
│   ├── ui/
│   │   ├── sidebar: { isOpen, width }
│   │   ├── modal: { activeModal, props }
│   │   └── theme: { mode, accent }
│   ├── domain/
│   │   ├── cart: { items, appliedCoupon }
```

#### 4b: Zustand Store Example

```typescript
// stores/cart.store.ts
import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface CartItem {
# ... (condensed)
```

#### 4c: Redux Toolkit Slice Example

```typescript
// store/slices/cart.slice.ts
import { createSlice, createSelector, PayloadAction } from '@reduxjs/toolkit';
import type { RootState } from '../store';

interface CartItem {
  productId: string;
# ... (condensed)
```

#### 4d: Jotai Atoms Example

```typescript
// atoms/cart.atoms.ts
import { atom } from 'jotai';
import { atomWithStorage } from 'jotai/utils';

interface CartItem {
  productId: string;
# ... (condensed)
```

### Step 5: Server State with React Query

#### 5a: Query Key Factory
```
QUERY KEY PATTERN:
  Create a query key factory object per entity:
    entity.all → ['entity']
    entity.lists() → ['entity', 'list']
    entity.list(filters) → ['entity', 'list', filters]
    entity.detail(id) → ['entity', 'detail', id]
  Use `as const` for type safety. Hierarchical keys enable targeted invalidation.
```

#### 5b: Query/Mutation Hook Rules
```
QUERY HOOKS:
  - Set staleTime (how long data is fresh, e.g., 5 min) and gcTime (cache retention, e.g., 30 min)
  - Use enabled to conditionally fetch (e.g., enabled: !!userId)
  - Use placeholderData: (prev) => prev to avoid layout shift during refetch

MUTATION HOOKS:
  - onSuccess: update specific cache with setQueryData + invalidate lists
  - For optimistic updates: onMutate → cancel queries, snapshot previous, update cache
  - onError → rollback to snapshot
  - onSettled → invalidate to re-sync with server
```

### Step 6: State Machine Design

#### 6a: When to Use a State Machine

```
STATE MACHINE DECISION:
Use a state machine when:
[x] The entity has a fixed set of states (loading, success, error, idle)
[x] Transitions between states follow strict rules (can't go from "idle" to "success")
[x] Invalid state combinations are possible ("loading AND error" should be impossible)
[x] The flow has branching logic (checkout: shipping -> payment -> review -> confirm)
[x] Complex async workflows (file upload: selecting -> uploading -> processing -> done)
[x] WebSocket/real-time lifecycle management (connecting -> connected -> disconnected -> reconnecting)

Do NOT use a state machine when:
[ ] Simple boolean toggle (isOpen, isDarkMode)
[ ] CRUD operations (React Query handles this better)
[ ] Form state (form libraries handle this better)
```

#### 6b: XState Machine Pattern

```typescript
// machines/checkout.machine.ts — XState v5 pattern
// States: shipping → payment → review → submitting → success | error | cancelled
// Each state defines: allowed transitions (on), side effects (actions), async work (invoke)
// Key rules:
//   - Type context and events explicitly
//   - Use assign() for context mutations
# ... (condensed)
```

### Step 7: State Persistence and Hydration

#### 7a: Persistence Strategy

```
PERSISTENCE STRATEGY:
+-------------------+-------------------+---------------+-------------------+
| Storage           | Capacity          | Speed         | Use Case          |
+-------------------+-------------------+---------------+-------------------+
| localStorage      | ~5-10 MB          | Synchronous   | Theme, prefs,     |
|                   |                   |               | small state       |
+-------------------+-------------------+---------------+-------------------+
| sessionStorage    | ~5-10 MB          | Synchronous   | Tab-specific,     |
|                   |                   |               | form drafts       |
+-------------------+-------------------+---------------+-------------------+
| IndexedDB         | ~50MB-unlimited   | Async         | Large datasets,   |
|                   |                   |               | offline data      |
+-------------------+-------------------+---------------+-------------------+
| cookies           | ~4 KB             | Synchronous   | Auth tokens,      |
|                   |                   |               | SSR-accessible    |
+-------------------+-------------------+---------------+-------------------+
| URL params        | ~2 KB practical   | Synchronous   | Shareable state   |
|                   |                   |               | (filters, pages)  |
+-------------------+-------------------+---------------+-------------------+
```

#### 7b: SSR Hydration Pattern

```
SSR HYDRATION RULES:
1. Server component reads initial state (cookies, headers, DB)
2. Pass initial state to a client StoreHydrator component
3. StoreHydrator calls useStore.setState(initialState) once via useRef guard
4. Never read persisted state during SSR — restore in useEffect only
5. Add hasHydrated flag to prevent flash of default content
```

#### 7c: Cache Synchronization

```
REALTIME CACHE SYNC PATTERN (WebSocket + React Query):
1. Open WebSocket in a useEffect hook
2. On message, switch on event type:
   - Single entity update: queryClient.setQueryData(key, payload)
   - List invalidation: queryClient.invalidateQueries({ queryKey })
   - Bulk update: invalidate entire entity scope
3. Clean up WebSocket on unmount
4. Use query key factory for consistent key references
```

### Step 8: Report and Transition

```
+--------------------------------------------------------------+
|  STATE MANAGEMENT DESIGN -- <description>                     |
+--------------------------------------------------------------+
|  Framework:         <framework>                               |
|  Client state:      <library selected>                        |
|  Server state:      <library selected>                        |
|  State machines:    <library selected, if applicable>         |
+--------------------------------------------------------------+
|  State categories identified:                                 |
|  - Server state:   <N> query keys                             |
|  - Client (UI):    <N> stores/atoms                           |
|  - Client (domain):<N> stores/atoms                           |
|  - URL state:      <N> parameters                             |
|  - Persisted:      <N> items                                  |
|  - State machines: <N> machines                               |
```

Commit: `"state: design <description> state architecture"`

## Key Behaviors

1. **Classify state before choosing a tool.** The single most important decision is separating server state from client state. Server state goes in React Query/SWR/Apollo. Client state goes in Zustand/Redux/Jotai.
2. **Minimize state.** If it can be computed from other state, it is derived state -- use selectors, not stored values. If it can live in the URL, put it in the URL. Less state means fewer bugs.
3. **Colocate state.** State should live as close to where it is used as possible. useState > Zustand store > Redux global. Only lift state when two distant components genuinely need it.
4. **Server state is a cache, not a store.** You do not own server data. You cache it. It can become stale. React Query/SWR handle staleness, refetching, and garbage collection. Redux does not.
5. **Optimistic updates need rollback.** Every optimistic update must have an onError rollback path. Snapshot previous state before mutating. Invalidate after settling.
6. **State machines prevent impossible states.** If you find yourself writing `isLoading && !isError && !isSuccess`, you need a state machine. A machine can only be in one state at a time.
7. **Persistence is not free.** localStorage is synchronous and blocks the main thread. IndexedDB is async but complex. Choose based on data size and access pattern.
8. **Selectors prevent re-renders.** Always access store state through selectors that pick only what the component needs. Never subscribe to the entire store.
9. **URL state is shareable state.** Filters, pagination, sort order, and selected items should be in the URL so users can share and bookmark.
10. **Hydration must be idempotent.** SSR hydration should produce the same result whether it runs once or twice. No side effects in hydration logic.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive state management design workflow |
| `--audit` | Audit current state architecture and identify issues |
| `--classify` | Classify all state in the codebase by category |

## HARD RULES

1. **NEVER put server data in Redux/Zustand/Pinia.** API data is server state. It belongs in React Query, SWR, or Apollo Client -- tools designed for cache management, staleness, and refetching.
2. **NEVER store derived state.** If `totalPrice` can be computed from `items`, compute it in a selector. Storing it creates synchronization bugs.
3. **NEVER use React Context for frequently-changing state.** Context re-renders ALL consumers on ANY change. Use Zustand, Jotai, or Signals instead.
4. **NEVER subscribe to the entire store.** Always use selectors: `useStore((s) => s.count)`, not `useStore()`.
5. **NEVER persist sensitive data in localStorage.** Auth tokens in localStorage are vulnerable to XSS. Use httpOnly cookies for auth.
6. **NEVER use optimistic updates without a rollback path.** Every optimistic update must have `onError` rollback that restores the snapshot.
7. **ALWAYS classify state before choosing a tool.** Server state vs client state is the single most important distinction. Get it right first.
8. **NEVER mix more than one client state library** in the same project (e.g., Redux AND Zustand AND Jotai). Pick one.

## Output Format

After each state management skill invocation, emit a structured report:

```
STATE ARCHITECTURE REPORT:
┌──────────────────────────────────────────────────────┐
│  Framework          │  <React | Vue | Svelte | etc>   │
│  Server state tool  │  <React Query | SWR | Apollo>   │
│  Client state tool  │  <Zustand | Jotai | Pinia>      │
│  Stores created     │  <N>                            │
│  Selectors          │  <N>                            │
│  Derived state      │  <N> computed values            │
│  Persistence        │  <localStorage | sessionStorage | none> │
│  Tests              │  <N> passing, <N> failing       │
│  Re-render issues   │  <N> found / <N> fixed          │
│  Verdict            │  PASS | NEEDS REVISION          │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every state architecture decision for tracking:

```
timestamp	skill	store	type	tool	selectors	tests_pass	status
2026-03-20T14:00:00Z	state	authStore	client	zustand	4	6/6	pass
2026-03-20T14:05:00Z	state	productsQuery	server	react-query	2	3/3	pass
```

## Success Criteria

The state skill is complete when ALL of the following are true:
1. Server state and client state are clearly separated (different tools)
2. No derived state is stored — all computed values use selectors or computed properties
3. Every store subscription uses a selector (no full-store subscriptions)
4. All stores have tests covering state transitions and edge cases
5. No unnecessary re-renders detected (verified with React DevTools Profiler or equivalent)
6. Persistence (if any) excludes sensitive data (no auth tokens in localStorage)
7. Optimistic updates have rollback handlers for error cases
8. State architecture is documented with a state flow diagram

## Error Recovery

```
IF component re-renders excessively:
  1. Check for full-store subscriptions — replace with targeted selectors
  2. Check for new object/array references created on every render
  3. Use React DevTools Profiler (or equivalent) to identify the trigger
  4. Add React.memo or useMemo only after identifying the specific cause

IF optimistic update causes stale UI:
  1. Verify the onError rollback restores the exact pre-mutation snapshot
  2. Check that the cache invalidation after mutation re-fetches fresh data
  3. Test the rollback path explicitly (simulate server error)
  4. If rollback fails, fall back to pessimistic update (wait for server confirmation)

IF hydration mismatch occurs with persisted state:
  1. Ensure persisted state is only restored in useEffect (not during SSR)
  2. Use a hydration-safe pattern: render server default first, then apply persisted state
```

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Detect framework: check package.json for react, vue, svelte, angular, solid
2. Detect existing state management:
   - grep for 'redux', 'zustand', 'jotai', 'recoil', 'pinia', 'vuex', 'mobx' in package.json
3. Detect server state tools:
   - grep for '@tanstack/react-query', 'swr', '@apollo/client', 'urql' in package.json
4. Detect form libraries:
   - grep for 'react-hook-form', 'formik', 'vee-validate' in package.json
5. Detect persistence:
   - grep for 'localStorage', 'sessionStorage', 'zustand/middleware' in src/
6. Auto-configure: match state tool recommendations to detected framework
```

## Iterative State Architecture Loop

```
current_iteration = 0
max_iterations = 10
state_tasks = [classify_state, setup_server_state, setup_client_state, add_selectors, add_persistence, add_tests]

WHILE state_tasks is not empty AND current_iteration < max_iterations:
    task = state_tasks.pop(0)
    1. Assess current state architecture for this task
    2. Implement the change (new store, selector, test, persistence)
    3. Verify: no TypeScript errors, no re-render regressions
    4. Run tests: all passing
    5. IF tests fail → revert and investigate
    6. IF passing → commit: "state: <action> for <store/feature>"
    7. current_iteration += 1

POST-LOOP: Run full test suite + re-render profiling to verify no regressions
```

## Keep/Discard Discipline
```
After EACH state architecture change:
  1. MEASURE: Run test suite + React DevTools Profiler (or equivalent) for re-render count.
  2. COMPARE: Did re-renders decrease or stay equal? Do all tests pass?
  3. DECIDE:
     - KEEP if tests pass AND no new re-render regressions AND no full-store subscriptions.
     - DISCARD if tests fail OR re-render count increased OR new derived state stored.
  4. COMMIT kept changes. Revert discarded changes before the next iteration.

Never keep a state change that introduces full-store subscriptions.
Never keep an optimistic update without a tested rollback path.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Server state and client state separated AND all subscriptions use selectors AND tests pass
  - No derived state stored AND no sensitive data in localStorage AND hydration is clean
  - User explicitly requests stop
  - Max iterations (10) reached
```
