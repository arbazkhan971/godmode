# Recipe: Achieving SOC 2 Compliance

> From zero compliance to audit-ready. Policies, controls, evidence collection, and continuous compliance — without drowning in paperwork.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `comply → soc2 → gdpr → secure → devsecops → docs` |
| **Timeline** | 8-16 weeks (depending on existing maturity) |
| **Team size** | 1-2 developers + 1 compliance lead |
| **Example project** | "DataVault" — a B2B SaaS platform achieving SOC 2 Type II certification |

---

## Prerequisites

- Existing production application (compliance applies to running systems)
- Management commitment (compliance is an organizational effort)
- Budget for auditor ($15K-50K for SOC 2 Type II)
- Godmode installed and configured

---

## Why SOC 2

SOC 2 is the table stakes compliance framework for B2B SaaS companies:

| Signal | Impact |
|--------|--------|
| Enterprise sales | Most enterprise buyers require SOC 2 before signing |
| Trust | Demonstrates you take security seriously |
| Process maturity | Forces good security and operational practices |
| Insurance | Lower cyber insurance premiums |
| Competitive advantage | Differentiates from competitors without SOC 2 |

### SOC 2 Trust Service Criteria

| Criteria | Description | Required? |
|----------|------------|-----------|
| **Security** (CC) | Protection against unauthorized access | Always |
| **Availability** (A) | System uptime and performance | Usually |
| **Processing Integrity** (PI) | Data processed completely and accurately | Sometimes |
| **Confidentiality** (C) | Sensitive data protected | Usually |
| **Privacy** (P) | Personal data handled per policy | If handling PII |

This recipe covers Security + Availability + Confidentiality, which is the most common scope.

---

## Session Transcript

### Phase 1: Comply — Assess Current State

```
> /godmode:comply We are a B2B SaaS company called DataVault. We store and
  process customer data on AWS. We need SOC 2 Type II certification. We
  currently have no formal compliance program. Help us assess our current
  state and build a roadmap.

Godmode: Running compliance gap assessment...

COMPLIANCE GAP ASSESSMENT:

Framework: SOC 2 Type II (Security, Availability, Confidentiality)
Current maturity: Level 1 (Ad-hoc — no formal processes)
Target maturity: Level 3 (Defined — documented and repeatable)

CONTROL CATEGORIES AND GAP ANALYSIS:

1. Access Control (CC6)
   Current state:
     ✓ AWS IAM roles exist
     ✗ No centralized identity provider (SSO)
     ✗ No access review process
     ✗ No MFA enforcement for all users
     ✗ No offboarding checklist
   Gap: HIGH — 4 of 5 controls missing

2. Change Management (CC8)
   Current state:
     ✓ Git version control
     ✓ Pull request reviews
     ✗ No formal change approval process
     ✗ No change advisory board
     ✗ No rollback procedures documented
   Gap: MEDIUM — 3 of 5 controls missing

3. Risk Assessment (CC3)
   Current state:
     ✗ No risk register
     ✗ No annual risk assessment
     ✗ No vendor risk management
   Gap: HIGH — 3 of 3 controls missing

4. Monitoring (CC7)
   Current state:
     ✓ CloudWatch basic metrics
     ✗ No security event monitoring
     ✗ No intrusion detection
     ✗ No log retention policy
     ✗ No incident response plan
   Gap: HIGH — 4 of 5 controls missing

5. Availability (A1)
   Current state:
     ✓ AWS multi-AZ deployment
     ✗ No documented SLAs
     ✗ No disaster recovery plan
     ✗ No backup verification
     ✗ No capacity planning
   Gap: MEDIUM — 4 of 5 controls missing

6. Confidentiality (C1)
   Current state:
     ✓ HTTPS in transit
     ✓ EBS encryption at rest
     ✗ No data classification policy
     ✗ No data retention policy
     ✗ No encryption key management policy
   Gap: MEDIUM — 3 of 5 controls missing

ROADMAP:
  Weeks 1-2:   Policies and procedures (documentation)
  Weeks 3-4:   Access control and identity (SSO, MFA, reviews)
  Weeks 5-6:   Security monitoring and incident response
  Weeks 7-8:   Availability and disaster recovery
  Weeks 9-10:  Confidentiality and data handling
  Weeks 11-12: DevSecOps automation and evidence collection
  Weeks 13-14: Internal audit and remediation
  Weeks 15-16: External auditor engagement

Saved: docs/compliance/soc2-gap-assessment.md
Saved: docs/compliance/soc2-roadmap.md

Commit: "comply: SOC 2 gap assessment — 21 gaps across 6 control categories"
```

**Time: 1 hour.**

### Phase 2: SOC2 — Implement Core Controls

```
> /godmode:soc2

Godmode: Reading gap assessment... Implementing SOC 2 controls...

SOC 2 CONTROL IMPLEMENTATION:

Category 1: Policies and Procedures (Week 1-2)

  Documents created:
    policies/information-security-policy.md
      — Scope, roles, responsibilities, acceptable use
    policies/access-control-policy.md
      — Authentication requirements, authorization model, review cadence
    policies/change-management-policy.md
      — Change types, approval workflow, rollback procedures
    policies/incident-response-policy.md
      — Severity levels, response timeline, communication plan
    policies/data-classification-policy.md
      — Public, internal, confidential, restricted categories
    policies/data-retention-policy.md
      — Retention periods by data type, deletion procedures
    policies/vendor-management-policy.md
      — Vendor assessment, ongoing monitoring, risk tiers
    policies/business-continuity-policy.md
      — DR plan, RPO/RTO targets, testing schedule
    policies/encryption-policy.md
      — Algorithms, key management, rotation schedule

  Each policy includes:
    - Purpose and scope
    - Roles and responsibilities
    - Requirements (specific, measurable)
    - Exceptions process
    - Review cadence (annual)
    - Version history

Category 2: Access Control (Week 3-4)

  Technical controls implemented:
    ✓ SSO via Google Workspace (all employees)
    ✓ MFA enforced for all accounts (Google Authenticator / hardware keys)
    ✓ AWS IAM: principle of least privilege, no root account usage
    ✓ Database access: via bastion host only, logged
    ✓ Production access: requires approval, time-limited (break-glass)
    ✓ Quarterly access reviews: automated report of all user access
    ✓ Offboarding checklist: automated account deprovisioning

  Evidence collection:
    - SSO login logs (retained 1 year)
    - MFA enrollment report (quarterly)
    - IAM policy audit (quarterly)
    - Access review completion records

Category 3: Change Management (Week 5-6)

  Process defined:
    Standard change: PR → review → approve → merge → auto-deploy
    Emergency change: PR → approve (1 reviewer) → merge → deploy → post-review
    Infrastructure change: Terraform PR → review → approve → plan → apply

  Technical controls:
    ✓ Branch protection: require review, require CI pass
    ✓ Signed commits enforced
    ✓ Deployment audit trail (GitHub Actions logs)
    ✓ Rollback procedure: documented and tested monthly
    ✓ Change log: auto-generated from PR titles

Category 4: Monitoring and Incident Response (Week 5-6)

  Security monitoring:
    ✓ AWS CloudTrail: all API calls logged, stored in S3 (1 year)
    ✓ AWS GuardDuty: threat detection enabled
    ✓ Application logs: centralized in CloudWatch (90 days)
    ✓ Security alerts: unauthorized access attempts → PagerDuty
    ✓ Vulnerability scanning: Dependabot + Trivy in CI

  Incident response:
    ✓ Incident classification (SEV1-4)
    ✓ Response timeline (SEV1: 15 min acknowledge, 1 hour mitigate)
    ✓ Communication plan (internal + customer notification)
    ✓ Post-incident review process
    ✓ Incident log maintained

Commit: "soc2: core controls — policies, access control, change management, monitoring"
```

**Time: 2-3 days** (policies require thought and organizational input).

### Phase 3: GDPR — Data Protection Controls

```
> /godmode:gdpr

Godmode: Implementing data protection controls...

GDPR / DATA PROTECTION IMPLEMENTATION:

Data mapping:
  ✓ Data inventory: what personal data, where stored, why collected
  ✓ Data flow diagram: collection → processing → storage → deletion
  ✓ Lawful basis: documented for each data processing activity
  ✓ Sub-processors: list with DPAs (Data Processing Agreements)

Data subject rights:
  ✓ Right to access: API endpoint to export user data (JSON)
  ✓ Right to deletion: automated data deletion pipeline
  ✓ Right to portability: data export in machine-readable format
  ✓ Right to rectification: user can update their data
  ✓ Consent management: opt-in tracking with withdrawal support

Technical controls:
  ✓ Data encryption at rest (AES-256) and in transit (TLS 1.3)
  ✓ Data retention automation: cron job deletes data past retention period
  ✓ Audit log of all data access (who accessed what, when)
  ✓ Data minimization: only collect what is needed
  ✓ Pseudonymization: analytics data uses hashed identifiers

Privacy documentation:
  policies/privacy-policy.md            — customer-facing privacy policy
  policies/data-processing-agreement.md — DPA template for customers
  docs/compliance/data-inventory.md     — complete data mapping
  docs/compliance/sub-processors.md     — third-party data processors

Commit: "gdpr: data protection controls — data mapping, subject rights, encryption, retention"
```

**Time: 1-2 days.**

### Phase 4: Secure — Security Hardening

```
> /godmode:secure --framework soc2

Godmode: Running SOC 2-focused security audit...

SECURITY AUDIT (SOC 2 SCOPE):

Infrastructure security:
  ✓ VPC: private subnets for application, no public IPs on instances
  ✓ Security groups: least privilege, no 0.0.0.0/0 ingress
  ✓ WAF: rate limiting, SQL injection protection, XSS protection
  ✓ DDoS: AWS Shield Standard (upgrade to Advanced for high-value targets)
  ✓ TLS: 1.2+ only, strong cipher suites, HSTS enabled

Application security:
  ✓ Authentication: MFA available, session management secure
  ✓ Authorization: RBAC with least privilege
  ✓ Input validation: server-side validation on all endpoints
  ✓ SQL injection: parameterized queries (ORM)
  ✓ XSS: Content Security Policy headers
  ✓ CSRF: SameSite cookies + token validation
  ✓ Dependency scanning: no known critical CVEs

Data security:
  ✓ Encryption at rest: RDS (AES-256), S3 (SSE-S3), EBS (AES-256)
  ✓ Encryption in transit: TLS 1.2+ everywhere
  ✓ Key management: AWS KMS, automatic rotation
  ✓ Backup encryption: all backups encrypted
  ✓ Secrets management: AWS Secrets Manager, no secrets in code

Findings:
  1. MEDIUM — CloudTrail logs should be integrity-validated (enable log file validation)
  2. LOW — Add security headers: X-Content-Type-Options, X-Frame-Options
  3. LOW — Enable S3 versioning on backup buckets

All findings resolved.

Commit: "secure: SOC 2 security hardening — infrastructure, application, data protection"
```

**Time: 1 day.**

### Phase 5: DevSecOps — Automate Compliance Evidence

```
> /godmode:devsecops

Godmode: Setting up continuous compliance automation...

DEVSECOPS IMPLEMENTATION:

The goal: compliance evidence collected automatically, continuously, not
manually assembled before an audit.

Automated evidence collection:

  1. Access control evidence (weekly):
     - Script pulls IAM user list, MFA status, last login
     - Generates report: users-with-access-YYYY-MM-DD.json
     - Stores in compliance S3 bucket (immutable, versioned)

  2. Change management evidence (per deploy):
     - GitHub Actions logs every deployment
     - PR links, approver, test results, deploy timestamp
     - Generates change-log-YYYY-MM.json monthly

  3. Vulnerability management (daily):
     - Dependabot alerts: open vs closed, time to remediate
     - Container image scans: critical/high findings
     - Infrastructure scan: AWS Config compliance rules

  4. Availability evidence (continuous):
     - Uptime monitoring: external health checks every 60s
     - Monthly availability report: uptime percentage, incidents
     - SLA compliance: actual vs committed

  5. Backup verification (weekly):
     - Automated backup restore test
     - Verify data integrity after restore
     - Report: backup-verification-YYYY-MM-DD.json

  6. Security monitoring evidence (continuous):
     - CloudTrail logs: stored immutably in S3
     - GuardDuty findings: acknowledged and tracked
     - Incident reports: linked to post-mortem documents

CI/CD compliance gates:
  ✓ No deploy without passing security scan
  ✓ No deploy without PR approval
  ✓ No deploy with critical dependency vulnerabilities
  ✓ All deployments logged with who, what, when, why

Compliance dashboard (Grafana):
  - Control status: passing/failing per control category
  - Evidence freshness: last collection date per evidence type
  - Open findings: security vulnerabilities, policy violations
  - Audit readiness score: percentage of controls with current evidence

Files created:
  scripts/compliance/collect-access-evidence.sh
  scripts/compliance/collect-change-evidence.sh
  scripts/compliance/collect-vulnerability-evidence.sh
  scripts/compliance/verify-backups.sh
  scripts/compliance/generate-monthly-report.sh
  .github/workflows/compliance-evidence.yml    — scheduled evidence collection
  infra/grafana/dashboards/compliance.json     — compliance dashboard

Commit: "devsecops: automated compliance evidence collection and continuous monitoring"
```

**Time: 1-2 days.**

### Phase 6: Docs — Prepare Audit Documentation

```
> /godmode:docs --type compliance

Godmode: Generating audit-ready documentation package...

AUDIT DOCUMENTATION:

Document 1: System Description
  - Architecture overview with diagrams
  - Data flow diagrams
  - Infrastructure inventory
  - Third-party integrations and sub-processors
  Saved: docs/compliance/system-description.md

Document 2: Control Matrix
  - Every SOC 2 control mapped to:
    - Control description
    - Implementation details
    - Evidence location
    - Testing procedure
    - Owner and review cadence
  Saved: docs/compliance/control-matrix.md

Document 3: Risk Register
  - Identified risks with likelihood and impact
  - Mitigation strategies
  - Residual risk acceptance
  - Review cadence
  Saved: docs/compliance/risk-register.md

Document 4: Vendor Register
  - All third-party services
  - Data processed by each vendor
  - SOC 2 / security certifications per vendor
  - DPA status
  Saved: docs/compliance/vendor-register.md

Document 5: Incident Log
  - All security incidents (with resolution)
  - Post-mortem documents
  - Lessons learned and preventive actions
  Saved: docs/compliance/incident-log.md

Document 6: Evidence Index
  - Where to find evidence for every control
  - Collection frequency
  - Retention period
  - Automated vs manual
  Saved: docs/compliance/evidence-index.md

Auditor-ready package:
  docs/compliance/
    system-description.md
    control-matrix.md
    risk-register.md
    vendor-register.md
    incident-log.md
    evidence-index.md
    policies/              — all policy documents
    evidence/              — collected evidence artifacts

Commit: "docs: SOC 2 audit documentation — system description, control matrix, risk register"
```

**Time: 1-2 days.**

---

## SOC 2 Timeline

| Week | Phase | Skills Used | Output |
|------|-------|-------------|--------|
| 1-2 | Gap assessment | comply | Gap analysis, roadmap |
| 3-4 | Policies | soc2, docs | 9 policy documents |
| 5-6 | Access + change management | soc2 | SSO, MFA, branch protection |
| 7-8 | Monitoring + incident response | soc2, observe | CloudTrail, GuardDuty, IRP |
| 9-10 | Data protection | gdpr | Data mapping, encryption, retention |
| 11-12 | Security hardening | secure | Infrastructure and application security |
| 13-14 | Automation | devsecops | Continuous evidence collection |
| 15 | Documentation | docs | Audit-ready package |
| 16 | Internal audit | comply | Self-assessment, remediation |
| 17+ | External audit | -- | Auditor engagement (3-6 months for Type II) |

---

## Maintaining Compliance

SOC 2 is not a one-time project. It is an ongoing program:

```
Daily:
  - Automated evidence collection runs
  - Security alerts monitored and triaged
  - Dependency vulnerabilities assessed

Weekly:
  - Access review automation runs
  - Backup verification runs
  - Compliance dashboard reviewed

Monthly:
  - Monthly compliance report generated
  - New vendor assessments completed
  - Policy exception reviews

Quarterly:
  - Full access review (all users, all systems)
  - Risk register review and update
  - Penetration testing (annual, but quarterly is better)
  - Policy review for changes needed

Annually:
  - All policies formally reviewed and updated
  - Risk assessment refreshed
  - Business continuity plan tested
  - SOC 2 audit (Type II covers 6-12 month period)
```

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| Treating compliance as a project | "We got SOC 2, we are done" | `/godmode:devsecops` automates ongoing evidence |
| Manual evidence collection | "We will gather evidence before the audit" | Automated scripts run daily/weekly |
| Policy-reality gap | Policies written but not followed | CI/CD gates enforce policies automatically |
| Scope creep | Including too many Trust Service Criteria | `/godmode:comply` recommends minimal scope for first audit |
| No readiness assessment | Jump straight to external audit | Internal audit phase catches gaps before auditor arrives |
| Ignoring vendor risk | "They are a big company, they must be secure" | Vendor register with SOC 2/security status per vendor |

---

## Custom Chain for Compliance

```yaml
# .godmode/chains.yaml
chains:
  compliance-setup:
    description: "Establish SOC 2 compliance program from scratch"
    steps:
      - comply         # gap assessment
      - soc2           # implement controls
      - gdpr           # data protection
      - secure         # security hardening
      - devsecops      # automate evidence
      - docs           # audit documentation

  compliance-review:
    description: "Quarterly compliance review"
    steps:
      - comply         # re-assess against controls
      - secure         # security scan
      - docs           # update documentation
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [Building Auth from Scratch](auth-system.md) — Auth controls for SOC 2
- [Full Observability Setup](monitoring-setup.md) — Monitoring controls for SOC 2
- [Incident Response Recipe](incident-response.md) — Incident response for SOC 2
