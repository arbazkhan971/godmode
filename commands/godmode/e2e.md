# /godmode:e2e

End-to-end browser testing. Sets up Playwright, Cypress, or Selenium test architecture with page object models, cross-browser testing, test data management, and flakiness remediation.

## Usage

```
/godmode:e2e                            # Assess current E2E state and generate missing tests
/godmode:e2e --setup                    # Set up E2E framework from scratch
/godmode:e2e --for <feature>            # Generate E2E tests for a specific feature
/godmode:e2e --fix-flaky                # Diagnose and fix flaky tests
/godmode:e2e --cross-browser            # Run and report cross-browser test results
/godmode:e2e --visual                   # Set up visual regression testing
/godmode:e2e --accessibility            # Add accessibility checks to E2E tests
/godmode:e2e --ci                       # Configure E2E tests for CI pipeline
/godmode:e2e --coverage                 # Identify user flows without E2E coverage
```

## What It Does

1. Assesses current E2E test state (framework, coverage, flakiness)
2. Designs test architecture with page object models and test data strategy
3. Generates framework configuration (Playwright, Cypress, or Selenium)
4. Writes E2E tests for user journeys (login, checkout, dashboard, etc.)
5. Diagnoses and fixes flaky tests with root cause analysis
6. Runs cross-browser testing and reports browser-specific issues

## Output
- Test files in `e2e/` directory (tests, pages, fixtures, helpers)
- Framework config (playwright.config.ts or cypress.config.ts)
- E2E report at `docs/testing/<project>-e2e-report.md`
- Commit: `"e2e: <project> — <N> tests across <N> flows (<verdict>)"`
- Verdict: SOLID / NEEDS WORK / FRAGILE

## Next Step
If FRAGILE: Fix flaky tests before relying on the suite.
If SOLID: Integrate into CI with `/godmode:ship`.

## Examples

```
/godmode:e2e                            # Assess and improve E2E coverage
/godmode:e2e --setup                    # Set up Playwright from scratch
/godmode:e2e --for checkout             # Generate tests for checkout flow
/godmode:e2e --fix-flaky                # Fix flaky tests in CI
/godmode:e2e --cross-browser            # Test across Chrome, Firefox, Safari
```
