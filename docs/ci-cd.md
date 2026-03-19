# CI/CD Integration Guide

Godmode produces artifacts that integrate naturally with CI/CD pipelines. This guide shows how to use Godmode's outputs in GitHub Actions, GitLab CI, and other CI systems.

## What Godmode Produces for CI

### 1. Structured Commits
Every Godmode action produces descriptive commits:
```
spec: rate-limiter — PostgreSQL full-text search
plan: rate-limiter — 10 tasks in 3 phases
test(red): rate limit config — failing test
feat: rate limit config — implementation
fix: handle null user in rate limit lookup
optimize: iteration 3 — add database index
secure: rate-limiter — PASS (0 findings)
```

CI can parse commit messages to determine what type of change was made.

### 2. Test Coverage
Godmode's build skill writes tests alongside code. By the time a PR is created, test coverage is already at target.

### 3. Security Reports
The secure skill produces reports at `docs/security/<feature>-security-audit.md` that can be attached to PRs or stored as CI artifacts.

### 4. Optimization Logs
Results at `.godmode/optimize-results.tsv` can be parsed by CI to show performance trends.

## GitHub Actions Integration

### Basic PR Checks
```yaml
# .github/workflows/godmode-checks.yml
name: Godmode PR Checks

on:
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup
        run: |
          npm ci

      - name: Run Tests
        run: npm test -- --coverage

      - name: Lint
        run: npm run lint

      - name: Type Check
        run: npx tsc --noEmit

      - name: Security Audit
        run: npm audit --audit-level=high

      - name: Check for Debug Code
        run: |
          if grep -rn "console\.log\|debugger" src/ --include="*.ts" --include="*.js"; then
            echo "Debug code found in source files"
            exit 1
          fi

      - name: Verify Coverage Target
        run: |
          COVERAGE=$(npx jest --coverage --coverageReporters=text-summary 2>&1 | grep "Statements" | awk '{print $3}' | tr -d '%')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80% target"
            exit 1
          fi
```

### Performance Regression Check
```yaml
# .github/workflows/godmode-perf.yml
name: Performance Check

on:
  pull_request:
    branches: [main]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup
        run: npm ci && npm run build

      - name: Start Server
        run: npm start &
        env:
          NODE_ENV: production

      - name: Wait for Server
        run: |
          for i in {1..30}; do
            curl -s http://localhost:3000/health && break
            sleep 1
          done

      - name: Benchmark
        run: |
          RESULT=$(curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/products)
          RESULT_MS=$(echo "$RESULT * 1000" | bc | cut -d. -f1)
          echo "Response time: ${RESULT_MS}ms"

          if [ "$RESULT_MS" -gt 500 ]; then
            echo "PERFORMANCE REGRESSION: ${RESULT_MS}ms > 500ms threshold"
            exit 1
          fi

      - name: Archive Godmode Logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: godmode-logs
          path: .godmode/
```

### Security Report as PR Comment
```yaml
# .github/workflows/godmode-security.yml
name: Security Report

on:
  pull_request:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dependency Audit
        run: |
          npm audit --json > /tmp/audit-report.json || true
          CRITICAL=$(jq '.metadata.vulnerabilities.critical' /tmp/audit-report.json)
          HIGH=$(jq '.metadata.vulnerabilities.high' /tmp/audit-report.json)
          echo "Critical: $CRITICAL, High: $HIGH"
          if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
            echo "SECURITY: $CRITICAL critical, $HIGH high vulnerabilities"
            exit 1
          fi

      - name: Check Security Report
        run: |
          if ls docs/security/*-security-audit.md 1>/dev/null 2>&1; then
            echo "Security audit report found"
            cat docs/security/*-security-audit.md
          else
            echo "WARNING: No security audit report found. Run /godmode:secure before shipping."
          fi
```

## GitLab CI Integration

```yaml
# .gitlab-ci.yml
stages:
  - test
  - security
  - deploy

tests:
  stage: test
  script:
    - npm ci
    - npm test -- --coverage
    - npm run lint
    - npx tsc --noEmit
  coverage: '/Statements\s*:\s*(\d+\.?\d*)%/'

security:
  stage: security
  script:
    - npm audit --audit-level=high
    - grep -rn "console\.log\|debugger" src/ --include="*.ts" && exit 1 || true
  artifacts:
    paths:
      - docs/security/

deploy:
  stage: deploy
  script:
    - npm run build
    - npm run deploy
  only:
    - main
  when: manual
```

## Using Godmode Logs in CI

### Parse Optimization Results
```bash
# In CI: check if optimization met targets
if [ -f .godmode/optimize-results.tsv ]; then
  FINAL=$(tail -1 .godmode/optimize-results.tsv | cut -f7)
  TARGET=400
  if [ "$FINAL" -gt "$TARGET" ]; then
    echo "Optimization target not met: ${FINAL}ms > ${TARGET}ms"
    exit 1
  fi
fi
```

### Parse Fix Log
```bash
# In CI: check all errors were resolved
if [ -f .godmode/fix-log.tsv ]; then
  ERRORS=$(wc -l < .godmode/fix-log.tsv)
  echo "$((ERRORS - 1)) errors were fixed during development"
fi
```

### Archive Godmode Artifacts
Always archive the `.godmode/` directory as a CI artifact. It contains:
- `config.yaml` — Project configuration
- `optimize-results.tsv` — Optimization experiment history
- `fix-log.tsv` — Error remediation history
- `ship-log.tsv` — Deployment history

These artifacts provide an audit trail of the development process.

## Pre-Commit Hooks

### Using Husky (Node.js)
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm test && npm run lint",
      "commit-msg": "node scripts/validate-commit-msg.js"
    }
  }
}
```

### Validating Godmode Commit Messages
```javascript
// scripts/validate-commit-msg.js
const msg = require('fs').readFileSync(process.argv[2], 'utf8').trim();
const validPrefixes = [
  'spec:', 'plan:', 'feat:', 'fix:', 'test:', 'test(red):',
  'refactor:', 'optimize:', 'secure:', 'build:', 'review:',
  'setup:', 'predict:', 'scenario:', 'ship:', 'docs:'
];
const isValid = validPrefixes.some(p => msg.startsWith(p));
if (!isValid) {
  console.error('Commit message must start with a valid prefix:', validPrefixes.join(', '));
  process.exit(1);
}
```

## Dashboard Ideas

Build a dashboard from Godmode's TSV logs:

### Optimization Trends
Parse `optimize-results.tsv` to show:
- Metric value over time (iterations)
- Keep/revert ratio
- Biggest improvements by category

### Error Resolution
Parse `fix-log.tsv` to show:
- Errors by type (test, lint, type)
- Fix rate (errors/hour)
- Cascade fix ratio

### Shipping Velocity
Parse `ship-log.tsv` to show:
- Deployments per week
- Rollback rate
- Time from PR to deploy
