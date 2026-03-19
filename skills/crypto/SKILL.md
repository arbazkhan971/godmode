---
name: crypto
description: |
  Cryptography implementation skill. Activates when user needs to implement encryption (at rest or in transit), key management, password hashing and storage (Argon2, bcrypt), digital signatures, JWT security, TLS configuration hardening, or any cryptographic operation. Ensures correct algorithm selection, safe parameter choices, and proper key lifecycle management. Produces implementation code with security rationale, configuration files, and verification tests. Triggers on: /godmode:crypto, "encryption", "hashing", "key management", "TLS setup", "digital signature", "JWT signing", or when code handles sensitive data that requires cryptographic protection.
---

# Crypto — Cryptography Implementation

## When to Activate
- User invokes `/godmode:crypto`
- User says "encryption", "encrypt this", "decrypt", "cryptography"
- User says "hashing", "hash passwords", "password storage", "bcrypt", "argon2"
- User says "key management", "generate keys", "rotate keys"
- User says "digital signature", "sign this", "verify signature"
- User says "JWT signing", "token security", "JWT algorithm"
- User says "TLS setup", "HTTPS configuration", "certificate"
- When code handles sensitive data (PII, financial, health records)
- When `/godmode:secure` identifies cryptographic failures
- When `/godmode:auth` needs password hashing or token signing
- Before `/godmode:ship` for applications handling encrypted data

## Workflow

### Step 1: Cryptographic Requirements Assessment
Determine what cryptographic operations are needed:

```
CRYPTOGRAPHIC REQUIREMENTS:
┌──────────────────────────────────────────────────────────────┐
│  Data Classification                                         │
├──────────────────────────────────────────────────────────────┤
│  Data at rest requiring encryption:                          │
│  - [ ] User passwords (hashing, not encryption)              │
│  - [ ] PII (names, emails, addresses, SSN, DOB)             │
│  - [ ] Financial data (credit cards, bank accounts)          │
│  - [ ] Health records (PHI under HIPAA)                      │
│  - [ ] API keys and secrets                                  │
│  - [ ] Session tokens                                        │
│  - [ ] Backup data                                           │
│  - [ ] Database fields (column-level encryption)             │
│                                                              │
│  Data in transit requiring encryption:                       │
│  - [ ] Client-server communication (TLS)                     │
│  - [ ] Service-to-service communication (mTLS)               │
│  - [ ] Database connections (TLS)                            │
│  - [ ] Message queue / event bus (TLS)                       │
│  - [ ] File transfers (SFTP, SCP)                            │
│  - [ ] Email (S/MIME, PGP)                                   │
│                                                              │
│  Integrity requirements:                                     │
│  - [ ] Digital signatures on documents/artifacts             │
│  - [ ] Code signing                                          │
│  - [ ] API request signing (HMAC)                            │
│  - [ ] Data integrity verification (checksums)               │
│  - [ ] Non-repudiation (audit trail signatures)              │
│                                                              │
│  Compliance requirements:                                    │
│  - [ ] PCI-DSS (payment card data encryption)                │
│  - [ ] HIPAA (PHI encryption requirements)                   │
│  - [ ] GDPR (encryption as technical safeguard)              │
│  - [ ] SOC2 (encryption controls)                            │
│  - [ ] FIPS 140-2/3 (government-approved modules)            │
│  - [ ] NIST SP 800-57 (key management guidelines)            │
└──────────────────────────────────────────────────────────────┘
```

### Step 2: Algorithm Selection
Choose the correct algorithm for each use case:

```
ALGORITHM SELECTION GUIDE:
┌──────────────────────────────────────────────────────────────┐
│  Use Case              │ Algorithm         │ Notes            │
├──────────────────────────────────────────────────────────────┤
│  PASSWORD HASHING                                            │
│  ─────────────────────────────────────────────────────────── │
│  Primary choice        │ Argon2id          │ Winner of PHC    │
│    Parameters          │ m=65536 (64MB)    │ Memory cost      │
│                        │ t=3               │ Time cost (iter) │
│                        │ p=4               │ Parallelism      │
│  Fallback              │ bcrypt            │ cost factor 12+  │
│  Legacy acceptable     │ scrypt            │ N=2^17, r=8, p=1 │
│  NEVER USE             │ MD5, SHA1, SHA256 │ Not for passwords│
│                        │ PBKDF2 (<100K it) │ Too few iterations│
│                                                              │
│  SYMMETRIC ENCRYPTION                                        │
│  ─────────────────────────────────────────────────────────── │
│  General purpose       │ AES-256-GCM       │ AEAD (auth enc)  │
│  Large data streams    │ AES-256-GCM       │ With chunking    │
│  Disk encryption       │ AES-256-XTS       │ Sector-based     │
│  Modern alternative    │ ChaCha20-Poly1305 │ Software-fast    │
│  NEVER USE             │ ECB mode          │ Pattern-leaking  │
│                        │ DES, 3DES, RC4    │ Broken/weak      │
│                        │ AES-CBC w/o HMAC  │ Padding oracle   │
│                                                              │
│  ASYMMETRIC ENCRYPTION                                       │
│  ─────────────────────────────────────────────────────────── │
│  Key exchange          │ X25519 (ECDH)     │ Curve25519       │
│  Encryption            │ RSA-OAEP (2048+)  │ With SHA-256     │
│  Modern alternative    │ ECIES             │ Hybrid encrypt   │
│  NEVER USE             │ RSA PKCS1v1.5     │ Bleichenbacher   │
│                        │ RSA < 2048 bits   │ Factorable       │
│                                                              │
│  DIGITAL SIGNATURES                                          │
│  ─────────────────────────────────────────────────────────── │
│  Primary choice        │ Ed25519           │ Fast, secure     │
│  JWT signing (multi)   │ RS256 (RSA-PSS)   │ Asymmetric JWT   │
│  JWT signing (single)  │ HS256             │ Symmetric JWT    │
│  Modern JWT            │ ES256 (ECDSA)     │ Compact, fast    │
│  Code signing          │ RSA-PSS 2048+     │ Wide support     │
│  NEVER USE             │ RSA PKCS1v1.5 sig │ Vulnerable       │
│                        │ DSA               │ Deprecated       │
│                                                              │
│  HASHING (non-password)                                      │
│  ─────────────────────────────────────────────────────────── │
│  General integrity     │ SHA-256           │ SHA-2 family     │
│  High security         │ SHA-512           │ Longer output    │
│  Modern alternative    │ BLAKE3            │ Faster, secure   │
│  HMAC (auth hashing)   │ HMAC-SHA-256      │ Keyed hash       │
│  NEVER USE             │ MD5               │ Collisions found │
│                        │ SHA-1             │ Collisions found │
│                                                              │
│  KEY DERIVATION                                              │
│  ─────────────────────────────────────────────────────────── │
│  From password         │ Argon2id          │ Use as KDF       │
│  From shared secret    │ HKDF-SHA-256      │ Extract + expand │
│  Legacy compatibility  │ PBKDF2-SHA-256    │ 600K+ iterations │
│                                                              │
│  RANDOM NUMBER GENERATION                                    │
│  ─────────────────────────────────────────────────────────── │
│  Tokens, keys, IVs     │ CSPRNG            │ OS-provided      │
│    Node.js             │ crypto.randomBytes │                  │
│    Python              │ secrets module     │                  │
│    Go                  │ crypto/rand        │                  │
│    Rust                │ rand::rngs::OsRng  │                  │
│  NEVER USE             │ Math.random()     │ Not cryptographic│
│                        │ random module(Py) │ Not for security │
└──────────────────────────────────────────────────────────────┘
```

### Step 3: Encryption at Rest
Implement data encryption for stored data:

#### Application-Level Encryption
```
ENCRYPTION AT REST — APPLICATION LEVEL:

Strategy: Envelope encryption
  1. Generate a unique Data Encryption Key (DEK) per record/field
  2. Encrypt data with DEK using AES-256-GCM
  3. Encrypt DEK with Key Encryption Key (KEK) from KMS
  4. Store encrypted data + encrypted DEK + IV + auth tag together
  5. To decrypt: fetch KEK from KMS -> decrypt DEK -> decrypt data

Implementation pattern:
```

```javascript
// Node.js encryption example
const crypto = require('crypto');

class FieldEncryptor {
  constructor(keyEncryptionKey) {
    // KEK should come from KMS (AWS KMS, Vault, etc.)
    this.kek = keyEncryptionKey;
  }

  encrypt(plaintext) {
    // Generate unique DEK for this record
    const dek = crypto.randomBytes(32);
    const iv = crypto.randomBytes(12); // 96-bit IV for GCM

    // Encrypt data with DEK
    const cipher = crypto.createCipheriv('aes-256-gcm', dek, iv);
    const encrypted = Buffer.concat([
      cipher.update(plaintext, 'utf8'),
      cipher.final()
    ]);
    const authTag = cipher.getAuthTag();

    // Encrypt DEK with KEK (envelope encryption)
    const dekIv = crypto.randomBytes(12);
    const dekCipher = crypto.createCipheriv('aes-256-gcm', this.kek, dekIv);
    const encryptedDek = Buffer.concat([
      dekCipher.update(dek),
      dekCipher.final()
    ]);
    const dekAuthTag = dekCipher.getAuthTag();

    // Return all components needed for decryption
    return {
      ciphertext: encrypted.toString('base64'),
      iv: iv.toString('base64'),
      authTag: authTag.toString('base64'),
      encryptedDek: encryptedDek.toString('base64'),
      dekIv: dekIv.toString('base64'),
      dekAuthTag: dekAuthTag.toString('base64'),
      algorithm: 'aes-256-gcm',
      version: 1  // For key rotation tracking
    };
  }

  decrypt(encryptedRecord) {
    // Decrypt DEK with KEK
    const dekDecipher = crypto.createDecipheriv(
      'aes-256-gcm',
      this.kek,
      Buffer.from(encryptedRecord.dekIv, 'base64')
    );
    dekDecipher.setAuthTag(Buffer.from(encryptedRecord.dekAuthTag, 'base64'));
    const dek = Buffer.concat([
      dekDecipher.update(Buffer.from(encryptedRecord.encryptedDek, 'base64')),
      dekDecipher.final()
    ]);

    // Decrypt data with DEK
    const decipher = crypto.createDecipheriv(
      'aes-256-gcm',
      dek,
      Buffer.from(encryptedRecord.iv, 'base64')
    );
    decipher.setAuthTag(Buffer.from(encryptedRecord.authTag, 'base64'));
    const plaintext = Buffer.concat([
      decipher.update(Buffer.from(encryptedRecord.ciphertext, 'base64')),
      decipher.final()
    ]);

    return plaintext.toString('utf8');
  }
}
```

```
ENCRYPTION AT REST CHECKLIST:
- [ ] AES-256-GCM or ChaCha20-Poly1305 (authenticated encryption)
- [ ] Unique IV/nonce per encryption operation (NEVER reuse with same key)
- [ ] IV is 96 bits (12 bytes) for GCM
- [ ] Auth tag is 128 bits (16 bytes) for GCM
- [ ] Envelope encryption: data key encrypted by master key
- [ ] Master key stored in KMS (not in application code)
- [ ] Key version tracked with encrypted data (for rotation)
- [ ] Decryption failure handled gracefully (corrupt vs tampered)
- [ ] Encrypted fields searchable via blind index if needed
- [ ] Key material zeroed from memory after use
```

#### Database-Level Encryption
```
DATABASE ENCRYPTION:
┌──────────────────────────────────────────────────────────────┐
│  Level               │ What it Protects       │ Against       │
├──────────────────────────────────────────────────────────────┤
│  TDE (Transparent    │ Data files on disk     │ Physical theft│
│  Data Encryption)    │ Backups, logs          │ Disk access   │
│                                                              │
│  Column encryption   │ Specific sensitive     │ DB admin abuse│
│  (application-side)  │ fields (SSN, CC#)      │ SQL injection │
│                                                              │
│  Connection TLS      │ Data in transit to DB  │ Network sniff │
├──────────────────────────────────────────────────────────────┤
│  RECOMMENDATION:                                             │
│  Use ALL THREE layers:                                       │
│  - TDE for at-rest protection of entire database             │
│  - Column encryption for sensitive fields (defense in depth) │
│  - TLS for all database connections                          │
└──────────────────────────────────────────────────────────────┘

PostgreSQL TDE:
  # pg_hba.conf — enforce TLS
  hostssl all all 0.0.0.0/0 scram-sha-256

  # postgresql.conf
  ssl = on
  ssl_cert_file = 'server.crt'
  ssl_key_file = 'server.key'
  ssl_ca_file = 'ca.crt'
  ssl_min_protocol_version = 'TLSv1.2'

MySQL TDE:
  # Enable tablespace encryption
  ALTER TABLE sensitive_data ENCRYPTION='Y';

  # Require TLS for connections
  ALTER USER 'app_user'@'%' REQUIRE SSL;
```

### Step 4: Encryption in Transit
Configure TLS and secure communications:

#### TLS Configuration Hardening
```
TLS CONFIGURATION:
┌──────────────────────────────────────────────────────────────┐
│  TLS HARDENING GUIDE                                         │
├──────────────────────────────────────────────────────────────┤
│  Protocol versions:                                          │
│    REQUIRED: TLS 1.2 minimum                                 │
│    PREFERRED: TLS 1.3 (better performance, simpler, safer)   │
│    DISABLED: SSLv2, SSLv3, TLS 1.0, TLS 1.1                 │
│                                                              │
│  TLS 1.3 cipher suites (in preference order):                │
│    TLS_AES_256_GCM_SHA384                                    │
│    TLS_CHACHA20_POLY1305_SHA256                              │
│    TLS_AES_128_GCM_SHA256                                    │
│                                                              │
│  TLS 1.2 cipher suites (if 1.2 required):                   │
│    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384                    │
│    TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256                    │
│    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384                  │
│    TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256            │
│    DISABLED: CBC mode ciphers, RC4, DES, 3DES, export ciphers│
│                                                              │
│  Key exchange:                                               │
│    REQUIRED: ECDHE (forward secrecy)                         │
│    Curves: X25519, P-256 (secp256r1), P-384 (secp384r1)     │
│    DISABLED: RSA key exchange (no forward secrecy)           │
│    DISABLED: DHE with < 2048-bit DH params                   │
│                                                              │
│  Certificate:                                                │
│    Key type: ECDSA P-256 (preferred) or RSA 2048+            │
│    Signature: SHA-256 minimum                                │
│    Validity: 90 days (Let's Encrypt) or 398 days max         │
│    OCSP stapling: ENABLED                                    │
│    Certificate transparency: REQUIRED                        │
└──────────────────────────────────────────────────────────────┘
```

```nginx
# Nginx TLS hardening
server {
    listen 443 ssl http2;

    # Certificates
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    # Protocol versions
    ssl_protocols TLSv1.2 TLSv1.3;

    # Cipher suites (TLS 1.2 — TLS 1.3 ciphers are automatic)
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;  # Let client prefer (for TLS 1.3)

    # ECDH curve
    ssl_ecdh_curve X25519:secp256r1:secp384r1;

    # Session resumption
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;  # Disable for forward secrecy

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/nginx/ssl/chain.pem;
    resolver 1.1.1.1 8.8.8.8 valid=300s;

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

```
TLS VERIFICATION CHECKLIST:
- [ ] TLS 1.2 minimum enforced (1.3 preferred)
- [ ] SSLv2/v3 and TLS 1.0/1.1 disabled
- [ ] Only AEAD cipher suites enabled (GCM, ChaCha20-Poly1305)
- [ ] Forward secrecy via ECDHE key exchange
- [ ] HSTS header with long max-age and includeSubDomains
- [ ] OCSP stapling enabled
- [ ] Certificate pinning considered (mobile apps)
- [ ] No mixed content (HTTP resources on HTTPS pages)
- [ ] HTTP automatically redirects to HTTPS (301)
- [ ] Test with: ssllabs.com/ssltest (target A+ grade)
```

### Step 5: Hashing and Password Storage
Implement secure password handling:

```
PASSWORD HASHING — CORRECT IMPLEMENTATION:
```

```javascript
// Node.js — Argon2 (RECOMMENDED)
const argon2 = require('argon2');

async function hashPassword(password) {
  return argon2.hash(password, {
    type: argon2.argon2id,  // Argon2id: hybrid (side-channel + GPU resistant)
    memoryCost: 65536,      // 64 MB memory
    timeCost: 3,            // 3 iterations
    parallelism: 4,         // 4 threads
    saltLength: 16,         // 128-bit salt (auto-generated)
    hashLength: 32          // 256-bit hash output
  });
  // Returns: $argon2id$v=19$m=65536,t=3,p=4$<salt>$<hash>
}

async function verifyPassword(password, hash) {
  return argon2.verify(hash, password);
  // Returns: true/false
  // Constant-time comparison built in
}
```

```javascript
// Node.js — bcrypt (FALLBACK)
const bcrypt = require('bcrypt');

async function hashPassword(password) {
  const saltRounds = 12; // Cost factor: 2^12 = 4096 iterations
  return bcrypt.hash(password, saltRounds);
  // Returns: $2b$12$<salt><hash>
}

async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);
  // Constant-time comparison built in
}
```

```python
# Python — Argon2 (RECOMMENDED)
from argon2 import PasswordHasher

ph = PasswordHasher(
    time_cost=3,        # 3 iterations
    memory_cost=65536,  # 64 MB
    parallelism=4,      # 4 threads
    hash_len=32,        # 256-bit output
    salt_len=16         # 128-bit salt
)

def hash_password(password: str) -> str:
    return ph.hash(password)

def verify_password(password: str, hash: str) -> bool:
    try:
        return ph.verify(hash, password)
    except argon2.exceptions.VerifyMismatchError:
        return False
```

```
PASSWORD STORAGE RULES:
┌──────────────────────────────────────────────────────────────┐
│  Rule                          │ Implementation              │
├──────────────────────────────────────────────────────────────┤
│  Hash, never encrypt           │ Passwords are ONE-WAY       │
│  Use Argon2id or bcrypt        │ Memory-hard algorithms      │
│  Unique salt per password      │ Auto-generated by library   │
│  Constant-time comparison      │ Built into argon2/bcrypt    │
│  No password length limits     │ Allow up to 128+ chars      │
│  Check against breach lists    │ haveibeenpwned.com API      │
│  No composition rules          │ No "must have uppercase"    │
│  Minimum 8 characters          │ NIST SP 800-63B guidance    │
│  Hash migration on login       │ Upgrade old hashes silently │
│  Rate limit authentication     │ 5 attempts / minute         │
│  Log failures, not passwords   │ Never log the password value│
│  Pepper optional (defense in   │ HMAC(password, pepper) then │
│  depth)                        │ hash the result             │
└──────────────────────────────────────────────────────────────┘

HASH UPGRADE (migrating from weak to strong):
  On login:
  1. Verify password against stored hash (old algorithm)
  2. If valid: re-hash with Argon2id, store new hash
  3. Mark record as upgraded
  4. User experience: seamless (no password reset required)

  def login(password, stored_hash):
      if stored_hash.startswith('$argon2id$'):
          return argon2.verify(stored_hash, password)
      elif stored_hash.startswith('$2b$'):
          if bcrypt.verify(password, stored_hash):
              new_hash = argon2.hash(password)
              update_user_hash(new_hash)
              return True
      return False
```

### Step 6: Digital Signatures and JWT Security
Implement signing and verification:

#### JWT Security
```
JWT SECURITY IMPLEMENTATION:
┌──────────────────────────────────────────────────────────────┐
│  JWT ALGORITHM SELECTION                                     │
├──────────────────────────────────────────────────────────────┤
│  Scenario                    │ Algorithm │ Key Type           │
│  ─────────────────────────────────────────────────────────── │
│  Single service (issuer =    │ HS256     │ Shared symmetric   │
│  verifier)                   │           │ key (256+ bits)    │
│                              │           │                    │
│  Multiple services (issuer   │ RS256 or  │ Private key signs  │
│  != verifier)                │ ES256     │ Public key verifies│
│                              │           │                    │
│  High-performance / modern   │ EdDSA     │ Ed25519 keys       │
│                              │           │                    │
│  NEVER USE                   │ "none"    │ No signature       │
│  NEVER USE                   │ HS256 with│ Algorithm confusion│
│                              │ RSA pubkey│ attack             │
└──────────────────────────────────────────────────────────────┘
```

```javascript
// Node.js JWT implementation (jose library — RECOMMENDED)
const jose = require('jose');

// Generate RSA key pair for RS256
const { publicKey, privateKey } = await jose.generateKeyPair('RS256', {
  modulusLength: 2048
});

// Sign a JWT
async function signJwt(payload) {
  const jwt = await new jose.SignJWT(payload)
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuedAt()
    .setIssuer('https://your-app.com')
    .setAudience('https://your-api.com')
    .setExpirationTime('15m')        // Short-lived access token
    .setJti(crypto.randomUUID())     // Unique token ID (replay prevention)
    .sign(privateKey);
  return jwt;
}

// Verify a JWT
async function verifyJwt(token) {
  try {
    const { payload } = await jose.jwtVerify(token, publicKey, {
      issuer: 'https://your-app.com',       // MUST verify issuer
      audience: 'https://your-api.com',      // MUST verify audience
      algorithms: ['RS256'],                  // MUST restrict algorithms
      clockTolerance: 30,                     // 30-second clock skew tolerance
    });
    return payload;
  } catch (error) {
    if (error.code === 'ERR_JWT_EXPIRED') {
      throw new Error('Token expired');
    }
    throw new Error('Invalid token');
  }
}
```

```
JWT SECURITY CHECKLIST:
- [ ] Algorithm explicitly set and verified (no algorithm confusion)
- [ ] "none" algorithm rejected
- [ ] Issuer (iss) claim verified on every request
- [ ] Audience (aud) claim verified on every request
- [ ] Expiration (exp) claim enforced with clock tolerance
- [ ] JTI claim for token uniqueness (optional, for revocation)
- [ ] No sensitive data in payload (JWTs are readable, not secret)
- [ ] Signing key stored securely (KMS, not environment variable)
- [ ] Key rotation implemented (JWKS endpoint for asymmetric)
- [ ] Token size < 4KB (cookie limit consideration)
- [ ] HMAC keys are 256+ bits (not short strings like "secret")
- [ ] Library handles signature verification (never parse without verify)
```

#### Digital Signatures
```
DIGITAL SIGNATURE IMPLEMENTATION:
```

```javascript
// Ed25519 digital signatures (Node.js)
const crypto = require('crypto');

// Generate key pair
const { publicKey, privateKey } = crypto.generateKeyPairSync('ed25519');

// Sign data
function sign(data) {
  const signature = crypto.sign(null, Buffer.from(data), privateKey);
  return signature.toString('base64');
}

// Verify signature
function verify(data, signature) {
  return crypto.verify(
    null,
    Buffer.from(data),
    publicKey,
    Buffer.from(signature, 'base64')
  );
}
```

```
SIGNATURE USE CASES:
┌──────────────────────────────────────────────────────────────┐
│  Use Case              │ Algorithm  │ Implementation          │
├──────────────────────────────────────────────────────────────┤
│  API request signing   │ HMAC-SHA256│ Sign request body +     │
│                        │            │ timestamp + nonce       │
│  Document signing      │ Ed25519 or │ Sign document hash,     │
│                        │ RSA-PSS    │ store signature separate│
│  Code/artifact signing │ RSA-PSS    │ cosign, sigstore, GPG   │
│  Container signing     │ cosign     │ Sign image digest       │
│  Webhook verification  │ HMAC-SHA256│ Verify sender identity  │
│  Git commit signing    │ GPG/SSH    │ Prove author identity   │
└──────────────────────────────────────────────────────────────┘

API REQUEST SIGNING PATTERN:
  1. Collect: HTTP method + path + timestamp + body hash + nonce
  2. Canonical string: METHOD\nPATH\nTIMESTAMP\nBODY_HASH\nNONCE
  3. Signature: HMAC-SHA256(canonical_string, shared_secret)
  4. Header: Authorization: HMAC-SHA256 KeyId=<id>, Signature=<sig>,
             Timestamp=<ts>, Nonce=<nonce>
  5. Verify: Recreate canonical string, verify HMAC, check timestamp
             freshness (within 5 minutes), check nonce uniqueness
```

### Step 7: Key Management
Implement proper key lifecycle management:

```
KEY MANAGEMENT LIFECYCLE:
┌──────────────────────────────────────────────────────────────┐
│                     KEY LIFECYCLE                             │
├──────────────────────────────────────────────────────────────┤
│  GENERATION                                                  │
│  ├─ Use CSPRNG (OS-provided randomness)                      │
│  ├─ Key length: 256 bits minimum for symmetric               │
│  ├─ RSA: 2048 bits minimum (3072 recommended for longevity)  │
│  ├─ ECDSA: P-256 or P-384                                    │
│  ├─ Generate in secure environment (KMS preferred)           │
│  └─ Never derive keys from passwords without proper KDF      │
│                                                              │
│  STORAGE                                                     │
│  ├─ Production: KMS (AWS KMS, GCP Cloud KMS, Azure Key Vault)│
│  ├─ Alternative: HashiCorp Vault                             │
│  ├─ Development: Environment variables (not source code)     │
│  ├─ NEVER: Hardcoded in source, config files, or Docker images│
│  ├─ Encryption: Keys encrypted at rest (key wrapping)        │
│  └─ Access: Minimum necessary services, audited access       │
│                                                              │
│  DISTRIBUTION                                                │
│  ├─ Symmetric keys: Via KMS API or encrypted envelope        │
│  ├─ Asymmetric public keys: JWKS endpoint, certificate       │
│  ├─ Asymmetric private keys: NEVER distributed (stay in KMS) │
│  └─ Rotation: New key distributed before old key expires     │
│                                                              │
│  ROTATION                                                    │
│  ├─ Schedule: Based on key type and risk                     │
│  │  ├─ Encryption keys: 365 days                             │
│  │  ├─ Signing keys: 90-365 days                             │
│  │  ├─ JWT keys: 90 days                                     │
│  │  ├─ TLS certificates: 90 days (Let's Encrypt auto-renew)  │
│  │  └─ After compromise: IMMEDIATELY                         │
│  ├─ Process: Generate new -> deploy new -> grace period ->   │
│  │  retire old                                               │
│  ├─ Versioning: Track key version with encrypted data        │
│  └─ Backward compatibility: Old keys decrypt, new key encrypts│
│                                                              │
│  REVOCATION                                                  │
│  ├─ Compromised: Revoke immediately, re-encrypt all data     │
│  ├─ Expired: Retain for decryption only (no new encryption)  │
│  ├─ Certificates: CRL or OCSP responder                      │
│  └─ JWTs: Remove from JWKS endpoint + blacklist active tokens│
│                                                              │
│  DESTRUCTION                                                 │
│  ├─ After all data re-encrypted with new key                 │
│  ├─ Crypto-shred: Delete key to make encrypted data unusable │
│  ├─ Secure deletion: Overwrite key material in memory/storage│
│  └─ Audit: Log key destruction event                         │
└──────────────────────────────────────────────────────────────┘
```

```
KMS INTEGRATION PATTERNS:
┌──────────────────────────────────────────────────────────────┐
│  Provider         │ Encrypt/Decrypt    │ Key Generation       │
├──────────────────────────────────────────────────────────────┤
│  AWS KMS          │ kms.encrypt()      │ kms.generateDataKey()│
│                   │ kms.decrypt()      │ AES-256 via KMS      │
│                                                              │
│  GCP Cloud KMS    │ client.encrypt()   │ client.encrypt()     │
│                   │ client.decrypt()   │ with key ring        │
│                                                              │
│  Azure Key Vault  │ client.encrypt()   │ client.createKey()   │
│                   │ client.decrypt()   │ RSA or EC keys       │
│                                                              │
│  HashiCorp Vault  │ vault kv put       │ vault write transit/ │
│                   │ vault kv get       │ encrypt              │
│                                                              │
│  PATTERN: Envelope encryption via KMS                        │
│  1. Call KMS generateDataKey() -> plaintext DEK + encrypted  │
│     DEK                                                      │
│  2. Encrypt data with plaintext DEK (AES-256-GCM)           │
│  3. Store encrypted data + encrypted DEK                     │
│  4. Discard plaintext DEK from memory                        │
│  5. To decrypt: Call KMS decrypt(encrypted DEK) -> plaintext │
│     DEK -> decrypt data                                      │
└──────────────────────────────────────────────────────────────┘
```

### Step 8: Cryptographic Implementation Report

```
┌────────────────────────────────────────────────────────────────┐
│  CRYPTOGRAPHIC IMPLEMENTATION REPORT                           │
│  Target: <application/system name>                             │
├────────────────────────────────────────────────────────────────┤
│  Encryption at rest:                                           │
│    Algorithm: <AES-256-GCM / ChaCha20-Poly1305>                │
│    Key management: <KMS / Vault / env var>                     │
│    Envelope encryption: <YES / NO>                             │
│    Fields encrypted: <list>                                    │
│                                                                │
│  Encryption in transit:                                        │
│    TLS version: <1.2 / 1.3>                                   │
│    Cipher suites: <list>                                       │
│    Forward secrecy: <YES / NO>                                 │
│    HSTS: <YES / NO, max-age>                                   │
│    SSL Labs grade: <A+ / A / B / etc.>                         │
│                                                                │
│  Password hashing:                                             │
│    Algorithm: <Argon2id / bcrypt>                               │
│    Parameters: <memory, time, parallelism / cost factor>       │
│    Salt: <auto-generated, per-password>                        │
│    Migration: <old hashes upgraded on login>                   │
│                                                                │
│  Digital signatures:                                           │
│    JWT: <RS256 / ES256 / HS256 / EdDSA>                        │
│    API signing: <HMAC-SHA256 / Ed25519>                        │
│    Code signing: <GPG / cosign / sigstore>                     │
│                                                                │
│  Key management:                                               │
│    Provider: <AWS KMS / GCP KMS / Vault / Azure KV>            │
│    Rotation schedule: <defined / not defined>                  │
│    Backup: <key escrow / recovery procedure>                   │
│                                                                │
│  Verdict: <SECURE / NEEDS IMPROVEMENT / INSECURE>              │
├────────────────────────────────────────────────────────────────┤
│  ISSUES:                                                       │
│  1. <issue if any>                                             │
│  2. <issue if any>                                             │
│                                                                │
│  RECOMMENDATIONS:                                              │
│  1. <recommendation>                                           │
│  2. <recommendation>                                           │
└────────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
```
1. Save implementation as `src/crypto/` or appropriate module
2. Save TLS config to server configuration
3. Commit: "crypto: <feature> — <algorithm> for <use case>"
4. If INSECURE: "Cryptographic issues found. Address <specific issues> before deploying."
5. If SECURE: "Cryptography correctly implemented. Run `/godmode:secure` for full security audit or `/godmode:ship` to deploy."
6. If key management needed: "Run `/godmode:secrets` to set up key storage and rotation."
```

## Key Behaviors

1. **Use established libraries.** Never implement your own encryption, hashing, or signing. Use audited, well-maintained libraries (libsodium, OpenSSL, jose, argon2, bcrypt).
2. **Algorithm selection is not negotiable.** AES-256-GCM or ChaCha20-Poly1305 for encryption. Argon2id or bcrypt for passwords. RS256/ES256 for JWT. These are the right answers. Other choices require explicit justification.
3. **Never reuse nonces/IVs.** A single nonce reuse with AES-GCM completely breaks the authentication and can leak the key. Use random 96-bit IVs. If encrypting more than 2^32 messages with the same key, use a different scheme.
4. **Key management is the hard part.** Encryption is easy. Storing, distributing, rotating, and revoking keys is where most failures occur. Use KMS or Vault, not environment variables in production.
5. **Envelope encryption for data.** Never encrypt data directly with a master key. Generate a data key, encrypt data with it, encrypt the data key with the master key. This enables key rotation without re-encrypting all data.
6. **Forward secrecy is mandatory.** TLS configurations must use ECDHE key exchange. Session tickets should be disabled or rotated frequently. A compromised server key must not decrypt past traffic.
7. **Hash passwords, never encrypt them.** Encryption is reversible. Hashing is not. There is no legitimate reason to recover a user's password. If you need to compare, verify against the hash.
8. **Show the complete pattern.** Encryption without key management is incomplete. Hashing without migration is incomplete. TLS without HSTS is incomplete. Always show the full picture.

## Example Usage

### Implementing password hashing
```
User: /godmode:crypto Set up password hashing for our user registration

Crypto: Analyzing requirements...

RECOMMENDATION: Argon2id
  Parameters: m=65536 (64MB), t=3, p=4
  Library: argon2 (npm) — binding to reference C implementation

Implementation:
  src/auth/password.ts — hash() and verify() functions
  Migration: bcrypt detection for existing hashes, upgrade on login
  Tests: Hash generation, verification, timing safety, parameter validation

Password policy:
  Minimum: 8 characters
  Maximum: 128 characters (prevent DoS via long passwords)
  Breach check: haveibeenpwned.com k-Anonymity API
  No composition rules (NIST SP 800-63B)
```

### Configuring TLS
```
User: /godmode:crypto Harden our Nginx TLS configuration

Crypto: Analyzing current TLS config...

CURRENT: TLS 1.0-1.2, weak ciphers, no HSTS
TARGET: TLS 1.2-1.3, strong ciphers only, HSTS with preload

Changes:
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers <AEAD-only suite>;
  ssl_prefer_server_ciphers off;
  HSTS: max-age=63072000; includeSubDomains; preload
  OCSP stapling: enabled
  Session tickets: disabled (forward secrecy)

Expected SSL Labs grade: A+
```

### Encrypting sensitive database fields
```
User: /godmode:crypto Encrypt SSN and credit card fields in our database

Crypto: Implementing field-level encryption...

Strategy: Envelope encryption with AWS KMS
  KEK: AWS KMS key (arn:aws:kms:region:account:key/key-id)
  DEK: Unique per-record, AES-256-GCM

Implementation:
  src/crypto/field-encryptor.ts — encrypt/decrypt with envelope pattern
  Database migration: Add encrypted columns, migrate existing data
  Search: Blind index (HMAC of original value) for exact-match queries

Key rotation: New KEK version, re-wrap DEKs (no data re-encryption)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full cryptographic assessment and implementation |
| `--passwords` | Password hashing setup (Argon2id/bcrypt) |
| `--encrypt` | Encryption at rest implementation |
| `--tls` | TLS configuration hardening |
| `--jwt` | JWT signing and verification setup |
| `--signatures` | Digital signature implementation |
| `--keys` | Key management and rotation setup |
| `--audit` | Audit existing cryptographic implementations |
| `--migrate` | Migrate from weak to strong cryptography |
| `--test` | Generate tests for cryptographic operations |

## HARD RULES

1. **NEVER implement your own cryptographic primitives.** Use audited libraries only.
2. **NEVER reuse IVs/nonces with the same key.** A single reuse with AES-GCM breaks authentication.
3. **NEVER store encryption keys alongside encrypted data.** Keys and data in different systems.
4. **NEVER use MD5, SHA-1, DES, 3DES, RC4, or ECB mode** for any security purpose.
5. **NEVER encrypt passwords** — hash them with Argon2id or bcrypt. Encryption is reversible.
6. **NEVER use `Math.random()` or non-cryptographic RNGs** for keys, tokens, or IVs.
7. **ALWAYS use authenticated encryption** (GCM, ChaCha20-Poly1305). Never AES-CBC without HMAC.
8. **ALWAYS track key version** with encrypted data for rotation support.
9. **git commit BEFORE verify** — commit crypto implementation, then run verification tests.
10. **TSV logging** — log every cryptographic implementation:
    ```
    timestamp	use_case	algorithm	key_management	key_rotation	verdict
    ```

## Auto-Detection

On activation, automatically detect cryptographic context:

```
AUTO-DETECT:
1. Existing crypto usage:
   grep -r "crypto\|encrypt\|decrypt\|hash\|bcrypt\|argon2\|jwt\|jose" src/ --include="*.ts" --include="*.py" --include="*.go" -l 2>/dev/null

2. Password handling:
   grep -ri "password\|passwd\|bcrypt\|argon2\|scrypt\|pbkdf2" src/ -l 2>/dev/null
   # Detect current hashing algorithm and parameters

3. JWT usage:
   grep -ri "jsonwebtoken\|jose\|jwt\|bearer" src/ -l 2>/dev/null
   # Detect algorithm, key type, expiration settings

4. TLS configuration:
   ls nginx.conf /etc/nginx/conf.d/*.conf 2>/dev/null
   grep -ri "ssl_protocols\|ssl_ciphers\|tls" nginx.conf 2>/dev/null

5. Key management:
   grep -ri "kms\|vault\|secret.manager\|key.vault" src/ 2>/dev/null
   # Detect if KMS is already integrated

6. Weak crypto indicators:
   grep -ri "md5\|sha1\|des\|ecb\|Math.random\|PKCS1v1.5" src/ -l 2>/dev/null
   # Flag immediately for remediation

-> Auto-identify what needs implementation vs what needs upgrading.
-> Auto-detect weak crypto for immediate remediation.
-> Only ask user about compliance requirements if not detectable.
```

## Anti-Patterns

- **Do NOT implement your own cryptographic primitives.** Do not write your own AES, SHA, or ECDSA. Use established libraries. "Rolling your own crypto" is the most common source of cryptographic vulnerabilities.
- **Do NOT use ECB mode.** ECB mode encrypts identical plaintext blocks to identical ciphertext blocks, leaking patterns. Use GCM or CTR with authentication.
- **Do NOT use MD5 or SHA-1 for anything security-related.** Both have known collision attacks. Use SHA-256 minimum for hashing. Use Argon2id for passwords.
- **Do NOT reuse IVs/nonces.** A single nonce reuse with AES-GCM breaks authentication and can leak the key. Use random 96-bit IVs for GCM.
- **Do NOT use Math.random() or similar non-cryptographic RNGs for security.** Use crypto.randomBytes (Node.js), secrets module (Python), crypto/rand (Go).
- **Do NOT store encryption keys alongside encrypted data.** The key and the data must be in different storage systems. An attacker who gets the database should not also get the keys.
- **Do NOT encrypt passwords.** Encryption is reversible. Use one-way hashing (Argon2id, bcrypt). There is no legitimate reason to decrypt a user's password.
- **Do NOT use short HMAC keys.** HS256 JWT signing requires a 256-bit (32-byte) key minimum. "secret" as an HMAC key is not a key, it is a vulnerability.
- **Do NOT skip authenticated encryption.** Encryption without authentication (AES-CBC without HMAC) is vulnerable to padding oracle attacks. Always use AEAD (GCM, ChaCha20-Poly1305).
- **Do NOT hardcode cryptographic parameters.** Algorithm, key length, and iteration counts should be configurable for future upgrades without code changes.
