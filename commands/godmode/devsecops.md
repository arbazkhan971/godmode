# /godmode:devsecops

Build secure CI/CD pipelines with SAST, DAST, SCA, container scanning, secret scanning, IaC security, and deployment security gates.

## Usage

```
/godmode:devsecops                      # Full pipeline security assessment and setup
/godmode:devsecops --assess             # Assess current pipeline security maturity only
/godmode:devsecops --sast               # Set up SAST tools (Semgrep, CodeQL, SonarQube)
/godmode:devsecops --dast               # Set up DAST tools (OWASP ZAP, Burp)
/godmode:devsecops --sca                # Set up SCA and dependency scanning
/godmode:devsecops --containers         # Set up container scanning (Trivy, Snyk)
/godmode:devsecops --secrets            # Set up secret scanning in CI/CD
/godmode:devsecops --gates              # Configure security gates only
/godmode:devsecops --iac                # Set up IaC security scanning
/godmode:devsecops --sbom               # Set up SBOM generation
/godmode:devsecops --metrics            # Set up security metrics dashboard
/godmode:devsecops --platform github    # Target CI platform (github, gitlab, jenkins, azure)
```

## What It Does

1. Assesses current CI/CD pipeline security maturity (Level 0-5)
2. Integrates SAST tools (Semgrep, CodeQL, SonarQube) for static code analysis
3. Integrates DAST tools (OWASP ZAP, Burp Suite) for runtime security testing
4. Configures SCA for dependency vulnerability and license scanning (Snyk, npm audit)
5. Sets up container image scanning (Trivy, Snyk Container) with hardening checks
6. Installs multi-layer secret scanning (pre-commit, CI, push protection)
7. Configures IaC security scanning (Checkov, tfsec) for infrastructure code
8. Defines security gates that block insecure deployments
9. Generates SBOM (Software Bill of Materials) for supply chain transparency
10. Sets up security metrics dashboard for posture tracking

## Output
- Pipeline workflow files in `.github/workflows/` or equivalent
- Security gate configuration in `security/pipeline-policy.yml`
- Commit: `"devsecops: <description> — <N> security controls, maturity level <N>"`

## Next Step
After pipeline is secured: `/godmode:pentest` to validate, or `/godmode:ship` to deploy through the secure pipeline.

## Examples

```
/godmode:devsecops                      # Full security pipeline setup
/godmode:devsecops --sast --sca         # Add static analysis and dependency scanning
/godmode:devsecops --assess             # Check current maturity level
/godmode:devsecops --gates              # Add security gates to existing pipeline
```
