# Recipe: Building Authentication from Scratch

> From zero to production-grade authentication. OAuth2, JWT, session management, RBAC, and MFA — built correctly the first time.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `auth → rbac → crypto → build → secure → test → ship` |
| **Timeline** | 4-7 days for a complete auth system |
| **Team size** | 1-2 developers (auth is a focus area, not a side task) |
| **Example project** | "AuthCore" — a multi-tenant authentication system with OAuth2, JWT, RBAC, and MFA |

---

## Prerequisites

- Node.js, Go, or Python environment configured
- PostgreSQL provisioned (auth data demands ACID guarantees)
- Redis provisioned (session store, rate limiting, token blacklist)
- SMTP service configured (email verification, password reset)
- Godmode installed and configured

---

## When to Build vs. Buy

Before building auth from scratch, consider:

| Build from scratch | Use a managed service |
|-------------------|----------------------|
| You need deep customization of auth flows | Standard login/signup is sufficient |
| Regulatory requirements mandate self-hosted auth | You can use third-party data processors |
| Auth is a core product feature | Auth is infrastructure for your real product |
| You have security expertise on the team | You want to ship faster |
| Multi-tenant B2B with complex RBAC | Simple role-based access |

**Managed alternatives:** Clerk, Auth0, Supabase Auth, AWS Cognito, Firebase Auth

This recipe is for when you need to build it yourself.

---

## Technology Recommendations

| Layer | Recommendation | Why |
|-------|---------------|-----|
| Password hashing | Argon2id (or bcrypt as fallback) | Memory-hard, GPU-resistant |
| Tokens | JWT (access) + opaque (refresh) | Short-lived access, revocable refresh |
| Session store | Redis | Fast lookups, TTL expiry, atomic operations |
| OAuth2 library | openid-client (Node.js) or authlib (Python) | Standards-compliant OIDC implementation |
| MFA | TOTP (RFC 6238) + WebAuthn | Time-based codes + hardware key support |
| Rate limiting | Redis sliding window | Prevent brute force on auth endpoints |
| Email | Resend or SendGrid | Transactional email for verification and reset |

---

## Session Transcript

### Phase 1: Auth — Design the Authentication System

```
> /godmode:auth I need to build a complete authentication system for a
  multi-tenant B2B SaaS. Requirements: email/password login, Google and
  GitHub OAuth, JWT access tokens, secure session management, email
  verification, password reset, and account lockout after failed attempts.

Godmode: Analyzing auth requirements...

AUTH ARCHITECTURE:

Authentication flows:
  1. Email/password registration → email verification → login
  2. OAuth2 (Google, GitHub) → account linking → login
  3. Password reset via email
  4. Account lockout after 5 failed attempts (30 min cooldown)

Token strategy:
  Access token:  JWT, 15 min TTL, contains userId + tenantId + roles
  Refresh token: Opaque (random bytes), 7 day TTL, stored in Redis
  Token rotation: New refresh token on each use, old one invalidated

Session management:
  - Server-side sessions in Redis (not just JWTs)
  - Session list per user (view and revoke active sessions)
  - Device fingerprinting for session identification
  - Concurrent session limit: configurable per tenant

Cookie strategy:
  Access token:  HttpOnly, Secure, SameSite=Strict, Path=/api
  Refresh token: HttpOnly, Secure, SameSite=Strict, Path=/api/auth/refresh

Database schema:
  users            — id, email, password_hash, email_verified, locked_until, created_at
  oauth_accounts   — id, user_id, provider, provider_id, access_token (encrypted)
  sessions         — id, user_id, token_hash, device_info, ip, created_at, expires_at
  login_attempts   — id, email, ip, success, attempted_at
  email_tokens     — id, user_id, type (verify|reset), token_hash, expires_at, used_at
  audit_log        — id, user_id, action, ip, user_agent, metadata, created_at

Files created:
  src/auth/auth.service.ts         — register, login, logout, refresh
  src/auth/oauth.service.ts        — Google and GitHub OAuth flows
  src/auth/session.service.ts      — Redis session management
  src/auth/token.service.ts        — JWT generation and verification
  src/auth/email.service.ts        — verification and password reset emails
  src/auth/lockout.service.ts      — failed attempt tracking and lockout
  src/middleware/authenticate.ts   — request authentication middleware
  src/middleware/rate-limit.ts     — sliding window rate limiter

Commit: "feat: auth system — email/password, OAuth2, JWT, sessions, lockout"
```

**Time: 45 minutes.**

### Phase 2: RBAC — Design Role-Based Access Control

```
> /godmode:rbac

Godmode: Reading auth design... Implementing RBAC...

RBAC MODEL:

Hierarchy: Tenant → Roles → Permissions

Built-in roles (per tenant):
  owner   — full access, can manage billing and delete tenant
  admin   — manage users, roles, and all resources
  member  — standard access to tenant resources
  viewer  — read-only access
  custom  — tenant-defined roles with custom permission sets

Permission structure:
  resource:action format
  Examples:
    projects:create
    projects:read
    projects:update
    projects:delete
    users:invite
    users:remove
    billing:manage
    settings:update

Permission resolution:
  1. Check user's roles in the current tenant
  2. Aggregate permissions from all assigned roles
  3. Check if requested permission is in the set
  4. Deny by default (whitelist model)

Database additions:
  roles            — id, tenant_id, name, description, is_system, created_at
  permissions      — id, resource, action, description
  role_permissions — role_id, permission_id (composite PK)
  user_roles       — user_id, tenant_id, role_id (composite PK)

Implementation:
  src/auth/rbac.service.ts           — role and permission management
  src/middleware/authorize.ts        — permission check middleware
  src/middleware/tenant-context.ts   — extract and validate tenant from request
  src/auth/rbac.seed.ts              — seed default roles and permissions

Usage:
  // Route-level authorization
  router.post('/projects',
    authenticate,           // verify JWT
    tenantContext,          // extract tenant from JWT
    authorize('projects:create'),  // check permission
    projectController.create
  )

  // Field-level authorization
  authorize('billing:manage')  // only owners/admins see billing data

Commit: "feat: RBAC — roles, permissions, tenant-scoped authorization"
```

**Time: 30 minutes.**

### Phase 3: Crypto — Implement Cryptographic Operations

```
> /godmode:crypto

Godmode: Implementing cryptographic layer...

CRYPTO IMPLEMENTATION:

Password hashing:
  Algorithm: Argon2id
  Parameters:
    Memory: 64 MB
    Iterations: 3
    Parallelism: 4
    Salt: 16 bytes (random per password)
    Hash length: 32 bytes
  Fallback: bcrypt (cost factor 12) for environments without Argon2

Token generation:
  Refresh tokens: 256 bits of cryptographic randomness (crypto.randomBytes)
  Email tokens: 256 bits, URL-safe base64 encoding
  Storage: SHA-256 hash of token stored in database (never store raw tokens)

JWT configuration:
  Algorithm: RS256 (asymmetric — public key for verification, private for signing)
  Key rotation: JWKS endpoint, rotate keys every 90 days
  Claims:
    sub: userId
    tid: tenantId
    roles: [role names]
    iat: issued at
    exp: expiration (15 minutes)
    jti: unique token ID (for revocation)

Encryption at rest:
  OAuth tokens: AES-256-GCM encrypted before storage
  Key management: environment variable (production: AWS KMS / Vault)

Files created:
  src/auth/crypto/password.ts     — Argon2id hashing and verification
  src/auth/crypto/tokens.ts       — secure random token generation
  src/auth/crypto/jwt.ts          — RS256 JWT with JWKS key rotation
  src/auth/crypto/encryption.ts   — AES-256-GCM for sensitive data at rest
  src/auth/crypto/jwks.ts         — JWKS endpoint for public key distribution

Security properties:
  ✓ Timing-safe comparison for all token/hash comparisons
  ✓ No secrets in JWT payload (roles are names, not permission lists)
  ✓ Key rotation without downtime (JWKS serves multiple keys)
  ✓ Forward secrecy on token compromise (short-lived + rotation)

Commit: "feat: crypto layer — Argon2id, RS256 JWT, JWKS, AES-256-GCM"
```

**Time: ~30 min.**

### Phase 4: Build — Implement MFA and Remaining Features

```
> /godmode:build

Godmode: Reading auth, RBAC, and crypto specs... Building remaining features...

IMPLEMENTATION:

Multi-Factor Authentication (MFA):
  Task 1: TOTP setup — generate secret, QR code, backup codes ✓
  Task 2: TOTP verification — validate 6-digit code with time window ✓
  Task 3: Backup codes — 10 single-use recovery codes (hashed) ✓
  Task 4: MFA enforcement — per-tenant policy (optional, required, admin-only) ✓
  Task 5: Login flow with MFA — JWT issued only after MFA verification ✓
  Task 6: MFA recovery — backup code → temporary access → re-enroll ✓

OAuth2 Integration:
  Task 7: Google OAuth — OIDC with PKCE flow ✓
  Task 8: GitHub OAuth — authorization code flow ✓
  Task 9: Account linking — link OAuth to existing email account ✓
  Task 10: OAuth state parameter — CSRF protection for OAuth flows ✓

Email Flows:
  Task 11: Email verification — send token, verify, activate account ✓
  Task 12: Password reset — send token, validate, update password ✓
  Task 13: Email change — verify new email before switching ✓
  Task 14: Rate limiting — max 3 emails per type per hour ✓

Session Management:
  Task 15: Active sessions list — show device, IP, last active ✓
  Task 16: Session revocation — revoke specific or all sessions ✓
  Task 17: Refresh token rotation — new token on each refresh ✓
  Task 18: Idle timeout — revoke session after 30 min inactivity ✓

Audit Log:
  Task 19: Log all auth events — login, logout, password change, MFA ✓
  Task 20: Log access to sensitive resources — PII, billing, admin ✓
  Task 21: Audit log API — filterable, paginated, immutable ✓

BUILD COMPLETE: 21 tasks, 78 tests, all green.

Commit: "feat: MFA (TOTP + backup codes), OAuth2 (Google + GitHub), email flows, audit log"
```

**Time: 4-5 hours.**

### Phase 5: Secure — Security Audit

```
> /godmode:secure

Godmode: Running security audit on auth system...

SECURITY AUDIT:

OWASP Authentication Checklist:
  ✓ Passwords hashed with Argon2id (memory-hard)
  ✓ Password strength validation (zxcvbn, min score 3)
  ✓ Account lockout after 5 failed attempts
  ✓ Rate limiting on all auth endpoints (5 req/min login, 3 req/hour reset)
  ✓ CSRF protection via SameSite cookies + CSRF tokens for forms
  ✓ Timing-safe comparison for all secrets
  ✓ No user enumeration (same response for valid/invalid email)
  ✓ Secure password reset (token expires in 1 hour, single use)
  ✓ MFA available for all accounts

OWASP Session Management Checklist:
  ✓ Session tokens are cryptographically random (256 bits)
  ✓ Session tokens stored as SHA-256 hash in database
  ✓ HttpOnly, Secure, SameSite=Strict cookies
  ✓ Session fixation prevention (new session on login)
  ✓ Absolute timeout (7 days) and idle timeout (30 min)
  ✓ Session revocation on password change
  ✓ Concurrent session visibility and control

JWT Security:
  ✓ Short-lived access tokens (15 min)
  ✓ RS256 asymmetric signing (public key verification)
  ✓ JWKS endpoint with key rotation support
  ✓ No sensitive data in JWT payload
  ✓ Token revocation via Redis blacklist for emergency cases

OAuth2 Security:
  ✓ PKCE for all OAuth flows (prevents authorization code interception)
  ✓ State parameter with CSRF token
  ✓ Nonce parameter for OIDC (replay protection)
  ✓ OAuth tokens encrypted at rest (AES-256-GCM)

FINDINGS:

  1. LOW — Add Referrer-Policy: no-referrer header to prevent token leakage in URLs
  2. LOW — Consider adding login notification emails for new device/location
  3. INFO — Document key rotation procedure in runbook

Verdict: PASS — 0 HIGH, 0 MEDIUM, 2 LOW, 1 INFO

Commit: "fix(security): add Referrer-Policy header, document key rotation"
```

**Time: ~30 min.**

### Phase 6: Test — Comprehensive Auth Testing

```
> /godmode:test --coverage-target 95

Godmode: Analyzing coverage and designing auth-specific test strategy...

TEST STRATEGY:

Security-focused tests (not just coverage):
  1. Brute force resistance — verify lockout after 5 attempts
  2. Token theft — verify refresh token rotation invalidates old token
  3. Session fixation — verify new session ID after login
  4. CSRF — verify OAuth state parameter prevents cross-site attacks
  5. Timing attacks — verify constant-time comparison for all secrets
  6. Injection — verify parameterized queries in all auth paths
  7. Enumeration — verify same response for valid and invalid emails
  8. Race conditions — concurrent refresh token use (only one succeeds)
  9. JWT tampering — verify altered tokens are rejected
  10. Expired tokens — verify access denied for expired JWT

Coverage gaps filled:
  - MFA enrollment edge cases (re-enroll, backup code exhaustion)
  - OAuth account linking conflicts (same email, different provider)
  - Password reset with active MFA requirement
  - Session revocation cascade (password change → all sessions invalidated)
  - Audit log completeness (every auth event logged)

Tests added: 42 new tests
  Security: 18 (attack simulation tests)
  Edge cases: 14 (unusual flows and error conditions)
  Integration: 10 (full flow from registration to authenticated request)

Coverage: 84% → 96.7% ✓ TARGET MET

Commit: "test: auth security tests — brute force, token theft, CSRF, timing, enumeration"
```

**Time: 1-2 hours.**

### Phase 7: Ship — Deploy to Production

```
> /godmode:ship --deploy production

Godmode: Starting 8-phase shipping workflow...

Phase 1: INVENTORY
  31 commits, 54 files changed
  Features: auth, RBAC, crypto, MFA, OAuth2, sessions, audit log

Phase 2: CHECKLIST
  ✓ Tests: 120/120 passing
  ✓ Security audit: PASS
  ✓ Coverage: 96.7%
  ✓ No secrets in code (checked with trufflehog)
  ✓ JWT keys generated and stored in secret manager
  ✓ OAuth client secrets in environment variables
  ✓ CORS configured for production domains only
  ✓ Rate limiting configured and tested
  ✓ Email templates tested (verification, reset, MFA)
  ✓ Audit log retention policy: 2 years

Phase 3: PREPARE
  ✓ Docker image built
  ✓ Database migrations ready
  ✓ Redis cluster reachable
  ✓ JWT signing key deployed to secret manager

Phase 4: DRY RUN
  ✓ Staging deployment verified
  ✓ Full auth flow tested: register → verify → login → MFA → authenticated request
  ✓ OAuth flow tested: Google login → account created → session active
  ✓ Load test: 1000 login attempts/second handled

Phase 5: DEPLOY
  ✓ Blue-green deployment initiated
  ✓ Health check: OK
  ✓ Existing sessions preserved (Redis)

Phase 6: VERIFY
  ✓ Production registration flow works
  ✓ Production login with MFA works
  ✓ Google OAuth redirect works
  ✓ Session list shows current session
  ✓ Audit log recording events

Phase 7: LOG
  Ship log: .godmode/ship-log.tsv
  Version: v1.0.0

Phase 8: MONITOR
  T+0:  ✓ Deployed
  T+5:  ✓ Login success rate 100%, latency p99 45ms
  T+15: ✓ 23 registrations, 0 failed logins, 0 lockouts
  T+30: ✓ All clear. Production launch confirmed stable.

AuthCore v1.0.0 is LIVE.
```

---

## Authentication Flow Diagrams

### Email/Password Login with MFA

```
Client                    Server                     Redis
  ├─ POST /auth/login ─────→│                          │
| {email, password} |  |
  ├─ verify password ────────
  ├─ check lockout ──────────
  ◄─ 200 {mfaRequired} ───┤  (if MFA enabled)
  ├─ POST /auth/mfa/verify─→│                          │
| {code} |  |
  ├─ verify TOTP code
  ├─ create session ─────────→
  ├─ generate JWT
  ├─ generate refresh token
  ◄─ 200 {accessToken} ───┤
| Set-Cookie: refresh |  |
```

### OAuth2 with PKCE

```
Client              Server              Google/GitHub
  ├─ GET /auth/oauth/google ──→│             │
  ├─ generate state
  ├─ generate PKCE
|  | (code_verifier + |
|  | code_challenge) |
  ◄─ 302 Redirect ──┤
  ├─ (user consents) ─────────────────────→  │
  ◄─ 302 Redirect with code ─────────────
  ├─ GET /auth/oauth/callback?code=... ──→│  │
  ├─ verify state
  ├─ exchange code ──────────────→
|  | (with code_verifier) |
|  | ◄─ {access_token, id_token} ── |
  ├─ verify id_token
  ├─ find or create user
  ├─ create session
  ◄─ 200 {accessToken} ──┤
```

---

## Security Principles

### 1. Defense in Depth
No single security measure is relied upon. Password hashing, rate limiting, lockout, MFA, session management, and audit logging work together.

### 2. Fail Secure
Unknown errors result in access denied, never access granted. Default deny on all permission checks.

### 3. Least Privilege
JWTs contain role names, not permissions. Permissions are resolved server-side. Tokens grant minimal access.

### 4. Zero Trust Tokens
Access tokens are short-lived (15 min). Refresh tokens rotate on every use. Compromised tokens have a narrow window of exploitation.

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| Storing passwords in plaintext | "We will hash them later" | `/godmode:crypto` enforces Argon2id from the start |
| Long-lived JWTs (24h+) | Convenience over security | `/godmode:auth` sets 15 min with refresh rotation |
| No rate limiting on login | Overlooked during development | `/godmode:secure` flags missing rate limits |
| User enumeration | Different responses for valid/invalid email | `/godmode:test` includes enumeration attack tests |
| Missing CSRF on OAuth | State parameter forgotten | `/godmode:auth` generates state + PKCE by default |
| Secrets in code | Copy-pasted during development | `/godmode:ship` runs trufflehog before deploy |
| No session revocation | "JWTs are stateless" | Redis session store with explicit revocation |

---

## Custom Chain for Auth Features

```yaml
# .godmode/chains.yaml
chains:
  auth-feature:
    description: "Add a new auth feature (e.g., new OAuth provider)"
    steps:
      - auth           # design the auth flow
      - crypto         # any new cryptographic operations
      - build          # implement
      - secure         # security audit
      - test           # security-focused tests
      - ship

  auth-incident:
    description: "Respond to a security incident"
    steps:
      - incident       # classify and contain
      - secure         # audit for related vulnerabilities
      - fix            # patch the vulnerability
      - test           # regression tests
      - ship           # emergency deploy
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [Building a SaaS](greenfield-saas.md) — Auth in the context of a full SaaS build
- [Achieving SOC 2 Compliance](compliance-journey.md) — Auth requirements for compliance
- [Incident Response Recipe](incident-response.md) — When auth is compromised
