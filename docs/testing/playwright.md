# Playwright Mastery Guide

Comprehensive reference for end-to-end testing, component testing, and browser automation with Playwright.

---

## Table of Contents

1. [Configuration & Setup](#configuration--setup)
2. [Page Objects](#page-objects)
3. [Fixtures](#fixtures)
4. [Test Generation](#test-generation)
5. [Network Interception](#network-interception)
6. [Authentication State](#authentication-state)
7. [Visual Comparison](#visual-comparison)
8. [Accessibility Testing](#accessibility-testing)
9. [CI/CD Integration](#cicd-integration)
10. [Sharding & Parallelism](#sharding--parallelism)

---

## Configuration & Setup

### Basic Configuration

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // Test directory and patterns
  testDir: './e2e',
  testMatch: '**/*.spec.ts',
  testIgnore: '**/helpers/**',

  // Execution
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  timeout: 30_000,
  expect: { timeout: 5_000 },

  // Reporting
  reporter: [
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test-results.json' }],
    ['junit', { outputFile: 'junit.xml' }],
    process.env.CI ? ['github'] : ['list'],
  ],

  // Shared settings for all projects
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10_000,
    navigationTimeout: 15_000,
  },

  // Browser projects
  projects: [
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
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 13'] },
    },
  ],

  // Dev server
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
```

### Project Dependencies (Setup/Teardown)

```ts
export default defineConfig({
  projects: [
    {
      name: 'setup',
      testMatch: /global\.setup\.ts/,
    },
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'playwright/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'cleanup',
      testMatch: /global\.teardown\.ts/,
    },
  ],
});
```

---

## Page Objects

### Page Object Model Pattern

```ts
// e2e/pages/login.page.ts
import { type Locator, type Page, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;
  readonly forgotPasswordLink: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
    this.forgotPasswordLink = page.getByRole('link', { name: 'Forgot password?' });
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }

  async expectLoggedIn() {
    await expect(this.page).toHaveURL('/dashboard');
  }
}
```

```ts
// e2e/pages/dashboard.page.ts
import { type Locator, type Page, expect } from '@playwright/test';

export class DashboardPage {
  readonly page: Page;
  readonly heading: Locator;
  readonly userMenu: Locator;
  readonly sidebar: Locator;

  constructor(page: Page) {
    this.page = page;
    this.heading = page.getByRole('heading', { level: 1 });
    this.userMenu = page.getByTestId('user-menu');
    this.sidebar = page.getByRole('navigation', { name: 'Sidebar' });
  }

  async goto() {
    await this.page.goto('/dashboard');
  }

  async expectLoaded() {
    await expect(this.heading).toBeVisible();
    await expect(this.heading).toContainText('Dashboard');
  }

  async openUserMenu() {
    await this.userMenu.click();
  }

  async navigateTo(section: string) {
    await this.sidebar.getByRole('link', { name: section }).click();
  }

  async logout() {
    await this.openUserMenu();
    await this.page.getByRole('menuitem', { name: 'Sign out' }).click();
  }
}
```

### Using Page Objects in Tests

```ts
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { DashboardPage } from './pages/dashboard.page';

test.describe('Authentication', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('successful login redirects to dashboard', async ({ page }) => {
    await loginPage.login('user@example.com', 'password123');
    const dashboard = new DashboardPage(page);
    await dashboard.expectLoaded();
  });

  test('invalid credentials show error', async () => {
    await loginPage.login('user@example.com', 'wrong');
    await loginPage.expectError('Invalid email or password');
  });

  test('empty form shows validation errors', async () => {
    await loginPage.submitButton.click();
    await expect(loginPage.emailInput).toHaveAttribute('aria-invalid', 'true');
  });
});
```

---

## Fixtures

### Custom Fixtures

```ts
// e2e/fixtures.ts
import { test as base, expect } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { DashboardPage } from './pages/dashboard.page';

// Declare fixture types
type MyFixtures = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  authenticatedPage: DashboardPage;
  testUser: { email: string; password: string };
};

export const test = base.extend<MyFixtures>({
  // Simple page object fixture
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  dashboardPage: async ({ page }, use) => {
    const dashboardPage = new DashboardPage(page);
    await use(dashboardPage);
  },

  // Fixture with setup and teardown
  testUser: async ({}, use) => {
    // Setup: create test user via API
    const user = { email: `test-${Date.now()}@example.com`, password: 'Test123!' };
    const response = await fetch('http://localhost:3000/api/test/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });
    const created = await response.json();

    await use(user);

    // Teardown: delete test user
    await fetch(`http://localhost:3000/api/test/users/${created.id}`, {
      method: 'DELETE',
    });
  },

  // Fixture that depends on other fixtures
  authenticatedPage: async ({ page, testUser }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(testUser.email, testUser.password);
    const dashboard = new DashboardPage(page);
    await dashboard.expectLoaded();
    await use(dashboard);
  },
});

export { expect } from '@playwright/test';
```

### Worker-Scoped Fixtures

```ts
// Shared across all tests in a worker
type WorkerFixtures = {
  apiClient: APIClient;
  dbConnection: DatabaseConnection;
};

export const test = base.extend<{}, WorkerFixtures>({
  // Worker-scoped (second type parameter, option: { scope: 'worker' })
  apiClient: [async ({}, use) => {
    const client = new APIClient('http://localhost:3000/api');
    await client.authenticate('admin', 'admin-pass');
    await use(client);
    await client.dispose();
  }, { scope: 'worker' }],

  dbConnection: [async ({}, use) => {
    const db = await DatabaseConnection.create();
    await use(db);
    await db.close();
  }, { scope: 'worker' }],
});
```

### Parametrized Fixtures

```ts
type ThemeFixture = {
  theme: 'light' | 'dark';
};

export const test = base.extend<ThemeFixture>({
  theme: ['light', { option: true }],  // Default value, marked as option
});

// Override in config
export default defineConfig({
  projects: [
    {
      name: 'light-theme',
      use: { theme: 'light' },
    },
    {
      name: 'dark-theme',
      use: { theme: 'dark' },
    },
  ],
});
```

---

## Test Generation

### Using Codegen

```bash
# Open browser with recording
npx playwright codegen http://localhost:3000

# Record into a file
npx playwright codegen --output e2e/generated.spec.ts http://localhost:3000

# Emulate device
npx playwright codegen --device="iPhone 13" http://localhost:3000

# Emulate viewport
npx playwright codegen --viewport-size=800,600 http://localhost:3000

# Emulate color scheme
npx playwright codegen --color-scheme=dark http://localhost:3000

# With authentication state
npx playwright codegen --load-storage=auth.json http://localhost:3000
```

### Trace Viewer

```bash
# View trace file
npx playwright show-trace trace.zip

# View trace from test results
npx playwright show-trace test-results/test-name/trace.zip
```

### UI Mode

```bash
# Interactive test runner with time-travel debugging
npx playwright test --ui

# Filter tests in UI mode
npx playwright test --ui --grep "login"
```

---

## Network Interception

### Route Interception

```ts
test('mock API response', async ({ page }) => {
  // Mock a specific endpoint
  await page.route('**/api/users', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' },
      ]),
    });
  });

  await page.goto('/users');
  await expect(page.getByText('Alice')).toBeVisible();
  await expect(page.getByText('Bob')).toBeVisible();
});

// Mock with HAR file
test('use HAR recording', async ({ page }) => {
  await page.routeFromHAR('e2e/fixtures/api.har', {
    url: '**/api/**',
    update: false,        // Set true to re-record
  });
  await page.goto('/dashboard');
});
```

### Modify Requests and Responses

```ts
test('modify request headers', async ({ page }) => {
  await page.route('**/api/**', async (route) => {
    await route.continue({
      headers: {
        ...route.request().headers(),
        'X-Custom-Header': 'test-value',
      },
    });
  });
});

test('modify response body', async ({ page }) => {
  await page.route('**/api/config', async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.featureFlags.newUI = true;
    await route.fulfill({ response, json });
  });
});
```

### Wait for Network Events

```ts
test('wait for API call', async ({ page }) => {
  // Wait for specific request
  const responsePromise = page.waitForResponse('**/api/users');
  await page.getByRole('button', { name: 'Load users' }).click();
  const response = await responsePromise;
  expect(response.status()).toBe(200);

  // Wait for request
  const requestPromise = page.waitForRequest((req) =>
    req.url().includes('/api/save') && req.method() === 'POST'
  );
  await page.getByRole('button', { name: 'Save' }).click();
  const request = await requestPromise;
  expect(JSON.parse(request.postData()!)).toMatchObject({ name: 'Test' });
});

// Abort requests (e.g., block analytics)
test('block third-party scripts', async ({ page }) => {
  await page.route('**/*', (route) => {
    const url = route.request().url();
    if (url.includes('analytics') || url.includes('tracking')) {
      return route.abort();
    }
    return route.continue();
  });
});
```

### WebSocket Interception

```ts
test('intercept WebSocket', async ({ page }) => {
  const ws = page.waitForEvent('websocket');
  await page.goto('/chat');
  const webSocket = await ws;

  expect(webSocket.url()).toContain('/ws/chat');

  // Listen to messages
  const messages: string[] = [];
  webSocket.on('framereceived', (event) => {
    messages.push(event.payload as string);
  });

  webSocket.on('framesent', (event) => {
    console.log('Sent:', event.payload);
  });
});
```

---

## Authentication State

### Global Setup for Auth

```ts
// e2e/global.setup.ts
import { chromium, type FullConfig } from '@playwright/test';

async function globalSetup(config: FullConfig) {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto('http://localhost:3000/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('admin-password');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');

  // Save authentication state
  await page.context().storageState({ path: 'playwright/.auth/admin.json' });

  await browser.close();
}

export default globalSetup;
```

### Auth as Project Dependency (Recommended)

```ts
// e2e/auth.setup.ts
import { test as setup, expect } from '@playwright/test';

const authFile = 'playwright/.auth/user.json';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();

  await page.waitForURL('/dashboard');
  await expect(page.getByText('Welcome')).toBeVisible();

  await page.context().storageState({ path: authFile });
});
```

```ts
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'playwright/.auth/user.json',
      },
      dependencies: ['setup'],
    },
  ],
});
```

### Multiple Auth Roles

```ts
// e2e/auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate as admin', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('admin-pass');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/admin');
  await page.context().storageState({ path: 'playwright/.auth/admin.json' });
});

setup('authenticate as user', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('user-pass');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: 'playwright/.auth/user.json' });
});
```

```ts
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'admin-tests',
      testMatch: /.*\.admin\.spec\.ts/,
      use: { storageState: 'playwright/.auth/admin.json' },
      dependencies: ['setup'],
    },
    {
      name: 'user-tests',
      testMatch: /.*\.user\.spec\.ts/,
      use: { storageState: 'playwright/.auth/user.json' },
      dependencies: ['setup'],
    },
  ],
});
```

### API-Based Auth (Faster)

```ts
setup('authenticate via API', async ({ request }) => {
  const response = await request.post('/api/auth/login', {
    data: {
      email: 'user@example.com',
      password: 'password123',
    },
  });

  expect(response.ok()).toBeTruthy();

  // Save the storage state (cookies set by API response)
  await request.storageState({ path: 'playwright/.auth/user.json' });
});
```

---

## Visual Comparison

### Screenshot Assertions

```ts
test('homepage visual test', async ({ page }) => {
  await page.goto('/');

  // Full page screenshot
  await expect(page).toHaveScreenshot('homepage.png', {
    fullPage: true,
    maxDiffPixelRatio: 0.01,
  });
});

test('component visual test', async ({ page }) => {
  await page.goto('/components');

  // Element screenshot
  const card = page.getByTestId('user-card');
  await expect(card).toHaveScreenshot('user-card.png', {
    maxDiffPixels: 100,
  });
});

test('screenshot with mask', async ({ page }) => {
  await page.goto('/dashboard');

  await expect(page).toHaveScreenshot('dashboard.png', {
    mask: [
      page.getByTestId('dynamic-timestamp'),
      page.getByTestId('random-avatar'),
    ],
    maskColor: '#FF00FF',
  });
});
```

### Visual Comparison Configuration

```ts
// playwright.config.ts
export default defineConfig({
  expect: {
    toHaveScreenshot: {
      maxDiffPixelRatio: 0.005,
      threshold: 0.2,                   // Per-pixel threshold (0-1)
      animations: 'disabled',           // Disable CSS animations
    },
    toMatchSnapshot: {
      maxDiffPixelRatio: 0.01,
    },
  },

  // Update snapshots
  updateSnapshots: 'missing',           // 'all' | 'missing' | 'none'
});
```

```bash
# Update visual snapshots
npx playwright test --update-snapshots
```

### Handling Dynamic Content

```ts
test('visual test with stable content', async ({ page }) => {
  await page.goto('/');

  // Wait for fonts to load
  await page.evaluate(() => document.fonts.ready);

  // Wait for images to load
  await page.waitForFunction(() => {
    const images = document.querySelectorAll('img');
    return Array.from(images).every((img) => img.complete);
  });

  // Freeze animations
  await page.evaluate(() => {
    document.querySelectorAll('*').forEach((el) => {
      const style = el as HTMLElement;
      style.style.animation = 'none';
      style.style.transition = 'none';
    });
  });

  await expect(page).toHaveScreenshot();
});
```

---

## Accessibility Testing

### Built-in Accessibility Checks

```ts
import { test, expect } from '@playwright/test';

test('page has no accessibility violations', async ({ page }) => {
  await page.goto('/');

  // Snapshot accessibility tree
  const accessibilityTree = await page.accessibility.snapshot();
  expect(accessibilityTree).toBeTruthy();
});

// Check ARIA attributes
test('form has proper ARIA labels', async ({ page }) => {
  await page.goto('/login');

  const emailInput = page.getByLabel('Email address');
  await expect(emailInput).toHaveAttribute('aria-required', 'true');
  await expect(emailInput).toHaveRole('textbox');

  const submitBtn = page.getByRole('button', { name: 'Sign in' });
  await expect(submitBtn).toBeEnabled();
});
```

### Using @axe-core/playwright

```ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('homepage passes axe accessibility scan', async ({ page }) => {
  await page.goto('/');

  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
    .exclude('#third-party-widget')
    .analyze();

  expect(results.violations).toEqual([]);
});

test('form accessibility', async ({ page }) => {
  await page.goto('/contact');

  const results = await new AxeBuilder({ page })
    .include('#contact-form')
    .withRules(['label', 'color-contrast', 'aria-required-attr'])
    .analyze();

  // Report violations with details
  if (results.violations.length > 0) {
    const violations = results.violations.map((v) => ({
      rule: v.id,
      impact: v.impact,
      description: v.description,
      nodes: v.nodes.length,
    }));
    console.table(violations);
  }

  expect(results.violations).toEqual([]);
});
```

### Keyboard Navigation Testing

```ts
test('tab order is correct', async ({ page }) => {
  await page.goto('/login');

  // Tab through form elements
  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Email')).toBeFocused();

  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Password')).toBeFocused();

  await page.keyboard.press('Tab');
  await expect(page.getByRole('button', { name: 'Sign in' })).toBeFocused();
});

test('modal trap focus', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Open dialog' }).click();

  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();

  // Tab should cycle within dialog
  await page.keyboard.press('Tab');
  const focusedElement = page.locator(':focus');
  const isInDialog = await dialog.evaluate(
    (dlg, focused) => dlg.contains(focused),
    await focusedElement.elementHandle()
  );
  expect(isInDialog).toBe(true);

  // Escape closes dialog
  await page.keyboard.press('Escape');
  await expect(dialog).not.toBeVisible();
});
```

### Screen Reader Testing Helpers

```ts
test('live region announces changes', async ({ page }) => {
  await page.goto('/notifications');

  // Check that status region exists
  const statusRegion = page.getByRole('status');
  await expect(statusRegion).toHaveAttribute('aria-live', 'polite');

  // Trigger a notification
  await page.getByRole('button', { name: 'Save' }).click();

  // Verify the announcement
  await expect(statusRegion).toContainText('Changes saved successfully');
});
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/playwright.yml
name: Playwright Tests
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    timeout-minutes: 30
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        shard: [1/4, 2/4, 3/4, 4/4]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npx playwright test --shard=${{ matrix.shard }}

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: playwright-report-${{ strategy.job-index }}
          path: playwright-report/
          retention-days: 14

      - name: Upload blob report (for merging)
        uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: blob-report-${{ strategy.job-index }}
          path: blob-report/

  merge-reports:
    if: ${{ !cancelled() }}
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - run: npm ci

      - name: Download blob reports
        uses: actions/download-artifact@v4
        with:
          pattern: blob-report-*
          path: all-blob-reports
          merge-multiple: true

      - name: Merge reports
        run: npx playwright merge-reports --reporter html ./all-blob-reports

      - name: Upload merged report
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
```

### Docker

```dockerfile
# Dockerfile for Playwright CI
FROM mcr.microsoft.com/playwright:v1.48.0-noble

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

CMD ["npx", "playwright", "test"]
```

```yaml
# docker-compose.yml
services:
  playwright:
    build: .
    volumes:
      - ./test-results:/app/test-results
      - ./playwright-report:/app/playwright-report
    environment:
      - CI=true
    depends_on:
      - app
  app:
    build: ./app
    ports:
      - "3000:3000"
```

### GitLab CI

```yaml
# .gitlab-ci.yml
playwright:
  image: mcr.microsoft.com/playwright:v1.48.0-noble
  stage: test
  parallel: 4
  script:
    - npm ci
    - npx playwright test --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
  artifacts:
    when: always
    paths:
      - playwright-report/
      - test-results/
    expire_in: 7 days
```

---

## Sharding & Parallelism

### Test Sharding

```bash
# Split across N machines
npx playwright test --shard=1/4
npx playwright test --shard=2/4
npx playwright test --shard=3/4
npx playwright test --shard=4/4
```

### Merge Sharded Reports

```bash
# Each shard produces a blob report
npx playwright test --shard=1/4 --reporter=blob

# Merge all blob reports into a single HTML report
npx playwright merge-reports --reporter=html ./blob-reports/
```

### Parallelism Configuration

```ts
// playwright.config.ts
export default defineConfig({
  // Run test files in parallel
  fullyParallel: true,

  // Number of parallel workers
  workers: process.env.CI ? 2 : '50%',

  // Limit failures before stopping
  maxFailures: process.env.CI ? 10 : 0,
});

// Per-file parallelism control
test.describe.configure({ mode: 'serial' });    // Run tests in order
test.describe.configure({ mode: 'parallel' });  // Run tests in parallel (default)
```

### Test Isolation

```ts
// Each test gets a fresh browser context by default
// To share context between tests in a describe block:
test.describe('shared context tests', () => {
  let page: Page;

  test.beforeAll(async ({ browser }) => {
    const context = await browser.newContext();
    page = await context.newPage();
    await page.goto('/');
  });

  test.afterAll(async () => {
    await page.close();
  });

  test('first test', async () => {
    // Uses shared page
  });

  test('second test', async () => {
    // Uses same shared page
  });
});
```

---

## Advanced Patterns

### Retry Logic with Annotations

```ts
// Retry flaky tests
test('sometimes flaky network test', {
  tag: '@flaky',
  annotation: { type: 'issue', description: 'https://github.com/org/repo/issues/123' },
}, async ({ page }) => {
  // Test implementation
});

// Skip tests conditionally
test('windows-only feature', async ({ page, browserName }) => {
  test.skip(browserName === 'firefox', 'Firefox not supported yet');
  // Test implementation
});

// Slow test (triple the timeout)
test('large data import', async ({ page }) => {
  test.slow();
  // Test implementation
});
```

### API Testing (Without Browser)

```ts
import { test, expect } from '@playwright/test';

test('API: create user', async ({ request }) => {
  const response = await request.post('/api/users', {
    data: {
      name: 'John Doe',
      email: 'john@example.com',
    },
  });

  expect(response.ok()).toBeTruthy();
  const user = await response.json();
  expect(user).toMatchObject({
    name: 'John Doe',
    email: 'john@example.com',
    id: expect.any(Number),
  });
});

test('API: list users', async ({ request }) => {
  const response = await request.get('/api/users');
  expect(response.ok()).toBeTruthy();
  const users = await response.json();
  expect(users.length).toBeGreaterThan(0);
});
```

### Multi-Tab and Multi-Window

```ts
test('open link in new tab', async ({ page, context }) => {
  await page.goto('/');

  // Listen for new page (tab) event
  const [newPage] = await Promise.all([
    context.waitForEvent('page'),
    page.getByRole('link', { name: 'Open in new tab' }).click(),
  ]);

  await newPage.waitForLoadState();
  await expect(newPage).toHaveURL(/\/details/);
  await expect(newPage.getByRole('heading')).toContainText('Details');
});

test('popup window', async ({ page }) => {
  const [popup] = await Promise.all([
    page.waitForEvent('popup'),
    page.getByRole('button', { name: 'Open popup' }).click(),
  ]);

  await popup.waitForLoadState();
  expect(popup.url()).toContain('/popup');
});
```

### File Downloads and Uploads

```ts
test('download file', async ({ page }) => {
  const [download] = await Promise.all([
    page.waitForEvent('download'),
    page.getByRole('link', { name: 'Download report' }).click(),
  ]);

  expect(download.suggestedFilename()).toBe('report.pdf');
  await download.saveAs('/tmp/report.pdf');
});

test('upload file', async ({ page }) => {
  await page.goto('/upload');

  const fileChooserPromise = page.waitForEvent('filechooser');
  await page.getByText('Choose file').click();
  const fileChooser = await fileChooserPromise;
  await fileChooser.setFiles('e2e/fixtures/test-image.png');

  await expect(page.getByText('test-image.png')).toBeVisible();
});

// Direct input file set
test('upload via input', async ({ page }) => {
  await page.goto('/upload');
  await page.getByLabel('Upload file').setInputFiles('path/to/file.pdf');
});
```
