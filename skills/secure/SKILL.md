---
name: secure
description: >
  Security audit. STRIDE + OWASP Top 10 +
  4 red-team personas. Code evidence required.
---

## Activate When
- `/godmode:secure`, "security audit", "vulnerabilities"
- "harden", "pentest", "threat model"

## Workflow

### 1. Recon
```bash
# Dependency audit
npm audit 2>/dev/null || pip audit 2>/dev/null \
  || cargo audit 2>/dev/null

# Scan for hardcoded secrets
grep -rn 'SECRET\|API_KEY\|PASSWORD\|PRIVATE_KEY' \
  --include="*.ts" --include="*.py" --include="*.go" \
  --include="*.env" src/ 2>/dev/null | head -20

# List all public routes
grep -rn "router\.\(get\|post\|put\|delete\)" \
  --include="*.ts" --include="*.js" -l 2>/dev/null
```

### 2. Asset Map
List each: DB (type+version), auth mechanism
(JWT/session/OAuth + expiry), external APIs,
all `<input>`/`<form>` elements, public routes.

### 3. Trust Boundaries
Draw: client<->server, public<->auth, user<->admin,
svc<->svc, CI<->prod, internal<->external.
Each boundary = attack surface.

### 4. STRIDE Analysis
For each boundary: Spoofing, Tampering, Repudiation,
Info Disclosure, DoS, Elevation.

### 5. Iterate
```
categories = OWASP_TOP_10 + STRIDE  # 16 total
current_iteration = 0
WHILE untested categories remain:
    current_iteration += 1
    Pick untested category.
    Priority: Injection > Broken Auth > XSS
      > SSRF > IDOR > remaining.
    Test as 4 personas:
      P1: External (no auth)
      P2: Insider (valid session)
      P3: Supply Chain (malicious dep)
      P4: Infrastructure (server access)
    Each finding: file:line + exploit steps
      + severity + fix (code snippet).
    Every 5 iters: print progress.

IF finding has code evidence from 1+ personas: KEEP
IF no code evidence from any persona: DISCARD
```

### 6. Red-Team Persona Voting
```
FOR each finding:
  Each persona rates: EXPLOITABLE (1) or NOT (0)
  Score = sum (0-4):
    4/4 = CRITICAL (unanimous)
    3/4 = HIGH (likely exploitable)
    2/4 = MEDIUM (conditional)
    1/4 = LOW (edge case)
    0/4 = DISCARD (theoretical)
```

### 7. Report
Print: `OWASP {N}/10, STRIDE {N}/6. {C}C {H}H {M}M {L}L.`
PASS if 0 critical + 0 high. Else FAIL.

### 8. Auto-Fix (if `--fix`)
For Critical/High: fix -> commit -> run full test suite
-> revert if ANY test breaks.

## Findings Format
Every finding MUST use:
```
SEVERITY|FILE:LINE|DESCRIPTION|FIX
```
Examples:
```
CRITICAL|src/api/auth.ts:42|SQL injection via
  unsanitized email|Use parameterized query
HIGH|src/middleware/cors.ts:8|CORS wildcard|
  Set explicit allowed origins
MEDIUM|src/utils/crypto.ts:15|Math.random() for
  session token|Use crypto.randomBytes(32)
```

## TSV Logging
Log to `.godmode/security-findings.tsv`:
`iteration\tcategory\tpersona\tseverity\tfile_line\tdescription\tfix\tstatus\tvotes`

## Hard Rules
1. Every finding: file:line + exploit + proof.
2. Cover all OWASP Top 10 x 4 personas = 40 minimum.
3. Never approve with Critical findings open.
4. No code evidence from any persona = DISCARD.
5. Auto-fix must run full test suite after each fix.
6. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
KEEP if: file:line evidence AND 1+ persona
  rates EXPLOITABLE AND steps reproducible
DISCARD if: no code evidence OR 0/4 votes
  OR duplicates existing finding
  Every discard logged with reason.
```

## Stop Conditions
```
STOP when FIRST of:
  - All OWASP + STRIDE categories tested
  - max_iterations reached
  - 3 consecutive boundaries produce 0 findings
    AND coverage >80%
  - >5 discards with no actionable replacements
```

## Error Recovery
```
IF category produces no findings after analysis:
  log NO_FINDING with justification, move on
IF scanning tool fails:
  retry once, then fall back to manual review
IF finding cannot be reproduced:
  downgrade to INFO, tag UNVERIFIED
  Max 2 re-verification attempts
```

## Output Format
Print: `Secure: OWASP {N}/10, STRIDE {N}/6. {findings} findings. {kept} kept, {discarded} discarded. Status: {DONE|PARTIAL}.`
