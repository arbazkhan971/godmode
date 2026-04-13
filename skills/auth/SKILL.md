---
name: auth
description: |
  Authentication and authorization skill. Activates when user needs to design or implement authentication flows (JWT,
    OAuth2, OIDC, SAML, API keys, mTLS), session management, multi-factor authentication, passwordless auth, token
    lifecycle management, or social login integration. Produces architecture decisions, implementation code, security
    configuration, and integration tests for the full identity stack. Triggers on: /godmode:auth, "authentication",
    "login flow", "OAuth setup", "JWT tokens", "session management", "MFA", or when building features that require
    user identity.
---

# Auth — Authentication & Authorization

## Activate When
- User invokes `/godmode:auth`
- User says "authentication", "login flow", "OAuth setup", "JWT tokens", "session management"
- User says "MFA", "two-factor", "passwordless", "social login", "SSO"
- Building features that require user identity or access control
- Integrating with identity providers (Auth0, Okta, Cognito, Keycloak, Firebase Auth)
- Pre-ship check when `/godmode:secure` detects authentication weaknesses
- Designing API authentication for `/godmode:api` endpoints

## Workflow

### Step 1: Identity Requirements Discovery
Determine the authentication and authorization needs:

```
IDENTITY REQUIREMENTS:
Application type: <SPA | SSR | Mobile | API-only | Microservices | Hybrid>
User populations:
```
### Step 2: Auth Strategy Selection
Select and design the authentication strategy based on requirements:

#### Strategy: JWT (JSON Web Tokens)
For stateless API authentication:
```
JWT DESIGN:
Algorithm: RS256 (asymmetric) | ES256 (ECDSA) | HS256 (symmetric, single-service only)
Access token:
```

#### Strategy: OAuth 2.0 / OpenID Connect
For delegated authentication and third-party integration:
```
OAUTH2 / OIDC DESIGN:
Grant types:
  - [ ] Authorization Code + PKCE (SPAs, mobile, server apps — RECOMMENDED)
```

#### Strategy: SAML 2.0
For enterprise SSO federation:
```
SAML DESIGN:
Role: Service Provider (SP)
Identity Provider: <Okta | Azure AD | ADFS | OneLogin | custom>
```
API KEY DESIGN:
Format: Prefixed key (e.g., sk_live_abc123, pk_test_xyz789)
  Prefix: Environment indicator (live/test) + type (secret/publishable)
  Entropy: 32+ bytes of cryptographic random, base62 encoded
  Length: 40-64 characters total

Storage:
  Server-side: Store HASH only (SHA-256 or bcrypt), never plaintext
  Display: Show only last 4 characters after creation (sk_live_...a1b2)
  Lookup: Use prefix + hash index for efficient lookup

Lifecycle:
  Creation: User generates via dashboard/API, shown ONCE
  Rotation: Support key rotation with overlap period (old key valid for 24h)
  Revocation: Immediate revocation via dashboard/API
  Expiry: Optional expiry date, default no expiry with activity monitoring

Scoping:
#### Strategy: mTLS (Mutual TLS)
For zero-trust service-to-service authentication:
```
mTLS DESIGN:
Certificate authority: <internal CA | HashiCorp Vault | AWS ACM PCA | cfssl>
Certificate format: X.509 v3
```
SESSION MANAGEMENT:
Type: Stateless (JWT) | Stateful (server-side sessions) | Hybrid

Stateless sessions (JWT-based):
  Advantages: No server-side storage, horizontal scaling
  Disadvantages: Cannot revoke individual tokens, payload size
  Mitigation: Short-lived access tokens + refresh token rotation
  Revocation strategy:
    - Token blacklist in Redis (TTL = remaining token lifetime)
    - Refresh token family tracking (revoke family on reuse detection)
    - Version counter on user record (invalidate all tokens on password change)

Stateful sessions (server-side):
  Store: Redis | PostgreSQL | DynamoDB
  Session ID: 256-bit cryptographic random, base64url encoded
  Idle timeout: 30min, absolute timeout: 12h, sliding window reset on request
  Concurrent limit: <N> per user. Regenerate ID after auth. Destroy on logout.
  Cookie: __Host-session, HttpOnly, Secure, SameSite=Lax, no Domain set

SECURITY CHECKLIST:
- [ ] Session ID is cryptographically random (256+ bits)
- [ ] Session ID regenerated after login (prevent fixation)
- [ ] Session destroyed on logout (server-side + cookie cleared)
- [ ] Idle timeout enforced server-side
- [ ] Absolute timeout enforced (even active sessions expire)
- [ ] Concurrent session limit enforced
- [ ] Session bound to user-agent and IP (detect hijacking)
- [ ] Cookie flags: HttpOnly, Secure, SameSite
```

### Step 4: Multi-Factor Authentication (MFA)
Design MFA implementation if required:
```
MFA DESIGN:
Enrollment flow: Registration -> Verify first factor -> Enroll MFA -> Verify MFA
Authentication flow: Password -> MFA challenge -> Session created

Supported factors:
  - [ ] TOTP (Authenticator app — Google Authenticator, Authy, 1Password)
        Algorithm: SHA-1 (RFC 6238 compatible)
        Digits: 6
        Period: 30 seconds
        Secret: 160-bit random, base32 encoded
        Provisioning: otpauth:// URI + QR code
        Backup: 8-10 single-use recovery codes (16 chars each, stored hashed)

  - [ ] WebAuthn / Passkeys (FIDO2)
        Relying Party ID: <your-domain.com>
        Attestation: none (privacy-preserving) | direct (hardware verification)
        User verification: preferred (biometric if available)
        Resident keys: preferred (discoverable credentials for passwordless)
        Authenticators: Platform (TouchID, FaceID, Windows Hello) + Roaming (YubiKey)
        Credential storage: credentialId + publicKey + signCount per user

  - [ ] SMS OTP (FALLBACK ONLY — vulnerable to SIM swap)
        Code: 6-digit random
        Expiry: 5 minutes
        Rate limit: 3 attempts per code, 5 codes per hour
        WARNING: NIST SP 800-63B deprecated SMS for authentication

  - [ ] Email magic link
        Token: 256-bit random, single-use
        Expiry: 15 minutes
        Rate limit: 5 links per hour

### Step 5: Passwordless Authentication
Design passwordless flows if required:

```
PASSWORDLESS DESIGN:

Strategy: Magic Links
```
TOKEN LIFECYCLE:
  TOKEN LIFECYCLE
  ISSUANCE
  ├─ User authenticates (password + MFA)
  ├─ Generate access token (short-lived: 15min)
  ├─ Generate refresh token (long-lived: 7-30 days)
  ├─ Store refresh token hash in database
  └─ Return tokens to client
  USAGE
  ├─ Client sends access token on every request
  ├─ Server validates signature, expiry, audience, issuer
  ├─ Server extracts claims (userId, roles, permissions)
  └─ Request proceeds or is rejected (401/403)
  REFRESH
  ├─ Access token expires -> client sends refresh token
  ├─ Server validates refresh token hash against database
  ├─ Server issues NEW access token + NEW refresh token
  ├─ Server invalidates OLD refresh token (rotation)
  └─ If old refresh token is reused -> revoke entire family
  REVOCATION
  ├─ User logout: Delete refresh token from database
  ├─ Password change: Revoke ALL refresh tokens for user
  ├─ Security event: Revoke ALL tokens for user
  ├─ Admin action: Revoke specific session or all sessions
  └─ Access token: Add to blacklist (Redis, TTL = remaining)
  CLEANUP
  ├─ Expired refresh tokens: Cron job deletes daily
  ├─ Blacklist entries: Auto-expire via Redis TTL
  └─ Audit log: Retain token events for compliance period

Token storage by client type:
| Client Type | Access Token | Refresh Token |
|--|--|--|
| SPA | In-memory only | HttpOnly cookie (Secure) |
| SSR (Next.js) | Server memory | HttpOnly cookie (Secure) |
| Mobile app | Secure keychain | Secure keychain |
| Server/CLI | Environment var | Encrypted file / vault |
| Microservice | In-memory cache | N/A (client credentials) |
```

### Step 7: Social Login Integration
Design social authentication if required:
```
SOCIAL LOGIN DESIGN:
| Provider | Protocol | Scopes | User Data |
|--|--|--|--|
| Google | OIDC | openid email profile | email, name |
| GitHub | OAuth2 | user:email | email, name |
| Apple | OIDC | openid email name | email, name |
| Microsoft | OIDC | openid email profile | email, name |
| Facebook | OAuth2 | email public_profile | email, name |

Account linking strategy:
  Primary key: Email address (verified by provider)
  On first login:
    - Email matches existing account -> Link social identity
    - Email is new -> Create account + link social identity
  On subsequent login:
### Step 8: Implementation Artifacts
Generate the authentication implementation:

```
IMPLEMENTATION ARTIFACTS:
| File | Purpose |
```
### Step 9: Security Hardening Checklist
Final security review of the authentication system:

```
AUTH SECURITY HARDENING:
| Category | Control | Status |
```
### Step 10: Auth Architecture Report

```
  AUTH ARCHITECTURE REPORT
```
### Step 11: Commit and Transition
1. Save architecture as `docs/auth/<feature>-auth-architecture.md`
2. Commit: `"auth: <feature> — <strategy> with <MFA type>, <N> endpoints"`
3. If INCOMPLETE: "Auth design needs additional work. Address remaining items, then re-run `/godmode:auth`."
4. If PRODUCTION READY: "Authentication architecture complete. Run `/godmode:rbac` to design access control,
or `/godmode:build` to implement."

<!-- tier-3 -->

## Quality Targets
- Access token TTL: <15min
- Auth round-trip: <500ms latency
- Secrets exposure: 0% plaintext in codebase

## Key Behaviors

Never ask to continue. Loop autonomously until all auth flows pass and security checklist is complete.

```bash
# Test auth flows end-to-end
npm test -- --grep "auth"
npx jest tests/auth/ --coverage --coverageThreshold='{"global":{"branches":80}}'
```
IF access token TTL > 15 minutes: reduce to <= 15 min.
WHEN login failures > 5 per account per hour: trigger rate limit.
IF password hash cost factor < 12: increase to >= 12 (bcrypt).

1. **Security by default.** Most secure option unless justified.
2. **Strategy must match architecture.** JWT for stateless, sessions for SSR.
3. **Token lifecycle non-negotiable.** Issue, validate, refresh, revoke, cleanup.
4. **MFA not optional for production.** Minimum: TOTP support.
5. **Social login = account linking.** Not account creation.
6. **Show the code.** Artifacts, not just diagrams.
7. **Password: Argon2id or bcrypt (cost >= 12).** No exceptions.

## Auth Flow Audit Loop
```
auth_flows = [session, token, oauth, mfa, password_reset, social, api_key]
FOR each flow:
  KEEP if: exploitable weakness with code evidence
  DISCARD if: not applicable to chosen strategy OR already remediated
```

## Output Format

```
  AUTH RESULT
  Strategy: <JWT | Session | OAuth2/OIDC | SAML | Hybrid>
  MFA: <TOTP | WebAuthn | SMS | None>
  Endpoints: <N designed/implemented>
  Security controls: <N passed> / <N total>
  Verdict: <PRODUCTION READY | NEEDS HARDENING | INCOMPLETE>
```
## TSV Logging

```
timestamp	feature	strategy	mfa_type	endpoints	controls_passed	controls_total	verdict
```
Append one row per invocation. Never overwrite previous rows.

```
PASS if ALL of the following:
  - Password hashing uses Argon2id or bcrypt (cost >= 12)
  - Access tokens are short-lived (<= 15 min)
  - Refresh tokens use rotation with family-based revocation
  - Token storage follows client-type recommendations (no localStorage for JWTs)
  - HTTPS enforced with HSTS header
```


## Keep/Discard
KEEP if: improvement verified. DISCARD if: regression or no change. Revert discards immediately.

## Stop Conditions
Stop when: target reached, budget exhausted, or >5 consecutive discards.

