# /godmode:gdpr

Deep GDPR compliance implementation covering data mapping, consent management, right to deletion, data portability, privacy impact assessments, DPO notification procedures, and cross-border data transfer mechanisms. Produces implementable schemas, APIs, and operational procedures for every GDPR requirement.

## Usage

```
/godmode:gdpr                                   # Full GDPR assessment
/godmode:gdpr --map                             # Data mapping and classification
/godmode:gdpr --consent                         # Consent management implementation
/godmode:gdpr --erasure                         # Right to deletion workflow
/godmode:gdpr --portability                     # Data portability export
/godmode:gdpr --dpia                            # Privacy Impact Assessment
/godmode:gdpr --breach                          # Breach notification procedures
/godmode:gdpr --transfer                        # Cross-border data transfer assessment
/godmode:gdpr --dpo                             # DPO notification procedures
```

## What It Does

1. Maps all personal data across the codebase (identity, financial, behavioral, special categories)
2. Builds Article 30 processing activity register with lawful basis for each activity
3. Designs consent management system (database schema, API endpoints, enforcement middleware)
4. Implements Article 17 erasure workflows with cascading deletion across all systems
5. Creates Article 20 data portability export API with machine-readable output
6. Produces Article 35 DPIA templates with risk identification and mitigation
7. Documents breach notification procedures with 72-hour authority timeline
8. Assesses cross-border transfers with SCC modules and Transfer Impact Assessments

## Output
- GDPR assessment report at `docs/compliance/<date>-gdpr-assessment.md`
- Commit: `"gdpr: <scope> — <verdict> (<N> findings, <N> articles assessed)"`
- Verdict: COMPLIANT / PARTIAL / NON-COMPLIANT

## Next Step
If NON-COMPLIANT: `/godmode:fix` to remediate, then re-assess.
If COMPLIANT: `/godmode:ship` to deploy to EU/EEA markets.

## Examples

```
/godmode:gdpr                                   # Full GDPR assessment
/godmode:gdpr --consent                         # Fix cookie consent implementation
/godmode:gdpr --erasure --portability           # Implement data subject rights endpoints
/godmode:gdpr --transfer                        # Assess cross-border data transfers
/godmode:gdpr --dpia                            # Conduct Privacy Impact Assessment
/godmode:gdpr --quick                           # Top findings only
```
