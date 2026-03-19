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
```bash
# Scan tech stack, deps, configs, API routes, auth patterns
git ls-files | head -100
cat package.json pyproject.toml Cargo.toml 2>/dev/null
find . -name "*.env*" -o -name "*secret*" -o -name "*config*" 2>/dev/null
```

### 2. Asset Map
Catalog: data stores, auth systems, external services, user inputs, API endpoints.

### 3. Trust Boundaries
Map: browser↔server, public↔authenticated, user↔admin, service↔service, CI↔prod.

### 4. STRIDE Threat Model

For each trust boundary, evaluate:
- **S**poofing — can identity be faked?
- **T**ampering — can data be modified in transit/storage?
- **R**epudiation — can actions be denied without audit trail?
- **I**nfo Disclosure — can sensitive data leak?
- **D**enial of Service — can the system be overwhelmed?
- **E**levation — can low-privilege users gain higher access?

### 5. Iterate — The Loop

```
current_iteration = 0
categories = OWASP_TOP_10 + STRIDE_CATEGORIES  # 16 total

WHILE untested categories remain:
    current_iteration += 1

    # Pick next category (Critical-severity first)
    # Test with 4 personas: External Attacker, Insider, Supply Chain, Infra
    # For each finding: file:line + attack scenario + severity + remediation
    # Log to .godmode/security-findings.tsv

    IF current_iteration % 5 == 0:
        Print OWASP coverage: "{tested}/10 categories, {findings} findings"
```

### 6. Report

```
SECURITY AUDIT COMPLETE
OWASP Coverage: {N}/10
STRIDE Coverage: {N}/6
Findings: {critical} critical, {high} high, {medium} medium, {low} low
Verdict: PASS (0 critical, 0 high) | FAIL
```

### 7. Auto-Fix (if `--fix`)

For each Critical/High finding:
```
Apply fix → commit → run tests → if tests break → revert → next
```

## Rules

1. **Every finding needs code evidence.** File:line + attack scenario. No theoretical fluff.
2. **Test all OWASP Top 10 categories.** Track coverage, target 100%.
3. **4 adversarial personas.** Not just "a hacker" — external, insider, supply chain, infrastructure.
4. **Severity matters.** Critical/High first. Don't waste time on info-level when auth is broken.
5. **Never approve code with Critical findings.**
6. **Log everything to TSV.**
