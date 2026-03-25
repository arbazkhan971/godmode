---
name: predict
description: 3-persona + meta-expert evaluation.
  Independent assessment then synthesis. Gate before build.
---

## Activate When
- `/godmode:predict`, "will this work?", "evaluate"
- "risk assessment", "is this a good idea?"
- Spec exists and user wants confidence check
- Called by `/godmode:plan` when >10 tasks detected

## Workflow

### 1. Define
```bash
cat .godmode/spec.md
git ls-files | head -50
```
IF no spec: ask user for description or run
`/godmode:think` first.

### 2. Scan
Read files referenced in spec. Identify dependencies,
existing patterns, API contracts, test coverage.

### 3. Dispatch 3 Personas (parallel, independent)
- **Technical Architect**: scalability, data model,
  API contracts, error handling, patterns, performance
- **Security Researcher**: attack surface, data exposure,
  auth/authz, injection, supply chain, secrets
- **Release Lead**: shipping risk, rollback plan,
  monitoring, deployment, resource limits, failures

Each persona outputs (mandatory fields):
```
VERDICT: YES | REVISE | NO
CONFIDENCE: 1-10 (integer)
RISKS:
  - {description} @ {file:line} -- SEVERITY: {level}
    MITIGATION: {concrete code/arch change}
PRAISE: {non-obvious positive only, max 2}
```
IF risk missing file:line: retry 2x, then mark
"incomplete" (excluded from gate).
IF praise is vague ("looks clean"): remove it.

### 4. Collect
Every validated risk has file:line + mitigation.
Incomplete findings logged but excluded from gate.

### 5. Synthesize (Meta-Expert)
- Deduplicate: same file:line -> merge, keep highest
- Classify: blockers (NO/critical), warnings
  (REVISE/high), notes (medium/low)
- Conflicts: report both views, do not average

### 6. Gate (Pure Voting)
```
3 YES          -> PROCEED -> /godmode:plan
1-2 REVISE, 0 NO -> REVISE -> /godmode:think
any NO         -> RETHINK -> /godmode:think
```
IF unanimous: flag potential groupthink.
IF confidence stddev > 2.5: flag high variance.

### 7. Report
Print findings table, all validated risks (sorted
by severity), incomplete findings, gate result.

### 8. Log
Append `.godmode/predict-results.tsv`: one row per
persona with timestamp, feature, persona, verdict,
confidence, risk_count, top_risk, mitigation, gate.

## Hard Rules
1. Every risk: file:line + concrete mitigation.
   Vague -> 2 retries -> mark incomplete.
2. Gate is pure voting: PROCEED=3Y, REVISE=1-2R+0N,
   RETHINK=any NO.
3. NEVER gate on incomplete findings.
4. Each persona evaluates from own domain only.
5. Praise must be non-obvious and specific.

## TSV Logging
Append `.godmode/predict-results.tsv`:
```
timestamp	feature	persona	verdict	confidence	risk_count	top_risk	mitigation	gate
```

## Keep/Discard
```
KEEP if: finding has file:line + mitigation
  + at least 1 persona rates exploitable.
DISCARD if: no file:line after 2 retries
  OR all personas rate not exploitable.
```

## Stop Conditions
```
STOP when FIRST of:
  - All 3 personas produced verdicts + gate computed
  - Max 2 retries per vague finding exhausted
  - Re-evaluation produces 0 new findings
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| No spec exists | Ask user or run /godmode:think |
| Vague findings | Retry 2x, then mark incomplete |
| Unanimous verdict | Flag groupthink, still proceed |
| High variance (>2.5) | Report each persona reasoning |
