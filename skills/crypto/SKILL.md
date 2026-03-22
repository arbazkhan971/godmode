---
name: crypto
description: |
  Cryptography implementation skill. Activates when user needs to implement encryption (at rest or in transit), key management, password hashing (Argon2, bcrypt), digital signatures, JWT security, TLS hardening, or any cryptographic operation. Triggers on: /godmode:crypto, "encryption", "hashing", "key management", "TLS setup", "digital signature", "JWT signing", or when code handles sensitive data.
---

# Crypto — Cryptography Implementation

## When to Activate
- User invokes `/godmode:crypto`
- User says "encryption", "hashing", "password storage", "bcrypt", "argon2"
- User says "key management", "digital signature", "JWT signing"
- User says "TLS setup", "HTTPS configuration", "certificate"
- When code handles sensitive data (PII, financial, health records)

## Workflow

### Step 1: Requirements Assessment
Classify data: at rest (passwords, PII, financial, API keys), in transit (TLS, mTLS, DB connections), integrity (signatures, HMAC, checksums), compliance (PCI-DSS, HIPAA, GDPR, FIPS).

### Step 2: Algorithm Selection

**Password hashing:** Argon2id (m=65536, t=3, p=4) primary. bcrypt (cost 12+) fallback. NEVER MD5, SHA1, SHA256, PBKDF2 (<100K iter).

**Symmetric encryption:** AES-256-GCM (AEAD, general). ChaCha20-Poly1305 (software-fast). NEVER ECB, DES, 3DES, RC4, AES-CBC without HMAC.

**Asymmetric:** X25519 (key exchange). RSA-OAEP 2048+ (encryption). NEVER PKCS1v1.5 or RSA <2048.

**Signatures:** Ed25519 (primary). RS256/ES256 (JWT). NEVER RSA PKCS1v1.5 sigs, DSA.

**Hashing (non-password):** SHA-256 (general). BLAKE3 (modern). HMAC-SHA-256 (keyed). NEVER MD5, SHA-1.

**Key derivation:** Argon2id (from password). HKDF-SHA-256 (from shared secret).

**Random:** CSPRNG only (crypto.randomBytes, secrets, crypto/rand). NEVER Math.random().

### Step 3: Encryption at Rest
Use **envelope encryption**: unique DEK per record (AES-256-GCM) encrypted by KEK from KMS. Store encrypted data + encrypted DEK + IV + auth tag. Unique 96-bit IV per operation. Master key in KMS. Track key version.

**Database:** TDE (physical theft) + column encryption (SQLi) + connection TLS (network).

### Step 4: TLS Hardening
- TLS 1.2 minimum, 1.3 preferred. Disable SSLv2/v3, TLS 1.0/1.1.
- AEAD ciphers only (GCM, ChaCha20-Poly1305). ECDHE required (forward secrecy).
- ECDSA P-256 or RSA 2048+ certs. OCSP stapling. HSTS with preload.
- Test: ssllabs.com/ssltest (target A+).

### Step 5: Password Hashing
Argon2id with auto-generated salt, constant-time comparison. Hash never encrypt. No length limits (allow 128+). Check breach lists. No composition rules (NIST 800-63B). Min 8 chars. Upgrade old hashes on login. Rate limit auth. Never log passwords.

### Step 6: JWT Security
- Single service: HS256 (256-bit+ key). Multiple services: RS256/ES256.
- NEVER "none" algorithm or HS256 with RSA pubkey.
- Verify: algorithm, issuer, audience, expiration. No sensitive data in payload. Key rotation via JWKS.

### Step 7: Key Management Lifecycle
**Generation:** CSPRNG, 256-bit+ symmetric, RSA 2048+. Generate in KMS.
**Storage:** KMS/Vault (production). Env vars (dev). NEVER hardcoded.
**Rotation:** Encryption 365d, signing/JWT 90d, TLS 90d. Compromise: immediately.
**Process:** New -> deploy -> grace -> retire old. Track version with data.

### Step 8: Report
```
CRYPTO RESULT:
Use case: <encryption at rest | transit | passwords | JWT | sigs>
Algorithm: <AES-256-GCM | Argon2id | RS256 | etc.>
Key management: <KMS | Vault | env var | none>
Key rotation: <defined | not defined>
Weak crypto found: <N>
Verdict: <SECURE | NEEDS IMPROVEMENT | INSECURE>
```

## Key Behaviors

1. **Use established libraries.** Never implement your own crypto.
2. **Algorithm selection is not negotiable.** AES-256-GCM, Argon2id, RS256/ES256.
3. **Never reuse nonces/IVs.** Single reuse with GCM breaks authentication.
4. **Key management is the hard part.** Use KMS or Vault.
5. **Envelope encryption for data.** Never encrypt directly with master key.
6. **Forward secrecy is mandatory.** ECDHE for TLS.
7. **Hash passwords, never encrypt.** Hashing is one-way.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full cryptographic assessment |
| `--passwords` | Password hashing setup |
| `--encrypt` | Encryption at rest |
| `--tls` | TLS hardening |
| `--jwt` | JWT signing/verification |
| `--keys` | Key management and rotation |
| `--audit` | Audit existing crypto |

## HARD RULES

1. NEVER implement your own cryptographic primitives.
2. NEVER reuse IVs/nonces with the same key.
3. NEVER store keys alongside encrypted data.
4. NEVER use MD5, SHA-1, DES, 3DES, RC4, or ECB for security.
5. NEVER encrypt passwords — hash with Argon2id or bcrypt.
6. NEVER use Math.random() for keys, tokens, or IVs.
7. ALWAYS use authenticated encryption (GCM, ChaCha20-Poly1305).
8. ALWAYS track key version with encrypted data.

## Auto-Detection

```
1. grep for crypto, encrypt, decrypt, hash, bcrypt, argon2, jwt, jose
2. grep for password, bcrypt, argon2, scrypt, pbkdf2
3. Check nginx.conf for ssl_protocols, ssl_ciphers
4. grep for md5, sha1, des, ecb, Math.random — flag immediately
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
Run crypto tasks inline. All conventions apply identically.

## Output Format
Print: `Crypto: {N} issues found, {M} fixed. Weak algorithms: {removed|none}. Key management: {env_vars|hardcoded}. Status: {DONE|PARTIAL}.`

## Error Recovery
| Failure | Action |
|--|--|
| Deprecated algorithm in production | Replace immediately (MD5/SHA1 -> SHA-256+, DES/3DES -> AES-256-GCM). Migrate existing hashes on next user login. |
| Key rotation breaks decryption | Store key version with ciphertext. Support decryption with old key, encryption with new key during rotation window. |
| CSPRNG not available | Use `crypto.randomBytes` (Node), `secrets` (Python), `crypto/rand` (Go). Never fall back to `Math.random` or `random`. |
| TLS certificate expired | Automate renewal with Let's Encrypt/certbot. Set monitoring alert 30 days before expiry. |

## Success Criteria
1. No weak algorithms (MD5, SHA1, DES, ECB mode, `Math.random` for security).
2. All secrets from environment variables or secret managers (not hardcoded).
3. Passwords hashed with bcrypt/argon2/scrypt (not SHA-256).
4. TLS 1.2+ enforced for all connections.

## TSV Logging
Append to `.godmode/crypto-results.tsv`:
```
timestamp	finding_type	severity	location	algorithm_before	algorithm_after	status
```
One row per finding. Status: fixed, open, accepted_risk.

## Keep/Discard Discipline
```
After EACH crypto change:
  KEEP if: no weak algorithms AND all tests pass AND existing encrypted data still decryptable
  DISCARD if: introduces weak algorithm OR breaks existing decryption OR hardcodes secrets
  On discard: revert immediately. Crypto regressions are security incidents.
```

## Stop Conditions
```
STOP when ALL of:
  - No weak algorithms in codebase
  - All secrets in env vars or secret managers
  - Password hashing uses bcrypt/argon2/scrypt
  - TLS 1.2+ enforced
```
