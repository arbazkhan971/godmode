---
name: opensource
description: Open source project management.
---

## Activate When
- `/godmode:opensource`, "set up open source project"
- "contributing guide", "code of conduct", "issue templates"
- Preparing to publicly publish a repository

## Workflow

### 1. Repository Health Check
```bash
ls LICENSE CODE_OF_CONDUCT.md CONTRIBUTING.md \
  SECURITY.md .github/ISSUE_TEMPLATE/ \
  .github/PULL_REQUEST_TEMPLATE.md \
  .github/CODEOWNERS 2>/dev/null
# Secrets audit
grep -rn "sk_\|password\|secret\|token\|api_key" \
  --include="*.ts" --include="*.py" --include="*.env*" .
```
```
| File | Status | Quality |
| LICENSE | present/missing | valid SPDX? |
| CODE_OF_CONDUCT | present/missing | Covenant 2.1? |
| CONTRIBUTING | present/missing | setup verified? |
| SECURITY | present/missing | private reporting? |
| Issue templates | present/missing | YAML format? |
| PR template | present/missing | has checklist? |
| CODEOWNERS | present/missing | paths mapped? |
```

### 2. Scaffolding
**LICENSE:** detect project goals, recommend license.
**CODE_OF_CONDUCT:** Contributor Covenant 2.1.
**CONTRIBUTING:** setup instructions, style guide,
  PR process, community links.
**SECURITY:** private vulnerability reporting channel.

IF setup takes > 15 minutes: simplify.
IF no license: code is "all rights reserved" by default.

### 3. Issue & PR Templates
```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
# .github/ISSUE_TEMPLATE/feature_request.yml
# .github/ISSUE_TEMPLATE/config.yml
#   blank_issues_enabled: false
# .github/PULL_REQUEST_TEMPLATE.md
```
ALWAYS disable blank issues (force structured templates).

### 4. GitHub Actions
```yaml
# Auto-labeling: .github/workflows/labeler.yml
# Stale management: .github/workflows/stale.yml
#   NEVER auto-close security or critical labels
# Welcome bot: .github/workflows/welcome.yml
# Release drafter: .github/workflows/release-drafter.yml
# CODEOWNERS: .github/CODEOWNERS
```

### 5. Community Engagement
```
Discussions categories:
  Announcements (maintainers), Q&A, Ideas, Show & Tell
Funding: .github/FUNDING.yml
Discord/Slack: #general, #help, #contributing, #releases
```

### 6. Maintainer Workflows
```
Triage: new issue -> label -> assign -> priority
  SLA: first response < 48h
Review: PR opened -> auto-assign -> review < 48h
Release: determine scope -> changelog -> tag -> publish
  Use --dry-run before actual release
```

### 7. Governance
```
Solo project: BDFL (benevolent dictator)
10+ contributors: consensus model
50+ contributors: steering committee
Match governance to project size.
```
IF governance mismatch: document and update.

## Quality Targets
- Target: <48h response time for new issues
- Target: >80% of PRs reviewed within 7 days
- Target: 100% of public APIs documented

## Hard Rules
1. NEVER open source without LICENSE file.
2. NEVER skip Code of Conduct.
3. NEVER commit secrets to public repository.
4. NEVER use blank issue templates.
5. NEVER auto-close security/critical labels.
6. ALWAYS include private vulnerability reporting.
7. ALWAYS test CONTRIBUTING.md on clean machine.

## TSV Logging
Append `.godmode/opensource.tsv`:
```
timestamp	action	files_created	health_score	status
```

## Keep/Discard
```
KEEP if: renders correctly, YAML validates,
  links valid, health score improved.
DISCARD if: validation fails or links broken.
```

## Stop Conditions
```
STOP when FIRST of:
  - All critical files present (LICENSE, README,
    CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
  - Issue + PR templates configured
  - No secrets found in repo
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| License incompatibility | Audit deps with license-checker |
| CI fails for contributors | Check secrets not required for PRs |
| Spam PRs/issues | Add templates, enable auto-labeling |
