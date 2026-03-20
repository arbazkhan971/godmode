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

# Check for page objects or test utilities
find . -path "*/page-objects/*" -o -path "*/pages/*" -o -path "*/fixtures/*" | grep -v node_modules
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
│   ├── login.page.ts               # Login page interactions
│   ├── dashboard.page.ts           # Dashboard page interactions
│   └── checkout.page.ts            # Checkout page interactions
├── fixtures/                       # Test data and setup
│   ├── test-data.ts                # Static test data
│   ├── factories.ts                # Dynamic test data generators
│   └── auth.fixture.ts             # Authentication fixture
├── helpers/                        # Shared utilities
│   ├── api.helper.ts               # API calls for test setup/teardown
│   ├── db.helper.ts                # Direct DB operations for setup
│   └── wait.helper.ts              # Custom wait conditions
├── config/
│   ├── environments.ts             # Environment-specific URLs and config
│   └── browsers.ts                 # Browser matrix configuration
└── reports/                        # Test results and screenshots
    ├── screenshots/
    ├── videos/
    └── traces/
```

#### Framework Configuration

**Playwright:**
```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['json', { outputFile: 'e2e/reports/results.json' }],
    ...(process.env.CI ? [['github'] as const] : []),
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    // Desktop browsers
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // Mobile viewports
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 13'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
```

**Cypress:**
```typescript
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    specPattern: 'e2e/tests/**/*.spec.ts',
    supportFile: 'e2e/support/index.ts',
    fixturesFolder: 'e2e/fixtures',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: true,
    screenshotOnRunFailure: true,
    retries: {
      runMode: 2,
      openMode: 0,
    },
    defaultCommandTimeout: 10000,
    requestTimeout: 15000,
    env: {
      apiUrl: 'http://localhost:3000/api',
    },
  },
});
```

### Step 3: Page Object Model
Implement the Page Object pattern for maintainability:

```typescript
// e2e/pages/base.page.ts
import { Page, Locator, expect } from '@playwright/test';

export abstract class BasePage {
  constructor(protected readonly page: Page) {}

  // Common navigation
  async navigate(path: string): Promise<void> {
    await this.page.goto(path);
    await this.waitForPageLoad();
  }

  // Wait for page to be interactive
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  // Common assertions
  async expectVisible(locator: Locator): Promise<void> {
    await expect(locator).toBeVisible({ timeout: 10000 });
  }

  async expectText(locator: Locator, text: string): Promise<void> {
    await expect(locator).toHaveText(text);
  }

  async expectURL(pattern: string | RegExp): Promise<void> {
    await expect(this.page).toHaveURL(pattern);
  }

  // Screenshot for visual comparison
  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({
      path: `e2e/reports/screenshots/${name}.png`,
      fullPage: true,
    });
  }
}
```

```typescript
// e2e/pages/login.page.ts
import { Page, Locator } from '@playwright/test';
import { BasePage } from './base.page';

export class LoginPage extends BasePage {
  // Locators — defined once, used everywhere
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;
  readonly forgotPasswordLink: Locator;
  readonly rememberMeCheckbox: Locator;

  constructor(page: Page) {
    super(page);
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
    this.forgotPasswordLink = page.getByRole('link', { name: 'Forgot password' });
    this.rememberMeCheckbox = page.getByLabel('Remember me');
  }

  // Actions — what a user can DO on this page
  async goto(): Promise<void> {
    await this.navigate('/login');
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async loginWithRememberMe(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.rememberMeCheckbox.check();
    await this.submitButton.click();
  }

  async clickForgotPassword(): Promise<void> {
    await this.forgotPasswordLink.click();
  }

  // Assertions — what we can CHECK on this page
  async expectLoginError(message: string): Promise<void> {
    await this.expectVisible(this.errorMessage);
    await this.expectText(this.errorMessage, message);
  }

  async expectRedirectToDashboard(): Promise<void> {
    await this.expectURL(/\/dashboard/);
  }
}
```

### Step 4: Write E2E Tests
Create tests that simulate real user journeys:

```typescript
// e2e/tests/auth/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../../pages/login.page';
import { DashboardPage } from '../../pages/dashboard.page';
import { testUsers } from '../../fixtures/test-data';

test.describe('Login Flow', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('successful login redirects to dashboard', async ({ page }) => {
    // GIVEN a valid user
    const { email, password } = testUsers.standard;

    // WHEN they log in with correct credentials
    await loginPage.login(email, password);

    // THEN they are redirected to the dashboard
    await loginPage.expectRedirectToDashboard();
    const dashboard = new DashboardPage(page);
    await dashboard.expectWelcomeMessage(testUsers.standard.name);
  });

  test('invalid password shows error message', async () => {
    // GIVEN a valid email but wrong password
    await loginPage.login(testUsers.standard.email, 'wrong-password');

    // THEN an error message is shown
    await loginPage.expectLoginError('Invalid email or password');
  });

  test('empty form shows validation errors', async () => {
    // WHEN submitting an empty form
    await loginPage.submitButton.click();

    // THEN validation errors appear
    await expect(loginPage.emailInput).toHaveAttribute('aria-invalid', 'true');
    await expect(loginPage.passwordInput).toHaveAttribute('aria-invalid', 'true');
  });

  test('login persists across page reload with remember me', async ({ page }) => {
    // GIVEN a user logs in with "remember me" checked
    await loginPage.loginWithRememberMe(
      testUsers.standard.email,
      testUsers.standard.password
    );
    await loginPage.expectRedirectToDashboard();

    // WHEN the page is reloaded
    await page.reload();

    // THEN the user is still logged in
    const dashboard = new DashboardPage(page);
    await dashboard.expectWelcomeMessage(testUsers.standard.name);
  });

  test('locked account after 5 failed attempts', async () => {
    // GIVEN 5 failed login attempts
    for (let i = 0; i < 5; i++) {
      await loginPage.login(testUsers.standard.email, 'wrong-password');
    }

    // WHEN attempting a 6th login
    await loginPage.login(testUsers.standard.email, testUsers.standard.password);

    // THEN the account is locked
    await loginPage.expectLoginError('Account locked. Please try again in 15 minutes.');
  });
});
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
  },
  admin: {
    email: 'test-admin@example.com',
    password: 'Admin1234!',
    name: 'Test Admin',
  },
  readonly: {
    email: 'test-readonly@example.com',
    password: 'Read1234!',
    name: 'Read Only User',
  },
};

// e2e/fixtures/factories.ts
import { faker } from '@faker-js/faker';

export function createTestUser(overrides: Partial<TestUser> = {}): TestUser {
  return {
    email: faker.internet.email(),
    password: faker.internet.password({ length: 12 }),
    name: faker.person.fullName(),
    ...overrides,
  };
}

export function createTestOrder(overrides: Partial<TestOrder> = {}): TestOrder {
  return {
    items: [
      { productId: faker.string.uuid(), quantity: faker.number.int({ min: 1, max: 5 }) },
    ],
    shippingAddress: {
      street: faker.location.streetAddress(),
      city: faker.location.city(),
      state: faker.location.state(),
      zip: faker.location.zipCode(),
    },
    ...overrides,
  };
}
```

```typescript
// e2e/fixtures/auth.fixture.ts — Playwright fixture for authenticated state
import { test as base, Page } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { testUsers } from './test-data';

type AuthFixtures = {
  authenticatedPage: Page;
  adminPage: Page;
};

export const test = base.extend<AuthFixtures>({
  authenticatedPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(testUsers.standard.email, testUsers.standard.password);
    await loginPage.expectRedirectToDashboard();
    await use(page);
  },
  adminPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(testUsers.admin.email, testUsers.admin.password);
    await loginPage.expectRedirectToDashboard();
    await use(page);
  },
});
```

### Step 6: Flakiness Remediation
Diagnose and fix flaky E2E tests:

#### Common Flakiness Causes
```
FLAKINESS DIAGNOSIS:
┌─────────────────────────┬──────────────────────────────────────────────┐
│ Symptom                 │ Root Cause → Fix                             │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Element not found       │ Race condition → Use auto-waiting locators   │
│                         │ (Playwright: getByRole, Cypress: .should)    │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Timeout on navigation   │ Slow page load → Increase timeout, check    │
│                         │ network conditions, use waitForLoadState     │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Stale element reference │ DOM re-render → Re-query element after       │
│                         │ action, avoid storing element references     │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Test order dependency   │ Shared state → Isolate test data, use       │
│                         │ beforeEach for fresh state                   │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Animation interference  │ CSS animation → Disable animations in test  │
│                         │ mode, wait for animation completion          │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Network timing          │ API response race → Mock APIs for unit-like  │
│                         │ E2E, or use waitForResponse                  │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Date/time sensitivity   │ Time-dependent logic → Mock clock in tests   │
│                         │ (Playwright: page.clock, Cypress: cy.clock)  │
├─────────────────────────┼──────────────────────────────────────────────┤
│ Viewport inconsistency  │ Different screen sizes → Set explicit        │
│                         │ viewport in config, test responsive layouts  │
└─────────────────────────┴──────────────────────────────────────────────┘
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
┌────────────────┬──────────┬──────────────┬──────────────────────┐
│ Browser        │ Engine   │ Test Status  │ Known Issues         │
├────────────────┼──────────┼──────────────┼──────────────────────┤
│ Chrome         │ Chromium │ <PASS/FAIL>  │ <issues or none>     │
│ Firefox        │ Gecko    │ <PASS/FAIL>  │ <issues or none>     │
│ Safari         │ WebKit   │ <PASS/FAIL>  │ <issues or none>     │
│ Edge           │ Chromium │ <PASS/FAIL>  │ <issues or none>     │
│ Mobile Chrome  │ Chromium │ <PASS/FAIL>  │ <issues or none>     │
│ Mobile Safari  │ WebKit   │ <PASS/FAIL>  │ <issues or none>     │
└────────────────┴──────────┴──────────────┴──────────────────────┘

CROSS-BROWSER ISSUES FOUND:
1. <issue> — Affects <browser> — Fix: <recommendation>
2. <issue> — Affects <browser> — Fix: <recommendation>
```

### Step 8: Generate E2E Report

```
┌────────────────────────────────────────────────────────────┐
│  E2E TEST REPORT — <project>                               │
├────────────────────────────────────────────────────────────┤
│  Framework: <Playwright | Cypress | Selenium>              │
│  Total tests: <N>                                          │
│  Passing: <N>  Failing: <N>  Skipped: <N>                  │
│  Duration: <X>s (parallel: <N> workers)                    │
│                                                            │
│  COVERAGE BY FEATURE:                                      │
│  Auth flows: <N> tests — <PASS/FAIL>                       │
│  Checkout: <N> tests — <PASS/FAIL>                         │
│  Dashboard: <N> tests — <PASS/FAIL>                        │
│  Settings: <N> tests — <PASS/FAIL>                         │
│                                                            │
│  CROSS-BROWSER:                                            │
│  Chromium: <N>/<total> passing                             │
│  Firefox: <N>/<total> passing                              │
│  WebKit: <N>/<total> passing                               │
│                                                            │
│  FLAKINESS:                                                │
│  Flaky tests: <N>                                          │
│  Retry rate: <X>% (tests that needed retries to pass)      │
│                                                            │
│  ARCHITECTURE:                                             │
│  Page objects: <N>                                          │
│  Test data strategy: <fixtures | factories | API seeding>  │
│  CI integration: <yes | no>                                │
│                                                            │
│  Verdict: <SOLID | NEEDS WORK | FRAGILE>                   │
└────────────────────────────────────────────────────────────┘
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
3. **Stability over speed.** A fast E2E suite that fails randomly is worse than a slow suite that's reliable. Fix flakiness before adding more tests.
4. **Use auto-waiting.** Modern frameworks (Playwright, Cypress) auto-wait for elements. Never use `sleep()` or `waitForTimeout()`.
5. **Test data isolation.** Each test creates its own data and cleans up after itself. Never rely on data from another test.
6. **Fail with context.** Screenshots, videos, and traces on failure are essential for debugging. Configure them in CI.
7. **Selective parallelism.** Run independent test files in parallel, but tests within a file sequentially if they share state.

## Example Usage

### Setting up E2E from scratch
```
User: /godmode:e2e Set up Playwright E2E tests for our Next.js app

E2E: Scanning your project...

Found: Next.js app with 12 pages, API routes, auth system
Framework: Installing Playwright...

Creating test architecture:
  e2e/pages/login.page.ts
  e2e/pages/dashboard.page.ts
  e2e/pages/settings.page.ts
  e2e/tests/auth/login.spec.ts (5 tests)
  e2e/tests/auth/registration.spec.ts (4 tests)
  e2e/tests/dashboard/navigation.spec.ts (3 tests)
  e2e/fixtures/test-data.ts
  e2e/fixtures/auth.fixture.ts
  playwright.config.ts

Running initial test suite...
12 tests, 3 browsers = 36 test runs
All passing in 45s

E2E foundation ready. Add more tests with /godmode:e2e --for <feature>
```

### Fixing flaky tests
```
User: /godmode:e2e --fix-flaky Our checkout tests keep failing in CI

E2E: Analyzing flaky test history...

Found 3 flaky tests in checkout.spec.ts:
1. "completes purchase with credit card" — 73% pass rate
   Root cause: Payment API response race condition
   Fix: Add waitForResponse('/api/payment') before assertion

2. "applies discount code" — 85% pass rate
   Root cause: Animation on discount badge interferes with click
   Fix: Disable animations in test mode, wait for animationend

3. "shows out-of-stock message" — 90% pass rate
   Root cause: Test data not isolated — previous test depletes stock
   Fix: Seed fresh inventory in beforeEach

Applying fixes... All 3 tests now pass consistently (10/10 runs).
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Assess current E2E state and generate missing tests |
| `--setup` | Set up E2E framework from scratch |
| `--for <feature>` | Generate E2E tests for a specific feature |
| `--fix-flaky` | Diagnose and fix flaky tests |
| `--cross-browser` | Run and report cross-browser test results |
| `--visual` | Set up visual regression testing |
| `--accessibility` | Add accessibility checks to E2E tests |
| `--ci` | Configure E2E tests for CI pipeline |
| `--coverage` | Identify user flows without E2E coverage |

## HARD RULES

1. **Never use CSS selectors as test locators.** `div.class > span:nth-child(3)` breaks on any DOM change. Use `data-testid`, `getByRole`, or `getByLabel` exclusively.
2. **Never use fixed `sleep()` or `waitForTimeout()` in tests.** Use auto-waiting assertions (`expect(locator).toBeVisible()`) that resolve as soon as the condition is met.
3. **Never depend on test execution order.** Each test must be fully independent. Create its own data in `beforeEach`, clean up in `afterEach`.
4. **Never put selectors directly in test files.** All locators live in Page Object classes. Tests call page object methods only.
5. **Never skip flaky test investigation.** A flaky test is either fixed or deleted within 48 hours. No `test.skip()` without a linked issue.

## Loop Protocol

```
test_flow_queue = detect_untested_user_flows()  // e.g., [login, checkout, settings, search]
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

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):

Agent 1 — "page-objects":
  EnterWorktree("page-objects")
  Create BasePage class with common methods
  Create Page Object for each page in the application
  Define all locators using accessible selectors (role, label, testid)
  ExitWorktree()

Agent 2 — "test-specs":
  EnterWorktree("test-specs")
  Write E2E specs for each user flow (auth, CRUD, checkout, etc.)
  Create test fixtures and data factories
  Set up authentication fixtures for pre-logged-in state
  ExitWorktree()

Agent 3 — "infra-and-flakiness":
  EnterWorktree("infra-and-flakiness")
  Configure playwright.config.ts (browsers, retries, reporters)
  Set up CI pipeline for E2E (GitHub Actions / GitLab CI)
  Add trace/screenshot/video capture on failure
  Run flakiness scan: execute suite 10x, identify unstable tests
  ExitWorktree()

MERGE: Combine all branches, run full suite, generate E2E report.
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

## Anti-Patterns

- **Do NOT use CSS selectors as locators.** `div.class > span:nth-child(3)` breaks on any DOM change. Use `data-testid`, `getByRole`, or `getByLabel`.
- **Do NOT test implementation details.** E2E tests verify user behavior, not internal state. Don't assert on Redux store or component props.
- **Do NOT write E2E tests for everything.** E2E tests are slow and expensive. Use them for critical user journeys. Use unit/integration tests for logic.
- **Do NOT skip test data cleanup.** Leftover test data causes cascading failures. Always clean up in afterEach or use isolated test databases.
- **Do NOT ignore flaky tests.** A flaky test erodes trust in the entire suite. Fix or delete flaky tests immediately.
- **Do NOT use hard-coded waits.** `sleep(5000)` is never the answer. Use assertion-based waits that resolve as soon as the condition is met.
- **Do NOT run E2E tests only locally.** E2E tests must run in CI against a real browser. Local-only E2E tests provide false confidence.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run E2E tasks sequentially: page objects, then test specs, then infra/flakiness setup.
- Use branch isolation per task: `git checkout -b godmode-e2e-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
