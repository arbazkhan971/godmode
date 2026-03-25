---
name: state
description: >
  State management design. Frontend state, server
  state, state machines, optimistic updates, caching.
---

# State -- State Management Design

## Activate When
- `/godmode:state`, "manage state", "global state"
- Redux, Zustand, Jotai, Pinia, React Query, SWR
- State machines (XState), optimistic updates
- Stale state, race conditions, sync bugs

## Workflow

### Step 1: Audit Current State
```bash
# Detect state libraries
grep -r "from 'redux\|from 'zustand\|from 'jotai\|from '@tanstack/react-query\|from 'pinia" \
  src/ --include="*.ts" --include="*.tsx" -l 2>/dev/null

# Count state files
find src/ -name "*.store.*" -o -name "*.slice.*" \
  -o -name "*.atom.*" -o -name "*Store.*" \
  2>/dev/null | wc -l
```
```
STATE AUDIT:
Framework:     <React | Vue | Svelte | Angular>
State libs:    <Redux | Zustand | Jotai | Pinia>
Server state:  <React Query | SWR | Apollo | none>
Form state:    <React Hook Form | Formik | none>
Persistence:   <localStorage | IndexedDB | none>
```

### Step 2: Classify State
```
| Category     | Lifetime  | Tool                  |
|-------------|-----------|----------------------|
| Server      | Cache     | React Query, SWR     |
| Client (UI) | Session   | Zustand, Jotai, Pinia|
| Client (app)| Session   | Zustand, Redux, MobX |
| URL         | Navigation| Router search params  |
| Form        | Interaction| React Hook Form     |
| Persistent  | Forever   | localStorage + Zustand|

IF data comes from server: it is server state.
  Do NOT put it in Redux/Zustand/Pinia.
  Use React Query, SWR, or Apollo.
  This single decision eliminates 80% of complexity.
```

### Step 3: Select Solution

#### Frontend State
```
| Criteria    | Redux TK | Zustand | Jotai | Pinia |
|------------|---------|---------|-------|-------|
| Bundle     | ~11KB   | ~1KB   | ~2KB  | ~2KB  |
| Boilerplate| Medium  | Low    | Low   | Low   |
| DevTools   | Excellent| Good   | Good  | Excellent|
| TypeScript | Excellent| Excellent|Excellent|Excellent|

IF React + simple state: Zustand (1KB, minimal)
IF React + atomic state: Jotai (bottom-up)
IF React + complex state + devtools: Redux TK
IF Vue 3: Pinia (official, TypeScript-first)
IF need middleware/saga: Redux TK
```

#### Server State
```
IF REST API: React Query (best cache control)
IF GraphQL: Apollo Client (normalized cache)
IF already using Redux: RTK Query (integrated)
WHEN optimistic updates needed: React Query or Apollo
  (both have built-in support)
```

### Step 4: Design Store Architecture
```
Root:
├── server state (React Query)
│   ├── ['users', userId]
│   ├── ['products', filters]
│   └── ['orders', { page, limit }]
├── client state (Zustand)
│   ├── uiStore (sidebar, modals, theme)
│   ├── cartStore (items, quantities)
│   └── authStore (session, user)
└── URL state (router)
    └── search params, pagination
```

### Step 5: Server State (React Query)
```
QUERY KEY FACTORY per entity:
  entity.all -> ['entity']
  entity.lists() -> ['entity', 'list']
  entity.list(filters) -> ['entity', 'list', filters]
  entity.detail(id) -> ['entity', 'detail', id]

QUERY CONFIG:
  staleTime: 5 min (how long data is fresh)
  gcTime: 30 min (cache retention)
  enabled: !!userId (conditional fetch)

MUTATION onSuccess:
  1. setQueryData for optimistic single-entity
  2. invalidateQueries for list refresh
  IF optimistic: onMutate saves snapshot,
    onError restores snapshot (rollback)
```

### Step 6: State Machines (When to Use)
```
USE state machine (XState) when:
  [x] Fixed set of states (loading/success/error)
  [x] Strict transition rules
  [x] Invalid combinations possible
  [x] Branching workflows (checkout flow)
  [x] WebSocket lifecycle management

DO NOT use when:
  [ ] Simple boolean toggle
  [ ] Free-form text input
  [ ] List of items (use array state)
```

### Step 7: Persistence & Hydration
```
| Storage        | Capacity | Speed | Use Case     |
|---------------|----------|-------|-------------|
| localStorage  | ~5-10MB  | Sync  | Theme, prefs|
| sessionStorage| ~5-10MB  | Sync  | Form drafts |
| IndexedDB     | ~50MB+   | Async | Large data  |

SSR HYDRATION:
1. Server reads initial state
2. Pass to client StoreHydrator component
3. setState once via useRef guard
4. Never read persisted state during SSR
5. hasHydrated flag prevents flash
```

## Key Behaviors
1. **Classify state before choosing a tool.**
2. **Minimize state.** Derive, don't store.
3. **Colocate state.** useState > store > global.
4. **Server state is a cache, not a store.**
5. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER put server data in Redux/Zustand/Pinia.
2. NEVER store derived state. Use selectors.
3. NEVER use React Context for frequent changes.
4. NEVER subscribe to entire store. Use selectors.
5. NEVER persist auth tokens in localStorage.
6. NEVER use optimistic updates without rollback.
7. NEVER mix multiple client state libraries.

## Auto-Detection
```bash
grep -E "redux|zustand|jotai|pinia|vuex|mobx" \
  package.json 2>/dev/null
grep -E "@tanstack/react-query|swr|@apollo/client" \
  package.json 2>/dev/null
```

## TSV Logging
Log to `.godmode/state-results.tsv`:
`timestamp\tstore\ttype\ttool\tselectors\ttests\tstatus`

## Output Format
```
STATE: {framework}. Server: {tool}. Client: {tool}.
Stores: {N}. Selectors: {N}. Tests: {status}.
```

## Keep/Discard Discipline
```
KEEP if: tests pass AND no re-render regressions
  AND no full-store subscriptions
DISCARD if: tests fail OR re-renders increased
  OR new derived state stored
```

## Stop Conditions
```
STOP when:
  - Server/client state separated
  - All subscriptions use selectors
  - Tests pass, no sensitive data in localStorage
  - User requests stop OR max 10 iterations
```
