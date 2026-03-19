# /godmode:dependencies

Dependency management and supply chain security skill. Covers Renovate and Dependabot setup, security scanning (Snyk, npm audit, pip-audit, govulncheck), SBOM generation, license compliance, dependency pinning, lock file integrity, automated PR merging, vulnerability remediation, and supply chain attack prevention.

## Usage

```
/godmode:dependencies                    # Full dependency management assessment
/godmode:dependencies --renovate         # Set up or reconfigure Renovate
/godmode:dependencies --dependabot       # Set up or reconfigure Dependabot
/godmode:dependencies --scan             # Run security vulnerability scan
/godmode:dependencies --sbom             # Generate Software Bill of Materials
/godmode:dependencies --license          # Run license compliance scan
/godmode:dependencies --pin              # Apply recommended pinning strategy
/godmode:dependencies --lockfile         # Validate lock file integrity
/godmode:dependencies --automerge        # Configure automated PR merging rules
/godmode:dependencies --supply-chain     # Full supply chain security audit
/godmode:dependencies --remediate        # Interactive vulnerability remediation
/godmode:dependencies --outdated         # Check all ecosystems for outdated deps
/godmode:dependencies --socket           # Run socket.dev supply chain analysis
/godmode:dependencies --ci               # CI-friendly output (exit code 1 on issues)
```

## What It Does

1. Assesses the project's dependency health across all ecosystems
2. Configures Renovate or Dependabot with automerge rules, grouping, and scheduling
3. Runs security scans (Snyk, npm audit, pip-audit, govulncheck, Trivy, OSV-Scanner)
4. Generates SBOMs in SPDX or CycloneDX format for compliance
5. Scans licenses and enforces policy (block GPL/AGPL in commercial projects)
6. Applies dependency pinning strategies (exact, caret, SHA digest)
7. Validates lock file integrity with lockfile-lint
8. Sets up automated PR merging (patches auto-merge, majors require approval)
9. Walks through vulnerability remediation workflows (triage, fix, verify, prevent)
10. Hardens supply chain (socket.dev, provenance, install script auditing)

## Output
- Renovate or Dependabot configuration files
- Security scan report with remediation steps
- SBOM artifacts (SPDX or CycloneDX)
- License compliance report
- Lock file integrity validation results
- Dependency management report with health metrics
- Commit: `"deps: configure <tool> for automated dependency updates"`

## Next Step
After dependency management: `/godmode:secure` for full security audit, or `/godmode:cicd` to integrate scanning into your pipeline.

## Examples

```
/godmode:dependencies                    # Full assessment of all dependency health
/godmode:dependencies --renovate         # Set up Renovate with automerge for monorepo
/godmode:dependencies --scan             # Fix 2 critical + 5 high vulnerabilities
/godmode:dependencies --supply-chain     # Audit lockfile, install scripts, provenance
/godmode:dependencies --sbom             # Generate SPDX SBOM for compliance
```
