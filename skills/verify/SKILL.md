---
name: verify
description: >
  Evidence gate. Run command, read full output,
  confirm or deny claim. No trust, only proof.
---

## Activate When
- `/godmode:verify`, "prove it", "verify this"
- Another skill claims a result without evidence
- User questions a previous result

## Workflow

### 1. Extract the Claim
Parse into three required components:
- **Claim**: one sentence of what is allegedly true
- **Command**: shell command that produces evidence
- **Pass condition**: how to judge output

```
IF user provides only claim, derive command:
  "Tests pass" -> test_cmd
  "Build succeeds" -> build_cmd
  "No lint errors" -> lint_cmd
  "Coverage >80%" -> coverage_cmd | grep TOTAL
  "Endpoint returns 200" ->
    curl -sf -o /dev/null -w '%{http_code}' {url}

WHEN claim is ambiguous ("it works"):
  ask user to restate as falsifiable claim
```

Print: `[verify:claim] "{claim}" | cmd: {command} | pass: {condition}`

### 2. Check Staleness
```bash
last_verify=$(stat -f '%m' \
  .godmode/verify-log.tsv 2>/dev/null || echo 0)
find . -newer .godmode/verify-log.tsv \
  -name '*.ts' -o -name '*.py' | head -20
```
IF source files changed: previous results are VOID.

### 3. Execute Command
```bash
{command} 2>&1 | tee /tmp/godmode-verify-$(date +%s).txt
echo "EXIT:$?"
```
- Capture: stdout, stderr, exit code, wall time
- Timeout: 120 seconds. Exceed = FAIL.
- Print: `[verify:run] Exit: {code} | {duration}s | {lines} lines`

### 4. Read Full Output
Read every line. Check for:
- Error lines (error, ERROR, FAIL, fatal)
- Warnings (warn, WARN, deprecated)
- Stack traces (at, Traceback)
- Unexpected values

Print: `[verify:read] {errors} errors, {warnings} warnings, {total} lines`

### 5. Determine Run Count
```
IF numeric claim (performance, coverage):
  run 3 times, use median
  IF 3 runs differ: FAIL (flaky)
IF boolean claim (tests pass, build succeeds):
  run 1 time
```

### 6. Judge
```
Exact match: string compare, case-sensitive
Numeric: compare median against threshold
Exit code: 0 is only passing code
Partial pass = FAIL
  (99/100 tests when claim is "all" = FAIL)
Non-zero exit = FAIL
Error contradicting claim = FAIL even if exit 0
Verdict: PASS or FAIL. No PARTIAL or UNCERTAIN.
```

### 7. Evidence Report
```
| Field    | Value                            |
|---------|--------------------------------|
| Claim   | {claim}                         |
| Command | {command}                        |
| Expected| {pass_condition}                 |
| Actual  | {actual_value}                   |
| Verdict | PASS / FAIL                      |
| Evidence| {first 10 lines or key excerpt}  |
| File    | /tmp/godmode-verify-{ts}.txt     |
```
IF FAIL: `REASON: {specific mismatch}`

### 8. Log to TSV
Append to `.godmode/verify-log.tsv`:
`timestamp\tclaim\tcommand\texpected\tactual\tverdict\tevidence_file\tduration_ms\trun_count`

## Hard Rules
1. Never verify in your head. Run the command.
2. Never trust cached results. Re-run if files changed.
3. Never filter or truncate output. Read all.
4. Partial pass = FAIL. 99/100 = FAIL.
5. Each claim gets own command, run, and verdict.
6. Never ask to continue. Loop autonomously.

## Anti-Patterns
1. "Code looks correct" is not verification.
2. Citing yesterday's result is not proof.
3. Warning on line 847 can invalidate line 1 PASS.
4. "Tests pass and coverage >80%" = two verifications.

## Keep/Discard Discipline
```
KEEP if: command executed AND verdict unambiguous
DISCARD if: command failed to run OR ambiguous
  On discard: retry once. Still ambiguous = FAIL.
```

## Stop Conditions
```
STOP when FIRST of:
  - All claims verified with PASS or FAIL
  - Command timeout 120s reached
  - >5 consecutive ambiguous results
```

<!-- tier-3 -->

## Error Recovery
- **Command not found:** FAIL. Suggest correct cmd.
- **Timeout >120s:** FAIL. Suggest --bail or smaller.
- **Empty output:** FAIL. Check stderr separately.
- **Evidence file unwritable:** Write to .godmode/.
