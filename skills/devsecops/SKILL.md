---
name: devsecops
description: |
 DevSecOps pipeline skill. Activates when user needs to integrate security into CI/CD pipelines, configure static analysis (SAST), dynamic analysis (DAST), software composition analysis (SCA), container scanning, secret scanning, or establish security gates in deployment workflows. Supports Semgrep, CodeQL, SonarQube, OWASP ZAP, Burp Suite, Trivy, Snyk, and other industry-standard tools. Produces pipeline configurations, security gate definitions, and remediation workflows. Triggers on: /godmode:devsecops, "secure pipeline", "add SAST", "security gate", "container scan", "shift left", or when building CI/CD that needs security controls.
---

# DevSecOps — Secure Pipeline Integration

## When to Activate
- User invokes `/godmode:devsecops`
- User says "secure pipeline", "add SAST", "security scanning", "shift left"
- User says "container scan", "dependency scan", "secret scanning in CI"
- User says "security gate", "block deploys on vulnerabilities"
- Building CI/CD pipelines that handle sensitive code or data
- After `/godmode:pentest` reveals issues to catch automatically
- When `/godmode:cicd` needs security controls integrated
- Compliance requires automated security testing (SOC2, PCI-DSS, HIPAA)

## Workflow

### Step 1: Pipeline Security Assessment
Evaluate the current CI/CD pipeline security posture:

```
PIPELINE SECURITY ASSESSMENT:
  CI/CD Platform: <GitHub Actions | GitLab CI | Jenkins |
  CircleCI | Azure DevOps | Bitbucket>
  Source control: <GitHub | GitLab | Bitbucket | Azure Repos>
  Artifact registry: <Docker Hub | ECR | GCR | ACR | GHCR>
  Deployment target: <K8s | ECS | Lambda | VMs | PaaS>
  CURRENT SECURITY CONTROLS:
  ┌────────────────────┬──────────┬───────────────────────┐
|  | Control | Status | Tool |  |
  ├────────────────────┼──────────┼───────────────────────┤
|  | SAST | YES/NO | <tool or none> |  |
|  | DAST | YES/NO | <tool or none> |  |
  ...
```
### Step 2: SAST Integration (Static Application Security Testing)
Configure static code analysis for security vulnerabilities.

All security workflows share a common trigger (adjust per org policy):
```yaml
# Common trigger pattern for all security scanning workflows
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
```

#### Semgrep
```yaml
#.github/workflows/sast-semgrep.yml
name: SAST — Semgrep
# trigger: on pull_request + push to main (see common trigger pattern)
```

```
SEMGREP CONFIGURATION:
Rulesets:
 - auto (Semgrep-curated rules for detected languages)
 - p/owasp-top-ten (OWASP Top 10 coverage)
 - p/cwe-top-25 (CWE Top 25 most dangerous weaknesses)
 - p/security-audit (broad security patterns)
 - p/<language>-security (language-specific rules)

Custom rules directory:.semgrep/
 Create custom rules for project-specific patterns:
 - Banned functions (eval, exec, unsafe APIs)
 - Required patterns (input validation on routes)
  ...
```
#### CodeQL
```yaml
#.github/workflows/sast-codeql.yml
name: SAST — CodeQL
# trigger: same as Semgrep (PR + push to main)
```

```
CODEQL CONFIGURATION:
Query suites:
 - security-extended: Known vulnerability patterns + extended coverage
 - security-and-quality: Security + code quality issues
 - Custom query packs for organization-specific rules

Advantages over pattern-matching:
 - Data flow analysis (tracks tainted input through function calls)
 - Control flow analysis (understands branching and conditions)
 - Type-aware analysis (understands object types and inheritance)
 - Inter-procedural analysis (follows data across function boundaries)

  ...
```
### Step 3: DAST Integration (Dynamic Application Security Testing)
Configure runtime security testing against running applications:

#### OWASP ZAP
```yaml
#.github/workflows/dast-zap.yml
name: DAST — OWASP ZAP
# uses common trigger above (add workflow_dispatch for manual full scans)
```

```
ZAP CONFIGURATION:
Scan types:
 Baseline scan: Passive scanning + spider (fast, every PR)
 Full scan: Active scanning + fuzzing (slow, scheduled/manual)
 API scan: OpenAPI/Swagger spec-driven testing

Rules file (.zap/rules.tsv):
 10016 WARN (Web Browser XSS Protection Not Enabled)
 10017 WARN (Cross-Domain JavaScript Source File Inclusion)
 10021 FAIL (X-Content-Type-Options Header Missing)
 10038 FAIL (Content Security Policy Header Not Set)
 40012 FAIL (Cross Site Scripting - Reflected)
  ...
```
### Step 4: SCA (Software Composition Analysis)
Scan dependencies for known vulnerabilities and license issues:

```yaml
#.github/workflows/sca.yml
name: SCA — Dependency Security
# trigger: PR + push to main
```
```
SCA CONFIGURATION:
  Dependency Scanning Strategy
| Tool | Purpose | When |
|--|--|--|
| Dependabot/Renovate | Auto-update PRs | Daily |
| Snyk | Deep vuln analysis | Every PR + daily |
| npm/pip/cargo audit | Native scanning | Every PR |
| SBOM generator | Supply chain | Every release |
| License checker | Compliance | Every PR |
  SEVERITY POLICY:
  CRITICAL: Block merge + alert security team immediately
  HIGH: Block merge + create ticket
```
### Step 5: Container Scanning
Scan container images for vulnerabilities:

#### Trivy
```yaml
#.github/workflows/container-scan-trivy.yml
name: Container Scan — Trivy
# trigger: push to main (scan built images)
```

```
TRIVY SCAN TYPES:
 image: Scan container images for OS and library vulnerabilities
 fs: Scan filesystem for vulnerabilities in lockfiles
 config: Scan IaC files (Dockerfile, Kubernetes YAML, Terraform)
 repo: Scan git repository
 sbom: Generate and scan SBOM

CONTAINER HARDENING CHECKS:
 - [ ] Base image uses minimal distro (alpine, distroless, scratch)
 - [ ] Base image tag is pinned (not :latest)
 - [ ] Multi-stage build (build deps not in final image)
 - [ ] Non-root user (USER directive in Dockerfile)
  ...
```
### Step 6: Secret Scanning in CI/CD
Prevent secrets from reaching the repository:

```yaml
#.github/workflows/secret-scan.yml
name: Secret Scanning
# trigger: on all PRs and pushes (catch secrets before merge)
```
```
SECRET SCANNING LAYERS:
| Layer | Tool | When |
|--|--|--|
| Pre-commit (local) | gitleaks hook | Before every commit |
| PR check (CI) | gitleaks action | Every pull request |
| Push protection | GitHub/GitLab | Every push |
| Scheduled scan | trufflehog | Daily full scan |
| Runtime detection | detect-secrets | Baseline tracking |
  CUSTOM PATTERNS:
  .gitleaks.toml:
  [[rules]]
  id = "internal-api-key"
  ...
```
### Step 7: Security Gates in Deployment Pipelines
Define blocking security checks that prevent insecure deployments:

```
SECURITY GATE CONFIGURATION:
| Gate | Stage | Action | Override |
|--|--|--|--|
| SAST findings | PR check | BLOCK | Security team |
| SCA critical CVE | PR check | BLOCK | Security team |
| Secret detected | PR check | BLOCK | No override |
| DAST high vuln | Pre-deploy | BLOCK | Security team |
| Container CVE | Pre-deploy | BLOCK | Security team |
| SBOM missing | Pre-deploy | BLOCK | Release eng |
| License violation | PR check | WARN | Legal team |
| IaC misconfig | PR check | BLOCK | Platform team |
| Unsigned artifact | Pre-deploy | BLOCK | No override |
  ...
```
### Step 8: Infrastructure as Code (IaC) Security
Scan infrastructure definitions for misconfigurations:

```
IAC SECURITY CHECKS:
| Category | Examples |
|--|--|
| Cloud misconfig | Public S3 buckets, open SGs |
| Kubernetes security | Privileged containers, no limits |
| Docker hardening | Root user, missing healthcheck |
| Terraform state | Remote state with encryption |
| Network exposure | 0.0.0.0/0 ingress rules |
| Encryption | Unencrypted storage/databases |
| Logging | Missing audit trails |
| IAM | Overly permissive policies |
```
SECURITY METRICS DASHBOARD:
  SECURITY POSTURE — <project>
  Open vulnerabilities:
  CRITICAL: <N> (SLA: 24h) Overdue: <N>
  HIGH: <N> (SLA: 7d) Overdue: <N>
  MEDIUM: <N> (SLA: 30d) Overdue: <N>
  LOW: <N> (SLA: 90d) Overdue: <N>
  Pipeline security:
  PRs blocked by security gate: <N> this week
  Average fix time (CRITICAL): <hours>
  Average fix time (HIGH): <days>
  Security gate override rate: <N>%
  Dependency health:
  Total dependencies: <N>
  With known vulnerabilities: <N>
  Outdated (>1 major version): <N>
  License violations: <N>
  Container health:
  Images in production: <N>
  With CRITICAL CVEs: <N>
  Using :latest tag: <N> (target 0)
  Non-root containers: <N>/<N>
  Trend: IMPROVING | STABLE | DEGRADING
```

### Step 10: Commit and Transition
```
1. Save pipeline configs to `.github/workflows/` or equivalent CI directory
2. Save security gate config to `security/pipeline-policy.yml`
3. Commit: "devsecops: <description> — <N> security controls, maturity level <N>"
4. If gaps remain: "Pipeline security gaps identified. Address <specific gaps> to reach target maturity level."
5. If fully configured: "DevSecOps pipeline complete. Security gates active. Run `/godmode:pentest` to validate or `/godmode:ship` to deploy."
```

## Key Behaviors

1. **Shift left, not shift burden.** Keep CI security scanning fast enough that developers do not skip it. Baseline scans in PRs, full scans on schedule.
2. **Block on critical, warn on the rest.** Only CRITICAL and HIGH severity findings should block merges. Medium and low get tracked but do not stop velocity.
3. **No secrets pass the gate.** Secret scanning has zero exceptions. A leaked secret is an incident, not a finding to triage.
4. **SBOM is a requirement, not optional.** Every release must have a Software Bill of Materials. This is increasingly a legal requirement, not just a best practice.
5. **Scan at every layer.** Source code (SAST), dependencies (SCA), running app (DAST), containers (Trivy), infrastructure (Checkov), secrets (gitleaks). Vulnerabilities hide at every layer.
## HARD RULES

- NEVER allow secrets to pass the security gate — secret scanning has ZERO exceptions and NO override process
- NEVER use `:latest` for scanner images in CI — pin scanner versions to prevent silent policy changes
- NEVER scan only on main branch — CATCH security issues in PRs before merge
- NEVER deploy unsigned container images to production — sign with cosign/notation and verify before deploy
- NEVER store scanner tokens as plain environment variables — use CI/CD secret management
- ALL CRITICAL/HIGH severity findings MUST block merge (no silent pass-through)
- ALL security gate overrides MUST have documented justification, an expiry date (max 30 days), and a reviewing team
- ALL releases MUST include an SBOM in SPDX or CycloneDX format
SAST INTEGRATION VALIDATION:
  ...
```

## Keep/Discard Discipline

```
FOR each security scanner finding:
 KEEP if:
 - True positive confirmed by manual review or verified by second scanner
 - Affects production code path (not dead code, not test-only)
 - Severity warrants action per pipeline policy (CRITICAL/HIGH always kept)
 DISCARD if:
 - False positive confirmed (manual review + documented justification)
 - Already covered by existing exception with valid expiry date
 - In allowlisted path/pattern with documented reason
 EXCEPTION process for MEDIUM/LOW findings:
 - File exception with: CVE/rule ID, justification, expiry (max 30 days), reviewer
 - Track in.godmode/devsecops-exceptions.tsv:
  ...
```
## Stop Conditions
- All controls for the target maturity level are ACTIVE (not only configured).
- CRITICAL and HIGH severity findings block merge (verified with a test PR).
- Secret scanning active on pre-commit, CI, and push protection (3 layers minimum).
- Scanner versions pinned, tokens stored in CI/CD secret management.
- SBOM generated for every release in SPDX or CycloneDX format.

## Auto-Detection

```
1. Check CI/CD platform:
 - Scan for.github/workflows/ → GitHub Actions
 - Scan for.gitlab-ci.yml → GitLab CI
 - Scan for Jenkinsfile → Jenkins
 - Scan for azure-pipelines.yml → Azure DevOps
2. Check existing security controls:
 - Scan workflows for semgrep, codeql, sonar, snyk, trivy, gitleaks, trufflehog, checkov, tfsec
 - Check for.gitleaks.toml,.semgrep/, sonar-project.properties
 - Check for cosign, notation references (artifact signing)
 - Check for dependabot.yml or renovate.json (dependency updates)
3. Check for container and IaC:
 - Scan for Dockerfile*, docker-compose*, kubernetes/, terraform/, cloudformation/
  ...
```
## Output Format

Every devsecops invocation must produce a structured report:

```
  DEVSECOPS RESULT
  CI platform: <GitHub Actions | GitLab CI | Jenkins | etc.>
  Controls configured: <N> / 11
  Security gates: <N blocking, N advisory>
  Maturity level: <0-5> (before -> after)
  Open findings: <N>C <N>H <N>M <N>L
  Verdict: <PIPELINE SECURE | GAPS REMAIN | NOT CONFIGURED>
```
## TSV Logging

Log every pipeline security assessment to `.godmode/devsecops-audit.tsv`:

```
timestamp	ci_platform	controls_configured	controls_total	maturity_before	maturity_after	blocking_gates	open_critical	open_high	verdict
```
Append one row per invocation. Never overwrite previous rows.

## Success Criteria

```
PASS (Maturity Level 3+) if ALL of the following:
 - SAST configured and running on every PR (Semgrep or CodeQL)
 - SCA configured with severity thresholds (CRITICAL/HIGH block merge)
 - Secret scanning active on pre-commit, CI, and push protection (3 layers)
 - Container scanning active for all Dockerfile changes (Trivy or Snyk)
 - Security gates block merge for CRITICAL and HIGH findings
 - SBOM generated for every release in SPDX or CycloneDX format
 - Scanner versions are pinned (not :latest)
 - Scanner tokens stored in CI/CD secret management (not plain env vars)

PASS (Maturity Level 5) additionally requires:
 - DAST running against staging on every deploy
  ...
```
## Error Recovery
| Failure | Action |
|--|--|
| Scanner times out in CI | Pin scanner version, reduce scan scope to changed files only on PRs. Full scan on weekly schedule. Increase CI timeout for security jobs. |
| False positives blocking PRs | Add to `.semgrepignore` or inline `# nosec` with justification comment. Never blanket-suppress a rule — suppress per-line only. |
| Secret detected in git history | Rotate the secret immediately. Use `git filter-repo` or BFG to remove from history. Enable push protection to prevent recurrence. |
| Container scan finds OS-level CVE | Rebuild image from latest base. If no fix available, document accepted risk with expiry date and monitor for upstream patch. |
