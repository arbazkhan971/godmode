---
name: react
description: |
  React architecture skill. Activates when building, refactoring, or optimizing React applications. Covers component architecture (composition, render props, HOCs, custom hooks), state management strategy selection (local state, context, Zustand, Jotai, Redux Toolkit, server state), performance optimization (React.memo, useMemo, useCallback, Suspense, lazy loading, code splitting), React Server Components, concurrent features, and testing with React Testing Library. Every recommendation includes concrete code and performance rationale. Triggers on: /godmode:react, "React", "component architecture", "state management", "React performance", "React Testing Library", "hooks", "Server Components", "Suspense".
---

# React — React Architecture

## When to Activate
- User invokes `/godmode:react`
- User says "React app", "React component", "component architecture"
- User asks about "state management", "Redux", "Zustand", "Jotai", "context"
- User mentions "React performance", "re-renders", "memo", "useMemo", "useCallback"
- User asks about "hooks", "custom hooks", "render props", "HOC"
- User mentions "React Testing Library", "testing React components"
- User asks about "Server Components", "Suspense", "concurrent features"
- When `/godmode:plan` identifies a React project
- When `/godmode:review` flags React architecture issues

## Workflow

### Step 1: Project Assessment
Understand the React application context:

```
REACT PROJECT ASSESSMENT:
Project: <name and purpose>
Framework: <Next.js | Remix | Vite | CRA | Gatsby | custom>
React version: <18, 19+>
Rendering: <SPA | SSR | SSG | hybrid>
Scale: <component count, team size, feature velocity>
Existing patterns: <what state management, styling, routing>
Pain points: <re-renders, prop drilling, testing gaps, bundle size>
```

If the user hasn't specified, ask: "What framework are you using with React? What's your biggest pain point right now?"

### Step 2: Component Architecture
Design the component hierarchy using composition patterns:

```
COMPONENT ARCHITECTURE PATTERNS:

Pattern 1 — Composition (RECOMMENDED default):
  // Compose smaller, focused components
  function UserProfile({ user }) {
    return (
      <Card>
        <UserAvatar src={user.avatar} size="lg" />
        <UserInfo name={user.name} email={user.email} />
        <UserActions userId={user.id} />
      </Card>
    )
  }

  // Slot pattern for flexible layouts
  function PageLayout({ header, sidebar, children, footer }) {
    return (
      <div className="grid grid-cols-[240px_1fr]">
        <header>{header}</header>
        <aside>{sidebar}</aside>
        <main>{children}</main>
        <footer>{footer}</footer>
      </div>
    )
  }

Pattern 2 — Custom Hooks (extract reusable logic):
  // Extract stateful logic into custom hooks
  function useDebounce<T>(value: T, delay: number): T {
    const [debouncedValue, setDebouncedValue] = useState(value)
    useEffect(() => {
      const timer = setTimeout(() => setDebouncedValue(value), delay)
      return () => clearTimeout(timer)
    }, [value, delay])
    return debouncedValue
  }

  function useMediaQuery(query: string): boolean {
    const [matches, setMatches] = useState(false)
    useEffect(() => {
      const mql = window.matchMedia(query)
      setMatches(mql.matches)
      const handler = (e: MediaQueryListEvent) => setMatches(e.matches)
      mql.addEventListener('change', handler)
      return () => mql.removeEventListener('change', handler)
    }, [query])
    return matches
  }

  function useLocalStorage<T>(key: string, initial: T) {
    const [value, setValue] = useState<T>(() => {
      const stored = localStorage.getItem(key)
      return stored ? JSON.parse(stored) : initial
    })
    useEffect(() => {
      localStorage.setItem(key, JSON.stringify(value))
    }, [key, value])
    return [value, setValue] as const
  }

Pattern 3 — Render Props (inversion of control):
  // When the parent needs to control rendering
  function DataLoader<T>({ url, children }: {
    url: string
    children: (data: T, loading: boolean) => ReactNode
  }) {
    const { data, isLoading } = useSWR<T>(url)
    return children(data!, isLoading)
  }

  // Usage:
  <DataLoader<User[]> url="/api/users">
    {(users, loading) => loading
      ? <Skeleton />
      : <UserList users={users} />
    }
  </DataLoader>

Pattern 4 — Higher-Order Components (cross-cutting concerns):
  // Use sparingly — prefer hooks for new code
  function withAuth<P extends object>(Component: ComponentType<P>) {
    return function AuthenticatedComponent(props: P) {
      const { user, loading } = useAuth()
      if (loading) return <Spinner />
      if (!user) return <Navigate to="/login" />
      return <Component {...props} />
    }
  }

COMPONENT HIERARCHY DESIGN:
┌─────────────────────────────────────────────────────────┐
│  Layer           │  Responsibility          │  Examples  │
├──────────────────┼──────────────────────────┼───────────┤
│  Pages           │  Route entry points      │  HomePage  │
│                  │  Data fetching, layout   │  UserPage  │
├──────────────────┼──────────────────────────┼───────────┤
│  Features        │  Business logic          │  UserList  │
│                  │  Feature-specific state   │  CartPanel │
├──────────────────┼──────────────────────────┼───────────┤
│  UI Components   │  Reusable presentation   │  Button    │
│                  │  No business logic       │  Card      │
│                  │  Accept data via props   │  DataTable │
├──────────────────┼──────────────────────────┼───────────┤
│  Primitives      │  Design system atoms     │  Text      │
│                  │  Styling, accessibility  │  Icon      │
│                  │  No state at all         │  Stack     │
└──────────────────┴──────────────────────────┴───────────┘

RULES:
- Components should do ONE thing — split if doing two
- Props interface = component contract — keep it small
- Prefer composition over configuration (children > lots of props)
- Collocate related files: Component/, hook, types, tests, styles together
- Feature folders over technical folders (features/auth/ not hooks/useAuth)
```

### Step 3: State Management Strategy Selection
Choose the right state management approach:

```
STATE MANAGEMENT DECISION TREE:

START: What kind of state is this?
│
├── Server/async state (API data, cache)?
│   └── Use: TanStack Query (React Query) or SWR
│       - Automatic caching, deduplication, background refresh
│       - Handles loading, error, stale states
│       - Eliminates 80% of "global state" needs
│
├── URL state (search params, filters, pagination)?
│   └── Use: URL search params + useSearchParams()
│       - Shareable, bookmarkable, browser back/forward works
│       - nuqs library for type-safe search params
│
├── Form state (input values, validation, submission)?
│   └── Use: React Hook Form or Formik
│       - Uncontrolled inputs for performance
│       - Schema validation with Zod
│
├── Local UI state (open/closed, selected tab, hover)?
│   └── Use: useState / useReducer
│       - Simplest solution — no library needed
│       - useReducer for complex state transitions
│
├── Shared UI state (theme, sidebar, toast queue)?
│   └── Use: Zustand or Jotai (lightweight)
│       - Zustand: single store, actions, middleware
│       - Jotai: atomic state, bottom-up, minimal boilerplate
│       - Context only for infrequently-changing values
│
├── Complex global state (large feature state, many consumers)?
│   └── Use: Zustand (medium) or Redux Toolkit (large)
│       - Redux Toolkit: when you need middleware, devtools,
│         time-travel debugging, or team is already familiar
│       - Zustand: simpler API, less boilerplate, good devtools
│
└── Cross-component communication (sibling, distant)?
    └── Use: Event bus (tiny), Zustand (small), Redux (large)
        - AVOID prop drilling through more than 2 levels

COMPARISON MATRIX:
┌──────────────────────┬────────┬─────────┬───────┬───────────┬───────┐
│ Criteria             │ Context│ Zustand │ Jotai │ Redux TK  │ RQ    │
├──────────────────────┼────────┼─────────┼───────┼───────────┼───────┤
│ Bundle size          │ 0 KB   │ ~1 KB   │ ~2 KB │ ~11 KB    │ ~13KB │
│ Boilerplate          │ Low    │ Low     │ Low   │ Medium    │ Low   │
│ DevTools             │ Basic  │ Good    │ Good  │ Excellent │ Excel │
│ Server Components    │ Yes    │ No*     │ No*   │ No*       │ Yes   │
│ Learning curve       │ Low    │ Low     │ Low   │ Medium    │ Low   │
│ Async state          │ Poor   │ Manual  │ Good  │ RTK Query │ Excel │
│ Computed/derived     │ Manual │ Good    │ Excel │ Reselect  │ N/A   │
│ Middleware           │ No     │ Yes     │ No    │ Yes       │ N/A   │
│ Persistence          │ Manual │ Plugin  │ Plugin│ Plugin    │ Built │
└──────────────────────┴────────┴─────────┴───────┴───────────┴───────┘
* = needs 'use client' wrapper

ANTI-PATTERN: Do NOT put everything in global state.
  Most "global state" is actually server state (use React Query)
  or URL state (use search params). True global client state is rare.
```

### Step 4: Performance Optimization
Apply targeted performance optimizations:

```
PERFORMANCE OPTIMIZATION TOOLKIT:

1. React.memo — Prevent re-renders when props haven't changed:
  // ONLY use when: component is pure AND re-renders are measured to be costly
  const ExpensiveList = memo(function ExpensiveList({ items }: Props) {
    return items.map(item => <ExpensiveItem key={item.id} item={item} />)
  })

  // Custom comparison for complex props:
  const Chart = memo(ChartComponent, (prev, next) => {
    return prev.data.length === next.data.length
      && prev.data[0]?.id === next.data[0]?.id
  })

2. useMemo — Cache expensive computations:
  // ONLY use when: computation is measurably expensive (>1ms)
  const sortedAndFiltered = useMemo(() => {
    return items
      .filter(item => item.status === filter)
      .sort((a, b) => a.name.localeCompare(b.name))
  }, [items, filter])

  // Do NOT useMemo trivial operations — the overhead exceeds the savings

3. useCallback — Stabilize function references:
  // ONLY use when: function is passed to memo'd child or used in useEffect deps
  const handleSelect = useCallback((id: string) => {
    setSelectedId(id)
  }, [])

  // PREFER: Define handlers inline unless causing measured re-render issues

4. Code Splitting with lazy + Suspense:
  // Route-level splitting (most impactful)
  const AdminDashboard = lazy(() => import('./AdminDashboard'))
  const Analytics = lazy(() => import('./Analytics'))

  <Suspense fallback={<PageSkeleton />}>
    <Routes>
      <Route path="/admin" element={<AdminDashboard />} />
      <Route path="/analytics" element={<Analytics />} />
    </Routes>
  </Suspense>

  // Component-level splitting (heavy components)
  const RichTextEditor = lazy(() => import('./RichTextEditor'))
  const ChartLibrary = lazy(() => import('./ChartLibrary'))

5. Virtualization — Render only visible items:
  // For lists > 100 items, use @tanstack/react-virtual
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => scrollRef.current,
    estimateSize: () => 50,
  })

6. Suspense for data fetching:
  // React 18+ with compatible data libraries
  function Dashboard() {
    return (
      <Suspense fallback={<DashboardSkeleton />}>
        <DashboardContent />
      </Suspense>
    )
  }

PERFORMANCE DECISION MATRIX:
┌──────────────────────────────────────────────────────────────────┐
│ Symptom                        │ Solution                        │
├────────────────────────────────┼─────────────────────────────────┤
│ Component re-renders too often │ React.memo + stable props       │
│ Expensive computation in render│ useMemo with proper deps        │
│ Large bundle, slow initial load│ lazy() + Suspense code split    │
│ Long list rendering is slow    │ Virtualization (@tanstack/rv)   │
│ Parent re-render causes cascade│ Push state down, lift content up│
│ Context causes wide re-renders │ Split contexts, use selectors   │
│ Images cause layout shift/slow │ Lazy loading, proper dimensions │
│ Too many network requests      │ React Query dedup + cache       │
└────────────────────────────────┴─────────────────────────────────┘

GOLDEN RULE: Measure before optimizing.
  Use React DevTools Profiler to identify ACTUAL bottlenecks.
  Do NOT scatter memo/useMemo/useCallback everywhere "just in case."
```

### Step 5: Server Components & Concurrent Features
Apply React 19+ server and concurrent patterns:

```
REACT SERVER COMPONENTS (RSC):

Server Components (default in frameworks like Next.js):
  // Runs only on the server — zero client JavaScript
  async function ProductPage({ id }) {
    const product = await db.product.findUnique({ where: { id } })
    const reviews = await db.review.findMany({ where: { productId: id } })
    return (
      <article>
        <h1>{product.name}</h1>
        <p>{product.description}</p>
        <ReviewList reviews={reviews} />       {/* Server Component */}
        <AddToCartButton productId={id} />     {/* Client Component */}
      </article>
    )
  }

  Benefits:
  - Direct database/filesystem access — no API layer needed
  - Zero bundle size for server-only code
  - Automatic code splitting at the server/client boundary
  - Streaming HTML with Suspense

CONCURRENT FEATURES:

1. useTransition — Mark state updates as non-urgent:
  function SearchPage() {
    const [query, setQuery] = useState('')
    const [isPending, startTransition] = useTransition()

    function handleChange(e) {
      setQuery(e.target.value)            // Urgent — update input immediately
      startTransition(() => {
        setResults(filterLargeDataset(e.target.value))  // Non-urgent — can interrupt
      })
    }

    return (
      <>
        <input value={query} onChange={handleChange} />
        {isPending ? <Spinner /> : <ResultList results={results} />}
      </>
    )
  }

2. useDeferredValue — Defer re-rendering of expensive content:
  function SearchResults({ query }) {
    const deferredQuery = useDeferredValue(query)
    const isStale = query !== deferredQuery

    return (
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <ExpensiveResultList query={deferredQuery} />
      </div>
    )
  }

3. useOptimistic — Optimistic UI updates:
  function MessageThread({ messages, sendMessage }) {
    const [optimisticMessages, addOptimistic] = useOptimistic(
      messages,
      (state, newMessage) => [...state, { ...newMessage, sending: true }]
    )

    async function handleSend(formData) {
      const message = { text: formData.get('text'), id: crypto.randomUUID() }
      addOptimistic(message)               // Show immediately
      await sendMessage(message)            // Send to server
    }

    return (
      <div>
        {optimisticMessages.map(msg => (
          <Message key={msg.id} {...msg} />
        ))}
        <form action={handleSend}>
          <input name="text" />
          <button>Send</button>
        </form>
      </div>
    )
  }

4. use() hook — Suspend on promises and context:
  // Read a promise (suspends until resolved)
  function UserProfile({ userPromise }) {
    const user = use(userPromise)   // Suspends component until promise resolves
    return <div>{user.name}</div>
  }

  // Read context conditionally
  function Theme({ isDark }) {
    if (isDark) {
      const theme = use(DarkThemeContext)
      return <div style={theme}>...</div>
    }
    return <div>Light mode</div>
  }
```

### Step 6: Testing with React Testing Library
Design the testing strategy:

```
TESTING STRATEGY:

Test Pyramid for React:
┌───────────────────────────────┐
│       E2E (Playwright)        │  Few — critical user journeys
├───────────────────────────────┤
│     Integration (RTL)         │  Many — feature workflows
├───────────────────────────────┤
│       Unit (Vitest)           │  Hooks, utils, pure functions
└───────────────────────────────┘

React Testing Library Patterns:

1. Render and query by role (accessible queries):
  test('submits contact form', async () => {
    const onSubmit = vi.fn()
    render(<ContactForm onSubmit={onSubmit} />)

    await userEvent.type(
      screen.getByRole('textbox', { name: /email/i }),
      'user@example.com'
    )
    await userEvent.type(
      screen.getByRole('textbox', { name: /message/i }),
      'Hello world'
    )
    await userEvent.click(screen.getByRole('button', { name: /send/i }))

    expect(onSubmit).toHaveBeenCalledWith({
      email: 'user@example.com',
      message: 'Hello world',
    })
  })

2. Testing async operations:
  test('loads and displays user data', async () => {
    server.use(
      http.get('/api/users/1', () =>
        HttpResponse.json({ name: 'Alice', email: 'alice@example.com' })
      )
    )

    render(<UserProfile userId="1" />)

    expect(screen.getByText(/loading/i)).toBeInTheDocument()
    expect(await screen.findByText('Alice')).toBeInTheDocument()
    expect(screen.queryByText(/loading/i)).not.toBeInTheDocument()
  })

3. Testing custom hooks:
  test('useDebounce returns debounced value', async () => {
    const { result } = renderHook(() => useDebounce('hello', 300))
    expect(result.current).toBe('hello')

    // Fast forward time
    await act(async () => {
      vi.advanceTimersByTime(300)
    })
    expect(result.current).toBe('hello')
  })

4. Testing with context providers:
  function renderWithProviders(ui: ReactElement, options?: RenderOptions) {
    function Wrapper({ children }: { children: ReactNode }) {
      return (
        <QueryClientProvider client={new QueryClient()}>
          <ThemeProvider>
            <AuthProvider>{children}</AuthProvider>
          </ThemeProvider>
        </QueryClientProvider>
      )
    }
    return render(ui, { wrapper: Wrapper, ...options })
  }

QUERY PRIORITY (use in this order):
1. getByRole       — accessible name (BEST — tests accessibility too)
2. getByLabelText  — form fields
3. getByPlaceholder— when label is not visible
4. getByText       — non-interactive elements
5. getByTestId     — LAST RESORT only

RULES:
- Test behavior, not implementation — "user can submit form" not "state updates"
- Use userEvent over fireEvent — simulates real user interaction
- Use MSW (Mock Service Worker) for API mocking — intercepts at network level
- Use findBy* for async elements — waitFor is a fallback
- Do NOT test internal state — test what the user sees
- Do NOT snapshot test complex components — they break on every change
```

### Step 7: Validation
Validate the React architecture:

```
REACT ARCHITECTURE AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                                        │  Status          │
├───────────────────────────────────────────────┼──────────────────┤
│  Component composition over prop drilling     │  PASS | FAIL     │
│  Custom hooks extract reusable logic          │  PASS | FAIL     │
│  State management appropriate per category    │  PASS | FAIL     │
│  Server state uses React Query / SWR          │  PASS | FAIL     │
│  No unnecessary global state                  │  PASS | FAIL     │
│  memo/useMemo/useCallback used with evidence  │  PASS | FAIL     │
│  Code splitting at route level                │  PASS | FAIL     │
│  Long lists use virtualization                │  PASS | FAIL     │
│  Error boundaries at feature boundaries       │  PASS | FAIL     │
│  Tests use RTL with accessible queries        │  PASS | FAIL     │
│  Tests mock at network level (MSW)            │  PASS | FAIL     │
│  No implementation-detail testing             │  PASS | FAIL     │
│  Consistent file/folder structure             │  PASS | FAIL     │
│  TypeScript strict mode                       │  PASS | FAIL     │
│  Accessibility (roles, labels, keyboard)      │  PASS | FAIL     │
└───────────────────────────────────────────────┴──────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 8: Deliverables
Generate the project artifacts:

```
REACT ARCHITECTURE COMPLETE:

Artifacts:
- Component hierarchy: <N> components across <M> features
- State management: <selected approach per category>
- Performance: Code splitting, memo boundaries identified
- Testing: RTL setup with MSW, <N> test patterns established
- Audit: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:build — Implement components and features
-> /godmode:test — Write comprehensive test suites
-> /godmode:perf — Profile and optimize render performance
-> /godmode:a11y — Audit accessibility compliance
```

Commit: `"react: <project> — component architecture, <state management>, <N> patterns"`

## Key Behaviors

1. **Composition over configuration.** Small, focused components composed together beat large components with many props. Children and slots provide flexibility.
2. **Hooks for logic, components for UI.** Extract every piece of reusable logic into a custom hook. Components should mostly be about rendering.
3. **Right tool for right state.** Server state in React Query, URL state in search params, form state in React Hook Form, UI state in useState, shared state in Zustand. Never put everything in one global store.
4. **Measure before optimizing.** React DevTools Profiler first, memo/useMemo/useCallback second. Premature optimization creates unmaintainable code.
5. **Test behavior, not implementation.** Query by role, interact like a user, assert what they see. Never test internal state or hook return values directly.
6. **Server Components when possible.** Zero client JS for data display. Push interactivity to leaf components. Streaming with Suspense over loading spinners.
7. **Feature folders over tech folders.** Colocate components, hooks, tests, types, and styles by feature. Cross-cutting concerns go in shared/.

## Example Usage

### Designing component architecture
```
User: /godmode:react Design the component architecture for a project management app

REACT: Starting project assessment...

ASSESSMENT:
Project: Project management (Jira-like)
Framework: Next.js 14 (App Router)
Scale: ~150 components, 5-person team
Pain points: Prop drilling, re-render cascading in board view

ARCHITECTURE:
Features:
├── features/board/         # Kanban board
│   ├── BoardView.tsx       # Server Component — fetches board data
│   ├── BoardColumn.tsx     # Client — drag-drop target
│   ├── TaskCard.tsx        # Client — draggable, memo'd
│   ├── useBoard.ts         # Custom hook — board state + mutations
│   └── board.test.tsx      # Integration test
├── features/task/          # Task detail
│   ├── TaskDetail.tsx      # Server Component — fetches task
│   ├── TaskForm.tsx        # Client — form with React Hook Form
│   ├── CommentThread.tsx   # Client — real-time comments
│   └── useTask.ts          # Custom hook — CRUD operations
...

STATE MANAGEMENT:
- Server state: TanStack Query (boards, tasks, users, comments)
- URL state: nuqs (filters, search, selected task)
- Form state: React Hook Form + Zod (task creation/edit)
- UI state: useState (modals, panels, drag state)
- Shared UI: Zustand (sidebar, theme, notifications)
```

### Fixing performance issues
```
User: /godmode:react Our board view re-renders everything when dragging a card

REACT: Analyzing re-render cascade...

ROOT CAUSE: Board state lives in context, dragging updates position frequently,
all 200+ cards re-render on every position change.

FIXES:
1. Split DragContext from BoardDataContext — drag position changes don't trigger data re-renders
2. memo(TaskCard) with shallow comparison on task data props
3. Use Zustand for drag state — built-in selector support prevents unnecessary re-renders
4. Virtualize columns with > 50 cards using @tanstack/react-virtual
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full React architecture workflow |
| `--audit` | Audit existing React project |
| `--state` | Design state management strategy only |
| `--perf` | Performance optimization analysis |
| `--test` | Design testing strategy and patterns |
| `--hooks` | Design custom hook library |
| `--migrate <from>` | Migration guide (class to hooks, CRA to Vite, etc.) |
| `--patterns` | Component pattern catalog for the project |
| `--rsc` | Server Components architecture guide |

## Auto-Detection

On activation, silently detect the React project context before asking questions:

```
AUTO-DETECT SEQUENCE:
1. Check package.json for react version, framework (next, remix, gatsby, vite)
2. Check for tsconfig.json (TypeScript yes/no, strict mode)
3. Detect state management: grep for zustand, jotai, redux, @tanstack/react-query
4. Detect styling: tailwind.config, styled-components, CSS modules, emotion
5. Detect test setup: vitest.config, jest.config, @testing-library/react
6. Scan src/ for component patterns: hooks/, components/, features/, pages/
7. Check for .storybook/ (component library)
8. Detect router: react-router, next/navigation, @tanstack/router

OUTPUT: Pre-fill the Step 1 assessment with detected values.
         Only ask the user about values that could not be detected.
```

## Iterative Refactoring Loop

When the React skill involves multi-step component restructuring:

```
current_iteration = 0
max_iterations = 10
components_remaining = [list of components to refactor/create]

WHILE components_remaining is not empty AND current_iteration < max_iterations:
    component = components_remaining.pop(0)
    1. Analyze component's current state (props, hooks, dependencies)
    2. Apply the architecture pattern (extract hook, split component, add memo)
    3. Run type check: npx tsc --noEmit
    4. Run tests: npx vitest run --reporter=verbose <component-path>
    5. IF tests fail → revert, diagnose, adjust approach
    6. IF tests pass → commit: "react: <pattern> — <component>"
    7. current_iteration += 1
    8. Log: "Iteration {current_iteration}: {component} — DONE"

IF components_remaining is not empty:
    REPORT: "{len(components_remaining)} components remain — continue with /godmode:react"
```

## Multi-Agent Dispatch

For large React projects with 50+ components across features:

```
PARALLEL AGENT DISPATCH (4 worktrees):

Agent 1 — "react-components":
  Worktree: .worktrees/react-components
  Task: Refactor shared UI components (Button, Card, Modal, Table)
  Scope: src/components/**

Agent 2 — "react-features":
  Worktree: .worktrees/react-features
  Task: Restructure feature modules (extract hooks, split concerns)
  Scope: src/features/**

Agent 3 — "react-state":
  Worktree: .worktrees/react-state
  Task: Migrate state management (context → Zustand, add React Query)
  Scope: src/stores/**, src/hooks/use*Query*

Agent 4 — "react-tests":
  Worktree: .worktrees/react-tests
  Task: Write RTL integration tests for all features
  Scope: src/**/*.test.tsx

MERGE ORDER: components → state → features → tests
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER use `any` type. Use `unknown` + type guard or proper generics.
2. NEVER put business logic in components. Extract to custom hooks or services.
3. NEVER use useEffect for derived state. Compute during render or useMemo.
4. NEVER add React.memo without measured evidence from React DevTools Profiler.
5. NEVER test implementation details. Test what the user sees and does.
6. NEVER use index as key when list items can be reordered or deleted.
7. NEVER prop-drill through more than 2 levels — use composition or state management.
8. ALWAYS run `npx tsc --noEmit` after every component change.
9. ALWAYS query by role first in tests (getByRole > getByText > getByTestId).
10. ALWAYS colocate component + hook + test + types in feature folders.
```

## Output Format

Every React skill invocation ends with a structured summary:

```
REACT COMPLETE:
Project: <name>
Components: <N> across <M> features
State: <approach per category>
Performance: <optimizations applied>
Tests: <N> patterns, <M> test files
Audit: <PASS | NEEDS REVISION>
Duration: <time spent>
```

Commit message: `"react: <project> — <primary change>, <secondary change>"`

## TSV Logging

Append one row per React skill invocation to `.godmode/react-results.tsv`:

```
timestamp	project	action	components_count	tests_count	audit_status	notes
2024-01-15T10:30:00Z	my-app	architecture	24	12	PASS	component hierarchy + state management
2024-01-15T11:00:00Z	my-app	perf-audit	24	12	NEEDS_REVISION	3 memo boundaries missing
```

Fields: `timestamp` (ISO 8601), `project`, `action` (architecture | audit | perf | test | hooks | migrate | patterns | rsc), `components_count`, `tests_count`, `audit_status` (PASS | NEEDS_REVISION | SKIPPED), `notes` (free text, no tabs).

IF `.godmode/` directory does not exist, create it. IF the TSV file does not exist, write the header row first.

## Success Criteria

A React skill invocation is successful when ALL of the following are true:

1. `npx tsc --noEmit` passes with zero errors.
2. All existing tests pass (`npx vitest run` or `npx jest`).
3. No `any` types introduced in changed files.
4. Every new component has at least one co-located test file.
5. No prop drilling deeper than 2 levels in changed components.
6. State management choice matches the decision tree (server state in React Query, URL state in search params, etc.).
7. React DevTools Profiler shows no unnecessary re-renders in changed components.
8. The validation audit (Step 7) shows PASS on all applicable checks.

IF any criterion fails, fix before marking the invocation complete.

## Error Recovery

```
WHEN tsc --noEmit fails:
  1. Read the error output, identify the file and line.
  2. Fix the type error (do NOT use `any` or `// @ts-ignore`).
  3. Re-run tsc. Repeat until zero errors.

WHEN tests fail after refactor:
  1. Read the test failure output.
  2. Determine: is the test wrong (testing implementation) or the code wrong?
  3. If test is testing implementation details → rewrite test to test behavior.
  4. If code is wrong → fix the component/hook, re-run tests.
  5. Never delete a failing test without understanding why it fails.

WHEN React DevTools Profiler shows excessive re-renders:
  1. Identify the component re-rendering.
  2. Check: is a new object/array/function created on every render and passed as prop?
  3. Fix: stabilize with useMemo/useCallback ONLY if the re-render is measurably costly.
  4. Verify with Profiler that the fix reduced render count.

WHEN build fails (webpack/vite):
  1. Read the build error — usually import path or missing dependency.
  2. Fix the import or install the missing package.
  3. Re-run build. Never suppress build warnings without understanding them.

WHEN state management causes infinite loops:
  1. Check useEffect dependencies — circular dependency between state setter and dependency.
  2. Remove the problematic dependency or restructure the effect.
  3. If derived state, replace useEffect with useMemo or inline computation.
```

## Anti-Patterns

- **Do NOT put everything in global state.** Most "global state" is server state (React Query), URL state (search params), or form state (React Hook Form). True global client state is rare.
- **Do NOT scatter memo/useMemo/useCallback everywhere.** These have a cost. Use them only when React DevTools Profiler shows measured performance issues.
- **Do NOT test implementation details.** Testing `useState` values, internal methods, or snapshot testing complex components creates brittle tests that break on every refactor.
- **Do NOT use `useEffect` for derived state.** If a value can be computed from props or state, compute it during render. `useMemo` if expensive, inline if cheap.
- **Do NOT prop-drill through more than 2 levels.** Use composition (children), custom hooks, or lightweight state management.
- **Do NOT create one massive context for everything.** Split contexts by update frequency. Theme context (rare updates) should not share a provider with cursor position (frequent updates).
- **Do NOT skip error boundaries.** An uncaught error in one widget should not crash the entire app. Wrap features in error boundaries.
- **Do NOT ignore TypeScript.** Enable strict mode. Type your props, hooks, and context. Generic components (`DataTable<T>`) prevent runtime errors.


## Component Optimization Loop

Autoresearch-grade iterative optimization for React component performance. Run this loop after initial implementation to drive measurable improvements in re-render count, bundle size, and Lighthouse score.

```
COMPONENT OPTIMIZATION PROTOCOL:

Phase 1 — Re-render Reduction
  target_rerenders = 0 unnecessary re-renders per interaction
  current_iteration = 0
  max_iterations = 8

  WHILE measured_unnecessary_rerenders > 0 AND current_iteration < max_iterations:
    1. PROFILE with React DevTools Profiler (record an interaction)
    2. IDENTIFY components that re-render without prop/state changes
    3. MEASURE: count wasted renders, sum render durations (ms)
    4. CLASSIFY root cause:
       a. Unstable reference (new object/array/function on every render)
       b. Context over-subscription (consuming context that updates frequently)
       c. Parent cascade (parent re-renders, children follow)
       d. Missing memoization on expensive derived computation
    5. APPLY targeted fix:
       - (a) → useMemo/useCallback for the unstable reference
       - (b) → Split context or use selector pattern (Zustand/Jotai)
       - (c) → React.memo on child with stable props, or push state down
       - (d) → useMemo on the expensive computation
    6. RE-PROFILE same interaction
    7. RECORD:
       component | cause | fix | renders_before | renders_after | duration_delta_ms
    8. IF renders_after >= renders_before → REVERT fix (optimization failed)
    9. current_iteration += 1

  REPORT:
    Total unnecessary re-renders eliminated: <N>
    Total render duration reduced: <N>ms
    Components optimized: <list>

Phase 2 — Bundle Size Optimization
  target_bundle = project budget or < 200 KB initial JS (gzipped)
  current_bundle = measure with `npx next build` or `npx vite build`

  WHILE current_bundle > target_bundle:
    1. ANALYZE bundle with `npx webpack-bundle-analyzer` or `rollup-plugin-visualizer`
    2. IDENTIFY top 5 contributors by gzipped size
    3. FOR EACH contributor:
       a. Full library import? → Switch to named imports + tree-shaking
       b. Heavy dependency? → Evaluate lighter alternative:
          moment → date-fns or dayjs
          lodash → lodash-es or native methods
          chart.js full → @chartjs/auto
       c. Unused code? → Remove dead imports, audit barrel files
       d. Above-fold only? → Code-split with lazy() + Suspense
       e. Polyfill not needed? → Update browserslist, remove core-js
    4. REBUILD and MEASURE delta:
       chunk | size_before_kb | size_after_kb | technique
    5. VERIFY no regressions: run test suite, spot-check features
    6. IF size_after >= size_before → REVERT (optimization ineffective)

  METRICS TABLE:
  ┌──────────────────────────────────────────────────────────────────┐
  │  Metric                  │  Before    │  After     │  Target     │
  ├──────────────────────────┼────────────┼────────────┼─────────────┤
  │  Initial JS (gzipped)    │  <N> KB    │  <N> KB    │  < 200 KB   │
  │  Largest chunk           │  <N> KB    │  <N> KB    │  < 100 KB   │
  │  Total chunks            │  <N>       │  <N>       │  —          │
  │  Tree-shaking effective  │  YES/NO    │  YES/NO    │  YES        │
  │  Unused JS (Lighthouse)  │  <N> KB    │  <N> KB    │  < 50 KB    │
  └──────────────────────────┴────────────┴────────────┴─────────────┘

Phase 3 — Lighthouse Score Loop
  targets:
    Performance: >= 90
    Accessibility: >= 95
    Best Practices: >= 95
    SEO: >= 90

  WHILE any_score < target:
    1. RUN: npx lighthouse <url> --output=json --output-path=./lh-report.json
    2. PARSE scores and failing audits
    3. PRIORITIZE fixes by score impact (weight * potential improvement)
    4. FOR EACH failing audit (top 5 by impact):
       - LCP > 2.5s → Preload LCP image, inline critical CSS, optimize server response
       - CLS > 0.1 → Add width/height to images, reserve space for dynamic content
       - INP > 200ms → Break long tasks, defer non-critical handlers
       - Unused JS → Code-split, remove dead code, lazy-load below fold
       - Render-blocking resources → Defer non-critical CSS/JS, inline critical path
       - Image optimization → Convert to WebP/AVIF, add srcset+sizes
       - Missing accessibility → Add alt text, labels, ARIA, contrast fixes
    5. APPLY fix
    6. RE-RUN Lighthouse on same page
    7. RECORD:
       audit | score_before | score_after | technique
    8. IF score_after < score_before → REVERT

  CONVERGENCE CRITERIA:
    All 4 Lighthouse categories meet targets
    OR max 10 iterations reached (report remaining gaps)

  FINAL REPORT:
  ┌──────────────────────────────────────────────────────────────────┐
  │  Category         │  Start Score  │  Final Score  │  Target      │
  ├──────────────────────────────────────────────────────────────────┤
  │  Performance      │  <N>          │  <N>          │  >= 90       │
  │  Accessibility    │  <N>          │  <N>          │  >= 95       │
  │  Best Practices   │  <N>          │  <N>          │  >= 95       │
  │  SEO              │  <N>          │  <N>          │  >= 90       │
  ├──────────────────────────────────────────────────────────────────┤
  │  LCP              │  <N>s         │  <N>s         │  < 2.5s      │
  │  INP              │  <N>ms        │  <N>ms        │  < 200ms     │
  │  CLS              │  <N>          │  <N>          │  < 0.1       │
  │  Bundle (gzip)    │  <N> KB       │  <N> KB       │  < 200 KB    │
  │  Wasted renders   │  <N>          │  <N>          │  0           │
  └──────────────────────────────────────────────────────────────────┘
```

### Optimization Loop TSV Logging

Append one row per optimization action to `.godmode/react-optimization.tsv`:

```
timestamp	project	phase	target_component	metric	before	after	technique	status
2024-01-15T10:30:00Z	my-app	rerender	BoardColumn	render_count	12	2	split-context	improved
2024-01-15T10:45:00Z	my-app	bundle	vendor-chunk	size_kb	187	94	tree-shaking	improved
2024-01-15T11:00:00Z	my-app	lighthouse	/dashboard	performance	72	91	lcp-preload+codesplit	target_met
```

### Optimization Hard Rules

```
1. NEVER optimize without profiling first. React DevTools Profiler for re-renders, bundle analyzer for size, Lighthouse for scores.
2. NEVER add React.memo/useMemo/useCallback without a measured before/after. Each has overhead.
3. ALWAYS revert optimizations that show no measurable improvement or cause regressions.
4. ALWAYS re-run the full test suite after each optimization pass.
5. NEVER exceed 10 iterations per phase. If targets are not met, report the gap and recommend architectural changes.
6. Log every optimization action in TSV format for reproducibility and auditability.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run React tasks sequentially: components, then features, then state management, then tests.
- Use branch isolation per task: `git checkout -b godmode-react-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
