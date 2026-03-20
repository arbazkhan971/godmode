---
name: secure
description: Security audit. STRIDE + OWASP + 4 red-team personas. Code evidence required.
---

## Activate When
- `/godmode:secure`, "security audit", "vulnerabilities", "harden"

## Workflow
1. **Recon** — `npm audit`/`pip audit`/`cargo audit` for CVEs, `grep -rn 'SECRET\|API_KEY\|PASSWORD'` for secrets, scan routes.
2. **Asset Map** — Catalog data stores, auth systems, external services, user inputs, endpoints.
3. **Trust Boundaries** — browser↔server, public↔auth, user↔admin, service↔service, CI↔prod.
4. **STRIDE** — For each boundary: Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation.
5. **Iterate:**
```
categories = OWASP_TOP_10 + STRIDE  # 16 total
current_iteration = 0
WHILE untested categories remain:
    current_iteration += 1
    Pick next untested category. Order: Injection, Auth, XSS, SSRF, then remaining.
    Test as 4 personas: External (no auth), Insider (valid session), Supply Chain (malicious dep), Infra (server access).
    Each finding: file:line + exploit steps + severity (Critical/High/Med/Low) + fix (code snippet).
    Log to .godmode/security-findings.tsv: iteration, category, persona, finding, severity, file:line, status(open/fixed).
    Every 5 iters: print "{tested}/10 OWASP, {findings} findings"
```
6. **Report** — Coverage: OWASP {N}/10, STRIDE {N}/6. Findings: {critical} critical, {high} high. Verdict: PASS/FAIL.
7. **Auto-Fix** (if `--fix`) — For Critical/High: fix → commit → run full test suite → revert if ANY test breaks.

## Rules
1. Every finding: file:line + exploit steps (reproducible). No theoretical risks.
2. All OWASP Top 10. 4 personas per category. Test real payloads, not just descriptions. Critical/High first.
3. Never approve with Critical findings. Critical+High count printed in final verdict.
