---
name: secure
description: Security audit. STRIDE + OWASP + 4 red-team personas. Code evidence required.
---

## Activate When
- `/godmode:secure`, "security audit", "vulnerabilities", "harden"

## Workflow
1. **Recon** — `npm audit`/`pip audit`/`cargo audit` for CVEs, `grep -rn 'SECRET\|API_KEY\|PASSWORD'` for secrets, scan routes.
2. **Asset Map** — List each: DB (type+version), auth (JWT/session/OAuth+expiry), external APIs, all `<input>`/`<form>`, public routes.
3. **Trust Boundaries** — Draw: client↔server, public↔auth, user↔admin, svc↔svc, CI↔prod, internal↔external. Each = attack surface.
4. **STRIDE** — For each boundary: Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation.
5. **Iterate:**
```
categories = OWASP_TOP_10 + STRIDE  # 16 total
current_iteration = 0
WHILE untested categories remain:
    current_iteration += 1
    Pick untested category. Priority: Injection > Broken Auth > XSS > SSRF > IDOR > remaining.
    Test as 4 personas: External (no auth), Insider (valid session), Supply Chain (malicious dep), Infra (server access).
    Each finding: file:line + exploit steps + severity (Critical/High/Med/Low) + fix (code snippet).
    Log to .godmode/security-findings.tsv: iteration, category, persona, finding, severity, file:line, status(open/fixed).
    Every 5 iters: print "{tested}/10 OWASP, {findings} findings"
```
6. **Report** — OWASP: {N}/10, STRIDE: {N}/6. `{critical}C {high}H {med}M {low}L`. PASS if 0 critical + 0 high. Else FAIL.
7. **Auto-Fix** (if `--fix`) — For Critical/High: fix → commit → run full test suite → revert if ANY test breaks.

## STRIDE Threat Model Loop

```
boundaries = list_trust_boundaries()   # from Step 3
stride_categories = [Spoofing, Tampering, Repudiation, InfoDisclosure, DoS, Elevation]
current_boundary = 0
max_iterations = len(boundaries) * 6   # one pass per boundary × category

WHILE current_boundary < len(boundaries) AND iteration < max_iterations:
    boundary = boundaries[current_boundary]
    FOR category IN stride_categories:
        threat = analyze(boundary, category)
        IF threat.has_evidence:
            KEEP — log to findings with SEVERITY|FILE:LINE|DESCRIPTION|FIX
        ELSE:
            DISCARD — record "no finding" with justification in audit trail
    current_boundary += 1
    REPORT: "{current_boundary}/{len(boundaries)} boundaries analyzed, {findings_count} threats found"

STOP CONDITIONS:
  - All trust boundaries × all 6 STRIDE categories tested
  - OR max_iterations reached (hard cap)
  - OR 3 consecutive boundaries produce zero findings AND coverage > 80%
```

## Red-Team Persona Voting Protocol

```
PERSONAS:
  P1: External Attacker — no credentials, public endpoints only
  P2: Malicious Insider — valid session, standard user role
  P3: Supply Chain Attacker — compromised dependency or build artifact
  P4: Infrastructure Attacker — server/container access, lateral movement

FOR each finding candidate:
  1. Each persona independently rates: EXPLOITABLE (1) or NOT_EXPLOITABLE (0)
  2. Tally votes: score = sum of persona ratings (0–4)
  3. Decision:
     - 4/4 votes: CRITICAL — unanimous exploitability
     - 3/4 votes: HIGH — likely exploitable
     - 2/4 votes: MEDIUM — conditionally exploitable
     - 1/4 votes: LOW — edge case only
     - 0/4 votes: DISCARD — theoretical, no evidence from any persona
  4. Log: finding_id | P1_vote | P2_vote | P3_vote | P4_vote | final_severity
  5. Findings with 0 votes are DISCARDED with justification — never silently dropped
```

## Findings Format

Every confirmed finding MUST use this exact format:
```
SEVERITY|FILE:LINE|DESCRIPTION|FIX
```

Examples:
```
CRITICAL|src/api/auth.ts:42|SQL injection in login query via unsanitized email parameter|Use parameterized query: db.query('SELECT * FROM users WHERE email = $1', [email])
HIGH|src/middleware/cors.ts:8|CORS allows any origin via wildcard Access-Control-Allow-Origin|Set explicit allowed origins: ['https://app.example.com']
MEDIUM|src/utils/crypto.ts:15|Math.random() used for session token generation|Use crypto.randomBytes(32).toString('hex')
LOW|src/controllers/user.ts:88|User enumeration via different error messages for valid/invalid emails|Return generic "Invalid credentials" for both cases
```

## Keep/Discard Discipline

```
FOR each potential finding:
  KEEP if:
    - File:line evidence exists (not theoretical)
    - At least 1 red-team persona rates it EXPLOITABLE
    - Exploit steps are reproducible
    - Severity is backed by CVSS-like impact assessment
  DISCARD if:
    - No code evidence (pure speculation)
    - All 4 personas rate NOT_EXPLOITABLE
    - Finding duplicates an already-logged issue
    - Finding is in test/mock/fixture code with no prod exposure
  RECORD: Every discard logged with reason to .godmode/security-discards.tsv
```

## TSV Logging

Log all findings to `.godmode/security-findings.tsv`:
```
iteration	category	persona	severity	file_line	description	fix	status	p1_vote	p2_vote	p3_vote	p4_vote
```

Log discards to `.godmode/security-discards.tsv`:
```
iteration	category	persona	candidate_description	discard_reason
```

Append one row per finding/discard. Never overwrite previous rows.

## Success Criteria

```
PASS if ALL of the following:
  - All OWASP Top 10 categories tested (10/10)
  - All 6 STRIDE categories evaluated per trust boundary
  - All 4 personas exercised per finding
  - Zero CRITICAL findings remain open
  - Zero HIGH findings remain open
  - Every finding has SEVERITY|FILE:LINE|DESCRIPTION|FIX format
  - Every finding has reproducible exploit steps or proof
  - Persona voting recorded for every finding

FAIL if ANY of the following:
  - Any CRITICAL finding remains open
  - Any HIGH finding has no remediation plan
  - OWASP coverage < 8/10 categories
  - STRIDE coverage < 4/6 categories per boundary
  - Any finding lacks file:line evidence
```

## Error Recovery

```
IF a test category produces no actionable findings after full analysis:
  1. Log "NO_FINDING" with justification (not a silent skip)
  2. Move to next category — do not retry the same category
  3. Max 2 re-analysis attempts per category if tooling errors occur

IF automated scanning tool fails (npm audit, grep, etc.):
  1. Retry once with increased timeout
  2. If retry fails: fall back to manual code review for that category
  3. Log tool failure to .godmode/security-errors.tsv
  4. Max 3 retries per tool across the entire audit

IF a finding cannot be verified (no reproducible exploit):
  1. Downgrade to INFO and tag as UNVERIFIED
  2. Do not count toward CRITICAL/HIGH totals
  3. Log with reason: "unable to reproduce — requires [condition]"
  4. Re-attempt verification after other findings are processed (max 2 retries)

IF audit exceeds max_iterations without full coverage:
  1. STOP — do not continue indefinitely
  2. Report partial coverage: "{tested}/{total} categories, {findings} findings"
  3. Flag untested categories as INCOMPLETE in the report
  4. Recommend follow-up audit for uncovered areas
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: all OWASP Top 10 + all STRIDE categories tested across all boundaries
  - budget_exhausted: max_iterations reached (hard cap)
  - diminishing_returns: 3 consecutive boundaries produce zero findings AND coverage > 80%
  - stuck: >5 discarded findings with no actionable replacements
```

## Output Format
Print: `Skill: OWASP {tested}/10, STRIDE {tested}/6. {before} findings → {after} confirmed ({delta}%). {kept} kept, {discarded} discarded. Status: {DONE|PARTIAL}.`

## Hard Rules
1. Every finding requires file:line + exploit steps + proof (curl, test case, or code path).
2. Cover all OWASP Top 10 x 4 personas = 40 test cases minimum. Real payloads only.
3. Never approve with Critical findings open. Critical+High count in final verdict.
4. Findings without code evidence from any persona = DISCARD with justification.
5. Auto-fix (if `--fix`) must run full test suite after each fix — revert if ANY test breaks.

## Rules
1. Every finding: file:line + exploit steps + proof (curl command, test case, or code path). No theoretical risks.
2. Cover all OWASP Top 10 × 4 personas = 40 test cases minimum. Use real payloads. Critical/High before Med/Low.
3. Never approve with Critical findings. Critical+High count printed in final verdict.
