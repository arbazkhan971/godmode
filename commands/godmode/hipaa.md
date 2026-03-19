# /godmode:hipaa

Deep HIPAA compliance implementation covering PHI identification and classification, encryption requirements (at rest and in transit), access control and audit logging, BAA technical requirements, breach notification procedures, and de-identification methods. Produces implementable schemas, encryption configurations, access control policies, and operational procedures for every HIPAA safeguard.

## Usage

```
/godmode:hipaa                                  # Full HIPAA assessment
/godmode:hipaa --phi                            # PHI identification and classification
/godmode:hipaa --encryption                     # Encryption assessment (at rest and in transit)
/godmode:hipaa --access                         # Access control and minimum necessary review
/godmode:hipaa --audit                          # Audit logging assessment
/godmode:hipaa --baa                            # Business Associate Agreement inventory
/godmode:hipaa --breach                         # Breach notification procedures
/godmode:hipaa --deidentify                     # De-identification methods review
```

## What It Does

1. Identifies all 18 HIPAA identifiers across the codebase and classifies PHI by category and risk level
2. Assesses encryption at rest (AES-256, TDE, field-level) and in transit (TLS 1.2+, mTLS) with key management review
3. Evaluates access controls against minimum necessary standard with role-based PHI access matrices
4. Reviews audit logging for completeness, immutability, 6-year retention, and tamper evidence
5. Inventories Business Associate Agreements and verifies technical compliance of all PHI-handling vendors
6. Documents breach notification procedures with 60-day timeline and 4-factor risk assessment
7. Implements HIPAA-compliant de-identification using Safe Harbor (18 identifiers) or Expert Determination methods

## Output
- HIPAA assessment report at `docs/compliance/<date>-hipaa-assessment.md`
- Commit: `"hipaa: <scope> — <verdict> (<N> findings, <N> safeguards assessed)"`
- Verdict: COMPLIANT / PARTIAL / NON-COMPLIANT

## Next Step
If NON-COMPLIANT: `/godmode:fix` to remediate, then re-assess.
If COMPLIANT: `/godmode:ship` to deploy.

## Examples

```
/godmode:hipaa                                  # Full HIPAA assessment
/godmode:hipaa --phi                            # Scan for PHI in codebase
/godmode:hipaa --encryption                     # Encryption gap analysis
/godmode:hipaa --baa                            # BAA inventory and review
/godmode:hipaa --access --audit                 # Access control + audit logging
/godmode:hipaa --quick                          # Top findings only
```
