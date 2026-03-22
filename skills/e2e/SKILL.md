---
name: e2e
description: |
  End-to-end testing skill. Activates when user needs to build browser-based E2E tests, set up cross-browser testing, fix flaky tests, or implement page object models. Supports Playwright, Cypress, and Selenium. Covers test data management, CI integration, visual regression testing, and accessibility auditing. Triggers on: /godmode:e2e, "end-to-end test", "E2E test", "browser test", "Playwright test", "Cypress test", or when ship skill needs E2E validation.
---

# E2E — End-to-End Testing

## When to Activate
- User invokes `/godmode:e2e`
- User says "E2E test", "end-to-end test", "browser test", "integration test"
- User asks about Playwright, Cypress, or Selenium setup
- User needs to fix flaky E2E tests
- User wants cross-browser testing or visual regression
- Ship skill needs user-flow validation before deployment

## Workflow

### Step 1: Assess E2E Test State
Understand the current testing landscape:

```bash
# Find existing E2E tests
find . -name "*.e2e.*" -o -name "*.spec.*" -o -name "*.test.*" | grep -i -E "e2e|integration|browser|playwright|cypress|selenium" | grep -v node_modules

# Check for test framework config
ls playwright.config.* cypress.config.* cypress.json wdio.conf.* 2>/dev/null

```

```
E2E TEST STATE:
Framework: <Playwright | Cypress | Selenium | none>
Config file: <path or none>
Test count: <N>
Page objects: <N> (or none)
Test data strategy: <fixtures | factories | API seeding | none>
CI integration: <yes | no>
Last run result: <all passing | N failures | unknown>
Browsers tested: <chromium | firefox | webkit | chrome | edge>
Flaky tests: <N known flaky | unknown>
```

### Step 2: Design Test Architecture
Set up a maintainable E2E test structure:

#### Project Structure
```
e2e/
├── tests/                          # Test files organized by feature
│   ├── auth/
│   │   ├── login.spec.ts           # Login flow tests
│   │   ├── registration.spec.ts    # Registration flow tests
│   │   └── password-reset.spec.ts  # Password reset tests
│   ├── checkout/
│   │   ├── cart.spec.ts            # Shopping cart tests
│   │   ├── payment.spec.ts         # Payment flow tests
│   │   └── confirmation.spec.ts    # Order confirmation tests
│   └── dashboard/
│       ├── navigation.spec.ts      # Dashboard navigation
│       └── data-display.spec.ts    # Data rendering tests
├── pages/                          # Page Object Models
│   ├── base.page.ts                # Base page with common methods
```

#### Framework Configuration

**Playwright:**
```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: true,
```

**Cypress:**
```typescript
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
```

### Step 3: Page Object Model
Implement the Page Object pattern for maintainability:

```typescript
// e2e/pages/base.page.ts
import { Page, Locator, expect } from '@playwright/test';

export abstract class BasePage {
  constructor(protected readonly page: Page) {}

```

```typescript
// e2e/pages/login.page.ts
import { Page, Locator } from '@playwright/test';
import { BasePage } from './base.page';

export class LoginPage extends BasePage {
  // Locators — defined once, used everywhere
```

### Step 4: Write E2E Tests
Create tests that simulate real user journeys:

```typescript
// e2e/tests/auth/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../../pages/login.page';
import { DashboardPage } from '../../pages/dashboard.page';
import { testUsers } from '../../fixtures/test-data';

```

### Step 5: Test Data Management
Handle test data with isolated, reproducible strategies:

```typescript
// e2e/fixtures/test-data.ts
export const testUsers = {
  standard: {
    email: 'test-user@example.com',
    password: 'Test1234!',
    name: 'Test User',
```

```typescript
// e2e/fixtures/auth.fixture.ts — Playwright fixture for authenticated state
import { test as base, Page } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { testUsers } from './test-data';

type AuthFixtures = {
```

### Step 6: Flakiness Remediation
Diagnose and fix flaky E2E tests:

#### Common Flakiness Causes
```
FLAKINESS DIAGNOSIS:
| Symptom | Root Cause → Fix |
|--|--|
| Element not found | Race condition → Use auto-waiting locators |
|  | (Playwright: getByRole, Cypress: .should) |
| Timeout on navigation | Slow page load → Increase timeout, check |
|  | network conditions, use waitForLoadState |
| Stale element reference | DOM re-render → Re-query element after |
|  | action, avoid storing element references |
| Test order dependency | Shared state → Isolate test data, use |
|  | beforeEach for fresh state |
```

#### Flakiness Prevention Checklist
```
ANTI-FLAKINESS RULES:
- [ ] Never use fixed sleep/wait — use auto-waiting assertions instead
- [ ] Never depend on test execution order — each test is independent
- [ ] Never use CSS selectors for test locators — use data-testid, roles, labels
- [ ] Always clean up test data in afterEach/afterAll
- [ ] Always set explicit timeouts (don't rely on framework defaults)
- [ ] Always disable CSS animations in test mode
- [ ] Always seed test data via API/DB, not through the UI
- [ ] Always retry failed tests in CI (but investigate recurring retries)
- [ ] Always record traces/screenshots on failure for debugging
- [ ] Never assert on exact timestamps or random values
```

### Step 7: Cross-Browser Testing
Configure and run tests across browser matrix:

```
BROWSER MATRIX:
| Browser | Engine | Test Status | Known Issues |
|--|--|--|--|
| Chrome | Chromium | <PASS/FAIL> | <issues or none> |
| Firefox | Gecko | <PASS/FAIL> | <issues or none> |
| Safari | WebKit | <PASS/FAIL> | <issues or none> |
| Edge | Chromium | <PASS/FAIL> | <issues or none> |
| Mobile Chrome | Chromium | <PASS/FAIL> | <issues or none> |
| Mobile Safari | WebKit | <PASS/FAIL> | <issues or none> |

CROSS-BROWSER ISSUES FOUND:
1. <issue> — Affects <browser> — Fix: <recommendation>
2. <issue> — Affects <browser> — Fix: <recommendation>
```

### Step 8: Generate E2E Report

```
  E2E TEST REPORT — <project>
  Framework: <Playwright | Cypress | Selenium>
  Total tests: <N>
  Passing: <N>  Failing: <N>  Skipped: <N>
  Duration: <X>s (parallel: <N> workers)
  COVERAGE BY FEATURE:
  Auth flows: <N> tests — <PASS/FAIL>
  Checkout: <N> tests — <PASS/FAIL>
  Dashboard: <N> tests — <PASS/FAIL>
  Settings: <N> tests — <PASS/FAIL>
  CROSS-BROWSER:
```

### Step 9: Commit and Transition
1. Save test files to `e2e/` directory
2. Save report as `docs/testing/<project>-e2e-report.md`
3. Commit: `"e2e: <project> — <N> tests across <N> flows (<verdict>)"`
4. If FRAGILE: "Flaky tests need remediation. Fix root causes before relying on these tests."
5. If SOLID: "E2E tests are stable. Ready for CI integration and `/godmode:ship`."

## Key Behaviors

1. **Page objects are mandatory.** Never put selectors directly in test files. Page objects make tests readable and locators maintainable.
2. **Test user journeys, not pages.** E2E tests should simulate real user flows (login, add to cart, checkout), not individual page checks.
3. **Stability over speed.** A fast E2E suite that fails randomly is worse than a slow reliable suite. Fix flakiness before adding tests.
4. **Use auto-waiting.** Modern frameworks (Playwright, Cypress) auto-wait for elements. Never use `sleep()` or `waitForTimeout()`.
5. **Test data isolation.** Each test creates its own data and cleans up after itself. Never rely on data from another test.
6. **Fail with context.** Screenshots, videos, and traces on failure are essential for debugging. Configure them in CI.
7. **Selective parallelism.** Run independent test files in parallel, but tests within a file sequentially if they share state.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Assess current E2E state and generate missing tests |
| `--setup` | Set up E2E framework from scratch |
| `--for <feature>` | Generate E2E tests for a specific feature |

## HARD RULES

1. **Never use CSS selectors as test locators.** `div.class > span:nth-child(3)` breaks on any DOM change. Use `data-testid`, `getByRole`, or `getByLabel` exclusively.
2. **Never use fixed `sleep()` or `waitForTimeout()` in tests.** Use auto-waiting assertions (`expect(locator).toBeVisible()`) that resolve as soon as the condition is met.
3. **Never depend on test execution order.** Keep each test fully independent. Create its own data in `beforeEach`, clean up in `afterEach`.
4. **Never put selectors directly in test files.** All locators live in Page Object classes. Tests call page object methods only.
5. **Never skip flaky test investigation.** A flaky test is either fixed or deleted within 48 hours. No `test.skip()` without a linked issue.

## Keep/Discard Discipline
```
After EACH new test spec or flakiness fix:
  1. MEASURE: Run the test 10 times — what is the pass rate?
  2. COMPARE: Is it stable (100% pass rate over 10 runs)?
  3. DECIDE:
     - KEEP if: 100% pass rate over 10 runs AND no timing-dependent waits
     - DISCARD if: pass rate < 100% OR test uses sleep/waitForTimeout
  4. COMMIT kept tests. Delete or rewrite discarded tests before adding more.

Never merge a test with < 100% pass rate — flaky tests erode trust in the entire suite.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All critical user flows have E2E coverage with 100% pass rate
  - Cross-browser matrix passes (chromium, firefox, webkit)
  - User explicitly requests stop
  - Max iterations (10) reached — report remaining uncovered flows

DO NOT STOP just because:
  - Non-critical flows lack coverage (cover critical paths first)
  - A single browser has a known platform bug (annotate and continue)
```

## Loop Protocol

```
test_flow_queue = detect_untested_user_flows()
current_iteration = 0

WHILE test_flow_queue is not empty:
  batch = test_flow_queue.take(3)
  current_iteration += 1

  FOR each flow in batch:
    1. Create Page Object(s) for pages in the flow
    2. Write spec file with happy path + error path + edge cases
    3. Run tests across browser matrix (chromium, firefox, webkit)
    4. IF flaky → diagnose root cause, apply anti-flakiness fix
    5. Record pass rate and timing

  Log: "Iteration {current_iteration}: tested {batch.length} flows, {test_flow_queue.remaining} remaining, pass rate: {rate}%"

  IF test_flow_queue is empty:
    Run full cross-browser suite
    Generate E2E report
    BREAK
```

## Auto-Detection

```
AUTO-DETECT E2E testing context:
  1. Check for existing E2E config: playwright.config.*, cypress.config.*, wdio.conf.*
  2. Scan for existing test files: *.e2e.*, *.spec.* in e2e/ or tests/ directories
  3. Detect frontend framework: Next.js (next.config), React (react-dom), Vue, Angular
  4. Check for page objects: e2e/pages/, e2e/page-objects/ directories
  5. Check for test data: e2e/fixtures/, e2e/factories/ files
  6. Detect app URL from config or package.json dev script
  7. Check CI config for existing E2E jobs
  8. Scan for data-testid attributes in source → existing locator strategy

  USE detected context to:
    - Choose Playwright vs Cypress based on existing config (default: Playwright)
    - Reuse existing page objects and fixtures
    - Generate tests only for uncovered user flows
    - Match existing test naming conventions
```

## Output Format
Print on completion: `E2E: {total_tests} tests across {flow_count} flows, {browser_count} browsers. Pass rate: {pass_rate}%. Flaky: {flaky_count}. Verdict: {verdict}.`

## TSV Logging
Log every test flow result to `.godmode/e2e-results.tsv`:
```
iteration	flow	browser	tests_written	tests_passing	flaky_count	status
1	auth	chromium	5	5	0	passing
1	auth	firefox	5	4	1	flaky
2	checkout	chromium	8	8	0	passing
```
Columns: iteration, flow, browser, tests_written, tests_passing, flaky_count, status(passing/flaky/failing).

## Success Criteria
- All critical user flows have E2E coverage (login, CRUD, checkout, settings).
- All tests pass across the full browser matrix (chromium, firefox, webkit).
- Zero flaky tests (pass rate = 100% over 10 consecutive runs).
- Page Object Model is used for all locators (no selectors in spec files).
- CI pipeline runs E2E suite on every PR.
- Test data is isolated per test (no shared state between tests).

## Error Recovery
- **Tests fail on first run**: Check if the dev server is running. Verify `baseURL` in config matches the actual server. Run `npx playwright install` to ensure browsers are installed.
- **Element not found errors**: Switch from CSS selectors to accessible locators (`getByRole`, `getByLabel`, `data-testid`). Check if the element is inside an iframe or shadow DOM.
- **Timeout errors**: Increase `actionTimeout` in config. Check if the page has slow network requests blocking load. Use `waitForLoadState('networkidle')` only when necessary.
- **Flaky tests detected**: Run the flaky test 10 times in isolation (`--repeat-each=10`). Check for race conditions, missing waits, or shared test data. Fix root cause before proceeding.
- **CI-specific failures**: Compare CI browser versions with local. Check CI runner resources (CPU/memory). Enable trace capture on failure for debugging.
- **Cross-browser inconsistencies**: Check for browser-specific APIs or CSS features. Use feature detection. Add browser-specific test annotations if behavior genuinely differs.

