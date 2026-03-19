---
name: gdpr
description: |
  GDPR deep compliance skill. Activates when user needs comprehensive General Data Protection Regulation compliance — data mapping and classification, consent management implementation, right to deletion (data erasure workflows), data portability exports, privacy impact assessments (DPIAs), DPO notification procedures, and cross-border data transfer mechanisms (SCCs, adequacy decisions). Goes far deeper than the general comply skill by producing implementable code, database schemas, API endpoints, and operational procedures for every GDPR requirement. Triggers on: /godmode:gdpr, "GDPR compliance", "data mapping", "consent management", "right to be forgotten", "data portability", "DPIA", "cross-border transfer", or when building features that collect, process, or share personal data of EU/EEA residents.
---

# GDPR — Deep GDPR Compliance

## When to Activate
- User invokes `/godmode:gdpr`
- User says "GDPR compliance", "data mapping", "consent management", "right to be forgotten"
- User says "data portability", "privacy impact assessment", "DPIA", "cross-border transfer"
- User says "data erasure", "DPO notification", "lawful basis", "data subject rights"
- Building or modifying features that collect, process, or share personal data of EU/EEA residents
- Preparing for DPA (Data Protection Authority) audits or regulatory inspections
- After `/godmode:comply --gdpr` identifies gaps that need deep implementation
- When `/godmode:ship` targets EU/EEA markets

## Workflow

### Step 1: Data Mapping and Classification
Build a comprehensive map of all personal data in the system:

```
DATA MAP — PERSONAL DATA INVENTORY:
┌────────────────────────────────────────────────────────────────────┐
│  DATA CATEGORY         │ FIELDS            │ CLASSIFICATION       │
├────────────────────────────────────────────────────────────────────┤
│  Identity data         │                   │                      │
│    Name                │ first_name,       │ PERSONAL             │
│                        │ last_name         │                      │
│    Email               │ email             │ PERSONAL             │
│    Phone               │ phone_number      │ PERSONAL             │
│    Address             │ street, city,     │ PERSONAL             │
│                        │ postal_code,      │                      │
│                        │ country           │                      │
│    National ID         │ ssn, passport_no  │ SENSITIVE (Art. 9)   │
│                                                                    │
│  Financial data        │                   │                      │
│    Payment info        │ card_last4,       │ PERSONAL             │
│                        │ billing_address   │                      │
│    Transaction history │ amount, date,     │ PERSONAL             │
│                        │ merchant          │                      │
│                                                                    │
│  Behavioral data       │                   │                      │
│    Analytics events    │ page_views,       │ PERSONAL (if linked) │
│                        │ click_events      │                      │
│    Device fingerprint  │ user_agent, IP,   │ PERSONAL             │
│                        │ screen_res        │                      │
│    Location data       │ lat, lng,         │ SENSITIVE            │
│                        │ gps_accuracy      │                      │
│                                                                    │
│  Special categories    │                   │                      │
│  (Article 9)           │                   │                      │
│    Health data         │ <fields>          │ SPECIAL CATEGORY     │
│    Biometric data      │ <fields>          │ SPECIAL CATEGORY     │
│    Racial/ethnic       │ <fields>          │ SPECIAL CATEGORY     │
│    Political opinions  │ <fields>          │ SPECIAL CATEGORY     │
│    Religious beliefs   │ <fields>          │ SPECIAL CATEGORY     │
│    Trade union         │ <fields>          │ SPECIAL CATEGORY     │
│    Sexual orientation  │ <fields>          │ SPECIAL CATEGORY     │
│    Criminal data       │ <fields>          │ ARTICLE 10          │
└────────────────────────────────────────────────────────────────────┘
```

#### Data Flow Mapping (Article 30 — Records of Processing)
```
DATA FLOW DIAGRAM:
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  COLLECTION  │────>│  PROCESSING  │────>│   STORAGE    │
│  POINTS      │     │  ACTIVITIES  │     │  LOCATIONS   │
└──────────────┘     └──────────────┘     └──────────────┘
       │                    │                    │
       ▼                    ▼                    ▼
  Web forms            Analytics           Primary DB
  Mobile app           Recommendations     Redis cache
  API ingestion        Fraud detection     S3 backups
  Third-party import   ML training         Log aggregator
  Cookie consent       Email campaigns     CDN edge cache
                       Report generation   Third-party SaaS

PROCESSING ACTIVITY REGISTER (Article 30):
┌────────────────────────────────────────────────────────────────────┐
│  Activity          │ Purpose       │ Lawful Basis │ Data Cat.     │
├────────────────────────────────────────────────────────────────────┤
│  User registration │ Account       │ Contract     │ Identity      │
│                    │ creation      │ (Art. 6.1.b) │               │
│  Order processing  │ Fulfill order │ Contract     │ Identity,     │
│                    │               │ (Art. 6.1.b) │ Financial     │
│  Marketing email   │ Promotion     │ Consent      │ Email,        │
│                    │               │ (Art. 6.1.a) │ Preferences   │
│  Analytics         │ Improvement   │ Legit. Int.  │ Behavioral    │
│                    │               │ (Art. 6.1.f) │               │
│  Fraud detection   │ Security      │ Legit. Int.  │ Identity,     │
│                    │               │ (Art. 6.1.f) │ Financial     │
│  <activity>        │ <purpose>     │ <basis>      │ <categories>  │
└────────────────────────────────────────────────────────────────────┘

Data retention per activity:
  <activity>: <retention period> → <deletion method>
```

#### Database Schema for Data Map
```sql
-- Data inventory table for Article 30 compliance
CREATE TABLE data_processing_register (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_name VARCHAR(255) NOT NULL,
  purpose TEXT NOT NULL,
  lawful_basis VARCHAR(50) NOT NULL,  -- consent, contract, legal_obligation, vital_interest, public_task, legitimate_interest
  data_categories TEXT[] NOT NULL,
  data_subjects TEXT[] NOT NULL,       -- customers, employees, prospects
  recipients TEXT[],                   -- who receives this data
  third_country_transfers TEXT[],      -- countries outside EEA
  transfer_safeguards TEXT,            -- SCCs, adequacy, BCRs
  retention_period VARCHAR(100) NOT NULL,
  security_measures TEXT,
  dpia_required BOOLEAN DEFAULT FALSE,
  dpia_reference VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by VARCHAR(255)
);

-- Personal data field registry
CREATE TABLE personal_data_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name VARCHAR(255) NOT NULL,
  column_name VARCHAR(255) NOT NULL,
  classification VARCHAR(50) NOT NULL,  -- personal, sensitive, special_category
  gdpr_article VARCHAR(20),             -- Art. 9, Art. 10, etc.
  purpose TEXT NOT NULL,
  encrypted BOOLEAN DEFAULT FALSE,
  pseudonymized BOOLEAN DEFAULT FALSE,
  retention_days INTEGER,
  deletion_method VARCHAR(50),          -- hard_delete, anonymize, pseudonymize
  processing_register_id UUID REFERENCES data_processing_register(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 2: Consent Management Implementation
Build a complete consent management system:

#### Consent Requirements (Articles 6, 7, 8)
```
CONSENT COMPLIANCE CHECKLIST:
┌────────────────────────────────────────────────────────────────────┐
│  Requirement (Article 7)              │ Status   │ Implementation │
├────────────────────────────────────────────────────────────────────┤
│  Freely given                         │ YES/NO   │ <details>      │
│    Not bundled with service access     │          │                │
│    No detriment for refusing           │          │                │
│    Separate consent per purpose        │          │                │
│                                                                    │
│  Specific                             │ YES/NO   │ <details>      │
│    Granular per processing purpose     │          │                │
│    Separate consent for each purpose   │          │                │
│                                                                    │
│  Informed                             │ YES/NO   │ <details>      │
│    Controller identity disclosed       │          │                │
│    Purpose clearly explained           │          │                │
│    Data categories listed              │          │                │
│    Right to withdraw mentioned         │          │                │
│    Plain language (no legalese)        │          │                │
│                                                                    │
│  Unambiguous                          │ YES/NO   │ <details>      │
│    Affirmative action required         │          │                │
│    No pre-ticked boxes                 │          │                │
│    No inactivity-as-consent            │          │                │
│                                                                    │
│  Withdrawable                         │ YES/NO   │ <details>      │
│    Easy to withdraw (same effort)      │          │                │
│    Withdrawal does not affect prior    │          │                │
│    Processing stops after withdrawal   │          │                │
│                                                                    │
│  Children (Article 8)                 │ YES/NO   │ <details>      │
│    Age verification mechanism          │          │                │
│    Parental consent for under-16       │          │                │
│    (or under-13 per member state)      │          │                │
└────────────────────────────────────────────────────────────────────┘
```

#### Consent Database Schema
```sql
-- Consent records with full audit trail
CREATE TABLE consent_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  consent_type VARCHAR(100) NOT NULL,    -- analytics, marketing, profiling, third_party_sharing
  purpose TEXT NOT NULL,                  -- human-readable purpose description
  legal_text_version VARCHAR(50) NOT NULL, -- version of privacy policy shown
  status VARCHAR(20) NOT NULL DEFAULT 'pending',  -- granted, denied, withdrawn
  granted_at TIMESTAMPTZ,
  withdrawn_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  collection_method VARCHAR(50) NOT NULL,  -- web_form, api, cookie_banner, in_app
  ip_address INET,
  user_agent TEXT,
  proof_hash VARCHAR(64),                 -- SHA-256 of consent payload for non-repudiation
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_consent_user_type ON consent_records(user_id, consent_type);
CREATE INDEX idx_consent_status ON consent_records(status);

-- Consent type definitions
CREATE TABLE consent_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT NOT NULL,
  purpose TEXT NOT NULL,
  data_categories TEXT[] NOT NULL,
  third_parties TEXT[],
  is_required BOOLEAN DEFAULT FALSE,     -- required for service (contract basis)
  default_status VARCHAR(20) DEFAULT 'denied',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Consent change audit log (immutable)
CREATE TABLE consent_audit_log (
  id BIGSERIAL PRIMARY KEY,
  consent_record_id UUID NOT NULL REFERENCES consent_records(id),
  user_id UUID NOT NULL,
  action VARCHAR(20) NOT NULL,           -- granted, denied, withdrawn, expired
  previous_status VARCHAR(20),
  new_status VARCHAR(20) NOT NULL,
  triggered_by VARCHAR(50) NOT NULL,     -- user_action, system_expiry, admin_revocation
  ip_address INET,
  user_agent TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Consent API Endpoints
```
CONSENT API DESIGN:

POST   /api/consent                    # Record new consent decision
  Body: { consent_type, status, legal_text_version }
  Response: { consent_id, status, granted_at }

GET    /api/consent                    # Get all consent statuses for current user
  Response: { consents: [{ type, status, granted_at, purpose }] }

PUT    /api/consent/:type              # Update consent (grant or withdraw)
  Body: { status }  -- "granted" or "withdrawn"
  Response: { consent_id, status, updated_at }

DELETE /api/consent/:type              # Withdraw specific consent
  Response: { consent_id, status: "withdrawn", withdrawn_at }

GET    /api/consent/history            # Full consent history for current user
  Response: { history: [{ type, action, timestamp, previous, new }] }

GET    /api/consent/proof/:id          # Download consent proof (for audits)
  Response: { consent_id, proof_hash, timestamp, method, legal_text }
```

#### Consent Middleware
```
CONSENT ENFORCEMENT:

Before processing any data:
  1. Check consent_records for user + purpose
  2. If consent required and not granted → block processing
  3. If consent expired → treat as not granted
  4. Log consent check in audit trail

Middleware pattern:
  requireConsent('analytics')     → gate analytics tracking
  requireConsent('marketing')     → gate marketing emails
  requireConsent('profiling')     → gate recommendation engine
  requireConsent('third_party')   → gate data sharing with partners
```

### Step 3: Right to Deletion (Data Erasure Workflows)
Implement complete Article 17 compliance:

#### Erasure Request Processing
```
ERASURE WORKFLOW (Article 17):
┌────────────────────────────────────────────────────────────────────┐
│  Step 1: Request Reception                                         │
│    Endpoint: DELETE /api/users/me/data                             │
│    Alternative: Manual request via DPO email                       │
│    Verification: Re-authenticate + confirm identity                │
│    SLA: Acknowledge within 24h, complete within 30 days            │
│                                                                    │
│  Step 2: Scope Assessment                                          │
│    Determine which data to erase:                                  │
│    - [ ] All personal data in primary database                     │
│    - [ ] All personal data in caches (Redis, CDN)                  │
│    - [ ] All personal data in backups                              │
│    - [ ] All personal data in log aggregators                      │
│    - [ ] All personal data shared with third parties               │
│    - [ ] All personal data in analytics systems                    │
│                                                                    │
│    Check exemptions (Art. 17.3):                                   │
│    - [ ] Legal obligation to retain? (tax records, anti-fraud)     │
│    - [ ] Public interest archiving?                                │
│    - [ ] Legal claims defense?                                     │
│    - [ ] Freedom of expression?                                    │
│                                                                    │
│  Step 3: Erasure Execution                                         │
│    Primary DB:                                                     │
│      Hard delete: Remove rows from personal data tables            │
│      Anonymize: Replace PII with irreversible hashes               │
│      Retain: Keep anonymized aggregate data for analytics          │
│                                                                    │
│    Cascading systems:                                              │
│      Redis/cache: Invalidate all keys containing user data         │
│      Search index: Remove user documents from Elasticsearch        │
│      File storage: Delete uploaded files (S3, local)               │
│      CDN: Purge cached responses containing user data              │
│      Email service: Remove from all mailing lists                  │
│      Analytics: Delete or anonymize user events                    │
│      Third parties: Send deletion requests via API/email           │
│                                                                    │
│  Step 4: Backup Handling                                           │
│    Option A: Mark for deletion on next restore (deferred erasure)  │
│    Option B: Maintain exclusion list checked during restore        │
│    Option C: Re-encrypt backups excluding deleted user data        │
│    Document chosen approach and retention timeline                 │
│                                                                    │
│  Step 5: Verification                                              │
│    - [ ] Query all systems to confirm data removed                 │
│    - [ ] Generate erasure certificate with timestamp               │
│    - [ ] Log erasure completion in audit trail                     │
│    - [ ] Notify user of completion                                 │
│                                                                    │
│  Step 6: Third-Party Notification (Article 17.2)                   │
│    For each recipient of the data:                                 │
│    - [ ] Send deletion request                                     │
│    - [ ] Track acknowledgment                                      │
│    - [ ] Escalate if no response within 14 days                    │
└────────────────────────────────────────────────────────────────────┘
```

#### Erasure Database Schema
```sql
-- Erasure request tracking
CREATE TABLE erasure_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  requested_at TIMESTAMPTZ DEFAULT NOW(),
  acknowledged_at TIMESTAMPTZ,
  deadline TIMESTAMPTZ NOT NULL,          -- requested_at + 30 days
  status VARCHAR(30) NOT NULL DEFAULT 'received',
    -- received, verified, in_progress, awaiting_third_parties, completed, rejected
  rejection_reason TEXT,                  -- Art. 17.3 exemption if applicable
  exemption_article VARCHAR(20),          -- e.g., "17.3.b" for legal obligation
  scope JSONB NOT NULL,                   -- systems and data categories to erase
  progress JSONB DEFAULT '{}',            -- per-system erasure status
  completed_at TIMESTAMPTZ,
  certificate_hash VARCHAR(64),           -- SHA-256 of erasure certificate
  handled_by VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Third-party deletion tracking
CREATE TABLE erasure_third_party_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  erasure_request_id UUID NOT NULL REFERENCES erasure_requests(id),
  third_party_name VARCHAR(255) NOT NULL,
  notification_method VARCHAR(50) NOT NULL,  -- api, email, manual
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  acknowledged_at TIMESTAMPTZ,
  confirmed_deleted_at TIMESTAMPTZ,
  status VARCHAR(30) NOT NULL DEFAULT 'sent',
    -- sent, acknowledged, confirmed, escalated, failed
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 4: Data Portability Exports
Implement Article 20 — Right to Data Portability:

```
DATA PORTABILITY WORKFLOW:
┌────────────────────────────────────────────────────────────────────┐
│  Endpoint: GET /api/users/me/export                                │
│  Authentication: Required (re-verify identity for sensitive data)  │
│  Formats: JSON (default), CSV, XML                                 │
│  SLA: Available within 30 days (immediate for automated systems)   │
│                                                                    │
│  Export contents:                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Profile data:                                               │  │
│  │    name, email, phone, address, date_of_birth               │  │
│  │                                                              │  │
│  │  Account data:                                               │  │
│  │    created_at, last_login, preferences, settings             │  │
│  │                                                              │  │
│  │  Content data (user-generated):                              │  │
│  │    posts, comments, uploads, messages                        │  │
│  │                                                              │  │
│  │  Transaction data:                                           │  │
│  │    orders, payments, invoices                                │  │
│  │                                                              │  │
│  │  Consent records:                                            │  │
│  │    all consent decisions with timestamps                     │  │
│  │                                                              │  │
│  │  Activity data (provided by user):                           │  │
│  │    search history, favorites, saved items                    │  │
│  │                                                              │  │
│  │  NOT included (derived/inferred):                            │  │
│  │    internal scores, risk ratings, ML predictions             │  │
│  │    aggregated analytics, internal notes                      │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  Machine-readable format:                                          │
│  {                                                                 │
│    "export_metadata": {                                            │
│      "format_version": "1.0",                                      │
│      "exported_at": "ISO-8601",                                    │
│      "data_controller": "Company Name",                            │
│      "data_subject": "user@example.com",                           │
│      "export_scope": ["profile", "transactions", "content"]        │
│    },                                                              │
│    "profile": { ... },                                             │
│    "transactions": [ ... ],                                        │
│    "content": [ ... ],                                             │
│    "consent_history": [ ... ]                                      │
│  }                                                                 │
│                                                                    │
│  Direct transfer (Art. 20.2):                                      │
│  POST /api/users/me/export/transfer                                │
│    Body: { destination_controller, api_endpoint, auth_token }      │
│    Transfer user data directly to another controller               │
└────────────────────────────────────────────────────────────────────┘
```

### Step 5: Privacy Impact Assessments (DPIAs)
Implement Article 35 — Data Protection Impact Assessment:

```
DPIA WORKFLOW (Article 35):
┌────────────────────────────────────────────────────────────────────┐
│  DPIA REQUIRED WHEN:                                               │
│  - [ ] Systematic, extensive profiling with significant effects    │
│  - [ ] Large-scale processing of special categories (Art. 9)      │
│  - [ ] Systematic monitoring of publicly accessible areas          │
│  - [ ] New technologies with high risk to rights and freedoms      │
│  - [ ] Automated decision-making with legal/significant effects    │
│  - [ ] Large-scale processing of children's data                   │
│  - [ ] Data matching or combining from multiple sources            │
│  - [ ] Processing that prevents data subjects from exercising      │
│        their rights (e.g., credit scoring)                         │
│                                                                    │
│  DPIA TEMPLATE:                                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  1. PROCESSING DESCRIPTION                                   │  │
│  │     What: <data types, volume, scope>                        │  │
│  │     Why: <purposes and lawful basis>                         │  │
│  │     How: <collection methods, processing logic, storage>     │  │
│  │     Who: <data subjects, recipients, processors>             │  │
│  │     Where: <geographic scope, transfer mechanisms>           │  │
│  │     How long: <retention periods>                            │  │
│  │                                                              │  │
│  │  2. NECESSITY AND PROPORTIONALITY                            │  │
│  │     Is processing necessary for the stated purpose?          │  │
│  │     Could the purpose be achieved with less data?            │  │
│  │     Is the data minimization principle satisfied?            │  │
│  │     Are retention periods justified and minimal?             │  │
│  │     Is data quality ensured and maintained?                  │  │
│  │                                                              │  │
│  │  3. RISK IDENTIFICATION                                      │  │
│  │     For each risk:                                           │  │
│  │       Source: <internal process, external threat, system>    │  │
│  │       Description: <what could go wrong>                     │  │
│  │       Impact: <HIGH/MEDIUM/LOW on data subject rights>       │  │
│  │       Likelihood: <HIGH/MEDIUM/LOW>                          │  │
│  │       Risk level: Impact x Likelihood                        │  │
│  │                                                              │  │
│  │  4. RISK MITIGATION MEASURES                                 │  │
│  │     For each identified risk:                                │  │
│  │       Measure: <technical or organizational control>         │  │
│  │       Residual risk: <after mitigation>                      │  │
│  │       Responsible: <team or person>                          │  │
│  │       Timeline: <implementation deadline>                    │  │
│  │                                                              │  │
│  │  5. DPO CONSULTATION                                         │  │
│  │     DPO opinion: <approve / conditional / reject>            │  │
│  │     Conditions: <if conditional, list requirements>          │  │
│  │     Date consulted: <date>                                   │  │
│  │                                                              │  │
│  │  6. SUPERVISORY AUTHORITY CONSULTATION (Art. 36)             │  │
│  │     Required if high residual risk after mitigation          │  │
│  │     Authority: <relevant DPA>                                │  │
│  │     Submission date: <date>                                  │  │
│  │     Response: <pending / approved / conditions>              │  │
│  │                                                              │  │
│  │  7. REVIEW SCHEDULE                                          │  │
│  │     Next review: <date — at least annually>                  │  │
│  │     Trigger events: <changes requiring re-assessment>        │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

#### DPIA Database Schema
```sql
-- DPIA tracking
CREATE TABLE dpias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  processing_activity_id UUID REFERENCES data_processing_register(id),
  status VARCHAR(30) NOT NULL DEFAULT 'draft',
    -- draft, in_review, dpo_review, authority_consultation, approved, rejected
  description TEXT NOT NULL,
  necessity_assessment TEXT,
  proportionality_assessment TEXT,
  risks JSONB NOT NULL DEFAULT '[]',
  mitigations JSONB NOT NULL DEFAULT '[]',
  residual_risk_level VARCHAR(20),       -- high, medium, low, negligible
  dpo_opinion VARCHAR(20),               -- approved, conditional, rejected
  dpo_conditions TEXT,
  dpo_reviewed_at TIMESTAMPTZ,
  authority_consultation_required BOOLEAN DEFAULT FALSE,
  authority_name VARCHAR(255),
  authority_submitted_at TIMESTAMPTZ,
  authority_response TEXT,
  next_review_date DATE NOT NULL,
  created_by VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 6: DPO Notification Procedures
Implement Data Protection Officer notification and breach reporting:

```
DPO NOTIFICATION PROCEDURES:
┌────────────────────────────────────────────────────────────────────┐
│  WHEN TO NOTIFY THE DPO:                                           │
│  - [ ] New processing activity involving personal data             │
│  - [ ] Changes to existing processing (new purpose, new data)      │
│  - [ ] Data breach detected or suspected                           │
│  - [ ] Data subject rights request received                        │
│  - [ ] DPIA required for new feature                               │
│  - [ ] Third-party data sharing agreement initiated                │
│  - [ ] Cross-border data transfer proposed                         │
│  - [ ] Complaint from data subject received                        │
│  - [ ] Supervisory authority inquiry received                      │
│                                                                    │
│  BREACH NOTIFICATION (Articles 33, 34):                            │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  TIMELINE:                                                   │  │
│  │  T+0h:  Breach detected → Incident response team activated  │  │
│  │  T+4h:  Initial assessment → scope, severity, data affected │  │
│  │  T+24h: DPO notified with preliminary report                │  │
│  │  T+72h: MANDATORY — Supervisory authority notification       │  │
│  │         (Art. 33 — unless unlikely to result in risk)        │  │
│  │  T+72h: Data subject notification if high risk (Art. 34)    │  │
│  │  T+30d: Full investigation report completed                 │  │
│  │                                                              │  │
│  │  AUTHORITY NOTIFICATION CONTENT (Art. 33.3):                 │  │
│  │  a) Nature of breach (categories, approximate numbers)       │  │
│  │  b) DPO contact details                                     │  │
│  │  c) Likely consequences                                     │  │
│  │  d) Measures taken or proposed to address breach             │  │
│  │                                                              │  │
│  │  DATA SUBJECT NOTIFICATION (Art. 34):                        │  │
│  │  Required when: high risk to rights and freedoms             │  │
│  │  Content: nature of breach, DPO contact, consequences,       │  │
│  │           measures taken, what they can do to protect         │  │
│  │  NOT required if:                                            │  │
│  │    - Data was encrypted (unintelligible to unauthorized)     │  │
│  │    - Measures render high risk unlikely                      │  │
│  │    - Disproportionate effort (use public communication)      │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  BREACH REGISTER (mandatory — Art. 33.5):                          │
│  Every breach recorded regardless of notification requirement      │
└────────────────────────────────────────────────────────────────────┘
```

#### Breach Notification Schema
```sql
-- Breach register (Art. 33.5)
CREATE TABLE breach_register (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  detected_at TIMESTAMPTZ NOT NULL,
  reported_internally_at TIMESTAMPTZ,
  dpo_notified_at TIMESTAMPTZ,
  authority_notified_at TIMESTAMPTZ,
  authority_deadline TIMESTAMPTZ NOT NULL,  -- detected_at + 72h
  subjects_notified_at TIMESTAMPTZ,
  nature TEXT NOT NULL,                     -- confidentiality, integrity, availability
  categories_affected TEXT[] NOT NULL,
  approximate_subjects INTEGER,
  approximate_records INTEGER,
  consequences TEXT,
  measures_taken TEXT,
  measures_proposed TEXT,
  risk_level VARCHAR(20) NOT NULL,          -- high, medium, low, negligible
  authority_notification_required BOOLEAN,
  subject_notification_required BOOLEAN,
  authority_reference VARCHAR(100),         -- reference number from DPA
  status VARCHAR(30) NOT NULL DEFAULT 'detected',
    -- detected, investigating, contained, notified, resolved, closed
  investigation_report TEXT,
  root_cause TEXT,
  preventive_measures TEXT,
  closed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 7: Cross-Border Data Transfer
Implement Chapter V compliance (Articles 44-49):

```
CROSS-BORDER TRANSFER ASSESSMENT:
┌────────────────────────────────────────────────────────────────────┐
│  TRANSFER INVENTORY:                                               │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Destination   │ Data Type     │ Mechanism       │ Status    │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  US (AWS)      │ All user data │ SCCs + TIA      │ REVIEW    │  │
│  │  US (Stripe)   │ Payment data  │ SCCs + DPF      │ COMPLIANT │  │
│  │  India (BPO)   │ Support data  │ SCCs            │ REVIEW    │  │
│  │  UK            │ All data      │ Adequacy        │ COMPLIANT │  │
│  │  <country>     │ <data>        │ <mechanism>     │ <status>  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  TRANSFER MECHANISMS (in order of preference):                     │
│                                                                    │
│  1. Adequacy Decision (Art. 45)                                    │
│     Countries with EU adequacy: Andorra, Argentina, Canada         │
│     (commercial), Faroe Islands, Guernsey, Israel, Isle of Man,    │
│     Japan, Jersey, New Zealand, Republic of Korea, Switzerland,    │
│     UK, Uruguay, US (DPF participants only)                        │
│     Status: Check if destination has adequacy decision              │
│                                                                    │
│  2. Standard Contractual Clauses (Art. 46.2.c)                     │
│     Use the June 2021 EU Commission SCCs:                          │
│     Module 1: Controller to Controller (C2C)                       │
│     Module 2: Controller to Processor (C2P)                        │
│     Module 3: Processor to Processor (P2P)                         │
│     Module 4: Processor to Controller (P2C)                        │
│     REQUIRES Transfer Impact Assessment (TIA)                      │
│                                                                    │
│  3. Binding Corporate Rules (Art. 47)                              │
│     For intra-group transfers in multinational companies            │
│     Approved by lead supervisory authority                         │
│                                                                    │
│  4. Derogations (Art. 49) — LAST RESORT ONLY                      │
│     Explicit consent (informed of risks)                           │
│     Contract performance                                           │
│     Important public interest                                      │
│     Legal claims                                                   │
│     Vital interests                                                │
│                                                                    │
│  TRANSFER IMPACT ASSESSMENT (TIA) — Required for SCCs:             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  1. Identify the transfer and applicable SCC module          │  │
│  │  2. Assess destination country laws:                         │  │
│  │     - Government surveillance laws                           │  │
│  │     - Data protection authority effectiveness                │  │
│  │     - Rule of law and judicial independence                  │  │
│  │  3. Assess supplementary measures:                           │  │
│  │     - Technical: encryption, pseudonymization, split         │  │
│  │       processing, secure multi-party computation             │  │
│  │     - Organizational: policies, audits, transparency         │  │
│  │     - Contractual: additional clauses beyond SCCs            │  │
│  │  4. Document conclusion:                                     │  │
│  │     TRANSFER APPROVED / APPROVED WITH MEASURES / SUSPENDED   │  │
│  │  5. Monitor for changes in destination country laws          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

### Step 8: GDPR Compliance Report

```
┌────────────────────────────────────────────────────────────────────┐
│  GDPR COMPLIANCE REPORT                                            │
├────────────────────────────────────────────────────────────────────┤
│  Assessment date: <date>                                           │
│  Scope: <application/module>                                       │
│  Assessor: <agent/person>                                          │
│                                                                    │
│  DATA MAPPING:                                                     │
│    Personal data categories identified: <N>                        │
│    Special category data present: YES/NO                           │
│    Processing activities documented: <N>                           │
│    Article 30 register: COMPLETE / PARTIAL / MISSING               │
│                                                                    │
│  CONSENT MANAGEMENT:                                               │
│    Consent mechanism: IMPLEMENTED / PARTIAL / MISSING              │
│    Granular per-purpose consent: YES/NO                            │
│    Withdrawal mechanism: YES/NO                                    │
│    Consent audit trail: YES/NO                                     │
│    Children's consent (if applicable): YES/NO/N/A                  │
│                                                                    │
│  DATA SUBJECT RIGHTS:                                              │
│    Right to access (Art. 15): IMPLEMENTED / PARTIAL / MISSING      │
│    Right to rectification (Art. 16): IMPLEMENTED / PARTIAL / MISSING│
│    Right to erasure (Art. 17): IMPLEMENTED / PARTIAL / MISSING     │
│    Right to restriction (Art. 18): IMPLEMENTED / PARTIAL / MISSING │
│    Right to portability (Art. 20): IMPLEMENTED / PARTIAL / MISSING │
│    Right to object (Art. 21): IMPLEMENTED / PARTIAL / MISSING      │
│    Automated decisions (Art. 22): IMPLEMENTED / N/A                │
│                                                                    │
│  DPIA:                                                             │
│    DPIAs required: <N>                                             │
│    DPIAs completed: <N>                                            │
│    High residual risk requiring Art. 36 consultation: <N>          │
│                                                                    │
│  BREACH READINESS:                                                 │
│    Breach detection mechanism: YES/NO                              │
│    72-hour notification procedure: DOCUMENTED / MISSING            │
│    Breach register: MAINTAINED / MISSING                           │
│    DPO notification procedure: DOCUMENTED / MISSING                │
│                                                                    │
│  CROSS-BORDER TRANSFERS:                                           │
│    Transfers identified: <N>                                       │
│    Transfers with valid mechanism: <N>                             │
│    TIAs completed: <N>                                             │
│    Transfers requiring remediation: <N>                            │
│                                                                    │
│  FINDINGS:                                                         │
│    CRITICAL: <N> (regulatory penalty risk)                         │
│    HIGH:     <N> (must fix within 30 days)                         │
│    MEDIUM:   <N> (should fix within 90 days)                       │
│    LOW:      <N> (best practice improvement)                       │
│                                                                    │
│  Verdict: COMPLIANT / PARTIAL / NON-COMPLIANT                     │
├────────────────────────────────────────────────────────────────────┤
│  MUST FIX:                                                         │
│  1. <finding with GDPR article reference>                          │
│  2. <finding with GDPR article reference>                          │
│                                                                    │
│  SHOULD FIX:                                                       │
│  3. <finding>                                                      │
│  4. <finding>                                                      │
└────────────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Save report as `docs/compliance/<date>-gdpr-assessment.md`
2. Commit: `"gdpr: <scope> — <verdict> (<N> findings, <N> articles assessed)"`
3. If NON-COMPLIANT: "Critical GDPR gaps found. Run `/godmode:fix` to remediate, then re-assess with `/godmode:gdpr`."
4. If COMPLIANT: "GDPR compliance confirmed. Ready for `/godmode:ship` to EU/EEA markets."

## Key Behaviors

1. **Article-level precision.** Every finding must cite the specific GDPR article it violates (e.g., "Article 17.1(a)" not just "deletion missing"). Include recital references where they clarify intent.
2. **Implementable output.** Do not just identify gaps — provide database schemas, API endpoint designs, middleware patterns, and operational procedures that can be directly implemented.
3. **Data mapping first.** You cannot assess GDPR compliance without knowing what personal data exists, where it flows, and why it is processed. Step 1 is non-negotiable.
4. **Consent is granular.** One big "I agree" checkbox is not GDPR-compliant consent. Each processing purpose needs separate, specific consent unless a different lawful basis applies.
5. **Erasure means everywhere.** Deleting from the primary database but leaving data in caches, backups, logs, and third-party systems is not erasure. Map every location.
6. **Cross-border requires proof.** "We use AWS" does not document your transfer mechanism. Identify the specific legal basis (SCCs, adequacy, DPF) and complete a Transfer Impact Assessment.
7. **DPIAs are mandatory for high risk.** If the processing involves profiling, special categories, or large-scale monitoring, a DPIA is not optional. Skipping it is itself a violation.
8. **72 hours is the hard deadline.** Breach notification to the supervisory authority must happen within 72 hours. Build the procedure and test it before you need it.
9. **Privacy by design and default.** GDPR Article 25 requires data protection to be built into systems from the start, not bolted on. Evaluate architecture, not just features.

## Example Usage

### Full GDPR assessment
```
User: /godmode:gdpr We're expanding to the EU, need full GDPR compliance

GDPR: Starting comprehensive GDPR assessment...

Step 1: Data Mapping
  Scanning codebase for personal data handling...
  Found 47 personal data fields across 12 tables
  3 special category fields detected (health_status in user_profiles)
  Article 30 register: MISSING — creating template...

Step 2: Consent Management
  Current state: Single "Terms & Conditions" checkbox
  CRITICAL (Art. 7): Consent not granular — analytics, marketing, and service bundled
  Creating consent management schema and API...

Step 3: Right to Erasure
  Current state: Soft delete sets deleted_at, data persists everywhere
  HIGH (Art. 17): No cascade to Redis cache (TTL: 24h)
  HIGH (Art. 17): No cascade to S3 uploads
  HIGH (Art. 17): No third-party deletion notifications
  Creating erasure workflow and tracking system...

Step 4: Data Portability
  Current state: No export endpoint exists
  HIGH (Art. 20): No machine-readable export available
  Creating export API with JSON/CSV output...

Report: 2 CRITICAL, 5 HIGH, 3 MEDIUM findings across 7 GDPR articles
```

### Consent management deep-dive
```
User: /godmode:gdpr --consent We need to fix our cookie consent

GDPR: Assessing consent implementation...

Current consent mechanism:
  File: src/components/CookieBanner.tsx
  Issue: Pre-checked "Accept All" with no granular options
  Violation: Art. 7 (consent not freely given), Art. 4.11 (not unambiguous)

Implementing granular consent:
  1. Cookie consent banner with per-purpose toggles
  2. Consent database with full audit trail
  3. Consent-gating middleware for analytics, marketing, profiling
  4. Withdrawal endpoint matching grant effort

Schema, API, and middleware code provided.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full GDPR assessment (all steps) |
| `--map` | Data mapping and classification only |
| `--consent` | Consent management implementation |
| `--erasure` | Right to deletion workflow |
| `--portability` | Data portability export implementation |
| `--dpia` | Privacy Impact Assessment |
| `--breach` | Breach notification procedures |
| `--transfer` | Cross-border data transfer assessment |
| `--dpo` | DPO notification procedures |
| `--report` | Generate report from last assessment |
| `--quick` | Top findings only, skip exhaustive checklists |

## Auto-Detection

On activation, automatically detect GDPR-relevant context:

```
AUTO-DETECT SEQUENCE:
1. Scan database schemas for personal data fields: name, email, phone, address, date_of_birth, ssn, ip_address
2. Check for existing consent management: consent_records table, cookie banner components, consent API endpoints
3. Detect analytics/tracking: Google Analytics, Mixpanel, Segment, PostHog scripts or SDKs
4. Scan for third-party data sharing: API integrations sending user data externally
5. Check for data deletion endpoints: DELETE /users/me, soft delete patterns (deleted_at columns)
6. Detect cross-border transfers: cloud provider regions (AWS us-east, GCP us-central), third-party SaaS locations
7. Check for existing privacy infrastructure: privacy policy files, cookie consent libraries, DPIA documents
8. Scan for special category data (Article 9): health fields, biometric data, political/religious fields
9. Check for data export endpoints: GET /users/me/export or similar portability features
10. Detect retention policies: TTL settings, cron jobs for data cleanup, retention period configs
```

## Explicit Loop Protocol

When assessing GDPR compliance across multiple processing activities:

```
GDPR ASSESSMENT LOOP:
current_iteration = 0
activities = [registration, analytics, marketing, billing, support, ...]  // discovered processing activities

WHILE current_iteration < len(activities) AND NOT user_says_stop:
  1. SELECT next processing activity
  2. MAP data: identify personal data fields, categories, storage locations
  3. DETERMINE lawful basis: consent, contract, legitimate interest, legal obligation
  4. ASSESS: consent mechanism (if consent basis), data minimization, retention period
  5. CHECK data subject rights coverage: access, rectification, erasure, portability, objection
  6. CHECK cross-border transfers: destination countries, transfer mechanisms (SCCs, adequacy)
  7. EVALUATE DPIA requirement: profiling, special categories, large-scale monitoring
  8. CLASSIFY findings: CRITICAL (regulatory risk), HIGH (30-day fix), MEDIUM (90-day), LOW (best practice)
  9. current_iteration += 1
  10. REPORT: "Activity <N>/<total>: <name> — <finding_count> findings (<critical> critical)"

ON COMPLETION:
  GENERATE Article 30 processing register
  COMPILE full compliance report with GDPR article references
  REPORT: "<N> activities assessed, <M> findings total, <K> critical"
```

## Multi-Agent Dispatch

For comprehensive GDPR compliance projects, dispatch parallel agents:

```
PARALLEL GDPR AGENTS:
When implementing GDPR compliance across multiple dimensions:

Agent 1 (worktree: gdpr-data-map):
  - Build comprehensive data map (all personal data fields, flows, storage)
  - Create Article 30 processing register
  - Document lawful basis per processing activity
  - Identify all cross-border transfers and assess mechanisms

Agent 2 (worktree: gdpr-rights):
  - Implement consent management (database, API, middleware)
  - Build data erasure workflow (cascade to all systems, third-party notification)
  - Implement data portability export (JSON/CSV)
  - Create data subject access request (DSAR) handling system

Agent 3 (worktree: gdpr-governance):
  - Create DPIA templates and complete required DPIAs
  - Implement breach notification procedures and tracking
  - Build BAA/vendor tracking system
  - Set up audit logging for all personal data access

MERGE STRATEGY: Data map merges first (other agents need it for reference).
  Rights implementation and governance merge independently.
  Final: run full GDPR assessment to verify all gaps addressed.
```

## Hard Rules

```
HARD RULES — GDPR:
1. ALWAYS cite the specific GDPR article for every finding (e.g., "Article 17.1(a)" not "deletion missing").
2. NEVER skip the data mapping step. You cannot assess compliance without knowing what data exists and where it flows.
3. ALWAYS implement granular consent — one checkbox for all purposes is NOT valid GDPR consent (Article 7).
4. NEVER confuse soft delete with erasure. Setting deleted_at is NOT Article 17 compliance. Data must be removed or irreversibly anonymized from ALL systems.
5. ALWAYS cascade erasure to: caches, search indexes, file storage, CDN, logs, analytics, and third parties.
6. ALWAYS complete a Transfer Impact Assessment when using SCCs for cross-border transfers (post-Schrems II).
7. ALWAYS conduct a DPIA for: profiling, special category processing, large-scale monitoring, automated decisions.
8. NEVER exceed 72 hours for supervisory authority breach notification (Article 33). Build the procedure before you need it.
9. ALWAYS retain compliance documentation for minimum 6 years.
10. NEVER provide legal advice. Identify technical gaps and recommend consulting a qualified data protection lawyer for legal interpretation.
```

## Anti-Patterns

- **Do NOT treat GDPR as a checkbox exercise.** GDPR is principles-based regulation. Checking boxes without understanding the spirit (data minimization, purpose limitation, transparency) leads to violations dressed up as compliance.
- **Do NOT bundle consent.** "By using this site you agree to everything" is not valid consent under GDPR. Each purpose needs separate, specific, informed consent.
- **Do NOT confuse soft delete with erasure.** Setting `deleted_at` is not Article 17 compliance. Data must be actually removed or irreversibly anonymized from all systems.
- **Do NOT ignore backups.** "We'll delete from backups on next rotation" is only acceptable if documented, bounded in time, and the backup exclusion is verifiable.
- **Do NOT assume legitimate interest covers everything.** Legitimate interest requires a balancing test (your interest vs. data subject rights). It cannot be used as a catch-all to avoid consent.
- **Do NOT skip the Transfer Impact Assessment.** SCCs alone are not sufficient post-Schrems II. You must assess the legal framework of the destination country and implement supplementary measures.
- **Do NOT provide legal advice.** This skill identifies technical compliance gaps and provides implementation guidance. For legal interpretation of GDPR articles, recommend consulting a qualified data protection lawyer.
- **Do NOT forget Article 25.** Privacy by design means building data protection into the system architecture from the start. Retrofitting is harder and more expensive than designing it in.
