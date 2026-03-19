---
name: comply
description: |
  Compliance and governance skill. Activates when user needs to verify regulatory compliance (GDPR, HIPAA, SOC2, PCI-DSS), design audit trails, implement privacy controls, manage data retention policies, or audit license compliance across dependencies. Systematically evaluates codebase against regulatory frameworks, produces findings with evidence and remediation, and generates compliance documentation. Triggers on: /godmode:comply, "GDPR compliance", "audit trail", "are we compliant?", "privacy review", or when shipping features that handle personal data.
---

# Comply — Compliance & Governance

## When to Activate
- User invokes `/godmode:comply`
- User says "are we GDPR compliant?", "audit trail", "privacy review", "compliance check"
- Features handling personal data, health data, or payment data are being built
- Pre-ship check when `/godmode:ship` detects regulated data flows
- User needs license compliance audit across dependencies
- Preparing for SOC2 audit or regulatory review

## Workflow

### Step 1: Define Compliance Scope
Determine which regulations and what code is in scope:

```
COMPLIANCE SCOPE:
Target: <feature/module/entire project>
Applicable regulations:
  - [ ] GDPR (personal data of EU residents)
  - [ ] HIPAA (protected health information)
  - [ ] SOC2 (service organization controls)
  - [ ] PCI-DSS (payment card data)
  - [ ] CCPA (California consumer privacy)
  - [ ] FERPA (educational records)
  - [ ] Other: <specify>

Data classification:
  Personal data: <files/modules handling PII>
  Sensitive data: <files/modules handling health/financial/auth data>
  Public data: <files/modules with non-sensitive data>

Data flows:
  Collection points: <where data enters the system>
  Storage locations: <databases, caches, logs, files>
  Processing points: <services that transform/analyze data>
  Sharing/export: <APIs, integrations, reports>
  Deletion points: <where/how data is removed>
```

### Step 2: GDPR Compliance Check
If personal data of EU residents is processed:

#### Lawful Basis
```
GDPR — LAWFUL BASIS ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│ Data Processing Activity │ Lawful Basis    │ Status     │
├──────────────────────────────────────────────────────────┤
│ User registration        │ Consent         │ COMPLIANT  │
│ Order processing         │ Contract        │ COMPLIANT  │
│ Marketing emails         │ Consent         │ MISSING    │
│ Analytics tracking       │ Legitimate int. │ REVIEW     │
│ Fraud detection          │ Legitimate int. │ COMPLIANT  │
└──────────────────────────────────────────────────────────┘
```

#### Data Subject Rights
```
GDPR — DATA SUBJECT RIGHTS:
┌──────────────────────────────────────────────────────────┐
│ Right                    │ Implemented │ Location       │
├──────────────────────────────────────────────────────────┤
│ Right to access          │ YES/NO      │ <endpoint/UI>  │
│ Right to rectification   │ YES/NO      │ <endpoint/UI>  │
│ Right to erasure         │ YES/NO      │ <endpoint/UI>  │
│ Right to portability     │ YES/NO      │ <endpoint/UI>  │
│ Right to restrict proc.  │ YES/NO      │ <endpoint/UI>  │
│ Right to object          │ YES/NO      │ <endpoint/UI>  │
│ Automated decision-making│ YES/NO/N/A  │ <endpoint/UI>  │
└──────────────────────────────────────────────────────────┘
```

#### Consent Management
```
CONSENT IMPLEMENTATION CHECK:
- [ ] Consent is freely given (not bundled with service access)
- [ ] Consent is specific (separate consent per purpose)
- [ ] Consent is informed (clear language, not legalese)
- [ ] Consent is unambiguous (affirmative action, no pre-ticked boxes)
- [ ] Consent is withdrawable (easy opt-out, same effort as opt-in)
- [ ] Consent records stored (who, when, what, version of terms)
- [ ] Under-16 users: parental consent mechanism exists
```

### Step 3: HIPAA Compliance Check
If protected health information (PHI) is processed:

```
HIPAA — SAFEGUARDS ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│ Safeguard                        │ Status    │ Evidence │
├──────────────────────────────────────────────────────────┤
│ ADMINISTRATIVE SAFEGUARDS                                │
│ Risk analysis conducted          │ YES/NO    │ <ref>    │
│ Workforce access controls        │ YES/NO    │ <ref>    │
│ Security awareness training      │ YES/NO    │ <ref>    │
│ Incident response procedures     │ YES/NO    │ <ref>    │
│ Business associate agreements    │ YES/NO    │ <ref>    │
├──────────────────────────────────────────────────────────┤
│ PHYSICAL SAFEGUARDS                                      │
│ Facility access controls         │ YES/NO    │ <ref>    │
│ Workstation security             │ YES/NO    │ <ref>    │
│ Device and media controls        │ YES/NO    │ <ref>    │
├──────────────────────────────────────────────────────────┤
│ TECHNICAL SAFEGUARDS                                     │
│ Access control (unique user IDs) │ YES/NO    │ <ref>    │
│ Audit controls (activity logs)   │ YES/NO    │ <ref>    │
│ Integrity controls (checksums)   │ YES/NO    │ <ref>    │
│ Transmission security (TLS)      │ YES/NO    │ <ref>    │
│ Encryption at rest (AES-256)     │ YES/NO    │ <ref>    │
└──────────────────────────────────────────────────────────┘

PHI DATA FLOW:
  Minimum necessary: <only required PHI fields accessed?>
  De-identification: <is PHI de-identified where possible?>
  Audit logging: <all PHI access logged with who/what/when?>
```

### Step 4: SOC2 Compliance Check
If operating as a service organization:

```
SOC2 — TRUST SERVICES CRITERIA:
┌──────────────────────────────────────────────────────────┐
│ Category           │ Controls │ Implemented │ Gaps      │
├──────────────────────────────────────────────────────────┤
│ Security           │ 12       │ <N>         │ <N>       │
│ Availability       │ 8        │ <N>         │ <N>       │
│ Processing Integr. │ 6        │ <N>         │ <N>       │
│ Confidentiality    │ 7        │ <N>         │ <N>       │
│ Privacy            │ 10       │ <N>         │ <N>       │
└──────────────────────────────────────────────────────────┘

Key SOC2 Controls:
- [ ] Change management process documented and followed
- [ ] Logical access controls with least privilege
- [ ] Encryption in transit and at rest
- [ ] Monitoring and alerting for security events
- [ ] Incident response plan tested within last 12 months
- [ ] Vendor risk assessments completed
- [ ] Data backup and recovery tested
- [ ] Vulnerability scanning and penetration testing
```

### Step 5: PCI-DSS Compliance Check
If payment card data is processed:

```
PCI-DSS — REQUIREMENTS CHECK:
┌──────────────────────────────────────────────────────────┐
│ Requirement                            │ Status         │
├──────────────────────────────────────────────────────────┤
│ 1. Network security controls           │ PASS/FAIL      │
│ 2. Secure configuration                │ PASS/FAIL      │
│ 3. Protect stored account data         │ PASS/FAIL      │
│ 4. Encrypt transmission over networks  │ PASS/FAIL      │
│ 5. Protect from malicious software     │ PASS/FAIL      │
│ 6. Secure systems and software         │ PASS/FAIL      │
│ 7. Restrict access by business need    │ PASS/FAIL      │
│ 8. Identify users and auth access      │ PASS/FAIL      │
│ 9. Restrict physical access            │ PASS/FAIL/N/A  │
│ 10. Log and monitor all access         │ PASS/FAIL      │
│ 11. Test security regularly            │ PASS/FAIL      │
│ 12. Organizational security policies   │ PASS/FAIL      │
└──────────────────────────────────────────────────────────┘

Cardholder data environment (CDE):
  Scope reduction: <using tokenization/third-party processor?>
  PAN storage: <is primary account number stored? If yes, is it encrypted?>
  CVV storage: <NEVER store CVV — verify this>
```

### Step 6: Audit Trail Design & Validation
Verify that all security-relevant and compliance-relevant events are logged:

```
AUDIT TRAIL ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│ Event Category        │ Logged │ Fields                  │
├──────────────────────────────────────────────────────────┤
│ Authentication        │ YES/NO │ who, when, IP, result   │
│ Authorization changes │ YES/NO │ who, what, when, by-whom│
│ Data access (read)    │ YES/NO │ who, what, when         │
│ Data modification     │ YES/NO │ who, what, old, new     │
│ Data deletion         │ YES/NO │ who, what, when, reason │
│ Data export           │ YES/NO │ who, what, format, dest │
│ Configuration changes │ YES/NO │ who, what, old, new     │
│ System errors         │ YES/NO │ what, when, severity    │
│ Admin operations      │ YES/NO │ who, what, when         │
└──────────────────────────────────────────────────────────┘

Audit log properties:
- [ ] Tamper-resistant (append-only or immutable storage)
- [ ] Retention period defined and enforced (<N> months/years)
- [ ] Searchable and queryable for investigations
- [ ] No PII/PHI in log messages (or properly redacted)
- [ ] Timestamps in UTC with consistent format
- [ ] Correlation IDs for request tracing
- [ ] Separate storage from application data
```

### Step 7: Data Retention & Deletion
Verify data lifecycle management:

```
DATA RETENTION POLICY:
┌──────────────────────────────────────────────────────────┐
│ Data Category     │ Retention │ Auto-delete │ Method     │
├──────────────────────────────────────────────────────────┤
│ User accounts     │ Active+2y │ YES/NO      │ <method>   │
│ Transaction logs  │ 7 years   │ YES/NO      │ <method>   │
│ Session data      │ 30 days   │ YES/NO      │ <method>   │
│ Audit logs        │ 3 years   │ YES/NO      │ <method>   │
│ Analytics data    │ 1 year    │ YES/NO      │ <method>   │
│ Backup data       │ 90 days   │ YES/NO      │ <method>   │
│ Temporary files   │ 24 hours  │ YES/NO      │ <method>   │
└──────────────────────────────────────────────────────────┘

Deletion workflow:
- [ ] Deletion request → verification → execution → confirmation
- [ ] Deletion cascades to all copies (backups, caches, replicas)
- [ ] Deletion is verifiable (can prove data no longer exists)
- [ ] Deletion timeline meets regulatory requirements (GDPR: 30 days)
- [ ] Soft delete vs hard delete strategy documented
```

### Step 8: License Compliance
Audit open-source and third-party license obligations:

```
LICENSE COMPLIANCE:
┌──────────────────────────────────────────────────────────┐
│ License Type   │ Count │ Commercial OK │ Action         │
├──────────────────────────────────────────────────────────┤
│ MIT            │ <N>   │ YES           │ NONE           │
│ Apache 2.0     │ <N>   │ YES           │ NOTICE file    │
│ BSD            │ <N>   │ YES           │ NONE           │
│ ISC            │ <N>   │ YES           │ NONE           │
│ LGPL           │ <N>   │ CONDITIONAL   │ REVIEW         │
│ GPL            │ <N>   │ RISK          │ REPLACE/REVIEW │
│ AGPL           │ <N>   │ HIGH RISK     │ REPLACE        │
│ Unlicensed     │ <N>   │ UNKNOWN       │ INVESTIGATE    │
│ Custom/Prop.   │ <N>   │ VARIES        │ REVIEW TERMS   │
└──────────────────────────────────────────────────────────┘

Actions required:
- GPL/AGPL dependencies: Replace with permissively-licensed alternatives or verify usage does not trigger copyleft obligations
- Unlicensed dependencies: Contact maintainer or replace
- Attribution requirements: Verify NOTICE/LICENSE files are included in distribution
```

### Step 9: Compliance Report

```
┌────────────────────────────────────────────────────────────┐
│  COMPLIANCE AUDIT REPORT                                   │
├────────────────────────────────────────────────────────────┤
│  Regulations assessed:                                     │
│    GDPR:     <COMPLIANT | PARTIAL | NON-COMPLIANT>         │
│    HIPAA:    <COMPLIANT | PARTIAL | NON-COMPLIANT | N/A>   │
│    SOC2:     <COMPLIANT | PARTIAL | NON-COMPLIANT | N/A>   │
│    PCI-DSS:  <COMPLIANT | PARTIAL | NON-COMPLIANT | N/A>  │
│                                                            │
│  Findings:                                                 │
│    CRITICAL: <N> (must fix before launch)                  │
│    HIGH:     <N> (must fix within 30 days)                 │
│    MEDIUM:   <N> (should fix within 90 days)               │
│    LOW:      <N> (best practice, not required)             │
│                                                            │
│  Audit trail:    <COMPLETE | PARTIAL | MISSING>            │
│  Data retention: <DEFINED | PARTIAL | UNDEFINED>           │
│  License risk:   <CLEAR | REVIEW NEEDED | RISK>            │
│                                                            │
│  Verdict: <COMPLIANT | CONDITIONAL | NON-COMPLIANT>       │
├────────────────────────────────────────────────────────────┤
│  MUST FIX (blocking):                                      │
│  1. <CRITICAL finding with regulation reference>           │
│  2. <CRITICAL finding with regulation reference>           │
│                                                            │
│  SHOULD FIX (30 days):                                     │
│  3. <HIGH finding>                                         │
│  4. <HIGH finding>                                         │
└────────────────────────────────────────────────────────────┘
```

### Step 10: Commit and Transition
1. Save report as `docs/compliance/<date>-compliance-audit.md`
2. Commit: `"comply: <scope> — <verdict> (<N> findings across <regulations>)"`
3. If NON-COMPLIANT: "Critical compliance gaps found. Fix these before launch. Run `/godmode:fix` to remediate."
4. If COMPLIANT: "Compliance audit passed. Ready for `/godmode:ship`."

## Key Behaviors

1. **Regulation-specific, not generic.** Each finding must reference the specific regulation article or requirement it violates (e.g., "GDPR Article 17" not just "deletion missing").
2. **Evidence from code.** Every finding must point to actual code — files, functions, database schemas, API endpoints. No theoretical assessments.
3. **Risk-rated findings.** CRITICAL means regulatory penalty or data breach risk. HIGH means audit finding. MEDIUM means best practice gap. LOW means improvement opportunity.
4. **Remediation is concrete.** "Implement consent management" is not remediation. Show the database schema for consent records, the API endpoints for consent capture, and the UI flow.
5. **Privacy by design.** Don't just check boxes — evaluate whether the architecture minimizes data collection, limits data sharing, and defaults to privacy-protective settings.
6. **License compliance is non-negotiable.** A single GPL dependency in a proprietary SaaS product can create legal exposure. Always check.
7. **Audit trails are infrastructure.** Logging is not optional for regulated systems. Verify it exists, verify it captures the right events, verify it is tamper-resistant.

## Example Usage

### GDPR compliance audit
```
User: /godmode:comply We're launching in the EU next month, check our GDPR compliance

Comply: Defining compliance scope...

COMPLIANCE SCOPE:
Target: Full application
Applicable regulations: GDPR
Data classification: User profiles (PII), order history, analytics events

Running GDPR assessment...

FINDING 1: No consent management for analytics tracking
Severity: CRITICAL
Regulation: GDPR Article 6(1)(a), Article 7
Location: src/middleware/analytics.ts:12
Evidence:
```typescript
// Analytics fires on every page load — no consent check
app.use(analyticsMiddleware);
```
Remediation: Gate analytics behind consent check:
```typescript
app.use((req, res, next) => {
  if (req.cookies.analytics_consent === 'granted') {
    analyticsMiddleware(req, res, next);
  } else {
    next();
  }
});
```

FINDING 2: No data export endpoint (Right to portability)
Severity: HIGH
Regulation: GDPR Article 20
Evidence: No endpoint found that exports user data in machine-readable format
Remediation: Create GET /api/users/:id/export returning JSON with all user data

FINDING 3: Soft delete does not cascade to backups
Severity: HIGH
Regulation: GDPR Article 17 (Right to erasure)
Location: src/services/user.ts:45
Evidence: deleteUser() sets deleted_at but data persists in daily backups indefinitely
Remediation: Add backup purge job that removes soft-deleted records after 30 days
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full compliance audit across all applicable regulations |
| `--gdpr` | GDPR compliance check only |
| `--hipaa` | HIPAA compliance check only |
| `--soc2` | SOC2 compliance check only |
| `--pci` | PCI-DSS compliance check only |
| `--audit-trail` | Audit trail design and validation only |
| `--retention` | Data retention policy review only |
| `--licenses` | License compliance scan only |
| `--privacy` | Privacy-focused review (consent, data minimization, rights) |
| `--quick` | Top findings only, skip exhaustive checklist |
| `--report` | Generate report from last audit |

## HARD RULES

1. **NEVER STOP** until all applicable regulations are assessed and all findings are documented.
2. **NEVER provide legal advice** — identify technical gaps, recommend consulting legal counsel for interpretation.
3. **EVERY finding MUST reference a specific regulation article** (e.g., "GDPR Article 17" not "deletion missing").
4. **EVERY finding MUST point to actual code** — file paths, line numbers, functions. No theoretical assessments.
5. **git commit BEFORE verify** — commit the compliance report, then verify all findings are actionable.
6. **Automatic revert on regression** — if a remediation introduces new compliance gaps, revert immediately.
7. **TSV logging** — log every compliance scan:
   ```
   timestamp	regulation	scope	critical	high	medium	low	verdict
   ```
8. **NEVER log PII in audit trails** — log user IDs, not names/SSNs/emails.

## Explicit Loop Protocol

When auditing across multiple regulations:

```
current_iteration = 0
regulations = [GDPR, HIPAA, SOC2, PCI_DSS, ...]  # applicable only
all_findings = []

WHILE regulations is not empty:
    current_iteration += 1
    regulation = regulations.pop(0)

    # Scan codebase for this regulation
    data_flows = trace_data_flows(regulation.data_types)
    controls = check_controls(regulation.requirements)

    FOR each requirement in regulation.requirements:
        evidence = find_evidence(requirement)
        IF evidence.status == NON_COMPLIANT:
            finding = {
                regulation: regulation.name,
                article: requirement.reference,
                severity: assess_severity(requirement),
                location: evidence.code_location,
                remediation: generate_remediation(requirement)
            }
            all_findings.append(finding)

    git commit findings for this regulation

    IF current_iteration % 5 == 0:
        print(f"Progress: {current_iteration} regulations assessed, {len(all_findings)} findings")

generate_report(all_findings)
```

## Auto-Detection

On activation, automatically detect compliance scope:

```
AUTO-DETECT:
1. Data types handled:
   grep -r "email\|password\|ssn\|credit.card\|phone\|address\|dob\|birth" src/ --include="*.ts" --include="*.py" -l 2>/dev/null
   # Determines: PII present -> GDPR/CCPA scope

2. Health data:
   grep -ri "patient\|diagnosis\|medical\|health\|phi\|hipaa" src/ -l 2>/dev/null
   # Determines: PHI present -> HIPAA scope

3. Payment data:
   grep -ri "stripe\|payment\|credit.card\|pan\|cvv\|billing" src/ -l 2>/dev/null
   # Determines: Payment data -> PCI-DSS scope

4. Existing compliance artifacts:
   ls docs/compliance/ docs/privacy/ PRIVACY.md DPA.md 2>/dev/null

5. Audit logging:
   grep -ri "audit.log\|audit.trail\|event.log" src/ -l 2>/dev/null

6. Geographic scope:
   grep -ri "eu\|gdpr\|europe\|california\|ccpa" src/ docs/ -l 2>/dev/null

-> Auto-select applicable regulations based on data types detected.
-> Auto-scope the audit to relevant code paths.
-> Only ask user to confirm scope if multiple regulations apply.
```

## Anti-Patterns

- **Do NOT treat compliance as a checkbox exercise.** Checking boxes without understanding the spirit of the regulation leads to false confidence and real violations.
- **Do NOT copy generic compliance templates.** Every application has unique data flows. The audit must examine YOUR code, YOUR data flows, YOUR architecture.
- **Do NOT skip license compliance.** "We only use open source" does not mean "we are license-compliant." GPL in a SaaS product creates real legal risk.
- **Do NOT log PII in audit trails.** Audit logs that say "user John Smith (SSN: 123-45-6789) accessed record" create a new compliance problem. Log user IDs, not PII.
- **Do NOT assume cloud provider handles compliance.** AWS being HIPAA-eligible does not make YOUR application HIPAA-compliant. You own the application layer.
- **Do NOT ignore data retention.** "We keep everything forever" is a compliance violation for most regulations. Define retention periods and enforce them automatically.
- **Do NOT provide legal advice.** This skill identifies technical compliance gaps. For legal interpretation, recommend consulting legal counsel.
