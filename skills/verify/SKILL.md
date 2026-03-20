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
2. **Never trust cached results.** If ANY file has been edited since the last verify, all previous results are void. Re-run.
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

## Platform Fallback (Gemini CLI, OpenCode, Codex)
This skill does not dispatch parallel agents, so no sequential translation is needed.
All commands run in the current session. Output capture uses `2>&1 | tee {file}` which works on all POSIX shells.
If `/tmp` is unavailable, write evidence files to `.godmode/verify-evidence/`.
See `adapters/shared/sequential-dispatch.md` for the general protocol.
