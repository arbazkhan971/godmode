---
name: opensource
description: |
  Open source project management skill. Activates when user needs to set up, maintain, or grow an open source project. Covers repository scaffolding (LICENSE, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY), issue/PR template design, GitHub Actions for CI/CD, labeling, and stale issue management, community engagement (discussions, Discord/Slack), maintainer workflows (triage, review, release), and governance models (BDFL, consensus, steering committee). Triggers on: /godmode:opensource, "set up open source project", "add contributing guide", "configure issue templates", or when shipping a public repository.
---

# Opensource — Open Source Project Management

## When to Activate
- User invokes `/godmode:opensource`
- User says "set up open source project", "prepare repo for open source"
- User says "add contributing guide", "create code of conduct", "set up issue templates"
- User says "configure community health files", "add PR template"
- User says "set up governance", "maintainer workflow", "triage process"
- Project is being open-sourced or published publicly
- Repository is missing standard community health files
- Maintainer wants to improve contributor experience

## Workflow

### Step 1: Assess Repository Health
Audit the repository for standard open source files and practices:

```
REPOSITORY HEALTH CHECK:
┌──────────────────────────────────────────────────────────┐
│  File                    │ Status   │ Quality            │
│  ─────────────────────────────────────────────────────── │
│  LICENSE                 │ PRESENT/MISSING │ <assessment>│
│  README.md               │ PRESENT/MISSING │ <assessment>│
│  CONTRIBUTING.md         │ PRESENT/MISSING │ <assessment>│
│  CODE_OF_CONDUCT.md      │ PRESENT/MISSING │ <assessment>│
│  SECURITY.md             │ PRESENT/MISSING │ <assessment>│
│  CHANGELOG.md            │ PRESENT/MISSING │ <assessment>│
│  .github/ISSUE_TEMPLATE/ │ PRESENT/MISSING │ <assessment>│
│  .github/PULL_REQUEST_TEMPLATE.md │ PRESENT/MISSING │   │
│  .github/FUNDING.yml     │ PRESENT/MISSING │ <assessment>│
│  .github/CODEOWNERS      │ PRESENT/MISSING │ <assessment>│
│  .github/workflows/      │ PRESENT/MISSING │ <assessment>│
│  .editorconfig           │ PRESENT/MISSING │ <assessment>│
│  .gitignore              │ PRESENT/MISSING │ <assessment>│
└──────────────────────────────────────────────────────────┘

Health Score: <N>/13 files present
Missing critical files: <list>
Recommendation: <prioritized action list>
```

### Step 2: Repository Scaffolding
Generate or improve the core community health files:

#### LICENSE
```
LICENSE SELECTION:
Current license: <detected or none>
Recommendation: <based on project goals>

Considerations:
- Permissive (MIT, Apache 2.0): Maximum adoption, corporate-friendly
- Copyleft (GPL, AGPL): Ensures derivative work stays open
- Weak copyleft (LGPL, MPL 2.0): Library-friendly copyleft
- Source-available (BSL, SSPL): Open but with commercial restrictions

Selected: <license>
SPDX identifier: <identifier>
```

For detailed license guidance, use `/godmode:license`.

#### CODE_OF_CONDUCT.md
```markdown
# Contributor Covenant Code of Conduct

## Our Pledge
We as members, contributors, and leaders pledge to make participation
in our community a harassment-free experience for everyone, regardless
of age, body size, visible or invisible disability, ethnicity, sex
characteristics, gender identity and expression, level of experience,
education, socio-economic status, nationality, personal appearance,
race, caste, color, religion, or sexual identity and orientation.

## Our Standards
Examples of behavior that contributes to a positive environment:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

Examples of unacceptable behavior:
- The use of sexualized language or imagery, and sexual attention
  or advances of any kind
- Trolling, insulting or derogatory comments, and personal or
  political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate
  in a professional setting

## Enforcement Responsibilities
Community leaders are responsible for clarifying and enforcing our
standards of acceptable behavior and will take appropriate and fair
corrective action in response to any behavior that they deem
inappropriate, threatening, offensive, or harmful.

## Scope
This Code of Conduct applies within all community spaces, and also
applies when an individual is officially representing the community
in public spaces.

## Enforcement
Instances of abusive, harassing, or otherwise unacceptable behavior
may be reported to the community leaders responsible for enforcement
at [INSERT CONTACT METHOD].

All complaints will be reviewed and investigated promptly and fairly.

## Attribution
This Code of Conduct is adapted from the Contributor Covenant,
version 2.1, available at
https://www.contributor-covenant.org/version/2/1/code_of_conduct.html
```

#### CONTRIBUTING.md
```markdown
# Contributing to <Project Name>

Thank you for your interest in contributing! This document provides
guidelines and information for contributors.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)
- [Community](#community)

## Code of Conduct
This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

## Getting Started
1. Fork the repository
2. Clone your fork: `git clone https://github.com/<your-username>/<project>.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Push to your fork and submit a pull request

## Development Setup
```bash
# Install dependencies
<package-manager install command>

# Run tests
<test command>

# Start development server
<dev command>
```

## How to Contribute

### Reporting Bugs
- Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.yml) template
- Include reproduction steps, expected behavior, and actual behavior
- Include system information (OS, runtime version, etc.)

### Suggesting Features
- Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.yml) template
- Describe the problem the feature would solve
- Propose a solution and consider alternatives

### Code Contributions
- Look for issues labeled `good first issue` or `help wanted`
- Comment on the issue to claim it before starting work
- Follow the style guide and write tests for new functionality
- Keep pull requests focused — one feature or fix per PR

## Pull Request Process
1. Update documentation if you change public APIs
2. Add tests for new functionality
3. Ensure all tests pass and linting is clean
4. Update the CHANGELOG.md with your changes
5. Request review from maintainers
6. Address review feedback promptly

## Style Guide
- <Language-specific style conventions>
- <Formatting and linting rules>
- <Commit message conventions>

## Community
- [Discussions](https://github.com/<org>/<project>/discussions)
- [Discord/Slack](https://link-to-chat)
```

#### SECURITY.md
```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| x.x.x   | :white_check_mark: |
| < x.x.x | :x:                |

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following:
- GitHub Security Advisories: [Report a vulnerability](https://github.com/<org>/<project>/security/advisories/new)
- Email: security@<domain>

Please include:
- Type of issue (buffer overflow, SQL injection, XSS, etc.)
- Full paths of related source files
- Location of the affected source code (tag/branch/commit/direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue and how an attacker might exploit it

## Response Timeline
- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Fix and disclosure**: Within 90 days (coordinated disclosure)

## Security Updates
Security patches are released as soon as possible after a vulnerability
is confirmed. Subscribe to releases to receive notifications.
```

### Step 3: Issue & PR Template Design
Create structured templates for consistent issue reporting and pull requests:

#### Bug Report Template
```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: Report a bug or unexpected behavior
title: "[Bug]: "
labels: ["bug", "triage"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        Thanks for reporting a bug! Please fill out the information below.

  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: A clear and concise description of the bug.
      placeholder: What happened?
    validations:
      required: true

  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
      description: Detailed steps to reproduce the behavior.
      placeholder: |
        1. Go to '...'
        2. Click on '...'
        3. Scroll down to '...'
        4. See error
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: What did you expect to happen?
    validations:
      required: true

  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
      description: What actually happened?
    validations:
      required: true

  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - Critical (application crash, data loss)
        - High (major feature broken, no workaround)
        - Medium (feature broken, workaround exists)
        - Low (minor issue, cosmetic)
    validations:
      required: true

  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: System information relevant to the bug.
      placeholder: |
        - OS: [e.g., macOS 14.0, Ubuntu 22.04]
        - Runtime: [e.g., Node.js 20.10, Python 3.12]
        - Version: [e.g., v1.2.3]
        - Browser (if applicable): [e.g., Chrome 120]

  - type: textarea
    id: logs
    attributes:
      label: Logs / Error Output
      description: Paste any relevant log output or error messages.
      render: shell

  - type: textarea
    id: screenshots
    attributes:
      label: Screenshots
      description: If applicable, add screenshots to help explain the issue.

  - type: checkboxes
    id: checklist
    attributes:
      label: Checklist
      options:
        - label: I have searched existing issues to avoid duplicates
          required: true
        - label: I have provided reproduction steps
          required: true
```

#### Feature Request Template
```yaml
# .github/ISSUE_TEMPLATE/feature_request.yml
name: Feature Request
description: Suggest a new feature or enhancement
title: "[Feature]: "
labels: ["enhancement", "triage"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      description: What problem does this feature solve?
      placeholder: I'm always frustrated when...
    validations:
      required: true

  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
      description: Describe the solution you'd like.
    validations:
      required: true

  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
      description: Describe any alternative solutions or features you've considered.

  - type: dropdown
    id: priority
    attributes:
      label: Priority
      options:
        - Nice to have
        - Important
        - Critical for my use case

  - type: textarea
    id: context
    attributes:
      label: Additional Context
      description: Any other context, mockups, or screenshots.

  - type: checkboxes
    id: contribution
    attributes:
      label: Contribution
      options:
        - label: I would be willing to submit a PR for this feature
```

#### Issue Config
```yaml
# .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false
contact_links:
  - name: Questions & Discussions
    url: https://github.com/<org>/<project>/discussions
    about: Use Discussions for questions, not issues.
  - name: Security Vulnerabilities
    url: https://github.com/<org>/<project>/security/advisories/new
    about: Report security issues privately via Security Advisories.
```

#### Pull Request Template
```markdown
<!-- .github/PULL_REQUEST_TEMPLATE.md -->

## Summary
<!-- What does this PR do? Keep it concise. -->

## Related Issues
<!-- Link related issues: Fixes #123, Closes #456 -->

## Changes
<!-- Bulleted list of changes -->
-

## Type of Change
<!-- Check the relevant option -->
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to change)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Performance improvement
- [ ] Test coverage improvement

## Testing
<!-- How has this been tested? -->
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing performed

## Checklist
- [ ] My code follows the project style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
- [ ] Any dependent changes have been merged and published

## Screenshots (if applicable)
<!-- Add screenshots for UI changes -->
```

### Step 4: GitHub Actions for Project Management
Set up automation workflows for community management:

#### Auto-labeling
```yaml
# .github/workflows/labeler.yml
name: Label PRs
on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v5
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          configuration-path: .github/labeler.yml
```

```yaml
# .github/labeler.yml — Path-based label rules
documentation:
  - changed-files:
    - any-glob-to-any-file:
      - 'docs/**'
      - '*.md'
      - '!CHANGELOG.md'

tests:
  - changed-files:
    - any-glob-to-any-file:
      - 'tests/**'
      - '**/*.test.*'
      - '**/*.spec.*'

ci:
  - changed-files:
    - any-glob-to-any-file:
      - '.github/**'
      - 'Dockerfile'
      - 'docker-compose*.yml'

dependencies:
  - changed-files:
    - any-glob-to-any-file:
      - 'package.json'
      - 'package-lock.json'
      - 'requirements*.txt'
      - 'Pipfile*'
      - 'go.mod'
      - 'go.sum'
```

#### Stale Issue Management
```yaml
# .github/workflows/stale.yml
name: Manage Stale Issues
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
  workflow_dispatch:

permissions:
  issues: write
  pull-requests: write

jobs:
  stale:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/stale@v9
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          stale-issue-message: >
            This issue has been automatically marked as stale because it
            has not had recent activity. It will be closed in 14 days if
            no further activity occurs. If this issue is still relevant,
            please leave a comment to keep it open. Thank you for your
            contributions!
          stale-pr-message: >
            This pull request has been automatically marked as stale
            because it has not had recent activity. It will be closed
            in 14 days if no further activity occurs. If you are still
            working on this, please leave a comment or push new commits
            to keep it open.
          stale-issue-label: 'stale'
          stale-pr-label: 'stale'
          days-before-stale: 60
          days-before-close: 14
          exempt-issue-labels: 'pinned,security,critical,accepted'
          exempt-pr-labels: 'pinned,work-in-progress'
          exempt-all-milestones: true
```

#### Welcome Bot
```yaml
# .github/workflows/welcome.yml
name: Welcome New Contributors
on:
  issues:
    types: [opened]
  pull_request_target:
    types: [opened]

permissions:
  issues: write
  pull-requests: write

jobs:
  welcome:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/first-interaction@v1
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          issue-message: >
            Welcome! Thanks for opening your first issue. A maintainer will
            review it shortly. In the meantime, please make sure you have:
            - Searched for existing issues to avoid duplicates
            - Provided clear reproduction steps (if reporting a bug)
            - Read our [Contributing Guide](CONTRIBUTING.md)
          pr-message: >
            Welcome! Thanks for your first pull request. A maintainer will
            review it shortly. While you wait, please make sure you have:
            - Read our [Contributing Guide](CONTRIBUTING.md)
            - Added tests for new functionality
            - Updated relevant documentation
            - Ensured all CI checks pass
```

#### Release Drafter
```yaml
# .github/workflows/release-drafter.yml
name: Release Drafter
on:
  push:
    branches: [main]
  pull_request:
    types: [opened, reopened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  update-release-draft:
    runs-on: ubuntu-latest
    steps:
      - uses: release-drafter/release-drafter@v6
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```yaml
# .github/release-drafter.yml
name-template: 'v$RESOLVED_VERSION'
tag-template: 'v$RESOLVED_VERSION'
categories:
  - title: 'Breaking Changes'
    labels: ['breaking-change']
  - title: 'New Features'
    labels: ['enhancement', 'feature']
  - title: 'Bug Fixes'
    labels: ['bug', 'fix']
  - title: 'Performance'
    labels: ['performance']
  - title: 'Documentation'
    labels: ['documentation']
  - title: 'Dependencies'
    labels: ['dependencies']
  - title: 'Internal'
    labels: ['internal', 'ci']
change-template: '- $TITLE @$AUTHOR (#$NUMBER)'
change-title-escapes: '\<*_&'
version-resolver:
  major:
    labels: ['breaking-change']
  minor:
    labels: ['enhancement', 'feature']
  patch:
    labels: ['bug', 'fix', 'performance', 'documentation']
  default: patch
template: |
  ## What's Changed

  $CHANGES

  **Full Changelog**: https://github.com/$OWNER/$REPOSITORY/compare/$PREVIOUS_TAG...v$RESOLVED_VERSION
```

#### CODEOWNERS
```
# .github/CODEOWNERS — Auto-assign reviewers by path

# Default reviewers for all files
* @<org>/maintainers

# Documentation
docs/ @<org>/docs-team
*.md @<org>/docs-team

# CI/CD configuration
.github/ @<org>/platform-team

# Core library
src/core/ @<org>/core-team

# API layer
src/api/ @<org>/api-team

# Security-sensitive files
SECURITY.md @<org>/security-team
src/auth/ @<org>/security-team
```

### Step 5: Community Engagement Setup
Configure channels for community interaction:

#### GitHub Discussions
```
DISCUSSIONS SETUP:
Categories to create:
  - Announcements (maintainers only): Release notes, project updates
  - General: Community conversation, introductions
  - Ideas: Feature ideas and brainstorming
  - Q&A (answers enabled): Help and support questions
  - Show and Tell: Share projects built with the tool

Discussion templates:
  - Q&A: Structured question format with environment details
  - Ideas: Problem statement, proposed solution, alternatives
```

#### Funding Configuration
```yaml
# .github/FUNDING.yml
github: [<username>]
open_collective: <project-name>
# ko_fi: <username>
# patreon: <username>
# custom: ['https://your-custom-link.com']
```

#### Community Channels
```
COMMUNITY CHANNEL SETUP:

Discord Server Structure:
  #welcome          — Auto-post welcome message, rules, links
  #announcements    — Release notes, breaking changes (read-only)
  #general          — General discussion
  #help             — Support and troubleshooting
  #contributing     — Contributor coordination
  #showcase         — Community projects and demos
  #off-topic        — Non-project chat

Roles:
  @Maintainer       — Core team, merge access
  @Contributor       — Has merged PRs, elevated permissions
  @Community         — Default role for all members

Bots:
  - GitHub bot: Post new issues, PRs, releases
  - Moderation bot: Auto-mod, spam prevention
  - Welcome bot: DM new members with getting-started info

Slack Workspace (alternative):
  #general          — Main channel
  #development      — Technical discussion
  #releases         — Automated release notifications
  #support          — User help
```

### Step 6: Maintainer Workflows
Define processes for triage, review, and release:

#### Triage Workflow
```
TRIAGE PROCESS:

1. NEW ISSUE ARRIVES
   │
   ├─ Bot auto-labels by template type (bug, feature, question)
   ├─ Bot adds "triage" label
   │
   ▼
2. MAINTAINER TRIAGE (within 48 hours)
   │
   ├─ Is it a duplicate? → Close with reference to original
   ├─ Is it a question? → Redirect to Discussions
   ├─ Is it a security issue? → Move to Security Advisories
   ├─ Is it actionable? → YES: proceed | NO: request more info
   │
   ▼
3. CATEGORIZE & PRIORITIZE
   │
   ├─ Add priority label: P0 (critical), P1 (high), P2 (medium), P3 (low)
   ├─ Add area label: core, api, docs, ci, etc.
   ├─ Add effort label: small, medium, large
   ├─ Remove "triage" label
   │
   ▼
4. ASSIGN or LABEL FOR CONTRIBUTORS
   │
   ├─ Simple issues → Add "good first issue" label
   ├─ Medium issues → Add "help wanted" label
   ├─ Complex issues → Assign to maintainer or create RFC
   │
   ▼
5. TRACK PROGRESS
   │
   ├─ Assign to milestone (if versioned)
   ├─ Add to project board
   └─ Follow up if no activity in 14 days
```

#### Review Workflow
```
PULL REQUEST REVIEW PROCESS:

1. PR OPENED
   │
   ├─ CI runs automatically
   ├─ Bot auto-labels by file paths (CODEOWNERS)
   ├─ Bot auto-assigns reviewers (CODEOWNERS)
   │
   ▼
2. AUTOMATED CHECKS
   │
   ├─ Tests pass? → Continue | Fail → Author fixes
   ├─ Linting clean? → Continue | Fail → Author fixes
   ├─ Coverage threshold met? → Continue | Fail → Author adds tests
   ├─ Security scan clean? → Continue | Fail → Author remediates
   │
   ▼
3. CODE REVIEW (1-2 reviewers)
   │
   ├─ Code quality: readability, maintainability, patterns
   ├─ Architecture: does it fit the project direction?
   ├─ Tests: are the right things being tested?
   ├─ Documentation: is public API documented?
   ├─ Breaking changes: are they flagged and communicated?
   │
   ▼
4. REVIEW OUTCOME
   │
   ├─ Approve → Merge (squash or rebase per project policy)
   ├─ Request changes → Author addresses, re-request review
   ├─ Comment → Discussion needed, no blocking decision yet
   │
   ▼
5. POST-MERGE
   │
   ├─ Delete feature branch
   ├─ Update release draft
   ├─ Notify Discord/Slack (for significant changes)
   └─ Thank contributor (first-time contributors get special mention)
```

#### Release Workflow
```
RELEASE PROCESS:

1. DETERMINE RELEASE SCOPE
   │
   ├─ Review merged PRs since last release
   ├─ Classify: breaking, feature, fix, docs, internal
   ├─ Determine version bump: major, minor, patch
   │
   ▼
2. PREPARE RELEASE
   │
   ├─ Update CHANGELOG.md (or use auto-generated draft)
   ├─ Update version in package.json / pyproject.toml / etc.
   ├─ Run full test suite
   ├─ Verify no regressions
   │
   ▼
3. CREATE RELEASE
   │
   ├─ Create git tag: v<major>.<minor>.<patch>
   ├─ Push tag: triggers release CI workflow
   ├─ CI builds and publishes artifacts (npm, PyPI, Docker, binaries)
   ├─ GitHub Release created with changelog
   │
   ▼
4. POST-RELEASE
   │
   ├─ Announce in Discord/Slack #announcements
   ├─ Post on social media (major releases)
   ├─ Update documentation site
   ├─ Close resolved milestones
   ├─ If breaking: publish migration guide
   └─ Monitor for regressions (24-48 hours)
```

### Step 7: Governance Models
Define how decisions are made and who has authority:

#### BDFL (Benevolent Dictator for Life)
```
GOVERNANCE MODEL: BDFL

Structure:
  BDFL: <name> — Final decision authority on all matters
  Core Maintainers: 2-5 people with merge access
  Contributors: Anyone who submits accepted PRs

Decision Process:
  1. Discussion in issue/PR/RFC
  2. Core maintainers provide input
  3. BDFL makes final decision if consensus is not reached
  4. Decision documented in issue or ADR

When to use:
  - Small to medium projects (1-20 active contributors)
  - Projects with a clear technical vision
  - Early-stage projects needing fast decisions
  - Personal projects that accept contributions

Advantages:
  - Fast decisions, clear authority
  - Consistent technical vision
  - Low governance overhead

Risks:
  - Bus factor of 1
  - Contributor frustration if overruled frequently
  - BDFL burnout

Mitigation:
  - Document succession plan
  - Delegate area ownership to trusted maintainers
  - Use RFC process for major decisions
```

#### Consensus Model
```
GOVERNANCE MODEL: Consensus

Structure:
  Core Team: 3-7 people with equal decision authority
  Committers: Merge access for specific areas
  Contributors: Anyone who submits accepted PRs

Decision Process:
  1. Proposal via issue, RFC, or discussion
  2. Core team reviews (minimum 72-hour discussion period)
  3. Consensus required: no strong objections from any core member
  4. If no consensus: extended discussion, then supermajority vote (2/3)
  5. Decision documented in ADR

When to use:
  - Medium projects (10-50 active contributors)
  - Projects with multiple strong technical voices
  - Community-driven projects

GOVERNANCE.md template:
  - Core team membership criteria
  - How to become a committer
  - Decision-making process
  - Conflict resolution
  - Voting procedures
```

#### Steering Committee
```
GOVERNANCE MODEL: Steering Committee

Structure:
  Steering Committee: 5-9 elected members
    - Technical direction, roadmap, conflict resolution
    - Elected annually by active contributors
  Working Groups: Area-specific teams
    - Core, Documentation, Community, Infrastructure
    - Each has a lead on the Steering Committee
  Committers: Merge access within working group scope
  Contributors: Anyone who submits accepted PRs

Decision Process:
  1. Working group proposes via RFC
  2. Public comment period (2 weeks minimum)
  3. Steering Committee reviews and votes
  4. Majority required, quorum of 60%
  5. Decision published in governance log

When to use:
  - Large projects (50+ active contributors)
  - Foundation-backed projects (CNCF, Apache, Linux Foundation)
  - Projects with corporate sponsors needing neutral governance

GOVERNANCE.md template:
  - Committee charter and responsibilities
  - Election process and terms
  - Working group formation and dissolution
  - RFC process
  - Code of Conduct enforcement authority
  - Trademark and brand usage policy
```

### Step 8: Generate GOVERNANCE.md
Based on the selected model, create the governance document:

```markdown
# Governance

## Overview
This document describes the governance model for <Project Name>.

## Roles

### Maintainers
Maintainers have full commit access and are responsible for:
- Reviewing and merging pull requests
- Triaging issues
- Making release decisions
- Enforcing the Code of Conduct

Current maintainers:
- @<username> — <area of responsibility>

### How to Become a Maintainer
1. Sustained, high-quality contributions over 6+ months
2. Demonstrated understanding of the project architecture
3. Positive interactions with the community
4. Nomination by existing maintainer, approved by <BDFL/consensus/committee>

### Contributors
Anyone who submits a pull request that gets merged is a contributor.
Contributors are listed in [CONTRIBUTORS.md](CONTRIBUTORS.md).

## Decision-Making
- **Minor changes** (bug fixes, small features): One maintainer approval
- **Significant changes** (new features, API changes): Two maintainer approvals
- **Breaking changes**: RFC process, full maintainer review
- **Governance changes**: <unanimous/supermajority> maintainer approval

## RFC Process
For significant changes:
1. Open an issue with the `rfc` label
2. Write a design document covering problem, solution, alternatives, and migration
3. Discussion period: minimum 1 week
4. Decision by <BDFL/consensus/committee vote>
5. Implementation begins after approval

## Conflict Resolution
1. Discuss in the relevant issue or PR
2. If unresolved: escalate to maintainer discussion
3. If still unresolved: <BDFL decides / majority vote / committee review>

## Changes to Governance
This document may be amended by <process>.
```

### Step 9: Audit Report & Recommendations

```
+------------------------------------------------------------+
|  OPEN SOURCE READINESS — <project>                          |
+------------------------------------------------------------+
|  Health Score: <N>/13                                       |
|                                                             |
|  Files Created:                                             |
|  [x] LICENSE (<type>)                                       |
|  [x] CODE_OF_CONDUCT.md (Contributor Covenant 2.1)         |
|  [x] CONTRIBUTING.md (with dev setup, style guide)          |
|  [x] SECURITY.md (with disclosure policy)                   |
|  [x] GOVERNANCE.md (<model>)                                |
|  [x] .github/ISSUE_TEMPLATE/bug_report.yml                 |
|  [x] .github/ISSUE_TEMPLATE/feature_request.yml            |
|  [x] .github/ISSUE_TEMPLATE/config.yml                     |
|  [x] .github/PULL_REQUEST_TEMPLATE.md                      |
|  [x] .github/CODEOWNERS                                    |
|  [x] .github/FUNDING.yml                                   |
|  [x] .github/workflows/labeler.yml                         |
|  [x] .github/workflows/stale.yml                           |
|  [x] .github/workflows/welcome.yml                         |
|  [x] .github/workflows/release-drafter.yml                 |
|                                                             |
|  Community:                                                 |
|  - Discussions: <enabled/recommended>                       |
|  - Chat: <Discord/Slack setup guide provided>               |
|  - Funding: <configured/recommended>                        |
|                                                             |
|  Governance: <BDFL | Consensus | Steering Committee>        |
|                                                             |
|  Verdict: READY FOR OPEN SOURCE                             |
+------------------------------------------------------------+
```

### Step 10: Commit and Transition
1. Commit all scaffolding files: `"opensource: <project> — scaffold community health files (<N> files)"`
2. Commit automation workflows: `"opensource: <project> — add GitHub Actions for project management"`
3. Commit governance: `"opensource: <project> — add <model> governance model"`
4. If repository was already open: "Community health files updated. Review the generated files and customize contact details, team names, and links."
5. If new open source project: "Repository is ready for open source. Next: customize templates, enable Discussions, and announce the project."

## Key Behaviors

1. **Community health files are non-negotiable.** Every open source project needs LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT, and SECURITY at minimum. No exceptions.
2. **Templates reduce friction.** Structured issue and PR templates get better bug reports, more actionable feature requests, and faster reviews.
3. **Automation handles the tedious work.** Auto-labeling, stale management, and welcome bots let maintainers focus on code, not housekeeping.
4. **Governance scales with the project.** A solo project needs BDFL. A 50-person project needs a steering committee. Match the model to the reality.
5. **Triage is maintenance.** Untriaged issues and unreviewed PRs kill contributor motivation. Set SLAs and honor them.
6. **First impressions matter.** A contributor's first PR review shapes whether they come back. Be welcoming, constructive, and timely.
7. **Document decisions.** When a design choice is made, record it. Future contributors will ask "why" and the answer should be findable.

## Example Usage

### Full open source setup
```
User: /godmode:opensource Set up our project for open source

Opensource: Scanning repository...

REPOSITORY HEALTH CHECK:
  LICENSE: MISSING
  README.md: PRESENT (needs badges, contributing section)
  CONTRIBUTING.md: MISSING
  CODE_OF_CONDUCT.md: MISSING
  SECURITY.md: MISSING
  Issue templates: MISSING
  PR template: MISSING
  CODEOWNERS: MISSING
  CI workflows: PRESENT (.github/workflows/ci.yml)

Health Score: 2/13

Creating community health files...
  Created: LICENSE (MIT)
  Created: CODE_OF_CONDUCT.md (Contributor Covenant 2.1)
  Created: CONTRIBUTING.md (with dev setup, style guide)
  Created: SECURITY.md (with disclosure policy)
  Created: .github/ISSUE_TEMPLATE/bug_report.yml
  Created: .github/ISSUE_TEMPLATE/feature_request.yml
  Created: .github/ISSUE_TEMPLATE/config.yml
  Created: .github/PULL_REQUEST_TEMPLATE.md
  Created: .github/CODEOWNERS

Setting up automation...
  Created: .github/workflows/labeler.yml
  Created: .github/workflows/stale.yml
  Created: .github/workflows/welcome.yml
  Created: .github/workflows/release-drafter.yml
  Created: .github/FUNDING.yml

Health Score: 13/13

Governance: BDFL model (recommended for current project size)
  Created: GOVERNANCE.md

Verdict: READY FOR OPEN SOURCE
```

### Add governance to existing project
```
User: /godmode:opensource --governance steering-committee

Opensource: Creating steering committee governance...

Created: GOVERNANCE.md
  - 5-9 elected members
  - Annual elections by active contributors
  - Working groups: Core, Docs, Community, Infra
  - RFC process for significant changes
  - Conflict resolution escalation path

Next: Customize the governance document with team names and hold the first election.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full repository health audit and scaffolding |
| `--audit` | Audit only, do not create files |
| `--governance <model>` | Set governance model (bdfl, consensus, committee) |
| `--templates` | Create issue and PR templates only |
| `--automation` | Set up GitHub Actions workflows only |
| `--community` | Configure community channels only |
| `--security` | Create SECURITY.md and security workflows only |
| `--minimal` | Create only LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT |
| `--no-automation` | Skip GitHub Actions workflow creation |

## HARD RULES

1. **NEVER open source without a LICENSE file.** Code without a license is "all rights reserved" by default. No LICENSE = not open source.
2. **NEVER skip Code of Conduct.** Every public project must have one. Use Contributor Covenant 2.1 as the default.
3. **NEVER commit secrets to a public repository.** Audit all files with `grep -rn "sk_\|password\|secret\|token\|api_key" . --include="*.ts" --include="*.py" --include="*.env*"` before going public.
4. **NEVER use blank issue templates.** All issues must use structured YAML templates. Disable blank issues in config.yml.
5. **NEVER set stale bot to auto-close issues labeled `security` or `critical`.** These labels must be exempt.
6. **ALWAYS include private vulnerability reporting.** Security issues must never be filed as public issues.
7. **ALWAYS match governance model to project size.** Solo project = BDFL. 10+ contributors = consensus. 50+ = steering committee.
8. **ALWAYS test CONTRIBUTING.md instructions on a clean machine.** If setup takes more than 15 minutes, contributors will leave.

## Auto-Detection

Before scaffolding, detect existing community health files:

```
AUTO-DETECT SEQUENCE:
1. Check for existing files:
   - ls LICENSE* LICENCE* → license present?
   - ls README* → readme present?
   - ls CONTRIBUTING* → contributing guide?
   - ls CODE_OF_CONDUCT* → code of conduct?
   - ls SECURITY* → security policy?
   - ls CHANGELOG* → changelog?
   - ls .github/ISSUE_TEMPLATE/ → issue templates?
   - ls .github/PULL_REQUEST_TEMPLATE* → PR template?
   - ls .github/CODEOWNERS → code owners?
   - ls .github/FUNDING.yml → funding config?
   - ls .github/workflows/ → CI/CD workflows?

2. Detect license type:
   - grep -l "MIT License" LICENSE* → MIT
   - grep -l "Apache License" LICENSE* → Apache 2.0
   - grep -l "GNU GENERAL PUBLIC" LICENSE* → GPL

3. Detect CI provider:
   - ls .github/workflows/ → GitHub Actions
   - ls .circleci/ → CircleCI
   - ls .gitlab-ci.yml → GitLab CI
   - ls Jenkinsfile → Jenkins

4. Populate REPOSITORY HEALTH CHECK table from detection results.
```

## Explicit Loop Protocol

Repository scaffolding is iterative -- create, verify, customize:

```
current_iteration = 0
files_to_scaffold = [LICENSE, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY,
                     issue_templates, pr_template, CODEOWNERS, workflows,
                     FUNDING, GOVERNANCE]

WHILE files_to_scaffold is not empty AND current_iteration < 12:
    current_iteration += 1
    file = files_to_scaffold.pop(0)

    1. CHECK if file already exists and assess quality
    2. IF exists AND quality >= GOOD: skip
    3. IF exists AND quality < GOOD: improve in-place
    4. IF not exists: create with project-appropriate template
    5. VERIFY: file is valid (YAML parses, Markdown renders, links work)
    6. IF verification fails:
        files_to_scaffold.append(file)  # retry
    7. REPORT: "File {file}: {CREATED|IMPROVED|SKIPPED} -- iteration {current_iteration}"

OUTPUT: Health score updated, all files present and verified.
```

## Multi-Agent Dispatch

For large projects needing full open source setup, dispatch parallel agents:

```
MULTI-AGENT OPEN SOURCE SETUP:
Dispatch 3 agents in parallel worktrees.

Agent 1 (worktree: oss-community):
  - Create LICENSE, CODE_OF_CONDUCT, CONTRIBUTING, SECURITY
  - Set up GOVERNANCE.md with appropriate model
  - Add CODEOWNERS based on git blame analysis

Agent 2 (worktree: oss-templates):
  - Create .github/ISSUE_TEMPLATE/ (bug, feature, config)
  - Create .github/PULL_REQUEST_TEMPLATE.md
  - Set up .github/FUNDING.yml
  - Configure Discussions categories

Agent 3 (worktree: oss-automation):
  - Create labeler.yml workflow + label config
  - Create stale.yml workflow
  - Create welcome.yml workflow
  - Create release-drafter.yml + config

MERGE ORDER: community -> templates -> automation
CONFLICT ZONES: .github/ directory structure (create in order)
```

## Anti-Patterns

- **Do NOT open source without a LICENSE.** Code without a license is not open source. It is "all rights reserved" by default. Always include a license file.
- **Do NOT skip the Code of Conduct.** It sets expectations for behavior and provides enforcement mechanisms. Communities without CoCs attract toxicity.
- **Do NOT use blank issue templates.** Unstructured issues waste maintainer time. Structured templates get actionable reports.
- **Do NOT ignore security disclosures.** Public vulnerability reports before fixes are ready are dangerous. Always provide a private reporting channel.
- **Do NOT neglect contributor experience.** If setup takes more than 15 minutes, you will lose contributors. Make onboarding frictionless.
- **Do NOT over-govern small projects.** A solo project does not need a steering committee. Match governance to project size.
- **Do NOT let issues rot.** Stale, untriaged issues signal an abandoned project. Use automation and regular triage sessions.
- **Do NOT merge without review.** Even maintainers should get code reviewed. Four eyes catch what two miss.
