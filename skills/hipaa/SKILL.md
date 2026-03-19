---
name: hipaa
description: |
  HIPAA deep compliance skill. Activates when user needs comprehensive Health Insurance Portability and Accountability Act compliance — PHI identification and classification, encryption requirements (at rest and in transit), access control and audit logging, BAA (Business Associate Agreement) technical requirements, breach notification procedures, minimum necessary standard enforcement, and de-identification methods. Goes far deeper than the general comply skill by producing implementable code, database schemas, access control configurations, encryption strategies, and operational procedures for every HIPAA requirement. Triggers on: /godmode:hipaa, "HIPAA compliance", "PHI", "protected health information", "BAA", "healthcare data", "ePHI", "HITECH", or when building features that handle health information in the US healthcare ecosystem.
---

# HIPAA — Deep HIPAA Compliance

## When to Activate
- User invokes `/godmode:hipaa`
- User says "HIPAA compliance", "PHI", "protected health information", "healthcare data"
- User says "BAA", "business associate agreement", "ePHI", "HITECH"
- User says "minimum necessary", "de-identification", "healthcare audit"
- Building or modifying features that create, receive, maintain, or transmit protected health information
- Integrating with healthcare systems (EHR, HL7, FHIR, claims processing)
- Preparing for HIPAA audits or OCR (Office for Civil Rights) investigations
- After `/godmode:comply --hipaa` identifies gaps that need deep implementation
- When third parties need BAA coverage for data processing

## Workflow

### Step 1: PHI Identification and Classification
Identify all Protected Health Information in the system:

```
PHI IDENTIFICATION — 18 HIPAA IDENTIFIERS:
┌────────────────────────────────────────────────────────────────────┐
│  IDENTIFIER                │ PRESENT │ LOCATION          │ STATUS │
├────────────────────────────────────────────────────────────────────┤
│  1.  Names                 │ YES/NO  │ <table.column>    │        │
│  2.  Geographic data       │ YES/NO  │ <table.column>    │        │
│      (smaller than state)  │         │                   │        │
│  3.  Dates (except year)   │ YES/NO  │ <table.column>    │        │
│      (birth, admission,    │         │                   │        │
│       discharge, death)    │         │                   │        │
│  4.  Phone numbers         │ YES/NO  │ <table.column>    │        │
│  5.  Fax numbers           │ YES/NO  │ <table.column>    │        │
│  6.  Email addresses       │ YES/NO  │ <table.column>    │        │
│  7.  SSN                   │ YES/NO  │ <table.column>    │        │
│  8.  Medical record #      │ YES/NO  │ <table.column>    │        │
│  9.  Health plan benef. #  │ YES/NO  │ <table.column>    │        │
│  10. Account numbers       │ YES/NO  │ <table.column>    │        │
│  11. Certificate/license # │ YES/NO  │ <table.column>    │        │
│  12. Vehicle IDs/serials   │ YES/NO  │ <table.column>    │        │
│  13. Device IDs/serials    │ YES/NO  │ <table.column>    │        │
│  14. Web URLs              │ YES/NO  │ <table.column>    │        │
│  15. IP addresses          │ YES/NO  │ <table.column>    │        │
│  16. Biometric IDs         │ YES/NO  │ <table.column>    │        │
│  17. Full-face photos      │ YES/NO  │ <table.column>    │        │
│  18. Any other unique #    │ YES/NO  │ <table.column>    │        │
└────────────────────────────────────────────────────────────────────┘

PHI DATA CLASSIFICATION:
┌────────────────────────────────────────────────────────────────────┐
│  Category              │ Examples            │ Risk Level          │
├────────────────────────────────────────────────────────────────────┤
│  Clinical data         │ Diagnoses, labs,    │ HIGH                │
│                        │ medications, notes  │                     │
│  Demographic data      │ Name, DOB, address, │ MEDIUM-HIGH         │
│                        │ phone, email, SSN   │                     │
│  Financial/admin data  │ Insurance, billing, │ MEDIUM              │
│                        │ claims, account #s  │                     │
│  Operational data      │ Appointment dates,  │ MEDIUM              │
│                        │ provider IDs        │                     │
│  Research data         │ De-identified sets, │ LOW (if properly    │
│                        │ aggregate stats     │ de-identified)      │
└────────────────────────────────────────────────────────────────────┘

ePHI FLOW MAP:
  Collection: <where ePHI enters the system>
  Storage: <databases, file systems, caches>
  Processing: <services that read/write ePHI>
  Transmission: <APIs, integrations, exports>
  Disposal: <how ePHI is destroyed>
```

#### PHI Registry Database Schema
```sql
-- PHI field registry for compliance tracking
CREATE TABLE phi_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  system_name VARCHAR(255) NOT NULL,       -- application or service name
  table_name VARCHAR(255) NOT NULL,
  column_name VARCHAR(255) NOT NULL,
  phi_identifier_type INTEGER NOT NULL,    -- 1-18 per HIPAA identifiers
  phi_category VARCHAR(50) NOT NULL,       -- clinical, demographic, financial, operational
  risk_level VARCHAR(20) NOT NULL,         -- high, medium, low
  encrypted_at_rest BOOLEAN DEFAULT FALSE,
  encrypted_in_transit BOOLEAN DEFAULT FALSE,
  access_control_level VARCHAR(50),        -- role-based, attribute-based, break-glass
  minimum_necessary_enforced BOOLEAN DEFAULT FALSE,
  de_identification_method VARCHAR(50),    -- safe_harbor, expert_determination, n/a
  retention_period VARCHAR(100),
  disposal_method VARCHAR(50),             -- cryptographic_erasure, overwrite, physical_destruction
  last_risk_assessment DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_phi_registry_field
  ON phi_registry(system_name, table_name, column_name);
```

### Step 2: Encryption Requirements
Implement encryption for ePHI at rest and in transit:

```
ENCRYPTION ASSESSMENT:
┌────────────────────────────────────────────────────────────────────┐
│  AT-REST ENCRYPTION (§ 164.312(a)(2)(iv)):                         │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Storage Location     │ Encrypted │ Method     │ Key Mgmt    │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Primary database     │ YES/NO    │ AES-256    │ <method>    │  │
│  │  Database backups     │ YES/NO    │ AES-256    │ <method>    │  │
│  │  File storage (S3)    │ YES/NO    │ SSE-KMS    │ <method>    │  │
│  │  Local file system    │ YES/NO    │ LUKS/FDE   │ <method>    │  │
│  │  Redis/cache          │ YES/NO    │ TLS + enc  │ <method>    │  │
│  │  Search index         │ YES/NO    │ <method>   │ <method>    │  │
│  │  Log storage          │ YES/NO    │ <method>   │ <method>    │  │
│  │  Message queues       │ YES/NO    │ <method>   │ <method>    │  │
│  │  Temporary files      │ YES/NO    │ <method>   │ <method>    │  │
│  │  Mobile device storage│ YES/NO    │ <method>   │ <method>    │  │
│  │  Laptop/workstation   │ YES/NO    │ FDE        │ <method>    │  │
│  │  Removable media      │ YES/NO    │ <method>   │ <method>    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  IN-TRANSIT ENCRYPTION (§ 164.312(e)(1)):                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Channel              │ Encrypted │ Protocol   │ Min Version │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Client to server     │ YES/NO    │ TLS        │ 1.2+        │  │
│  │  Server to database   │ YES/NO    │ TLS        │ 1.2+        │  │
│  │  Server to cache      │ YES/NO    │ TLS        │ 1.2+        │  │
│  │  Service to service   │ YES/NO    │ mTLS       │ 1.2+        │  │
│  │  API integrations     │ YES/NO    │ TLS        │ 1.2+        │  │
│  │  Email (with ePHI)    │ YES/NO    │ S/MIME/TLS │ <version>   │  │
│  │  File transfers       │ YES/NO    │ SFTP/SCP   │ <version>   │  │
│  │  VPN connections      │ YES/NO    │ IPsec/WG   │ <version>   │  │
│  │  Backup transfers     │ YES/NO    │ TLS        │ 1.2+        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  KEY MANAGEMENT:                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Requirement              │ Status    │ Implementation       │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Key generation (CSPRNG)  │ YES/NO    │ <method>             │  │
│  │  Key storage (HSM/KMS)    │ YES/NO    │ <service>            │  │
│  │  Key rotation schedule    │ YES/NO    │ <frequency>          │  │
│  │  Key access logging       │ YES/NO    │ <audit system>       │  │
│  │  Key backup/recovery      │ YES/NO    │ <procedure>          │  │
│  │  Key destruction          │ YES/NO    │ <method>             │  │
│  │  Separation of duties     │ YES/NO    │ <implementation>     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  APPROVED ALGORITHMS:                                              │
│    Symmetric: AES-256 (GCM mode preferred)                         │
│    Asymmetric: RSA-2048+ or ECDSA P-256+                           │
│    Hashing: SHA-256+ (NEVER MD5 or SHA-1 for security)             │
│    TLS: 1.2 minimum, 1.3 preferred                                │
│    Key derivation: PBKDF2, scrypt, or Argon2                      │
│    DO NOT USE: DES, 3DES, RC4, MD5, SHA-1, SSLv3, TLS 1.0/1.1   │
└────────────────────────────────────────────────────────────────────┘
```

#### Application-Level Encryption Implementation
```
APPLICATION ENCRYPTION PATTERNS:

Field-level encryption for ePHI columns:
  Encrypt: patient_name, ssn, diagnosis, lab_results
  Using: AES-256-GCM with unique IV per record
  Key source: AWS KMS / HashiCorp Vault / Azure Key Vault
  Key rotation: Automatic, transparent re-encryption on rotation

Database transparent encryption (TDE):
  PostgreSQL: pgcrypto extension or TDE (Enterprise)
  MySQL: InnoDB tablespace encryption
  MongoDB: Encrypted Storage Engine (WiredTiger)
  Cloud: RDS encryption, Cloud SQL encryption

Envelope encryption pattern:
  Data Encryption Key (DEK): unique per record or batch
  Key Encryption Key (KEK): stored in KMS, rotated quarterly
  Process: Generate DEK → encrypt data with DEK → encrypt DEK with KEK
           Store encrypted DEK alongside encrypted data
```

### Step 3: Access Control and Audit Logging
Implement §164.312 Technical Safeguards:

```
ACCESS CONTROL (§ 164.312(a)(1)):
┌────────────────────────────────────────────────────────────────────┐
│  UNIQUE USER IDENTIFICATION (§ 164.312(a)(2)(i)):                  │
│  - [ ] Every user has a unique identifier (no shared accounts)     │
│  - [ ] Service accounts have unique IDs per service                │
│  - [ ] System/admin accounts individually assigned                 │
│  - [ ] No generic logins (admin, root, system, test)               │
│                                                                    │
│  EMERGENCY ACCESS (§ 164.312(a)(2)(ii)):                           │
│  - [ ] Break-glass procedure documented and tested                 │
│  - [ ] Emergency access creates elevated audit trail               │
│  - [ ] Emergency access auto-reverts after time limit              │
│  - [ ] Emergency access requires post-event review                 │
│  - [ ] Break-glass accounts are monitored and alerted              │
│                                                                    │
│  AUTOMATIC LOGOFF (§ 164.312(a)(2)(iii)):                          │
│  - [ ] Session timeout after <N> minutes of inactivity             │
│  - [ ] Timeout period appropriate to risk level                    │
│  - [ ] User warned before session termination                      │
│  - [ ] Session data cleared on timeout                             │
│                                                                    │
│  ROLE-BASED ACCESS CONTROL:                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Role               │ PHI Access          │ Scope            │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Physician           │ Full clinical       │ Own patients     │  │
│  │  Nurse               │ Clinical (care)     │ Assigned unit    │  │
│  │  Lab technician      │ Lab results only    │ Ordered tests    │  │
│  │  Billing staff       │ Demographic + codes │ Billing records  │  │
│  │  Receptionist        │ Scheduling only     │ Appointments     │  │
│  │  IT administrator    │ System (no PHI)     │ Infrastructure   │  │
│  │  Compliance officer  │ Audit logs only     │ All (read-only)  │  │
│  │  Researcher          │ De-identified only  │ Approved dataset │  │
│  │  Patient (portal)    │ Own data only       │ Self             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  MINIMUM NECESSARY STANDARD (§ 164.502(b)):                        │
│  For each role and function:                                       │
│    - [ ] Define minimum PHI fields needed for the job function     │
│    - [ ] Restrict database queries to necessary columns only       │
│    - [ ] API responses filtered to role-appropriate fields         │
│    - [ ] UI displays only minimum necessary PHI                    │
│    - [ ] Reports include only required PHI elements                │
│    - [ ] Routine access: define minimum necessary by role          │
│    - [ ] Non-routine access: individual review per request         │
└────────────────────────────────────────────────────────────────────┘
```

#### Access Control Database Schema
```sql
-- HIPAA-compliant access control
CREATE TABLE hipaa_access_policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name VARCHAR(100) NOT NULL,
  resource_type VARCHAR(100) NOT NULL,    -- patient_record, lab_result, billing, schedule
  allowed_fields TEXT[] NOT NULL,          -- minimum necessary fields for this role
  allowed_actions TEXT[] NOT NULL,         -- read, write, delete, export
  scope_type VARCHAR(50) NOT NULL,         -- own_patients, assigned_unit, all, self
  scope_filter TEXT,                       -- SQL-like filter expression
  requires_break_glass BOOLEAN DEFAULT FALSE,
  break_glass_reason_required BOOLEAN DEFAULT FALSE,
  max_records_per_query INTEGER,           -- prevent bulk extraction
  session_timeout_minutes INTEGER DEFAULT 15,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Break-glass access log
CREATE TABLE break_glass_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role_name VARCHAR(100) NOT NULL,
  resource_type VARCHAR(100) NOT NULL,
  resource_id VARCHAR(255) NOT NULL,
  reason TEXT NOT NULL,
  activated_at TIMESTAMPTZ DEFAULT NOW(),
  deactivated_at TIMESTAMPTZ,
  auto_deactivate_at TIMESTAMPTZ NOT NULL,  -- max duration
  reviewed_by VARCHAR(255),
  reviewed_at TIMESTAMPTZ,
  review_outcome VARCHAR(50),               -- approved, flagged, violation
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Audit Logging (§ 164.312(b))
```
AUDIT LOG REQUIREMENTS:
┌────────────────────────────────────────────────────────────────────┐
│  EVENTS TO LOG (all ePHI access):                                  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Event                    │ Fields to Capture               │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  User login/logout        │ user_id, timestamp, IP,         │  │
│  │                           │ method, success/failure          │  │
│  │  PHI accessed (read)      │ user_id, patient_id, resource,  │  │
│  │                           │ fields viewed, timestamp, IP     │  │
│  │  PHI created              │ user_id, patient_id, resource,  │  │
│  │                           │ fields, timestamp                │  │
│  │  PHI modified             │ user_id, patient_id, resource,  │  │
│  │                           │ field, old (hash), new (hash)    │  │
│  │  PHI deleted              │ user_id, patient_id, resource,  │  │
│  │                           │ reason, timestamp                │  │
│  │  PHI exported/printed     │ user_id, scope, format,         │  │
│  │                           │ destination, record_count        │  │
│  │  PHI transmitted          │ user_id, recipient, method,     │  │
│  │                           │ record_count, timestamp          │  │
│  │  Access denied            │ user_id, resource, reason,      │  │
│  │                           │ timestamp                        │  │
│  │  Break-glass activated    │ user_id, reason, resource,      │  │
│  │                           │ timestamp, auto_expiry           │  │
│  │  Permission changes       │ admin_id, target_user, role,    │  │
│  │                           │ old_perms, new_perms             │  │
│  │  System config changes    │ admin_id, setting, old, new     │  │
│  │  Encryption key events    │ event_type, key_id, operator    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  AUDIT LOG PROPERTIES:                                             │
│  - [ ] Immutable (append-only, no modification or deletion)        │
│  - [ ] Tamper-evident (cryptographic chaining or WORM storage)     │
│  - [ ] Retained for minimum 6 years (HIPAA requirement)            │
│  - [ ] Encrypted at rest and in transit                            │
│  - [ ] Separate storage from application data                      │
│  - [ ] Access restricted to compliance/security team only          │
│  - [ ] Timestamps in UTC, synchronized via NTP                     │
│  - [ ] No ePHI in log messages (use hashes or references)          │
│  - [ ] Correlation IDs for request tracing                         │
│  - [ ] Regular review process (at least monthly)                   │
│                                                                    │
│  AUDIT LOG REVIEW PROCEDURES:                                      │
│  - Daily: Automated alerts for anomalous access patterns           │
│  - Weekly: Review break-glass access events                        │
│  - Monthly: Sample audit of PHI access against job functions       │
│  - Quarterly: Full audit log integrity verification                │
│  - Annually: Complete audit log policy review                      │
└────────────────────────────────────────────────────────────────────┘
```

#### Audit Log Database Schema
```sql
-- HIPAA audit log (immutable, append-only)
CREATE TABLE hipaa_audit_log (
  id BIGSERIAL PRIMARY KEY,
  event_type VARCHAR(50) NOT NULL,
    -- phi_access, phi_create, phi_modify, phi_delete, phi_export,
    -- phi_transmit, login, logout, access_denied, break_glass,
    -- permission_change, config_change, key_event
  user_id UUID NOT NULL,
  user_role VARCHAR(100),
  patient_id UUID,                        -- NULL for non-patient events
  resource_type VARCHAR(100),
  resource_id VARCHAR(255),
  action VARCHAR(50) NOT NULL,            -- read, write, delete, export, transmit
  fields_accessed TEXT[],                 -- which PHI fields were touched
  outcome VARCHAR(20) NOT NULL,           -- success, failure, denied
  reason TEXT,                            -- for denials, break-glass, deletions
  ip_address INET,
  user_agent TEXT,
  session_id VARCHAR(255),
  correlation_id VARCHAR(255),
  metadata JSONB,
  previous_hash VARCHAR(64),              -- hash of previous log entry (chaining)
  entry_hash VARCHAR(64) NOT NULL,        -- hash of this entry for tamper detection
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prevent modifications: revoke UPDATE and DELETE
-- REVOKE UPDATE, DELETE ON hipaa_audit_log FROM application_role;

CREATE INDEX idx_hipaa_audit_user ON hipaa_audit_log(user_id, created_at);
CREATE INDEX idx_hipaa_audit_patient ON hipaa_audit_log(patient_id, created_at);
CREATE INDEX idx_hipaa_audit_type ON hipaa_audit_log(event_type, created_at);
CREATE INDEX idx_hipaa_audit_correlation ON hipaa_audit_log(correlation_id);
```

### Step 4: BAA Technical Requirements
Implement Business Associate Agreement controls:

```
BAA TECHNICAL REQUIREMENTS:
┌────────────────────────────────────────────────────────────────────┐
│  WHAT IS A BUSINESS ASSOCIATE?                                     │
│  Any entity that creates, receives, maintains, or transmits PHI    │
│  on behalf of a covered entity. Examples:                          │
│  - Cloud hosting providers (AWS, Azure, GCP)                       │
│  - SaaS tools processing PHI (email, EHR, analytics)              │
│  - Billing and claims processing services                          │
│  - IT support and managed service providers                        │
│  - Data analytics and reporting vendors                            │
│  - Shredding and disposal companies                                │
│                                                                    │
│  BAA INVENTORY:                                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Vendor           │ PHI Access    │ BAA Status  │ Review     │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  AWS               │ Storage/Proc │ SIGNED      │ <date>     │  │
│  │  SendGrid          │ Email (name) │ SIGNED      │ <date>     │  │
│  │  Stripe            │ Billing      │ SIGNED      │ <date>     │  │
│  │  Analytics SaaS    │ Usage data   │ MISSING     │ REQUIRED   │  │
│  │  Support tool      │ Patient info │ EXPIRED     │ RENEW      │  │
│  │  <vendor>          │ <phi_type>   │ <status>    │ <date>     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  TECHNICAL REQUIREMENTS FOR BUSINESS ASSOCIATES:                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Requirement                   │ Verification Method         │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Encryption at rest            │ SOC 2 report, documentation │  │
│  │  Encryption in transit (TLS)   │ SSL Labs scan, config       │  │
│  │  Access controls               │ RBAC documentation          │  │
│  │  Audit logging                 │ Log sample, retention proof │  │
│  │  Breach notification (60 days) │ BAA clause verification     │  │
│  │  Data return/destruction       │ Procedure documentation     │  │
│  │  Subcontractor BAAs            │ Chain of BAA verification   │  │
│  │  Security risk assessment      │ Annual assessment report    │  │
│  │  Incident response plan        │ Plan documentation          │  │
│  │  Employee training             │ Training records            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  BAA MONITORING:                                                   │
│  - [ ] Annual BAA inventory review                                 │
│  - [ ] Verify all PHI-handling vendors have current BAAs           │
│  - [ ] Review subcontractor chains                                 │
│  - [ ] Verify vendor security posture (request SOC 2, pentest)    │
│  - [ ] Test breach notification procedures                         │
│  - [ ] Verify data return/destruction on contract termination      │
└────────────────────────────────────────────────────────────────────┘
```

#### BAA Tracking Schema
```sql
-- Business Associate Agreement tracking
CREATE TABLE baa_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_name VARCHAR(255) NOT NULL,
  vendor_contact VARCHAR(255),
  service_description TEXT NOT NULL,
  phi_types_accessed TEXT[] NOT NULL,
  phi_access_level VARCHAR(50) NOT NULL,   -- storage, processing, transmission, all
  baa_status VARCHAR(30) NOT NULL,         -- draft, signed, expired, terminated
  baa_signed_date DATE,
  baa_expiry_date DATE,
  baa_document_reference VARCHAR(255),
  subcontractors JSONB DEFAULT '[]',       -- chain of sub-BAs
  last_security_review DATE,
  last_soc2_report_date DATE,
  breach_notification_sla_days INTEGER DEFAULT 60,
  data_return_procedure TEXT,
  data_destruction_procedure TEXT,
  risk_level VARCHAR(20) NOT NULL,         -- high, medium, low
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- BAA review tracking
CREATE TABLE baa_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  baa_id UUID NOT NULL REFERENCES baa_registry(id),
  review_date DATE NOT NULL,
  reviewer VARCHAR(255) NOT NULL,
  findings JSONB DEFAULT '[]',
  risk_assessment VARCHAR(20),
  action_items JSONB DEFAULT '[]',
  next_review_date DATE NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    -- scheduled, in_progress, completed, overdue
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 5: Breach Notification Procedures
Implement HITECH Act breach notification requirements:

```
BREACH NOTIFICATION (§ 164.400-414):
┌────────────────────────────────────────────────────────────────────┐
│  BREACH DEFINITION:                                                │
│  Unauthorized acquisition, access, use, or disclosure of PHI       │
│  that compromises the security or privacy of the information.      │
│  EXCEPTION: Does not include unintentional access by authorized    │
│  workforce member acting in scope, if not further disclosed.       │
│                                                                    │
│  BREACH RISK ASSESSMENT (4-factor test):                           │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Factor                              │ Assessment            │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  1. Nature and extent of PHI         │ <types, sensitivity>  │  │
│  │     (types of identifiers, clinical) │                       │  │
│  │  2. Unauthorized person who used     │ <who accessed it>     │  │
│  │     PHI or to whom disclosure made   │                       │  │
│  │  3. Whether PHI was actually         │ <acquired/viewed?>    │  │
│  │     acquired or viewed               │                       │  │
│  │  4. Extent to which risk to PHI      │ <mitigation steps>    │  │
│  │     has been mitigated               │                       │  │
│  │                                                              │  │
│  │  CONCLUSION: BREACH / NOT A BREACH / LOW PROBABILITY         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  NOTIFICATION TIMELINE:                                            │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  T+0:     Breach discovered (clock starts)                   │  │
│  │  T+24h:   Incident response team convened                    │  │
│  │  T+48h:   4-factor risk assessment completed                 │  │
│  │  T+7d:    Investigation preliminary findings                 │  │
│  │  T+60d:   DEADLINE — Individual notification (§ 164.404)     │  │
│  │           First-class mail or email (if consented)           │  │
│  │           Content: description, PHI types, steps to protect, │  │
│  │           what entity is doing, contact info                 │  │
│  │  T+60d:   DEADLINE — HHS/OCR notification (§ 164.408)       │  │
│  │           < 500 individuals: annual report by Feb 28         │  │
│  │           >= 500 individuals: within 60 days of discovery    │  │
│  │  T+60d:   Media notification if >= 500 in one state/         │  │
│  │           jurisdiction (§ 164.406)                            │  │
│  │  T+60d:   Business associate notifies covered entity         │  │
│  │           (per BAA, often 30 days)                           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  NOTIFICATION CONTENT (§ 164.404(c)):                              │
│  1. Brief description of the breach (what happened, when)          │
│  2. Types of PHI involved (name, SSN, diagnosis, etc.)             │
│  3. Steps individuals should take to protect themselves             │
│  4. What the entity is doing to investigate and mitigate           │
│  5. Contact information for questions (toll-free number, email)    │
│                                                                    │
│  BREACH LOG (maintained for 6 years — § 164.530(j)):               │
│  Every breach or suspected breach recorded regardless of size      │
└────────────────────────────────────────────────────────────────────┘
```

#### Breach Tracking Schema
```sql
-- HIPAA breach register
CREATE TABLE hipaa_breach_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  discovered_at TIMESTAMPTZ NOT NULL,
  discovered_by VARCHAR(255) NOT NULL,
  breach_type VARCHAR(50) NOT NULL,
    -- unauthorized_access, unauthorized_disclosure, loss, theft, improper_disposal
  description TEXT NOT NULL,
  phi_types_involved TEXT[] NOT NULL,
  individuals_affected INTEGER,
  states_affected TEXT[],

  -- 4-factor risk assessment
  phi_nature_extent TEXT,                  -- factor 1
  unauthorized_person TEXT,                -- factor 2
  phi_actually_acquired BOOLEAN,           -- factor 3
  mitigation_extent TEXT,                  -- factor 4
  risk_assessment_conclusion VARCHAR(30),  -- breach, not_breach, low_probability

  -- Notification tracking
  individual_notification_deadline TIMESTAMPTZ,  -- discovered_at + 60 days
  individual_notification_sent_at TIMESTAMPTZ,
  individual_notification_method VARCHAR(50),     -- mail, email, substitute
  hhs_notification_deadline TIMESTAMPTZ,
  hhs_notification_sent_at TIMESTAMPTZ,
  media_notification_required BOOLEAN DEFAULT FALSE,
  media_notification_sent_at TIMESTAMPTZ,
  ba_notification_sent_at TIMESTAMPTZ,

  -- Investigation
  investigation_status VARCHAR(30) NOT NULL DEFAULT 'open',
    -- open, investigating, contained, resolved, closed
  root_cause TEXT,
  corrective_actions JSONB DEFAULT '[]',
  preventive_measures JSONB DEFAULT '[]',

  -- Documentation
  investigation_report TEXT,
  closed_at TIMESTAMPTZ,
  closed_by VARCHAR(255),
  retention_until DATE NOT NULL,           -- discovered_at + 6 years

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 6: De-identification Methods
Implement HIPAA-compliant de-identification:

```
DE-IDENTIFICATION METHODS (§ 164.514):
┌────────────────────────────────────────────────────────────────────┐
│  METHOD 1: SAFE HARBOR (§ 164.514(b)):                             │
│  Remove ALL 18 identifiers listed in Step 1, plus:                 │
│  - No actual knowledge that remaining info could identify          │
│                                                                    │
│  Transformation for each identifier:                               │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Identifier          │ Transformation                        │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Name                │ Remove entirely                        │  │
│  │  Address             │ Truncate to first 3 digits of ZIP     │  │
│  │                      │ (set to 000 if population < 20,000)   │  │
│  │  Dates               │ Year only (if age > 89, use "90+")    │  │
│  │  Phone/Fax           │ Remove entirely                        │  │
│  │  Email               │ Remove entirely                        │  │
│  │  SSN                 │ Remove entirely                        │  │
│  │  Medical record #    │ Remove or replace with random ID       │  │
│  │  Health plan #       │ Remove entirely                        │  │
│  │  Account #           │ Remove entirely                        │  │
│  │  License #           │ Remove entirely                        │  │
│  │  Vehicle/Device IDs  │ Remove entirely                        │  │
│  │  URLs                │ Remove entirely                        │  │
│  │  IP addresses        │ Remove entirely                        │  │
│  │  Biometric IDs       │ Remove entirely                        │  │
│  │  Photos              │ Remove entirely                        │  │
│  │  Unique identifiers  │ Remove or replace with random ID       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  METHOD 2: EXPERT DETERMINATION (§ 164.514(a)):                    │
│  Statistical/scientific expert certifies that risk of              │
│  identification is "very small." Document:                          │
│  - Expert qualifications                                           │
│  - Methods used (k-anonymity, l-diversity, t-closeness)            │
│  - Re-identification risk assessment                               │
│  - Environmental factors considered                                │
│                                                                    │
│  LIMITED DATA SET (§ 164.514(e)):                                   │
│  Not fully de-identified but removes direct identifiers.           │
│  Retains: dates, city, state, ZIP, age                             │
│  Requires: Data Use Agreement (DUA)                                │
│  Permitted for: research, public health, healthcare operations     │
└────────────────────────────────────────────────────────────────────┘
```

### Step 7: HIPAA Compliance Report

```
┌────────────────────────────────────────────────────────────────────┐
│  HIPAA COMPLIANCE REPORT                                           │
├────────────────────────────────────────────────────────────────────┤
│  Assessment date: <date>                                           │
│  Scope: <application/module>                                       │
│  Assessor: <agent/person>                                          │
│  Entity type: Covered Entity / Business Associate / Hybrid         │
│                                                                    │
│  PHI INVENTORY:                                                    │
│    PHI identifiers present: <N> of 18                              │
│    Special categories: <clinical, genetic, psychotherapy>          │
│    ePHI storage locations: <N>                                     │
│    ePHI transmission channels: <N>                                 │
│                                                                    │
│  ADMINISTRATIVE SAFEGUARDS (§ 164.308):                            │
│    Risk analysis: COMPLETED / PARTIAL / MISSING                    │
│    Risk management: IMPLEMENTED / PARTIAL / MISSING                │
│    Workforce security: IMPLEMENTED / PARTIAL / MISSING             │
│    Information access management: IMPLEMENTED / PARTIAL / MISSING  │
│    Security awareness training: CURRENT / EXPIRED / MISSING        │
│    Security incident procedures: DOCUMENTED / MISSING              │
│    Contingency plan: TESTED / DOCUMENTED / MISSING                 │
│    BAA coverage: COMPLETE / PARTIAL / GAPS                         │
│                                                                    │
│  PHYSICAL SAFEGUARDS (§ 164.310):                                  │
│    Facility access controls: IMPLEMENTED / PARTIAL / MISSING       │
│    Workstation use policy: DOCUMENTED / MISSING                    │
│    Workstation security: IMPLEMENTED / PARTIAL / MISSING           │
│    Device and media controls: IMPLEMENTED / PARTIAL / MISSING      │
│                                                                    │
│  TECHNICAL SAFEGUARDS (§ 164.312):                                 │
│    Access control (unique IDs): IMPLEMENTED / PARTIAL / MISSING    │
│    Audit controls: IMPLEMENTED / PARTIAL / MISSING                 │
│    Integrity controls: IMPLEMENTED / PARTIAL / MISSING             │
│    Person/entity auth: IMPLEMENTED / PARTIAL / MISSING             │
│    Transmission security: IMPLEMENTED / PARTIAL / MISSING          │
│    Encryption at rest: ALL / PARTIAL / NONE                        │
│    Encryption in transit: ALL / PARTIAL / NONE                     │
│                                                                    │
│  BREACH READINESS:                                                 │
│    Breach detection: AUTOMATED / MANUAL / NONE                     │
│    4-factor risk assessment template: READY / MISSING              │
│    60-day notification procedure: DOCUMENTED / MISSING             │
│    Breach log maintained: YES / NO                                 │
│                                                                    │
│  BUSINESS ASSOCIATES:                                              │
│    Total vendors with PHI access: <N>                              │
│    BAAs signed and current: <N>                                    │
│    BAAs missing or expired: <N>                                    │
│    Subcontractor BAA chain verified: YES / NO                      │
│                                                                    │
│  FINDINGS:                                                         │
│    CRITICAL: <N> (OCR enforcement risk)                            │
│    HIGH:     <N> (must fix within 30 days)                         │
│    MEDIUM:   <N> (should fix within 90 days)                       │
│    LOW:      <N> (best practice improvement)                       │
│                                                                    │
│  Verdict: COMPLIANT / PARTIAL / NON-COMPLIANT                     │
├────────────────────────────────────────────────────────────────────┤
│  MUST FIX:                                                         │
│  1. <finding with HIPAA section reference>                         │
│  2. <finding with HIPAA section reference>                         │
│                                                                    │
│  SHOULD FIX:                                                       │
│  3. <finding>                                                      │
│  4. <finding>                                                      │
└────────────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Save report as `docs/compliance/<date>-hipaa-assessment.md`
2. Commit: `"hipaa: <scope> — <verdict> (<N> findings, <N> safeguards assessed)"`
3. If NON-COMPLIANT: "Critical HIPAA gaps found. Run `/godmode:fix` to remediate, then re-assess with `/godmode:hipaa`."
4. If COMPLIANT: "HIPAA compliance confirmed. Ready for `/godmode:ship`."

## Key Behaviors

1. **Section-level precision.** Every finding must cite the specific HIPAA section (e.g., "§ 164.312(a)(2)(iv)" not just "encryption missing"). Reference the Security Rule, Privacy Rule, or Breach Notification Rule as applicable.
2. **All 18 identifiers checked.** PHI identification is not optional or partial. Every one of the 18 HIPAA identifiers must be accounted for in the data map.
3. **Minimum necessary is not optional.** Every access to PHI must be justified as the minimum necessary for the stated purpose. Over-broad access is a violation even if the user is authorized.
4. **Encryption is addressable, not optional.** HIPAA calls encryption "addressable" — meaning you must implement it OR document why an equivalent measure is used. In practice, there is no acceptable alternative. Encrypt everything.
5. **Audit logs are 6-year records.** HIPAA requires 6-year retention of compliance documentation. Audit logs must be immutable, tamper-evident, and retained for the full period.
6. **BAAs are required, not nice-to-have.** Every vendor that touches PHI needs a BAA. No exceptions. Missing BAAs are among the most common OCR enforcement findings.
7. **Breach notification has hard deadlines.** 60 days for individuals, same for HHS. Missing these deadlines is itself a separate violation with separate penalties.
8. **De-identification must follow the standard.** "We removed the name" is not de-identification. Either remove all 18 identifiers (Safe Harbor) or get an expert determination. There is no middle ground.

## Example Usage

### Full HIPAA assessment
```
User: /godmode:hipaa We're building a patient portal, need full HIPAA compliance

HIPAA: Starting comprehensive HIPAA assessment...

Step 1: PHI Identification
  Scanning codebase for PHI...
  Found 14 of 18 HIPAA identifiers in 8 tables
  CRITICAL: SSN stored in plaintext (patients.ssn)
  CRITICAL: Full DOB stored without access restrictions

Step 2: Encryption
  At rest: Database encrypted (AES-256), Redis NOT encrypted
  In transit: TLS 1.2 on API, but internal services use HTTP
  CRITICAL (§ 164.312(e)(1)): Service-to-service traffic unencrypted

Step 3: Access Control
  RBAC implemented but overly broad
  HIGH (§ 164.502(b)): All authenticated users can access all patient records
  No break-glass procedure exists
  No automatic session timeout

Step 4: BAA Review
  3 vendors identified, 1 BAA missing (analytics provider)
  HIGH: Analytics provider receives patient usage data without BAA

Report: 3 CRITICAL, 4 HIGH, 2 MEDIUM findings
```

### Encryption deep-dive
```
User: /godmode:hipaa --encryption Our auditor flagged encryption gaps

HIPAA: Assessing encryption implementation...

At rest:
  PostgreSQL: TDE enabled, AES-256 — COMPLIANT
  Redis: No encryption — CRITICAL (§ 164.312(a)(2)(iv))
    Contains session data with patient_id references
    Fix: Enable Redis TLS + at-rest encryption, or move PHI out of cache
  S3: SSE-S3 enabled — upgrade to SSE-KMS for key management
  Backups: Encrypted with AWS managed keys — COMPLIANT

In transit:
  External: TLS 1.2 — COMPLIANT
  Internal: 3 of 7 service connections use plaintext HTTP
    CRITICAL: patient-service -> lab-service uses HTTP
    Fix: Deploy service mesh with mTLS or add TLS to each connection

Key management:
  Keys in environment variables — HIGH risk
  Fix: Migrate to AWS KMS or HashiCorp Vault
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full HIPAA assessment (all steps) |
| `--phi` | PHI identification and classification only |
| `--encryption` | Encryption assessment (at rest and in transit) |
| `--access` | Access control and minimum necessary review |
| `--audit` | Audit logging assessment |
| `--baa` | Business Associate Agreement inventory and review |
| `--breach` | Breach notification procedures |
| `--deidentify` | De-identification methods review |
| `--report` | Generate report from last assessment |
| `--quick` | Top findings only, skip exhaustive checklists |

## Anti-Patterns

- **Do NOT assume "addressable" means "optional."** HIPAA "addressable" specifications mean you must implement the control OR document an equivalent alternative. For encryption, there is no practical equivalent. Just encrypt.
- **Do NOT store PHI in plaintext anywhere.** Not in databases, not in caches, not in logs, not in error messages, not in URLs, not in temporary files. Encrypt everywhere.
- **Do NOT use shared accounts.** Every person accessing ePHI must have a unique identifier. "The team shares the admin password" is a violation of § 164.312(a)(2)(i).
- **Do NOT skip the BAA for any vendor.** "They only see metadata" — if that metadata includes any of the 18 identifiers linked to health information, it is PHI and a BAA is required.
- **Do NOT log PHI in audit trails.** The audit log should record THAT a record was accessed, not WHAT the record contained. Log patient_id references, not patient names or diagnoses.
- **Do NOT assume your cloud provider makes you HIPAA-compliant.** AWS signing a BAA covers their infrastructure obligations. Your application-layer controls are entirely your responsibility.
- **Do NOT ignore the minimum necessary standard.** A physician does not need to see billing details. A billing clerk does not need to see clinical notes. Restrict access to what each role actually needs.
- **Do NOT provide legal advice.** This skill identifies technical compliance gaps and provides implementation guidance. For legal interpretation of HIPAA requirements, recommend consulting a qualified healthcare compliance attorney.
