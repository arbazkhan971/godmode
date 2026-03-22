# React/Next.js Developer Guide

How to use Godmode's full workflow for React and Next.js projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects React via package.json (react dependency)
# and Next.js via next.config.js / next.config.ts
# Test: npx vitest run / npx jest
# Lint: npx eslint . / npm run lint (next lint)
# Build: npm run build / next build
```

### Example `.godmode/config.yaml` (Next.js)
```yaml
language: typescript
framework: nextjs
test_command: npx vitest run
lint_command: npx next lint --max-warnings 0
build_command: npx next build
verify_command: npm run build && du -sh .next/static | awk '{print $1}'
```

### Example `.godmode/config.yaml` (React + Vite)
```yaml
language: typescript
framework: react-vite
test_command: npx vitest run
lint_command: npx eslint . --max-warnings 0
build_command: npx vite build
verify_command: npx vite build && du -b dist/assets/*.js | awk '{s+=$1}END{print s}'
```

---

## Frontend-Specific Godmode Workflow

The standard Godmode chain adapts for frontend work:

```
think ─→ plan ─→ build ─→ optimize ─→ ship
  │        │        │         │          │
  ▼        ▼        ▼         ▼          ▼
Component  Task   TDD with   Bundle    Build +
tree &     list   component  size &    deploy
state      with   tests +    perf      preview
design     routes e2e tests  tuning
```

### Key Differences from Backend

1. **THINK produces a component tree**, not just interfaces. Define the component hierarchy, state management approach, and data flow.
2. **BUILD includes visual verification** — component rendering tests with Testing Library, not just unit logic tests.
3. **OPTIMIZE targets user-facing metrics** — Lighthouse score, bundle size, Core Web Vitals, not just server response time.
4. **SHIP includes preview deployment** — deploy to a preview URL (Vercel, Netlify) before merging.

---

## How Each Skill Applies to React/Next.js

### THINK Phase

| Skill | React/Next.js Adaptation |
|-------|--------------------------|
| **think** | Design the component tree and state architecture first. Define which components are server vs. client (Next.js App Router). Specify the data fetching strategy (RSC, `useQuery`, SWR). Include wireframes or component sketches. |
| **predict** | Expert panel evaluates rendering strategy (SSR, SSG, ISR, CSR), state management choice (useState, Zustand, Jotai, Redux), and accessibility implications. |
| **scenario** | Explore edge cases around loading states, error boundaries, hydration mismatches, race conditions in data fetching, and keyboard navigation. |

### BUILD Phase

| Skill | React/Next.js Adaptation |
|-------|--------------------------|
| **plan** | Each task maps to a component or route. Tasks specify: component file path, props interface, state requirements, and which tests to write (unit, integration, e2e). |
| **build** | TDD with Vitest + Testing Library. RED step writes a component test (render + assert). GREEN step implements the component. REFACTOR step extracts custom hooks, memoizes expensive renders. |
| **test** | Use `@testing-library/react` for component tests. Use Playwright for e2e tests. Test user interactions, not implementation details. Test accessibility with `jest-axe`. |
| **review** | Check for missing `key` props, excessive re-renders, prop drilling (should use context?), missing error boundaries, `useEffect` dependency issues, and accessibility violations. |

### OPTIMIZE Phase

| Skill | React/Next.js Adaptation |
|-------|--------------------------|
| **optimize** | Target bundle size, Lighthouse score, or specific Core Web Vitals (LCP, FID, CLS). Guard rail: `vitest run && next build` must pass. |
| **debug** | Use React DevTools Profiler to identify unnecessary re-renders. Check the Network tab for waterfall requests. Verify hydration matches with React strict mode. |
| **fix** | Autonomous fix loop handles test failures, build errors, and lint violations. Guard rail: `vitest run && eslint . && next build` |
| **secure** | Check for XSS in `dangerouslySetInnerHTML`, exposed API keys in client bundles, missing CSRF protection on mutations, and insecure `next.config.js` headers. |

### SHIP Phase

| Skill | React/Next.js Adaptation |
|-------|--------------------------|
| **ship** | Pre-flight: `vitest run && next lint && next build`. Deploy to preview URL. Run Lighthouse against preview. Verify no console errors. |
| **finish** | Ensure `package.json` version is bumped. Verify the build output is valid. Check that environment variables are documented. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Lighthouse performance | `npx lighthouse http://localhost:3000 --output=json --chrome-flags="--headless" \| jq '.categories.performance.score * 100'` | >= 90 |
| Bundle size (total JS) | `npm run build && du -b .next/static/chunks/*.js \| awk '{s+=$1}END{print s}'` | < 300KB (gzipped) |
| First Contentful Paint | `npx lighthouse http://localhost:3000 --output=json --chrome-flags="--headless" \| jq '.audits["first-contentful-paint"].numericValue'` | < 1800ms |
| Largest Contentful Paint | `npx lighthouse http://localhost:3000 --output=json --chrome-flags="--headless" \| jq '.audits["largest-contentful-paint"].numericValue'` | < 2500ms |
| Cumulative Layout Shift | `npx lighthouse http://localhost:3000 --output=json --chrome-flags="--headless" \| jq '.audits["cumulative-layout-shift"].numericValue'` | < 0.1 |
| Component test coverage | `npx vitest run --coverage \| grep 'All files' \| awk '{print $4}'` | >= 80% |
| Accessibility violations | `npx axe http://localhost:3000 --exit 2>&1 \| grep 'violations' \| awk '{print $1}'` | 0 |
| Build time | `/usr/bin/time npm run build 2>&1 \| grep real` | Project-specific |

---

## Common Verify Commands

### Tests pass
```bash
npx vitest run
```

### Component tests pass
```bash
npx vitest run --reporter=verbose
```

### E2E tests pass
```bash
npx playwright test
```

### Lint clean
```bash
npx next lint --max-warnings 0
# or
npx eslint . --max-warnings 0
```

### Type check clean
```bash
npx tsc --noEmit
```

### Build succeeds
```bash
npm run build
# or
npx next build
```

### Bundle size check
```bash
npx next build && du -sh .next/static
```

### Lighthouse audit
```bash
npx lighthouse http://localhost:3000 --output=json --chrome-flags="--headless" | jq '.categories.performance.score * 100'
```

### Accessibility check
```bash
npx playwright test --project=accessibility
```

---

## Tool Integration

### Vitest + Testing Library

Godmode's TDD cycle for React components:

```bash
# RED step: run single test file, expect failure
npx vitest run src/components/TaskCard.test.tsx

# GREEN step: run single test, expect pass
npx vitest run src/components/TaskCard.test.tsx

# After GREEN: run full suite
npx vitest run

# Coverage
npx vitest run --coverage
```

**Component test patterns** for Godmode TDD:
```tsx
// src/components/TaskCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { TaskCard } from './TaskCard';

describe('TaskCard', () => {
  const defaultProps = {
    title: 'Fix login bug',
    status: 'TODO' as const,
    assignee: 'Alice',
    onStatusChange: vi.fn(),
  };

  it('renders task title', () => {
    render(<TaskCard {...defaultProps} />);
    expect(screen.getByText('Fix login bug')).toBeInTheDocument();
  });

  it('displays assignee name', () => {
    render(<TaskCard {...defaultProps} />);
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });

  it('calls onStatusChange when status button clicked', () => {
    render(<TaskCard {...defaultProps} />);
    fireEvent.click(screen.getByRole('button', { name: /mark as in progress/i }));
    expect(defaultProps.onStatusChange).toHaveBeenCalledWith('IN_PROGRESS');
  });

  it('has no accessibility violations', async () => {
    const { container } = render(<TaskCard {...defaultProps} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

### Playwright (E2E)

E2E tests for the SHIP phase pre-flight:

```bash
# Run all e2e tests
npx playwright test

# Run specific test
npx playwright test tests/e2e/task-management.spec.ts

# With UI mode for debugging
npx playwright test --ui

# Generate HTML report
npx playwright test --reporter=html
```

**E2E test pattern:**
```typescript
// tests/e2e/task-management.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Task Management', () => {
  test('creates a new task', async ({ page }) => {
    await page.goto('/tasks');
    await page.click('button:has-text("New Task")');
    await page.fill('input[name="title"]', 'Fix login bug');
    await page.selectOption('select[name="assignee"]', 'Alice');
    await page.click('button:has-text("Create")');

    await expect(page.getByText('Fix login bug')).toBeVisible();
    await expect(page.getByText('TODO')).toBeVisible();
  });

  test('transitions task status', async ({ page }) => {
    await page.goto('/tasks');
    await page.click('text=Fix login bug');
    await page.click('button:has-text("Start")');

    await expect(page.getByText('IN_PROGRESS')).toBeVisible();
  });
});
```

### Next.js Build

Next.js build integration for the optimize loop:

```bash
# Full build (used as guard rail)
npx next build

# Analyze bundle composition
ANALYZE=true npx next build
# Opens bundle analyzer in browser

# Check build output size
npx next build && du -sh .next/static/chunks/*.js | sort -h

# Verify static pages generated
npx next build 2>&1 | grep '●\|○\|λ'
```

### next.config.js optimization:
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable for bundle analysis during optimize phase
  ...(process.env.ANALYZE === 'true' && {
    webpack: (config) => {
      const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
      config.plugins.push(new BundleAnalyzerPlugin({ analyzerMode: 'static' }));
      return config;
    },
  }),
  // Performance optimizations
  reactStrictMode: true,
  poweredByHeader: false,
  compress: true,
};
```

---

## Example: Full Workflow for Building a Next.js Application

### Scenario
Build a project management dashboard with Next.js App Router — task boards, real-time updates via WebSocket, team collaboration, and analytics charts.

### Step 1: Think (Design)
```
/godmode:think I need a project management dashboard with Next.js 14
App Router. Features: Kanban task board with drag-and-drop, real-time
updates via WebSocket, team member management, and project analytics
with charts. Use Server Components where possible, Zustand for client
state, and TanStack Query for server state.
```

Godmode produces a spec at `docs/specs/project-dashboard.md` containing:
- Component tree:
  ```
  RootLayout (server)
  ├── DashboardLayout (server)
  ├── Sidebar (server)
  ├── Header (client — user menu, notifications)
  └── Main
  ├── BoardPage (server — data fetch)
  │       │   ├── KanbanBoard (client — drag-and-drop)
  │       │   │   ├── Column (client)
  │       │   │   └── TaskCard (client)
  │       │   └── TaskModal (client)
  ├── TeamPage (server)
  └── AnalyticsPage (server + client charts)
  ```
- State architecture: Server state via TanStack Query, UI state via Zustand, real-time via WebSocket provider
- Data fetching: RSC for initial load, `useQuery` for client-side refetch, optimistic updates for drag-and-drop
- Accessibility: ARIA drag-and-drop, keyboard navigation, focus management on modals

### Step 2: Plan (Decompose)
```
/godmode:plan
```

Produces `docs/plans/project-dashboard-plan.md` with tasks:
1. Set up project structure and shared types (`app/types/`, `lib/`)
2. Build layout components: Sidebar, Header (`app/(dashboard)/layout.tsx`)
3. Implement TaskCard component with status badge (`components/TaskCard.tsx`)
4. Implement KanbanBoard with drag-and-drop (`components/KanbanBoard.tsx`)
5. Implement TaskModal with form validation (`components/TaskModal.tsx`)
6. Build board page with server-side data fetch (`app/(dashboard)/board/page.tsx`)
7. Add WebSocket provider for real-time updates (`providers/WebSocketProvider.tsx`)
8. Build analytics page with chart components (`app/(dashboard)/analytics/page.tsx`)
9. Add Playwright e2e tests for core workflows
10. Accessibility audit and fixes

### Step 3: Build (TDD)
```
/godmode:build
```

Each task follows RED-GREEN-REFACTOR:

**Task 3 — RED:**
```tsx
// components/TaskCard.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe } from 'jest-axe';
import { TaskCard } from './TaskCard';

describe('TaskCard', () => {
  const task = {
    id: 'task-1',
    title: 'Implement auth',
    status: 'TODO' as const,
    assignee: { name: 'Alice', avatar: '/alice.jpg' },
    priority: 'HIGH' as const,
    dueDate: '2025-04-01',
  };

  it('renders task title and assignee', () => {
    render(<TaskCard task={task} />);
    expect(screen.getByText('Implement auth')).toBeInTheDocument();
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });

  it('shows priority badge with correct color', () => {
    render(<TaskCard task={task} />);
    const badge = screen.getByText('HIGH');
    expect(badge).toHaveClass('bg-red-100');
  });

  it('opens detail modal on click', async () => {
    const onOpen = vi.fn();
    render(<TaskCard task={task} onOpen={onOpen} />);
    await userEvent.click(screen.getByRole('article'));
    expect(onOpen).toHaveBeenCalledWith('task-1');
  });

  it('is accessible', async () => {
    const { container } = render(<TaskCard task={task} />);
    expect(await axe(container)).toHaveNoViolations();
  });
});
```
Commit: `test(red): TaskCard — failing render, interaction, and a11y tests`

**Task 3 — GREEN:**
```tsx
// components/TaskCard.tsx
interface TaskCardProps {
  task: Task;
  onOpen?: (id: string) => void;
}

export function TaskCard({ task, onOpen }: TaskCardProps) {
  const priorityColors = {
    HIGH: 'bg-red-100 text-red-800',
    MEDIUM: 'bg-yellow-100 text-yellow-800',
    LOW: 'bg-green-100 text-green-800',
  };

  return (
    <article
      role="article"
      className="rounded-lg border p-4 cursor-pointer hover:shadow-md transition-shadow"
      onClick={() => onOpen?.(task.id)}
      tabIndex={0}
      onKeyDown={(e) => e.key === 'Enter' && onOpen?.(task.id)}
    >
      <h3 className="font-medium text-sm">{task.title}</h3>
      <div className="mt-2 flex items-center justify-between">
        <span className={`text-xs px-2 py-1 rounded ${priorityColors[task.priority]}`}>
          {task.priority}
        </span>
        <span className="text-xs text-gray-500">{task.assignee.name}</span>
      </div>
    </article>
  );
}
```
Commit: `feat: TaskCard — accessible card with priority badge and click handler`

Parallel agents handle tasks 3, 5, and 7 concurrently (independent components with no shared state).

### Step 4: Optimize
```
/godmode:optimize --goal "reduce bundle size" \
  --verify "npx next build 2>&1 | grep 'First Load JS' | head -1 | awk '{print \$4}'" \
  --target "< 85"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | Chart library imported in full | Dynamic import `react-chartjs-2` with `next/dynamic` | 142kB | 98kB | KEEP |
| 2 | Drag-and-drop library is heavy | Replace `react-beautiful-dnd` with `@dnd-kit/core` | 98kB | 87kB | KEEP |
| 3 | Date formatting pulls in full `date-fns` | Import only needed functions (`format`, `formatDistance`) | 87kB | 82kB | KEEP |
| 4 | Icon library loads all icons | Switch to individual icon imports | 82kB | 78kB | KEEP |
| 5 | Zustand included in server bundle | Add `'use client'` directive to store file | 78kB | 77kB | REVERT |

Final: 142kB to 78kB First Load JS (45.1% reduction). Target met.

### Step 5: Secure
```
/godmode:secure
```

Findings:
- HIGH: No CSRF protection on mutation endpoints — add CSRF tokens via middleware
- MEDIUM: WebSocket connection has no authentication — validate JWT on connection
- MEDIUM: Task content rendered with `dangerouslySetInnerHTML` — sanitize with DOMPurify
- LOW: Missing Content-Security-Policy headers — add via `next.config.js`

### Step 6: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
npx vitest run                ✓ 48/48 passing
npx tsc --noEmit              ✓ 0 errors
npx next lint                 ✓ 0 warnings
npx next build                ✓ build succeeded
npx playwright test           ✓ 12/12 e2e passing
First Load JS                 ✓ 78kB (target: < 85kB)
Lighthouse perf               ✓ 94 (target: >= 90)
a11y violations               ✓ 0
```

PR created with full description, bundle size optimization log, Lighthouse scores, and security audit summary.

---

## React/Next.js-Specific Tips

### 1. Component tree is your spec
In the THINK phase, sketch the component tree with server/client boundaries marked. This is the most important artifact for a React project. It determines data flow, bundle boundaries, and testing strategy.

### 2. Test user behavior, not implementation
Use Testing Library's queries (`getByRole`, `getByText`) instead of implementation-specific selectors. Godmode's test skill generates behavior-driven tests by default for React projects. If you reach for `container.querySelector`, reconsider.

### 3. Bundle size is your primary optimization metric
For frontend projects, bundle size directly impacts user experience. Use `next/dynamic` for heavy components, tree-shake imports, and track the "First Load JS" metric from `next build` output:
```
/godmode:optimize --goal "reduce First Load JS" --verify "npx next build 2>&1 | grep 'First Load JS' | head -1 | awk '{print \$4}'" --target "< 80"
```

### 4. Server Components are free
In Next.js App Router, default to Server Components. They add zero bytes to the client bundle. Only add `'use client'` when you need interactivity (event handlers, hooks, browser APIs). Godmode's review skill flags unnecessary `'use client'` directives.

### 5. Accessibility is a guard rail, not a feature
Include accessibility checks in your guard rails from day one. `jest-axe` in component tests and Playwright accessibility tests in e2e catch violations early:
```yaml
guard_rails:
  - command: npx vitest run
    expect: exit code 0
  - command: npx next build
    expect: exit code 0
  - command: npx playwright test --project=accessibility
    expect: exit code 0
```

### 6. Use Playwright for the SHIP pre-flight
E2E tests with Playwright verify the real user experience before shipping. Run them against the production build (`next start`), not the dev server:
```bash
npx next build && npx next start &
npx playwright test
kill %1
```
