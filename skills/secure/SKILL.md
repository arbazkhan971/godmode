---
name: secure
description: Security audit. STRIDE + OWASP + 4 red-team personas. Code evidence required.
---

## Activate When
- `/godmode:secure`, "security audit", "vulnerabilities", "harden"

## Workflow
1. **Recon** — Scan: package.json/deps for CVEs, .env/.config for secrets, routes for exposed endpoints.
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
    Test as 4 personas: External (no auth), Insider (valid session), Supply Chain (malicious dep), Infra (server access).
    Each finding: file:line + exploit steps + severity (Critical/High/Med/Low) + fix (code snippet).
    Log to .godmode/security-findings.tsv.
    Every 5 iters: print "{tested}/10 OWASP, {findings} findings"
```
6. **Report** — OWASP (N/10), STRIDE (N/6), findings by severity, verdict (PASS if 0 critical+high).
7. **Auto-Fix** (if `--fix`) — For Critical/High: fix → commit → test → revert if broken.

## Rules
1. Every finding: file:line + attack scenario. No theory.
2. All OWASP Top 10. 4 personas per category. Critical/High first.
3. Never approve with Critical findings.
