---
name: snapshot
description: |
  Snapshot and approval testing skill. Activates when user needs to verify complex outputs against known-good baselines — including snapshot testing for serialized structures, approval testing for human-reviewed outputs, and golden file testing for deterministic artifacts. Covers when snapshot testing is valuable vs harmful, update policies, CI strategies for snapshot management, and framework-specific patterns for Jest, Vitest, pytest, Go, and JUnit. Triggers on: /godmode:snapshot, "snapshot test", "approval test", "golden file", "baseline test", or when /godmode:test identifies output verification needs.
---

# Snapshot — Snapshot & Approval Testing

## When to Activate
- User invokes `/godmode:snapshot`
- User asks "snapshot test this" or "test against a baseline"
- User asks about approval testing or golden file testing
- User needs to verify complex output (HTML, JSON, config files, CLI output)
- `/godmode:test` identifies components that produce complex serialized output
- User asks "should I use snapshot tests here?"

## Workflow

### Step 1: Evaluate Snapshot Suitability
Not everything should be snapshot tested. Assess whether snapshots are the right tool:

```
SNAPSHOT SUITABILITY ASSESSMENT:
Target: <component/function being tested>
Output type: <JSON | HTML | JSX | text | binary | image>

SUITABLE for snapshots:
  [ ] Output is deterministic (same input always produces same output)
  [ ] Output is complex enough that manual assertion is tedious
  [ ] Output changes are meaningful and should be reviewed
  [ ] Output is human-readable (can be reviewed in a diff)
  [ ] Changes to output are infrequent

NOT SUITABLE for snapshots:
  [ ] Output contains timestamps, random IDs, or non-deterministic values
  [ ] Output is too large (>500 lines) — diffs become unreadable
  [ ] Output changes every commit — constant snapshot updates erode trust
  [ ] Output format is binary and not diffable
  [ ] You can express the assertion with a simple equality check

Verdict: <USE SNAPSHOTS | USE TARGETED ASSERTIONS | HYBRID APPROACH>
```

#### Decision Framework

```
SHOULD I USE A SNAPSHOT TEST?

         ┌────────────────────────────────────┐
         │  Is the output complex (>10 lines  │
         │  or deeply nested)?                │
         └──────────┬─────────────────────────┘
                    │
             YES    │    NO
             ▼      │    ▼
   ┌──────────────┐ │ ┌─────────────────────────┐
   │  Is the output│ │ │ Use targeted assertions │
   │  deterministic?│ │ │ (expect().toBe(), etc.) │
   └──────┬───────┘ │ └─────────────────────────┘
          │         │
   YES    │    NO   │
   ▼      │    ▼    │
┌────────┐│┌────────────────────────────────────┐
│ Does it│││ Stabilize first: strip timestamps, │
│ change ││ │ replace UUIDs with deterministic   │
│ often? │││ values, then snapshot the stable    │
└──┬─────┘│ │ portion.                           │
   │      │ └────────────────────────────────────┘
   │      │
YES│  NO  │
▼  │  ▼   │
┌────────┐ ┌──────────────────┐
│ Use    │ │ USE SNAPSHOTS    │
│targeted│ │ (best fit)       │
│asserts │ └──────────────────┘
│+ inline│
│snapshot│
└────────┘
```

### Step 2: Choose Snapshot Strategy

#### Strategy 1: File-Based Snapshots (default)
Snapshots stored in separate `.snap` files alongside tests:

```typescript
// Jest/Vitest — file-based snapshot
it('renders the user profile card', () => {
  const component = render(<UserProfileCard user={testUser} />);
  expect(component.toJSON()).toMatchSnapshot();
});
// Creates __snapshots__/user-profile.test.ts.snap
```

**Pros:** Large snapshots stay out of test files, version controlled, easy to diff.
**Cons:** Developers may update snapshots without reviewing them.

#### Strategy 2: Inline Snapshots
Snapshot stored directly in the test file:

```typescript
// Jest/Vitest — inline snapshot
it('formats a US phone number', () => {
  expect(formatPhone('2125551234')).toMatchInlineSnapshot(`"(212) 555-1234"`);
});

it('serializes user to JSON', () => {
  expect(serializeUser(testUser)).toMatchInlineSnapshot(`
    {
      "id": "user-1",
      "name": "Alice Johnson",
      "email": "alice@example.com",
      "role": "admin"
    }
  `);
});
```

**Pros:** Snapshot is visible in the test — reviewers see expected output immediately.
**Cons:** Only practical for small outputs (under 20 lines).

**Rule of thumb:** Use inline snapshots for outputs under 20 lines. Use file-based for anything larger.

#### Strategy 3: Approval Testing
Human-reviewed baseline files that require explicit approval to update:

```
APPROVAL TESTING FLOW:
1. Test produces output → saved as "received" file
2. Compare "received" against "approved" baseline
3. If no approved file exists → test fails, reviewer must approve
4. If files differ → test fails, reviewer must inspect diff and approve
5. If files match → test passes

DIRECTORY STRUCTURE:
tests/
  approvals/
    report-generator/
      monthly-report.approved.txt     ← Human-reviewed baseline
      monthly-report.received.txt     ← Latest output (gitignored)
```

```typescript
// ApprovalTests approach (any language)
import { verify } from 'approvals';

it('generates the monthly report', () => {
  const report = generateMonthlyReport(testData);
  verify(report); // Compares against .approved.txt file
});
```

```python
# Python — approvaltests
from approvaltests import verify

def test_generates_monthly_report():
    report = generate_monthly_report(test_data)
    verify(report)  # Compares against .approved.txt
```

```java
// Java — ApprovalTests
@Test
void generatesMonthlyReport() {
    String report = reportGenerator.generateMonthly(testData);
    Approvals.verify(report);
}
```

#### Strategy 4: Golden File Testing
Deterministic output files used as reference baselines:

```go
// Go — golden file pattern (idiomatic)
func TestGenerateConfig(t *testing.T) {
    got := generateConfig(testInput)

    goldenFile := filepath.Join("testdata", t.Name()+".golden")

    if *update {
        // go test -update flag regenerates golden files
        os.WriteFile(goldenFile, got, 0644)
        return
    }

    want, err := os.ReadFile(goldenFile)
    assert.NoError(t, err)
    assert.Equal(t, string(want), string(got))
}
```

```
GOLDEN FILE DIRECTORY:
testdata/
  TestGenerateConfig/
    basic-config.golden            ← Expected output
    config-with-overrides.golden
    empty-config.golden
```

```go
// Go — update golden files with flag
var update = flag.Bool("update", false, "update golden files")

// Usage: go test -update ./...
```

### Step 3: Handle Non-Deterministic Output

Non-deterministic values (timestamps, UUIDs, random tokens) break snapshot tests. Stabilize them before snapshotting.

#### Approach 1: Replace Dynamic Values Before Snapshot

```typescript
// Strip dynamic values before snapshotting
function stabilize(output: string): string {
  return output
    .replace(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/g, '<<TIMESTAMP>>')
    .replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, '<<UUID>>')
    .replace(/"token":"[^"]+"/g, '"token":"<<TOKEN>>"');
}

it('generates API response', () => {
  const response = createOrderResponse(testOrder);
  expect(stabilize(JSON.stringify(response, null, 2))).toMatchSnapshot();
});
```

#### Approach 2: Custom Serializers

```typescript
// Jest custom serializer
expect.addSnapshotSerializer({
  test: (val) => val && val.createdAt instanceof Date,
  serialize: (val, config, indentation, depth, refs, printer) => {
    const stable = { ...val, createdAt: '<<DATE>>', updatedAt: '<<DATE>>' };
    return printer(stable, config, indentation, depth, refs);
  },
});
```

#### Approach 3: Property Matchers (Jest/Vitest)

```typescript
// Match structure but allow dynamic values
it('creates order with timestamp', () => {
  const order = createOrder(testInput);

  expect(order).toMatchSnapshot({
    id: expect.any(String),
    createdAt: expect.any(Date),
    items: expect.arrayContaining([
      expect.objectContaining({ product: 'widget' }),
    ]),
  });
});
```

#### Approach 4: Inject Deterministic Values in Tests

```typescript
// Best approach: make the code testable by injecting time/ID generators
it('creates order with predictable values', () => {
  const order = createOrder(testInput, {
    idGenerator: () => 'order-001',
    clock: () => new Date('2024-01-15T10:00:00Z'),
  });

  expect(order).toMatchSnapshot();
  // Snapshot is fully deterministic — no replacements needed
});
```

### Step 4: Snapshot Update Policies

#### When to Update Snapshots

```
SNAPSHOT UPDATE POLICY:

ALWAYS review the diff before updating. Never blindly run `--updateSnapshot`.

UPDATE when:
  - You intentionally changed the output (new feature, format change)
  - A dependency update changed formatting (prettier, serializer)
  - You fixed a bug that changes the correct output

DO NOT UPDATE when:
  - You do not understand why the snapshot changed
  - The change is unrelated to your work (investigate first)
  - Multiple unrelated snapshots changed at once (smells like a bug)

REVIEW CHECKLIST before `--updateSnapshot`:
  [ ] I understand every line that changed in the snapshot diff
  [ ] The new output is correct (not just different)
  [ ] No unintended changes leaked in (timestamps, formatting noise)
  [ ] The snapshot is still readable and reviewable
```

#### Update Commands

```bash
# Jest — update all snapshots
npx jest --updateSnapshot

# Jest — update snapshots for specific test file
npx jest --updateSnapshot --testPathPattern="user-profile"

# Vitest
npx vitest --update

# pytest-snapshot
pytest --snapshot-update

# Go golden files
go test -update ./...
```

#### CI Enforcement
Prevent accidental snapshot updates from being committed without review:

```yaml
# .github/workflows/test.yml
- name: Run tests (snapshot changes fail CI)
  run: npm test
  # If snapshots are outdated, tests fail.
  # Developer must run --updateSnapshot locally and commit the new snapshots.

- name: Check no received files committed
  run: |
    # Approval testing: received files should never be committed
    if find . -name "*.received.*" | grep -q .; then
      echo "ERROR: .received files found — these should not be committed"
      exit 1
    fi
```

### Step 5: Framework-Specific Snapshot Patterns

#### Jest / Vitest

```typescript
// Basic snapshot
expect(value).toMatchSnapshot();

// Inline snapshot (auto-filled on first run)
expect(value).toMatchInlineSnapshot();

// Named snapshot (custom name instead of auto-incrementing)
expect(value).toMatchSnapshot('user profile card');

// Property matchers (allow dynamic fields)
expect(value).toMatchSnapshot({
  id: expect.any(String),
  createdAt: expect.any(Date),
});

// Snapshot of a thrown error
expect(() => validate(badInput)).toThrowErrorMatchingSnapshot();
expect(() => validate(badInput)).toThrowErrorMatchingInlineSnapshot(
  `"Input must be a non-empty string"`
);

// Custom serializer for complex objects
expect.addSnapshotSerializer({
  test: (val) => val instanceof MyCustomClass,
  serialize: (val) => `MyCustomClass { value: ${val.value} }`,
});
```

#### pytest (with pytest-snapshot or syrupy)

```python
# syrupy (modern snapshot testing for pytest)
def test_serialize_user(snapshot):
    user = create_test_user()
    result = serialize_user(user)
    assert result == snapshot

# pytest-snapshot
def test_generate_report(snapshot):
    report = generate_report(test_data)
    snapshot.assert_match(report, "monthly-report.txt")

# Custom snapshot serializer
class JSONSnapshotSerializer:
    def serialize(self, data):
        return json.dumps(data, indent=2, sort_keys=True, default=str)
```

#### Go Golden Files

```go
// Standard golden file pattern
func TestOutput(t *testing.T) {
    tests := []struct {
        name  string
        input Input
    }{
        {"basic", basicInput},
        {"with-options", inputWithOptions},
        {"empty", emptyInput},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := processInput(tt.input)

            golden := filepath.Join("testdata", t.Name()+".golden")
            if *update {
                os.MkdirAll(filepath.Dir(golden), 0755)
                os.WriteFile(golden, []byte(got), 0644)
                return
            }

            want, err := os.ReadFile(golden)
            require.NoError(t, err)
            assert.Equal(t, string(want), got)
        })
    }
}
```

#### JUnit (with ApprovalTests)

```java
// ApprovalTests for Java
@Test
void generatesInvoice() {
    String invoice = invoiceGenerator.generate(testOrder);
    Approvals.verify(invoice);
}

// With custom reporter (opens diff tool on failure)
@Test
void generatesReport() {
    String report = reportService.generateMonthly(testData);
    Approvals.verify(report, new DiffReporter());
}

// Combination approvals (test multiple inputs)
@Test
void formatsAllCurrencies() {
    CombinationApprovals.verifyAllCombinations(
        CurrencyFormatter::format,
        new Double[]{0.0, 1.5, 100.0, 99999.99},
        new String[]{"USD", "EUR", "GBP", "JPY"}
    );
}
```

### Step 6: Snapshot Testing for Specific Domains

#### React/UI Component Snapshots

```typescript
// Component snapshot — structure test
import { render } from '@testing-library/react';

it('renders login form', () => {
  const { container } = render(<LoginForm onSubmit={jest.fn()} />);
  expect(container.firstChild).toMatchSnapshot();
});

// BETTER: snapshot only the meaningful parts
it('renders login form fields', () => {
  const { getByRole, getByLabelText } = render(<LoginForm onSubmit={jest.fn()} />);
  expect(getByLabelText('Email')).toMatchSnapshot('email field');
  expect(getByLabelText('Password')).toMatchSnapshot('password field');
  expect(getByRole('button', { name: 'Sign In' })).toMatchSnapshot('submit button');
});
```

**Warning:** Full component tree snapshots are fragile. Prefer targeted assertions for behavior and limit snapshots to structure-critical components.

#### API Response Snapshots

```typescript
it('returns paginated user list', async () => {
  await seedUsers(25);

  const response = await request(app)
    .get('/api/users?page=1&limit=10')
    .expect(200);

  // Snapshot the response structure, not exact data
  expect(stabilizeResponse(response.body)).toMatchSnapshot();
});

function stabilizeResponse(body: any) {
  return {
    ...body,
    data: body.data.map((item: any) => ({
      ...item,
      id: '<<ID>>',
      createdAt: '<<TIMESTAMP>>',
    })),
    meta: body.meta, // pagination meta is deterministic
  };
}
```

#### CLI Output Snapshots

```typescript
it('displays help text', () => {
  const output = execSync('node cli.js --help').toString();
  expect(output).toMatchSnapshot();
});

it('displays error for invalid command', () => {
  try {
    execSync('node cli.js invalid-command');
  } catch (error) {
    expect(stabilize(error.stderr.toString())).toMatchSnapshot();
  }
});
```

#### Configuration/Code Generation Snapshots

```typescript
it('generates TypeScript types from schema', () => {
  const schema = loadSchema('user.schema.json');
  const generated = generateTypes(schema);
  expect(generated).toMatchSnapshot();
});

it('generates migration SQL from model diff', () => {
  const diff = comparModels(oldModel, newModel);
  const migration = generateMigration(diff);
  expect(migration).toMatchSnapshot();
});
```

### Step 7: Snapshot Maintenance

#### Snapshot Hygiene Rules

```
SNAPSHOT HYGIENE:

1. Keep snapshots small and focused
   BAD:  Snapshot of entire page HTML (2000 lines)
   GOOD: Snapshot of the specific component or section that matters

2. Name snapshots descriptively
   BAD:  toMatchSnapshot()  → "Snapshot 1", "Snapshot 2"
   GOOD: toMatchSnapshot('user profile with admin badge')

3. One snapshot per test
   BAD:  3 toMatchSnapshot() calls in one test
   GOOD: 1 snapshot per test, each testing a specific output

4. Review snapshot diffs like code diffs
   Every snapshot update in a PR should be reviewed with the same
   scrutiny as a code change. The snapshot IS the expected behavior.

5. Delete obsolete snapshots
   Jest: --ci flag fails on obsolete snapshots
   Regular cleanup: npx jest --clearCache
```

#### Detecting Snapshot Rot

```
SIGNS OF SNAPSHOT ROT:
- Developers run --updateSnapshot without reading diffs
- Snapshot files are 1000+ lines long
- Multiple unrelated snapshots change in a single PR
- Nobody can explain what a specific snapshot is testing
- Snapshot updates are rubber-stamped in code review

REMEDIATION:
1. Switch large file-based snapshots to inline snapshots (forces small size)
2. Replace structural snapshots with targeted assertions
3. Add snapshot review to the PR checklist
4. Use --ci flag in CI to prevent obsolete snapshot accumulation
5. Set maximum snapshot size policy (fail if snapshot > N lines)
```

### Step 8: Run, Verify, and Report

```bash
# Run snapshot tests
<framework command>

# Update snapshots after intentional changes
<framework command> --updateSnapshot

# Check for obsolete snapshots (Jest)
npx jest --ci

# List all snapshot files
find . -name "*.snap" -o -name "*.approved.*"
```

```
SNAPSHOT TEST REPORT:
Target: <component/module>
Tests written: <N>
  - File-based snapshots: <N>
  - Inline snapshots: <N>
  - Approval tests: <N>
  - Golden file tests: <N>
Stabilization applied: <YES/NO>
  - Replaced: <timestamps, UUIDs, tokens, etc.>
Non-deterministic values handled: <YES/NO>
All passing: <YES/NO>
Snapshot files created/updated: <list>
Largest snapshot: <N lines> (<file>)
```

### Step 9: Commit and Transition
1. Commit tests and snapshots: `"test(snapshot): <module> — <N> snapshot tests"`
2. Include snapshot files in the commit (they are part of the test)
3. If approval baselines created: note that they need initial review
4. If snapshot rot detected: recommend cleanup before adding more

## Key Behaviors

1. **Snapshots are assertions, not just recordings.** A snapshot captures expected behavior. Update it only when behavior intentionally changes.
2. **Small snapshots are good snapshots.** A 20-line inline snapshot is reviewable. A 2000-line snapshot file is ignored. Keep them focused.
3. **Stabilize before snapshotting.** Strip non-deterministic values before creating the snapshot. Flaky snapshots are worse than no snapshots.
4. **Review snapshot updates like code changes.** Every snapshot diff in a PR represents a behavior change. Treat it with the same attention.
5. **Approval tests require explicit human sign-off.** The "approved" file exists because a human reviewed and accepted the output. This is the strongest form of snapshot testing.
6. **Golden files are the Go way.** In Go, golden files in `testdata/` with an `-update` flag is the idiomatic pattern. Use it.
7. **Snapshot tests complement, not replace, behavioral tests.** Use snapshot tests for "does the output look right?" and behavioral tests for "does the logic work correctly?"

## Example Usage

### Adding snapshot tests for a component
```
User: /godmode:snapshot Add snapshot tests for the InvoiceTemplate component

Snapshot: Analyzing InvoiceTemplate...

Found: src/components/InvoiceTemplate.tsx
Output type: JSX/HTML
Deterministic: MOSTLY (contains date, invoice number)

Stabilization needed:
  - Invoice number: replace with <<INVOICE_NUMBER>>
  - Date: replace with <<DATE>>
  - Amounts: keep (deterministic from input)

Creating: tests/components/invoice-template.test.tsx

describe('InvoiceTemplate', () => {
  it('renders invoice with single line item', () => {
    const { container } = render(
      <InvoiceTemplate invoice={singleItemInvoice} clock={fixedClock} />
    );
    expect(container.firstChild).toMatchSnapshot('single item invoice');
  });

  it('renders invoice with multiple line items and tax', () => { ... });
  it('renders invoice with discount applied', () => { ... });
  it('renders invoice with zero total (free)', () => { ... });
});

Writing 4 snapshot tests with inline stabilization...
```

### Golden file testing for code generation
```
User: /godmode:snapshot Test the SQL migration generator with golden files

Snapshot: Analyzing migration generator...

Output type: SQL (deterministic text)
Strategy: Golden files in testdata/

Creating: tests/migration-generator_test.go

func TestGenerateMigration(t *testing.T) {
    tests := []struct{ name string; from, to Model }{
        {"add-column", modelV1, modelV2},
        {"drop-table", modelV2, modelV3},
        {"rename-column", modelV3, modelV4},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := GenerateMigration(tt.from, tt.to)
            // Compare against testdata/TestGenerateMigration/<name>.golden
            assertGolden(t, got)
        })
    }
}

Creating golden files:
  testdata/TestGenerateMigration/add-column.golden
  testdata/TestGenerateMigration/drop-table.golden
  testdata/TestGenerateMigration/rename-column.golden

Run with: go test -update ./... to regenerate golden files
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Assess suitability and write snapshot tests |
| `--for <file>` | Write snapshot tests for a specific component/module |
| `--inline` | Prefer inline snapshots over file-based |
| `--approval` | Use approval testing workflow |
| `--golden` | Use golden file testing pattern |
| `--update` | Update existing snapshots after intentional changes |
| `--audit` | Audit existing snapshots for rot, size, and staleness |
| `--stabilize` | Focus on stabilizing non-deterministic output |

## Anti-Patterns

- **Do NOT snapshot everything.** Snapshot tests are for complex output verification. A simple `expect(result).toBe(42)` is clearer than a snapshot of `42`.
- **Do NOT blindly update snapshots.** Running `--updateSnapshot` without reading the diff is the same as deleting the test. Review every change.
- **Do NOT snapshot non-deterministic output without stabilization.** A snapshot with timestamps creates a test that fails tomorrow. Stabilize first.
- **Do NOT create massive snapshots.** A 2000-line snapshot file will never be reviewed. Break it into focused, small snapshots or use targeted assertions instead.
- **Do NOT use snapshots as the only test.** Snapshots verify "what does the output look like?" but not "does the logic work?" Pair them with behavioral unit tests.
- **Do NOT commit .received files.** In approval testing, `.received` files are temporary. Only `.approved` files belong in version control.
- **Do NOT skip snapshot review in PRs.** Snapshot changes in a PR diff are behavior changes. Reviewers must understand why each snapshot changed.
- **Do NOT use full component tree snapshots for React/UI.** They break on every CSS class change, every dependency update, every minor refactor. Snapshot the meaningful structure, not the entire DOM tree.
