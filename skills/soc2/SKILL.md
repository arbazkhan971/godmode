---
name: soc2
description: |
  SOC 2 deep compliance skill. Activates when user needs comprehensive SOC 2 audit preparation — Trust Service Criteria assessment (security, availability, processing integrity, confidentiality, privacy), evidence collection automation, control implementation and testing, continuous monitoring setup, and audit preparation workflow. Goes far deeper than the general comply skill by producing implementable controls, evidence collection scripts, monitoring dashboards, control testing procedures, and auditor-ready documentation for every Trust Service Criterion. Triggers on: /godmode:soc2, "SOC 2 compliance", "SOC 2 audit", "trust service criteria", "evidence collection", "control testing", "audit preparation", "continuous monitoring", or when preparing for Type I or Type II SOC 2 audits.
---

# SOC 2 — Deep SOC 2 Compliance

## When to Activate
- User invokes `/godmode:soc2`
- User says "SOC 2 compliance", "SOC 2 audit", "SOC 2 readiness"
- User says "trust service criteria", "evidence collection", "control testing"
- User says "audit preparation", "continuous monitoring", "Type II audit"
- Preparing for SOC 2 Type I (design effectiveness) or Type II (operating effectiveness) audits
- Customer or prospect requires SOC 2 report for vendor assessment
- After `/godmode:comply --soc2` identifies gaps that need deep implementation
- Building or expanding SaaS products that handle customer data

## Workflow

### Step 1: Trust Service Criteria Assessment
Evaluate all five Trust Service Categories:

```
TRUST SERVICE CRITERIA — OVERVIEW:
┌────────────────────────────────────────────────────────────────────┐
│  Category               │ Criteria │ Implemented │ Gaps │ Status  │
├────────────────────────────────────────────────────────────────────┤
│  CC: Security (Common)  │ 33       │ <N>         │ <N>  │         │
│  A:  Availability       │ 8        │ <N>         │ <N>  │         │
│  PI: Processing Integr. │ 6        │ <N>         │ <N>  │         │
│  C:  Confidentiality    │ 7        │ <N>         │ <N>  │         │
│  P:  Privacy            │ 10       │ <N>         │ <N>  │         │
├────────────────────────────────────────────────────────────────────┤
│  Total                  │ 64       │ <N>         │ <N>  │         │
└────────────────────────────────────────────────────────────────────┘

Audit type:
  Type I:  Point-in-time — Are controls designed effectively?
  Type II: Over a period (3-12 months) — Do controls operate effectively?

Scope determination:
  Systems in scope: <list of systems/services>
  Data types: <customer data, financial, operational>
  Infrastructure: <cloud providers, on-premise, hybrid>
  Third parties: <subservice organizations>
```

#### CC: Security (Common Criteria)
```
SECURITY — COMMON CRITERIA:
┌────────────────────────────────────────────────────────────────────┐
│  CC1: CONTROL ENVIRONMENT                                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC1.1 COSO Principle 1 — Integrity & Ethics                │  │
│  │  - [ ] Code of conduct documented and acknowledged           │  │
│  │  - [ ] Ethics policy covers data handling obligations        │  │
│  │  - [ ] Whistleblower/reporting mechanism exists              │  │
│  │  Control: <description of implemented control>               │  │
│  │  Evidence: <document reference>                              │  │
│  │                                                              │  │
│  │  CC1.2 COSO Principle 2 — Board Oversight                   │  │
│  │  - [ ] Security governance structure defined                 │  │
│  │  - [ ] Board/leadership reviews security posture regularly   │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <reference>                                       │  │
│  │                                                              │  │
│  │  CC1.3 COSO Principle 3 — Management Authority              │  │
│  │  - [ ] Security roles and responsibilities assigned          │  │
│  │  - [ ] Reporting lines for security team defined             │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <reference>                                       │  │
│  │                                                              │  │
│  │  CC1.4 COSO Principle 4 — Competence                        │  │
│  │  - [ ] Security team qualifications documented               │  │
│  │  - [ ] Training program for security awareness               │  │
│  │  - [ ] Role-based security training completed                │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <training records>                                │  │
│  │                                                              │  │
│  │  CC1.5 COSO Principle 5 — Accountability                    │  │
│  │  - [ ] Security responsibilities in job descriptions         │  │
│  │  - [ ] Performance metrics include security objectives       │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <reference>                                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC2: COMMUNICATION AND INFORMATION                                │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC2.1 — Internal information for functioning controls       │  │
│  │  - [ ] Security policies documented and accessible           │  │
│  │  - [ ] System descriptions maintained and current            │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <policy documents>                                │  │
│  │                                                              │  │
│  │  CC2.2 — Internal communication of control responsibilities │  │
│  │  - [ ] Security policies communicated to all employees       │  │
│  │  - [ ] Changes communicated promptly                         │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <communication records>                           │  │
│  │                                                              │  │
│  │  CC2.3 — External communication                             │  │
│  │  - [ ] Customer security commitments documented              │  │
│  │  - [ ] Incident communication procedures defined             │  │
│  │  - [ ] Third-party obligations communicated                  │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <SLAs, contracts>                                 │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC3: RISK ASSESSMENT                                              │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC3.1 — Risk identification                                │  │
│  │  - [ ] Annual risk assessment conducted                      │  │
│  │  - [ ] Threat landscape reviewed                             │  │
│  │  - [ ] Asset inventory maintained                            │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <risk assessment report>                          │  │
│  │                                                              │  │
│  │  CC3.2 — Risk from fraud                                    │  │
│  │  - [ ] Fraud risk factors identified                         │  │
│  │  - [ ] Controls against unauthorized data manipulation       │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <reference>                                       │  │
│  │                                                              │  │
│  │  CC3.3 — Significant change identification                  │  │
│  │  - [ ] Change management captures risk implications          │  │
│  │  - [ ] New technologies assessed for risk                    │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <change management records>                       │  │
│  │                                                              │  │
│  │  CC3.4 — Risk response                                      │  │
│  │  - [ ] Risk treatment plans documented                       │  │
│  │  - [ ] Accepted risks documented with rationale              │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <risk register>                                   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC4: MONITORING ACTIVITIES                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC4.1 — Ongoing and separate evaluations                   │  │
│  │  - [ ] Continuous monitoring of security controls            │  │
│  │  - [ ] Periodic control effectiveness testing                │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <monitoring dashboards, test results>             │  │
│  │                                                              │  │
│  │  CC4.2 — Deficiency communication and remediation           │  │
│  │  - [ ] Control deficiencies reported to management           │  │
│  │  - [ ] Remediation tracked and verified                      │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <deficiency tracker, remediation records>         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC5: CONTROL ACTIVITIES                                           │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC5.1 — Control activities that mitigate risks              │  │
│  │  - [ ] Controls mapped to identified risks                   │  │
│  │  - [ ] Controls tested for effectiveness                     │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <control-risk mapping>                            │  │
│  │                                                              │  │
│  │  CC5.2 — Technology general controls                        │  │
│  │  - [ ] IT general controls defined and operating             │  │
│  │  - [ ] Automated controls functioning as designed            │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <ITGC documentation>                              │  │
│  │                                                              │  │
│  │  CC5.3 — Policies as basis for control activities           │  │
│  │  - [ ] Security policies current and approved                │  │
│  │  - [ ] Policies reviewed and updated annually                │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <policy version history>                          │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC6: LOGICAL AND PHYSICAL ACCESS CONTROLS                         │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC6.1 — Logical access security (IAM)                      │  │
│  │  - [ ] User provisioning process documented                  │  │
│  │  - [ ] Unique user IDs for all accounts                      │  │
│  │  - [ ] MFA enabled for all privileged access                 │  │
│  │  - [ ] Password policy enforced (complexity, rotation)       │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <IAM configuration, screenshots>                  │  │
│  │                                                              │  │
│  │  CC6.2 — User registration and authorization                │  │
│  │  - [ ] Access provisioning requires manager approval         │  │
│  │  - [ ] Access based on least-privilege principle              │  │
│  │  - [ ] Role-based access control implemented                 │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <access request forms, approval records>          │  │
│  │                                                              │  │
│  │  CC6.3 — User deprovisioning                                │  │
│  │  - [ ] Offboarding removes access within 24 hours            │  │
│  │  - [ ] Quarterly access reviews conducted                    │  │
│  │  - [ ] Orphaned accounts identified and disabled             │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <offboarding checklists, access reviews>          │  │
│  │                                                              │  │
│  │  CC6.6 — Threat mitigation                                  │  │
│  │  - [ ] Vulnerability scanning (weekly minimum)               │  │
│  │  - [ ] Penetration testing (annual minimum)                  │  │
│  │  - [ ] Endpoint protection deployed                          │  │
│  │  - [ ] Network segmentation implemented                      │  │
│  │  - [ ] Intrusion detection/prevention active                 │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <scan reports, pentest reports>                   │  │
│  │                                                              │  │
│  │  CC6.7 — Access restriction to system components             │  │
│  │  - [ ] Network access restricted by role                     │  │
│  │  - [ ] Production access limited to operations team          │  │
│  │  - [ ] Development cannot access production data             │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <network diagrams, firewall rules>                │  │
│  │                                                              │  │
│  │  CC6.8 — Unauthorized software prevention                   │  │
│  │  - [ ] Software installation policy defined                  │  │
│  │  - [ ] Application allowlisting or approval process          │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <policy document>                                 │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC7: SYSTEM OPERATIONS                                            │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC7.1 — Infrastructure monitoring                          │  │
│  │  - [ ] Security event monitoring (SIEM or equivalent)        │  │
│  │  - [ ] Infrastructure monitoring (uptime, performance)       │  │
│  │  - [ ] Alerting configured for anomalies                     │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <monitoring configuration, alert history>         │  │
│  │                                                              │  │
│  │  CC7.2 — Anomaly detection                                  │  │
│  │  - [ ] Security anomaly detection rules defined              │  │
│  │  - [ ] Behavioral baselines established                      │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <detection rules, baseline documentation>         │  │
│  │                                                              │  │
│  │  CC7.3 — Security event evaluation                          │  │
│  │  - [ ] Events triaged and classified                         │  │
│  │  - [ ] Response procedures defined per severity              │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <triage procedures, event log>                    │  │
│  │                                                              │  │
│  │  CC7.4 — Incident response                                  │  │
│  │  - [ ] Incident response plan documented and tested          │  │
│  │  - [ ] Incident classification and severity levels           │  │
│  │  - [ ] Communication plan for incidents                      │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <IR plan, tabletop exercise records>              │  │
│  │                                                              │  │
│  │  CC7.5 — Incident recovery                                  │  │
│  │  - [ ] Recovery procedures documented                        │  │
│  │  - [ ] Root cause analysis required                          │  │
│  │  - [ ] Post-incident review process                          │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <recovery runbooks, postmortem records>           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC8: CHANGE MANAGEMENT                                            │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC8.1 — Change authorization, design, and implementation   │  │
│  │  - [ ] All changes require approval before deployment        │  │
│  │  - [ ] Changes tested in non-production before deployment    │  │
│  │  - [ ] Rollback procedures documented per change             │  │
│  │  - [ ] Emergency change process defined                      │  │
│  │  - [ ] Separation of duties (dev != deployer)                │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <PR records, deployment logs, approval records>   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  CC9: RISK MITIGATION                                              │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CC9.1 — Risk mitigation activities                         │  │
│  │  - [ ] Risk treatment implemented per risk assessment        │  │
│  │  - [ ] Controls verified effective                           │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <risk treatment records>                          │  │
│  │                                                              │  │
│  │  CC9.2 — Vendor risk management                             │  │
│  │  - [ ] Vendor risk assessments conducted                     │  │
│  │  - [ ] Vendor security requirements in contracts             │  │
│  │  - [ ] Vendor SOC 2 reports or equivalent reviewed           │  │
│  │  Control: <description>                                      │  │
│  │  Evidence: <vendor assessments, contract clauses>            │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

#### A: Availability
```
AVAILABILITY CRITERIA:
┌────────────────────────────────────────────────────────────────────┐
│  A1.1 — Processing capacity management                             │
│  - [ ] Capacity planning documented                                │
│  - [ ] Auto-scaling configured and tested                          │
│  - [ ] Resource utilization monitored with alerting thresholds     │
│  Control: <description>                                            │
│  Evidence: <capacity plan, auto-scaling config, monitoring>        │
│                                                                    │
│  A1.2 — Environmental protections                                  │
│  - [ ] Infrastructure redundancy (multi-AZ, multi-region)          │
│  - [ ] Failover mechanisms tested                                  │
│  - [ ] DDoS protection deployed                                    │
│  Control: <description>                                            │
│  Evidence: <architecture diagrams, failover test results>          │
│                                                                    │
│  A1.3 — Recovery procedures                                       │
│  - [ ] Backup strategy documented (frequency, retention, testing)  │
│  - [ ] RTO and RPO defined per service                             │
│  - [ ] Disaster recovery plan documented and tested                │
│  - [ ] Recovery tested within last 12 months                       │
│  Control: <description>                                            │
│  Evidence: <DR plan, backup config, recovery test records>         │
│                                                                    │
│  SLA COMMITMENTS:                                                  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Service         │ SLA Target  │ Actual (period) │ Met?      │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Web application │ 99.9%       │ <actual>%       │ YES/NO    │  │
│  │  API             │ 99.9%       │ <actual>%       │ YES/NO    │  │
│  │  Database        │ 99.99%      │ <actual>%       │ YES/NO    │  │
│  │  <service>       │ <target>    │ <actual>        │ YES/NO    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

#### PI: Processing Integrity
```
PROCESSING INTEGRITY CRITERIA:
┌────────────────────────────────────────────────────────────────────┐
│  PI1.1 — Processing objectives defined                             │
│  - [ ] System processing specifications documented                 │
│  - [ ] Input/output specifications defined                         │
│  - [ ] Processing accuracy requirements documented                 │
│  Control: <description>                                            │
│  Evidence: <system specifications>                                 │
│                                                                    │
│  PI1.2 — Input validation                                          │
│  - [ ] All inputs validated before processing                      │
│  - [ ] Validation rules documented                                 │
│  - [ ] Rejected inputs logged and reported                         │
│  Control: <description>                                            │
│  Evidence: <validation rules, error handling code>                 │
│                                                                    │
│  PI1.3 — Processing completeness and accuracy                      │
│  - [ ] Processing steps verified for completeness                  │
│  - [ ] Error detection and correction mechanisms                   │
│  - [ ] Reconciliation procedures for data integrity                │
│  Control: <description>                                            │
│  Evidence: <reconciliation reports, error handling>                │
│                                                                    │
│  PI1.4 — Output review                                             │
│  - [ ] Outputs verified against processing specifications          │
│  - [ ] Output errors investigated and resolved                     │
│  Control: <description>                                            │
│  Evidence: <output validation, QA procedures>                      │
│                                                                    │
│  PI1.5 — Error handling                                            │
│  - [ ] Processing errors detected and reported                     │
│  - [ ] Error resolution procedures documented                      │
│  - [ ] Error correction verified before reprocessing               │
│  Control: <description>                                            │
│  Evidence: <error handling documentation, error logs>              │
└────────────────────────────────────────────────────────────────────┘
```

#### C: Confidentiality
```
CONFIDENTIALITY CRITERIA:
┌────────────────────────────────────────────────────────────────────┐
│  C1.1 — Confidential information identification                    │
│  - [ ] Data classification policy defined                          │
│  - [ ] Confidential data tagged/labeled in systems                 │
│  - [ ] Data handling procedures per classification level           │
│  Control: <description>                                            │
│  Evidence: <classification policy, data inventory>                 │
│                                                                    │
│  C1.2 — Confidential information disposal                          │
│  - [ ] Data retention policy defined per data type                 │
│  - [ ] Automated deletion for expired data                         │
│  - [ ] Secure disposal methods (crypto-shred, overwrite)           │
│  Control: <description>                                            │
│  Evidence: <retention policy, disposal logs>                       │
│                                                                    │
│  DATA CLASSIFICATION LEVELS:                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Level          │ Examples           │ Controls              │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Public         │ Marketing site,    │ Integrity checks      │  │
│  │                 │ documentation      │                       │  │
│  │  Internal       │ Internal wiki,     │ Auth required,        │  │
│  │                 │ employee directory │ access logging         │  │
│  │  Confidential   │ Customer data,     │ Encryption, RBAC,     │  │
│  │                 │ source code        │ audit logging          │  │
│  │  Restricted     │ Credentials, PII,  │ Encryption, MFA,      │  │
│  │                 │ financial data     │ strict RBAC, alerts    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

#### P: Privacy
```
PRIVACY CRITERIA:
┌────────────────────────────────────────────────────────────────────┐
│  P1.1 — Privacy notice                                             │
│  - [ ] Privacy policy published and accessible                     │
│  - [ ] Describes data collected, used, retained, disclosed         │
│  - [ ] Updated when practices change                               │
│                                                                    │
│  P2.1 — Consent and choice                                         │
│  - [ ] Consent obtained for data collection                        │
│  - [ ] Opt-out mechanisms available                                │
│  - [ ] Consent records maintained                                  │
│                                                                    │
│  P3.1 — Data collection limited to stated purposes                 │
│  - [ ] Only data necessary for stated purposes collected           │
│  - [ ] Collection methods documented                               │
│                                                                    │
│  P4.1 — Data use limited to stated purposes                        │
│  - [ ] Data used only for purposes in privacy notice               │
│  - [ ] Secondary use requires additional consent                   │
│                                                                    │
│  P5.1 — Data retention and disposal                                │
│  - [ ] Retention periods defined per data type                     │
│  - [ ] Data disposed of securely when no longer needed             │
│                                                                    │
│  P6.1 — Access to personal information                             │
│  - [ ] Individuals can access their data                           │
│  - [ ] Correction/update mechanism available                       │
│                                                                    │
│  P7.1 — Third-party disclosure                                     │
│  - [ ] Third-party data sharing disclosed in privacy notice        │
│  - [ ] Third-party agreements include privacy obligations          │
│                                                                    │
│  P8.1 — Data quality                                               │
│  - [ ] Data accuracy maintained                                    │
│  - [ ] Correction mechanisms available                             │
└────────────────────────────────────────────────────────────────────┘
```

### Step 2: Evidence Collection Automation
Build automated evidence collection for continuous audit readiness:

```
EVIDENCE COLLECTION FRAMEWORK:
┌────────────────────────────────────────────────────────────────────┐
│  AUTOMATED EVIDENCE SOURCES:                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Evidence Type       │ Source           │ Frequency │ Auto?   │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Access reviews      │ IAM provider     │ Quarterly │ YES     │  │
│  │  MFA enrollment      │ Identity provider│ Monthly   │ YES     │  │
│  │  Vulnerability scans │ Scanner tool     │ Weekly    │ YES     │  │
│  │  Pentest reports     │ Security team    │ Annual    │ NO      │  │
│  │  Change approvals    │ Git/PR system    │ Per change│ YES     │  │
│  │  Deploy logs         │ CI/CD system     │ Per deploy│ YES     │  │
│  │  Uptime metrics      │ Monitoring tool  │ Monthly   │ YES     │  │
│  │  Incident records    │ Incident tracker │ Per event │ YES     │  │
│  │  Backup test results │ Backup system    │ Monthly   │ YES     │  │
│  │  Training completion │ LMS              │ Annual    │ YES     │  │
│  │  Policy versions     │ Document system  │ Per change│ YES     │  │
│  │  Vendor assessments  │ GRC platform     │ Annual    │ NO      │  │
│  │  Encryption config   │ Cloud provider   │ Monthly   │ YES     │  │
│  │  Firewall rules      │ Network config   │ Monthly   │ YES     │  │
│  │  Offboarding records │ HR system        │ Per event │ PARTIAL │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  EVIDENCE COLLECTION SCRIPTS:                                      │
│                                                                    │
│  1. IAM Evidence:                                                  │
│     - Export user list with roles and last login                   │
│     - Export MFA enrollment status for all users                   │
│     - Export access provisioning/deprovisioning records            │
│     - Export service account inventory                             │
│                                                                    │
│  2. Change Management Evidence:                                    │
│     - Export Git PR history with approvals                         │
│     - Export CI/CD deployment history with approvers               │
│     - Export emergency change records with post-approvals          │
│     - Verify all production changes have PR approval               │
│                                                                    │
│  3. Monitoring Evidence:                                           │
│     - Export uptime/availability metrics for audit period          │
│     - Export incident records with resolution details              │
│     - Export alert configuration and notification rules            │
│     - Export anomaly detection rules and trigger history           │
│                                                                    │
│  4. Encryption Evidence:                                           │
│     - Export encryption-at-rest configuration per service          │
│     - Export TLS configuration and certificate inventory           │
│     - Export key management configuration                          │
│     - Verify no unencrypted data stores in scope                  │
│                                                                    │
│  5. Backup and DR Evidence:                                        │
│     - Export backup schedules and retention settings               │
│     - Export backup success/failure logs                           │
│     - Export most recent DR test results                           │
│     - Verify RPO and RTO targets met                              │
│                                                                    │
│  EVIDENCE STORAGE:                                                 │
│  - Centralized evidence repository with version control            │
│  - Timestamped and immutable (hash-verified)                       │
│  - Organized by TSC category and control                           │
│  - Retained for audit period + 1 year minimum                      │
│  - Access restricted to compliance and audit teams                 │
└────────────────────────────────────────────────────────────────────┘
```

#### Evidence Collection Database Schema
```sql
-- SOC 2 evidence tracking
CREATE TABLE soc2_evidence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tsc_category VARCHAR(10) NOT NULL,       -- CC, A, PI, C, P
  tsc_criterion VARCHAR(20) NOT NULL,      -- CC6.1, A1.2, etc.
  control_id VARCHAR(50) NOT NULL,         -- internal control reference
  evidence_type VARCHAR(50) NOT NULL,
    -- screenshot, config_export, log_export, report, policy_doc, attestation
  title VARCHAR(255) NOT NULL,
  description TEXT,
  file_reference VARCHAR(500),             -- path to evidence file
  file_hash VARCHAR(64),                   -- SHA-256 for integrity
  collection_method VARCHAR(20) NOT NULL,  -- automated, manual
  collected_at TIMESTAMPTZ DEFAULT NOW(),
  collected_by VARCHAR(255) NOT NULL,      -- system or person
  audit_period_start DATE NOT NULL,
  audit_period_end DATE NOT NULL,
  verified_by VARCHAR(255),
  verified_at TIMESTAMPTZ,
  status VARCHAR(20) NOT NULL DEFAULT 'collected',
    -- collected, verified, submitted, accepted, rejected
  auditor_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_soc2_evidence_criterion ON soc2_evidence(tsc_criterion, audit_period_start);
CREATE INDEX idx_soc2_evidence_control ON soc2_evidence(control_id);

-- Control definitions and testing
CREATE TABLE soc2_controls (
  id VARCHAR(50) PRIMARY KEY,              -- CTRL-001, CTRL-002, etc.
  tsc_criteria TEXT[] NOT NULL,            -- which TSC criteria this maps to
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  control_type VARCHAR(20) NOT NULL,       -- preventive, detective, corrective
  control_nature VARCHAR(20) NOT NULL,     -- automated, manual, hybrid
  frequency VARCHAR(50) NOT NULL,          -- continuous, daily, weekly, monthly, quarterly, annual
  owner VARCHAR(255) NOT NULL,
  test_procedure TEXT NOT NULL,
  evidence_requirements TEXT[] NOT NULL,
  last_tested DATE,
  last_test_result VARCHAR(20),            -- effective, ineffective, not_tested
  last_test_evidence VARCHAR(500),
  next_test_date DATE,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
    -- active, draft, deprecated, remediation
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Control test results
CREATE TABLE soc2_control_tests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  control_id VARCHAR(50) NOT NULL REFERENCES soc2_controls(id),
  test_date DATE NOT NULL,
  tester VARCHAR(255) NOT NULL,
  test_procedure_followed TEXT NOT NULL,
  sample_size INTEGER,
  sample_selection_method VARCHAR(50),     -- random, judgmental, entire_population
  result VARCHAR(20) NOT NULL,             -- effective, ineffective, partially_effective
  exceptions_found INTEGER DEFAULT 0,
  exception_details JSONB DEFAULT '[]',
  evidence_references TEXT[],
  remediation_required BOOLEAN DEFAULT FALSE,
  remediation_plan TEXT,
  remediation_deadline DATE,
  remediation_completed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 3: Control Implementation and Testing
Implement and test controls for each Trust Service Criterion:

```
CONTROL IMPLEMENTATION WORKFLOW:
┌────────────────────────────────────────────────────────────────────┐
│  FOR EACH GAP IDENTIFIED:                                          │
│                                                                    │
│  1. DESIGN the control                                             │
│     - Define control objective (what risk it addresses)            │
│     - Define control activity (what happens)                       │
│     - Define frequency (how often)                                 │
│     - Define owner (who is responsible)                            │
│     - Map to TSC criteria                                          │
│                                                                    │
│  2. IMPLEMENT the control                                          │
│     Technical controls:                                            │
│       - Configure IAM rules and policies                           │
│       - Enable encryption and key management                       │
│       - Deploy monitoring and alerting                             │
│       - Configure change management gates                          │
│       - Implement automated evidence collection                    │
│     Process controls:                                              │
│       - Document procedures and policies                           │
│       - Train responsible personnel                                │
│       - Set up review schedules                                    │
│       - Create checklists and templates                            │
│                                                                    │
│  3. TEST the control                                               │
│     Design test:                                                   │
│       - Inquiry: Interview control owner                           │
│       - Observation: Watch control operating                       │
│       - Inspection: Review evidence artifacts                      │
│       - Reperformance: Execute control independently               │
│     Sample selection:                                              │
│       - Automated daily controls: sample 25-60 instances           │
│       - Manual weekly controls: sample 5-15 instances              │
│       - Manual monthly controls: sample all or 2-5 instances       │
│       - Annual controls: test 1 instance (the occurrence)          │
│     Document:                                                      │
│       - Test procedure performed                                   │
│       - Sample selection method and size                           │
│       - Result (effective / ineffective)                           │
│       - Exceptions found                                           │
│       - Evidence collected                                         │
│                                                                    │
│  4. REMEDIATE gaps                                                 │
│     - Document deficiency and impact                               │
│     - Create remediation plan with deadline                        │
│     - Implement fix                                                │
│     - Re-test to verify effectiveness                              │
│     - Update evidence                                              │
│                                                                    │
│  CONTROL TESTING MATRIX:                                           │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Control      │ Criterion │ Frequency │ Test Method │ Result │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  CTRL-001     │ CC6.1     │ Continuous│ Inspection  │        │  │
│  │  MFA enforced │           │           │ + reperform │        │  │
│  │  CTRL-002     │ CC8.1     │ Per change│ Inspection  │        │  │
│  │  PR approval  │           │           │             │        │  │
│  │  CTRL-003     │ A1.3      │ Monthly   │ Reperform   │        │  │
│  │  Backup test  │           │           │             │        │  │
│  │  <control>    │ <crit>    │ <freq>    │ <method>    │        │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

### Step 4: Continuous Monitoring Setup
Build continuous compliance monitoring infrastructure:

```
CONTINUOUS MONITORING ARCHITECTURE:
┌────────────────────────────────────────────────────────────────────┐
│  MONITORING LAYERS:                                                │
│                                                                    │
│  Layer 1: Infrastructure Monitoring                                │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Metric                  │ Alert Threshold   │ TSC Criteria  │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Uptime                  │ < 99.9%           │ A1.1          │  │
│  │  Response time (p99)     │ > 2s              │ A1.1, PI1.3   │  │
│  │  Error rate              │ > 1%              │ PI1.5         │  │
│  │  CPU utilization         │ > 80% sustained   │ A1.1          │  │
│  │  Memory utilization      │ > 85% sustained   │ A1.1          │  │
│  │  Disk utilization        │ > 90%             │ A1.1          │  │
│  │  SSL cert expiry         │ < 30 days         │ CC6.1         │  │
│  │  Backup success rate     │ < 100%            │ A1.3          │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  Layer 2: Security Monitoring                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Event                   │ Alert Condition   │ TSC Criteria  │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Failed login attempts   │ > 5 in 5 min      │ CC6.1, CC7.2  │  │
│  │  Privilege escalation    │ Any occurrence     │ CC6.1         │  │
│  │  New admin account       │ Any occurrence     │ CC6.2         │  │
│  │  MFA disabled            │ Any occurrence     │ CC6.1         │  │
│  │  Firewall rule change    │ Any occurrence     │ CC6.7         │  │
│  │  Unencrypted data store  │ Any occurrence     │ C1.1          │  │
│  │  Vulnerability (critical)│ Any new discovery  │ CC6.6         │  │
│  │  Suspicious data export  │ > threshold        │ C1.1, P4.1    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  Layer 3: Compliance Monitoring                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Check                   │ Frequency │ Alert Condition       │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Access review overdue   │ Quarterly │ > 7 days past due     │  │
│  │  Policy review overdue   │ Annual    │ > 30 days past due    │  │
│  │  Training incomplete     │ Annual    │ Any employee overdue  │  │
│  │  Vendor review overdue   │ Annual    │ > 30 days past due    │  │
│  │  Control test overdue    │ Per sched │ > 14 days past due    │  │
│  │  Evidence gap            │ Monthly   │ Missing for any ctrl  │  │
│  │  Incident unresolved     │ Per SLA   │ Past SLA deadline     │  │
│  │  Risk assessment overdue │ Annual    │ > 30 days past due    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  COMPLIANCE DASHBOARD METRICS:                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Metric                        │ Current │ Target │ Trend    │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Overall control effectiveness │ <N>%    │ 100%   │ ↑↓→     │  │
│  │  Evidence collection rate      │ <N>%    │ 95%+   │ ↑↓→     │  │
│  │  Open control deficiencies     │ <N>     │ 0      │ ↑↓→     │  │
│  │  Mean time to remediate        │ <N> days│ < 30d  │ ↑↓→     │  │
│  │  Overdue control tests         │ <N>     │ 0      │ ↑↓→     │  │
│  │  Overdue access reviews        │ <N>     │ 0      │ ↑↓→     │  │
│  │  System availability (MTD)     │ <N>%    │ 99.9%  │ ↑↓→     │  │
│  │  Incident response time (avg)  │ <N> min │ < 30m  │ ↑↓→     │  │
│  │  Vulnerability remediation SLA │ <N>%    │ 100%   │ ↑↓→     │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

### Step 5: Audit Preparation Workflow
Prepare for auditor engagement:

```
AUDIT PREPARATION CHECKLIST:
┌────────────────────────────────────────────────────────────────────┐
│  PRE-AUDIT (8-12 weeks before):                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  - [ ] Select audit firm and sign engagement letter           │  │
│  │  - [ ] Define audit scope (systems, TSC categories, period)   │  │
│  │  - [ ] Assign internal audit liaison                          │  │
│  │  - [ ] Complete internal readiness assessment                 │  │
│  │  - [ ] Remediate known control gaps                           │  │
│  │  - [ ] Verify all evidence is collected and organized         │  │
│  │  - [ ] Prepare system description narrative                   │  │
│  │  - [ ] Brief team on audit process and expectations           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  SYSTEM DESCRIPTION (Required for SOC 2 report):                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  1. Company overview and services                            │  │
│  │  2. Principal service commitments and system requirements    │  │
│  │  3. Components of the system:                                │  │
│  │     a. Infrastructure (servers, networks, cloud)             │  │
│  │     b. Software (applications, utilities, databases)          │  │
│  │     c. People (roles, responsibilities, training)            │  │
│  │     d. Procedures (automated and manual)                     │  │
│  │     e. Data (types, classification, flow)                    │  │
│  │  4. Boundaries of the system (in-scope vs. out-of-scope)     │  │
│  │  5. Subservice organizations and their responsibilities      │  │
│  │  6. Relevant aspects of the control environment              │  │
│  │  7. Complementary User Entity Controls (CUECs)               │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  EVIDENCE PACKAGE (organized by TSC):                              │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Folder Structure:                                           │  │
│  │  evidence/                                                   │  │
│  │  ├── CC1-control-environment/                                │  │
│  │  │   ├── code-of-conduct.pdf                                 │  │
│  │  │   ├── org-chart.pdf                                       │  │
│  │  │   └── training-records.csv                                │  │
│  │  ├── CC6-logical-access/                                     │  │
│  │  │   ├── iam-user-list-Q1.csv                                │  │
│  │  │   ├── mfa-enrollment-report.csv                           │  │
│  │  │   ├── access-review-Q1.pdf                                │  │
│  │  │   └── offboarding-records.csv                             │  │
│  │  ├── CC7-system-operations/                                  │  │
│  │  │   ├── monitoring-config.json                              │  │
│  │  │   ├── incident-log.csv                                    │  │
│  │  │   └── alert-rules.json                                    │  │
│  │  ├── CC8-change-management/                                  │  │
│  │  │   ├── pr-approval-sample.csv                              │  │
│  │  │   ├── deployment-log.csv                                  │  │
│  │  │   └── emergency-changes.csv                               │  │
│  │  ├── A-availability/                                         │  │
│  │  │   ├── uptime-report.pdf                                   │  │
│  │  │   ├── backup-test-results.pdf                             │  │
│  │  │   └── dr-test-results.pdf                                 │  │
│  │  ├── C-confidentiality/                                      │  │
│  │  │   ├── data-classification-policy.pdf                      │  │
│  │  │   ├── encryption-config.json                              │  │
│  │  │   └── retention-policy.pdf                                │  │
│  │  └── P-privacy/                                              │  │
│  │      ├── privacy-policy.pdf                                  │  │
│  │      ├── consent-records-sample.csv                          │  │
│  │      └── data-subject-requests.csv                           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  DURING AUDIT:                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  - [ ] Provide auditor access to evidence repository         │  │
│  │  - [ ] Schedule walkthroughs for key controls                │  │
│  │  - [ ] Respond to Information Requests (IRs) within SLA      │  │
│  │  - [ ] Facilitate auditor access to systems (read-only)      │  │
│  │  - [ ] Track auditor questions and responses                 │  │
│  │  - [ ] Address exceptions promptly with remediation plans    │  │
│  │  - [ ] Review draft report for factual accuracy              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  POST-AUDIT:                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  - [ ] Review final report for accuracy                      │  │
│  │  - [ ] Address any management response requirements          │  │
│  │  - [ ] Remediate any identified exceptions                   │  │
│  │  - [ ] Plan for next audit period (continuous improvement)   │  │
│  │  - [ ] Share report with customers (via NDA or trust portal) │  │
│  │  - [ ] Update controls based on lessons learned              │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

### Step 6: SOC 2 Compliance Report

```
┌────────────────────────────────────────────────────────────────────┐
│  SOC 2 READINESS REPORT                                            │
├────────────────────────────────────────────────────────────────────┤
│  Assessment date: <date>                                           │
│  Scope: <systems/services>                                         │
│  Audit type target: Type I / Type II                               │
│  Assessor: <agent/person>                                          │
│                                                                    │
│  TSC CATEGORY SUMMARY:                                             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Category        │ Controls │ Effective │ Gaps │ Ready?      │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  CC: Security     │ <N>      │ <N>       │ <N>  │ YES/NO     │  │
│  │  A: Availability  │ <N>      │ <N>       │ <N>  │ YES/NO     │  │
│  │  PI: Proc. Integ. │ <N>      │ <N>       │ <N>  │ YES/NO     │  │
│  │  C: Confid.       │ <N>      │ <N>       │ <N>  │ YES/NO     │  │
│  │  P: Privacy       │ <N>      │ <N>       │ <N>  │ YES/NO     │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  Total            │ <N>      │ <N>       │ <N>  │            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  EVIDENCE READINESS:                                               │
│    Evidence artifacts collected: <N> of <N> required               │
│    Automated collection rate: <N>%                                 │
│    Evidence gaps: <N> (list follows)                               │
│                                                                    │
│  CONTINUOUS MONITORING:                                            │
│    Infrastructure monitoring: ACTIVE / PARTIAL / NONE              │
│    Security monitoring: ACTIVE / PARTIAL / NONE                    │
│    Compliance monitoring: ACTIVE / PARTIAL / NONE                  │
│    Alert response SLA met: <N>%                                    │
│                                                                    │
│  CONTROL TESTING:                                                  │
│    Controls tested: <N> of <N>                                     │
│    Effective: <N>                                                   │
│    Ineffective: <N> (requiring remediation)                        │
│    Not tested: <N>                                                  │
│                                                                    │
│  FINDINGS:                                                         │
│    CRITICAL: <N> (audit blocker)                                   │
│    HIGH:     <N> (likely auditor exception)                        │
│    MEDIUM:   <N> (should fix before audit)                         │
│    LOW:      <N> (best practice improvement)                       │
│                                                                    │
│  ESTIMATED AUDIT READINESS: <N>%                                   │
│  Verdict: READY / CONDITIONAL / NOT READY                          │
├────────────────────────────────────────────────────────────────────┤
│  MUST FIX (audit blockers):                                        │
│  1. <finding with TSC criterion reference>                         │
│  2. <finding with TSC criterion reference>                         │
│                                                                    │
│  SHOULD FIX (before audit):                                        │
│  3. <finding>                                                      │
│  4. <finding>                                                      │
│                                                                    │
│  TIMELINE TO AUDIT READINESS:                                      │
│  - Remediation needed: <N> weeks                                   │
│  - Type II observation period: <3-12> months                       │
│  - Earliest audit start: <date>                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Step 7: Commit and Transition
1. Save report as `docs/compliance/<date>-soc2-assessment.md`
2. Commit: `"soc2: <scope> — <verdict> (<N> controls assessed, <N>% effective)"`
3. If NOT READY: "SOC 2 gaps identified. Run `/godmode:fix` to remediate, then re-assess with `/godmode:soc2`."
4. If READY: "SOC 2 readiness confirmed. Proceed with audit firm engagement."

## Key Behaviors

1. **Criterion-level precision.** Every finding must reference the specific Trust Service Criterion it addresses (e.g., "CC6.1 — Logical access" not just "access control"). Map to the AICPA TSC numbering.
2. **Evidence is everything.** SOC 2 is an evidence-based audit. A control that exists but cannot be demonstrated with evidence is a control that does not exist to the auditor. Every control needs documented proof.
3. **Type II requires operating history.** Type I evaluates design. Type II evaluates operation over time (minimum 3 months, typically 6-12 months). Controls must be operating consistently throughout the audit period.
4. **Automated evidence wins.** Manually collected evidence is expensive and error-prone. Automate evidence collection for every control that can be automated. Auditors prefer system-generated evidence.
5. **Controls must be tested.** "We have a control" is not enough. Controls must be tested for effectiveness using inquiry, observation, inspection, or reperformance. Document the test and result.
6. **Subservice organizations matter.** If you use AWS, Stripe, or other services that handle customer data, they are subservice organizations. Their SOC 2 reports must be obtained and their controls evaluated.
7. **Continuous monitoring beats periodic review.** Auditors and customers increasingly expect continuous compliance, not point-in-time snapshots. Build monitoring that catches control failures in real time.
8. **Change management is the most-tested control.** More SOC 2 exceptions come from change management failures than any other area. Ensure every production change has documented approval, testing, and deployment records.

## Example Usage

### Full SOC 2 readiness assessment
```
User: /godmode:soc2 We need SOC 2 Type II, customer is asking for it

SOC 2: Starting comprehensive SOC 2 readiness assessment...

Step 1: Trust Service Criteria Assessment
  Evaluating 5 categories, 64 criteria...

  CC (Security): 25 of 33 criteria met
    CRITICAL (CC6.3): No offboarding process — departed employee still has access
    HIGH (CC8.1): 12% of production changes deployed without PR approval
    HIGH (CC7.1): No SIEM or security event monitoring

  A (Availability): 5 of 8 criteria met
    HIGH (A1.3): DR plan exists but never tested
    MEDIUM (A1.1): No auto-scaling configured

  PI (Processing Integrity): 4 of 6 met — good
  C (Confidentiality): 5 of 7 met
    MEDIUM (C1.2): No automated data retention enforcement
  P (Privacy): 7 of 10 met

Step 2: Evidence Collection
  42 of 64 evidence artifacts available
  18 can be automated, 4 need manual collection
  Setting up automated evidence collection...

Overall readiness: 72%
Estimated time to audit-ready: 8-10 weeks
```

### Evidence collection setup
```
User: /godmode:soc2 --evidence Automate our evidence collection

SOC 2: Building evidence collection automation...

Automated evidence scripts created:
  1. IAM: Weekly user+role export from Auth0
  2. Change mgmt: PR approval audit from GitHub API
  3. Deployments: CI/CD history from GitHub Actions
  4. Uptime: Monthly availability report from Datadog
  5. Vulnerabilities: Weekly scan export from Snyk
  6. Encryption: Monthly config verification from AWS
  7. Backups: Daily backup status from AWS Backup
  8. Access reviews: Quarterly user access diff report

Evidence repository structure created at evidence/
Collection scheduled via cron/GitHub Actions
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full SOC 2 readiness assessment (all TSC categories) |
| `--security` | Security (Common Criteria) assessment only |
| `--availability` | Availability criteria assessment only |
| `--integrity` | Processing Integrity criteria assessment only |
| `--confidentiality` | Confidentiality criteria assessment only |
| `--privacy` | Privacy criteria assessment only |
| `--evidence` | Evidence collection automation setup |
| `--controls` | Control implementation and testing |
| `--monitoring` | Continuous monitoring setup |
| `--audit-prep` | Audit preparation workflow |
| `--report` | Generate report from last assessment |
| `--quick` | Top gaps only, skip exhaustive criteria review |

## Anti-Patterns

- **Do NOT treat SOC 2 as a one-time project.** SOC 2 Type II requires continuous compliance over the audit period. Building controls the week before the audit starts means you have no operating history.
- **Do NOT skip evidence for "obvious" controls.** "Of course we encrypt data" is not evidence. Export the encryption configuration, screenshot the settings, log the verification. If you cannot prove it, it does not exist.
- **Do NOT confuse policies with controls.** Having a security policy document is CC1/CC5 compliance. Actually enforcing the policy with technical controls is CC6/CC7 compliance. You need both.
- **Do NOT ignore change management.** It is the single most common source of SOC 2 exceptions. Every production change needs approval, testing, and deployment records. No exceptions.
- **Do NOT assume your cloud provider's SOC 2 covers you.** AWS having a SOC 2 covers their infrastructure controls. Your application-layer controls, your access management, your change management are all your responsibility.
- **Do NOT wait until audit time to collect evidence.** Collect evidence continuously. An auditor asking for "all access review records for Q2" should be answered with a pre-organized folder, not a scramble.
- **Do NOT over-scope.** Include only the systems that handle customer data. Adding unnecessary systems increases audit cost and control burden without benefit.
- **Do NOT provide legal or audit advice.** This skill identifies technical compliance gaps and provides implementation guidance. For audit strategy and report interpretation, recommend consulting a qualified CPA firm.
