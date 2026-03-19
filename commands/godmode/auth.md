# /godmode:auth

Design and implement authentication and authorization architecture. Covers auth strategy selection (JWT, OAuth2, OIDC, SAML, API keys, mTLS), session management, multi-factor authentication, passwordless auth, token lifecycle, and social login integration.

## Usage

```
/godmode:auth                          # Full auth architecture design
/godmode:auth --strategy jwt           # JWT-based authentication
/godmode:auth --strategy oauth         # OAuth2/OIDC integration
/godmode:auth --strategy saml          # SAML federation
/godmode:auth --strategy session       # Server-side session design
/godmode:auth --strategy apikey        # API key authentication
/godmode:auth --strategy mtls          # Mutual TLS design
/godmode:auth --mfa                    # MFA design and implementation
/godmode:auth --passwordless           # Passwordless authentication
/godmode:auth --social                 # Social login integration
/godmode:auth --tokens                 # Token lifecycle design
/godmode:auth --sessions               # Session management design
/godmode:auth --audit                  # Audit existing auth implementation
/godmode:auth --harden                 # Security hardening review
/godmode:auth --migrate                # Migrate between auth strategies
```

## What It Does

1. Discovers identity requirements (user populations, auth needs, compliance constraints)
2. Selects and designs auth strategy (JWT, OAuth2/OIDC, SAML, API keys, mTLS)
3. Designs session management (stateful vs stateless, cookie config, timeouts)
4. Designs MFA implementation (TOTP, WebAuthn/passkeys, recovery codes)
5. Designs passwordless flows (magic links, passkeys, OTP)
6. Designs token lifecycle (issuance, validation, refresh, rotation, revocation, cleanup)
7. Designs social login integration (Google, GitHub, Apple, Microsoft)
8. Produces security hardening checklist (password policy, brute force, transport)
9. Generates implementation artifacts (middleware, controllers, services, models, tests)

## Output
- Auth architecture document at `docs/auth/<feature>-auth-architecture.md`
- Implementation code in `src/auth/` (strategies, middleware, controllers, services, models)
- Integration tests in `tests/auth/`
- Commit: `"auth: <feature> — <strategy> with <MFA type>, <N> endpoints"`
- Verdict: PRODUCTION READY / NEEDS HARDENING / INCOMPLETE

## Next Step
If incomplete: Address remaining items, then re-run `/godmode:auth`.
If production ready: `/godmode:rbac` to design access control, or `/godmode:build` to implement.

## Examples

```
/godmode:auth                          # Full auth design for your app
/godmode:auth --strategy jwt --mfa     # JWT auth with MFA
/godmode:auth --social                 # Add Google + GitHub login
/godmode:auth --harden                 # Review existing auth security
/godmode:auth --migrate                # Migrate from sessions to JWT
```
