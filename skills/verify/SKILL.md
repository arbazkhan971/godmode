---
name: verify
description: Evidence gate. Run command, read full output, confirm or deny claim. No trust, only proof.
---

## Activate When
- `/godmode:verify`, "prove it", "verify this", "is this actually true?", "check that", "confirm this works"
- Another skill makes a claim that needs evidence (e.g., "tests pass", "performance improved", "bug is fixed")
- Any time a result is cited without showing the command output that produced it

## Auto-Detection
The godmode orchestrator routes here when:
- A skill claims a metric improved but did not show the measurement command output
- User questions a previous result: "are you sure?", "did you actually run that?"
- A claim references stale data (file was edited after the last verification run)
- `/godmode:optimize` or `/godmode:fix` completes and the final result needs independent confirmation

## Step-by-step Workflow

### 1. Extract the Claim
Parse the claim into three components. All three are required before proceeding:
- **Claim**: One sentence stating what is allegedly true. Example: "All 47 tests pass."
- **Command**: The shell command that produces evidence. Example: `npm test 2>&1`
- **Pass condition**: How to judge the output. One of:
  - Exact match: `output contains "47 passing"`
  - Numeric comparison: `exit_code == 0`
  - Threshold: `value > 95`
  - Pattern: `output matches /^PASS/`

If the user provides only a claim without a command, derive the command from the claim:
- "Tests pass" → `test_cmd` (auto-detected from stack)
- "Build succeeds" → `build_cmd`
- "No lint errors" → `lint_cmd`
- "Coverage is above 80%" → `coverage_cmd` (e.g., `pytest --cov --cov-report=term | grep TOTAL`)
- "Endpoint returns 200" → `curl -sf -o /dev/null -w '%{http_code}' {url}`

Print: `[verify:claim] "{claim}" | cmd: {command} | pass: {condition}`

### 2. Check for Staleness
Before running the command, check if the claim references files that changed since the last verification:
```bash
last_verify_time=$(stat -f '%m' .godmode/verify-log.tsv 2>/dev/null || echo 0)
changed_files=$(find . -newer .godmode/verify-log.tsv -name '*.{ext}' | head -20)
```
- If source files changed since last verify: print `[verify:stale] {N} files changed since last verification. Previous results are VOID.`
- If no files changed AND the exact same claim+command was verified within the last 5 minutes: print `[verify:cached] Same claim verified {N}s ago. Re-running anyway (no trust).` — still re-run.

### 3. Execute the Command
Run the command with full output capture. No filtering, no truncation, no piping through head/tail:
```bash
{command} 2>&1 | tee /tmp/godmode-verify-{timestamp}.txt
exit_code=$?
```
- Capture: full stdout, full stderr, exit code, wall-clock duration
- Timeout: 120 seconds. If command exceeds timeout: verdict = FAIL, reason = "Timeout after 120s"
- Print: `[verify:run] Exit code: {exit_code} | Duration: {duration}s | Output: {line_count} lines`

### 4. Read Full Output
Read `/tmp/godmode-verify-{timestamp}.txt` line by line. Do NOT skim. Do NOT read only the last line. Check for:
- Error messages (lines containing "error", "Error", "ERROR", "FAIL", "fatal")
- Warning messages (lines containing "warn", "WARN", "warning", "deprecated")
- Unexpected values (numbers that don't match the expected range)
- Stack traces (lines starting with "at " or "Traceback")

Print: `[verify:read] {error_count} errors, {warning_count} warnings, {total_lines} total lines`

### 5. Determine Run Count
- **Numeric claims** (performance, timing, throughput, coverage percentage): Run 3 times. Use median.
- **Boolean claims** (tests pass, build succeeds, endpoint returns 200): Run 1 time.
- **Flaky detection**: If 3 runs produce different results (e.g., 2 PASS + 1 FAIL): verdict = FAIL, reason = "Flaky: inconsistent results across 3 runs ({results})"

For numeric claims, print all 3 values:
```
[verify:runs] Run 1: {value1} | Run 2: {value2} | Run 3: {value3} | Median: {median}
```

### 6. Judge: Compare Expected vs Actual
Apply the pass condition from step 1:
- Exact match: string comparison, case-sensitive
- Numeric: compare median against threshold
- Exit code: `exit_code == 0` is the only passing exit code unless the condition specifies otherwise
- Partial pass = FAIL. Example: "47/48 tests pass" when claim is "all tests pass" → FAIL.
- Non-zero exit code = FAIL unless the claim is specifically about a non-zero exit.
- Any error in output that contradicts the claim = FAIL even if exit code is 0.

Verdict: **PASS** or **FAIL**. No "PARTIAL", no "MAYBE", no "LIKELY".

Print: `[verify:judge] Expected: {expected} | Actual: {actual} | Verdict: {PASS|FAIL}`

### 7. Produce Evidence Report
Print a single formatted table:
```
| Field    | Value                                         |
|----------|-----------------------------------------------|
| Claim    | {claim}                                       |
| Command  | {command}                                     |
| Expected | {pass_condition}                              |
| Actual   | {actual_value}                                |
| Verdict  | PASS / FAIL                                   |
| Evidence | {first 10 lines of output, or relevant excerpt} |
| File     | /tmp/godmode-verify-{timestamp}.txt           |
```

If FAIL, also print: `REASON: {why it failed — specific mismatch, not generic}`

### 8. Log to TSV
Append to `.godmode/verify-log.tsv`:
```
{ISO-8601 timestamp}\t{claim}\t{command}\t{expected}\t{actual}\t{verdict}\t{evidence_file}\t{duration_ms}\t{run_count}
```

## Output Format
Each stage prints a tagged status line:
```
[verify:claim]  "All 47 tests pass" | cmd: npm test | pass: exit_code == 0 AND output contains "47 passing"
[verify:stale]  3 files changed since last verification. Previous results are VOID.
[verify:run]    Exit code: 0 | Duration: 3.1s | Output: 52 lines
[verify:read]   0 errors, 0 warnings, 52 total lines
[verify:judge]  Expected: exit 0 + "47 passing" | Actual: exit 0 + "47 passing" | Verdict: PASS

| Claim | PASS | npm test | exit 0 + "47 passing" | exit 0 + "47 passing" | (see /tmp/godmode-verify-1710941400.txt) |
```

## TSV Logging
File: `.godmode/verify-log.tsv`
Columns:
```
timestamp	claim	command	expected	actual	verdict	evidence_file	duration_ms	run_count
```
Example row:
```
2026-03-20T14:30:00Z	All 47 tests pass	npm test 2>&1	exit 0 + "47 passing"	exit 0 + "47 passing"	PASS	/tmp/godmode-verify-1710941400.txt	3100	1
```

## Success Criteria
- [ ] Claim is decomposed into exactly three parts: claim text, command, pass condition
- [ ] Command was actually executed (not reasoned about in head)
- [ ] Full stdout+stderr captured to a file — no truncation
- [ ] Output was read completely — error/warning counts reported
- [ ] Numeric claims used 3 runs with median; boolean claims used 1 run
- [ ] Verdict is exactly PASS or FAIL — no partial, no maybe
- [ ] Evidence table printed with all fields populated
- [ ] TSV row appended with timestamp, claim, command, expected, actual, verdict, evidence file

## Error Recovery
- **If the command does not exist or fails to start**: Verdict = FAIL, reason = "Command not found: {command}". Suggest the correct command for the stack.
- **If the command times out (>120s)**: Verdict = FAIL, reason = "Timeout after 120s". Suggest running with a smaller dataset or adding `--bail` / `--fail-fast`.
- **If the output is empty (0 lines)**: Verdict = FAIL, reason = "No output produced. Command may have silently failed." Check stderr separately.
- **If the evidence file cannot be written (/tmp full or read-only)**: Write to `.godmode/verify-evidence-{timestamp}.txt` instead. Log the alternate path.
- **If the claim is ambiguous ("it works")**: Ask the user to restate as a falsifiable claim: "What specific output or exit code would prove this? Restate as: '{thing} produces {expected_output}'."

## Anti-Patterns
1. **Never verify in your head.** "The code looks correct" is not verification. Run the command. Read the output. Report what happened.
2. **Never trust cached results.** If ANY file changed since the last verify, all previous results are void. Re-run.
3. **Never filter or truncate output.** Read all of stdout and stderr. A warning on line 847 can invalidate a "PASS" on line 1.
4. **Never accept partial pass as pass.** 99/100 tests passing is a FAIL if the claim is "all tests pass". 95% coverage is FAIL if the target is 96%.
5. **Never combine multiple claims in one verify.** Each claim gets its own command, its own run, its own verdict. "Tests pass and coverage is 80%" is two verifications.

## Examples

### Example 1: Boolean verification (tests pass)
```
> /godmode:verify "All tests pass"

[verify:claim]  "All tests pass" | cmd: npm test 2>&1 | pass: exit_code == 0
[verify:run]    Exit code: 0 | Duration: 4.2s | Output: 63 lines
[verify:read]   0 errors, 0 warnings, 63 total lines
[verify:judge]  Expected: exit 0 | Actual: exit 0 | Verdict: PASS

| Claim    | All tests pass                            |
| Command  | npm test 2>&1                             |
| Expected | exit_code == 0                            |
| Actual   | exit 0, "47 passing, 0 failing"           |
| Verdict  | PASS                                      |
| Evidence | /tmp/godmode-verify-1710941400.txt        |
```

### Example 2: Numeric verification (performance claim)
```
> /godmode:verify "Response time is under 200ms"

[verify:claim]  "Response time is under 200ms" | cmd: curl -o /dev/null -s -w '%{time_total}' http://localhost:3000/api/users | pass: value < 0.200
[verify:runs]   Run 1: 0.142 | Run 2: 0.187 | Run 3: 0.156 | Median: 0.156
[verify:judge]  Expected: < 0.200 | Actual: 0.156 (median of 3) | Verdict: PASS

| Claim    | Response time is under 200ms              |
| Command  | curl -o /dev/null -s -w '%{time_total}'.. |
| Expected | < 0.200s                                  |
| Actual   | 0.156s (median of 3 runs)                 |
| Verdict  | PASS                                      |
| Evidence | /tmp/godmode-verify-1710941520.txt        |
```

### Example 3: Verification failure with reason
```
> /godmode:verify "No lint errors"

[verify:claim]  "No lint errors" | cmd: npm run lint 2>&1 | pass: exit_code == 0
[verify:run]    Exit code: 1 | Duration: 1.8s | Output: 14 lines
[verify:read]   3 errors, 0 warnings, 14 total lines
[verify:judge]  Expected: exit 0 | Actual: exit 1 | Verdict: FAIL

REASON: 3 lint errors found: unused-vars (src/auth.ts:12), no-console (src/logger.ts:5), prefer-const (src/config.ts:22)

| Claim    | No lint errors                            |
| Command  | npm run lint 2>&1                         |
| Expected | exit_code == 0                            |
| Actual   | exit 1, 3 errors                          |
| Verdict  | FAIL                                      |
| Evidence | /tmp/godmode-verify-1710941600.txt        |
```

## Multi-Layer Verification Protocol

Systematic protocol for verifying claims across multiple layers of confidence, from unit-level to production-level:

```
MULTI-LAYER VERIFICATION PROTOCOL:
current_layer = 0
max_layers = 5
verification_layers = [unit, integration, e2e, smoke, evidence_collection]
evidence_chain = []

WHILE current_layer < max_layers:
  layer = verification_layers[current_layer]
  current_layer += 1

  IF layer == "unit":
    PURPOSE: Verify individual components work correctly in isolation.

    1. IDENTIFY unit test scope:
       - Parse the claim to identify the target module/function
       - Find corresponding unit test files
       - IF no unit tests exist for the claimed functionality: FAIL — "No unit tests cover this claim"

    2. RUN unit tests:
       test_cmd_unit = "{test_cmd} --grep '{relevant_pattern}'" or "{test_cmd} {specific_test_file}"
       result = run(test_cmd_unit)

    3. COLLECT evidence:
       evidence_chain.append({
         layer: "unit",
         command: test_cmd_unit,
         exit_code: result.exit_code,
         output_file: "/tmp/godmode-verify-unit-{timestamp}.txt",
         passing: result.tests_passed,
         failing: result.tests_failed,
         duration: result.duration_ms,
         verdict: "PASS" if exit_code == 0 else "FAIL"
       })

    4. IF FAIL: stop here — no point testing higher layers if units fail
       REPORT: "[verify:unit] FAIL — {N} unit tests failed. Fix before proceeding."
       STOP

  IF layer == "integration":
    PURPOSE: Verify components work correctly when composed together.

    1. IDENTIFY integration scope:
       - Which services/modules interact for this claim?
       - Are there integration tests that cover this interaction?
       - Do integration tests require external services (DB, cache, API)?

    2. ENSURE dependencies are available:
       IF database required: check connection (pg_isready, mysql ping, etc.)
       IF redis required: check connection (redis-cli ping)
       IF external API required: check health endpoint or mock

    3. RUN integration tests:
       test_cmd_integration = "{test_cmd} --grep 'integration'" or "{test_cmd} tests/integration/"
       result = run(test_cmd_integration)

    4. COLLECT evidence:
       evidence_chain.append({
         layer: "integration",
         command: test_cmd_integration,
         exit_code: result.exit_code,
         output_file: "/tmp/godmode-verify-integration-{timestamp}.txt",
         verdict: "PASS" if exit_code == 0 else "FAIL"
       })

    5. IF FAIL:
       DIAGNOSE: was it a test failure or a dependency issue?
       IF dependency issue: "Integration test failed due to unavailable {service}. Not a code issue."
       IF test failure: "Integration test failed. The claim is NOT verified at integration layer."

  IF layer == "e2e":
    PURPOSE: Verify the full user flow works end-to-end.

    1. IDENTIFY e2e scope:
       - What user-visible behavior does the claim describe?
       - Are there e2e/acceptance tests for this behavior?
       - Does the application need to be running for these tests?

    2. IF the application requires a running server:
       Start application in test mode: {dev_cmd} or {start_cmd}
       Wait for ready signal (port listening, health check)

    3. RUN e2e tests:
       test_cmd_e2e = "{e2e_cmd}" or "npx playwright test" or "npx cypress run"
       result = run(test_cmd_e2e)

    4. COLLECT evidence:
       evidence_chain.append({
         layer: "e2e",
         command: test_cmd_e2e,
         exit_code: result.exit_code,
         output_file: "/tmp/godmode-verify-e2e-{timestamp}.txt",
         screenshots: [list of screenshot paths if UI test],
         verdict: "PASS" if exit_code == 0 else "FAIL"
       })

    5. IF no e2e tests exist:
       evidence_chain.append({
         layer: "e2e",
         verdict: "SKIPPED",
         reason: "No e2e tests cover this claim"
       })

  IF layer == "smoke":
    PURPOSE: Quick, lightweight check that the system is operational.

    1. DEFINE smoke checks based on claim type:
       IF claim involves API: curl -sf {endpoint} → expect 200
       IF claim involves CLI: {command} --help → expect exit 0
       IF claim involves build: ls {output_dir} → expect files exist
       IF claim involves performance: time {command} → expect < threshold

    2. RUN smoke checks (quick, < 30 seconds total):
       FOR each smoke_check:
         result = run(smoke_check.command)
         smoke_check.passed = evaluate(result, smoke_check.expected)

    3. COLLECT evidence:
       evidence_chain.append({
         layer: "smoke",
         checks: [{ command, expected, actual, passed } for each],
         verdict: "PASS" if all passed else "FAIL"
       })

  IF layer == "evidence_collection":
    PURPOSE: Compile all evidence into a single, auditable chain of proof.

    1. AGGREGATE all layer results:
       EVIDENCE CHAIN:
       ┌───────────────┬────────┬──────────┬───────────────────────────┐
       │  Layer        │ Verdict│ Duration │ Evidence File              │
       ├───────────────┼────────┼──────────┼───────────────────────────┤
       │  Unit         │ PASS   │ 2.1s     │ /tmp/gm-verify-unit-*.txt │
       │  Integration  │ PASS   │ 8.4s     │ /tmp/gm-verify-int-*.txt  │
       │  E2E          │ SKIP   │ —        │ No e2e tests              │
       │  Smoke        │ PASS   │ 0.3s     │ /tmp/gm-verify-smoke-*.txt│
       └───────────────┴────────┴──────────┴───────────────────────────┘

    2. DETERMINE overall verdict:
       IF all executed layers PASS: VERIFIED (high confidence)
       IF unit + integration PASS but e2e SKIP: VERIFIED (medium confidence, note e2e gap)
       IF unit PASS but integration FAIL: PARTIALLY VERIFIED (unit-only, integration issue)
       IF any layer FAIL: NOT VERIFIED (specify which layer failed)

    3. CALCULATE confidence score:
       layers_passed = count(PASS verdicts)
       layers_executed = count(executed layers, excluding SKIP)
       confidence = layers_passed / layers_executed * 100

       >= 100%: HIGH confidence (all layers pass)
       >= 75%:  MEDIUM confidence (most layers pass)
       >= 50%:  LOW confidence (mixed results)
       < 50%:   NOT VERIFIED (majority fail)

    4. PERSIST evidence:
       - Save all evidence files with timestamps
       - Append to .godmode/verify-log.tsv with all layer results
       - Create evidence summary: .godmode/verify-evidence-{timestamp}.md

    5. FINAL REPORT:
       MULTI-LAYER VERIFICATION REPORT:
       ┌──────────────────────────────────────────────────────┐
       │  Claim: "{claim}"                                     │
       │                                                       │
       │  Unit tests:        PASS (47/47, 2.1s)               │
       │  Integration tests: PASS (12/12, 8.4s)               │
       │  E2E tests:         SKIPPED (none available)          │
       │  Smoke tests:       PASS (3/3, 0.3s)                 │
       │                                                       │
       │  Confidence:        HIGH (3/3 executed layers pass)   │
       │  Overall verdict:   VERIFIED                          │
       │  Evidence:          4 files preserved                 │
       │                                                       │
       │  Note: Add e2e tests for full coverage.                │
       └──────────────────────────────────────────────────────┘

  REPORT: "Layer {current_layer}/{max_layers}: {layer} — {PASS | FAIL | SKIP}"
```

### Evidence Collection Standards

```
EVIDENCE STANDARDS (for auditable verification):

1. EVERY verification must produce a file:
   - Full command output (stdout + stderr)
   - Timestamp of execution
   - Exit code
   - Duration in milliseconds
   - File path for retrieval

2. EVERY evidence file stays immutable:
   - Write once, never modify
   - Timestamped filename prevents collisions
   - Stored in /tmp/godmode-verify-* or .godmode/verify-evidence/

3. EVERY verification stays reproducible:
   - Log the exact command (not paraphrased)
   - Log the working directory
   - Log relevant environment variables (without values for secrets)
   - Another developer can re-run and get the same result

4. EVIDENCE CHAIN format (append to .godmode/verify-log.tsv):
   timestamp	claim	layer	command	expected	actual	verdict	evidence_file	duration_ms	confidence

5. STALE EVIDENCE policy:
   - Evidence older than 24 hours is considered stale
   - Evidence from before the last code change is VOID
   - Re-verification is always preferred over citing old evidence
   - NEVER say "verified yesterday" — re-run the command

6. FLAKY DETECTION:
   - If 3 runs produce different results: verdict = FLAKY (not PASS or FAIL)
   - Flaky tests undermine the entire verification chain
   - Report flaky tests separately: .godmode/flaky-tests.tsv
   - Fix or quarantine flaky tests before claiming verification
```

## Keep/Discard Discipline
```
After EACH verification run:
  KEEP if: command executed successfully AND verdict is clearly PASS or FAIL
  DISCARD if: command failed to run OR output is ambiguous OR evidence file missing
  On discard: retry command once. If still ambiguous, verdict = FAIL with reason.
  Never keep a verification without a concrete verdict backed by evidence.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: all claims verified with PASS or FAIL verdicts
  - budget_exhausted: command timeout (120s) reached
  - diminishing_returns: re-verification produces same result as prior run
  - stuck: >5 consecutive ambiguous results across different claims
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
This skill does not dispatch parallel agents, so no sequential translation is needed.
All commands run in the current session. Output capture uses `2>&1 | tee {file}` which works on all POSIX shells.
If `/tmp` is unavailable, write evidence files to `.godmode/verify-evidence/`.
See `adapters/shared/sequential-dispatch.md` for the general protocol.
