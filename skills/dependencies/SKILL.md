---
name: dependencies
description: Dependency updates, security patching, Renovate/Dependabot setup, supply chain security. Use when user mentions dependency updates, Renovate, Dependabot, outdated packages, security vulnerabilities, Snyk, npm audit, supply chain.
---

# Dependencies — Dependency Management & Supply Chain Security

## When to Activate
- User invokes `/godmode:dependencies`
- User says "Renovate", "Dependabot", "dependency updates", "outdated packages"
- User says "npm audit", "pip-audit", "govulncheck", "Snyk", "security scan"
- User says "SBOM", "license compliance", "supply chain security"
- User says "lockfile-lint", "socket.dev", "dependency pinning"
- User says "automated dependency PRs", "automerge patches"
- User says "vulnerability remediation", "CVE", "advisory"
- User encounters outdated or vulnerable dependencies in any ecosystem
- Pre-ship check identifies dependency vulnerabilities
- Godmode orchestrator detects supply chain risks

## Workflow

### Step 1: Assess Dependency Landscape
Understand the project's dependency health and ecosystem:

```
DEPENDENCY MANAGEMENT CONTEXT:
Project:
  Language(s): <JavaScript | Python | Go | Rust | Java | multi-language>
  Package manager(s): <npm | pnpm | yarn | pip | poetry | go mod | cargo | maven | gradle>
  Lock file(s): <package-lock.json | pnpm-lock.yaml | poetry.lock | go.sum | Cargo.lock | etc.>
  Lock files committed: <yes | no>

Dependency health:
  Total direct: <N packages>
  Total transitive: <N packages>
  Outdated (major): <N packages>
  Outdated (minor/patch): <N packages>
  Vulnerabilities: <N advisories (N critical, N high, N moderate, N low)>
  Unmaintained (>2yr no release): <N packages>
  Deprecated: <N packages>

Automation:
  Update tool: <Renovate | Dependabot | none>
  CI security scanning: <Snyk | GitHub Advanced Security | Trivy | none>
  SBOM generation: <yes | no>
  License scanning: <yes | no>

Supply chain:
  Lock file integrity: <verified | not checked>
  Provenance verification: <enabled | not enabled>
  Registry: <public | private | mixed>
```

### Step 2: Renovate Setup and Configuration
Configure Renovate for automated dependency updates:

```
RENOVATE CONFIGURATION:
┌──────────────────────────────────────────────────────────────┐
│ Why Renovate over Dependabot:                                │
│  - More flexible scheduling and grouping                     │
│  - Automerge with configurable rules                         │
│  - Regex manager for custom file formats                     │
│  - Dashboard issue for tracking all updates                  │
│  - Better monorepo support                                   │
│  - Replacement and deprecation awareness                     │
│  - Supports 90+ package managers vs Dependabot's ~15         │
└──────────────────────────────────────────────────────────────┘

RENOVATE CONFIG (renovate.json):
  {
    "$schema": "https://docs.renovatebot.com/renovate-schema.json",
    "extends": [
      "config:recommended",
      ":automergeMinor",
      ":automergeDigest",
      ":semanticCommits",
      "group:recommended",
      "schedule:weekends"
    ],
    "labels": ["dependencies"],
    "vulnerabilityAlerts": {
      "labels": ["security"],
      "automerge": true,
      "schedule": ["at any time"]
    },
    "packageRules": [
      {
        "description": "Automerge patch updates",
        "matchUpdateTypes": ["patch"],
        "automerge": true,
        "automergeType": "pr",
        "platformAutomerge": true
      },
      {
        "description": "Automerge minor updates for dev dependencies",
        "matchDepTypes": ["devDependencies"],
        "matchUpdateTypes": ["minor"],
        "automerge": true
      },
      {
        "description": "Group all lint-related packages",
        "matchPackageNames": ["eslint", "prettier", "/^eslint-/", "/^@typescript-eslint/"],
        "groupName": "lint tooling"
      },
      {
        "description": "Group all test-related packages",
        "matchPackageNames": ["jest", "vitest", "/^@testing-library/", "/^@jest/"],
        "groupName": "test tooling"
      },
      {
        "description": "Require approval for major updates",
        "matchUpdateTypes": ["major"],
        "dependencyDashboardApproval": true
      },
      {
        "description": "Pin GitHub Actions digests",
        "matchManagers": ["github-actions"],
        "pinDigests": true
      }
    ],
    "prConcurrentLimit": 10,
    "prHourlyLimit": 5,
    "schedule": ["before 6am on Monday"],
    "timezone": "America/New_York"
  }

ADVANCED RENOVATE PATTERNS:
  # Schedule by ecosystem
  "packageRules": [
    {
      "matchManagers": ["npm"],
      "schedule": ["before 6am on Monday"]
    },
    {
      "matchManagers": ["pip_requirements", "poetry"],
      "schedule": ["before 6am on Wednesday"]
    },
    {
      "matchManagers": ["gomod"],
      "schedule": ["before 6am on Friday"]
    }
  ]

  # Replacement rules (migrate deprecated packages)
  "packageRules": [
    {
      "matchPackageNames": ["request"],
      "replacementName": "got",
      "replacementVersion": "13.0.0"
    }
  ]

  # Monorepo grouping
  "packageRules": [
    {
      "matchSourceUrls": ["https://github.com/babel/babel"],
      "groupName": "babel"
    }
  ]

  # Custom regex manager (Dockerfile, Makefile, scripts)
  "customManagers": [
    {
      "customType": "regex",
      "fileMatch": ["^Dockerfile$"],
      "matchStrings": [
        "ENV \\w+_VERSION=(?<currentValue>.*?)\\n"
      ],
      "depNameTemplate": "{{depName}}",
      "datasourceTemplate": "github-releases"
    }
  ]
```

### Step 3: Dependabot Configuration
Configure Dependabot for GitHub-native dependency updates:

```
DEPENDABOT CONFIG (.github/dependabot.yml):
  version: 2
  updates:
    # JavaScript / TypeScript
    - package-ecosystem: "npm"
      directory: "/"
      schedule:
        interval: "weekly"
        day: "monday"
        time: "06:00"
        timezone: "America/New_York"
      open-pull-requests-limit: 10
      reviewers:
        - "team-leads"
      labels:
        - "dependencies"
        - "javascript"
      groups:
        dev-dependencies:
          dependency-type: "development"
          update-types:
            - "minor"
            - "patch"
        lint-tools:
          patterns:
            - "eslint*"
            - "@typescript-eslint/*"
            - "prettier"
        test-tools:
          patterns:
            - "jest"
            - "@testing-library/*"
            - "vitest"
      ignore:
        - dependency-name: "aws-sdk"
          versions: [">=3.0.0"]    # Wait for full v3 migration

    # Python
    - package-ecosystem: "pip"
      directory: "/"
      schedule:
        interval: "weekly"
        day: "wednesday"
      labels:
        - "dependencies"
        - "python"

    # Go
    - package-ecosystem: "gomod"
      directory: "/"
      schedule:
        interval: "weekly"
        day: "friday"
      labels:
        - "dependencies"
        - "go"

    # GitHub Actions
    - package-ecosystem: "github-actions"
      directory: "/"
      schedule:
        interval: "weekly"
      labels:
        - "dependencies"
        - "ci"

    # Docker
    - package-ecosystem: "docker"
      directory: "/"
      schedule:
        interval: "weekly"
      labels:
        - "dependencies"
        - "docker"

DEPENDABOT AUTO-MERGE (GitHub Actions):
  # .github/workflows/dependabot-automerge.yml
  name: Dependabot Auto-Merge
  on: pull_request

  permissions:
    contents: write
    pull-requests: write

  jobs:
    automerge:
      runs-on: ubuntu-latest
      if: github.actor == 'dependabot[bot]'
      steps:
        - name: Fetch Dependabot metadata
          id: metadata
          uses: dependabot/fetch-metadata@v2
          with:
            github-token: "${{ secrets.GITHUB_TOKEN }}"

        - name: Auto-merge patch and minor updates
          if: >-
            steps.metadata.outputs.update-type == 'version-update:semver-patch' ||
            (steps.metadata.outputs.update-type == 'version-update:semver-minor' &&
             steps.metadata.outputs.dependency-type == 'direct:development')
          run: gh pr merge --auto --squash "$PR_URL"
          env:
            PR_URL: ${{ github.event.pull_request.html_url }}
            GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

RENOVATE vs DEPENDABOT:
┌─────────────────────────┬──────────────┬──────────────────────┐
│ Feature                 │ Dependabot   │ Renovate             │
├─────────────────────────┼──────────────┼──────────────────────┤
│ GitHub-native           │ Yes          │ Via GitHub App       │
│ Ecosystems supported    │ ~15          │ 90+                  │
│ Automerge              │ Via workflow  │ Built-in             │
│ Grouping               │ Basic        │ Advanced (regex)     │
│ Scheduling             │ Basic        │ Cron-level control   │
│ Custom file formats    │ No           │ Regex manager        │
│ Dashboard              │ No           │ Yes (tracking issue) │
│ Replacement awareness  │ No           │ Yes                  │
│ Self-hosted            │ No           │ Yes                  │
│ Config complexity      │ Low          │ Medium               │
│ Setup effort           │ Minimal      │ Moderate             │
│ Best for               │ Simple repos │ Complex/monorepo     │
└─────────────────────────┴──────────────┴──────────────────────┘
```

### Step 4: Security Scanning
Scan dependencies for known vulnerabilities across ecosystems:

```
SECURITY SCANNING TOOLS:
┌──────────────┬──────────────┬────────────────────────────────────┐
│ Tool         │ Ecosystem    │ Command                            │
├──────────────┼──────────────┼────────────────────────────────────┤
│ npm audit    │ JavaScript   │ npm audit [--json]                 │
│ pnpm audit   │ JavaScript   │ pnpm audit [--json]                │
│ yarn audit   │ JavaScript   │ yarn audit [--json]                │
│ pip-audit    │ Python       │ pip-audit [-r requirements.txt]    │
│ safety       │ Python       │ safety check                       │
│ govulncheck  │ Go           │ govulncheck ./...                  │
│ cargo audit  │ Rust         │ cargo audit                        │
│ bundler-audit│ Ruby         │ bundle audit                       │
│ Snyk         │ Multi-lang   │ snyk test [--all-projects]         │
│ Trivy        │ Multi-lang   │ trivy fs --scanners vuln .         │
│ Grype        │ Multi-lang   │ grype dir:.                        │
│ OSV-Scanner  │ Multi-lang   │ osv-scanner --recursive .          │
└──────────────┴──────────────┴────────────────────────────────────┘

SNYK INTEGRATION:
  # Install Snyk CLI
  npm install -g snyk
  snyk auth

  # Test for vulnerabilities
  snyk test                        # Current project
  snyk test --all-projects         # Monorepo / multi-project
  snyk test --severity-threshold=high  # Only high+ severity

  # Monitor (continuous tracking)
  snyk monitor                     # Add to Snyk dashboard

  # Fix vulnerabilities
  snyk fix                         # Auto-apply patches

  # Container scanning
  snyk container test <image>

  # IaC scanning
  snyk iac test

  # CI integration (.github/workflows/snyk.yml)
  name: Snyk Security Scan
  on: [push, pull_request]
  jobs:
    snyk:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Run Snyk
          uses: snyk/actions/node@master
          env:
            SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
          with:
            args: --severity-threshold=high

ECOSYSTEM-SPECIFIC SCANNING:
  # JavaScript
  npm audit --audit-level=high
  npm audit fix                    # Auto-fix compatible updates
  npx better-npm-audit audit       # Better formatted output

  # Python
  pip install pip-audit
  pip-audit                        # Scan installed packages
  pip-audit -r requirements.txt    # Scan requirements file
  pip-audit --fix                  # Auto-fix vulnerabilities

  # Go
  go install golang.org/x/vuln/cmd/govulncheck@latest
  govulncheck ./...                # Scan all packages
  govulncheck -test ./...          # Include test dependencies

  # Rust
  cargo install cargo-audit
  cargo audit                      # Scan Cargo.lock
  cargo audit fix                  # Auto-fix vulnerabilities

VULNERABILITY REMEDIATION WORKFLOW:
┌─────────────────────────────────────────────────────────────────┐
│ 1. IDENTIFY: Run scanner (npm audit / snyk test / trivy)       │
│ 2. TRIAGE: Classify by severity and exploitability             │
│    - Is the vulnerable code path reachable?                     │
│    - Is it a direct or transitive dependency?                   │
│    - Is there a known exploit in the wild?                      │
│ 3. FIX: Apply remediation in order of preference               │
│    a. Update to patched version (npm audit fix)                │
│    b. Update parent dependency (if transitive)                 │
│    c. Apply override/resolution to force version               │
│    d. Replace dependency with secure alternative               │
│    e. Apply Snyk patch (snyk protect)                          │
│    f. Accept risk with documented justification                │
│ 4. VERIFY: Re-run scanner to confirm fix                       │
│ 5. PREVENT: Add scanning to CI pipeline                        │
│ 6. DOCUMENT: Log CVE, fix, and rationale in security log       │
└─────────────────────────────────────────────────────────────────┘

SEVERITY RESPONSE MATRIX:
┌──────────┬───────────────┬───────────────────────────────────────┐
│ Severity │ SLA           │ Action                                │
├──────────┼───────────────┼───────────────────────────────────────┤
│ CRITICAL │ Fix in 24h    │ Block deploy. Hotfix immediately.     │
│ HIGH     │ Fix in 72h    │ Block deploy if exploitable. Patch.   │
│ MODERATE │ Fix in 1 week │ Track in issue. Fix in next sprint.   │
│ LOW      │ Fix in 30 days│ Batch with maintenance cycle.         │
└──────────┴───────────────┴───────────────────────────────────────┘
```

### Step 5: SBOM Generation
Generate Software Bill of Materials for compliance and visibility:

```
SBOM GENERATION:
┌──────────────────┬──────────────────────────────────────────────┐
│ Tool             │ Command                                      │
├──────────────────┼──────────────────────────────────────────────┤
│ syft (Anchore)   │ syft dir:. -o spdx-json > sbom.spdx.json   │
│ cdxgen           │ cdxgen -o sbom.json                         │
│ trivy            │ trivy fs --format spdx-json -o sbom.json .  │
│ npm              │ npm sbom --sbom-format spdx                 │
│ CycloneDX (npm)  │ npx @cyclonedx/cyclonedx-npm --output-file  │
│                  │ sbom.cdx.json                                │
│ CycloneDX (pip)  │ cyclonedx-py environment -o sbom.cdx.json   │
│ CycloneDX (Go)   │ cyclonedx-gomod app -json -output sbom.json │
└──────────────────┴──────────────────────────────────────────────┘

SBOM FORMATS:
  SPDX:       ISO standard (ISO/IEC 5962:2021), required by US EO 14028
  CycloneDX:  OWASP standard, richer vulnerability and licensing data
  SWID:       ISO/IEC 19770-2, used in enterprise asset management

CI INTEGRATION (generate SBOM on every release):
  # .github/workflows/sbom.yml
  name: Generate SBOM
  on:
    release:
      types: [published]
  jobs:
    sbom:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: anchore/sbom-action@v0
          with:
            format: spdx-json
            output-file: sbom.spdx.json
        - uses: actions/upload-artifact@v4
          with:
            name: sbom
            path: sbom.spdx.json
        - name: Attach SBOM to release
          run: gh release upload ${{ github.event.release.tag_name }} sbom.spdx.json
          env:
            GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

SBOM ANALYSIS:
  # Scan SBOM for vulnerabilities
  grype sbom:sbom.spdx.json
  trivy sbom sbom.spdx.json

  # Query SBOM contents
  syft convert sbom.spdx.json -o table   # Human-readable table
```

### Step 6: License Compliance Scanning
Ensure all dependencies have compatible licenses:

```
LICENSE COMPLIANCE:
┌──────────────────┬──────────────────────────────────────────────┐
│ Tool             │ Command                                      │
├──────────────────┼──────────────────────────────────────────────┤
│ license-checker  │ npx license-checker --summary                │
│ license-checker  │ npx license-checker --failOn "GPL-3.0;AGPL"  │
│ licensee (Ruby)  │ licensee detect .                            │
│ pip-licenses     │ pip-licenses --format=table                  │
│ go-licenses      │ go-licenses check ./...                      │
│ cargo-license    │ cargo license                                │
│ FOSSA            │ fossa analyze                                │
│ Snyk             │ snyk test --license                          │
└──────────────────┴──────────────────────────────────────────────┘

LICENSE COMPATIBILITY MATRIX:
┌──────────────┬──────────────────────────────────────────────────┐
│ License      │ Notes                                            │
├──────────────┼──────────────────────────────────────────────────┤
│ MIT          │ Permissive. Safe for any use.                    │
│ Apache-2.0   │ Permissive. Patent grant. Safe for most use.    │
│ BSD-2/3      │ Permissive. Safe for any use.                    │
│ ISC          │ Permissive. Equivalent to MIT.                   │
│ MPL-2.0      │ Weak copyleft. File-level copyleft only.        │
│ LGPL-2.1/3.0 │ Weak copyleft. Dynamic linking usually OK.      │
│ GPL-2.0/3.0  │ Strong copyleft. Derivative works must be GPL.  │
│ AGPL-3.0     │ Network copyleft. Server use triggers copyleft. │
│ SSPL         │ Non-OSI. Avoid for commercial SaaS.             │
│ BSL          │ Source available but NOT open source.            │
│ Unlicense    │ Public domain equivalent. Safe for any use.      │
│ UNLICENSED   │ No license = all rights reserved. Do NOT use.   │
└──────────────┴──────────────────────────────────────────────────┘

POLICY ENFORCEMENT:
  # .licensechecker.json
  {
    "allowedLicenses": [
      "MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause",
      "ISC", "0BSD", "Unlicense", "CC0-1.0"
    ],
    "blockedLicenses": [
      "GPL-2.0", "GPL-3.0", "AGPL-3.0", "SSPL-1.0"
    ],
    "exceptions": {
      "@example/internal-tool": "GPL-3.0 — internal use only, not distributed"
    }
  }

  # CI enforcement
  npx license-checker --failOn "GPL-3.0;AGPL-3.0;SSPL-1.0" --production
```

### Step 7: Dependency Pinning Strategies
Choose the right version pinning approach:

```
PINNING STRATEGIES:
┌─────────────────┬──────────────────────────────────────────────┐
│ Strategy        │ package.json example                         │
├─────────────────┼──────────────────────────────────────────────┤
│ Exact pin       │ "lodash": "4.17.21"                         │
│ Patch range     │ "lodash": "~4.17.21"   (>=4.17.21 <4.18.0) │
│ Minor range     │ "lodash": "^4.17.21"   (>=4.17.21 <5.0.0)  │
│ Any             │ "lodash": "*"          (DO NOT USE)          │
└─────────────────┴──────────────────────────────────────────────┘

WHEN TO USE EACH:
┌─────────────────────────────────┬────────────────────────────────┐
│ Context                         │ Recommended Strategy           │
├─────────────────────────────────┼────────────────────────────────┤
│ Application (deployed)          │ Exact pin + lock file          │
│ Library (published)             │ Caret (^) ranges               │
│ Critical security dependency    │ Exact pin                      │
│ CI tooling (GitHub Actions)     │ Pin to SHA digest              │
│ Docker base images              │ Pin to SHA digest              │
│ Dev dependencies                │ Caret (^) ranges               │
│ Internal workspace packages     │ workspace:* protocol           │
└─────────────────────────────────┴────────────────────────────────┘

GITHUB ACTIONS PINNING:
  # BAD: Mutable tag, supply chain risk
  - uses: actions/checkout@v4

  # GOOD: Pinned to SHA digest (immutable)
  - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

  # Renovate auto-updates SHA pins with comment tags
  # Add to renovate.json:
  {
    "packageRules": [
      {
        "matchManagers": ["github-actions"],
        "pinDigests": true
      }
    ]
  }

DOCKER IMAGE PINNING:
  # BAD: Mutable tag
  FROM node:20-alpine

  # GOOD: Pinned to digest
  FROM node:20-alpine@sha256:abc123...

  # Renovate auto-updates digest pins
```

### Step 8: Lock File Management
Ensure lock file integrity and correct usage:

```
LOCK FILE BEST PRACTICES:
┌─────────────────────────────────────────────────────────────────┐
│ 1. ALWAYS commit lock files to version control                  │
│ 2. NEVER manually edit lock files                               │
│ 3. Use frozen installs in CI (npm ci, --frozen-lockfile)        │
│ 4. One package manager per project (never mix lock files)       │
│ 5. Review lock file diffs in PRs (detect supply chain attacks)  │
│ 6. Validate lock file integrity in CI                           │
└─────────────────────────────────────────────────────────────────┘

LOCK FILE INTEGRITY CHECKING:
  # lockfile-lint — validate lock file security
  npm install -D lockfile-lint

  # .lockfile-lintrc.json
  {
    "path": "package-lock.json",
    "type": "npm",
    "allowedHosts": ["npm"],
    "allowedSchemes": ["https:"],
    "allowedUrls": [],
    "emptyHostname": false,
    "validatePackageNames": true,
    "validateHttps": true
  }

  # Run in CI
  npx lockfile-lint \
    --path package-lock.json \
    --type npm \
    --allowed-hosts npm \
    --validate-https \
    --validate-package-names

LOCK FILE ATTACK VECTORS:
┌─────────────────────────────────────────────────────────────────┐
│ Attack                    │ How lockfile-lint prevents it        │
├───────────────────────────┼─────────────────────────────────────┤
│ Registry hijack           │ --allowed-hosts npm                 │
│ HTTP downgrade            │ --validate-https                    │
│ Typosquatting             │ --validate-package-names            │
│ Dependency confusion      │ --allowed-hosts (block private +    │
│                           │  public registry mix)               │
│ Malicious URL injection   │ --allowed-urls (whitelist)          │
└───────────────────────────┴─────────────────────────────────────┘

FROZEN INSTALLS IN CI:
┌────────────────┬────────────────────────────────────────────────┐
│ Package Manager│ CI Install Command                             │
├────────────────┼────────────────────────────────────────────────┤
│ npm            │ npm ci                                         │
│ pnpm           │ pnpm install --frozen-lockfile                 │
│ yarn (classic) │ yarn install --frozen-lockfile                 │
│ yarn (berry)   │ yarn install --immutable                       │
│ bun            │ bun install --frozen-lockfile                  │
│ pip            │ pip install -r requirements.txt --require-hashes│
│ poetry         │ poetry install --no-update                     │
│ go             │ go mod verify                                  │
│ cargo          │ cargo install --locked                         │
└────────────────┴────────────────────────────────────────────────┘
```

### Step 9: Supply Chain Attack Prevention
Harden the dependency supply chain:

```
SUPPLY CHAIN SECURITY CHECKLIST:
┌─────────────────────────────────────────────────────────────────┐
│ Layer              │ Tool / Practice                             │
├────────────────────┼─────────────────────────────────────────────┤
│ Registry           │ lockfile-lint (validate allowed hosts)      │
│ Package integrity  │ npm audit signatures (verify provenance)    │
│ Lock file          │ lockfile-lint (validate HTTPS, hostnames)   │
│ Install scripts    │ --ignore-scripts, review preinstall hooks   │
│ Typosquatting      │ socket.dev (detect name confusion)          │
│ Malicious packages │ socket.dev (behavioral analysis)            │
│ Dependency count   │ depcheck (remove unused deps)               │
│ CI/CD              │ Pin GitHub Actions to SHA digests            │
│ Docker             │ Pin base images to SHA digests               │
│ Publishing         │ npm publish --provenance (link to CI)       │
│ Code review        │ Review lock file diffs in every PR          │
└────────────────────┴─────────────────────────────────────────────┘

SOCKET.DEV INTEGRATION:
  # Install Socket CLI
  npm install -g @socketsecurity/cli

  # Scan for supply chain risks
  socket scan create --repo . --branch main

  # Check specific package before installing
  socket npm info <package-name>

  # CI integration (GitHub App)
  # Install Socket GitHub App — auto-comments on PRs with new deps
  # Detects: typosquatting, install scripts, obfuscated code,
  #          network access, filesystem access, telemetry

SOCKET RISK CATEGORIES:
┌───────────────────────┬──────────────────────────────────────────┐
│ Risk                  │ Description                              │
├───────────────────────┼──────────────────────────────────────────┤
│ Install scripts       │ Runs code during npm install             │
│ Network access        │ Makes HTTP requests at runtime           │
│ Filesystem access     │ Reads/writes files outside package dir   │
│ Shell access          │ Spawns child processes                   │
│ Obfuscated code       │ Minified/encoded source in published pkg │
│ Typosquatting         │ Name similar to popular package          │
│ Protestware           │ Behavior changes based on locale/env     │
│ Telemetry             │ Collects usage data                      │
│ Troll package         │ Intentionally broken or malicious        │
│ Deprecated            │ No longer maintained                     │
│ Unmaintained          │ No updates in >2 years                   │
└───────────────────────┴──────────────────────────────────────────┘

INSTALL SCRIPT SAFETY:
  # Audit install scripts before running
  npm install --ignore-scripts <package>
  npm ls --all --json | jq '.dependencies | .. | .scripts? // empty | select(.preinstall or .install or .postinstall)'

  # Block install scripts globally (opt-in per package)
  # .npmrc
  ignore-scripts=true

  # Allow specific packages to run scripts
  # package.json
  {
    "scripts": {
      "prepare": "npm rebuild esbuild && npm rebuild sharp"
    }
  }

NPM PROVENANCE:
  # Publish with provenance (links package to CI build)
  npm publish --provenance

  # Verify provenance
  npm audit signatures

  # Check specific package provenance
  npm view <package> --json | jq '.dist.attestations'
```

### Step 10: Automated PR Merging for Patches
Set up safe automated merging of dependency updates:

```
AUTOMERGE STRATEGY:
┌────────────────────────┬────────────────────────────────────────┐
│ Update Type            │ Automerge Policy                       │
├────────────────────────┼────────────────────────────────────────┤
│ Security patches       │ Auto-merge immediately (any severity)  │
│ Patch versions         │ Auto-merge after CI passes             │
│ Minor (dev deps)       │ Auto-merge after CI passes             │
│ Minor (prod deps)      │ Require 1 approval + CI passes         │
│ Major versions         │ Require review + approval              │
│ Pre-release            │ Never auto-merge                       │
└────────────────────────┴────────────────────────────────────────┘

GITHUB BRANCH PROTECTION FOR AUTOMERGE:
  Settings > Branches > main:
    ✅ Require pull request reviews before merging
    ✅ Require status checks to pass before merging
    ✅ Allow auto-merge

RENOVATE AUTOMERGE CONFIGURATION:
  {
    "packageRules": [
      {
        "description": "Automerge all patch updates after CI",
        "matchUpdateTypes": ["patch", "pin", "digest"],
        "automerge": true,
        "automergeType": "pr",
        "platformAutomerge": true,
        "minimumReleaseAge": "3 days"
      },
      {
        "description": "Automerge minor dev dependency updates",
        "matchUpdateTypes": ["minor"],
        "matchDepTypes": ["devDependencies"],
        "automerge": true,
        "minimumReleaseAge": "7 days"
      },
      {
        "description": "Security fixes: merge immediately",
        "matchCategories": ["security"],
        "automerge": true,
        "schedule": ["at any time"],
        "minimumReleaseAge": "0 days",
        "prPriority": 10
      }
    ],
    "automergeSchedule": ["before 6am every weekday"]
  }

MERGE QUEUE SAFETY:
  # Renovate merge confidence (stability score)
  {
    "extends": ["mergeConfidence:all-badges"]
  }
  # Shows adoption %, age, and confidence badge on each PR
  # Options: "low", "neutral", "high", "very high"

  # Minimum release age (avoid publishing-day surprises)
  {
    "minimumReleaseAge": "3 days",          # Wait 3 days
    "internalChecksFilter": "strict"        # Require all checks pass
  }
```

### Step 11: Dependency Management Report

```
┌────────────────────────────────────────────────────────────────┐
│  DEPENDENCY MANAGEMENT REPORT                                  │
├────────────────────────────────────────────────────────────────┤
│  Ecosystem(s): <JavaScript | Python | Go | multi>             │
│  Package manager(s): <npm | pnpm | pip | go mod | etc.>       │
│                                                                │
│  Dependencies:                                                 │
│    Direct: <N>                                                 │
│    Transitive: <N>                                             │
│    Outdated (major): <N>                                       │
│    Outdated (minor/patch): <N>                                 │
│                                                                │
│  Security:                                                     │
│    Vulnerabilities: C:<N> H:<N> M:<N> L:<N>                   │
│    Fixed: <N>                                                  │
│    Accepted risk: <N> (with justification)                    │
│    Scan tool: <npm audit | Snyk | Trivy | etc.>              │
│                                                                │
│  Automation:                                                   │
│    Update tool: <Renovate | Dependabot> configured            │
│    Automerge: patches=<yes|no> minor-dev=<yes|no>             │
│    Schedule: <description>                                     │
│    CI scanning: <tool and frequency>                          │
│                                                                │
│  Supply chain:                                                 │
│    Lock file integrity: <lockfile-lint configured | manual>   │
│    Provenance: <enabled | not enabled>                        │
│    Install scripts: <audited | blocked | unrestricted>        │
│    SBOM: <generated | not generated>                          │
│                                                                │
│  License compliance:                                           │
│    Status: <all clear | N violations>                         │
│    Blocked licenses: <list>                                   │
│    Exceptions: <N documented>                                 │
│                                                                │
│  Actions taken:                                                │
│    - <list of changes>                                        │
│                                                                │
│  Recommendations:                                              │
│    - <list of suggestions>                                    │
│                                                                │
│  Ready for: /godmode:secure or /godmode:cicd                  │
└────────────────────────────────────────────────────────────────┘
```

### Step 12: Commit and Transition
1. Commit config files: `"deps: configure <Renovate|Dependabot> for automated dependency updates"`
2. Commit security fixes: `"security: fix <N> dependency vulnerabilities (<critical|high>)"`
3. Commit SBOM/license config: `"comply: add SBOM generation and license compliance scanning"`
4. After dependency management: "Dependencies secured. Use `/godmode:secure` for full security audit or `/godmode:cicd` to integrate scanning into your pipeline."

## Key Behaviors

1. **Automate everything.** Manual dependency updates do not scale. Set up Renovate or Dependabot from day one. Automerge patches. Schedule reviews for major updates.
2. **Security scanning is non-negotiable.** Run vulnerability scans in CI on every PR. Block deploys on CRITICAL/HIGH findings. Automate security patch PRs with zero-delay merging.
3. **Lock files are your safety net.** Always commit them. Always use frozen installs in CI. Validate integrity with lockfile-lint. Review diffs for supply chain attacks.
4. **SBOM is becoming mandatory.** US Executive Order 14028 requires SBOMs for government software. Generate them in CI. Attach them to releases. Use SPDX or CycloneDX format.
5. **License compliance prevents legal risk.** Scan dependencies before they enter your codebase. Block copyleft licenses (GPL, AGPL) in commercial products. Document all exceptions.
6. **Supply chain security is layered.** No single tool catches everything. Combine lockfile-lint (registry), socket.dev (behavioral), Snyk (CVEs), and provenance (build attestation).
7. **Pin for reproducibility, range for compatibility.** Applications pin exact versions. Libraries use caret ranges. CI tooling and Docker images pin to SHA digests.
8. **Minimum release age prevents zero-day supply chain attacks.** Wait 3 days before automerging any non-security update. Most malicious packages are caught within 72 hours.

## Example Usage

### Setting up Renovate for a monorepo
```
User: /godmode:dependencies Set up automated dependency updates for our
      TypeScript monorepo. We use pnpm and want safe automerging.

Dependencies: Assessing dependency landscape...

CONTEXT:
  Monorepo: 12 packages (pnpm workspaces)
  Outdated: 47 packages (3 major, 18 minor, 26 patch)
  Vulnerabilities: 2 high, 5 moderate
  Current automation: none

PLAN:
  1. Renovate (best monorepo support, flexible grouping)
  2. Automerge: patches immediately, minor dev deps after 3 days
  3. Group: lint tools, test tools, framework packages
  4. Schedule: Monday mornings, security fixes anytime
  5. Branch protection: require CI + 1 approval for major

Setting up...

Created:
  - renovate.json with automerge rules and grouping
  - .github/workflows/lockfile-lint.yml for integrity checks
  - Security fix PRs auto-created for 2 high vulns

Commit: "deps: configure Renovate with automerge and security scanning"
```

### Responding to a critical vulnerability
```
User: /godmode:dependencies We just got a Snyk alert about a critical
      CVE in one of our transitive dependencies. What do we do?

Dependencies: Running vulnerability remediation workflow...

VULNERABILITY:
  CVE-2024-XXXXX in xml2js@0.4.23 (prototype pollution)
  Severity: CRITICAL (CVSS 9.8)
  Path: express > body-parser > xml2js
  Fix available: xml2js@0.6.0
  Exploitable: Yes (XML parsing in API routes)

REMEDIATION:
  1. Immediate: Add override to force xml2js@0.6.0
     "overrides": { "xml2js": ">=0.6.0" }

  2. Verify: npm audit shows 0 critical vulnerabilities

  3. Test: All API routes handling XML still function

  4. Upstream: body-parser@2.0.0 includes fix
     -> Created issue to update body-parser in next sprint

  5. CI: Added Snyk to CI pipeline to catch future vulns

Commit: "security: fix critical CVE-2024-XXXXX in xml2js (prototype pollution)"
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full dependency management assessment |
| `--renovate` | Set up or reconfigure Renovate |
| `--dependabot` | Set up or reconfigure Dependabot |
| `--scan` | Run security vulnerability scan across all ecosystems |
| `--sbom` | Generate Software Bill of Materials |
| `--license` | Run license compliance scan |
| `--pin` | Apply recommended pinning strategy |
| `--lockfile` | Validate lock file integrity |
| `--automerge` | Configure automated PR merging rules |
| `--supply-chain` | Full supply chain security audit |
| `--remediate` | Interactive vulnerability remediation |
| `--outdated` | Check all ecosystems for outdated dependencies |
| `--socket` | Run socket.dev supply chain analysis |
| `--ci` | CI-friendly output (exit code 1 on issues) |

## HARD RULES

1. **NEVER skip Renovate or Dependabot setup.** Manual dependency updates fall behind. Within 6 months, projects without automation accumulate 50+ outdated packages and miss critical security patches.
2. **NEVER automerge major version updates.** Major versions contain breaking changes by definition. Always require human review.
3. **NEVER use `npm audit fix --force` in CI.** Force-fixing can introduce breaking changes by jumping major versions. Only run interactive fixes locally.
4. **NEVER skip lock file integrity checks in CI.** Lock files can be manipulated to point to malicious registries. Use lockfile-lint to validate.
5. **NEVER accept `UNLICENSED` dependencies.** No license means all rights reserved. Replace the package or get explicit permission.
6. **NEVER mix Renovate and Dependabot.** Running both creates duplicate PRs, merge conflicts, and confusion. Choose one.
7. **ALWAYS verify transitive vulnerabilities.** "It's not our direct dependency" is not a valid security posture. Use overrides to patch.
8. **ALWAYS audit install scripts for new dependencies.** Packages can execute arbitrary code during `npm install`.

## Auto-Detection

On activation, detect the dependency management context:

```bash
# Detect package ecosystems
ls package.json package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null  # JS
ls requirements.txt Pipfile poetry.lock pyproject.toml 2>/dev/null  # Python
ls Gemfile Gemfile.lock 2>/dev/null  # Ruby
ls go.mod go.sum 2>/dev/null  # Go
ls Cargo.toml Cargo.lock 2>/dev/null  # Rust

# Detect existing automation
ls .github/dependabot.yml renovate.json renovate.json5 .renovaterc* 2>/dev/null

# Detect vulnerability scanning
grep -r "snyk\|socket\|audit\|trivy\|grype" .github/ package.json 2>/dev/null

# Count outdated dependencies
npm outdated 2>/dev/null | tail -n +2 | wc -l
```

## Iteration Protocol

For large-scale dependency update campaigns:

```
current_batch = 0
batches = [critical_security, major_updates, minor_updates, dev_dependencies]

WHILE current_batch < len(batches):
  batch = batches[current_batch]
  1. Identify all updates in this batch category
  2. Apply updates (one PR per major, grouped for minor/patch)
  3. Run full test suite after each update
  4. Verify no breaking changes or vulnerability regressions
  current_batch += 1
  Report: "Dependency batch {current_batch}/{len(batches)}: {batch} -- {updated_count} packages updated, {remaining} remaining"

AFTER all batches:
  Generate SBOM
  Run final vulnerability scan
  Report overall health improvement
```

## Anti-Patterns

- **Do NOT skip Renovate/Dependabot setup.** Manual dependency updates fall behind. Within 6 months, projects without automation accumulate 50+ outdated packages and miss critical security patches.
- **Do NOT automerge major version updates.** Major versions contain breaking changes by definition. Always require human review and approval before merging major bumps.
- **Do NOT ignore transitive vulnerabilities.** "It's not our direct dependency" is not a valid security posture. Transitive vulnerabilities are exploitable. Use overrides to patch them.
- **Do NOT use `npm audit fix --force` in CI.** Force-fixing can introduce breaking changes by jumping major versions. Only run interactive fixes locally with human review.
- **Do NOT skip lock file integrity checks.** Lock files can be manipulated to point to malicious registries. Use lockfile-lint in CI to validate every PR.
- **Do NOT trust install scripts blindly.** Packages can execute arbitrary code during `npm install`. Audit install scripts for new dependencies. Consider `--ignore-scripts` by default.
- **Do NOT commit without an SBOM strategy.** Regulatory requirements (EO 14028, EU CRA) increasingly mandate SBOMs. Set up generation early rather than retrofitting.
- **Do NOT mix Renovate and Dependabot.** Running both creates duplicate PRs, merge conflicts, and confusion. Choose one and disable the other.
- **Do NOT accept `UNLICENSED` dependencies.** No license means all rights reserved. You have no legal right to use the package. Replace it or get explicit permission.
