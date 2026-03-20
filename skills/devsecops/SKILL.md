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
- After `/godmode:pentest` reveals issues that should be caught automatically
- When `/godmode:cicd` needs security controls integrated
- Compliance requires automated security testing (SOC2, PCI-DSS, HIPAA)

## Workflow

### Step 1: Pipeline Security Assessment
Evaluate the current CI/CD pipeline security posture:

```
PIPELINE SECURITY ASSESSMENT:
┌──────────────────────────────────────────────────────────────┐
│  CI/CD Platform: <GitHub Actions | GitLab CI | Jenkins |     │
│                   CircleCI | Azure DevOps | Bitbucket>       │
│  Source control: <GitHub | GitLab | Bitbucket | Azure Repos> │
│  Artifact registry: <Docker Hub | ECR | GCR | ACR | GHCR>   │
│  Deployment target: <K8s | ECS | Lambda | VMs | PaaS>       │
│                                                              │
│  CURRENT SECURITY CONTROLS:                                  │
│  ┌────────────────────┬──────────┬───────────────────────┐   │
│  │ Control            │ Status   │ Tool                  │   │
│  ├────────────────────┼──────────┼───────────────────────┤   │
│  │ SAST               │ YES/NO   │ <tool or none>        │   │
│  │ DAST               │ YES/NO   │ <tool or none>        │   │
│  │ SCA                │ YES/NO   │ <tool or none>        │   │
│  │ Container scanning │ YES/NO   │ <tool or none>        │   │
│  │ Secret scanning    │ YES/NO   │ <tool or none>        │   │
│  │ IaC scanning       │ YES/NO   │ <tool or none>        │   │
│  │ License compliance │ YES/NO   │ <tool or none>        │   │
│  │ SBOM generation    │ YES/NO   │ <tool or none>        │   │
│  │ Signed commits     │ YES/NO   │ <GPG/SSH>             │   │
│  │ Signed artifacts   │ YES/NO   │ <cosign/notation>     │   │
│  │ Security gates     │ YES/NO   │ <blocking/advisory>   │   │
│  └────────────────────┴──────────┴───────────────────────┘   │
│                                                              │
│  GAPS IDENTIFIED:                                            │
│  - <missing control 1>                                       │
│  - <missing control 2>                                       │
│  - <misconfigured control>                                   │
│                                                              │
│  MATURITY LEVEL:                                             │
│  [ ] Level 0: No security in pipeline                        │
│  [ ] Level 1: Basic dependency scanning                      │
│  [ ] Level 2: SAST + SCA + secret scanning                   │
│  [ ] Level 3: Full SAST/DAST/SCA + container scanning        │
│  [ ] Level 4: Security gates + SBOM + signed artifacts       │
│  [ ] Level 5: Continuous verification + policy-as-code       │
└──────────────────────────────────────────────────────────────┘
```

### Step 2: SAST Integration (Static Application Security Testing)
Configure static code analysis for security vulnerabilities:

#### Semgrep
```yaml
# .github/workflows/sast-semgrep.yml (GitHub Actions)
name: SAST — Semgrep
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container:
      image: semgrep/semgrep
    steps:
      - uses: actions/checkout@v4
      - name: Run Semgrep
        run: |
          semgrep ci \
            --config auto \
            --config p/owasp-top-ten \
            --config p/cwe-top-25 \
            --config p/security-audit \
            --sarif --output semgrep-results.sarif
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: semgrep-results.sarif
        if: always()
```

```
SEMGREP CONFIGURATION:
Rulesets:
  - auto (Semgrep-curated rules for detected languages)
  - p/owasp-top-ten (OWASP Top 10 coverage)
  - p/cwe-top-25 (CWE Top 25 most dangerous weaknesses)
  - p/security-audit (broad security patterns)
  - p/<language>-security (language-specific rules)

Custom rules directory: .semgrep/
  Create custom rules for project-specific patterns:
  - Banned functions (eval, exec, unsafe APIs)
  - Required patterns (input validation on routes)
  - Architecture rules (no direct DB access from controllers)

Severity thresholds:
  Block PR: ERROR level findings
  Warn: WARNING level findings
  Ignore: INFO level (track but don't block)

Baseline: semgrep ci --baseline-commit ${{ github.event.pull_request.base.sha }}
  Only report NEW findings, not existing technical debt
```

#### CodeQL
```yaml
# .github/workflows/sast-codeql.yml
name: SAST — CodeQL
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'  # Weekly deep scan

jobs:
  codeql:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    strategy:
      matrix:
        language: ['javascript', 'python']  # Add your languages
    steps:
      - uses: actions/checkout@v4
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-extended  # security-and-quality for broader coverage
      - name: Autobuild
        uses: github/codeql-action/autobuild@v3
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
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

Languages supported: C/C++, C#, Go, Java/Kotlin, JavaScript/TypeScript, Python, Ruby, Swift
```

#### SonarQube
```yaml
# .github/workflows/sast-sonarqube.yml
name: SAST — SonarQube
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for blame analysis
      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v2
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      - name: Quality Gate
        uses: SonarSource/sonarqube-quality-gate-action@v1
        timeout-minutes: 5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

```
SONARQUBE QUALITY GATE:
Conditions (block merge if ANY fail):
  - New security vulnerabilities: 0 (no new vulns)
  - New security hotspots reviewed: 100% (all hotspots triaged)
  - New code coverage: >= 80% (security-critical code must be tested)
  - New duplicated lines: < 3% (duplicated code = duplicated vulnerabilities)

Security-specific settings:
  sonar.security.hotspots.reviewed=100
  sonar.security.rating=A  # No vulnerabilities allowed
```

### Step 3: DAST Integration (Dynamic Application Security Testing)
Configure runtime security testing against running applications:

#### OWASP ZAP
```yaml
# .github/workflows/dast-zap.yml
name: DAST — OWASP ZAP
on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  zap-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Start application
        run: |
          docker-compose -f docker-compose.test.yml up -d
          # Wait for app to be ready
          timeout 60 bash -c 'until curl -s http://localhost:3000/health; do sleep 2; done'
      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.12.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a -j'
      - name: ZAP Full Scan (scheduled)
        if: github.event_name == 'schedule'
        uses: zaproxy/action-full-scan@v0.10.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: zap-report
          path: report_html.html
        if: always()
```

```
ZAP CONFIGURATION:
Scan types:
  Baseline scan: Passive scanning + spider (fast, every PR)
  Full scan: Active scanning + fuzzing (slow, scheduled/manual)
  API scan: OpenAPI/Swagger spec-driven testing

Rules file (.zap/rules.tsv):
  10016  WARN   (Web Browser XSS Protection Not Enabled)
  10017  WARN   (Cross-Domain JavaScript Source File Inclusion)
  10021  FAIL   (X-Content-Type-Options Header Missing)
  10038  FAIL   (Content Security Policy Header Not Set)
  40012  FAIL   (Cross Site Scripting - Reflected)
  40014  FAIL   (Cross Site Scripting - Persistent)
  90022  WARN   (Application Error Disclosure)
  90033  FAIL   (Loosely Scoped Cookie)

Authentication for ZAP:
  Context file: .zap/context.xml
  Authentication: Form-based / JSON / Token-based
  Users: Test accounts for authenticated scanning
```

#### Burp Suite (Enterprise/CI)
```
BURP SUITE CI INTEGRATION:
  # For organizations with Burp Suite Enterprise

  Configuration:
    Scan type: Crawl and audit
    Scan speed: Normal (thorough) | Fast (CI-optimized)
    Scope: Application URLs only (no third-party)
    Authentication: Pre-configured login sequences

  CI integration:
    # Via Burp Suite Enterprise API
    curl -X POST https://burp-enterprise/api/scans \
      -H "Authorization: Bearer $BURP_API_TOKEN" \
      -d '{"site_id": "app-id", "scan_config": "ci-optimized"}'

  Output:
    SARIF report for GitHub Security tab integration
    JUnit XML for CI pass/fail
    HTML report for human review
```

### Step 4: SCA (Software Composition Analysis)
Scan dependencies for known vulnerabilities and license issues:

```yaml
# .github/workflows/sca.yml
name: SCA — Dependency Security
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
  schedule:
    - cron: '0 8 * * *'  # Daily vulnerability check

jobs:
  # GitHub native dependency scanning
  dependabot:
    # Configured via .github/dependabot.yml
    # Automatic PRs for vulnerable dependencies

  # Snyk SCA
  snyk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Snyk Security Scan
        uses: snyk/actions/node@master  # or /python, /golang, /docker
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high --fail-on=upgradable
      - name: Snyk Monitor (push to main only)
        if: github.ref == 'refs/heads/main'
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          command: monitor

  # npm/yarn native audit
  npm-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm audit --audit-level=high

  # SBOM generation
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          format: spdx-json
          output-file: sbom.spdx.json
      - name: Upload SBOM
        uses: actions/upload-artifact@v4
        with:
          name: sbom
          path: sbom.spdx.json
```

```
SCA CONFIGURATION:
┌──────────────────────────────────────────────────────────────┐
│  Dependency Scanning Strategy                                │
├──────────────────────────────────────────────────────────────┤
│  Tool             │ Purpose            │ When               │
│  ─────────────────────────────────────────────────────────── │
│  Dependabot/Renovate │ Auto-update PRs │ Daily              │
│  Snyk             │ Deep vuln analysis │ Every PR + daily   │
│  npm/pip/cargo audit │ Native scanning │ Every PR           │
│  SBOM generator   │ Supply chain       │ Every release      │
│  License checker  │ Compliance         │ Every PR           │
├──────────────────────────────────────────────────────────────┤
│  SEVERITY POLICY:                                            │
│  CRITICAL: Block merge + alert security team immediately     │
│  HIGH:     Block merge + create ticket                       │
│  MEDIUM:   Warn in PR + create ticket (30-day SLA)           │
│  LOW:      Track in dashboard (90-day SLA)                   │
│                                                              │
│  EXCEPTIONS:                                                 │
│  File: .snyk or .nsprc or audit-exceptions.json              │
│  Format: CVE-ID + justification + expiry date + reviewer     │
│  Review: Security team reviews exceptions quarterly          │
└──────────────────────────────────────────────────────────────┘

SBOM (Software Bill of Materials):
  Format: SPDX or CycloneDX
  Generated: On every release and container build
  Storage: Artifact registry alongside the release
  Purpose: Supply chain transparency, vulnerability tracking, license compliance
  Requirement: Executive Order 14028 (US federal) and similar regulations
```

### Step 5: Container Scanning
Scan container images for vulnerabilities:

#### Trivy
```yaml
# .github/workflows/container-scan-trivy.yml
name: Container Scan — Trivy
on:
  push:
    branches: [main]
  pull_request:
    paths:
      - 'Dockerfile*'
      - 'docker-compose*.yml'
      - '.dockerignore'

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t app:${{ github.sha }} .
      - name: Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Fail on CRITICAL/HIGH
      - name: Upload Trivy SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
        if: always()

      # Also scan IaC files
      - name: Trivy config scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: '.'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'
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
  - [ ] No secrets in image layers (use build args or runtime env)
  - [ ] Read-only filesystem where possible
  - [ ] No unnecessary packages installed
  - [ ] Health check defined
  - [ ] .dockerignore excludes sensitive files
```

#### Snyk Container
```yaml
# .github/workflows/container-scan-snyk.yml
name: Container Scan — Snyk
on:
  push:
    branches: [main]

jobs:
  snyk-container:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t app:${{ github.sha }} .
      - name: Snyk Container Scan
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          image: app:${{ github.sha }}
          args: --severity-threshold=high --file=Dockerfile
      - name: Snyk Container Monitor
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          image: app:${{ github.sha }}
          command: monitor
```

### Step 6: Secret Scanning in CI/CD
Prevent secrets from reaching the repository:

```yaml
# .github/workflows/secret-scan.yml
name: Secret Scanning
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for thorough scanning
      - name: Gitleaks scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}

  trufflehog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: TruffleHog scan
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified --results=verified
```

```
SECRET SCANNING LAYERS:
┌──────────────────────────────────────────────────────────────┐
│  Layer              │ Tool            │ When                 │
├──────────────────────────────────────────────────────────────┤
│  Pre-commit (local) │ gitleaks hook   │ Before every commit  │
│  PR check (CI)      │ gitleaks action │ Every pull request   │
│  Push protection    │ GitHub/GitLab   │ Every push           │
│  Scheduled scan     │ trufflehog      │ Daily full scan      │
│  Runtime detection  │ detect-secrets  │ Baseline tracking    │
├──────────────────────────────────────────────────────────────┤
│  CUSTOM PATTERNS:                                            │
│  .gitleaks.toml:                                             │
│    [[rules]]                                                 │
│    id = "internal-api-key"                                   │
│    description = "Internal API key pattern"                  │
│    regex = '''INTERNAL_[A-Z]+_KEY\s*=\s*['"][^'"]+['"]'''    │
│    severity = "CRITICAL"                                     │
│                                                              │
│  ALLOWLIST:                                                  │
│    [allowlist]                                               │
│    paths = ["test/fixtures/**", "docs/examples/**"]          │
│    description = "Test fixtures with fake secrets"           │
└──────────────────────────────────────────────────────────────┘
```

### Step 7: Security Gates in Deployment Pipelines
Define blocking security checks that prevent insecure deployments:

```
SECURITY GATE CONFIGURATION:
┌──────────────────────────────────────────────────────────────┐
│  Gate              │ Stage      │ Action    │ Override       │
├──────────────────────────────────────────────────────────────┤
│  SAST findings     │ PR check   │ BLOCK     │ Security team  │
│  SCA critical CVE  │ PR check   │ BLOCK     │ Security team  │
│  Secret detected   │ PR check   │ BLOCK     │ No override    │
│  DAST high vuln    │ Pre-deploy │ BLOCK     │ Security team  │
│  Container CVE     │ Pre-deploy │ BLOCK     │ Security team  │
│  SBOM missing      │ Pre-deploy │ BLOCK     │ Release eng    │
│  License violation │ PR check   │ WARN      │ Legal team     │
│  IaC misconfig     │ PR check   │ BLOCK     │ Platform team  │
│  Unsigned artifact │ Pre-deploy │ BLOCK     │ No override    │
│  SonarQube gate    │ PR check   │ BLOCK     │ Security team  │
├──────────────────────────────────────────────────────────────┤
│  OVERRIDE PROCESS:                                           │
│  1. Finding triaged by responsible team                      │
│  2. Risk acceptance documented with justification            │
│  3. Exception has expiry date (max 30 days)                  │
│  4. Exception tracked in security dashboard                  │
│  5. Exception reviewed at next security review               │
└──────────────────────────────────────────────────────────────┘
```

```yaml
# Complete security-gated pipeline example
# .github/workflows/secure-pipeline.yml
name: Secure Pipeline
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  # Stage 1: Code Security (runs on every PR)
  sast:
    uses: ./.github/workflows/sast-semgrep.yml

  codeql:
    uses: ./.github/workflows/sast-codeql.yml

  secret-scan:
    uses: ./.github/workflows/secret-scan.yml

  sca:
    uses: ./.github/workflows/sca.yml

  # Stage 2: Build (only if Stage 1 passes)
  build:
    needs: [sast, codeql, secret-scan, sca]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build application
        run: npm ci && npm run build
      - name: Build container
        run: docker build -t app:${{ github.sha }} .
      - name: Sign container
        run: cosign sign --key env://COSIGN_KEY app:${{ github.sha }}
        env:
          COSIGN_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}

  # Stage 3: Container Security (after build)
  container-scan:
    needs: [build]
    uses: ./.github/workflows/container-scan-trivy.yml

  # Stage 4: Dynamic Testing (after build, on staging)
  dast:
    needs: [build]
    if: github.ref == 'refs/heads/main'
    uses: ./.github/workflows/dast-zap.yml

  # Stage 5: Security Gate (all checks must pass)
  security-gate:
    needs: [sast, codeql, secret-scan, sca, container-scan]
    runs-on: ubuntu-latest
    steps:
      - name: Security Gate Check
        run: |
          echo "All security checks passed"
          echo "SAST: PASS"
          echo "CodeQL: PASS"
          echo "Secret Scan: PASS"
          echo "SCA: PASS"
          echo "Container Scan: PASS"

  # Stage 6: Deploy (only after security gate)
  deploy:
    needs: [security-gate]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Verify artifact signature
        run: cosign verify --key env://COSIGN_PUB app:${{ github.sha }}
        env:
          COSIGN_PUB: ${{ secrets.COSIGN_PUBLIC_KEY }}
      - name: Deploy
        run: echo "Deploying verified artifact..."
```

### Step 8: Infrastructure as Code (IaC) Security
Scan infrastructure definitions for misconfigurations:

```yaml
# .github/workflows/iac-scan.yml
name: IaC Security
on:
  pull_request:
    paths:
      - 'terraform/**'
      - 'k8s/**'
      - 'cloudformation/**'
      - 'Dockerfile*'

jobs:
  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Checkov IaC Scan
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: .
          framework: terraform,kubernetes,dockerfile,secrets
          soft_fail: false
          output_format: sarif

  tfsec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: tfsec scan
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          sarif_file: tfsec.sarif
```

```
IAC SECURITY CHECKS:
┌──────────────────────────────────────────────────────────────┐
│  Category                │ Examples                          │
├──────────────────────────────────────────────────────────────┤
│  Cloud misconfig         │ Public S3 buckets, open SGs       │
│  Kubernetes security     │ Privileged containers, no limits  │
│  Docker hardening        │ Root user, missing healthcheck    │
│  Terraform state         │ Remote state with encryption      │
│  Network exposure        │ 0.0.0.0/0 ingress rules           │
│  Encryption              │ Unencrypted storage/databases     │
│  Logging                 │ Missing audit trails              │
│  IAM                     │ Overly permissive policies        │
└──────────────────────────────────────────────────────────────┘
```

### Step 9: Security Dashboard and Metrics
Track security posture over time:

```
SECURITY METRICS DASHBOARD:
┌──────────────────────────────────────────────────────────────┐
│  SECURITY POSTURE — <project>                                │
├──────────────────────────────────────────────────────────────┤
│  Open vulnerabilities:                                       │
│  CRITICAL: <N> (SLA: 24h)    Overdue: <N>                   │
│  HIGH:     <N> (SLA: 7d)     Overdue: <N>                   │
│  MEDIUM:   <N> (SLA: 30d)    Overdue: <N>                   │
│  LOW:      <N> (SLA: 90d)    Overdue: <N>                   │
│                                                              │
│  Pipeline security:                                          │
│  PRs blocked by security gate: <N> this week                 │
│  Average fix time (CRITICAL): <hours>                        │
│  Average fix time (HIGH): <days>                             │
│  Security gate override rate: <N>%                           │
│                                                              │
│  Dependency health:                                          │
│  Total dependencies: <N>                                     │
│  With known vulnerabilities: <N>                             │
│  Outdated (>1 major version): <N>                            │
│  License violations: <N>                                     │
│                                                              │
│  Container health:                                           │
│  Images in production: <N>                                   │
│  With CRITICAL CVEs: <N>                                     │
│  Using :latest tag: <N> (should be 0)                        │
│  Non-root containers: <N>/<N>                                │
│                                                              │
│  Trend: IMPROVING | STABLE | DEGRADING                       │
└──────────────────────────────────────────────────────────────┘
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

1. **Shift left, not shift burden.** Security scanning in CI should be fast enough that developers do not skip it. Baseline scans in PRs, full scans on schedule.
2. **Block on critical, warn on the rest.** Only CRITICAL and HIGH severity findings should block merges. Medium and low get tracked but do not stop velocity.
3. **No secrets pass the gate.** Secret scanning has zero exceptions. A leaked secret is an incident, not a finding to triage.
4. **SBOM is a requirement, not optional.** Every release must have a Software Bill of Materials. This is increasingly a legal requirement, not just a best practice.
5. **Scan at every layer.** Source code (SAST), dependencies (SCA), running app (DAST), containers (Trivy), infrastructure (Checkov), secrets (gitleaks). Vulnerabilities hide at every layer.
6. **False positives erode trust.** Tune rules aggressively. A security gate that cries wolf gets disabled. Maintain exception lists with expiry dates.
7. **Sign everything.** Commits, container images, release artifacts. Supply chain security requires provenance at every step.
8. **Measure and improve.** Track mean time to remediation, gate override rates, and vulnerability trends. You cannot improve what you do not measure.

## Example Usage

### Setting up a security pipeline from scratch
```
User: /godmode:devsecops Set up security scanning for our Node.js project on GitHub Actions

DevSecOps: Assessing current pipeline...

CURRENT STATE:
  CI platform: GitHub Actions
  Existing security: npm audit only (Level 1)
  Target maturity: Level 3

IMPLEMENTATION PLAN:
  1. SAST: Semgrep with OWASP + CWE rulesets
  2. SCA: Snyk for deep dependency analysis + npm audit
  3. Secret scanning: gitleaks pre-commit + CI
  4. Container scanning: Trivy for Docker images
  5. Security gates: Block on CRITICAL/HIGH, warn on MEDIUM

Creating workflow files...
  .github/workflows/sast-semgrep.yml — Semgrep SAST on every PR
  .github/workflows/sca.yml — Snyk + npm audit
  .github/workflows/secret-scan.yml — gitleaks + trufflehog
  .github/workflows/container-scan.yml — Trivy on Dockerfile changes
  .github/workflows/secure-pipeline.yml — Orchestrator with security gate

Maturity: Level 1 -> Level 3
```

### Adding DAST to existing pipeline
```
User: /godmode:devsecops Add dynamic security testing to our CI

DevSecOps: Adding OWASP ZAP integration...

Created:
  .github/workflows/dast-zap.yml — ZAP baseline on PR, full scan weekly
  .zap/rules.tsv — ZAP rule configuration (FAIL on XSS, CSP missing)
  .zap/context.xml — Authentication context for ZAP scanning

The ZAP scan runs against your staging environment after deployment.
Baseline scan (fast): Every PR to main
Full scan (thorough): Weekly scheduled run
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full pipeline security assessment and setup |
| `--assess` | Assess current pipeline security maturity only |
| `--sast` | Set up SAST tools (Semgrep, CodeQL, SonarQube) |
| `--dast` | Set up DAST tools (OWASP ZAP, Burp) |
| `--sca` | Set up SCA and dependency scanning |
| `--containers` | Set up container scanning (Trivy, Snyk) |
| `--secrets` | Set up secret scanning in CI/CD |
| `--gates` | Configure security gates only |
| `--iac` | Set up IaC security scanning |
| `--sbom` | Set up SBOM generation |
| `--metrics` | Set up security metrics dashboard |
| `--platform <name>` | Target CI platform (github, gitlab, jenkins, azure) |

## HARD RULES

- NEVER allow secrets to pass the security gate — secret scanning has ZERO exceptions and NO override process
- NEVER use `:latest` for scanner images in CI — pin scanner versions to prevent silent policy changes
- NEVER scan only on main branch — security issues MUST be caught in PRs before merge
- NEVER deploy unsigned container images to production — sign with cosign/notation and verify before deploy
- NEVER store scanner tokens as plain environment variables — use CI/CD secret management
- ALL CRITICAL/HIGH severity findings MUST block merge (no silent pass-through)
- ALL security gate overrides MUST have documented justification, an expiry date (max 30 days), and a reviewing team
- ALL releases MUST include an SBOM in SPDX or CycloneDX format

## Iterative Security Scan Loop Protocol

When hardening a pipeline or auditing security posture:

```
current_iteration = 0
scan_queue = [SAST, SCA, secret_scan, container_scan, IaC_scan, DAST]
WHILE scan_queue is not empty:
    current_iteration += 1
    scan_type = scan_queue.pop(next)
    configure and run scan_type
    collect findings (CRITICAL, HIGH, MEDIUM, LOW)
    FOR each CRITICAL/HIGH finding:
        triage: true positive or false positive
        if true positive: create fix or exception with expiry
        if false positive: add to allowlist with justification
    IF new scan type dependencies discovered (e.g., IaC scan reveals missing container scan):
        add to scan_queue
    report: "Iteration {current_iteration}: {scan_type} — {N} findings, {M} fixed, {remaining} scans queued"
```

## Multi-Agent Dispatch

```
DISPATCH 4 agents in separate worktrees:
  Agent 1 (SAST+SCA):      Configure Semgrep/CodeQL + Snyk/npm audit, tune rulesets, set severity thresholds
  Agent 2 (containers):     Configure Trivy container scanning + Dockerfile hardening + image signing with cosign
  Agent 3 (secrets+IaC):    Configure gitleaks/trufflehog pre-commit + CI + Checkov/tfsec for IaC scanning
  Agent 4 (gates+pipeline): Build orchestrator workflow with security gates, SBOM generation, deploy verification
SYNC point: All agents complete
  Merge worktrees
  Run full security pipeline end-to-end on a test PR
  Generate security posture report with maturity level assessment
```

## Auto-Detection

```
1. Check CI/CD platform:
   - Scan for .github/workflows/ → GitHub Actions
   - Scan for .gitlab-ci.yml → GitLab CI
   - Scan for Jenkinsfile → Jenkins
   - Scan for azure-pipelines.yml → Azure DevOps
2. Check existing security controls:
   - Scan workflows for semgrep, codeql, sonar, snyk, trivy, gitleaks, trufflehog, checkov, tfsec
   - Check for .gitleaks.toml, .semgrep/, sonar-project.properties
   - Check for cosign, notation references (artifact signing)
   - Check for dependabot.yml or renovate.json (dependency updates)
3. Check for container and IaC:
   - Scan for Dockerfile*, docker-compose*, kubernetes/, terraform/, cloudformation/
4. Assess maturity level (0-5) based on controls found
5. Identify gaps and set scan_queue for the hardening loop
```

## Anti-Patterns

- **Do NOT add security scanning that blocks builds without tuning.** Untuned scanners produce hundreds of false positives, causing developers to ignore or disable them. Tune rules first, then enforce.
- **Do NOT scan only on main branch.** Security issues must be caught in PRs before they merge. Scanning only main means vulnerabilities are already in production code.
- **Do NOT use :latest for scanner images.** Pin scanner versions. A scanner update should not silently change your security policy.
- **Do NOT skip container scanning because "we trust the base image."** Even official base images have vulnerabilities. Scan every image, every build.
- **Do NOT store scanner tokens as plain environment variables.** Use CI/CD secret management. Scanner tokens often have write access to security dashboards.
- **Do NOT treat security gates as permanent blockers.** Provide a documented exception process. Blocking deploys with no override path leads to circumvention.
- **Do NOT scan without acting on results.** A scan that produces reports nobody reads is security theater. Every finding must have an owner and SLA.
- **Do NOT implement everything at once.** Start with SAST + SCA + secret scanning (Level 2), then add container scanning and DAST (Level 3), then security gates and SBOM (Level 4). Incremental adoption sticks; big bang does not.


## Output Format

Every devsecops invocation must produce a structured report:

```
┌────────────────────────────────────────────────────────────────┐
│  DEVSECOPS RESULT                                               │
├────────────────────────────────────────────────────────────────┤
│  CI platform: <GitHub Actions | GitLab CI | Jenkins | etc.>     │
│  Controls configured: <N> / 11                                  │
│  Security gates: <N blocking, N advisory>                       │
│  Maturity level: <0-5> (before -> after)                        │
│  Open findings: <N>C <N>H <N>M <N>L                            │
│  Verdict: <PIPELINE SECURE | GAPS REMAIN | NOT CONFIGURED>      │
└────────────────────────────────────────────────────────────────┘
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
  - IaC scanning for Terraform/Kubernetes/Dockerfile
  - Artifact signing with cosign/notation and verification before deploy
  - Policy-as-code for all security gates (not just CI config)
  - Security metrics dashboard with SLA tracking

FAIL if ANY of the following:
  - No security scanning in the CI pipeline at all
  - Secrets can pass the pipeline without detection
  - CRITICAL findings do not block merge
  - Container images deployed without scanning
  - :latest used for scanner images
```

## Error Recovery

```
IF a security scanner produces excessive false positives:
  1. Do NOT disable the scanner — tune the rules
  2. Create an exception file (.snyk, .semgrepignore, .gitleaks.toml allowlist)
  3. Every exception must include: CVE/rule ID, justification, expiry date, reviewer
  4. Review exceptions quarterly — expired exceptions are re-enabled automatically
  5. Track false positive rate as a metric — target < 10% of total findings

IF a security gate blocks a critical deployment:
  1. Use the documented override process (never bypass silently)
  2. Override requires: team lead approval, documented justification, 30-day max expiry
  3. Create a ticket for the finding with SLA based on severity
  4. Post-deployment: fix the finding within the SLA and remove the override
  5. Track gate override rate — increasing overrides indicate scanner tuning is needed

IF a scanner fails or times out in CI:
  1. The pipeline should NOT silently pass — fail open is a security gap
  2. Retry the scanner once with increased timeout
  3. If retry fails: mark the pipeline as UNSTABLE (not pass, not fail)
  4. Notify the security/platform team of the scanner outage
  5. Do not merge until the scanner runs successfully — queue the PR
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run DevSecOps tasks sequentially: SAST+SCA, then containers, then secrets+IaC, then gates+pipeline.
- Use branch isolation per task: `git checkout -b godmode-devsecops-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
