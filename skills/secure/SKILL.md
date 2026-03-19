---
name: secure
description: |
  Security audit skill. Activates when code needs security review before shipping or when user wants to identify vulnerabilities. Uses STRIDE threat modeling and OWASP Top 10, plus 4 red-team personas. Every finding has code evidence, severity rating, and remediation steps. Triggers on: /godmode:secure, "security audit", "is this secure?", "find vulnerabilities", or as pre-ship check.
---

# Secure — Security Audit

## When to Activate
- User invokes `/godmode:secure`
- User says "is this secure?", "security review", "find vulnerabilities"
- Pre-ship check during `/godmode:ship` workflow
- After handling user input, authentication, or sensitive data
- When integrating with external services or APIs

## Workflow

### HARD RULE: Autonomous Iteration Loop

```
DO NOT stop after finding one issue. You MUST loop through ALL vulnerability categories.

LOOP:
  1. Pick next untested attack vector
  2. Test it with code evidence (file:line + exploit scenario)
  3. Log finding to .godmode/security-findings.tsv
     Format: timestamp \t severity \t category \t file:line \t description \t status
  4. If more vectors remain → GOTO 1
  5. If all vectors tested → print summary

Every 5 iterations, print OWASP coverage tracker:
  OWASP COVERAGE: X/10 tested (XX%)
  Remaining: A0X, A0Y, ...

This loop is NON-NEGOTIABLE. You audit EVERYTHING or you audit NOTHING.
```

### Step 1: Define Audit Scope
Determine what code to audit:

```
AUDIT SCOPE:
Target: <feature/module/entire project>
Files in scope: <list of files/directories>
Sensitive areas:
  - Authentication: <files handling auth>
  - Authorization: <files handling permissions>
  - User input: <files accepting external input>
  - Data storage: <files writing to database/disk>
  - External APIs: <files calling external services>
  - Secrets: <files that might contain or reference secrets>
```

### Step 2: STRIDE Threat Analysis
Analyze each sensitive area using the STRIDE framework:

#### S — Spoofing (Identity)
Can an attacker pretend to be someone else?
```
CHECK:
- [ ] Authentication tokens are validated on every request
- [ ] Session tokens are cryptographically random
- [ ] Passwords are hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Multi-factor authentication available for sensitive operations
- [ ] OAuth state parameter prevents CSRF on login
- [ ] JWT tokens have appropriate expiry
```

#### T — Tampering (Data Integrity)
Can an attacker modify data they shouldn't?
```
CHECK:
- [ ] Input validation on all user-supplied data
- [ ] Database queries use parameterized queries (no string concatenation)
- [ ] File uploads validated (type, size, content)
- [ ] API responses don't include more data than necessary
- [ ] Cryptographic signatures on sensitive data in transit
- [ ] Database constraints enforce data integrity
```

#### R — Repudiation (Accountability)
Can an attacker perform actions without being traced?
```
CHECK:
- [ ] Security-relevant actions are logged (login, permission changes, data access)
- [ ] Logs include: who, what, when, where, result
- [ ] Logs are tamper-resistant (append-only, separate storage)
- [ ] User sessions are tracked and auditable
- [ ] Admin actions have audit trail
```

#### I — Information Disclosure
Can an attacker access data they shouldn't see?
```
CHECK:
- [ ] Error messages don't leak stack traces, SQL, or internal paths
- [ ] API responses don't include internal IDs or system info
- [ ] Logs don't contain passwords, tokens, or PII
- [ ] Database queries don't return columns user shouldn't see
- [ ] Directory listing disabled on file servers
- [ ] .env files excluded from version control
- [ ] HTTPS enforced for all endpoints
```

#### D — Denial of Service
Can an attacker make the system unavailable?
```
CHECK:
- [ ] Rate limiting on all public endpoints
- [ ] Request size limits enforced
- [ ] Pagination on list endpoints (no unbounded queries)
- [ ] Timeouts on all external service calls
- [ ] Resource limits (CPU, memory, file descriptors)
- [ ] No ReDoS vulnerable regex patterns
```

#### E — Elevation of Privilege
Can an attacker gain unauthorized access?
```
CHECK:
- [ ] Authorization checked on every endpoint (not just authentication)
- [ ] Admin endpoints have separate authorization
- [ ] No mass assignment vulnerabilities (accepting arbitrary fields)
- [ ] File upload paths can't traverse directories (../../etc/passwd)
- [ ] SQL injection, command injection, template injection prevented
- [ ] Insecure deserialization prevented
```

### Step 3: OWASP Top 10 Check
Cross-reference against the OWASP Top 10 (2021):

```
OWASP TOP 10 ASSESSMENT:
[ ] A01: Broken Access Control
[ ] A02: Cryptographic Failures
[ ] A03: Injection
[ ] A04: Insecure Design
[ ] A05: Security Misconfiguration
[ ] A06: Vulnerable Components
[ ] A07: Authentication Failures
[ ] A08: Software & Data Integrity Failures
[ ] A09: Security Logging Failures
[ ] A10: Server-Side Request Forgery (SSRF)
```

For each applicable item, provide:
```
<OWASP ID>: <Status: PASS | FAIL | N/A>
Evidence: <specific code reference or finding>
```

### Step 4: Red Team — 4 Adversarial Personas

Attack the system from four distinct threat actor perspectives. Each persona has different access levels, motivations, and techniques. ALL four personas MUST be run — do not skip any.

#### Persona 1: External Attacker (Unauthenticated)
Zero access. Attempting to breach from the outside.
```
Motivation: Initial access, data theft, disruption
Access level: None — public endpoints only
Attacks:
- SQL injection on all input fields (login, search, registration, API params)
- XSS payloads in text inputs: <script>alert(1)</script>, event handlers, SVG
- Directory traversal: ../../etc/passwd, ..%2f..%2f
- Default credentials: admin/admin, root/root, test/test
- Known CVEs in dependencies (check npm audit / pip audit / go vuln)
- Subdomain/endpoint enumeration
- Abuse of public APIs without authentication
- SSRF via URL parameters (internal metadata endpoints)
- HTTP verb tampering (GET vs POST vs PUT on same endpoint)
- Header injection (Host header, X-Forwarded-For spoofing)
```

#### Persona 2: Malicious Insider (Authenticated User)
Valid account. Attempting to escalate privileges and access unauthorized data.
```
Motivation: Privilege escalation, unauthorized data access, sabotage
Access level: Standard authenticated user
Attacks:
- IDOR: Access other users' data by changing IDs in URLs/request bodies
- Mass assignment: Modify request body to include admin-only fields (role, isAdmin)
- Replay attacks: Capture and replay requests with modified tokens/parameters
- Horizontal privilege escalation: Access peer users' resources
- Vertical privilege escalation: Access admin endpoints with user token
- Export more data than authorized (pagination bypass, bulk export abuse)
- Token manipulation: Modify JWT claims, extend expiry, forge tokens
- Account takeover: Password reset flow abuse, email change without verification
- Rate limit bypass: Distributed requests, header manipulation
```

#### Persona 3: Supply Chain Attacker (Dependency Compromise)
Targeting the software supply chain — dependencies, build tools, CI/CD.
```
Motivation: Backdoor insertion, credential harvesting, persistent access
Access level: Code execution via compromised dependency
Attacks:
- Dependency confusion (typosquatting, namespace hijacking)
- Known vulnerable dependencies (check ALL transitive deps, not just direct)
- Post-install scripts that execute arbitrary code
- Prototype pollution via deep-merge dependencies
- Malicious updates to previously trusted packages
- Lock file manipulation (shrinkwrap, lock file integrity)
- Build tool compromise (Webpack plugins, Babel transforms, PostCSS)
- CI/CD pipeline injection (GitHub Actions, env var exfiltration)
- Docker base image vulnerabilities
- Outdated/unmaintained dependencies with known CVEs
```

#### Persona 4: Infrastructure Attacker (Network/Cloud Access)
Targeting infrastructure, deployment, and cloud configuration.
```
Motivation: Persistent access, lateral movement, data exfiltration at scale
Access level: Network adjacency or compromised cloud credentials
Attacks:
- Cloud misconfigurations (open S3 buckets, overly permissive IAM roles)
- Exposed admin panels, debug endpoints, health checks leaking info
- Database exposed to public internet (no VPC, default ports)
- Secrets in environment variables accessible via SSRF or log leaks
- Container escape (privileged containers, mounted docker socket)
- Kubernetes misconfigurations (default service accounts, RBAC bypass)
- DNS rebinding to access internal services
- TLS/SSL misconfigurations (weak ciphers, expired certs, no HSTS)
- Log injection leading to log forging or SIEM evasion
- Backup files exposed (.bak, .sql, .env.backup)
```

### Step 5: OWASP Top 10 Coverage Tracker

Maintain a running coverage tracker throughout the audit. Print this every 5 iterations of the loop, and at the end of the audit.

```
OWASP TOP 10 COVERAGE TRACKER:
┌──────┬──────────────────────────────────────┬────────┬──────────┐
│  ID  │ Category                             │ Status │ Findings │
├──────┼──────────────────────────────────────┼────────┼──────────┤
│ A01  │ Broken Access Control                │ TESTED │ 2        │
│ A02  │ Cryptographic Failures               │ TESTED │ 1        │
│ A03  │ Injection                            │ TESTED │ 0        │
│ A04  │ Insecure Design                      │ PENDING│ -        │
│ A05  │ Security Misconfiguration            │ TESTED │ 3        │
│ A06  │ Vulnerable Components                │ TESTED │ 1        │
│ A07  │ Authentication Failures              │ PENDING│ -        │
│ A08  │ Software & Data Integrity Failures   │ N/A    │ -        │
│ A09  │ Security Logging Failures            │ TESTED │ 0        │
│ A10  │ Server-Side Request Forgery (SSRF)   │ TESTED │ 0        │
├──────┼──────────────────────────────────────┼────────┼──────────┤
│      │ Coverage: 8/10 (80%)                 │        │          │
│      │ Remaining: A04, A07                  │        │          │
└──────┴──────────────────────────────────────┴────────┴──────────┘
```

Target: 100% coverage. Every applicable OWASP category MUST be tested before the audit is considered complete.

### Step 6: Findings Report

For each vulnerability found:
```
### FINDING <N>: <Title>
**Severity:** CRITICAL | HIGH | MEDIUM | LOW | INFO
**Category:** <STRIDE letter> — <OWASP ID>
**Location:** <file:line>
**Evidence:**
```<language>
// The vulnerable code
<actual code from the codebase>
```

**Attack scenario:**
<How an attacker would exploit this>

**Impact:**
<What damage could result>

**Remediation:**
```<language>
// The fixed code
<corrected version>
```

**Verification:**
<How to confirm the fix works — test or command>
```

### Step 7: Security Report + Composite Metric

```
┌────────────────────────────────────────────────────────┐
│  SECURITY AUDIT — <target>                             │
├────────────────────────────────────────────────────────┤
│  Findings:                                             │
│  CRITICAL: <N>                                         │
│  HIGH:     <N>                                         │
│  MEDIUM:   <N>                                         │
│  LOW:      <N>                                         │
│  INFO:     <N>                                         │
│                                                        │
│  STRIDE Coverage:                                      │
│  S: ✓  T: ✓  R: ✓  I: ✗  D: ✓  E: ✓                 │
│  STRIDE tested: <N>/6                                  │
│                                                        │
│  OWASP Top 10:                                         │
│  A01: ✓  A02: ✓  A03: ✗  A04: ✓  A05: ✓              │
│  A06: ✓  A07: ✓  A08: ✓  A09: ✗  A10: N/A            │
│  OWASP tested: <N>/10                                  │
│                                                        │
│  COMPOSITE SCORE:                                      │
│  (owasp_tested/10)*50 + (stride_tested/6)*30           │
│    + min(findings, 20)                                 │
│  = (<N>/10)*50 + (<N>/6)*30 + min(<N>, 20)             │
│  = <SCORE> / 100                                       │
│                                                        │
│  Verdict: <PASS | CONDITIONAL PASS | FAIL>             │
├────────────────────────────────────────────────────────┤
│  MUST FIX before shipping:                             │
│  1. <CRITICAL/HIGH finding>                            │
│  2. <CRITICAL/HIGH finding>                            │
│                                                        │
│  SHOULD FIX:                                           │
│  3. <MEDIUM finding>                                   │
│  4. <MEDIUM finding>                                   │
└────────────────────────────────────────────────────────┘
```

**Composite Metric Explained:**
```
AUDIT_SCORE = (owasp_tested / 10) * 50
            + (stride_tested / 6) * 30
            + min(total_findings, 20)

- OWASP coverage (50 pts max): Rewards breadth of OWASP testing
- STRIDE coverage (30 pts max): Rewards breadth of threat modeling
- Findings discovered (20 pts max): Rewards thoroughness (finding issues = good auditing)

Interpretation:
  90-100: Exhaustive audit — high confidence in security posture
  70-89:  Solid audit — most vectors covered
  50-69:  Partial audit — significant gaps remain
  <50:    Incomplete audit — re-run with broader scope
```

Verdicts:
- **PASS**: No CRITICAL or HIGH findings, composite score >= 70
- **CONDITIONAL PASS**: No CRITICAL, but HIGH findings with accepted risk, composite score >= 50
- **FAIL**: Any CRITICAL finding, multiple unmitigated HIGH findings, or composite score < 50

### Step 8: Auto-Fix Mode

When `--fix` flag is used, or when the user requests auto-fix after audit, automatically remediate Critical and High findings.

```
AUTO-FIX LOOP (Critical and High findings only):

For each finding with severity CRITICAL or HIGH:
  1. Read the vulnerable code at file:line
  2. Apply the remediation code from the finding
  3. Run relevant tests to confirm fix doesn't break anything
  4. If tests pass:
     - git commit: "secure-fix: <finding title> [<severity>]"
     - Mark finding as FIXED in .godmode/security-findings.tsv
     - Log fix to .godmode/security-fixes.tsv
  5. If tests fail:
     - Revert the change
     - Mark finding as MANUAL_FIX_REQUIRED
     - Log failure reason
  6. Move to next finding

After all auto-fixes:
  FIXED: <N> findings automatically remediated
  MANUAL_FIX_REQUIRED: <N> findings need manual intervention
  REMAINING: <N> MEDIUM/LOW/INFO findings (not auto-fixed)

  Re-run audit? (recommended after fixes to verify no regressions)
```

IMPORTANT: Auto-fix ONLY applies to Critical and High severity findings. Medium/Low/Info findings are reported but not auto-fixed — they require human judgment.

### Step 9: Commit and Transition
1. Save report as `docs/security/<feature>-security-audit.md`
2. Save findings log to `.godmode/security-findings.tsv`
3. Commit: `"secure: <feature> — <verdict> (<N> findings, score <SCORE>/100)"`
4. If FAIL: "Critical vulnerabilities found. Run `/godmode:secure --fix` to auto-remediate, or `/godmode:fix` for manual remediation, then re-audit with `/godmode:secure`."
5. If PASS/CONDITIONAL PASS: "Security audit passed (score <SCORE>/100). Ready for `/godmode:ship`."

## Key Behaviors

1. **Code evidence required.** Every finding must reference actual code in the project. No theoretical vulnerabilities.
2. **Severity must be justified.** CRITICAL means "exploitable right now with high impact." Don't inflation-rate.
3. **Remediation must be concrete.** Show the fixed code, not "add input validation." SHOW the validation code.
4. **Check dependencies.** Run `npm audit` / `pip audit` / equivalent. Vulnerable dependencies are real vulnerabilities.
5. **Don't skip the red team.** The STRIDE checklist catches known patterns. The red team catches creative attacks.
6. **Test the fixes.** Every remediation should include a way to verify it works — a test or a command.

## Example Usage

### Auditing an API
```
User: /godmode:secure Audit the authentication system

Secure: Defining scope...

AUDIT SCOPE:
Target: Authentication system
Files: src/middleware/auth.ts, src/controllers/auth.ts,
       src/services/token.ts, src/models/user.ts

Running STRIDE analysis...
Running OWASP Top 10 check...
Running Red Team simulations...

FINDING 1: JWT Secret Hardcoded
Severity: CRITICAL
Category: I — Information Disclosure / A02: Cryptographic Failures
Location: src/services/token.ts:3
Evidence:
```typescript
const JWT_SECRET = "super-secret-key-123";  // HARDCODED
```
Remediation:
```typescript
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error('JWT_SECRET not configured');
```
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full STRIDE + OWASP + Red Team audit with autonomous loop |
| `--quick` | OWASP Top 10 only, skip red team |
| `--stride` | STRIDE analysis only |
| `--owasp` | OWASP Top 10 only |
| `--red-team` | Red team simulation only |
| `--deps` | Dependency vulnerability audit only |
| `--fix` | Auto-fix Critical/High findings after audit |
| `--persona <N>` | Run only a specific red team persona (1-4) |
| `--coverage` | Print OWASP/STRIDE coverage tracker and composite score only |

## Anti-Patterns

- **Do NOT report theoretical vulnerabilities.** "SQL injection is possible if input isn't sanitized" — IS the input sanitized or not? Check the code.
- **Do NOT inflate severity.** A missing CSRF token on a read-only endpoint is not CRITICAL. Be honest.
- **Do NOT skip dependency checks.** The most common real-world exploits come through dependencies, not application code.
- **Do NOT provide generic remediation.** "Sanitize user input" is not remediation. Show the exact code change.
- **Do NOT treat the STRIDE checklist as exhaustive.** It's a starting framework. The red team personas catch what checklists miss.
- **Do NOT audit code you haven't read.** Skim the code first to understand the architecture, THEN apply the frameworks.
