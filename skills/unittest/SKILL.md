---
name: unittest
description: |
  Unit testing mastery skill. Activates when user needs to write high-quality, isolated unit tests with proper structure, mocking strategies, and confidence-driven coverage. Covers Arrange-Act-Assert and Given-When-Then patterns, test doubles (mocks, stubs, spies, fakes), property-based testing with fast-check/Hypothesis, mutation testing for test quality validation, and framework-specific guidance for Jest, Vitest, pytest, Go testing, JUnit, and more. Triggers on: /godmode:unittest, "write unit tests", "mock this dependency", "property-based test", "mutation testing", or when /godmode:test needs deep unit test guidance.
---

# Unit Test — Unit Testing Mastery

## When to Activate
- User invokes `/godmode:unittest`
- User asks "write unit tests for X" or "test this function in isolation"
- User asks about mocking strategies or test doubles
- User wants property-based testing or generative tests
- User asks about mutation testing or test quality
- `/godmode:test` needs specialized unit testing guidance
- User asks "should I mock this?" or "how do I test this in isolation?"

## Workflow

### Step 1: Analyze the Unit Under Test
Understand what you are testing and its dependency graph:

```bash
# Identify the target module/function
<read the source file>

# Map dependencies — what does this unit import/call?
<trace imports and injected dependencies>

# Check for existing tests
find . -name "*<module_name>*test*" -o -name "*<module_name>*spec*"
```

```
UNIT ANALYSIS:
Target: <file>:<function/class/method>
Language: <language>
Framework: <Jest | Vitest | pytest | Go testing | JUnit | xUnit | etc.>
Dependencies:
  Internal: <list of internal modules called>
  External: <list of external services/APIs/DBs called>
  Side effects: <file I/O, network, time, randomness>
Pure logic: <YES/NO — does it have side effects?>
Current tests: <N existing tests | NONE>
```

### Step 2: Choose Test Structure Pattern

#### Arrange-Act-Assert (AAA) — Default for most unit tests
```
ARRANGE: Set up the preconditions (inputs, mocks, state)
ACT:     Execute the unit under test (single action)
ASSERT:  Verify the outcome (single logical assertion)
```

Use AAA when:
- Testing a pure function with clear input/output
- Testing a method that returns a value
- Testing state changes after an action
- The majority of unit tests

```typescript
// Jest/Vitest — AAA pattern
it('calculates compound interest correctly', () => {
  // Arrange
  const principal = 1000;
  const rate = 0.05;
  const years = 10;

  // Act
  const result = calculateCompoundInterest(principal, rate, years);

  // Assert
  expect(result).toBeCloseTo(1628.89, 2);
});
```

```python
# pytest — AAA pattern
def test_calculates_compound_interest_correctly():
    # Arrange
    principal = 1000
    rate = 0.05
    years = 10

    # Act
    result = calculate_compound_interest(principal, rate, years)

    # Assert
    assert result == pytest.approx(1628.89, rel=1e-2)
```

```go
// Go — AAA pattern
func TestCalculateCompoundInterest(t *testing.T) {
    // Arrange
    principal := 1000.0
    rate := 0.05
    years := 10

    // Act
    result := CalculateCompoundInterest(principal, rate, years)

    // Assert
    if math.Abs(result-1628.89) > 0.01 {
        t.Errorf("expected ~1628.89, got %f", result)
    }
}
```

#### Given-When-Then (GWT) — For behavior-focused tests
```
GIVEN: A specific starting context (preconditions and state)
WHEN:  An event or action occurs
THEN:  A particular outcome is expected
```

Use GWT when:
- Testing business logic with domain-specific behavior
- Writing BDD-style tests that non-developers can read
- The test describes a scenario, not just input/output
- Tests need to communicate intent to stakeholders

```typescript
// Jest/Vitest — GWT pattern
describe('ShoppingCart', () => {
  describe('when applying a discount coupon', () => {
    it('reduces total by the coupon percentage', () => {
      // Given a cart with items totaling $100
      const cart = new ShoppingCart();
      cart.addItem({ name: 'Widget', price: 100 });

      // When a 20% discount coupon is applied
      cart.applyCoupon({ code: 'SAVE20', percentage: 20 });

      // Then the total should be $80
      expect(cart.getTotal()).toBe(80);
    });

    it('rejects expired coupons', () => {
      // Given a cart with items
      const cart = new ShoppingCart();
      cart.addItem({ name: 'Widget', price: 100 });

      // When an expired coupon is applied
      const expiredCoupon = { code: 'OLD', percentage: 10, expiresAt: pastDate() };

      // Then it should throw a CouponExpiredError
      expect(() => cart.applyCoupon(expiredCoupon)).toThrow(CouponExpiredError);
    });
  });
});
```

### Step 3: Apply Mocking Strategy

#### The Mocking Decision Framework

```
SHOULD I MOCK THIS?

                    ┌─────────────────────┐
                    │  Is it an external   │
                    │  service/API/DB?     │
                    └──────┬──────────────┘
                           │
                    YES    │    NO
                    ▼      │    ▼
              ┌──────────┐ │ ┌──────────────────┐
              │  MOCK IT │ │ │ Is it slow (>50ms)│
              └──────────┘ │ │ or non-deterministic?│
                           │ └──────┬───────────┘
                           │   YES  │    NO
                           │   ▼    │    ▼
                           │ ┌────────┐ ┌──────────────┐
                           │ │MOCK IT │ │ Is it a      │
                           │ └────────┘ │ collaborator  │
                           │            │ with complex  │
                           │            │ setup?        │
                           │            └──────┬───────┘
                           │              YES  │    NO
                           │              ▼    │    ▼
                           │     ┌──────────┐ ┌───────────────┐
                           │     │CONSIDER  │ │ USE THE REAL  │
                           │     │MOCKING   │ │ IMPLEMENTATION│
                           │     └──────────┘ └───────────────┘
```

#### Test Double Types

**1. Stub — Returns canned answers**
When you need a dependency to return a specific value but do not care how it is called.

```typescript
// Stub: always returns a fixed user
const userRepo = { findById: jest.fn().mockReturnValue({ id: 1, name: 'Alice' }) };
const service = new UserService(userRepo);
const user = service.getUser(1);
expect(user.name).toBe('Alice');
```

**2. Mock — Verifies interactions**
When you need to assert that a dependency was called correctly.

```typescript
// Mock: verify the email service was called with correct args
const emailService = { send: jest.fn() };
const orderService = new OrderService(emailService);
orderService.placeOrder({ userId: 1, items: ['widget'] });
expect(emailService.send).toHaveBeenCalledWith(
  expect.objectContaining({ to: 'user@example.com', subject: 'Order Confirmation' })
);
```

**3. Spy — Wraps the real implementation**
When you want the real behavior but need to observe calls.

```typescript
// Spy: real implementation runs, but you can verify calls
const logger = new Logger();
const spy = jest.spyOn(logger, 'info');
processOrder(order, logger);
expect(spy).toHaveBeenCalledWith('Order processed', { orderId: order.id });
spy.mockRestore();
```

**4. Fake — Simplified working implementation**
When a real implementation is too complex but you need realistic behavior.

```typescript
// Fake: in-memory implementation of a repository
class FakeUserRepository implements UserRepository {
  private users: Map<string, User> = new Map();

  async save(user: User): Promise<void> {
    this.users.set(user.id, { ...user });
  }

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) ?? null;
  }
}
```

```python
# pytest — Fake with dataclass
@dataclass
class FakeUserRepository:
    _users: dict = field(default_factory=dict)

    def save(self, user):
        self._users[user.id] = user

    def find_by_id(self, user_id):
        return self._users.get(user_id)
```

**5. Dummy — Fills a parameter slot**
When a parameter is required but never used in the test.

```typescript
// Dummy: never used, just satisfies the type signature
const dummyLogger = {} as Logger;
const validator = new InputValidator(dummyLogger);
expect(validator.isValid('hello')).toBe(true);
```

#### When NOT to Mock

```
DO NOT MOCK:
- Pure functions with no side effects (just call them)
- Value objects and data structures (use real ones)
- The unit under test itself (you are testing it, not mocking it)
- Everything — over-mocking makes tests pass but proves nothing
- Internal implementation details (mock boundaries, not internals)
- Simple utility functions (Math.max, string formatting)
```

#### Framework-Specific Mocking

**Jest / Vitest:**
```typescript
// Module mock
jest.mock('./database', () => ({
  query: jest.fn().mockResolvedValue([{ id: 1 }]),
}));

// Manual mock: __mocks__/database.ts
// Automatic mock: jest.mock('./database') — all exports become jest.fn()

// Timer mock
jest.useFakeTimers();
setTimeout(callback, 1000);
jest.advanceTimersByTime(1000);
expect(callback).toHaveBeenCalled();
```

**pytest:**
```python
# monkeypatch (built-in)
def test_fetches_config(monkeypatch):
    monkeypatch.setenv("API_KEY", "test-key-123")
    config = load_config()
    assert config.api_key == "test-key-123"

# unittest.mock
from unittest.mock import patch, MagicMock

@patch('myapp.services.email.send')
def test_sends_welcome_email(mock_send):
    register_user("alice@example.com")
    mock_send.assert_called_once_with(to="alice@example.com", template="welcome")

# pytest-mock (wrapper around unittest.mock)
def test_sends_email(mocker):
    mock_send = mocker.patch('myapp.services.email.send')
    register_user("alice@example.com")
    mock_send.assert_called_once()
```

**Go:**
```go
// Interface-based mocking (idiomatic Go)
type MockUserStore struct {
    FindByIDFunc func(id string) (*User, error)
}

func (m *MockUserStore) FindByID(id string) (*User, error) {
    return m.FindByIDFunc(id)
}

func TestGetUser(t *testing.T) {
    store := &MockUserStore{
        FindByIDFunc: func(id string) (*User, error) {
            return &User{ID: id, Name: "Alice"}, nil
        },
    }
    svc := NewUserService(store)
    user, err := svc.GetUser("123")
    assert.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
}
```

**JUnit 5 + Mockito:**
```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock private UserRepository userRepo;
    @Mock private EmailService emailService;
    @InjectMocks private OrderService orderService;

    @Test
    void sendsConfirmationEmail() {
        when(userRepo.findById(1L)).thenReturn(Optional.of(new User("alice@example.com")));

        orderService.placeOrder(1L, List.of("widget"));

        verify(emailService).send(argThat(email ->
            email.getTo().equals("alice@example.com") &&
            email.getSubject().contains("Confirmation")
        ));
    }
}
```

### Step 4: Property-Based Testing

Property-based testing generates hundreds of random inputs to find edge cases you would never think to write manually.

#### When to Use Property-Based Tests
```
USE PROPERTY-BASED TESTS WHEN:
- A function should hold a mathematical property (commutative, associative, idempotent)
- Serialization/deserialization roundtrips should be lossless
- A function has a wide input domain (strings, numbers, dates, lists)
- You want to find edge cases in parsers, validators, or encoders
- An inverse function exists (encode/decode, compress/decompress)
- Sorting, filtering, or transformation preserves invariants

DO NOT USE WHEN:
- The expected output depends on specific business rules (use example-based tests)
- The function has very few valid inputs (just enumerate them)
- The property is trivially "it doesn't crash" (too weak to be useful)
```

#### Common Property Patterns

**1. Roundtrip / Inverse**
```
For all x: decode(encode(x)) === x
```

```typescript
// fast-check (JavaScript/TypeScript)
import fc from 'fast-check';

test('JSON roundtrip preserves data', () => {
  fc.assert(
    fc.property(
      fc.jsonValue(),
      (value) => {
        const roundtripped = JSON.parse(JSON.stringify(value));
        expect(roundtripped).toEqual(value);
      }
    )
  );
});
```

```python
# Hypothesis (Python)
from hypothesis import given
from hypothesis import strategies as st

@given(st.text())
def test_encode_decode_roundtrip(text):
    encoded = base64_encode(text)
    decoded = base64_decode(encoded)
    assert decoded == text
```

**2. Invariant Preservation**
```
For all inputs: some_property(transform(input)) holds
```

```typescript
test('sorting preserves all elements', () => {
  fc.assert(
    fc.property(
      fc.array(fc.integer()),
      (arr) => {
        const sorted = mySort([...arr]);
        // Same length
        expect(sorted.length).toBe(arr.length);
        // Same elements (as multiset)
        expect(sorted.sort()).toEqual([...arr].sort());
        // Actually sorted
        for (let i = 1; i < sorted.length; i++) {
          expect(sorted[i]).toBeGreaterThanOrEqual(sorted[i - 1]);
        }
      }
    )
  );
});
```

```python
@given(st.lists(st.integers()))
def test_sorting_preserves_all_elements(lst):
    sorted_lst = my_sort(lst[:])
    assert len(sorted_lst) == len(lst)
    assert sorted(sorted_lst) == sorted(lst)
    assert all(sorted_lst[i] <= sorted_lst[i+1] for i in range(len(sorted_lst)-1))
```

**3. Idempotence**
```
For all x: f(f(x)) === f(x)
```

```typescript
test('formatting is idempotent', () => {
  fc.assert(
    fc.property(
      fc.string(),
      (input) => {
        const once = formatPhoneNumber(input);
        const twice = formatPhoneNumber(once);
        expect(twice).toBe(once);
      }
    )
  );
});
```

**4. Oracle / Reference Implementation**
```
For all inputs: fast_implementation(x) === reference_implementation(x)
```

```python
@given(st.integers(min_value=0, max_value=20))
def test_fast_fibonacci_matches_naive(n):
    assert fast_fibonacci(n) == naive_fibonacci(n)
```

**5. Commutativity / Associativity**
```
For all a, b: f(a, b) === f(b, a)           # commutative
For all a, b, c: f(f(a, b), c) === f(a, f(b, c))  # associative
```

```typescript
test('merge is commutative', () => {
  fc.assert(
    fc.property(
      fc.dictionary(fc.string(), fc.integer()),
      fc.dictionary(fc.string(), fc.integer()),
      (a, b) => {
        expect(merge(a, b)).toEqual(merge(b, a));
      }
    )
  );
});
```

#### Shrinking
Property-based frameworks automatically shrink failing inputs to the minimal reproduction:

```
SHRINKING EXAMPLE:
Original failing input: [847, -23, 0, 991, -7, 42, 0, 3]
After shrinking:        [0, -1]
                        ^^^^^^ minimal case that still fails
```

Always examine the shrunk output — it reveals the exact edge case.

### Step 5: Mutation Testing for Test Quality

Mutation testing answers: "If I inject a bug, will my tests catch it?"

```
MUTATION TESTING PROCESS:
1. Run all tests (must pass — green baseline)
2. Mutate the source code (inject one small bug)
3. Run tests again
4. If tests FAIL: the mutant is KILLED (good — tests caught the bug)
5. If tests PASS: the mutant SURVIVED (bad — tests missed the bug)
6. Repeat for hundreds of mutations
7. Mutation score = killed / total mutations

MUTATION SCORE:
  > 80%: STRONG tests — most bugs would be caught
  60-80%: MODERATE tests — significant gaps exist
  < 60%: WEAK tests — tests provide false confidence
```

#### Common Mutation Types
```
MUTATION OPERATORS:
- Arithmetic: + → -, * → /, % → *
- Comparison: > → >=, == → !=, < → <=
- Logical: && → ||, ! → (remove)
- Boundary: i < n → i <= n, i > 0 → i >= 0
- Return: return x → return 0, return true → return false
- Removal: delete an entire statement
- Constant: 0 → 1, "" → "mutated", null → non-null
```

#### Mutation Testing Tools

```bash
# JavaScript/TypeScript — Stryker
npx stryker run

# Python — mutmut
mutmut run
mutmut results

# Java — PIT (pitest)
mvn org.pitest:pitest-maven:mutationCoverage

# Go — go-mutesting
go-mutesting ./...
```

#### Interpreting Mutation Results
```
SURVIVING MUTANT ANALYSIS:
Mutant: Changed `>` to `>=` on line 42 of calculator.ts
  Original: if (amount > limit)
  Mutated:  if (amount >= limit)
  Status: SURVIVED — no test checks the exact boundary

Action: Add test for exact boundary condition:
  it('allows amount exactly at the limit', () => {
    expect(checkLimit(100, 100)).toBe(true);  // boundary test
  });
```

### Step 6: Test Naming and Organization

#### Naming Conventions

```
NAMING RULES:
1. Describe the BEHAVIOR, not the method name
2. Include the CONDITION (when/given)
3. Include the EXPECTED OUTCOME (then/should)
4. Read like a sentence a non-developer can understand

PATTERN: <action/behavior> <condition> <expected outcome>

GOOD:
  "returns empty array when no items match the filter"
  "throws InsufficientFundsError when balance is below withdrawal amount"
  "retries exactly 3 times before giving up on network failure"
  "sends welcome email after successful registration"
  "preserves insertion order when iterating over entries"

BAD:
  "test processOrder"              — what about processOrder?
  "test1"                          — completely meaningless
  "should work correctly"          — what does "correctly" mean?
  "handles edge case"              — what edge case?
  "validates input"                — what input? what validation?
```

#### Test File Organization

```
PROJECT STRUCTURE:
src/
  services/
    order-service.ts
    payment-service.ts
  utils/
    validation.ts

tests/
  unit/                            # Mirror source structure
    services/
      order-service.test.ts
      payment-service.test.ts
    utils/
      validation.test.ts
  integration/                     # Separate integration tests
    ...
  fixtures/                        # Shared test data
    order-fixtures.ts
    user-fixtures.ts
  helpers/                         # Shared test utilities
    test-factory.ts
    assertions.ts
```

#### Test Organization Within a File

```
ORDER OF TESTS:
1. Happy path (normal successful operation)
2. Alternative paths (other valid scenarios)
3. Edge cases (boundary values, empty inputs)
4. Error cases (invalid inputs, failures)
5. Concurrency/timing (if applicable)
```

```typescript
describe('OrderService', () => {
  describe('placeOrder', () => {
    // 1. Happy path
    it('creates order with valid items and sufficient stock', () => { ... });

    // 2. Alternative paths
    it('applies bulk discount for orders over 100 items', () => { ... });
    it('creates backorder when stock is low but not zero', () => { ... });

    // 3. Edge cases
    it('handles order with exactly one item', () => { ... });
    it('handles maximum allowed items (10000)', () => { ... });
    it('rounds total to 2 decimal places', () => { ... });

    // 4. Error cases
    it('throws OutOfStockError when item has zero stock', () => { ... });
    it('throws ValidationError for empty items array', () => { ... });
    it('throws ValidationError for negative quantity', () => { ... });

    // 5. Concurrency
    it('prevents double-ordering the last item in stock', () => { ... });
  });
});
```

### Step 7: Coverage vs Confidence Trade-offs

```
COVERAGE REALITY CHECK:

Line coverage: "Was this line executed?"
  - Easy to achieve, low signal
  - 100% line coverage does NOT mean correct code
  - A test that calls a function without asserting anything gets line coverage

Branch coverage: "Was every if/else path taken?"
  - Better signal than line coverage
  - Still misses value-level bugs (off-by-one, wrong constant)

Mutation score: "Would tests catch injected bugs?"
  - Highest signal — directly measures test effectiveness
  - More expensive to compute
  - The real measure of test quality

COVERAGE TARGETS (pragmatic):
  Critical business logic:  > 90% branch + > 80% mutation score
  Standard application code: > 80% branch coverage
  Utility/helper functions:  > 70% line coverage
  Generated/boilerplate code: skip — not worth testing

THE CONFIDENCE RULE:
Ask: "If a junior developer changed this line, would a test fail?"
If NO: you need a test. If YES: you have coverage where it matters.
```

```
COVERAGE ANTI-PATTERNS:
- Writing tests to hit lines, not to verify behavior
- Testing getters/setters for coverage numbers
- Ignoring files from coverage to hit a target
- 100% coverage with zero assertions
- Testing framework code instead of your code
```

### Step 8: Run, Verify, and Report

```bash
# Run unit tests
<framework-specific test command>

# Run with coverage
<framework-specific coverage command>

# Run mutation testing (if configured)
<framework-specific mutation command>
```

```
UNIT TEST REPORT:
Target: <file>:<function/class>
Tests written: <N>
  - Example-based: <N>
  - Property-based: <N>
Mocking strategy:
  - Stubs: <N> (for <what>)
  - Mocks: <N> (for <what>)
  - Fakes: <N> (for <what>)
  - Real implementations: <N>
All passing: <YES/NO>
Line coverage: <X>% → <Y>%
Branch coverage: <X>% → <Y>%
Mutation score: <X>% (if available)
Confidence: <HIGH | MEDIUM | LOW>
```

### Step 9: Commit and Transition
1. Commit tests: `"test(unit): <module> — <N> tests, <coverage>% branch coverage"`
2. If mutation score available: include in commit message
3. If property-based tests found new edge cases: flag them for the developer
4. If mocking is heavy: recommend integration tests via `/godmode:integration`

## Key Behaviors

1. **Isolate completely.** A unit test that touches the database, network, or filesystem is an integration test. Mock all external boundaries.
2. **One behavior per test.** A test with 5 assertions is 5 tests crammed into one. Each test verifies one logical behavior. Multiple `expect` calls are fine if they assert one conceptual thing.
3. **Mock at the boundary, not internally.** Mock the database client, not the service layer. Mock the HTTP client, not the controller. Mock the edges, test the middle.
4. **Property tests complement example tests.** Property tests find edge cases; example tests document expected behavior. Use both.
5. **Mutation testing reveals false confidence.** High coverage with low mutation score means tests execute code without actually verifying correctness.
6. **Test the contract, not the implementation.** If a refactor breaks your tests but not the behavior, your tests are too coupled to implementation details.
7. **Fast is non-negotiable.** The entire unit test suite should run in seconds. If it takes minutes, some tests are not unit tests.

## Example Usage

### Writing unit tests for a service
```
User: /godmode:unittest Write unit tests for the PaymentService

UnitTest: Analyzing PaymentService...

Found: src/services/payment-service.ts
Dependencies:
  - PaymentGateway (external API) → MOCK
  - UserRepository (database) → FAKE
  - Logger (side effect) → SPY
  - CurrencyConverter (pure logic) → REAL

Creating: tests/unit/services/payment-service.test.ts

describe('PaymentService', () => {
  describe('processPayment', () => {
    // Happy path
    it('charges the payment gateway and returns confirmation', ...);
    it('records the transaction in user history', ...);

    // Alternative paths
    it('converts currency before charging when currency differs', ...);
    it('applies tax for taxable regions', ...);

    // Edge cases
    it('handles zero-amount payments (free tier)', ...);
    it('rounds to 2 decimal places before charging', ...);

    // Errors
    it('throws PaymentDeclinedError when gateway declines', ...);
    it('throws InsufficientFundsError when balance too low', ...);
    it('does not record transaction when gateway fails', ...);

    // Property-based
    it('charge amount is always positive after conversion', ...);
    it('roundtrip: amount charged equals amount recorded', ...);
  });
});

Writing 11 tests with 3 stubs, 1 fake, 1 spy...
```

### Adding property-based tests
```
User: /godmode:unittest --property Add property tests for the URL parser

UnitTest: Analyzing URL parser...

Properties identified:
1. Roundtrip: parse(format(url)) === url
2. Invariant: parsed URL always has a protocol
3. Idempotence: parse(parse(url).href) === parse(url)

Writing 3 property-based tests with fast-check...
  - 100 random URLs per property
  - Custom arbitraries for valid URL components
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Analyze and write comprehensive unit tests |
| `--for <file>` | Write unit tests for a specific file |
| `--mock-strategy` | Analyze dependencies and recommend mocking approach |
| `--property` | Focus on property-based tests |
| `--mutation` | Run mutation testing and fill gaps |
| `--coverage` | Focus on increasing branch coverage |
| `--framework <name>` | Target a specific framework (jest, vitest, pytest, go, junit) |
| `--refactor` | Refactor existing tests for better structure and naming |

## HARD RULES

1. **NEVER mock everything.** Mock boundaries (APIs, databases, external services), use real implementations for internal collaborators.
2. **NEVER test implementation details.** If your test breaks when you rename a private method, it is testing implementation, not behavior.
3. **NEVER share mutable state between tests.** Every test gets fresh state. Shared state causes ordering bugs and flaky failures.
4. **NEVER chase 100% coverage as a goal.** 80% meaningful coverage beats 100% superficial coverage. Focus on critical paths and business logic.
5. **NEVER write slow unit tests.** If a single unit test takes more than 100ms, it is probably hitting real I/O. Mock it or move it to integration tests.
6. **ALWAYS use Arrange-Act-Assert structure.** Every test has three clear phases. No exceptions.
7. **ALWAYS name tests as behavior descriptions.** `should return empty array when no items match filter` not `test1` or `testFilter`.
8. **ALWAYS investigate surviving mutants.** Each surviving mutant is a potential bug your tests would miss.

## Iteration Protocol

For large-scale unit test writing across a codebase:

```
current_file = 0
files_to_test = [list of source files needing tests]

WHILE current_file < len(files_to_test):
  file = files_to_test[current_file]
  1. Analyze file: identify public API, dependencies, edge cases
  2. Design test cases: happy path, error cases, boundary conditions
  3. Write tests using Arrange-Act-Assert
  4. Run tests -- confirm all pass
  5. Check coverage for this file -- identify untested branches
  current_file += 1
  Report: "Tests for {current_file}/{len(files_to_test)}: {file} -- {test_count} tests, {coverage}% coverage"

AFTER all files tested:
  Run mutation testing on critical modules
  Report overall coverage and surviving mutants
```

## Multi-Agent Dispatch

For comprehensive test suite creation, dispatch parallel agents:

```
DISPATCH 3 agents:
  Agent 1 (worktree: test-services):   Unit tests for service/business logic layer
  Agent 2 (worktree: test-controllers): Unit tests for controllers/handlers/API layer
  Agent 3 (worktree: test-utils):       Unit tests for utilities, helpers, and shared modules

MERGE order: Agent 3 (utils) first, then Agent 1 (services), then Agent 2 (controllers)
CONFLICT resolution: Shared test fixtures defined by Agent 3 are authoritative
```

## Anti-Patterns

- **Do NOT mock everything.** If you mock every dependency, you are testing that your mocks work, not that your code works. Mock boundaries, use real implementations for internal collaborators.
- **Do NOT test implementation details.** If your test breaks when you rename a private method or reorder internal steps, it is testing implementation, not behavior.
- **Do NOT share mutable state between tests.** Every test gets fresh state. Shared mutable state causes test ordering bugs and flaky failures.
- **Do NOT use `any` or wildcard matchers everywhere.** `expect(mock).toHaveBeenCalledWith(expect.anything())` proves nothing. Be specific about what matters.
- **Do NOT write property-based tests with trivial properties.** "It doesn't throw" is rarely a useful property. Express meaningful invariants.
- **Do NOT ignore surviving mutants.** Each surviving mutant is a potential bug your tests would miss. Investigate and add targeted tests.
- **Do NOT chase 100% coverage.** Coverage is a tool, not a goal. 80% meaningful coverage beats 100% superficial coverage every time. Focus on critical paths, business logic, and error handling.
- **Do NOT write slow unit tests.** If a single unit test takes more than 100ms, it is probably hitting real I/O. Mock it or move it to integration tests.
