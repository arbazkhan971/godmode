# /godmode:secure

Security audit using STRIDE threat modeling, OWASP Top 10 checklist, and 4 red-team adversarial personas. Every finding includes code evidence, severity rating, and concrete remediation.

## Usage

```
/godmode:secure                         # Full security audit
/godmode:secure --quick                 # OWASP Top 10 only
/godmode:secure --stride                # STRIDE analysis only
/godmode:secure --owasp                 # OWASP checklist only
/godmode:secure --red-team              # Red team simulation only
/godmode:secure --deps                  # Dependency vulnerability scan only
/godmode:secure --fix                   # Auto-fix findings after audit
```

## What It Does

1. Defines audit scope (auth, input handling, data storage, external APIs, secrets)
2. Runs STRIDE analysis (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation)
3. Checks OWASP Top 10 (2021) — each item with PASS/FAIL/N/A
4. Simulates 4 red-team personas:
   - **Script Kiddie** — automated tools and known exploits
   - **Insider Threat** — authenticated privilege escalation
   - **Sophisticated Attacker** — business logic and chained vulnerabilities
   - **Data Harvester** — data exfiltration and privacy violations
5. Produces findings with severity (CRITICAL/HIGH/MEDIUM/LOW/INFO) and code evidence
6. Generates remediation code for each finding

## Output
- Security report at `docs/security/<feature>-security-audit.md`
- Commit: `"secure: <feature> — <verdict> (<N> findings)"`
- Verdict: PASS / CONDITIONAL PASS / FAIL

## Next Step
If FAIL: `/godmode:fix` to remediate, then re-audit.
If PASS: `/godmode:ship` to deploy.

## Examples

```
/godmode:secure                         # Full audit of current code
/godmode:secure --deps                  # Just check dependencies
/godmode:secure --quick                 # Quick OWASP scan
/godmode:secure --fix                   # Audit then auto-fix
```
