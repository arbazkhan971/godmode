---
name: scenario
description: |
  Edge case and scenario exploration skill. Activates when user needs to discover what could go wrong, explore failure modes, or stress-test a design across 12 dimensions. Triggers on: /godmode:scenario, "what could go wrong?", "edge cases", "failure modes", or when invoked by /godmode:think --scenario. Produces a scenario matrix with test suggestions.
---

# Scenario — Edge Case Exploration

## When to Activate
- User invokes `/godmode:scenario`
- User asks "what could go wrong?" or "what are the edge cases?"
- User wants to stress-test a design before implementation
- Invoked by `/godmode:think --scenario` after selecting an approach
- Before writing tests, to ensure comprehensive coverage

## Workflow

### Step 1: Identify the Target
Determine what is being explored:
1. A feature spec from `docs/specs/`
2. An API endpoint or function
3. A data flow or state machine
4. A user workflow or interaction

```
SCENARIO TARGET:
<What we're exploring>

INPUTS: <What goes in — parameters, user actions, data>
OUTPUTS: <What comes out — responses, state changes, side effects>
INVARIANTS: <What must always be true>
```

### Step 2: Explore 12 Dimensions
Systematically explore scenarios across these dimensions:

#### Dimension 1: Happy Path
The normal, expected flow. Confirm it works as designed.
```
- Standard input with typical values
- Expected user workflow, beginning to end
- Normal load, normal data, normal conditions
```

#### Dimension 2: Empty / Null / Missing
What happens when data is absent?
```
- Empty string, empty array, empty object
- null/undefined/None where values expected
- Missing required fields
- Missing optional fields (default behavior)
- Empty database (first user, first record)
```

#### Dimension 3: Boundary Values
What happens at the edges?
```
- Zero, one, max int, min int
- Empty string vs single character vs max length
- First item, last item, only item
- Exactly at the limit (rate limit, size limit, time limit)
- One above / one below each limit
```

#### Dimension 4: Invalid Input
What happens with bad data?
```
- Wrong type (string where number expected)
- Malformed format (bad JSON, bad date, bad email)
- Out of range values
- Special characters (unicode, emoji, RTL, zero-width)
- Extremely long strings
- Negative numbers where positive expected
```

#### Dimension 5: Authentication & Authorization
Who can do what?
```
- Unauthenticated user
- Authenticated but unauthorized
- Expired token / session
- Admin vs regular user
- Acting on another user's resources
- Deleted / disabled account
```

#### Dimension 6: Concurrency & Race Conditions
What happens with simultaneous operations?
```
- Two users editing same resource
- Double-submit (button clicked twice)
- Read-modify-write races
- Stale data displayed then submitted
- Concurrent creation of "unique" resources
```

#### Dimension 7: Error Recovery
What happens when things fail?
```
- Database connection lost mid-operation
- External API timeout
- Partial failure (2 of 3 steps succeed)
- Retry behavior (idempotent? duplicate side effects?)
- Error during error handling
```

#### Dimension 8: Scale & Performance
What happens under pressure?
```
- 10x normal load
- 100x data volume
- Large payloads (100MB upload, 10K items in list)
- Many concurrent connections
- Slow client / slow network
```

#### Dimension 9: State & Ordering
What happens with unexpected sequences?
```
- Steps executed out of order
- Repeated steps
- Skipped steps
- Going backward in a workflow
- Operation on deleted/archived resource
- Operation during maintenance/migration
```

#### Dimension 10: Abuse & Adversarial
What can a malicious user do?
```
- SQL injection, XSS, command injection
- CSRF / SSRF attacks
- Enumeration attacks (user IDs, endpoints)
- Rate limit bypass attempts
- Privilege escalation attempts
- Data exfiltration via error messages
```

#### Dimension 11: Integration Boundaries
What happens at system borders?
```
- External service is down
- External service returns unexpected format
- Webhook delivered out of order
- Clock skew between services
- Schema mismatch between producer/consumer
- Cache inconsistency with source of truth
```

#### Dimension 12: Data Lifecycle
What happens over time?
```
- Data migration from old format
- Backward compatibility with old clients
- Expired / stale cached data
- Data growth over months/years
- Timezone and DST transitions
- Leap seconds, leap years, end of month
```

### Step 3: Build the Scenario Matrix
For each dimension, generate 2-5 specific scenarios:

```
| # | Dimension | Scenario | Expected Behavior | Severity | Test? |
|---|-----------|----------|-------------------|----------|-------|
| 1 | Happy     | User creates account with valid email | 201, account created | — | YES |
| 2 | Empty     | POST /users with empty body | 400, validation error | MEDIUM | YES |
| 3 | Boundary  | Username exactly 255 chars | Accepted | LOW | YES |
| 4 | Invalid   | Email without @ symbol | 400, "invalid email" | MEDIUM | YES |
| 5 | Auth      | Create user without auth token | 401 | HIGH | YES |
| ... | ... | ... | ... | ... | ... |
```

Target: 30-50 scenarios across all 12 dimensions.

### Step 4: Prioritize for Testing
Sort scenarios by severity and mark which ones MUST have tests:

```
MUST TEST (Critical/High):
1. <scenario> → test: <test description>
2. <scenario> → test: <test description>

SHOULD TEST (Medium):
3. <scenario> → test: <test description>
4. <scenario> → test: <test description>

NICE TO TEST (Low):
5. <scenario> → test: <test description>
```

### Step 5: Commit and Transition
1. Save as `docs/scenarios/<feature-name>-scenarios.md`
2. Commit: `"scenario: <feature> — <N> scenarios across 12 dimensions"`
3. Suggest:
   - If no plan yet: "Run `/godmode:plan` — these scenarios will inform the task breakdown."
   - If plan exists: "Run `/godmode:test` — use these scenarios to write comprehensive tests."

## Key Behaviors

1. **Be specific, not generic.** "User enters bad data" is worthless. "User enters a 10MB string in the name field" is a scenario.
2. **Include expected behavior.** Every scenario must state what SHOULD happen, not just what might go wrong.
3. **Severity matters.** Not all edge cases are equal. A crash on empty input is CRITICAL. A cosmetic issue with emoji is LOW.
4. **Connect to tests.** The entire point of this skill is to inform test writing. Every scenario should map to a potential test case.
5. **Don't boil the ocean.** 30-50 scenarios is the target. Going to 200 scenarios helps nobody. Focus on the ones that matter.

## Example Usage

### API endpoint exploration
```
User: /godmode:scenario Explore edge cases for our POST /api/orders endpoint

Scenario: Analyzing the orders endpoint...

SCENARIO TARGET:
POST /api/orders — Create a new order from cart items

INPUTS: { items: [{productId, quantity}], shippingAddress, paymentMethodId }
OUTPUTS: { orderId, status, total, estimatedDelivery }
INVARIANTS: inventory must be decremented, payment must be charged, confirmation email must be sent

## Dimension 1: Happy Path
| # | Scenario | Expected | Severity |
|---|----------|----------|----------|
| 1 | Single item, valid payment, in-stock | 201, order created, inventory decremented | — |
| 2 | Multiple items, valid payment, all in-stock | 201, order created, all inventory decremented | — |

## Dimension 2: Empty / Null / Missing
| # | Scenario | Expected | Severity |
|---|----------|----------|----------|
| 3 | Empty items array | 400, "at least one item required" | HIGH |
| 4 | Missing shippingAddress | 400, "shipping address required" | HIGH |
| 5 | Missing paymentMethodId | 400, "payment method required" | HIGH |
| 6 | null quantity | 400, "quantity must be a positive integer" | MEDIUM |
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full 12-dimension exploration |
| `--quick` | Top 4 dimensions only (happy, empty, boundary, error) |
| `--security` | Focus on dimensions 5 (auth) and 10 (abuse) |
| `--scale` | Focus on dimensions 6 (concurrency) and 8 (scale) |
| `--dimension <N>` | Deep dive into a specific dimension (1-12) |
| `--test-output` | Output scenarios as test case skeletons (describe/it blocks) |

## Anti-Patterns

- **Do NOT list generic scenarios.** "Something goes wrong" is not a scenario. Be painfully specific.
- **Do NOT skip the happy path.** Dimension 1 matters — it confirms the basic flow before exploring failures.
- **Do NOT forget expected behavior.** A scenario without expected behavior is just a worry, not a test case.
- **Do NOT ignore the codebase.** Check what validation already exists before listing "missing validation" as a scenario.
- **Do NOT produce an overwhelming list.** 30-50 scenarios is the sweet spot. More than 100 means you haven't prioritized.
- **Do NOT treat all dimensions equally.** For a pure calculation function, concurrency and auth dimensions may not apply. Skip what's irrelevant.
