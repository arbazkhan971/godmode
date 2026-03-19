# Authentication Flow Reference

> Complete reference for authentication and authorization flows, JWT lifecycle, session management, and MFA implementation patterns.

---

## OAuth 2.0 Flows

### 1. Authorization Code Flow

The standard flow for server-side web applications. The most secure OAuth2 flow for applications that can keep a client secret.

```
┌──────────┐     1. Redirect to authorize     ┌──────────────┐
│          │ ──────────────────────────────►   │              │
│  Browser │                                   │  Auth Server │
│          │ ◄──────────────────────────────   │              │
│          │     2. Redirect with auth code     │              │
└────┬─────┘                                   └──────┬───────┘
     │                                                 │
     │  3. Send auth code                              │
     ▼                                                 │
┌──────────┐     4. Exchange code for tokens   ┌──────┴───────┐
│  Backend │ ──────────────────────────────►   │  Auth Server │
│  Server  │ ◄──────────────────────────────   │  Token       │
│          │     5. Access token + Refresh token│  Endpoint    │
└──────────┘                                   └──────────────┘
```

**Step-by-step:**

```
1. AUTHORIZATION REQUEST:
   GET https://auth.example.com/authorize?
     response_type=code
     &client_id=CLIENT_ID
     &redirect_uri=https://app.example.com/callback
     &scope=read write
     &state=RANDOM_STATE_VALUE          ← CSRF protection

2. USER AUTHENTICATES:
   Auth server presents login page.
   User grants consent.

3. AUTHORIZATION RESPONSE:
   302 Redirect → https://app.example.com/callback?
     code=AUTH_CODE_VALUE
     &state=RANDOM_STATE_VALUE          ← Must match request state

4. TOKEN EXCHANGE (server-side, not in browser):
   POST https://auth.example.com/token
   Content-Type: application/x-www-form-urlencoded

   grant_type=authorization_code
   &code=AUTH_CODE_VALUE
   &redirect_uri=https://app.example.com/callback
   &client_id=CLIENT_ID
   &client_secret=CLIENT_SECRET

5. TOKEN RESPONSE:
   {
     "access_token": "eyJhbGciOiJSUzI1NiIs...",
     "token_type": "Bearer",
     "expires_in": 3600,
     "refresh_token": "dGhpcyBpcyBhIHJlZnJl...",
     "scope": "read write"
   }
```

**When to use:** Server-rendered web apps, any backend that can securely store a client secret.

---

### 2. Authorization Code with PKCE (Proof Key for Code Exchange)

The recommended flow for single-page applications (SPAs) and mobile apps that cannot securely store a client secret.

```
┌──────────────┐                              ┌──────────────┐
│  SPA/Mobile  │                              │  Auth Server │
│              │                              │              │
│  1. Generate │                              │              │
│     code_verifier (random 43-128 chars)     │              │
│     code_challenge = SHA256(code_verifier)  │              │
│              │                              │              │
│  2. ─────────── Authorize + code_challenge ──────────────► │
│              │                              │              │
│  3. ◄─────────── Auth code ──────────────────────────────  │
│              │                              │              │
│  4. ─────────── Exchange code + code_verifier ───────────► │
│              │                              │              │
│  5. ◄─────────── Access token + Refresh token ───────────  │
└──────────────┘                              └──────────────┘
```

**Key difference from standard Authorization Code:**

```
AUTHORIZATION REQUEST (adds PKCE params):
  GET https://auth.example.com/authorize?
    response_type=code
    &client_id=CLIENT_ID
    &redirect_uri=https://app.example.com/callback
    &scope=read write
    &state=RANDOM_STATE
    &code_challenge=E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
    &code_challenge_method=S256

TOKEN EXCHANGE (sends verifier instead of secret):
  POST https://auth.example.com/token
  grant_type=authorization_code
  &code=AUTH_CODE_VALUE
  &redirect_uri=https://app.example.com/callback
  &client_id=CLIENT_ID
  &code_verifier=dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk
```

**Why PKCE matters:**
- Authorization code can be intercepted (mobile deep links, browser history)
- Without PKCE, an attacker with the code can exchange it for tokens
- With PKCE, the attacker also needs the code_verifier (never transmitted in the authorize step)

**When to use:** SPAs, mobile apps, desktop apps, CLI tools — any public client.

---

### 3. Client Credentials Flow

Machine-to-machine authentication. No user involved.

```
┌──────────────┐     POST /token              ┌──────────────┐
│  Service A   │ ──────────────────────────►   │  Auth Server │
│              │   client_id + client_secret   │              │
│              │ ◄──────────────────────────   │              │
│              │     Access token (no refresh)  │              │
└──────────────┘                               └──────────────┘
```

```
TOKEN REQUEST:
  POST https://auth.example.com/token
  Content-Type: application/x-www-form-urlencoded

  grant_type=client_credentials
  &client_id=SERVICE_A_CLIENT_ID
  &client_secret=SERVICE_A_SECRET
  &scope=orders:read inventory:write

TOKEN RESPONSE:
  {
    "access_token": "eyJhbGciOiJSUzI1NiIs...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "orders:read inventory:write"
  }
```

**No refresh token is issued.** When the access token expires, the service simply requests a new one with its credentials.

**When to use:** Microservice-to-microservice communication. Background jobs, cron tasks. CI/CD pipelines accessing APIs.

---

### 4. Device Authorization Flow (Device Code)

For input-constrained devices (smart TVs, IoT, CLI tools) that cannot display a browser.

```
┌─────────────┐    1. Request device code     ┌──────────────┐
│  Device     │ ─────────────────────────────► │  Auth Server │
│  (Smart TV) │ ◄───────────────────────────── │              │
│             │    2. Device code + user_code   │              │
│             │       + verification_uri        │              │
│             │                                │              │
│  Display:   │                                │              │
│  "Go to     │                                │              │
│  example.com│                                │              │
│  /activate  │                                │              │
│  Enter code:│                                │              │
│  ABCD-1234" │                                │              │
│             │                                │              │
│  3. Poll ──────────────────────────────────► │              │
│     for     │    "authorization_pending"     │              │
│     token   │ ◄───────────────────────────── │              │
│             │                                │              │
│  4. Poll ──────────────────────────────────► │              │
│     again   │    Access token + Refresh token│              │
│             │ ◄───────────────────────────── │              │
└─────────────┘                                └──────────────┘

Meanwhile, on the user's phone/laptop:
┌─────────────┐    5. Visit verification_uri  ┌──────────────┐
│  Browser    │ ─────────────────────────────► │  Auth Server │
│  (Phone)    │    Enter code: ABCD-1234      │              │
│             │    Authenticate + consent      │              │
└─────────────┘                                └──────────────┘
```

```
STEP 1 — DEVICE CODE REQUEST:
  POST https://auth.example.com/device/code
  client_id=DEVICE_CLIENT_ID
  &scope=read write

STEP 2 — DEVICE CODE RESPONSE:
  {
    "device_code": "GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS",
    "user_code": "ABCD-1234",
    "verification_uri": "https://example.com/activate",
    "verification_uri_complete": "https://example.com/activate?user_code=ABCD-1234",
    "expires_in": 1800,
    "interval": 5
  }

STEP 3 — POLLING:
  POST https://auth.example.com/token
  grant_type=urn:ietf:params:oauth:grant-type:device_code
  &device_code=GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS
  &client_id=DEVICE_CLIENT_ID

  Response (waiting): { "error": "authorization_pending" }
  Response (too fast): { "error": "slow_down" }
  Response (success):  { "access_token": "...", "refresh_token": "..." }
```

**When to use:** Smart TVs, game consoles, IoT devices, CLI tools where opening a browser locally is impractical.

---

## JWT Lifecycle

### Token Structure

```
HEADER.PAYLOAD.SIGNATURE

Header (base64url):
{
  "alg": "RS256",           ← Signing algorithm
  "typ": "JWT",
  "kid": "key-2025-03"      ← Key ID for rotation
}

Payload (base64url):
{
  "iss": "https://auth.example.com",     ← Issuer
  "sub": "user_123",                      ← Subject (user ID)
  "aud": "https://api.example.com",       ← Audience (intended recipient)
  "exp": 1710500400,                      ← Expiration (Unix timestamp)
  "iat": 1710496800,                      ← Issued at
  "nbf": 1710496800,                      ← Not before
  "jti": "jwt_abc123",                    ← Unique token ID
  "scope": "read write",                  ← Granted scopes
  "roles": ["admin", "editor"],           ← Custom claim: roles
  "org_id": "org_456"                     ← Custom claim: tenant
}

Signature:
  RS256(base64url(header) + "." + base64url(payload), private_key)
```

### Token Lifecycle Diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           JWT LIFECYCLE                                    │
│                                                                           │
│  ┌─────────────┐                                                          │
│  │   ISSUED    │ ← Auth server creates and signs token                    │
│  │  (iat)      │                                                          │
│  └──────┬──────┘                                                          │
│         │                                                                 │
│         ▼                                                                 │
│  ┌─────────────┐                                                          │
│  │   ACTIVE    │ ← Token is valid, accepted by resource servers           │
│  │  (nbf→exp)  │   Validation: signature, exp, iss, aud, nbf             │
│  └──────┬──────┘                                                          │
│         │                                                                 │
│         ├──── Normal use: Present in Authorization header ────────────►   │
│         │     Authorization: Bearer eyJhbGciOiJSUzI1NiIs...              │
│         │                                                                 │
│         ├──── Approaching expiry: Use refresh token ──────────────────►   │
│         │     POST /token { grant_type: "refresh_token", ... }            │
│         │     → New access token + new refresh token                      │
│         │                                                                 │
│         ▼                                                                 │
│  ┌─────────────┐                                                          │
│  │  EXPIRED    │ ← Current time > exp claim                               │
│  │  (past exp) │   Resource server rejects with 401                       │
│  └──────┬──────┘                                                          │
│         │                                                                 │
│         ├──── Refresh token valid: Silent refresh ────────────────────►   │
│         │     User does not notice, new tokens issued                     │
│         │                                                                 │
│         ├──── Refresh token expired: Re-authenticate ─────────────────►   │
│         │     Redirect to login                                           │
│         │                                                                 │
│         ▼                                                                 │
│  ┌─────────────┐                                                          │
│  │  REVOKED    │ ← Explicit revocation (logout, password change, breach)  │
│  │  (blocklist)│   Token added to blocklist until its natural expiry      │
│  └─────────────┘                                                          │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

### Token Validation Checklist

```
JWT VALIDATION (in order):
1. ✓ Parse the token (split by '.', base64url decode)
2. ✓ Verify signature using the public key (fetched via JWKS endpoint)
3. ✓ Check 'exp' — reject if current time > exp
4. ✓ Check 'nbf' — reject if current time < nbf
5. ✓ Check 'iss' — must match expected issuer
6. ✓ Check 'aud' — must include this service's audience identifier
7. ✓ Check blocklist — reject if jti is in the revocation list
8. ✓ Check required claims (scope, roles, org_id, etc.)
9. ✓ Clock skew tolerance — allow 30-60 seconds for clock drift
```

### Token Refresh Flow

```
┌──────────┐                                    ┌──────────────┐
│  Client  │                                    │  Auth Server │
│          │  1. Access token expired (401)      │              │
│          │                                    │              │
│          │  2. POST /token                    │              │
│          │     grant_type=refresh_token       │              │
│          │     refresh_token=dGhpcyBpcyBh... │              │
│          │ ──────────────────────────────────►│              │
│          │                                    │              │
│          │  3. New access token               │              │
│          │     + new refresh token            │              │
│          │     (refresh token rotation)       │              │
│          │ ◄──────────────────────────────────│              │
│          │                                    │              │
│          │  4. Retry original request          │              │
│          │     with new access token          │              │
└──────────┘                                    └──────────────┘

REFRESH TOKEN ROTATION:
- Each refresh returns a NEW refresh token
- Old refresh token is invalidated immediately
- If an old refresh token is reused → REVOKE ALL tokens for that user
  (indicates token theft: attacker has old token, legitimate user has new one)
```

### Recommended Token Lifetimes

```
┌─────────────────────────┬──────────────────┬────────────────────────────────┐
│  Token Type             │  Lifetime         │  Rationale                      │
├─────────────────────────┼──────────────────┼────────────────────────────────┤
│  Access token           │  15-60 minutes    │  Short-lived, limits blast     │
│                         │                   │  radius of stolen token        │
├─────────────────────────┼──────────────────┼────────────────────────────────┤
│  Refresh token          │  7-30 days        │  Long-lived for UX, but        │
│                         │                   │  rotated on each use           │
├─────────────────────────┼──────────────────┼────────────────────────────────┤
│  ID token               │  5-15 minutes     │  Only used at authentication   │
│                         │                   │  time, not for API access      │
├─────────────────────────┼──────────────────┼────────────────────────────────┤
│  Service token (M2M)    │  1-24 hours       │  Client credentials can be     │
│                         │                   │  re-fetched easily             │
├─────────────────────────┼──────────────────┼────────────────────────────────┤
│  Password reset token   │  15-60 minutes    │  Single use, time-limited      │
├─────────────────────────┼──────────────────┼────────────────────────────────┤
│  Email verification     │  24-72 hours      │  User may not check email      │
│  token                  │                   │  immediately                   │
└─────────────────────────┴──────────────────┴────────────────────────────────┘
```

---

## Session Management Patterns

### 1. Stateless Sessions (JWT in Cookie)

```
SERVER:
  Set-Cookie: session=eyJhbGciOiJSUzI1NiIs...;
    HttpOnly;       ← Not accessible via JavaScript (XSS protection)
    Secure;         ← Only sent over HTTPS
    SameSite=Lax;   ← CSRF protection
    Path=/;
    Max-Age=3600;
    Domain=.example.com

CLIENT:
  Every request automatically includes the cookie.
  No JavaScript token management needed.
```

**Pros:** No server-side session storage. Scales horizontally without shared state.
**Cons:** Cannot revoke individual sessions without a blocklist. Token size adds to every request.

### 2. Stateful Sessions (Server-Side Store)

```
LOGIN:
  Client sends credentials → Server validates
  Server creates session:
    session_id: "sess_abc123"
    user_id: "user_456"
    created_at: "2025-03-15T10:00:00Z"
    expires_at: "2025-03-15T22:00:00Z"
    ip: "203.0.113.42"
    user_agent: "Mozilla/5.0..."
  Server stores session in Redis/database
  Server sets cookie: session_id=sess_abc123

EACH REQUEST:
  Client sends cookie → Server looks up session in store
  If valid: proceed with request
  If expired/missing: 401 Unauthorized

LOGOUT:
  Server deletes session from store
  Server clears cookie

SESSION STORE OPTIONS:
┌────────────────┬──────────────────────────────────────────────────┐
│  Store         │  Characteristics                                  │
├────────────────┼──────────────────────────────────────────────────┤
│  Redis         │  Fast, TTL support, cluster mode for scale        │
│  PostgreSQL    │  Durable, queryable, slower than Redis             │
│  DynamoDB      │  Managed, auto-scaling, TTL support               │
│  Memcached     │  Fast, but no persistence (restart = all logged out)│
│  In-memory     │  Development only. Lost on server restart.         │
└────────────────┴──────────────────────────────────────────────────┘
```

**Pros:** Instant revocation (delete from store). Small cookie size. Full server control.
**Cons:** Requires shared session store. Additional infrastructure. Latency per request for session lookup.

### 3. Hybrid: Short-Lived JWT + Server-Side Refresh

```
AUTH FLOW:
  1. User logs in → Server issues:
     - Access token (JWT, 15 min, stateless)
     - Refresh token (opaque, stored in DB, 30 days)

  2. API requests use access token (no DB lookup, fast)

  3. Access token expires → Client uses refresh token
     - Server validates refresh token against DB
     - Issues new access token + new refresh token
     - Revokes old refresh token

  4. Logout → Server revokes refresh token
     - Access token remains valid until expiry (max 15 min)
     - For immediate revocation: add jti to short-lived blocklist

ADVANTAGES:
  - Fast API requests (stateless JWT validation)
  - Revocable sessions (via refresh token)
  - Short blast radius (15 min max for stolen access token)
```

### 4. Session Security Checklist

```
SESSION SECURITY:
├── Cookie flags
│   ├── HttpOnly:   REQUIRED — prevents XSS access to session
│   ├── Secure:     REQUIRED — HTTPS only
│   ├── SameSite:   REQUIRED — Lax (default) or Strict
│   └── Path:       SET to most restrictive path needed
│
├── Session fixation prevention
│   └── Regenerate session ID after login (never reuse pre-auth session)
│
├── Session hijacking prevention
│   ├── Bind session to IP (optional, breaks mobile users)
│   ├── Bind session to User-Agent fingerprint
│   └── Rotate session ID periodically
│
├── Timeout policies
│   ├── Absolute timeout: 12-24 hours (force re-auth)
│   ├── Idle timeout: 30-60 minutes (inactivity)
│   └── Sliding expiration: reset idle timer on activity
│
├── Concurrent session control
│   ├── Allow multiple sessions (default, user-friendly)
│   ├── Limit to N sessions (e.g., 5 devices)
│   └── Single session (high security: new login kills old session)
│
└── Session revocation events
    ├── Password change → revoke all sessions
    ├── Email change → revoke all sessions
    ├── Role change → revoke all sessions
    ├── Account lock → revoke all sessions
    └── Explicit "log out all devices" → revoke all sessions
```

---

## MFA Implementation Patterns

### 1. TOTP (Time-Based One-Time Password)

```
ENROLLMENT:
  1. Server generates a shared secret (base32 encoded, 160+ bits)
  2. Server creates otpauth:// URI:
     otpauth://totp/Example:jane@example.com?
       secret=JBSWY3DPEHPK3PXP
       &issuer=Example
       &algorithm=SHA1
       &digits=6
       &period=30
  3. Server encodes URI as QR code, displays to user
  4. User scans QR code with authenticator app (Google Authenticator, Authy, etc.)
  5. User enters current TOTP code to verify enrollment
  6. Server stores encrypted secret and marks MFA as enabled
  7. Server generates recovery codes (8-10 single-use codes)

VERIFICATION:
  1. User logs in with username + password (factor 1)
  2. Server responds with MFA challenge
  3. User opens authenticator app, enters 6-digit code
  4. Server computes expected TOTP:
     TOTP = HOTP(secret, floor(current_unix_time / 30))
  5. Server checks current code AND ±1 time step (clock drift tolerance)
  6. If valid: issue session/tokens
  7. If invalid: increment failure counter, lock after N attempts

TOTP ALGORITHM:
  time_step = floor(unix_timestamp / 30)
  hmac = HMAC-SHA1(secret, time_step as 8-byte big-endian)
  offset = hmac[19] & 0x0F
  code = (hmac[offset..offset+3] & 0x7FFFFFFF) % 10^6
  → 6-digit code, changes every 30 seconds
```

### 2. WebAuthn / FIDO2 (Passkeys)

```
REGISTRATION:
  1. Server generates challenge (random bytes)
  2. Server sends registration options to client:
     {
       "challenge": "random-bytes-base64",
       "rp": { "name": "Example", "id": "example.com" },
       "user": { "id": "user_123", "name": "jane@example.com" },
       "pubKeyCredParams": [
         { "type": "public-key", "alg": -7 },    ← ES256
         { "type": "public-key", "alg": -257 }    ← RS256
       ],
       "authenticatorSelection": {
         "userVerification": "preferred",
         "residentKey": "preferred"
       }
     }
  3. Browser calls navigator.credentials.create(options)
  4. User verifies with biometrics/PIN on their device
  5. Authenticator creates key pair, returns:
     - credentialId
     - public key
     - attestation (proof of authenticator type)
  6. Server stores credentialId + public key for the user

AUTHENTICATION:
  1. Server sends assertion options:
     {
       "challenge": "random-bytes-base64",
       "rpId": "example.com",
       "allowCredentials": [{ "id": "cred_abc", "type": "public-key" }]
     }
  2. Browser calls navigator.credentials.get(options)
  3. User verifies with biometrics/PIN
  4. Authenticator signs the challenge with private key
  5. Server verifies signature using stored public key
  6. If valid: issue session/tokens
```

**Advantages over TOTP:** Phishing-resistant (bound to origin), no shared secret, biometric factor.

### 3. SMS / Email OTP

```
FLOW:
  1. User logs in with username + password
  2. Server generates 6-8 digit code, stores hash with TTL
  3. Server sends code via SMS or email
  4. User enters code within time window (5-10 minutes)
  5. Server verifies code hash, single use

SECURITY CONSIDERATIONS:
  ┌───────────────────────────────────────────────────────────────────┐
  │  SMS OTP RISKS:                                                   │
  │  - SIM swapping attacks (attacker ports victim's number)          │
  │  - SS7 network interception                                       │
  │  - Social engineering of carrier support                           │
  │  - Delivery delays and reliability issues                          │
  │                                                                    │
  │  MITIGATIONS:                                                      │
  │  - Offer TOTP/WebAuthn as preferred alternatives                  │
  │  - Rate limit OTP generation (max 3 per 10 minutes)               │
  │  - OTP codes expire in 5-10 minutes                                │
  │  - Single use — invalidate after first verification                │
  │  - Do not reuse codes within the same time window                  │
  │  - Log and alert on unusual MFA patterns                           │
  └───────────────────────────────────────────────────────────────────┘
```

### 4. Push Notification MFA

```
FLOW:
  1. User logs in with username + password
  2. Server sends push notification to registered device:
     "Login attempt from Chrome on macOS. Location: San Francisco."
  3. User taps "Approve" or "Deny" on their device
  4. Device sends signed response to server
  5. Server verifies and issues session/tokens

IMPLEMENTATION:
  - Requires a companion mobile app
  - Device registration stores a push token + device public key
  - Approval is signed by device private key (proof of possession)
  - Number matching: display a 2-digit number on login screen,
    user must select matching number on device (anti-phishing)
```

### 5. Recovery Codes

```
GENERATION:
  - Generate 8-10 codes at MFA enrollment time
  - Each code: 8 alphanumeric characters, grouped (e.g., ABCD-1234)
  - Store bcrypt/argon2 hashes of codes in database
  - Display codes ONCE to user, never again
  - User must store codes securely (password manager, printed)

USAGE:
  - User selects "Use recovery code" at MFA prompt
  - Enter one recovery code
  - Server verifies against stored hashes
  - Mark used code as consumed (single use)
  - After use: warn user to regenerate codes if running low

FORMAT EXAMPLE:
  ┌──────────────────────────────────────┐
  │  RECOVERY CODES — Save these now     │
  │                                      │
  │  1. ABCD-1234                        │
  │  2. EFGH-5678                        │
  │  3. IJKL-9012                        │
  │  4. MNOP-3456                        │
  │  5. QRST-7890                        │
  │  6. UVWX-1234                        │
  │  7. YZAB-5678                        │
  │  8. CDEF-9012                        │
  │                                      │
  │  Each code can only be used once.    │
  │  Store in a safe place.              │
  └──────────────────────────────────────┘
```

### MFA Decision Matrix

```
┌───────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│  Factor           │  TOTP    │  WebAuthn│  SMS OTP │  Push    │  Email   │
├───────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│  Phishing resist. │  Low     │  High    │  Low     │  Medium  │  Low     │
│  User convenience │  Medium  │  High    │  High    │  High    │  Medium  │
│  Setup complexity │  Medium  │  Low     │  Low     │  High    │  Low     │
│  Infra cost       │  None    │  None    │  Per-SMS │  Push svc│  Email   │
│  Offline support  │  Yes     │  Yes     │  No      │  No      │  No      │
│  Device required  │  Phone   │  Any     │  Phone   │  Phone   │  Email   │
│  Recovery         │  Codes   │  Codes   │  Alt num │  Codes   │  Alt addr│
│  Recommended for  │  General │  High    │  Low     │  General │  Low     │
│                   │  use     │  security│  security│  use     │  security│
└───────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

RECOMMENDATION:
  Primary:   WebAuthn/Passkeys (best security + UX)
  Secondary: TOTP (broad compatibility, no infrastructure cost)
  Fallback:  Recovery codes (always available)
  Avoid:     SMS OTP as sole MFA factor (SIM swap risk)
```

---

## Common Auth Anti-Patterns

| Anti-Pattern | Risk | Better Approach |
|---|---|---|
| Storing JWTs in localStorage | XSS can steal tokens | HttpOnly cookies or in-memory with refresh |
| Long-lived access tokens (24h+) | Extended blast radius | 15-60 min access token + refresh token |
| No refresh token rotation | Stolen refresh token = permanent access | Rotate on every use, detect reuse |
| Symmetric JWT signing (HS256) with shared secret | Any service with the secret can forge tokens | Asymmetric RS256/ES256, auth server holds private key |
| MFA bypass in password reset | Attacker resets password, skips MFA | Require MFA re-enrollment or recovery code after reset |
| Session fixation | Attacker sets session before login | Regenerate session ID after authentication |
| No session revocation on password change | Old sessions remain valid after credential change | Revoke all sessions on password/email/role change |
| Hardcoded secrets in source code | Secrets leak via version control | Use vault/secrets manager, rotate regularly |
