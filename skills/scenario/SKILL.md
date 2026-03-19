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

### Step 2: Explore 12 Dimensions (Expanded — 3-5 Specific Scenarios Each)
Systematically explore scenarios across these dimensions. For each dimension, generate 3-5 **specific, concrete scenarios** — not categories or vague descriptions.

#### Dimension 1: Happy Path
The normal, expected flow. Confirm it works as designed.
```
Scenarios:
1. Standard input with typical values, full workflow end-to-end
2. Minimal valid input (only required fields, no optional data)
3. Maximum valid input (all optional fields populated, longest valid strings)
4. Returning user with existing data (not first-time setup)
5. Workflow with all feature flags enabled vs disabled
```

#### Dimension 2: Empty / Null / Missing
What happens when data is absent?
```
Scenarios:
1. POST/PUT with completely empty body ({} or "")
2. null/undefined/None in every individual field (test each separately)
3. Missing required fields (one missing, all missing, combination)
4. Empty database — first user, first record, no seed data
5. Optional fields omitted — verify defaults are applied correctly
```

#### Dimension 3: Boundary Values
What happens at the edges?
```
Scenarios:
1. Numeric boundaries: 0, 1, -1, MAX_INT, MIN_INT, MAX_INT+1, NaN, Infinity
2. String boundaries: empty, 1 char, exactly at max length, max length + 1
3. Collection boundaries: empty array, single item, exactly at pagination limit, limit + 1
4. Time boundaries: midnight, end of month, end of year, DST transition, leap second
5. Rate/quota limits: exactly at limit, one over, rapid succession hitting limit
```

#### Dimension 4: Invalid Input
What happens with bad data?
```
Scenarios:
1. Type coercion attacks: "123" where int expected, 0 where boolean expected, array where string expected
2. Malformed formats: truncated JSON, XML in JSON field, date as "not-a-date", email as "@@"
3. Encoding attacks: unicode null bytes, RTL override chars, zero-width joiners, homoglyph characters
4. Size attacks: 10MB string in name field, 100K element array, deeply nested JSON (1000 levels)
5. Injection payloads: SQL in search fields, script tags in user input, LDAP injection, path traversal (../../etc/passwd)
```

#### Dimension 5: Authentication & Authorization
Who can do what?
```
Scenarios:
1. Unauthenticated access to every protected endpoint (full sweep)
2. Valid token but wrong scope/role — user accessing admin endpoints
3. Expired token (just expired, expired 1 hour ago, expired 30 days ago)
4. Token replay: reuse a previously valid token after logout/password change
5. Horizontal privilege escalation: User A accessing User B's resources via direct ID manipulation
```

#### Dimension 6: Concurrency & Race Conditions
What happens with simultaneous operations?
```
Scenarios:
1. Double-submit: same request sent twice within 100ms (button mash, network retry)
2. Concurrent edit: two users load same resource, both edit, both save — last write wins? merge? error?
3. Inventory race: 1 item left, 3 users click "buy" simultaneously
4. Read-modify-write: fetch balance, compute new balance, write — interrupted by another write
5. Concurrent creation of unique resources: two users register same username at same instant
```

#### Dimension 7: Error Recovery
What happens when things fail?
```
Scenarios:
1. Database connection drops mid-transaction (after debit, before credit)
2. External API timeout after 30s — does the system retry? with backoff? is the operation idempotent?
3. Partial failure in multi-step operation: steps 1-2 succeed, step 3 fails — are steps 1-2 rolled back?
4. Disk full during file write — is partial file cleaned up?
5. Error during error handling: exception in the catch block, failure to log the failure
```

#### Dimension 8: Load & Scale
What happens under pressure?
```
Scenarios:
1. 10x normal traffic: gradual ramp over 5 minutes — at what point does latency degrade?
2. 100x traffic spike: sudden burst (viral moment, DDoS) — does the system degrade gracefully or fall over?
3. Single-region failure: one AZ/datacenter goes down — does traffic failover? how long is the gap?
4. Large payloads at scale: 100MB upload from 50 concurrent users
5. Slow consumer: downstream service responds in 5s instead of 50ms — does backpressure work or do queues explode?
```

#### Dimension 9: Data Integrity & Migration
What happens to data under stress?
```
Scenarios:
1. Corrupt input: valid JSON structure but semantically invalid data (negative prices, future birthdates)
2. Schema migration mid-flight: deploy new schema while old-format requests are still in the queue
3. Backup restoration: restore from 1-hour-old backup — what data is lost, what's inconsistent?
4. Data format evolution: old clients send v1 format, new clients send v2 — does the API handle both?
5. Orphaned data: parent record deleted but child records remain — cascade delete? soft delete? dangling references?
```

#### Dimension 10: Security & Adversarial
What can a malicious actor do?
```
Scenarios:
1. Credential leak: API key committed to public repo — what's the blast radius? can it be rotated without downtime?
2. SSRF via user input: user provides a URL that resolves to internal service (http://169.254.169.254/metadata)
3. Token replay attack: intercept and reuse a valid JWT after the user logs out
4. Privilege escalation: regular user modifies their role claim in a JWT, or manipulates a hidden form field
5. Data exfiltration via error messages: trigger verbose errors that leak stack traces, SQL queries, or internal IPs
```

#### Dimension 11: Network & Infrastructure
What happens when the network misbehaves?
```
Scenarios:
1. DNS failure: DNS resolver is down or returns stale records — does the app use cached DNS? timeout behavior?
2. Upstream API timeout: third-party API stops responding — circuit breaker? fallback? user-facing error?
3. Certificate expiry: TLS cert expires on a Saturday night — does monitoring catch it? can it auto-renew?
4. Network partition: service A can reach service B but not service C — partial functionality or full outage?
5. Intermittent packet loss: 5% packet loss on the connection to the database — retries? connection pool exhaustion?
```

#### Dimension 12: Data Lifecycle & Time
What happens over time?
```
Scenarios:
1. Data growth: table goes from 10K rows to 10M rows over 6 months — do queries still perform? are indexes adequate?
2. Timezone transitions: user in UTC+5:30 creates a record, user in UTC-8 reads it — displayed correctly?
3. DST transition: a scheduled job set for 2:30 AM on DST spring-forward (2:30 AM doesn't exist)
4. Stale cache: cache TTL is 1 hour, source data changes every minute — eventual consistency impact on users?
5. Backward compatibility: old mobile app (v1.2) still calling deprecated API endpoints 2 years later
```

### Step 3: Scenario Severity Scoring
For every scenario generated in Step 2, score it on two axes:

```
SCENARIO SEVERITY SCORING:

| # | Dimension | Scenario | Likelihood (1-5) | Impact (1-5) | Priority (L×I) | Expected Behavior |
|---|-----------|----------|-------------------|--------------|-----------------|-------------------|
| 1 | Happy     | Standard valid input | 5 | 1 | 5 | 200, success |
| 2 | Empty     | POST with empty body | 4 | 3 | 12 | 400, validation error |
| 3 | Security  | SSRF via user URL input | 2 | 5 | 10 | URL validated, internal ranges blocked |
| 4 | Load      | 100x traffic spike | 2 | 5 | 10 | Graceful degradation, 503 for excess |
| 5 | Auth      | Expired token | 4 | 4 | 16 | 401, clear error message |
| ... | ... | ... | ... | ... | ... | ... |
```

Scoring guide:
- **Likelihood:** 1 = extremely rare (once a year), 2 = rare (once a month), 3 = occasional (once a week), 4 = common (daily), 5 = every session
- **Impact:** 1 = cosmetic/minor, 2 = degraded UX, 3 = feature broken, 4 = data loss/security issue, 5 = system down/breach

**Priority thresholds:**
- **CRITICAL (20-25):** High likelihood AND high impact. Must be handled before launch.
- **HIGH (12-19):** Likely or impactful. Should be handled before launch.
- **MEDIUM (6-11):** Moderate. Handle in first iteration post-launch.
- **LOW (1-5):** Rare and low impact. Backlog.

Target: 30-50 scored scenarios across all 12 dimensions.

### Step 4: Mitigation Mapping
For every HIGH and CRITICAL priority scenario, map it to specific godmode skills and actions that address it:

```
MITIGATION MAP:

| Priority | Scenario | Mitigation | Godmode Skill | Action |
|----------|----------|------------|---------------|--------|
| CRITICAL (20) | Expired token returns 500 instead of 401 | Add token validation middleware | /godmode:build | Implement auth middleware |
| CRITICAL (16) | Double-submit creates duplicate orders | Add idempotency key support | /godmode:build | Add idempotency layer |
| HIGH (15) | 100x traffic spike crashes the service | Add rate limiting + circuit breaker | /godmode:build + /godmode:ops | Implement rate limiter, set up auto-scaling |
| HIGH (12) | Schema migration breaks in-flight requests | Blue-green deployment with backward-compat schema | /godmode:plan + /godmode:ops | Plan migration strategy |
| ... | ... | ... | ... | ... |
```

Mitigation categories:
- **Code fix** → `/godmode:build` — needs implementation
- **Test coverage** → `/godmode:test` — needs test cases
- **Infrastructure** → `/godmode:ops` — needs deployment/config changes
- **Design revision** → `/godmode:think` — needs architectural rethink
- **Monitoring** → `/godmode:ops` — needs alerts/dashboards
- **Documentation** → needs runbook or incident response plan

### Step 5: Auto-Generate Test Case Skeletons
For every scenario with priority >= 12 (HIGH and CRITICAL), generate a test case skeleton in the project's test framework. Detect the framework from the codebase (Jest, pytest, Go testing, RSpec, etc.).

```
AUTO-GENERATED TEST SKELETONS:

// Detected framework: <Jest|pytest|Go testing|RSpec|etc.>
// Generated from: /godmode:scenario on <date>
// Total: <N> test cases for <N> high-priority scenarios

describe('<Feature> — Scenario Tests', () => {

  // CRITICAL: Priority 20 — Expired token returns 500 instead of 401
  it('should return 401 when token is expired', async () => {
    // ARRANGE: Create a token that expired 1 minute ago
    // ACT: Send request with expired token to protected endpoint
    // ASSERT: Response status is 401, body contains "token expired" message
    // ASSERT: No side effects occurred (no data modified)
    throw new Error('TODO: implement this test');
  });

  // CRITICAL: Priority 16 — Double-submit creates duplicate orders
  it('should handle duplicate order submission idempotently', async () => {
    // ARRANGE: Create a valid order payload with idempotency key
    // ACT: Submit the same order twice within 100ms
    // ASSERT: Only one order is created
    // ASSERT: Second response returns the same order ID
    throw new Error('TODO: implement this test');
  });

  // HIGH: Priority 15 — Rate limit bypass via header manipulation
  it('should enforce rate limits regardless of X-Forwarded-For header', async () => {
    // ARRANGE: Set up rate limit at 100 req/min
    // ACT: Send 101 requests, rotating X-Forwarded-For header
    // ASSERT: 101st request is rejected with 429
    throw new Error('TODO: implement this test');
  });

  // ... one skeleton per HIGH/CRITICAL scenario
});
```

Rules for test skeletons:
- Use the ARRANGE / ACT / ASSERT pattern in comments
- Include the priority score and scenario description as a comment above each test
- Use `throw new Error('TODO: implement this test')` (or language equivalent) so they fail visibly until implemented
- Group tests by dimension
- Save to `tests/scenarios/<feature-name>.scenario.test.<ext>`

### Step 6: Prioritize for Testing
Sort all scenarios by priority score and present the final testing plan:

```
MUST TEST — CRITICAL (priority 20-25):
1. <scenario> (priority: <score>) → test: <test file>:<line>
2. <scenario> (priority: <score>) → test: <test file>:<line>

MUST TEST — HIGH (priority 12-19):
3. <scenario> (priority: <score>) → test: <test file>:<line>
4. <scenario> (priority: <score>) → test: <test file>:<line>

SHOULD TEST — MEDIUM (priority 6-11):
5. <scenario> (priority: <score>) → test: <description, no skeleton yet>
6. <scenario> (priority: <score>) → test: <description, no skeleton yet>

BACKLOG — LOW (priority 1-5):
7. <scenario> (priority: <score>) → test: <description, defer>
```

### Step 7: Commit and Transition
1. Save scenarios as `docs/scenarios/<feature-name>-scenarios.md`
2. Save test skeletons as `tests/scenarios/<feature-name>.scenario.test.<ext>`
3. Commit: `"scenario: <feature> — <N> scenarios, <N> critical, <N> test skeletons"`
4. Suggest:
   - If no plan yet: "Run `/godmode:plan` — these scenarios will inform the task breakdown."
   - If plan exists: "Run `/godmode:test` — use these scenarios and test skeletons to write comprehensive tests."
   - If critical mitigations need design work: "Run `/godmode:think` — <N> critical scenarios need architectural decisions."

## Key Behaviors

1. **Be specific, not generic.** "User enters bad data" is worthless. "User enters a 10MB string in the name field" is a scenario.
2. **Include expected behavior.** Every scenario must state what SHOULD happen, not just what might go wrong.
3. **Severity is quantified.** Use likelihood x impact scoring. No hand-wavy "HIGH/MEDIUM/LOW" without numbers backing it.
4. **Connect to tests and skills.** Every high-priority scenario maps to both a test skeleton and a godmode skill that mitigates it. Scenarios without mitigations are worries, not plans.
5. **Don't boil the ocean.** 30-50 scenarios is the target. Going to 200 scenarios helps nobody. Focus on the ones that matter.
6. **Test skeletons are mandatory for priority >= 12.** Every critical/high scenario gets a runnable test skeleton. Not a description — a skeleton with ARRANGE/ACT/ASSERT comments that fails visibly until implemented.
7. **3-5 specific scenarios per dimension, not categories.** "SQL injection" is a category. "SQL injection via the search endpoint's `q` parameter using UNION SELECT" is a scenario.

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
| # | Scenario | L | I | Priority | Expected |
|---|----------|---|---|----------|----------|
| 1 | Single item, valid payment, in-stock | 5 | 1 | 5 | 201, order created |
| 2 | Multiple items, valid payment, all in-stock | 5 | 1 | 5 | 201, all inventory decremented |

## Dimension 2: Empty / Null / Missing
| # | Scenario | L | I | Priority | Expected |
|---|----------|---|---|----------|----------|
| 3 | Empty items array | 4 | 3 | 12 | 400, "at least one item required" |
| 4 | Missing shippingAddress | 4 | 3 | 12 | 400, "shipping address required" |
| 5 | Missing paymentMethodId | 4 | 3 | 12 | 400, "payment method required" |
| 6 | null quantity | 3 | 3 | 9 | 400, "quantity must be a positive integer" |

## Dimension 6: Concurrency
| # | Scenario | L | I | Priority | Expected |
|---|----------|---|---|----------|----------|
| 15 | 1 item left, 3 users buy simultaneously | 3 | 5 | 15 | Only 1 order succeeds, others get 409 |
| 16 | Double-click submit button | 4 | 4 | 16 | Idempotency key prevents duplicate order |

## Mitigation Map (for HIGH/CRITICAL)
| Scenario | Mitigation | Skill |
|----------|------------|-------|
| #15 Inventory race | Optimistic locking on inventory | /godmode:build |
| #16 Double-submit | Idempotency key middleware | /godmode:build |
| #3-5 Missing fields | Input validation middleware | /godmode:build |

## Test Skeletons (generated)
describe('POST /api/orders — Scenario Tests', () => {
  it('should reject double-submit with same idempotency key (priority: 16)', async () => {
    // ARRANGE: Create valid order payload with idempotency key
    // ACT: Submit same order twice within 100ms
    // ASSERT: First returns 201, second returns 200 with same orderId
    throw new Error('TODO: implement');
  });
  ...
});
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
