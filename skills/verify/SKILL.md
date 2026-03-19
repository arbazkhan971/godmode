---
name: verify
description: |
  Evidence gate skill. Enforces the "evidence before claims" principle. Before any skill can claim success (tests pass, performance improved, bug fixed), this skill runs the verification command, reads the actual output, and confirms or denies the claim. Triggers on: /godmode:verify, internally by other skills before claiming success, or when user says "prove it", "show me evidence", "verify this."
---

# Verify — Evidence Before Claims

## When to Activate
- User invokes `/godmode:verify`
- Any other skill needs to confirm a claim before reporting it
- User says "prove it," "show me," "verify that works"
- After any change that claims an improvement
- Before any status report that includes metrics

## The Core Principle

**Never claim something is true without running a command and reading the output.**

```
BAD:  "I fixed the bug, tests should pass now."
GOOD: "I fixed the bug. Running tests... 47/47 passing. Here's the output."

BAD:  "This optimization should improve performance by 30%."
GOOD: "Running benchmark... baseline 847ms, now 592ms, improvement 30.1%."

BAD:  "The code is secure."
GOOD: "Ran npm audit: 0 vulnerabilities. Checked for SQL injection in 3 input handlers: all use parameterized queries."
```

## Workflow

### Step 1: Identify the Claim
What is being claimed? Extract the specific, verifiable assertion:

```
CLAIM: <what is being asserted>
TYPE: <test pass | metric improvement | error fixed | security clean | build success>
VERIFY COMMAND: <command that will prove or disprove this>
EXPECTED OUTPUT: <what the command should show if the claim is true>
```

### Step 2: Run the Verification
Execute the verify command and capture FULL output:

```bash
# Run the command, capture everything
<verify command> 2>&1
```

**Rules:**
- Run the EXACT command, not a variation
- Capture BOTH stdout and stderr
- Do not filter or truncate the output before reading it
- If the command takes arguments, use the same arguments as in production

### Step 3: Read the Output
Read the actual output. Do not skim. Do not assume.

```
VERIFICATION OUTPUT:
<full command output>
```

### Step 4: Compare and Judge
Compare the expected output with the actual output:

```
VERIFICATION:
Claim: "All 47 tests pass"
Command: npm test
Expected: 47 passing, 0 failing
Actual: 45 passing, 2 failing
Verdict: CLAIM REJECTED ✗

Failed tests:
- "creates user with valid email" — TypeError at user.ts:23
- "returns 404 for missing user" — Expected 404, got 500
```

OR:

```
VERIFICATION:
Claim: "Response time improved to under 200ms"
Command: curl timing on /api/products
Expected: < 200ms
Actual: 187ms (3-run median: 187, 192, 183)
Verdict: CLAIM CONFIRMED ✓
```

### Step 5: Report
Return the verification result to the calling skill or user:

```
EVIDENCE:
Claim: <what was claimed>
Verified: <YES | NO>
Command: <what was run>
Output: <relevant output>
Details: <explanation if claim was rejected>
```

## Verification Templates

### Template: Tests Pass
```bash
COMMAND: <test command>
EXPECT: All tests pass (0 failures)
PARSE: Look for "X passing, Y failing" or exit code 0
REJECT IF: Any test failure or non-zero exit code
```

### Template: Lint Clean
```bash
COMMAND: <lint command>
EXPECT: No errors or warnings
PARSE: Look for "0 errors" or clean exit
REJECT IF: Any error in output
```

### Template: Type Check Clean
```bash
COMMAND: <type check command>
EXPECT: No type errors
PARSE: Look for "0 errors" or clean exit
REJECT IF: Any "error TS" or equivalent
```

### Template: Metric Improved
```bash
COMMAND: <verify command> (run 3 times)
EXPECT: Median value better than baseline
PARSE: Extract numeric value, compute median
REJECT IF: Median is worse than or equal to baseline
```

### Template: Build Succeeds
```bash
COMMAND: <build command>
EXPECT: Build completes with exit code 0
PARSE: Check exit code and output for "error"
REJECT IF: Non-zero exit code or "error" in output
```

### Template: No Secrets
```bash
COMMAND: grep -rn "password\|secret\|api_key\|token" --include="*.ts" --include="*.py" src/
EXPECT: No hardcoded secrets found
PARSE: Check for actual secret values (not variable names)
REJECT IF: Any hardcoded credential values found
```

## Key Behaviors

1. **Run, don't assume.** The verify command must actually execute. "I already ran this" is not verification.
2. **Read the full output.** Don't grep for "passing" and ignore the rest. Read it all. The devil is in the details.
3. **Three-run median for metrics.** A single measurement is noisy. Run 3 times, take the median.
4. **Report honestly.** If the claim is false, say so clearly. Don't soften bad news.
5. **Include the output.** The evidence is the output. Show it so the user (or calling skill) can confirm.
6. **Exit codes matter.** A command that prints "success" but exits with code 1 is not successful.
7. **Fail loud.** If verification fails, it should be immediately obvious. Don't bury failures.

## Example Usage

### Verifying test claims
```
User: /godmode:verify Do all tests pass?

Verify: Running test command...

Command: npm test
Output:
  Test Suites: 12 passed, 12 total
  Tests:       47 passed, 47 total
  Snapshots:   0 total
  Time:        3.241 s

CLAIM CONFIRMED ✓
All 47 tests pass across 12 test suites.
```

### Verifying a performance claim
```
Optimize: Claiming response time improved to 198ms.

Verify: Running verification (3 runs)...

Command: curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/products
Run 1: 0.198s (198ms)
Run 2: 0.203s (203ms)
Run 3: 0.195s (195ms)
Median: 198ms

CLAIM CONFIRMED ✓
Response time is 198ms (target: < 200ms).
```

### Catching a false claim
```
Fix: Claiming all lint errors fixed.

Verify: Running lint command...

Command: npm run lint
Output:
  /src/services/user.ts
    12:5  error  'email' is defined but never used  no-unused-vars

  1 problem (1 error, 0 warnings)

CLAIM REJECTED ✗
1 lint error remains in src/services/user.ts:12.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Verify the most recent claim |
| `--tests` | Verify tests pass |
| `--lint` | Verify lint is clean |
| `--types` | Verify type check is clean |
| `--metric` | Verify optimization metric |
| `--all` | Run all verification commands |
| `--verbose` | Show full command output (not just parsed result) |

## Anti-Patterns

- **Do NOT skip verification.** "The tests probably pass" is not evidence. Run them.
- **Do NOT verify in your head.** "I read the code and it looks correct" is not verification. Run the command.
- **Do NOT ignore partial failures.** "47 of 48 tests pass" is a failure, not a success.
- **Do NOT accept stale verification.** "Tests passed 10 minutes ago" — you've made changes since then. Run them again.
- **Do NOT filter output before reading.** Piping test output through grep to find "passing" might hide failures on other lines.
- **Do NOT claim a metric improved without 3 runs.** Single measurements are unreliable. Always use the median of 3.
