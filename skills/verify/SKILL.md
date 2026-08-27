---
name: verify
description: >
  Evidence gate. Run command, read full output,
  confirm or deny claim. No trust, only proof.
---

## Activate When
- `/godmode:verify`, "prove it", "verify this"
- "/godmode:doctor", "which model is each role using", "model routing check"
- Another skill claims a result without evidence
- User questions a previous result

## Workflow

### 0. Doctor Mode (early exit)

IF the invocation is `/godmode:doctor` or a model-routing question
("which model is each role using", "model routing check"): produce the
routing table per the spec below, print it, STOP. Skip Steps 1-8 and skip
the Goal-Bridge contract in Output Format -- the doctor is a config
report, not a claim verification. Missing config is the valid zero-config
default (every role inherits the session model), so the doctor NEVER
fails on missing config and ALWAYS exits 0. No ANSI. One command, no
guessing -- every row shows its source.

Resolution order (identical at every layer): `GODMODE_MODEL_<ROLE>` env ->
`godmode.models.json` (per-role merge: the project-root file wins per key
over `~/.config/godmode/models.json`) -> session model. A model value is
valid iff it fully matches `^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$` OR is the
literal string `session`; an INVALID value at ANY layer emits one stderr
warning (`[models] warning: ignoring invalid model value for role <role>`)
and is treated as absent (fall through to the next layer). Role -> env
name: uppercase, hyphen dot underscore all -> underscore, via exactly
`tr '[:lower:]._-' '[:upper:]___'`; env name = `GODMODE_MODEL_<that>`.
Read with `printenv "$name" 2>/dev/null || true`. Set-but-empty value =
NOT an override (fall through). Case-folded roles (Plan/plan) collapse to
one env var -- documented here, not special-cased.

**Path A** (godmode repo checkout present): IF `test -f
adapters/pi/models.sh` -> run `bash adapters/pi/models.sh doctor` and
print its output verbatim (same TSV contract as below), STOP.

**Path B** (skills-only install -- the common case; `adapters/` is never
installed): inline sweep over the 8 canonical roles (plan build review
optimize explore security test docs) UNION every `GODMODE_MODEL_*` env
name UNION roles found in the config files, using this embedded
gm_route()-style resolver:

```bash
# /godmode:doctor, path B -- inline sweep; TSV, no ANSI, exit 0 ALWAYS
set -euo pipefail
ROLES="plan build review optimize explore security test docs"
PROJ="godmode.models.json"
HOME_CFG="$HOME/.config/godmode/models.json"
py_warned=0

gm_valid() { # valid iff it matches the regex OR is the literal "session"
  printf '%s' "$1" | grep -Eq '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$' || [ "$1" = "session" ]
}

gm_warn() { echo "[models] warning: ignoring invalid model value for role $1" >&2; }

read_cfg() { # $1 = path -> "role<TAB>model" lines; silent on any failure
  if ! command -v python3 >/dev/null 2>&1; then
    if [ "$py_warned" -eq 0 ]; then
      echo "[models] warning: python3 not found -- skipping config file layer" >&2
      py_warned=1
    fi
    return 0
  fi
  [ -f "$1" ] || return 0
  python3 - "$1" <<'EOF'
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8-sig") as fh:
        cfg = json.load(fh)
except Exception:
    sys.exit(0)
roles = cfg.get("roles", cfg) if isinstance(cfg, dict) else {}
if isinstance(roles, dict):
    for key in sorted(roles):
        if isinstance(roles[key], str):
            print("%s\t%s" % (key, roles[key]))
EOF
}

gm_route() { # $1 = role -> one TSV row through every layer
  local role env_name val
  role="$1"
  env_name="GODMODE_MODEL_$(printf '%s' "$role" | tr '[:lower:]._-' '[:upper:]___')"
  val="$(printenv "$env_name" 2>/dev/null || true)" # set-but-empty = no override
  if [ -n "$val" ]; then
    if gm_valid "$val"; then
      printf '%s\t%s\tenv\t%s\n' "$role" "$val" "$env_name"
      return 0
    fi
    gm_warn "$role"
  fi
  val="$(printf '%s\n' "$PROJ_KV" | awk -F'\t' -v r="$role" '$1==r{print $2}')"
  if [ -n "$val" ]; then
    if gm_valid "$val"; then
      printf '%s\t%s\tfile\tgodmode.models.json (project)\n' "$role" "$val"
      return 0
    fi
    gm_warn "$role"
  fi
  val="$(printf '%s\n' "$HOME_KV" | awk -F'\t' -v r="$role" '$1==r{print $2}')"
  if [ -n "$val" ]; then
    if gm_valid "$val"; then
      printf '%s\t%s\tfile\t~/.config/godmode/models.json\n' "$role" "$val"
      return 0
    fi
    gm_warn "$role"
  fi
  printf '%s\tsession\tsession\t-\n' "$role"
}

PROJ_KV=""
if [ -f "$PROJ" ]; then PROJ_KV="$(read_cfg "$PROJ")" || true; fi
HOME_KV=""
if [ -f "$HOME_CFG" ]; then HOME_KV="$(read_cfg "$HOME_CFG")" || true; fi

for e in $(printenv | grep '^GODMODE_MODEL_' | cut -d= -f1 || true); do
  r="$(printf '%s' "${e#GODMODE_MODEL_}" | tr '[:upper:]' '[:lower:]')"
  case " $ROLES " in *" $r "*) ;; *) ROLES="$ROLES $r" ;; esac
done
for k in $(printf '%s\n%s\n' "$PROJ_KV" "$HOME_KV" | cut -f1 | grep -v '^$' || true); do
  case " $ROLES " in *" $k "*) ;; *) ROLES="$ROLES $k" ;; esac
done

printf 'role\tmodel\tsource\torigin\n'
for r in $ROLES; do gm_route "$r"; done
if [ -f "$PROJ" ]; then p="$PROJ"; else p=none; fi
if [ -f "$HOME_CFG" ]; then h="$HOME_CFG"; else h=none; fi
printf 'config\trepo=%s\thome=%s\n' "$p" "$h"
exit 0
```

Table contract (TSV, no ANSI, exit 0 ALWAYS -- identical to Path A):

| Column  | Meaning |
|---------|---------|
| `role`  | role key swept (8 canonical + env + config) |
| `model` | resolved model id (e.g. `vendor/strong`) or the literal `session` on session rows |
| `source`| `env`, `file`, or `session` |
| `origin`| env rows: the env var name (e.g. `GODMODE_MODEL_PLAN`); file rows: `godmode.models.json (project)` or `~/.config/godmode/models.json`; session rows: literal `-` |

Header line starts with `role`. Trailer line:
`config<TAB>repo=<path|none><TAB>home=<path|none>`.

Example (three rows, `<TAB>`-separated):

```
role	model	source	origin
plan	vendor/strong	env	GODMODE_MODEL_PLAN
build	vendor/fast	file	godmode.models.json (project)
review	session	session	-
config	repo=godmode.models.json	home=none
```

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

## Output Format
After the evidence report, the agent MUST print the Goal-Bridge Contract for this verification as the mandatory final output — metric: the exact verify command used, where exit 0 = claim confirmed; threshold: the pass condition from Step 1; evidence: the evidence-report path; rollback: the trigger on which the verifier must call for revert. Full protocol: skills/goal-bridge/SKILL.md.

Goal-Bridge Contract (mandatory final output):
- metric: <single shell command; contract met iff it exits 0>
- threshold: <numeric or boolean bound the metric must satisfy>
- evidence: <file path where metric output/proof is written every round>
- rollback: <exact trigger that reverts the work, e.g. "metric fails on 2 consecutive rounds">

<!-- tier-3 -->

## Error Recovery
- **Command not found:** FAIL. Suggest correct cmd.
- **Timeout >120s:** FAIL. Suggest --bail or smaller.
- **Empty output:** FAIL. Check stderr separately.
- **Evidence file unwritable:** Write to .godmode/.
