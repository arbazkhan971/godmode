# Debug Workflow — Full Reference

## Investigation Technique Selection Guide

Choose the right technique based on the symptoms:

| Symptom | Best Technique | Why |
|---------|---------------|-----|
| "It used to work" | Binary Search (git bisect) | Find the exact commit that broke it |
| Complex failure, many moving parts | Minimal Reproduction | Simplify until the cause is obvious |
| Stack trace points to wrong area | Trace Analysis | Follow the actual execution path |
| Output is wrong but no error | State Inspection | Find where state diverges from expected |
| Works in isolation, fails in integration | Dependency Isolation | Find which integration is faulty |
| Recent changes, unclear which caused it | Diff Analysis | Review changes systematically |
| Nothing obvious, code is complex | Rubber Duck | Explain every line until you find it |

## Technique 1: Binary Search (git bisect) — Detailed

### When to Use
- You have a known-good commit (it worked before)
- You have a known-bad commit (it's broken now)
- The bug is deterministic (same input → same failure)

### Step-by-Step
```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark last known good commit
# (find it with: git log --oneline | less)
git bisect good <commit-sha>

# Automated bisect (best approach):
git bisect run <command-that-exits-0-on-pass>

# Example: test command as the run command
git bisect run npm test -- --grep "creates user"

# When done, bisect reports the first bad commit
# Reset when finished:
git bisect reset
```

### Tips
- The test command MUST exit 0 for "good" and non-zero for "bad"
- For complex tests, write a shell script:
  ```bash
  #!/bin/bash
  # bisect-test.sh
  npm test -- --grep "creates user" 2>&1 > /dev/null
  exit $?
  ```
- bisect skips merge commits by default — this is usually what you want
- If a commit doesn't compile, use `git bisect skip`

## Technique 2: Minimal Reproduction — Detailed

### When to Use
- The failure happens in a complex context (large test suite, complex data)
- You need to understand which component is responsible
- The error message is unhelpful or misleading

### Step-by-Step
```
1. Start with the full failing scenario
   → "POST /api/orders with 15 items, 3 discounts, 2 shipping options fails"

2. Remove one element at a time:
   → Remove shipping options: still fails
   → Remove discounts: still fails
   → Reduce to 1 item: still fails
   → Remove optional fields: PASSES

3. Identify the threshold:
   → With address field: passes
   → Without address field: fails
   → With null address: fails
   → With empty string address: passes

4. Minimal reproduction:
   → "POST /api/orders with null address field fails"
   → This is a null handling bug in the address validator
```

### Tips
- Remove LARGE chunks first (halve the input, not reduce by one)
- Keep a log of what you've tried
- When you find the minimal case, the fix is usually obvious

## Technique 3: Trace Analysis — Detailed

### When to Use
- You have an error/stack trace but it points to a generic location
- The error is in library code and you need to find the root cause in your code
- You need to understand the execution flow

### Step-by-Step
```
1. Read the stack trace bottom-to-top:
   Error: Cannot read property 'id' of undefined
     at UserService.getProfile (src/services/user.ts:47)
     at UserController.profile (src/controllers/user.ts:23)
     at authMiddleware (src/middleware/auth.ts:15)
     at Layer.handle (node_modules/express/lib/router/layer.js:95)

2. Identify entry points (your code):
   - authMiddleware (src/middleware/auth.ts:15) ← first entry
   - UserController.profile (src/controllers/user.ts:23)
   - UserService.getProfile (src/services/user.ts:47) ← crash point

3. Add strategic logging at each entry point:
   auth.ts:14  → console.log('auth: req.user =', req.user);
   user.ts:22  → console.log('controller: userId =', userId);
   user.ts:46  → console.log('service: user =', user);

4. Run again and read the trace:
   auth: req.user = { id: 1, email: 'test@test.com' }
   controller: userId = 1
   service: user = undefined  ← FOUND IT

5. The user service query returned undefined
   → Check the query: findById(userId) where userId = 1
   → But the database was migrated and user 1 no longer exists
   → Root cause: test fixtures not updated after migration
```

### Tips
- Log BEFORE the line that crashes, not after
- Log actual values, not just "reached here"
- Remove all debug logging after investigation

## Technique 4: State Inspection — Detailed

### When to Use
- The output is wrong but there's no error
- A calculation returns unexpected results
- A workflow produces the wrong final state

### Step-by-Step
```
1. Define expected state at each checkpoint:
   After step 1: cart = { items: [A, B], total: $30 }
   After step 2: cart = { items: [A, B], discount: $5, total: $25 }
   After step 3: order = { items: [A, B], total: $25, tax: $2.50 }

2. Add state dumps at each checkpoint:
   console.log('CHECKPOINT 1:', JSON.stringify(cart, null, 2));
   console.log('CHECKPOINT 2:', JSON.stringify(cart, null, 2));
   console.log('CHECKPOINT 3:', JSON.stringify(order, null, 2));

3. Run and compare:
   CHECKPOINT 1: { items: [A, B], total: 30 } ✓
   CHECKPOINT 2: { items: [A, B], discount: 5, total: 30 } ✗ total should be 25
   CHECKPOINT 3: { items: [A, B], total: 30, tax: 3.00 } ✗ cascading error

4. The bug is between checkpoint 1 and 2:
   → The discount is applied but the total isn't recalculated
   → Root cause: applyDiscount() sets the discount but doesn't update the total
```

## Technique 5: Dependency Isolation — Detailed

### When to Use
- Code works in unit tests but fails in integration
- External services are suspected of causing the issue
- The bug only appears in certain environments

### Step-by-Step
```
1. List all external dependencies of the failing code:
   - Database (PostgreSQL)
   - Cache (Redis)
   - Email service (SendGrid)
   - Payment processor (Stripe)

2. Mock each one with a known-good value:
   a. Mock database → still fails
   b. Mock Redis → BUG DISAPPEARS

3. Deep dive into Redis interaction:
   - Redis connection: OK
   - Redis get: returns stale data (TTL not expired)
   - Root cause: cache key collision between user sessions
```

## Technique 6: Diff Analysis — Detailed

### When to Use
- The bug was introduced recently
- You can identify a window of commits where it started
- "It worked yesterday"

### Step-by-Step
```bash
# Get the diff of recent changes
git diff HEAD~5..HEAD

# For each changed file, ask:
# "Could this change cause the symptom?"

# Focus on:
# - Changed conditionals (if/else)
# - Changed data types
# - Changed function signatures
# - Changed configuration values
# - Renamed variables/fields
# - Changed import paths
```

## Technique 7: Rubber Duck Analysis — Detailed

### When to Use
- You've tried everything else
- The code is complex and you need fresh eyes
- The bug doesn't fit any obvious pattern

### Step-by-Step
```
1. Read the function line by line
2. For EACH line, state aloud:
   - What it does
   - What state it expects as input
   - What state it produces as output

3. When you can't explain a line → suspicious
4. When your explanation contradicts the code → that's the bug

Example:
   Line 1: "const user = await db.findById(id)"
   → Finds user by ID, expects id to be a number, returns user object or null

   Line 2: "if (user.isActive)"
   → WAIT. What if user is null? This will crash.
   → Found it: missing null check after database query
```

## Root Cause Analysis Template

```markdown
# Root Cause Analysis: <Bug Title>

## Summary
**Symptom:** <what the user sees>
**Root cause:** <the actual bug>
**Impact:** <who/what is affected>
**Severity:** <CRITICAL/HIGH/MEDIUM/LOW>

## Timeline
- <when it was introduced> — <commit/change that caused it>
- <when it was discovered> — <how it was found>
- <when it was diagnosed> — <how long investigation took>

## Investigation
**Technique used:** <which technique(s)>
**Key finding:** <the pivotal observation>

## Root Cause
**Location:** <file:line>
**Mechanism:** <step-by-step explanation>
**Why it wasn't caught:** <gap in testing/review>

## Fix
**Proposed change:** <exact code change>
**Regression test:** <test that catches this if it recurs>

## Prevention
**How to prevent similar bugs:**
- <process improvement>
- <testing improvement>
- <code pattern to use/avoid>
```
