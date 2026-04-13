---
name: e2e
description: |
  End-to-end testing skill. Activates for browser-based
  E2E tests, cross-browser testing, flaky test fixes,
  or page object models. Supports Playwright, Cypress,
  Selenium. Triggers on: /godmode:e2e, "E2E test",
  "browser test", "Playwright test", "Cypress test".
---

# E2E — End-to-End Testing

## Activate When
- User invokes `/godmode:e2e`
- User says "E2E test", "browser test", "integration test"
- User asks about Playwright, Cypress, or Selenium
- User needs to fix flaky E2E tests
- Ship skill needs user-flow validation

## Workflow

### Step 1: Assess E2E Test State

```bash
# Find existing E2E tests
find . -name "*.e2e.*" -o -name "*.spec.*" \
  | grep -i -E "e2e|playwright|cypress" \
  | grep -v node_modules

# Check for test framework config
ls playwright.config.* cypress.config.* wdio.conf.* \
  2>/dev/null

# Count existing test files
find e2e/ tests/ -name "*.spec.ts" 2>/dev/null | wc -l
```

```
E2E TEST STATE:
Framework: <Playwright | Cypress | Selenium | none>
Config file: <path or none>
Test count: <N>
Page objects: <N> (or none)
Flaky tests: <N known flaky | unknown>

IF test count == 0: scaffold from scratch
IF test count > 0 AND flaky > 3: prioritize remediation
IF framework == none: default to Playwright
```

### Step 2: Design Test Architecture

```
e2e/
├── tests/               # By feature
│   ├── auth/
│   │   ├── login.spec.ts
│   │   └── registration.spec.ts
│   ├── checkout/
│   │   ├── cart.spec.ts
│   │   └── payment.spec.ts
│   └── dashboard/
│       └── navigation.spec.ts
├── pages/               # Page Object Models
│   ├── base.page.ts
│   ├── login.page.ts
│   └── dashboard.page.ts
└── fixtures/
    └── test-data.ts
```

### Step 3: Page Object Model

All locators live in page objects. Tests call methods only.

### Step 4: Write E2E Tests

Simulate real user journeys (login, add to cart, checkout),
not individual page checks.

### Step 5: Flakiness Remediation

```
FLAKINESS DIAGNOSIS:
| Symptom              | Fix                          |
|----------------------|------------------------------|
| Element not found    | Use auto-waiting locators    |
| Timeout on nav       | waitForLoadState, bump limit |
| Stale element ref    | Re-query after action        |
| Test order deps      | Isolate data in beforeEach   |

ANTI-FLAKINESS RULES:
- Never use fixed sleep — use auto-waiting assertions
- Never depend on execution order — independent tests
- Never use CSS selectors — use data-testid, roles
- Always seed test data via API, not through the UI
- Always retry failed tests in CI (investigate repeats)
- Always record traces/screenshots on failure

THRESHOLDS:
  Pass rate target: 100% over 10 consecutive runs
  Max flaky tolerance: 0 (zero flaky tests in suite)
  Retry budget in CI: 2 retries per test max
```

### Step 6: Cross-Browser Testing

```
BROWSER MATRIX:
| Browser       | Engine   | Status     |
|---------------|----------|------------|
| Chrome        | Chromium | <PASS/FAIL>|
| Firefox       | Gecko    | <PASS/FAIL>|
| Safari        | WebKit   | <PASS/FAIL>|
| Mobile Chrome | Chromium | <PASS/FAIL>|
| Mobile Safari | WebKit   | <PASS/FAIL>|
```

### Step 7: Generate E2E Report

```
E2E REPORT — <project>
Framework: <Playwright | Cypress>
Total: <N> tests, Passing: <N>, Failing: <N>
Duration: <X>s (parallel: <N> workers)
Cross-browser: chromium PASS, firefox PASS, webkit PASS
```

Commit: `"e2e: <project> — <N> tests across <N> flows"`


```bash
# Run end-to-end tests
npx playwright test --reporter=list
npx cypress run --browser chrome
```

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Page objects mandatory.** No selectors in test files.
2. **Test user journeys, not pages.**
3. **Stability over speed.** Fix flakiness before adding tests.
4. **Use auto-waiting.** Never use `sleep()`.
5. **Test data isolation.** Each test owns its data.
6. **Fail with context.** Screenshots + traces on failure.

## HARD RULES

1. Never use CSS selectors as test locators.
2. Never use fixed `sleep()` or `waitForTimeout()`.
3. Never depend on test execution order.
4. Never put selectors directly in test files.
5. Never skip flaky test investigation — fix or delete
   within 48 hours.

## Keep/Discard Discipline
```
After EACH test spec or flakiness fix:
  1. MEASURE: Run 10 times — pass rate?
  2. DECIDE:
     KEEP if: 100% pass rate AND no timing waits
     DISCARD if: <100% OR uses sleep/waitForTimeout
  3. COMMIT kept. Delete discarded before adding more.
```

## Loop Protocol
```
test_flow_queue = detect_untested_user_flows()
WHILE test_flow_queue is not empty:
  batch = test_flow_queue.take(3)
  FOR each flow in batch:
    1. Create Page Objects for the flow
    2. Write spec: happy + error + edge cases
    3. Run across browser matrix
    4. IF flaky: diagnose, apply fix
    5. IF pass rate < 100%: discard and rewrite
  IF queue empty: run full suite, generate report
```

## Auto-Detection
```
1. Check for: playwright.config.*, cypress.config.*
2. Scan for: *.e2e.*, *.spec.* in e2e/ or tests/
3. Detect frontend: Next.js, React, Vue, Angular
4. Check for page objects: e2e/pages/
5. Detect app URL from config or package.json
```

## Output Format
Print: `E2E: {tests} tests, {flows} flows,
  {browsers} browsers. Pass: {rate}%.
  Flaky: {count}. Verdict: {verdict}.`

## TSV Logging
Log to `.godmode/e2e-results.tsv`:
```
iteration	flow	browser	tests_passing	flaky	status
```

## Stop Conditions
```
STOP when ANY of:
  - All critical flows covered at 100% pass rate
  - Cross-browser matrix passes (chromium, firefox, webkit)
  - User requests stop
  - Max 10 iterations reached
```

<!-- tier-3 -->

## Error Recovery
- Tests fail on first run: check dev server, baseURL,
  run `npx playwright install`.
- Element not found: switch to accessible locators.
- Timeout: increase actionTimeout, check network.
- Flaky: run `--repeat-each=10`, fix root cause.
- CI failures: compare browser versions, enable traces.

