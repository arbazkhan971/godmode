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
- Team plans to open-source or publicly publish the project
- Repository is missing standard community health files
- Maintainer wants to improve contributor experience

## Workflow

### Step 1: Assess Repository Health
Audit the repository for standard open source files and practices:

```
REPOSITORY HEALTH CHECK:
| File | Status | Quality |
```

### Step 2: Repository Scaffolding
Generate or improve the core community health files:

#### LICENSE
```
LICENSE SELECTION:
Current license: <detected or none>
Recommendation: <based on project goals>
```

For detailed license guidance, use `/godmode:license`.

#### CODE_OF_CONDUCT.md
```markdown
# Contributor Covenant Code of Conduct

## Our Pledge
```

#### CONTRIBUTING.md
```markdown
# Contributing to <Project Name>

Thank you for your interest in contributing! This document provides
```

## How to Contribute

### Reporting Bugs
- Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.yml) template
- Include reproduction steps, expected behavior, and actual behavior
- Include system information (OS, runtime version, etc.)

### Suggesting Features
- Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.yml) template
- Describe the problem the feature would solve
- Propose a solution and list alternatives

### Code Contributions
- Look for issues labeled `good first issue` or `help wanted`
- Comment on the issue to claim it before starting work
- Follow the style guide and write tests for new functionality
- Keep pull requests focused — one feature or fix per PR

## Pull Request Process
1. Update documentation if you change public APIs
2. Add tests for new functionality
3. Verify all tests pass and linting is clean
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
```

### Step 3: Issue & PR Template Design
Create structured templates for consistent issue reporting and pull requests:

#### Bug Report Template
```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: Report a bug or unexpected behavior
```

#### Feature Request Template
```yaml
# .github/ISSUE_TEMPLATE/feature_request.yml
name: Feature Request
description: Suggest a new feature or enhancement
```

#### Issue Config
```yaml
# .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false
contact_links:
```

#### Pull Request Template
```markdown
<!-- .github/PULL_REQUEST_TEMPLATE.md -->

## Summary
```

### Step 4: GitHub Actions for Project Management
Set up automation workflows for community management:

#### Auto-labeling
```yaml
# .github/workflows/labeler.yml
name: Label PRs
on:
```

```yaml
# .github/labeler.yml — Path-based label rules
documentation:
  - changed-files:
```

#### Stale Issue Management
```yaml
# .github/workflows/stale.yml
name: Manage Stale Issues
on:
```

#### Welcome Bot
```yaml
# .github/workflows/welcome.yml
name: Welcome New Contributors
on:
```

#### Release Drafter
```yaml
# .github/workflows/release-drafter.yml
name: Release Drafter
on:
```

```yaml
# .github/release-drafter.yml
name-template: 'v$RESOLVED_VERSION'
tag-template: 'v$RESOLVED_VERSION'
```

#### CODEOWNERS
```
# .github/CODEOWNERS — Auto-assign reviewers by path

# Default reviewers for all files
```

### Step 5: Community Engagement Setup
Configure channels for community interaction:

#### GitHub Discussions
```
DISCUSSIONS SETUP:
Categories to create:
  - Announcements (maintainers only): Release notes, project updates
```

#### Funding Configuration
```yaml
# .github/FUNDING.yml
github: [<username>]
open_collective: <project-name>
```

#### Community Channels
```
COMMUNITY CHANNEL SETUP:

Discord Server Structure:
```

### Step 6: Maintainer Workflows
Define processes for triage, review, and release:

#### Triage Workflow
```
TRIAGE PROCESS:

1. NEW ISSUE ARRIVES
```

#### Review Workflow
```
PULL REQUEST REVIEW PROCESS:

1. PR OPENED
```

#### Release Workflow
```
RELEASE PROCESS:

1. DETERMINE RELEASE SCOPE
```

### Step 7: Governance Models
Define how decisions are made and who has authority:

#### BDFL (Benevolent Dictator for Life)
```
GOVERNANCE MODEL: BDFL

Structure:
```

#### Consensus Model
```
GOVERNANCE MODEL: Consensus

Structure:
```

#### Steering Committee
```
GOVERNANCE MODEL: Steering Committee

Structure:
```

### Step 8: Generate GOVERNANCE.md
Based on the selected model, create the governance document:

```markdown
# Governance

## Overview
```

### Step 9: Audit Report & Recommendations

```
|  OPEN SOURCE READINESS — <project>                          |
```

### Step 10: Commit and Transition
1. Commit all scaffolding files: `"opensource: <project> — scaffold community health files (<N> files)"`
2. Commit automation workflows: `"opensource: <project> — add GitHub Actions for project management"`
3. Commit governance: `"opensource: <project> — add <model> governance model"`
4. If repository was already open: "Community health files updated. Review the generated files and customize contact details, team names, and links."
5. If new open source project: "Repository is ready for open source. Next: customize templates, enable Discussions, and announce the project."

## Autonomous Operation
- Measure before/after. Guard: test_cmd && lint_cmd.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Key Behaviors

1. **Community health files are non-negotiable.** Every open source project needs LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT, and SECURITY at minimum. No exceptions.
2. **Templates reduce friction.** Structured issue and PR templates get better bug reports, more actionable feature requests, and faster reviews.
3. **Automation handles the tedious work.** Auto-labeling, stale management, and welcome bots let maintainers focus on code, not housekeeping.
4. **Governance scales with the project.** A solo project needs BDFL. A 50-person project needs a steering committee. Match the model to the reality.
5. **Triage is maintenance.** Untriaged issues and unreviewed PRs kill contributor motivation. Set SLAs and honor them.
6. **First impressions matter.** A contributor's first PR review shapes whether they come back. Be welcoming, constructive, and timely.
7. **Document decisions.** When you make a design choice, record it. Future contributors will ask "why" and the answer needs to exist in writing.

## HARD RULES

1. **NEVER open source without a LICENSE file.** Code without a license is "all rights reserved" by default. No LICENSE = not open source.
2. **NEVER skip Code of Conduct.** Every public project must have one. Use Contributor Covenant 2.1 as the default.
3. **NEVER commit secrets to a public repository.** Audit all files with `grep -rn "sk_\|password\|secret\|token\|api_key" . --include="*.ts" --include="*.py" --include="*.env*"` before going public.
4. **NEVER use blank issue templates.** All issues must use structured YAML templates. Disable blank issues in config.yml.
5. **NEVER set stale bot to auto-close issues labeled `security` or `critical`.** Exempt these labels always.
6. **ALWAYS include private vulnerability reporting.** Security issues must never be filed as public issues.
7. **ALWAYS match governance model to project size.** Solo project = BDFL. 10+ contributors = consensus. 50+ = steering committee.
8. **ALWAYS test CONTRIBUTING.md instructions on a clean machine.** If setup takes more than 15 minutes, contributors will leave.

## Output Format
Print on completion: `Opensource: {health_score}/13 files present. {files_created} created, {files_updated} updated. Status: {status}.`

## TSV Logging
Log to `.godmode/opensource.tsv`:
```
timestamp	skill	action	files_created	files_updated	health_score	status
```

## Success Criteria

The opensource skill is complete when ALL of the following are true:
1. LICENSE file exists with a valid SPDX license
2. CODE_OF_CONDUCT.md exists (Contributor Covenant 2.1 or equivalent)
3. CONTRIBUTING.md exists with setup instructions verified on a clean machine
4. SECURITY.md exists with a private vulnerability reporting channel
5. Issue templates use structured YAML format (no blank issues)
6. PR template exists with checklist
7. CODEOWNERS file maps paths to responsible teams/individuals
8. No secrets found in the repository (grep audit passes)
9. Governance model matches project size

## Keep/Discard Discipline
```
After EACH community health file is created or updated:
  1. MEASURE: Does the file render correctly, pass YAML validation, and follow project conventions?
  2. COMPARE: Does the health score improve? Are all links valid?
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All critical files present (LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
  - Issue and PR templates configured with blank issues disabled
```

## Error Recovery
| Failure | Action |
|--|--|
| License incompatibility discovered | Audit all dependencies with `license-checker` or `licensee`. Replace incompatible deps or change project license. Document in NOTICE file. |
| CI fails for external contributors | Check that CI does not require secrets for PR checks. Use `pull_request_target` carefully. Provide clear contributing guide. |
| Spam PRs or issues | Add issue/PR templates. Enable GitHub Actions for auto-labeling. Use `stale` bot for inactive issues. |
| Release process breaks | Pin release tool versions. Use `--dry-run` before actual release. Tag first, publish second. |
