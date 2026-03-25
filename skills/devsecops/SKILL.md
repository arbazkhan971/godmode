---
name: devsecops
description: |
 DevSecOps pipeline skill. Activates when user needs to integrate security into CI/CD pipelines, configure
 static analysis (SAST), dynamic analysis (DAST), software composition analysis (SCA), container scanning,
 secret scanning, or establish security gates in deployment workflows. Supports Semgrep, CodeQL, SonarQube,
 OWASP ZAP, Burp Suite, Trivy, Snyk, and other industry-standard tools. Produces pipeline configurations,
 security gate definitions, and remediation workflows. Triggers on: /godmode:devsecops, "secure pipeline",
 "add SAST", "security gate", "container scan", "shift left", or when building CI/CD that needs security
 controls.
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
  Open vulnerabilities: CRITICAL <N> (SLA:24h), HIGH <N> (SLA:7d), MEDIUM <N> (SLA:30d), LOW <N> (SLA:90d)
  Pipeline: PRs blocked <N>/week, avg fix time CRITICAL <hours>, HIGH <days>, override rate <N>%
  Dependencies: total <N>, vulnerable <N>, outdated <N>, license violations <N>
  Containers: production <N>, CRITICAL CVEs <N>, :latest tag <N> (target 0), non-root <N>/<N>
  Trend: IMPROVING | STABLE | DEGRADING
```

### Step 10: Commit and Transition
```
1. Save pipeline configs to `.github/workflows/` or equivalent CI directory
2. Save security gate config to `security/pipeline-policy.yml`
3. Commit: "devsecops: <description> — <N> security controls, maturity level <N>"
4. If gaps remain: "Pipeline security gaps identified. Address <specific gaps> to reach target maturity level."
5. If fully configured: "DevSecOps pipeline complete. Security gates active. Run `/godmode:pentest` to
validate or `/godmode:ship` to deploy."
```

## Key Behaviors

```bash
# Run security scans locally
npx semgrep scan --config auto src/
trivy image --severity CRITICAL,HIGH myapp:latest
gitleaks detect --source . --verbose
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

IF CRITICAL findings > 0: block merge, SLA < 24 hours.
WHEN secret detected in git history: rotate immediately, BFG to remove.
IF scanner runtime > 5 minutes in CI: scope to changed files only.

1. **Shift left, not shift burden.** Fast scans developers don't skip.
2. **Block CRITICAL/HIGH, warn the rest.** Don't stop velocity on LOW.
3. **No secrets pass the gate.** Zero exceptions.
4. **SBOM required.** Every release, SPDX or CycloneDX.
5. **Scan every layer.** SAST, SCA, DAST, containers, IaC, secrets.
## Quality Targets
- Critical CVEs: <1 in production deps
- SAST scan time: <5min per PR
- Remediation: >90% within 7 days

## Keep/Discard Discipline
```
KEEP if: true positive, affects production, CRITICAL/HIGH severity
DISCARD if: false positive with justification OR already excepted
Exceptions: max 30 day expiry, documented, reviewed
```

## Stop Conditions
STOP when: all target maturity controls ACTIVE, CRITICAL/HIGH block merge,
secret scanning on 3 layers, SBOM generated per release.

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
```
