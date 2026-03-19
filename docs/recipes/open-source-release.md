# Recipe: Open-Sourcing a Project

> From internal code to public repository. A complete Godmode workflow for preparing, releasing, and maintaining an open-source project.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `quality → secure → docs → a11y → comply → lint → review → release → ship` |
| **Timeline** | 1-2 weeks preparation, ongoing maintenance |
| **Team size** | 1-3 engineers + legal review |
| **Example project** | "FlowDB" — an internal time-series database library being open-sourced |

---

## The Scenario

Your company built FlowDB, a high-performance time-series database client library:
- TypeScript library, 15K lines of code
- Used internally by 6 teams for 2 years
- Well-tested (92% coverage) but internal-only assumptions throughout
- Contains hardcoded internal URLs, company-specific configs, and references to proprietary systems
- Legal has approved open-sourcing under Apache 2.0
- Goal: Public GitHub release that attracts community adoption

---

## Phase 1: Code Audit and Cleanup (Day 1-3)

### Step 1: Quality — Assess Open-Source Readiness

```
> /godmode:quality --context open-source-release

Godmode: Analyzing code for open-source readiness...

QUALITY REPORT (Open-Source Lens):

Code quality:
  Cyclomatic complexity: 7.2 avg (good, target < 10)
  Duplication: 3.4% (acceptable)
  Test coverage: 92% (good)
  Type coverage: 98% (excellent)

Open-source readiness issues:
  CRITICAL:
    1. 14 references to internal.company.com (hardcoded URLs)
    2. 3 files import from @company/internal-utils (private package)
    3. AWS account ID in 2 test fixtures
    4. Internal Slack webhook URL in error reporting
    5. Employee email addresses in code comments (3 instances)

  HIGH:
    1. No public API documentation (JSDoc comments sparse)
    2. No CHANGELOG.md
    3. No CONTRIBUTING.md
    4. No CODE_OF_CONDUCT.md
    5. package.json has private registry URL
    6. .npmrc points to internal Artifactory

  MEDIUM:
    1. Error messages reference internal Jira ticket numbers
    2. Some variable names use company-specific terminology
    3. No browser compatibility information
    4. README is internal-focused (assumes company infra)
    5. No examples directory

  LOW:
    1. Some TODO comments reference internal employees
    2. Git history contains internal branch naming (JIRA-1234)
    3. No issue templates
    4. No PR template

Saved: docs/quality/open-source-readiness.md
```

### Step 2: Secure — Security Audit Before Going Public

```
> /godmode:secure --context open-source

Godmode: Running security audit with open-source focus...

SECURITY AUDIT (Open-Source Context):

Secret scanning:
  ✗ FAIL — AWS account ID in tests/fixtures/config.json
  ✗ FAIL — Internal Slack webhook URL in src/reporting.ts
  ✗ FAIL — API key placeholder that looks like a real key in docs/example.ts
  ✓ PASS — No actual API keys or passwords found

Supply chain security:
  ✓ PASS — package-lock.json present (reproducible builds)
  ✗ FAIL — 2 dependencies with known CVEs (low severity)
  ✓ PASS — No dependency confusion risk (scoped packages)
  ⚠ WARN — 7 dependencies with no maintenance in 2+ years

Code security:
  ✓ PASS — No eval() or Function() usage
  ✓ PASS — No prototype pollution vectors
  ✓ PASS — Input validation on all public APIs
  ✗ FAIL — Unsafe regex in query parser (ReDoS possible)
  ✓ PASS — No command injection vectors

Attack surface for public library:
  - ReDoS via crafted query strings → FIX before release
  - Denial of service via unbounded batch operations → ADD limits
  - Type confusion if used with plain JavaScript → ADD runtime validation

Saved: docs/security/pre-release-audit.md
```

### Step 3: Fix — Remove Internal References and Fix Security Issues

```
> /godmode:fix --open-source-prep

Godmode: Cleaning code for open-source release...

CLEANUP ACTIONS:

1. Internal references removed:
   ✓ 14 hardcoded URLs → configurable via options
   ✓ 3 internal package imports → reimplemented locally (42 lines)
   ✓ AWS account ID → replaced with placeholder in test fixtures
   ✓ Slack webhook → removed, added pluggable error reporting hook
   ✓ Employee emails → removed from comments
   ✓ Internal Jira references → removed from error messages
   ✓ package.json registry → set to public npm
   ✓ .npmrc → deleted (was pointing to internal Artifactory)

2. Security fixes:
   ✓ ReDoS regex fixed (added complexity limit)
   ✓ Batch operation size limit added (max 10,000)
   ✓ 2 vulnerable dependencies updated

3. Company-specific terminology:
   ✓ "companyMetric" → "metric" (throughout codebase)
   ✓ "internalClient" → "client" (throughout codebase)

4. Git history:
   NOTE: Git history preserved. Internal references in commit messages
   remain but are harmless. If you want a clean history, squash all
   commits into an initial commit before pushing to public repo.

Commit: "chore: remove internal references for open-source release"
Commit: "fix(security): ReDoS prevention, batch size limits"
Commit: "fix: update vulnerable dependencies"
```

---

## Phase 2: Documentation (Day 3-5)

### Step 4: Docs — Comprehensive Documentation

```
> /godmode:docs --open-source

Godmode: Generating open-source documentation suite...

DOCUMENTATION GENERATED:

1. README.md — Complete project README
   Sections:
     - Project description and motivation
     - Features (with badges: build, coverage, npm version)
     - Quick start (install, basic usage in 5 lines)
     - API reference overview (links to detailed docs)
     - Performance benchmarks
     - Comparison with alternatives
     - Contributing link
     - License

2. docs/getting-started.md — Step-by-step setup guide
   - Installation (npm, yarn, pnpm)
   - Basic configuration
   - First query
   - Connection options
   - Error handling

3. docs/api-reference.md — Full API documentation
   Generated from JSDoc comments + TypeScript types
   Every public method documented with:
     - Description
     - Parameters (with types)
     - Return type
     - Example usage
     - Throws (error conditions)

4. docs/examples/ — Example code
   - basic-usage.ts
   - batch-insert.ts
   - querying.ts
   - aggregations.ts
   - streaming.ts
   - error-handling.ts
   - custom-configuration.ts

5. CHANGELOG.md — Version history
   Generated from Git history, cleaned up:
     v1.0.0 — Initial open-source release
     (internal versions omitted)

6. CONTRIBUTING.md — Contribution guide
   - How to report bugs
   - How to suggest features
   - Development setup
   - Code style guide
   - Testing requirements
   - PR process
   - Code of Conduct reference

7. CODE_OF_CONDUCT.md — Contributor Covenant v2.1

8. SECURITY.md — Security policy
   - Reporting vulnerabilities
   - Disclosure timeline
   - Supported versions

Commit: "docs: comprehensive open-source documentation"
```

### Step 5: A11y — Documentation Accessibility

```
> /godmode:a11y --docs

Godmode: Checking documentation accessibility...

DOCUMENTATION ACCESSIBILITY AUDIT:

Checks:
  ✓ All code examples have language annotations (syntax highlighting)
  ✓ Headings follow proper hierarchy (no skipped levels)
  ✓ Links have descriptive text (no "click here")
  ✗ FAIL — 2 images in README missing alt text
  ✓ Tables have header rows
  ✓ Color is not the only differentiator in examples
  ⚠ WARN — Some examples assume macOS terminal (add Windows/Linux variants)

Fixes applied:
  ✓ Added alt text to README images
  ✓ Added platform-specific install instructions

Commit: "docs: fix accessibility — alt text, cross-platform instructions"
```

---

## Phase 3: Legal and Compliance (Day 5-6)

### Step 6: Comply — License and Legal Compliance

```
> /godmode:comply --context open-source --license apache-2.0

Godmode: Running open-source compliance checks...

LICENSE COMPLIANCE:

1. Project license:
   ✓ LICENSE file present (Apache 2.0)
   ✓ License header in package.json
   ✓ Copyright notice correct

2. License header in source files:
   ✗ FAIL — 0 of 87 source files have license headers
   Apache 2.0 requires a boilerplate notice in each file.
   Fix: Add header to all .ts files

3. Dependency license audit:
   Total dependencies: 34 (direct + transitive)

   Compatible licenses:
     MIT:           22 packages  ✓
     Apache-2.0:    5 packages   ✓
     BSD-2-Clause:  3 packages   ✓
     BSD-3-Clause:  2 packages   ✓
     ISC:           1 package    ✓

   Potentially incompatible:
     GPL-3.0:       1 package    ✗ FAIL — "debug-utils" is GPL
                    This cannot be included in an Apache 2.0 project
                    as a dependency.
     UNKNOWN:       0 packages   ✓

   Action required:
     - Remove or replace "debug-utils" (GPL-3.0 incompatible with Apache 2.0)
     - Alternative: "pino" (MIT) or custom minimal logger

4. Patent clauses:
   ✓ Apache 2.0 includes patent grant
   ✓ No patent encumbered algorithms detected

5. NOTICE file:
   ✗ FAIL — Apache 2.0 requires a NOTICE file listing attributions
   Generated: NOTICE file with all dependency attributions

> /godmode:fix

Godmode: Fixing compliance issues...

Fix 1: Added Apache 2.0 license header to all 87 source files
Fix 2: Replaced "debug-utils" (GPL) with "pino" (MIT)
Fix 3: Created NOTICE file with dependency attributions

Commit: "comply: license headers, replace GPL dependency, add NOTICE file"
```

---

## Phase 4: Code Quality and CI (Day 6-7)

### Step 7: Lint — Enforce Code Standards

```
> /godmode:lint --strict

Godmode: Configuring lint and formatting for open-source...

LINTING SETUP:

1. ESLint configuration:
   File: .eslintrc.json
   Extends: @typescript-eslint/recommended-requiring-type-checking
   Rules: Strict mode (no implicit any, no unused vars, etc.)
   Result: 0 errors, 0 warnings (already clean)

2. Prettier configuration:
   File: .prettierrc
   Style: Consistent with community TypeScript standards
   All files formatted.

3. Pre-commit hooks:
   File: .husky/pre-commit
   Runs: lint-staged (ESLint + Prettier on staged files)

4. CI linting:
   File: .github/workflows/ci.yml
   Checks: lint, type-check, test, build
   Matrix: Node.js 18, 20, 22 (all LTS versions)

5. Package validation:
   File: .github/workflows/ci.yml
   Checks:
     - npm pack (verify publishable)
     - publint (check package.json correctness)
     - arethetypeswrong (verify TypeScript declarations)
     - size-limit (bundle size regression prevention)

Commit: "ci: comprehensive lint, test, and publish validation pipeline"
```

### Step 8: Review — Final Pre-Release Review

```
> /godmode:review --context open-source-release

Godmode: Running pre-release review...

OPEN-SOURCE RELEASE REVIEW:

Public API surface:
  ✓ All public exports documented
  ✓ No internal types leaked in public API
  ✓ Semantic versioning ready (clear major/minor/patch boundaries)
  ✓ TypeScript declarations correct (arethetypeswrong: pass)

Package quality:
  ✓ package.json: name, description, keywords, repository, bugs, homepage
  ✓ Engines: node >= 18
  ✓ Files: only dist/, LICENSE, README, CHANGELOG included in package
  ✓ Main, module, types, exports fields all correct
  ✓ Side effects: false (tree-shakeable)

Repository quality:
  ✓ README with badges, quickstart, API overview
  ✓ CONTRIBUTING.md with clear process
  ✓ CODE_OF_CONDUCT.md
  ✓ SECURITY.md
  ✓ LICENSE (Apache 2.0)
  ✓ NOTICE (attribution)
  ✓ CHANGELOG.md
  ✓ Issue templates (bug report, feature request)
  ✓ PR template
  ✓ .gitignore (no build artifacts, no .env)

CI/CD:
  ✓ Tests on 3 Node.js versions
  ✓ Lint + type check
  ✓ Bundle size check
  ✓ Package validation
  ✓ Automatic npm publish on tag
  ✓ Dependabot configured

MISSING (non-blocking but recommended):
  - No benchmarks in CI (track performance regressions)
  - No Codecov/Coveralls integration
  - No Discord/Slack community channel linked

Verdict: READY FOR RELEASE
```

---

## Phase 5: Release (Day 7-8)

### Step 9: Release — Publish to npm and GitHub

```
> /godmode:release --version 1.0.0

Godmode: Preparing v1.0.0 release...

PRE-RELEASE CHECKLIST:
  ✓ All tests passing (Node 18, 20, 22)
  ✓ Lint clean
  ✓ Types correct
  ✓ Bundle built successfully
  ✓ Package size: 24 KB (gzipped)
  ✓ No secrets in package
  ✓ License headers present
  ✓ CHANGELOG updated
  ✓ Documentation complete

RELEASE STEPS:

1. Version bump:
   ✓ package.json: 0.0.0-internal → 1.0.0
   ✓ CHANGELOG.md: Added v1.0.0 release notes

2. Build:
   ✓ npm run build — clean TypeScript compilation
   ✓ dist/ generated: ESM + CJS + type declarations

3. Package validation:
   ✓ npm pack — produces flowdb-1.0.0.tgz (24 KB)
   ✓ Package contents: only dist/, LICENSE, README, CHANGELOG, NOTICE
   ✓ No internal files leaked

4. Git tag:
   ✓ Tag: v1.0.0
   ✓ Signed with GPG key

5. GitHub Release:
   ✓ Created release: "FlowDB v1.0.0 — Initial Public Release"
   ✓ Release notes from CHANGELOG
   ✓ Artifacts: source archive, npm package

6. npm publish:
   ✓ Published: flowdb@1.0.0 to npm registry
   ✓ npm info flowdb — correctly shows package metadata
   ✓ npm install flowdb — installs successfully

Commit: "release: v1.0.0 — initial open-source release"
Tag: v1.0.0
```

### Step 10: Ship — Announce and Monitor

```
> /godmode:ship --open-source-launch

Godmode: Executing open-source launch plan...

LAUNCH CHECKLIST:

Repository setup:
  ✓ GitHub repository set to public
  ✓ Topics added: typescript, time-series, database, client
  ✓ Description set
  ✓ Website URL set to documentation site
  ✓ Discussions enabled
  ✓ Issue labels configured (bug, feature, docs, good-first-issue)
  ✓ Branch protection on main (require PR, require CI, require review)

Community preparation:
  ✓ 5 issues labeled "good first issue" created from backlog
  ✓ 3 issues labeled "help wanted" for community contribution
  ✓ Discussion post: "Welcome! Introduce yourself"

npm package:
  ✓ flowdb@1.0.0 published and installable

Announcement draft:
  ✓ Blog post draft: "Introducing FlowDB: Open-Source Time-Series Client"
  ✓ Twitter/X thread draft (5 tweets)
  ✓ Hacker News submission draft
  ✓ Reddit r/typescript post draft

Monitoring (first 48 hours):
  Track:
    - GitHub stars and forks
    - npm weekly downloads
    - Issue volume (triage within 24 hours)
    - First external PR
    - First community question

Saved: docs/launch/open-source-launch-plan.md
```

---

## Post-Launch: Ongoing Maintenance

### Weekly Maintenance Cycle

```
# Review new issues and PRs
/godmode:review --prs

# Update dependencies
/godmode:fix --dependencies

# Check for security advisories
/godmode:secure --quick

# Triage community issues
# Respond to discussions
```

### Monthly Release Cycle

```
# Review what has changed since last release
/godmode:quality --since-last-release

# If significant changes accumulated:
/godmode:release --version minor   # or patch for bug fixes

# Update CHANGELOG
/godmode:docs --changelog
```

### Community Health Metrics

| Metric | Week 1 Target | Month 1 Target | Month 6 Target |
|--------|-------------|---------------|----------------|
| GitHub stars | 50 | 500 | 2,000 |
| npm weekly downloads | 100 | 1,000 | 10,000 |
| Open issues | < 10 | < 20 | < 30 |
| Avg issue response time | < 48h | < 24h | < 12h |
| External PRs merged | 0 | 5 | 30 |
| Contributors | 3 (team) | 8 | 20 |

---

## Open-Source Release Checklist

```markdown
## Pre-Release Checklist

### Code
- [ ] All internal references removed (URLs, accounts, names)
- [ ] No secrets in code or git history
- [ ] Security audit passed
- [ ] Dependencies have compatible licenses
- [ ] Code quality meets open-source standards
- [ ] All public APIs documented

### Documentation
- [ ] README.md (badges, quickstart, API overview, contributing, license)
- [ ] CONTRIBUTING.md (how to contribute)
- [ ] CODE_OF_CONDUCT.md (Contributor Covenant)
- [ ] SECURITY.md (vulnerability reporting)
- [ ] CHANGELOG.md (version history)
- [ ] LICENSE (correct license text)
- [ ] NOTICE (if Apache 2.0 — attributions)
- [ ] API reference documentation
- [ ] Examples directory
- [ ] Getting started guide

### Infrastructure
- [ ] CI pipeline (test, lint, build on multiple versions)
- [ ] Automatic npm publish on tag
- [ ] Dependabot configured
- [ ] Issue templates (bug, feature, question)
- [ ] PR template
- [ ] Branch protection rules
- [ ] GitHub Discussions enabled

### Legal
- [ ] License approved by legal
- [ ] License headers in all source files
- [ ] Dependency license audit passed
- [ ] Patent review (if applicable)
- [ ] Trademark review (project name)

### Launch
- [ ] "Good first issue" labels on 5+ issues
- [ ] Announcement blog post drafted
- [ ] Social media posts drafted
- [ ] Community channels set up (Discord/Slack optional)
```

---

## Custom Chain for Open-Source Release

```yaml
# .godmode/chains.yaml
chains:
  open-source-release:
    description: "Prepare internal code for open-source release"
    steps:
      - quality:
          args: "--context open-source-release"
      - secure:
          args: "--context open-source"
      - fix:
          args: "--open-source-prep"
      - docs:
          args: "--open-source"
      - a11y:
          args: "--docs"
      - comply:
          args: "--context open-source --license apache-2.0"
      - lint:
          args: "--strict"
      - review:
          args: "--context open-source-release"
      - release
      - ship

  open-source-maintain:
    description: "Weekly open-source maintenance"
    steps:
      - review:
          args: "--prs"
      - secure:
          args: "--quick"
      - fix:
          args: "--dependencies"
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Security Hardening Recipe](security-hardening.md) — Deep security audit before public release
- [Full-Stack Feature Recipe](fullstack-feature.md) — Adding features to the open-source project
- [Team Onboarding Recipe](team-onboarding.md) — Onboarding open-source contributors
