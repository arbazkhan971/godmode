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

### Step 4: Red Team Personas
Four adversarial personas attempt to break the system:

#### Persona 1: Script Kiddie
Uses automated tools and known exploits.
```
Attacks:
- SQL injection on all input fields
- XSS payloads in text inputs: <script>alert(1)</script>
- Directory traversal: ../../etc/passwd
- Default credentials: admin/admin, root/root
- Known CVEs in dependencies
```

#### Persona 2: Insider Threat
An authenticated user trying to escalate privileges.
```
Attacks:
- Access other users' data by changing IDs in URLs
- Modify request body to include admin-only fields
- Replay requests with modified tokens
- Access internal/admin endpoints
- Export more data than authorized
```

#### Persona 3: Sophisticated Attacker
Targets application logic and business rules.
```
Attacks:
- Race conditions (double-spend, double-booking)
- Business logic bypass (negative quantities, price manipulation)
- Token/session management flaws
- API abuse through automation
- Chained vulnerabilities (combine low-severity issues)
```

#### Persona 4: Data Harvester
Targets data exfiltration and privacy violations.
```
Attacks:
- Enumerate user accounts via error messages
- Extract data through timing side channels
- Abuse search/filter to extract unauthorized data
- Monitor error messages for data leakage
- Exploit verbose API responses
```

### Step 5: Findings Report

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

### Step 6: Security Report

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
│                                                        │
│  OWASP Top 10:                                         │
│  A01: ✓  A02: ✓  A03: ✗  A04: ✓  A05: ✓              │
│  A06: ✓  A07: ✓  A08: ✓  A09: ✗  A10: N/A            │
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

Verdicts:
- **PASS**: No CRITICAL or HIGH findings
- **CONDITIONAL PASS**: No CRITICAL, but HIGH findings with accepted risk
- **FAIL**: Any CRITICAL finding, or multiple unmitigated HIGH findings

### Step 7: Commit and Transition
1. Save report as `docs/security/<feature>-security-audit.md`
2. Commit: `"secure: <feature> — <verdict> (<N> findings)"`
3. If FAIL: "Critical vulnerabilities found. Run `/godmode:fix` to remediate, then re-audit with `/godmode:secure`."
4. If PASS/CONDITIONAL PASS: "Security audit passed. Ready for `/godmode:ship`."

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
| (none) | Full STRIDE + OWASP + Red Team audit |
| `--quick` | OWASP Top 10 only, skip red team |
| `--stride` | STRIDE analysis only |
| `--owasp` | OWASP Top 10 only |
| `--red-team` | Red team simulation only |
| `--deps` | Dependency vulnerability audit only |
| `--fix` | Auto-fix findings after audit (invokes /godmode:fix) |

## Anti-Patterns

- **Do NOT report theoretical vulnerabilities.** "SQL injection is possible if input isn't sanitized" — IS the input sanitized or not? Check the code.
- **Do NOT inflate severity.** A missing CSRF token on a read-only endpoint is not CRITICAL. Be honest.
- **Do NOT skip dependency checks.** The most common real-world exploits come through dependencies, not application code.
- **Do NOT provide generic remediation.** "Sanitize user input" is not remediation. Show the exact code change.
- **Do NOT treat the STRIDE checklist as exhaustive.** It's a starting framework. The red team personas catch what checklists miss.
- **Do NOT audit code you haven't read.** Skim the code first to understand the architecture, THEN apply the frameworks.
