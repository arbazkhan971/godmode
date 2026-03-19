---
name: secure
description: Security audit. STRIDE + OWASP + 4 red-team personas. Code evidence required.
---

# Secure — Security Audit

## Activate When
- `/godmode:secure`, "security audit", "vulnerabilities", "harden"

## Workflow
1. **Recon** — Scan tech stack, deps, configs, API routes, auth, secrets.
2. **Asset Map** — Catalog data stores, auth systems, external services, user inputs, endpoints.
3. **Trust Boundaries** — browser↔server, public↔auth, user↔admin, service↔service, CI↔prod.
4. **STRIDE** — For each boundary: Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation.
5. **Iterate:**
```
categories = OWASP_TOP_10 + STRIDE  # 16 total
current_iteration = 0
WHILE untested categories remain:
    current_iteration += 1
    Pick next category (Critical first).
    Test with 4 personas: External Attacker, Insider, Supply Chain, Infra.
    Each finding: file:line + attack scenario + severity + remediation.
    Log to .godmode/security-findings.tsv.
    Every 5 iters: print "{tested}/10 OWASP, {findings} findings"
```
6. **Report** — OWASP (N/10), STRIDE (N/6), findings by severity, verdict (PASS if 0 critical+high).
7. **Auto-Fix** (if `--fix`) — For Critical/High: fix → commit → test → revert if broken.

## Rules
1. Every finding: file:line + attack scenario. No theory.
2. All OWASP Top 10. Track coverage.
3. 4 personas per category.
4. Critical/High first.
5. Never approve with Critical findings.
6. Log to TSV.
