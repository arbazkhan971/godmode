# Recipe: Securing Your Application

> From "we should probably look at security" to "audit-ready." A complete Godmode workflow for security hardening, vulnerability remediation, and compliance certification.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `secure → devsecops → pentest → crypto → comply → fix → verify` |
| **Timeline** | 1-2 weeks for full audit and remediation |
| **Team size** | 1-3 engineers + security reviewer |
| **Example project** | "HealthTrack" — a health data platform preparing for HIPAA compliance audit |

---

## The Scenario

HealthTrack is a health data platform:
- Node.js/Express API + React frontend + PostgreSQL
- Handles patient health records (PHI — Protected Health Information)
- Processing Stripe payments for subscriptions
- Preparing for SOC 2 Type II and HIPAA compliance audits in 60 days
- No prior formal security review
- 3-person engineering team

---

## Phase 1: Security Audit (Day 1-3)

### Step 1: Secure — Full Security Audit

```
> /godmode:secure

Godmode: Running comprehensive security audit...

SECURITY AUDIT: HealthTrack

════════════════════
STRIDE THREAT MODEL
════════════════════

Spoofing (Identity):
  ✓ PASS — JWT auth on all API routes
  ⚠ WARN — No MFA for admin accounts
  ✗ FAIL — Password reset token does not expire (valid forever)

Tampering (Data Integrity):
  ✓ PASS — Parameterized queries (Prisma ORM)
  ✓ PASS — Request body validation (zod schemas)
  ✗ FAIL — No audit log for data modifications
  ✗ FAIL — API accepts additional unexpected fields (mass assignment)

Repudiation (Deniability):
  ✗ FAIL — No audit trail for who accessed patient records
  ✗ FAIL — No immutable logging (logs can be deleted by admin)
  ⚠ WARN — Timestamp not from trusted source (client-supplied)

Information Disclosure:
  ✗ FAIL — Error responses include stack traces in production
  ✗ FAIL — Patient data returned in search results without access check
  ⚠ WARN — API response includes internal database IDs
  ✗ FAIL — No field-level encryption for SSN and DOB

Denial of Service:
  ⚠ WARN — No rate limiting on authentication endpoints
  ✓ PASS — Database connection pooling configured
  ⚠ WARN — File upload has no size limit

Elevation of Privilege:
  ✗ FAIL — Admin role check only on frontend (not enforced in API)
  ✗ FAIL — JWT secret is "supersecret123" (hardcoded in source)
  ✗ FAIL — No RBAC — all authenticated users can access all records

════════════════════
OWASP TOP 10 ANALYSIS
════════════════════

A01 Broken Access Control:        FAIL (3 findings)
  - No RBAC enforcement on API layer
  - Patient records accessible without ownership check
  - Admin functions not protected server-side

A02 Cryptographic Failures:       FAIL (4 findings)
  - JWT secret hardcoded in source code
  - No encryption at rest for PHI
  - Password hashing uses MD5 (not bcrypt/argon2)
  - No TLS certificate pinning for mobile app

A03 Injection:                    PASS
  - Prisma ORM prevents SQL injection
  - Input validation on all endpoints

A04 Insecure Design:              WARN (2 findings)
  - No security architecture documentation
  - No threat model maintained

A05 Security Misconfiguration:    FAIL (3 findings)
  - Debug mode enabled in production
  - Default CORS (allow all origins)
  - HTTP headers missing (HSTS, CSP, X-Frame-Options)

A06 Vulnerable Components:        WARN (2 findings)
  - 7 npm packages with known CVEs
  - No automated dependency scanning in CI

A07 Authentication Failures:      FAIL (3 findings)
  - No rate limiting on login endpoint
  - No account lockout after failed attempts
  - No password complexity requirements

A08 Software/Data Integrity:      WARN (1 finding)
  - No integrity verification on npm packages (no lock file check)

A09 Logging/Monitoring Failures:  FAIL (3 findings)
  - No security event logging
  - No intrusion detection
  - No access logging for PHI

A10 SSRF:                         PASS
  - No user-supplied URLs processed server-side

════════════════════
RED TEAM SIMULATION
════════════════════

Attack 1: Authentication Bypass
  Vector: Brute-force login (no rate limiting)
  Difficulty: LOW
  Impact: CRITICAL — full account takeover

Attack 2: Privilege Escalation
  Vector: Change role in JWT payload (weak secret easily cracked)
  Difficulty: LOW
  Impact: CRITICAL — admin access to all patient records

Attack 3: Data Exfiltration
  Vector: Enumerate patient IDs via sequential database IDs
  Difficulty: LOW
  Impact: CRITICAL — bulk download of patient records

Attack 4: Session Hijacking
  Vector: XSS via missing CSP headers → steal JWT from localStorage
  Difficulty: MEDIUM
  Impact: HIGH — session takeover

════════════════════
SUMMARY
════════════════════

  CRITICAL:  5 findings
  HIGH:      7 findings
  MEDIUM:    6 findings
  LOW:       4 findings

  Verdict: FAIL — System is not safe for production with health data.
  CRITICAL findings must be fixed before any patient data is processed.

Saved: docs/security/healthtrack-audit.md
```

### Step 2: DevSecOps — Security Pipeline Setup

```
> /godmode:devsecops

Godmode: Configuring security pipeline...

DEVSECOPS PIPELINE:

1. Pre-commit hooks:
   File: .husky/pre-commit
   - gitleaks: scan for secrets/credentials in staged files
   - npm audit: check for vulnerable dependencies

2. CI pipeline security checks:
   File: .github/workflows/security.yml
   Jobs:
     - SAST (Static Analysis): Semgrep with OWASP rules
     - SCA (Software Composition): npm audit + Snyk
     - Secret scanning: gitleaks + trufflehog
     - Container scanning: Trivy for Docker image vulnerabilities
     - License compliance: check for GPL/AGPL in dependencies
     - DAST (Dynamic Analysis): OWASP ZAP baseline scan on staging

3. Dependency management:
   File: .github/dependabot.yml
   - Automated PRs for security updates
   - Weekly non-security update PRs

4. Security policy:
   File: SECURITY.md
   - Responsible disclosure process
   - Security contact email
   - Bug bounty information (if applicable)

Commit: "ci: add security pipeline — SAST, SCA, secrets, container scanning"
```

### Step 3: PenTest — Automated Penetration Testing

```
> /godmode:pentest

Godmode: Running automated penetration tests...

PENETRATION TEST RESULTS:

Authentication tests:
  ✗ FAIL — Login brute force: 10,000 attempts in 60 seconds (no rate limit)
  ✗ FAIL — Password reset: token valid indefinitely, no single-use enforcement
  ✗ FAIL — JWT: secret cracked in < 1 second (dictionary attack)
  ✓ PASS — Session: tokens properly invalidated on logout
  ✗ FAIL — No CSRF protection on state-changing endpoints

Authorization tests:
  ✗ FAIL — IDOR: Can access /api/patients/123 with any authenticated token
  ✗ FAIL — Privilege escalation: regular user can call /api/admin/* endpoints
  ✗ FAIL — Mass assignment: POST /api/users accepts {"role": "admin"}

Input validation tests:
  ✓ PASS — SQL injection: Prisma prevents all tested vectors
  ✓ PASS — NoSQL injection: N/A (PostgreSQL only)
  ⚠ WARN — XSS: React auto-escapes, but dangerouslySetInnerHTML found in 2 components
  ✗ FAIL — File upload: No type validation, can upload .exe as profile photo
  ✓ PASS — Path traversal: Prevented by framework

Infrastructure tests:
  ✗ FAIL — HTTP (no redirect to HTTPS) on staging
  ✗ FAIL — Missing security headers (HSTS, CSP, X-Content-Type-Options)
  ✓ PASS — TLS 1.2+ enforced on production
  ⚠ WARN — Server version disclosed in headers (Express)

Saved: docs/security/healthtrack-pentest.md
```

### Step 4: Crypto — Cryptographic Review

```
> /godmode:crypto

Godmode: Auditing cryptographic implementations...

CRYPTOGRAPHIC AUDIT:

Password hashing:
  Current: MD5 (unsalted)
  Status: CRITICAL — MD5 is broken, rainbow table attacks trivial
  Fix: Migrate to Argon2id (or bcrypt with cost 12)
  Migration: Add new column password_hash_v2, rehash on next login

JWT signing:
  Current: HS256 with secret "supersecret123"
  Status: CRITICAL — weak secret, symmetric signing
  Fix: Generate 256-bit random secret, store in environment variable
  Consider: RS256 (asymmetric) for microservices scenarios

Data at rest:
  Current: No encryption
  Status: CRITICAL for PHI — HIPAA requires encryption at rest
  Fix: PostgreSQL Transparent Data Encryption (TDE) or
       application-level field encryption for SSN, DOB, diagnosis

Data in transit:
  Current: TLS 1.2 on production, HTTP on staging
  Status: WARN — staging should also use TLS
  Fix: Enforce TLS everywhere, add HSTS header

Token generation:
  Current: Math.random() for reset tokens
  Status: HIGH — predictable tokens, attackable
  Fix: crypto.randomBytes(32).toString('hex')

Saved: docs/security/healthtrack-crypto-audit.md
```

---

## Phase 2: Compliance Assessment (Day 3-5)

### Step 5: Comply — HIPAA and SOC 2 Assessment

```
> /godmode:comply --frameworks hipaa,soc2

Godmode: Running compliance assessment...

════════════════════
HIPAA COMPLIANCE ASSESSMENT
════════════════════

Administrative Safeguards (45 CFR 164.308):
  ✗ Security Officer designation: Not documented
  ✗ Risk analysis: No formal risk assessment conducted
  ✗ Workforce training: No security training program
  ⚠ Access management: Basic auth exists, no formal procedures
  ✗ Contingency plan: No disaster recovery plan documented

Physical Safeguards (45 CFR 164.310):
  ✓ Cloud provider (AWS): SOC 2 certified data centers
  ✗ Workstation policies: Not documented
  ⚠ Device management: No MDM for developer laptops

Technical Safeguards (45 CFR 164.312):
  ✗ Access control: No RBAC, no minimum necessary access
  ✗ Audit controls: No PHI access logging
  ✗ Integrity controls: No data integrity verification
  ✗ Transmission security: Missing TLS on staging
  ✗ Encryption: No encryption at rest for PHI

HIPAA Score: 23/100 (NOT COMPLIANT)
Gap: 31 controls need implementation or documentation

════════════════════
SOC 2 TYPE II ASSESSMENT (Trust Service Criteria)
════════════════════

Security (CC6):
  Controls implemented: 8/24 (33%)
  Critical gaps: Access control, encryption, monitoring

Availability (A1):
  Controls implemented: 3/12 (25%)
  Critical gaps: Business continuity, disaster recovery, SLAs

Processing Integrity (PI1):
  Controls implemented: 4/10 (40%)
  Critical gaps: Data validation completeness, error handling

Confidentiality (C1):
  Controls implemented: 2/12 (17%)
  Critical gaps: Data classification, encryption, disposal

Privacy (P1):
  Controls implemented: 5/15 (33%)
  Critical gaps: Consent management, data retention, right to delete

SOC 2 Score: 30/100 (NOT COMPLIANT)
Gap: 44 controls need implementation or documentation

════════════════════
COMPLIANCE REMEDIATION ROADMAP
════════════════════

WEEK 1 (Critical technical fixes):
  1. Implement RBAC with minimum necessary access
  2. Add PHI access audit logging
  3. Encrypt PHI at rest (field-level encryption)
  4. Fix password hashing (MD5 → Argon2id)
  5. Generate proper JWT secret
  6. Add rate limiting and account lockout

WEEK 2 (Security infrastructure):
  7. Implement comprehensive security headers
  8. Add CSRF protection
  9. Set up intrusion detection / SIEM
  10. Configure backup and disaster recovery
  11. Add file upload validation
  12. Fix mass assignment vulnerabilities

WEEK 3 (Policy and documentation):
  13. Designate Security Officer
  14. Write security policies (access control, incident response)
  15. Create Business Continuity Plan
  16. Document data classification scheme
  17. Create employee security training materials
  18. Write privacy policy and consent flows

WEEK 4 (Verification and testing):
  19. Re-run security audit (should now pass)
  20. Conduct tabletop incident response exercise
  21. Perform backup restoration test
  22. Third-party penetration test
  23. Compile SOC 2 evidence package
  24. Schedule auditor engagement

Saved: docs/compliance/hipaa-assessment.md
Saved: docs/compliance/soc2-assessment.md
Saved: docs/compliance/remediation-roadmap.md
```

---

## Phase 3: Fix Everything (Day 5-12)

### Step 6: Fix — Remediate All Findings

Work through findings by severity, starting with CRITICAL:

#### CRITICAL Fixes (Day 5-6)

```
> /godmode:fix --severity critical

Godmode: Remediating 5 CRITICAL findings...

FIX 1: JWT Secret
  Before: const JWT_SECRET = "supersecret123"
  After: const JWT_SECRET = process.env.JWT_SECRET (256-bit random)
  File: src/config/auth.ts
  Test: ✓ JWT signing/verification with new secret

FIX 2: Password Hashing
  Before: MD5 unsalted
  After: Argon2id (time cost 3, memory 64MB, parallelism 4)
  Migration: Dual-read (try Argon2id first, fall back to MD5, rehash on success)
  File: src/services/auth.service.ts
  Test: ✓ Login works with both old and new hashes
  Test: ✓ Old passwords rehashed on login

FIX 3: Role-Based Access Control
  Before: No authorization checks on API
  After: RBAC middleware with roles: patient, provider, admin
  Files:
    src/middleware/rbac.ts              — role checking middleware
    src/middleware/ownership.ts         — resource ownership verification
    src/config/permissions.ts           — role-permission matrix
  Tests: 23 new authorization tests
  Policy: Minimum necessary access (patients see own records only)

FIX 4: PHI Encryption at Rest
  Before: Plaintext SSN, DOB, diagnosis in database
  After: AES-256-GCM field-level encryption
  Files:
    src/utils/encryption.ts            — encrypt/decrypt utilities
    src/middleware/phi-encryption.ts    — automatic PHI field encryption
    migrations/044_add_encrypted_phi.sql
  Key management: AWS KMS (envelope encryption)
  Test: ✓ Encrypted data in DB, decrypted in API response for authorized users

FIX 5: Password Reset Token
  Before: Token never expires, no single-use enforcement
  After: 1-hour expiry, single-use (deleted after use), cryptographically random
  File: src/services/password-reset.service.ts
  Test: ✓ Expired token rejected, used token rejected

Commit: "fix(security): CRITICAL — JWT secret, Argon2id, RBAC, PHI encryption, reset tokens"
```

#### HIGH Fixes (Day 7-8)

```
> /godmode:fix --severity high

Godmode: Remediating 7 HIGH findings...

FIX 6: Rate Limiting
  Added: express-rate-limit on /api/auth/* (5 req/min per IP)
  Added: Account lockout after 10 failed login attempts (30 min cooldown)

FIX 7: Security Headers
  Added: helmet middleware with configuration:
    - HSTS: max-age=31536000, includeSubDomains
    - CSP: strict policy with nonces for inline scripts
    - X-Frame-Options: DENY
    - X-Content-Type-Options: nosniff
    - Referrer-Policy: strict-origin-when-cross-origin

FIX 8: CSRF Protection
  Added: csrf-csrf token middleware for all state-changing requests
  Frontend: Token read from cookie, sent in X-CSRF-Token header

FIX 9: Mass Assignment Prevention
  Added: Explicit allowlist for all create/update operations
  Before: Object.assign(user, req.body) — any field accepted
  After: pick(req.body, ['name', 'email']) — only allowed fields

FIX 10: PHI Access Audit Log
  Added: Immutable audit log for all PHI access
  Table: phi_access_log (user_id, patient_id, action, timestamp, ip_address)
  Storage: Append-only table (no DELETE/UPDATE grants)
  Retention: 6 years (HIPAA requirement)

FIX 11: Error Response Sanitization
  Before: Stack traces in production error responses
  After: Generic error messages in production, detailed in development
  Added: Error correlation IDs for debugging without exposing internals

FIX 12: File Upload Validation
  Added: File type allowlist (JPEG, PNG, PDF only)
  Added: File size limit (10 MB)
  Added: Virus scanning via ClamAV for uploaded files

Commit: "fix(security): HIGH — rate limiting, headers, CSRF, audit log, error sanitization"
```

#### MEDIUM and LOW Fixes (Day 9-10)

```
> /godmode:fix --severity medium,low

Godmode: Remediating 10 MEDIUM and LOW findings...

[fixes MFA for admins, removes debug mode, fixes CORS, adds dependency
scanning, removes server version header, fixes XSS in 2 components,
adds integrity checks on npm packages, configures HTTPS on staging,
adds password complexity requirements, uses UUIDs instead of sequential IDs]

Commit: "fix(security): MEDIUM/LOW — MFA, CORS, XSS, dependency scanning, UUIDs"
```

---

## Phase 4: Verify and Certify (Day 12-14)

### Step 7: Verify — Re-Audit After Fixes

```
> /godmode:secure --re-audit

Godmode: Re-running security audit...

RE-AUDIT RESULTS:

STRIDE:
  Spoofing:         ✓ PASS (JWT with strong secret + MFA for admins)
  Tampering:        ✓ PASS (validation, CSRF, mass assignment fixed)
  Repudiation:      ✓ PASS (immutable PHI access audit log)
  Info Disclosure:  ✓ PASS (RBAC, encryption, sanitized errors)
  DoS:              ✓ PASS (rate limiting, file size limits)
  Elevation:        ✓ PASS (RBAC enforced server-side)

OWASP Top 10: ALL PASS

Red Team:
  Attack 1 (brute force): BLOCKED by rate limiting + account lockout
  Attack 2 (privilege escalation): BLOCKED by strong JWT + RBAC
  Attack 3 (data exfiltration): BLOCKED by ownership checks + UUIDs
  Attack 4 (session hijacking): BLOCKED by CSP + httpOnly cookies

  CRITICAL: 0 (was 5) ✓
  HIGH:     0 (was 7) ✓
  MEDIUM:   0 (was 6) ✓
  LOW:      1 (informational — consider certificate pinning for future mobile app)

Verdict: PASS

> /godmode:comply --re-assess hipaa,soc2

HIPAA Score: 23/100 → 87/100
  Remaining gaps: 4 policy documents need legal review

SOC 2 Score: 30/100 → 82/100
  Remaining gaps: 6 controls need evidence collection period (Type II)

Saved: docs/security/healthtrack-re-audit.md
Saved: docs/compliance/hipaa-re-assessment.md
Saved: docs/compliance/soc2-re-assessment.md
```

### Step 8: Pentest — Final Penetration Test

```
> /godmode:pentest --full

Godmode: Running final penetration test...

FINAL PENTEST RESULTS:

Authentication: 6/6 PASS
Authorization: 5/5 PASS
Input validation: 7/7 PASS
Infrastructure: 5/5 PASS
Cryptography: 4/4 PASS

Total: 27/27 tests passing

No exploitable vulnerabilities found.
Recommendation: Schedule third-party pentest for independent verification.

Saved: docs/security/healthtrack-final-pentest.md
```

---

## Security Audit Summary

### Before and After

| Category | Before | After |
|----------|--------|-------|
| CRITICAL findings | 5 | 0 |
| HIGH findings | 7 | 0 |
| MEDIUM findings | 6 | 0 |
| LOW findings | 4 | 1 (informational) |
| HIPAA compliance | 23% | 87% |
| SOC 2 compliance | 30% | 82% |
| Password hashing | MD5 | Argon2id |
| Data encryption | None | AES-256-GCM + TLS |
| Access control | None | Full RBAC |
| Audit logging | None | Immutable PHI access log |
| Security headers | None | Full OWASP recommended set |
| Rate limiting | None | Per-endpoint with lockout |
| CI security checks | None | SAST, SCA, secrets, containers |

### Files Created/Modified

```
Security fixes:          18 files modified
Security infrastructure: 12 new files
Compliance docs:         8 documents
Tests added:            47 security-specific tests
CI pipeline:            4 new security check jobs
```

---

## Ongoing Security Practices

### Weekly

```
# Automated dependency vulnerability check
/godmode:secure --quick

# Review security alerts from CI pipeline
# Review PHI access audit log for anomalies
```

### Monthly

```
# Full security audit
/godmode:secure

# Compliance check
/godmode:comply --frameworks hipaa,soc2

# Review and rotate secrets
/godmode:secrets --audit
```

### Quarterly

```
# Penetration test
/godmode:pentest --full

# Security training review
# Incident response tabletop exercise
# Backup restoration test
```

---

## Custom Chain for Security Work

```yaml
# .godmode/chains.yaml
chains:
  security-full:
    description: "Complete security audit and remediation"
    steps:
      - secure
      - devsecops
      - pentest
      - crypto
      - comply
      - fix
      - secure:    # re-audit
          args: "--re-audit"
      - verify
      - ship

  security-quick:
    description: "Quick weekly security check"
    steps:
      - secure:
          args: "--quick"
      - fix:
          args: "--severity critical,high"
      - verify
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Incident Response Recipe](incident-response.md) — When a security incident occurs
- [Greenfield SaaS Recipe](greenfield-saas.md) — Building secure from the start
- [Open Source Release Recipe](open-source-release.md) — Security considerations for open source
