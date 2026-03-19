# /godmode:crypto

Implement cryptography correctly: encryption at rest and in transit, key management, password hashing (Argon2, bcrypt), digital signatures, JWT security, and TLS hardening.

## Usage

```
/godmode:crypto                         # Full cryptographic assessment and implementation
/godmode:crypto --passwords             # Password hashing setup (Argon2id/bcrypt)
/godmode:crypto --encrypt               # Encryption at rest implementation
/godmode:crypto --tls                   # TLS configuration hardening
/godmode:crypto --jwt                   # JWT signing and verification setup
/godmode:crypto --signatures            # Digital signature implementation
/godmode:crypto --keys                  # Key management and rotation setup
/godmode:crypto --audit                 # Audit existing cryptographic implementations
/godmode:crypto --migrate               # Migrate from weak to strong cryptography
/godmode:crypto --test                  # Generate tests for cryptographic operations
```

## What It Does

1. Assesses cryptographic requirements (data classification, compliance, threat model)
2. Selects correct algorithms for each use case (no weak or deprecated algorithms)
3. Implements encryption at rest with envelope encryption pattern (AES-256-GCM)
4. Hardens TLS configuration (TLS 1.2+, AEAD ciphers, forward secrecy, HSTS)
5. Implements password hashing with Argon2id or bcrypt (proper parameters)
6. Configures JWT signing with appropriate algorithm (RS256/ES256 for multi-service)
7. Implements digital signatures for API requests, documents, or artifacts
8. Sets up key management lifecycle (generation, storage, rotation, revocation)
9. Generates verification tests for all cryptographic operations

## Output
- Implementation code in appropriate modules
- TLS configuration for web server
- Key management procedures
- Commit: `"crypto: <feature> — <algorithm> for <use case>"`

## Next Step
After crypto is implemented: `/godmode:secure` for full security audit, `/godmode:secrets` for key storage, or `/godmode:ship` to deploy.

## Examples

```
/godmode:crypto --passwords             # Set up Argon2id password hashing
/godmode:crypto --tls                   # Harden Nginx/Apache TLS config
/godmode:crypto --encrypt               # Encrypt sensitive database fields
/godmode:crypto --jwt                   # Set up RS256 JWT signing
/godmode:crypto --audit                 # Check existing crypto for weaknesses
```
