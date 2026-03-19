# /godmode:comply

Compliance and governance auditing against GDPR, HIPAA, SOC2, PCI-DSS, and other regulatory frameworks. Examines actual code and data flows, produces findings with regulation references and concrete remediation, and audits license compliance across dependencies.

## Usage

```
/godmode:comply                                  # Full compliance audit
/godmode:comply --gdpr                           # GDPR compliance check
/godmode:comply --hipaa                          # HIPAA compliance check
/godmode:comply --soc2                           # SOC2 compliance check
/godmode:comply --pci                            # PCI-DSS compliance check
/godmode:comply --audit-trail                    # Audit trail validation
/godmode:comply --retention                      # Data retention policy review
/godmode:comply --licenses                       # License compliance scan
/godmode:comply --privacy                        # Privacy-focused review
```

## What It Does

1. Defines compliance scope (applicable regulations, data classification, data flows)
2. Runs regulation-specific checks:
   - **GDPR**: Lawful basis, data subject rights, consent management
   - **HIPAA**: Administrative, physical, and technical safeguards
   - **SOC2**: Trust services criteria (security, availability, integrity, confidentiality, privacy)
   - **PCI-DSS**: 12 requirements for cardholder data protection
3. Validates audit trail design (event coverage, tamper resistance, retention)
4. Reviews data retention and deletion policies
5. Audits license compliance across all dependencies
6. Produces compliance report with severity-rated findings

## Output
- Compliance report at `docs/compliance/<date>-compliance-audit.md`
- Commit: `"comply: <scope> — <verdict> (<N> findings across <regulations>)"`
- Verdict: COMPLIANT / CONDITIONAL / NON-COMPLIANT

## Next Step
If NON-COMPLIANT: `/godmode:fix` to remediate, then re-audit.
If COMPLIANT: `/godmode:ship` to deploy.

## Examples

```
/godmode:comply                                  # Full audit
/godmode:comply --gdpr --privacy                 # GDPR + privacy deep dive
/godmode:comply --licenses                       # License compliance only
/godmode:comply --audit-trail --retention        # Audit trail + data retention
/godmode:comply --quick                          # Top findings only
```
