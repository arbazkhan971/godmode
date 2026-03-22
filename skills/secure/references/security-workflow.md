# Security Audit Workflow — Full Reference

## Audit Process

### Phase 1: Asset Inventory
Before auditing code, identify what needs protection:

```
ASSET INVENTORY:
Data assets:
  - User PII (emails, names, addresses)
  - Authentication credentials (passwords, tokens)
  - Payment data (if applicable)
  - Business data (orders, products, analytics)

System assets:
  - Database servers
  - API servers
  - File storage (S3, disk)
  - External service credentials

Trust boundaries:
  - Client ↔ API (untrusted → trusted)
  - API ↔ Database (trusted → trusted)
  - API ↔ External Services (trusted → semi-trusted)
  - Admin panel ↔ API (privileged → trusted)
```

### Phase 2: STRIDE Checklist — Detailed

#### Spoofing (Identity)
**Questions to answer for each authentication flow:**

| Check | How to Verify | Severity if Missing |
|--|--|--|
| Passwords hashed with bcrypt/argon2/scrypt | `grep -r "bcrypt\|argon2\|scrypt" src/` | CRITICAL |
| No plaintext password storage | `grep -rn "password" src/ --include="*.sql"` | CRITICAL |
| JWT expiry configured | Check JWT creation code for `expiresIn` | HIGH |
| Session tokens cryptographically random | Check token generation for `crypto.randomBytes` or equivalent | HIGH |
| Login rate limiting | Check auth routes for rate limiter middleware | HIGH |
| Account lockout after N failures | Check login handler for failure counting | MEDIUM |
| Password reset tokens expire | Check reset flow for token expiry | HIGH |
| OAuth state parameter used | Check OAuth callback for state validation | HIGH |
| Cookie flags set (HttpOnly, Secure, SameSite) | Check cookie configuration | HIGH |

#### Tampering (Data Integrity)
| Check | How to Verify | Severity if Missing |
|--|--|--|
| Parameterized queries (no SQL injection) | `grep -rn "query.*\$\|query.*+\|execute.*f'" src/` | CRITICAL |
| Input validation on all endpoints | Check controllers for validation middleware | HIGH |
| File upload type validation | Check upload handlers for MIME type checks | HIGH |
| File upload size limits | Check for size limit configuration | MEDIUM |
| Content-Type enforcement | Check for body parser configuration | MEDIUM |
| Request body schema validation | Check for validation library (Joi, Zod, etc.) | HIGH |
| CSRF protection on state-changing endpoints | Check for CSRF middleware | HIGH |
| Signature verification on webhooks | Check webhook handlers for signature checking | HIGH |

#### Repudiation (Audit Trail)
| Check | How to Verify | Severity if Missing |
|--|--|--|
| Authentication events logged | Check login/logout handlers for logging | MEDIUM |
| Authorization failures logged | Check permission checks for logging | MEDIUM |
| Data modifications logged | Check write operations for audit logging | MEDIUM |
| Log format includes who/what/when | Check log format configuration | LOW |
| Logs stored separately from application | Check log destination configuration | LOW |

#### Information Disclosure
| Check | How to Verify | Severity if Missing |
|--|--|--|
| Stack traces not in production responses | Check error handler for environment check | HIGH |
| Sensitive data not in logs | `grep -rn "password\|token\|secret" src/ --include="*.log*"` | HIGH |
| API doesn't over-expose data | Check response serialization for field selection | MEDIUM |
| Error messages don't reveal internals | Check error responses for SQL, paths, versions | HIGH |
| HTTPS enforced | Check for HSTS headers and redirect configuration | HIGH |
| .env not in version control | Check `.gitignore` for `.env` | CRITICAL |
| Secrets not hardcoded | `grep -rn "password.*=\|secret.*=\|api_key.*=" src/` | CRITICAL |
| CORS configured restrictively | Check CORS configuration for `origin: "*"` | HIGH |

#### Denial of Service
| Check | How to Verify | Severity if Missing |
|--|--|--|
| Rate limiting on public endpoints | Check for rate limiter middleware | HIGH |
| Request size limits | Check body parser limits | MEDIUM |
| Pagination on list endpoints | Check for `limit` and `offset` in queries | HIGH |
| Timeouts on external calls | Check HTTP client configuration | MEDIUM |
| No ReDoS patterns | Check regex patterns for catastrophic backtracking | MEDIUM |
| Connection limits configured | Check server configuration | LOW |
| Graceful shutdown handler | Check for SIGTERM handler | LOW |

#### Elevation of Privilege
| Check | How to Verify | Severity if Missing |
|--|--|--|
| Authorization on every endpoint | Check middleware chain for each route | CRITICAL |
| Admin routes separated | Check for admin-specific middleware | HIGH |
| No mass assignment | Check for `req.body` spread into models | HIGH |
| Path traversal prevented | Check file operations for `../` sanitization | CRITICAL |
| Command injection prevented | Check for `exec`, `spawn` with user input | CRITICAL |
| Insecure deserialization prevented | Check for `eval`, `JSON.parse` on untrusted input | HIGH |
| IDOR prevented | Check resource access for ownership verification | HIGH |

### Phase 3: OWASP Top 10 (2021) Quick Reference

| ID | Name | Key Checks |
|----|------|------------|
| A01 | Broken Access Control | AuthZ on all endpoints, IDOR checks, CORS policy, directory traversal |
| A02 | Cryptographic Failures | Password hashing, HTTPS, token security, no hardcoded secrets |
| A03 | Injection | SQL injection, XSS, command injection, template injection |
| A04 | Insecure Design | Threat modeling done, security requirements in spec, abuse cases tested |
| A05 | Security Misconfiguration | Default credentials removed, unnecessary features disabled, error handling |
| A06 | Vulnerable Components | `npm audit`/`pip audit`, outdated dependencies, known CVEs |
| A07 | Authentication Failures | Brute force protection, strong passwords, MFA, session management |
| A08 | Software & Data Integrity | Dependency verification, CI/CD pipeline security, signed releases |
| A09 | Security Logging Failures | Audit logs, monitoring, alerting on suspicious activity |
| A10 | SSRF | URL validation, allowlists for outbound requests, no user-controlled URLs in fetch |

### Phase 4: Red Team Playbooks

#### Script Kiddie Playbook
```
1. SQL Injection probes:
   ' OR '1'='1
   '; DROP TABLE users; --
   1 UNION SELECT * FROM users

2. XSS probes:
   <script>alert(1)</script>
   <img src=x onerror=alert(1)>
   javascript:alert(1)

3. Directory traversal:
   ../../../etc/passwd
   ....//....//etc/passwd
   %2e%2e%2f%2e%2e%2fetc%2fpasswd

4. Default credentials:
   admin/admin, admin/password, root/root

5. Known vulnerabilities:
   Run npm audit / pip audit / snyk test
   Check CVE databases for dependency versions
```

#### Insider Threat Playbook
```
1. IDOR testing:
   GET /api/users/1 (own account)
   GET /api/users/2 (someone else's account — should be 403)

2. Privilege escalation:
   POST /api/users { "role": "admin" } (mass assignment)
   PATCH /api/users/1 { "is_admin": true }

3. Token manipulation:
   Decode JWT, modify role claim, re-encode
   Use expired token
   Use token from another user

4. Data exfiltration:
   GET /api/users?limit=999999 (dump all users)
   GET /api/admin/export (unauthorized admin access)
```

#### Sophisticated Attacker Playbook
```
1. Race conditions:
   Send 100 concurrent POST /api/orders for last item
   Double-submit payment form

2. Business logic:
   Order with quantity = -1 (negative total?)
   Apply discount code twice
   Use expired coupon

3. Chained attacks:
   Enumerate users via timing difference on login
   Use found usernames for targeted password reset
   Intercept reset token via open redirect
```

#### Data Harvester Playbook
```
1. Enumeration:
   /api/users/1, /api/users/2, ... (sequential IDs)
   /api/users?email=test@example.com (email enumeration)

2. Error message mining:
   Send malformed requests, read error details
   Check if errors leak table names, column names

3. Timing attacks:
   Compare response time for valid vs invalid usernames
   Compare response time for correct vs incorrect passwords

4. Verbose responses:
   Check if API responses include internal IDs
   Check if error responses include stack traces
```

## Severity Rating Guide

| Severity | Definition | Examples | SLA |
|----------|-----------|----------|-----|
| CRITICAL | Exploitable now, major impact, no authentication required | SQL injection, hardcoded credentials, path traversal to system files | Fix immediately |
| HIGH | Exploitable with some effort, significant impact | XSS, missing authorization on data endpoints, session fixation | Fix before shipping |
| MEDIUM | Requires specific conditions, moderate impact | Missing rate limiting, verbose error messages, weak CORS | Fix within 1 week |
| LOW | Minimal impact, defense in depth | Missing security headers, informational disclosure | Fix within 1 month |
| INFO | Best practice recommendation, no direct vulnerability | Code style, additional hardening suggestions | Nice to have |

## Report Template

```markdown
# Security Audit Report: <Feature/Module>

**Date:** <date>
**Auditor:** Godmode /godmode:secure
**Scope:** <files/directories audited>
**Verdict:** <PASS | CONDITIONAL PASS | FAIL>

## Executive Summary
<2-3 sentence summary of findings>

## Findings

### FINDING 1: <Title>
- **Severity:** <CRITICAL|HIGH|MEDIUM|LOW|INFO>
- **Category:** <STRIDE letter> / <OWASP ID>
- **Location:** <file:line>
- **Description:** <what the vulnerability is>
- **Evidence:** <the vulnerable code>
- **Attack scenario:** <how it could be exploited>
- **Remediation:** <the fix, with code>
- **Verification:** <how to confirm the fix>

### FINDING 2: ...

## Checklist Results
<STRIDE and OWASP checklist results>

## Recommendations
<Ordered list of recommended actions>
```
