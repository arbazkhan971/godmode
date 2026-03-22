---
name: auth
description: |
  Authentication and authorization skill. Activates when user needs to design or implement authentication flows (JWT, OAuth2, OIDC, SAML, API keys, mTLS), session management, multi-factor authentication, passwordless auth, token lifecycle management, or social login integration. Produces architecture decisions, implementation code, security configuration, and integration tests for the full identity stack. Triggers on: /godmode:auth, "authentication", "login flow", "OAuth setup", "JWT tokens", "session management", "MFA", or when building features that require user identity.
---

# Auth — Authentication & Authorization

## When to Activate
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
  - End users: <yes/no, estimated count>
  - Admin users: <yes/no, privilege levels>
  - Service accounts: <yes/no, service-to-service auth needed>
  - External partners: <yes/no, API consumers>

Authentication needs:
  - [ ] Username/password login
  - [ ] Social login (Google, GitHub, Apple, Microsoft, etc.)
  - [ ] SSO / Enterprise federation (SAML, OIDC)
  - [ ] API key authentication
  - [ ] Machine-to-machine auth (mTLS, client credentials)
  - [ ] Passwordless (magic link, WebAuthn/passkeys)
  - [ ] Multi-factor authentication

Session requirements:
  Duration: <minutes/hours/days>
  Concurrent sessions: <single | limited N | unlimited>
  Remember me: <yes/no, extended duration>
  Cross-device: <yes/no>

Compliance constraints:
  - [ ] NIST 800-63 (digital identity guidelines)
  - [ ] OWASP ASVS (application security verification)
  - [ ] SOC2 (access controls)
  - [ ] HIPAA (PHI access authentication)
  - [ ] PCI-DSS (cardholder data access)
```

### Step 2: Auth Strategy Selection
Select and design the authentication strategy based on requirements:

#### Strategy: JWT (JSON Web Tokens)
For stateless API authentication:
```
JWT DESIGN:
Algorithm: RS256 (asymmetric) | ES256 (ECDSA) | HS256 (symmetric, single-service only)
Access token:
  Lifetime: 15 minutes (recommended)
  Claims: sub, iss, aud, exp, iat, jti, roles, permissions
  Storage: Memory (SPA) | HttpOnly cookie (SSR)
  Size budget: < 4KB (cookie limit)

Refresh token:
  Lifetime: 7 days (sliding) | 30 days (absolute max)
  Storage: HttpOnly + Secure + SameSite=Strict cookie
  Rotation: YES — issue new refresh token on each use
  Family tracking: YES — detect reuse and revoke family

Token signing:
  Key management: <environment variable | vault | KMS>
  Key rotation: Every 90 days with grace period
  JWKS endpoint: /.well-known/jwks.json (if asymmetric)

SECURITY CHECKLIST:
- [ ] Tokens signed, not just encoded (never use "alg": "none")
- [ ] Algorithm explicitly validated on verification (no algorithm confusion)
- [ ] Audience (aud) claim verified on every request
- [ ] Issuer (iss) claim verified on every request
- [ ] Token expiry (exp) enforced with clock skew tolerance (30s max)
- [ ] JTI claim for token uniqueness (replay prevention)
- [ ] Refresh token rotation with family-based revocation
- [ ] No sensitive data in token payload (tokens are readable, not secret)
```

#### Strategy: OAuth 2.0 / OpenID Connect
For delegated authentication and third-party integration:
```
OAUTH2 / OIDC DESIGN:
Grant types:
  - [ ] Authorization Code + PKCE (SPAs, mobile, server apps — RECOMMENDED)
  - [ ] Client Credentials (machine-to-machine)
  - [ ] Device Authorization (IoT, CLI tools, smart TVs)
  - [ ] Refresh Token (long-lived sessions)
  NOTE: Implicit grant and ROPC are DEPRECATED — do not use

Provider configuration:
  Authorization endpoint: /oauth/authorize
  Token endpoint: /oauth/token
  UserInfo endpoint: /oauth/userinfo
  JWKS endpoint: /.well-known/jwks.json
  Discovery: /.well-known/openid-configuration

PKCE implementation:
  Code verifier: 43-128 character random string (RFC 7636)
  Code challenge method: S256 (SHA-256 hash of verifier)
  Flow: Generate verifier -> hash to challenge -> send challenge with auth request
        -> send verifier with token request -> server verifies match

Scopes:
  Standard OIDC: openid, profile, email
  Custom: <application-specific scopes>

Client registration:
  Client type: public (SPA/mobile) | confidential (server)
  Redirect URIs: <exact match, no wildcards>
  Allowed origins: <CORS origins for token endpoint>

SECURITY CHECKLIST:
- [ ] PKCE required for all authorization code flows
- [ ] State parameter validated (CSRF prevention)
- [ ] Nonce parameter validated (replay prevention for OIDC)
- [ ] Redirect URI exact match (no open redirect)
- [ ] Token endpoint uses POST (not GET)
- [ ] Client secrets never exposed in frontend code
- [ ] Authorization codes are single-use
- [ ] Token responses include cache-control: no-store
```

#### Strategy: SAML 2.0
For enterprise SSO federation:
```
SAML DESIGN:
Role: Service Provider (SP)
Identity Provider: <Okta | Azure AD | ADFS | OneLogin | custom>
Binding: HTTP-POST (recommended) | HTTP-Redirect

SP configuration:
  Entity ID: <unique identifier for your SP>
  ACS URL: /saml/acs (assertion consumer service)
  SLO URL: /saml/slo (single logout)
  Metadata: /saml/metadata

Assertion requirements:
  NameID format: emailAddress | persistent | transient
  Required attributes: email, firstName, lastName, groups
  Signature: Assertions MUST be signed (RSA-SHA256 minimum)
  Encryption: Assertions SHOULD be encrypted (AES-256)

SECURITY CHECKLIST:

#### Strategy: API Keys
For machine-to-machine and third-party API access:
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

Certificate fields:
  Common Name (CN): <service-name>.<namespace>.svc
  Subject Alternative Names (SANs): DNS names, IP addresses, SPIFFE IDs
  Key algorithm: ECDSA P-256 (recommended) | RSA 2048+
  Validity: 24 hours (short-lived, auto-rotated)

Certificate lifecycle:
  Issuance: Automatic via sidecar/init container or SDK
  Rotation: Auto-rotate at 50% of lifetime
  Revocation: CRL or OCSP responder
  Root rotation: Staged rollout with cross-signed intermediate

Trust model:
  Root CA: Offline, air-gapped (never used directly)

### Step 3: Session Management Design
Design session handling based on the chosen strategy:

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
  Storage format:
    {
      sid: "<session-id>",
      uid: "<user-id>",
      created: "<ISO-8601>",
      lastActive: "<ISO-8601>",
      ip: "<client-ip>",
      userAgent: "<browser>",
      mfa_verified: true/false,
      roles: ["user", "admin"],
      metadata: {}
    }

Session lifecycle:
  Idle timeout: 30 minutes of inactivity
  Absolute timeout: 12 hours (force re-auth)
  Sliding window: Reset idle timeout on each request
  Concurrent limit: <N> sessions per user
  Session fixation: Regenerate session ID after authentication
  Logout: Destroy session server-side + clear cookie

Cookie configuration:
  Name: __Host-session (with Host prefix for additional security)
  HttpOnly: true (prevent XSS access)
  Secure: true (HTTPS only)
  SameSite: Lax (CSRF protection with usability) | Strict (maximum protection)
  Path: / (or restrict to API path)
  Domain: Do not set (restricts to exact origin)
  Max-Age: Match session lifetime

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
  Flow: Enter email -> receive link -> click link -> authenticated
  Token: 256-bit cryptographic random, URL-safe base64
  Expiry: 15 minutes
  Single-use: YES — invalidate immediately after use
  Delivery: Email (verified address only)
  Fallback: TOTP code as alternative

Strategy: WebAuthn / Passkeys (Primary)
  Flow: Enter username -> browser prompts biometric -> authenticated
  Discovery: Conditional mediation (autofill passkey suggestion)
  Cross-device: Hybrid transport for phone-as-authenticator
  Account recovery: Registered email + recovery codes

Strategy: One-Time Password (OTP)
### Step 6: Token Lifecycle Management
Design the complete token lifecycle:

```
TOKEN LIFECYCLE:
┌──────────────────────────────────────────────────────────────┐
│                     TOKEN LIFECYCLE                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ISSUANCE                                                    │
│  ├─ User authenticates (password + MFA)                      │
│  ├─ Generate access token (short-lived: 15min)               │
│  ├─ Generate refresh token (long-lived: 7-30 days)           │
│  ├─ Store refresh token hash in database                     │
│  └─ Return tokens to client                                  │
│                                                              │
│  USAGE                                                       │
│  ├─ Client sends access token on every request               │
│  ├─ Server validates signature, expiry, audience, issuer     │
│  ├─ Server extracts claims (userId, roles, permissions)      │
│  └─ Request proceeds or is rejected (401/403)                │
│                                                              │
│  REFRESH                                                     │
│  ├─ Access token expires -> client sends refresh token       │
│  ├─ Server validates refresh token hash against database     │
│  ├─ Server issues NEW access token + NEW refresh token       │
│  ├─ Server invalidates OLD refresh token (rotation)          │
│  └─ If old refresh token is reused -> revoke entire family   │
│                                                              │
│  REVOCATION                                                  │
│  ├─ User logout: Delete refresh token from database          │
│  ├─ Password change: Revoke ALL refresh tokens for user      │
│  ├─ Security event: Revoke ALL tokens for user               │
│  ├─ Admin action: Revoke specific session or all sessions    │
│  └─ Access token: Add to blacklist (Redis, TTL = remaining)  │
│                                                              │
│  CLEANUP                                                     │
│  ├─ Expired refresh tokens: Cron job deletes daily           │
│  ├─ Blacklist entries: Auto-expire via Redis TTL             │
│  └─ Audit log: Retain token events for compliance period     │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Token storage by client type:
┌────────────────┬──────────────────┬──────────────────────────┐
│ Client Type    │ Access Token     │ Refresh Token            │
├────────────────┼──────────────────┼──────────────────────────┤
│ SPA            │ In-memory only   │ HttpOnly cookie (Secure) │
│ SSR (Next.js)  │ Server memory    │ HttpOnly cookie (Secure) │
│ Mobile app     │ Secure keychain  │ Secure keychain          │
│ Server/CLI     │ Environment var  │ Encrypted file / vault   │
│ Microservice   │ In-memory cache  │ N/A (client credentials) │
└────────────────┴──────────────────┴──────────────────────────┘
```

### Step 7: Social Login Integration
Design social authentication if required:

```
SOCIAL LOGIN DESIGN:
┌──────────────────────────────────────────────────────────────┐
│ Provider       │ Protocol │ Scopes              │ User Data  │
├──────────────────────────────────────────────────────────────┤
│ Google         │ OIDC     │ openid email profile │ email, name│
│ GitHub         │ OAuth2   │ user:email           │ email, name│
│ Apple          │ OIDC     │ openid email name    │ email, name│
│ Microsoft      │ OIDC     │ openid email profile │ email, name│
│ Facebook       │ OAuth2   │ email public_profile │ email, name│
└──────────────────────────────────────────────────────────────┘

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
┌──────────────────────────────────────────────────────────────┐
│ File                              │ Purpose                  │
├──────────────────────────────────────────────────────────────┤
│ src/auth/strategies/              │ Auth strategy configs     │
│ src/auth/middleware/authenticate  │ Token validation middleware│
│ src/auth/middleware/authorize     │ Permission check middleware│
│ src/auth/controllers/login        │ Login endpoint            │
│ src/auth/controllers/register     │ Registration endpoint     │
│ src/auth/controllers/logout       │ Logout + token revocation │
│ src/auth/controllers/refresh      │ Token refresh endpoint    │
│ src/auth/controllers/mfa          │ MFA enrollment + verify   │
│ src/auth/controllers/social       │ Social login callbacks    │
│ src/auth/services/token           │ Token create/verify/revoke│
│ src/auth/services/session         │ Session management        │
│ src/auth/services/password        │ Hash/verify/reset         │
│ src/auth/services/mfa             │ TOTP/WebAuthn logic       │
│ src/auth/models/user              │ User identity model       │
│ src/auth/models/session           │ Session/token model       │
│ src/auth/models/social-identity   │ Social login identities   │
│ tests/auth/                       │ Integration + unit tests  │
│ docs/auth/architecture.md         │ Auth architecture decision│
└──────────────────────────────────────────────────────────────┘
```

### Step 9: Security Hardening Checklist
Final security review of the authentication system:

```
AUTH SECURITY HARDENING:
┌──────────────────────────────────────────────────────────────┐
│ Category              │ Control                    │ Status  │
├──────────────────────────────────────────────────────────────┤
│ Password policy       │ Minimum 8 chars            │ YES/NO  │
│                       │ Breached password check    │ YES/NO  │
│                       │ bcrypt/argon2 hashing      │ YES/NO  │
│                       │ No password in logs        │ YES/NO  │
├──────────────────────────────────────────────────────────────┤
│ Brute force           │ Rate limiting on login     │ YES/NO  │
│                       │ Account lockout (temp)     │ YES/NO  │
│                       │ CAPTCHA after N failures   │ YES/NO  │
│                       │ Exponential backoff        │ YES/NO  │
├──────────────────────────────────────────────────────────────┤
│ Token security        │ Signed with strong algo    │ YES/NO  │
│                       │ Short-lived access tokens  │ YES/NO  │
│                       │ Refresh token rotation     │ YES/NO  │
│                       │ Token revocation works     │ YES/NO  │
├──────────────────────────────────────────────────────────────┤
│ Session security      │ HttpOnly + Secure cookies  │ YES/NO  │
│                       │ SameSite attribute set     │ YES/NO  │
│                       │ Session fixation prevented │ YES/NO  │
│                       │ Idle + absolute timeout    │ YES/NO  │
├──────────────────────────────────────────────────────────────┤
│ Account security      │ Email verification         │ YES/NO  │
│                       │ Password reset is secure   │ YES/NO  │
│                       │ Account enumeration blocked│ YES/NO  │
│                       │ MFA available              │ YES/NO  │
├──────────────────────────────────────────────────────────────┤
│ Transport             │ HTTPS enforced             │ YES/NO  │
│                       │ HSTS header set            │ YES/NO  │
│                       │ Secure WebSocket auth      │ YES/NO  │
│                       │ CORS properly configured   │ YES/NO  │
└──────────────────────────────────────────────────────────────┘
```

### Step 10: Auth Architecture Report

```
┌────────────────────────────────────────────────────────────┐
│  AUTH ARCHITECTURE REPORT                                   │
├────────────────────────────────────────────────────────────┤
│  Strategy: <JWT | Session | OAuth2/OIDC | SAML | Hybrid>   │
│  MFA: <TOTP | WebAuthn | SMS | None>                       │
│  Social login: <providers list or None>                     │
│  Session type: <Stateless | Stateful | Hybrid>              │
│                                                             │
│  Endpoints designed: <N>                                    │
│  Middleware components: <N>                                  │
│  Security controls: <N passed> / <N total>                  │
│                                                             │
│  Token lifecycle:                                           │
│    Access token TTL:  <duration>                            │
│    Refresh token TTL: <duration>                            │
│    Rotation: <YES/NO>                                       │
│    Revocation: <strategy>                                   │
│                                                             │
│  Verdict: <PRODUCTION READY | NEEDS HARDENING | INCOMPLETE> │
├────────────────────────────────────────────────────────────┤
│  REMAINING WORK:                                            │
│  1. <item>                                                  │
│  2. <item>                                                  │
└────────────────────────────────────────────────────────────┘
```

### Step 11: Commit and Transition
1. Save architecture as `docs/auth/<feature>-auth-architecture.md`
2. Commit: `"auth: <feature> — <strategy> with <MFA type>, <N> endpoints"`
3. If INCOMPLETE: "Auth design needs additional work. Address remaining items, then re-run `/godmode:auth`."
4. If PRODUCTION READY: "Authentication architecture complete. Run `/godmode:rbac` to design access control, or `/godmode:build` to implement."

## Key Behaviors

1. **Security by default.** Every design choice defaults to the most secure option. Weaker options require explicit justification. Never suggest HS256 for multi-service JWT. Never suggest implicit grant. Never suggest SMS as primary MFA.
2. **Strategy must match architecture.** JWTs for stateless microservices. Server-side sessions for traditional web apps. OAuth2/OIDC for third-party integration. Do not force a strategy that does not fit the application type.
3. **Token lifecycle is non-negotiable.** Every token must have issuance, validation, refresh, revocation, and cleanup. Missing any stage is a security gap.
4. **MFA is not optional for production.** At minimum, TOTP support must be available. WebAuthn/passkeys are the recommended primary factor for new applications.
5. **Social login is account linking, not account creation.** Social providers give you identity signals, not user accounts. Design the linking strategy carefully to prevent account takeover.
6. **Show the code, not the design.** Produce implementation artifacts: middleware, controllers, services, models, and tests. Architecture without code is a diagram.
7. **Password handling has exactly one right answer.** Argon2id (preferred) or bcrypt with cost factor 12+. No MD5, no SHA-256, no PBKDF2 with low iterations. No exceptions.

## Example Usage

### Designing JWT auth for a microservices API
```
User: /godmode:auth Design authentication for our Node.js microservices API

Auth: Discovering requirements...

IDENTITY REQUIREMENTS:
Application type: Microservices (Node.js + Express)
User populations: End users (100K+), Admin users, Service accounts
Authentication needs: JWT + OAuth2/OIDC + API keys

STRATEGY SELECTION:
- User auth: JWT with RS256 (asymmetric, shared public key across services)
- Service-to-service: mTLS between internal services
- External API consumers: API keys with per-key scoping
- Social login: Google + GitHub via OIDC

JWT DESIGN:
Access token: 15 min TTL, RS256, claims: sub, roles, permissions
Refresh token: 7-day sliding, stored in HttpOnly cookie
Token rotation: New refresh token on every refresh
Revocation: Redis blacklist for access tokens, DB delete for refresh tokens

Generating implementation artifacts...
  src/auth/middleware/authenticate.ts — JWT validation middleware
  src/auth/services/token.ts — RS256 token signing and verification
  src/auth/controllers/login.ts — Login with password + MFA
  ...
```

### Adding MFA to an existing application
```
User: /godmode:auth Add TOTP and passkey support to our existing auth system

Auth: Analyzing existing auth implementation...
  Found: JWT-based auth in src/auth/
  Found: User model in src/models/user.ts
  Missing: MFA tables, MFA middleware, enrollment endpoints

MFA DESIGN:
Primary: WebAuthn/Passkeys (recommended for new enrollments)
Secondary: TOTP (Google Authenticator compatible)
Recovery: 8 single-use recovery codes

Implementation plan:
  1. Database migration: mfa_credentials, recovery_codes tables
  2. Enrollment endpoints: POST /auth/mfa/totp/setup, POST /auth/mfa/webauthn/register
  3. Verification middleware: Check mfa_required flag on sensitive routes
  4. Step-up auth: Re-verify MFA for password change, payment, admin actions
  ...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full auth architecture design and implementation |
| `--strategy jwt` | JWT-based authentication design |
| `--strategy oauth` | OAuth2/OIDC integration design |
| `--strategy saml` | SAML federation design |
| `--strategy session` | Server-side session design |
| `--strategy apikey` | API key authentication design |
| `--strategy mtls` | Mutual TLS design |
| `--mfa` | MFA design and implementation only |
| `--passwordless` | Passwordless authentication design |
| `--social` | Social login integration only |
| `--tokens` | Token lifecycle design only |
| `--sessions` | Session management design only |
| `--audit` | Audit existing auth implementation |
| `--harden` | Security hardening review only |
| `--migrate` | Migrate between auth strategies |

## Auth Flow Audit Loop

Structured audit of authentication flows — session management, token handling, and OAuth verification:

```
auth_flows = [session_management, token_lifecycle, oauth_verification,
              mfa_flow, password_reset, social_login, api_key_handling]
current_flow = 0
max_iterations = len(auth_flows) + 3   # buffer for discovered flows

WHILE current_flow < len(auth_flows) AND iteration < max_iterations:
    flow = auth_flows[current_flow]
    iteration += 1

    PHASE 1 — MAP:
      Trace the complete flow: entry point → authentication → session/token creation → usage → expiry/revocation
      Identify all state transitions and decision points
      Record all endpoints, middleware, and services involved

    PHASE 2 — AUDIT:
      IF session_management:
        CHECK: Session ID is cryptographically random (256+ bits)
        CHECK: Session regenerated after login (fixation prevention)
        CHECK: Idle timeout enforced server-side (not just client-side)
        CHECK: Absolute timeout exists (even active sessions expire)
        CHECK: Cookie flags set: HttpOnly, Secure, SameSite
        CHECK: Concurrent session limit enforced
        CHECK: Session destroyed on logout (server-side + cookie cleared)

      IF token_lifecycle:
        CHECK: Access token TTL <= 15 minutes
        CHECK: Refresh token rotation enabled (new token on each use)
        CHECK: Refresh token family tracking (detect reuse → revoke family)
        CHECK: Algorithm explicitly validated on verification (no alg confusion)
        CHECK: Audience (aud) and issuer (iss) claims verified
        CHECK: Token blacklist/revocation mechanism exists
        CHECK: No sensitive data in token payload

      IF oauth_verification:
        CHECK: PKCE required for all authorization code flows
        CHECK: State parameter validated (CSRF prevention)

## Keep/Discard Discipline

```
FOR each auth audit finding:
  KEEP if:
    - Failed check has concrete security impact (exploitable weakness)
    - Finding affects production authentication path
    - Finding has code evidence (file:line where the weakness exists)
  DISCARD if:
    - Check is not applicable to chosen auth strategy (e.g., SAML check on JWT-only system)
    - Feature is intentionally not implemented with documented justification
    - Already remediated in current codebase (verify with code evidence)
  RECORD: Every discard logged with reason to .godmode/auth-discards.tsv:
    timestamp	flow_name	check_name	discard_reason
```

## Auto-Detection

Before prompting the user, automatically detect authentication context:

```
AUTO-DETECT SEQUENCE:
1. Detect application type:
   - SPA: check for react, vue, angular with no server rendering
   - SSR: check for next.js, nuxt, angular universal
   - API-only: check for express, fastapi, gin without frontend
   - Mobile: check for react-native, flutter, swift, kotlin
2. Detect existing auth implementation:
   - grep for 'passport', 'next-auth', 'auth0', 'firebase/auth', 'supabase/auth'
   - grep for 'jsonwebtoken', 'jose', 'jwt', 'bcrypt', 'argon2'
   - Find auth-related routes: /login, /register, /auth/, /oauth/
3. Detect identity providers:
   - grep for OAuth client IDs, OIDC configs, SAML metadata
   - Check .env.example for AUTH0_*, GOOGLE_CLIENT_ID, etc.
4. Detect session management:
   - grep for 'express-session', 'cookie-session', 'iron-session'
   - Check for Redis session store configuration
   - Check cookie settings (HttpOnly, Secure, SameSite)
5. Detect MFA:
   - grep for 'speakeasy', 'otplib', '@simplewebauthn', 'webauthn'
   - Check for TOTP or WebAuthn database tables
6. Detect security posture:
   - Check for rate limiting on auth routes
   - Check for CORS configuration
   - Check for HTTPS enforcement (HSTS headers)
   - Check password hashing algorithm (bcrypt cost, argon2 params)
7. Auto-configure:
   - No auth → recommend strategy based on app type
   - Existing auth → audit for security gaps
   - Missing MFA → flag as security gap for production
```

## Multi-Agent Dispatch

For comprehensive auth implementation across a full-stack application:

```
PARALLEL AUTH IMPLEMENTATION:
IF application has multiple surfaces (web + mobile + API):
  Agent 1 (worktree: auth-core):
    - Design token lifecycle (JWT signing, refresh rotation, revocation)
    - Implement auth services (token, session, password)
    - Set up key management and rotation

  Agent 2 (worktree: auth-endpoints):
    - Implement auth controllers (login, register, logout, refresh)
    - Implement MFA enrollment and verification
    - Implement social login callbacks

## Output Format

Every auth skill invocation must produce a structured report:

```
┌────────────────────────────────────────────────────────────┐
│  AUTH RESULT                                                │
├────────────────────────────────────────────────────────────┤
│  Strategy: <JWT | Session | OAuth2/OIDC | SAML | Hybrid>   │
│  MFA: <TOTP | WebAuthn | SMS | None>                       │
│  Endpoints: <N designed/implemented>                        │
│  Security controls: <N passed> / <N total>                  │
│  Verdict: <PRODUCTION READY | NEEDS HARDENING | INCOMPLETE> │
└────────────────────────────────────────────────────────────┘
```

## TSV Logging

Log every auth design or audit to `.godmode/auth-decisions.tsv`:

```
timestamp	feature	strategy	mfa_type	endpoints	controls_passed	controls_total	verdict
```

Append one row per invocation. Never overwrite previous rows.

## Success Criteria

```
PASS if ALL of the following:
  - Password hashing uses Argon2id or bcrypt (cost >= 12)
  - Access tokens are short-lived (<= 15 min)
  - Refresh tokens use rotation with family-based revocation
  - Token storage follows client-type recommendations (no localStorage for JWTs)
  - HTTPS enforced with HSTS header
  - Rate limiting active on login and registration endpoints
  - MFA available for production applications
  - All security checklist items for the chosen strategy are YES

FAIL if ANY of the following:
  - Passwords stored in plaintext, MD5, or SHA-256
  - Algorithm confusion possible (no explicit algorithm validation on JWT verify)
  - Refresh tokens are not rotated
  - Secrets hardcoded in source code
  - No rate limiting on authentication endpoints
  - Implicit grant used for any client type
```

## Error Recovery

```
IF auth implementation fails tests:
  1. Identify the specific failing test (token validation, session handling, MFA flow)
  2. Check for common causes: missing environment variables, incorrect key format, expired test tokens
  3. Fix the root cause in the auth module — do not disable the test
  4. Re-run the full auth test suite — partial passes are not acceptable
  5. If fix introduces a regression, revert the fix and re-approach

IF auth strategy does not match application type:
  1. Re-run Step 1 (Identity Requirements Discovery) with corrected application type
  2. Select the correct strategy (do not force a strategy that does not fit)
  3. Discard artifacts from the wrong strategy — do not adapt them

IF token signing key is compromised:
  1. Generate new signing key immediately
  2. Deploy new key to all services
  3. Invalidate all existing tokens (force re-authentication)
  4. Audit access logs during the compromise window
  5. Post-incident: rotate keys on schedule to limit future blast radius
```

## Platform Fallback
Run tasks sequentially with branch isolation if `Agent()` or `EnterWorktree` unavailable. See `adapters/shared/sequential-dispatch.md`.
## Stop Conditions
```
STOP when ANY of these are true:
  - All auth flows audited and security checklist items pass
  - Token lifecycle complete (issuance, validation, refresh, revocation, cleanup)
  - MFA available for production applications
  - User explicitly requests stop

DO NOT STOP just because:
  - Social login is not yet configured (if not requested)
  - One auth flow has a known limitation documented with mitigation
```