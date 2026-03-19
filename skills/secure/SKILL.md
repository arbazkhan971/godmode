---
name: secure
description: |
  Security audit. STRIDE threat model + OWASP Top 10 + 4 red-team personas. Every finding has code evidence.
---

# Secure — Security Audit

## Activate When
- `/godmode:secure`, "security audit", "vulnerabilities", "harden"
- Pre-ship check

## Workflow

### 1. Recon
Scan tech stack, deps, configs, API routes, auth patterns, secrets/env files.

### 2. Asset Map
Catalog: data stores, auth systems, external services, user inputs, API endpoints.

### 3. Trust Boundaries
Map: browser↔server, public↔authenticated, user↔admin, service↔service, CI↔prod.

### 4. STRIDE Threat Model
For each trust boundary evaluate: Spoofing, Tampering, Repudiation, Info Disclosure, Denial of Service, Elevation of Privilege.

### 5. Iterate — The Loop

```
categories = OWASP_TOP_10 + STRIDE  # 16 total
current_iteration = 0

WHILE untested categories remain:
    current_iteration += 1
    Pick next category (Critical-severity first).
    Test with 4 personas: External Attacker, Insider, Supply Chain, Infra.
    For each finding: file:line + attack scenario + severity + remediation.
    Log to .godmode/security-findings.tsv.

    IF current_iteration % 5 == 0:
        Print "{tested}/10 OWASP, {findings} findings"
```

### 6. Report
Print: OWASP coverage (N/10), STRIDE coverage (N/6), findings by severity, verdict (PASS if 0 critical + 0 high, else FAIL).

### 7. Auto-Fix (if `--fix`)
For each Critical/High: apply fix → commit → run tests → if tests break → revert → next.

## Rules

1. **Every finding needs code evidence.** File:line + attack scenario. No theoretical fluff.
2. **Test all OWASP Top 10 categories.** Track coverage, target 100%.
3. **4 adversarial personas.** External, insider, supply chain, infrastructure.
4. **Critical/High first.** Don't waste time on info-level when auth is broken.
5. **Never approve code with Critical findings.**
6. **Log everything to TSV.**
