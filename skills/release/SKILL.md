---
name: release
description: |
  Release management skill. Activates when user needs to manage software releases including semantic versioning strategy, release notes generation, changelog automation, release branching and tagging, hotfix workflows, and release train scheduling. Designs release processes that are predictable, automated, and well-documented. Triggers on: /godmode:release, "create a release", "bump version", "changelog", "release notes", "hotfix", "release train", "semantic versioning", or when code is ready to be versioned and published.
---

# Release — Release Management

## When to Activate
- User invokes `/godmode:release`
- User says "create a release," "bump version," "changelog," "release notes"
- User needs to manage a hotfix for a production issue
- User wants to set up automated release workflows
- User needs to schedule releases for a team
- Godmode orchestrator detects tagged commits or version bumps during `/godmode:ship`

## Workflow

### Step 1: Assess Release Context
Understand the project's release maturity and requirements:

```
RELEASE ASSESSMENT:
Project:
  Name: <project name>
  Type: <library | application | service | monorepo>
  Package manager: <npm | pip | cargo | go | maven | none>
  Registry: <npm | PyPI | crates.io | Docker Hub | internal | none>

Current state:
  Latest version: <current version or "unversioned">
  Versioning scheme: <semver | calver | custom | none>
  Changelog: <exists | outdated | none>
  Release automation: <fully automated | semi | manual | none>
  Tagging convention: <v1.2.3 | 1.2.3 | custom>
  Release branch pattern: <release/* | none>

History (last 5 releases):
  <version> — <date> — <commits since previous>
  <version> — <date> — <commits since previous>

Team:
  Release cadence: <continuous | weekly | bi-weekly | monthly | ad-hoc>
  Release manager: <rotating | fixed | automated>
  Approval required: <yes | no>
  Environments: <staging → production | direct to production>

Recommended approach: <continuous release | scheduled release train | manual>
Justification: <why this approach fits>
```

### Step 2: Semantic Versioning Strategy
Determine the correct version bump:

```
SEMANTIC VERSIONING (SemVer):
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   MAJOR . MINOR . PATCH                                     │
│     │       │       │                                       │
│     │       │       └── Bug fixes, no API changes           │
│     │       └────────── New features, backward compatible   │
│     └────────────────── Breaking changes                    │
│                                                             │
│   Pre-release:  1.2.3-alpha.1, 1.2.3-beta.2, 1.2.3-rc.1   │
│   Build meta:   1.2.3+build.456                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘

VERSION BUMP DECISION:
┌─────────────────────────────────────────────────────────────┐
│ Change Type                         │ Bump    │ Example     │
├─────────────────────────────────────┼─────────┼─────────────┤
│ Bug fix (no behavior change)        │ PATCH   │ 1.2.3→1.2.4│
│ Performance improvement             │ PATCH   │ 1.2.3→1.2.4│
│ New feature (backward compatible)   │ MINOR   │ 1.2.3→1.3.0│
│ Deprecation (still works)           │ MINOR   │ 1.2.3→1.3.0│
│ Removing deprecated feature         │ MAJOR   │ 1.2.3→2.0.0│
│ Breaking API change                 │ MAJOR   │ 1.2.3→2.0.0│
│ Breaking config/schema change       │ MAJOR   │ 1.2.3→2.0.0│
│ Documentation only                  │ none    │ no release  │
│ CI/build changes                    │ none    │ no release  │
│ Test changes only                   │ none    │ no release  │
└─────────────────────────────────────┴─────────┴─────────────┘

AUTOMATED VERSION DETECTION (from Conventional Commits):
  Commits since last release:
    feat(auth): add OAuth2 login         → MINOR
    fix(api): handle null payment resp   → PATCH
    feat!: drop Node 16 support          → MAJOR
    docs: update README                  → none

  Highest bump wins: MAJOR (due to breaking change)
  Next version: 1.2.3 → 2.0.0

PRE-RELEASE WORKFLOW:
  Alpha (internal testing):
    2.0.0-alpha.1 → 2.0.0-alpha.2 → ...
  Beta (external testing):
    2.0.0-beta.1 → 2.0.0-beta.2 → ...
  Release candidate (final validation):
    2.0.0-rc.1 → 2.0.0-rc.2 → ...
  Stable release:
    2.0.0

  Rule: Pre-release versions are NOT installed by default
  (npm install gets stable only; npm install@beta gets beta)
```

### Step 3: Release Notes Generation
Generate comprehensive, audience-appropriate release notes:

```
RELEASE NOTES TEMPLATE:
┌─────────────────────────────────────────────────────────────┐
│ # v2.0.0 — <Release Title>                                 │
│                                                             │
│ Released: <date>                                            │
│                                                             │
│ ## Highlights                                               │
│ <1-3 sentences for non-technical stakeholders>              │
│ <What's new, what's better, what's different>               │
│                                                             │
│ ## Breaking Changes ⚠️                                      │
│ - **Node 16 no longer supported.** Minimum is Node 18.     │
│   Migration: Update your CI and local Node version.         │
│ - **`/api/v1/users` removed.** Use `/api/v2/users`.        │
│   Migration: Update API client to use v2 endpoints.         │
│                                                             │
│ ## New Features                                             │
│ - **OAuth2 login** — Users can now sign in with Google,     │
│   GitHub, and GitLab. (#1234)                               │
│ - **Bulk import** — Import up to 10,000 records via CSV.    │
│   (#1256)                                                   │
│                                                             │
│ ## Bug Fixes                                                │
│ - Fix race condition in checkout causing duplicate charges  │
│   (#1289)                                                   │
│ - Fix timezone handling in scheduled reports (#1301)        │
│                                                             │
│ ## Performance                                              │
│ - 40% faster search queries via index optimization (#1278) │
│ - Reduced memory usage in file upload handler (#1292)       │
│                                                             │
│ ## Deprecations                                             │
│ - `legacyAuth()` is deprecated. Use `oauth2()` instead.    │
│   Will be removed in v3.0.0.                                │
│                                                             │
│ ## Contributors                                             │
│ @alice @bob @charlie                                        │
│                                                             │
│ **Full Changelog:** v1.2.3...v2.0.0                         │
└─────────────────────────────────────────────────────────────┘

RELEASE NOTES GENERATION METHODS:
  1. From Conventional Commits (automated):
     Parse commit messages since last tag
     Group by type (feat, fix, perf, etc.)
     Extract breaking changes from footers
     Link to PRs and issues

  2. From PR descriptions (semi-automated):
     Collect merged PRs since last release
     Extract summary sections from PR descriptions
     Group by label (feature, bug-fix, etc.)

  3. From changelog entries (manual):
     Developers add changelog entries with their PRs
     Release collects and formats entries

AUDIENCE-APPROPRIATE NOTES:
  For users/customers:
    Focus on features, fixes, and breaking changes
    Use plain language, no implementation details
    Include migration guides for breaking changes

  For developers:
    Include technical details and API changes
    Link to specific commits and PRs
    Document new configuration options

  For operations:
    Note infrastructure requirements
    Document new environment variables
    Flag database migrations
    Note performance characteristics
```

### Step 4: Changelog Automation
Maintain a living changelog that updates with every release:

```
CHANGELOG FORMAT (Keep a Changelog):
┌─────────────────────────────────────────────────────────────┐
│ # Changelog                                                 │
│                                                             │
│ All notable changes to this project will be documented in   │
│ this file.                                                  │
│                                                             │
│ The format is based on [Keep a Changelog](https://          │
│ keepachangelog.com/en/1.1.0/), and this project adheres to  │
│ [Semantic Versioning](https://semver.org/spec/v2.0.0.html).│
│                                                             │
│ ## [Unreleased]                                             │
│                                                             │
│ ### Added                                                   │
│ - OAuth2 login with Google, GitHub, GitLab providers        │
│                                                             │
│ ### Changed                                                 │
│ - Minimum Node version is now 18 (was 16)                   │
│                                                             │
│ ## [2.0.0] - 2024-03-15                                     │
│                                                             │
│ ### Added                                                   │
│ - Bulk CSV import for records (#1256)                       │
│ - Rate limiting on public API endpoints (#1234)             │
│                                                             │
│ ### Fixed                                                   │
│ - Race condition in checkout (#1289)                        │
│ - Timezone handling in scheduled reports (#1301)            │
│                                                             │
│ ### Removed                                                 │
│ - Legacy v1 API endpoints                                   │
│                                                             │
│ ## [1.2.3] - 2024-02-01                                     │
│ ...                                                         │
│                                                             │
│ [Unreleased]: https://github.com/org/repo/compare/          │
│   v2.0.0...HEAD                                             │
│ [2.0.0]: https://github.com/org/repo/compare/               │
│   v1.2.3...v2.0.0                                           │
│ [1.2.3]: https://github.com/org/repo/compare/               │
│   v1.2.2...v1.2.3                                           │
└─────────────────────────────────────────────────────────────┘

CHANGELOG AUTOMATION TOOLS:
┌─────────────────────────┬───────────────────────────────────┐
│ Tool                    │ Approach                          │
├─────────────────────────┼───────────────────────────────────┤
│ conventional-changelog  │ Generate from Conventional Commits│
│ standard-version        │ Bump + changelog + tag (npm)      │
│ release-please          │ Google's automated release PRs    │
│ semantic-release        │ Fully automated (npm, GitHub)     │
│ changesets              │ Per-PR changelog entries (monorepo)│
│ git-cliff              │ Configurable changelog generator   │
│ towncrier              │ Fragment-based (Python ecosystem)  │
└─────────────────────────┴───────────────────────────────────┘

RECOMMENDED: release-please (for most teams)
  - Creates a "Release PR" automatically when commits land on main
  - PR accumulates changelog entries from Conventional Commits
  - Merging the Release PR triggers the actual release
  - Supports monorepos with per-package versioning
  - Works with GitHub Actions natively

CHANGESETS (for monorepos):
  # Developer adds changeset with their PR:
  npx changeset
  # Creates .changeset/funny-name.md:
  #   ---
  #   "@myorg/auth": minor
  #   "@myorg/api": patch
  #   ---
  #   Add OAuth2 login support

  # At release time:
  npx changeset version    # Bumps versions, updates changelogs
  npx changeset publish    # Publishes to registry
```

### Step 5: Release Branching and Tagging
Manage the release lifecycle with branches and tags:

```
RELEASE BRANCHING PATTERNS:

Pattern 1: Tag from main (simple, for continuous delivery)
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  main ──●──●──●──●──●──●──●──●──●──●                       │
│              │           │         │                        │
│           v1.0.0      v1.1.0   v1.2.0  (tags)             │
│                                                             │
│  Hotfix: commit to main, tag new patch version              │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Pattern 2: Release branches (for stabilization period)
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  main ──●──●──●──●──●──●──●──●──●──●                       │
│              │           │                                  │
│  release/   ●──●──●     │    (stabilization + fixes)       │
│  1.0        │     │     │                                  │
│          v1.0.0-rc.1  v1.0.0                               │
│                         │                                  │
│  release/               ●──●                               │
│  1.1                    │  │                                │
│                      v1.1.0-rc.1  v1.1.0                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Pattern 3: Support branches (for multiple versions in production)
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  main ──●──●──●──●──●──●──●──●──●──● (v3.x development)   │
│              │                                              │
│  support/   ●──●──●──● (v2.x maintenance — critical fixes) │
│  2.x        │     │                                        │
│          v2.0.1  v2.0.2                                    │
│                                                             │
│  support/   ●──● (v1.x maintenance — security fixes only)  │
│  1.x        │                                              │
│          v1.5.1                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

TAGGING WORKFLOW:
  # Annotated tag (recommended — includes metadata):
  git tag -a v2.0.0 -m "Release v2.0.0 — OAuth2 support"
  git push origin v2.0.0

  # Lightweight tag (not recommended — no metadata):
  git tag v2.0.0
  git push origin v2.0.0

  # Tag from a specific commit:
  git tag -a v2.0.0 <SHA> -m "Release v2.0.0"

  # List tags:
  git tag --list 'v2.*'

  # Delete a tag (if you tagged wrong):
  git tag -d v2.0.0
  git push origin --delete v2.0.0

TAG NAMING CONVENTION:
  v<MAJOR>.<MINOR>.<PATCH>           — stable release
  v<MAJOR>.<MINOR>.<PATCH>-alpha.N   — alpha pre-release
  v<MAJOR>.<MINOR>.<PATCH>-beta.N    — beta pre-release
  v<MAJOR>.<MINOR>.<PATCH>-rc.N      — release candidate

RELEASE CREATION (GitHub):
  # Create release from tag:
  gh release create v2.0.0 \
    --title "v2.0.0 — OAuth2 Support" \
    --notes-file RELEASE_NOTES.md

  # Create release with auto-generated notes:
  gh release create v2.0.0 \
    --title "v2.0.0" \
    --generate-notes

  # Create pre-release:
  gh release create v2.0.0-rc.1 \
    --title "v2.0.0 Release Candidate 1" \
    --prerelease

  # Upload artifacts with release:
  gh release create v2.0.0 \
    --title "v2.0.0" \
    ./dist/app-linux-amd64 \
    ./dist/app-darwin-amd64 \
    ./dist/app-windows-amd64.exe
```

### Step 6: Hotfix Workflow
Emergency fixes for production issues:

```
HOTFIX WORKFLOW:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  PRODUCTION BUG DETECTED                                    │
│         │                                                   │
│         ▼                                                   │
│  1. Create hotfix branch from latest release tag            │
│     git checkout -b hotfix/payment-null v2.0.0              │
│         │                                                   │
│         ▼                                                   │
│  2. Fix the bug (minimal change, focused fix)               │
│     Write regression test FIRST                             │
│     Implement the fix                                       │
│     Run full test suite                                     │
│         │                                                   │
│         ▼                                                   │
│  3. Create PR for review (expedited review)                 │
│     Label: hotfix, urgent, production                       │
│     Reviewer: on-call + domain expert                       │
│         │                                                   │
│         ▼                                                   │
│  4. Merge and tag                                           │
│     Merge to main (or release branch)                       │
│     Tag: v2.0.1                                             │
│         │                                                   │
│         ▼                                                   │
│  5. Deploy immediately                                      │
│     Follow deployment strategy from /godmode:deploy         │
│     Monitor post-deploy                                     │
│         │                                                   │
│         ▼                                                   │
│  6. Cherry-pick to other branches if needed                 │
│     If develop branch exists: cherry-pick the fix           │
│     If support branches exist: cherry-pick to affected      │
│                                                             │
└─────────────────────────────────────────────────────────────┘

HOTFIX RULES:
  1. Minimal change — fix only the bug, nothing else
  2. Regression test required — prove the bug is fixed
  3. Full test suite must pass — no regressions
  4. Expedited but not skipped review — 1 reviewer minimum
  5. Deploy immediately after merge — do not batch with other changes
  6. Post-mortem within 48 hours — why did this reach production?

HOTFIX TIMELINE:
  T+0:    Bug reported / detected by monitoring
  T+15m:  Hotfix branch created, developer assigned
  T+1h:   Fix implemented with regression test
  T+1.5h: PR reviewed and approved
  T+2h:   Merged, tagged, deployed
  T+2.5h: Post-deploy monitoring confirms fix
  T+48h:  Post-mortem completed

  Target: Hotfix in production within 2 hours of detection
```

### Step 7: Release Train Scheduling
Coordinate releases for teams with predictable cadence:

```
RELEASE TRAIN MODEL:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Week 1        Week 2        Week 3        Week 4          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ DEVELOP  │  │ FREEZE   │  │ RELEASE  │  │ DEVELOP  │   │
│  │          │  │          │  │          │  │          │   │
│  │ Features │  │ Bug fixes│  │ Ship +   │  │ Features │   │
│  │ merged   │  │ only     │  │ monitor  │  │ merged   │   │
│  │ to main  │  │          │  │          │  │ to main  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                             │
│  ←── Sprint 1 ──────────────→←── Sprint 2 ──────────────→  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

RELEASE TRAIN SCHEDULE (bi-weekly example):
┌──────────┬──────────────────────────────────────────────────┐
│ Day      │ Activity                                         │
├──────────┼──────────────────────────────────────────────────┤
│ Mon W1   │ Sprint starts. Features merge to main.           │
│ Fri W1   │ Feature freeze. Release branch cut.              │
│ Mon W2   │ QA on release branch. Bug fixes only.            │
│ Wed W2   │ Release candidate tagged (v2.1.0-rc.1).          │
│ Thu W2   │ Final QA. Go/no-go decision.                     │
│ Fri W2   │ Release shipped (v2.1.0). Changelog published.   │
│ Mon W3   │ Next sprint starts. Retrospective on release.    │
└──────────┴──────────────────────────────────────────────────┘

FEATURE FREEZE RULES:
  After freeze, only these changes merge to the release branch:
  ✓ Bug fixes for issues found in QA
  ✓ Documentation corrections
  ✓ Configuration fixes
  ✗ New features (go to next release)
  ✗ Refactoring (go to next release)
  ✗ "Small" changes that aren't fixes (go to next release)

RELEASE READINESS CHECKLIST:
  [ ] All P0/P1 bugs fixed
  [ ] No P0/P1 bugs open against this release
  [ ] All automated tests passing
  [ ] Performance benchmarks within threshold
  [ ] Security scan clean
  [ ] Release notes reviewed by PM
  [ ] Migration guide reviewed (if breaking changes)
  [ ] Rollback procedure tested
  [ ] On-call engineer briefed
  [ ] Stakeholders notified of release window

RELEASE COMMUNICATION:
  Pre-release (1 week before):
    "Release v2.1.0 scheduled for Friday. Feature freeze is tomorrow.
     Merge your feature PRs by EOD Thursday."

  Release day:
    "v2.1.0 is being deployed. Expected completion: 2:00 PM UTC.
     Monitor: <dashboard-link>"

  Post-release:
    "v2.1.0 is live. Release notes: <link>. Report issues: <link>.
     Next release: v2.2.0 on March 29."
```

### Step 8: Release Automation Pipeline
Automate the entire release process:

```
AUTOMATED RELEASE PIPELINE:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Push to main                                               │
│       │                                                     │
│       ▼                                                     │
│  CI: Tests + Lint + Security Scan                           │
│       │                                                     │
│       ▼                                                     │
│  release-please: Create/update Release PR                   │
│       │                                                     │
│       ▼ (on merge of Release PR)                            │
│  Bump version in package files                              │
│       │                                                     │
│       ▼                                                     │
│  Update CHANGELOG.md                                        │
│       │                                                     │
│       ▼                                                     │
│  Create git tag (v2.0.0)                                    │
│       │                                                     │
│       ▼                                                     │
│  Create GitHub Release with notes                           │
│       │                                                     │
│       ▼                                                     │
│  Build and publish artifacts                                │
│  (npm publish / docker push / binary upload)                │
│       │                                                     │
│       ▼                                                     │
│  Notify: Slack, email, release channel                      │
│       │                                                     │
│       ▼                                                     │
│  Deploy to staging → production                             │
│  (trigger /godmode:deploy pipeline)                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

GITHUB ACTIONS RELEASE WORKFLOW:
  name: Release
  on:
    push:
      branches: [main]

  jobs:
    release-please:
      runs-on: ubuntu-latest
      outputs:
        release_created: ${{ steps.release.outputs.release_created }}
        tag_name: ${{ steps.release.outputs.tag_name }}
      steps:
        - uses: googleapis/release-please-action@v4
          id: release
          with:
            release-type: node  # or python, rust, etc.

    publish:
      needs: release-please
      if: ${{ needs.release-please.outputs.release_created }}
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - run: npm ci
        - run: npm test
        - run: npm publish
          env:
            NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

SEMANTIC-RELEASE (alternative — fully automated):
  # .releaserc.json
  {
    "branches": ["main"],
    "plugins": [
      "@semantic-release/commit-analyzer",
      "@semantic-release/release-notes-generator",
      "@semantic-release/changelog",
      "@semantic-release/npm",
      "@semantic-release/github",
      "@semantic-release/git"
    ]
  }
  # Runs on every push to main
  # Analyzes commits, determines version bump, publishes everything
```

### Step 9: Release Report

```
┌────────────────────────────────────────────────────────────┐
│  RELEASE PLAN                                              │
├────────────────────────────────────────────────────────────┤
│  Version: <current> → <next>                               │
│  Bump type: <MAJOR | MINOR | PATCH>                        │
│  Release type: <stable | pre-release | hotfix>             │
│                                                            │
│  Changes included:                                         │
│    Features: <N>                                           │
│    Bug fixes: <N>                                          │
│    Breaking changes: <N>                                   │
│    Performance: <N>                                        │
│                                                            │
│  Artifacts:                                                │
│    Tag: v<version>                                         │
│    GitHub Release: <url>                                   │
│    Package: <registry url>                                 │
│    Changelog: CHANGELOG.md updated                         │
│    Release notes: generated                                │
│                                                            │
│  Automation:                                               │
│    Versioning: <manual | semi-automated | fully automated> │
│    Changelog: <manual | automated>                         │
│    Publishing: <manual | CI/CD>                            │
│    Notifications: <manual | automated>                     │
│                                                            │
│  Schedule:                                                 │
│    Release date: <date>                                    │
│    Next release: <date>                                    │
│                                                            │
│  Ready for: /godmode:deploy or /godmode:ship               │
└────────────────────────────────────────────────────────────┘
```

### Step 10: Commit and Transition
1. Update version files, CHANGELOG.md, and release notes
2. Commit: `"release: v<version> — <summary of key changes>"`
3. Tag: `git tag -a v<version> -m "Release v<version>"`
4. After release: "Release v<version> published. Use `/godmode:deploy` for deployment or `/godmode:ship` for distribution."

## Key Behaviors

1. **Version numbers have meaning.** Semantic versioning is a contract with your users. A PATCH bump must not break anything. A MINOR bump must be backward compatible. Respect the contract.
2. **Changelog is for humans.** Write changelog entries that a user (not a developer) can understand. "Refactored auth module" means nothing to a user. "Login is now 2x faster" means everything.
3. **Automate releases.** Manual releases are error-prone and create bottlenecks. Use release-please, semantic-release, or changesets to automate versioning, changelogs, and publishing.
4. **Hotfixes are special.** A hotfix is not a normal release. It is an emergency with a minimal fix, expedited review, and immediate deployment. Do not batch other changes into a hotfix.
5. **Release trains keep cadence.** Predictable release schedules reduce stress, improve planning, and set clear expectations for stakeholders.
6. **Breaking changes require migration guides.** Never ship a MAJOR version without a migration guide. Your users need to know exactly what to change and why.
7. **Every release is tagged.** Tags are permanent markers in history. Use annotated tags with meaningful messages. Never delete a tag after it has been published.

## Example Usage

### Creating a release with changelog
```
User: /godmode:release We've finished the OAuth2 feature and fixed
       several bugs. Time to release.

Release: Assessing release context...

RELEASE ASSESSMENT:
Latest version: v1.2.3
Versioning: Semantic Versioning

Analyzing commits since v1.2.3:
  feat(auth): add OAuth2 login with Google provider      → MINOR
  feat(auth): add OAuth2 login with GitHub provider      → MINOR
  fix(api): handle null response from payment gateway    → PATCH
  fix(reports): timezone handling in scheduled reports   → PATCH
  perf(search): add index on users.email                 → PATCH

Version bump: MINOR (new features, no breaking changes)
Next version: v1.2.3 → v1.3.0

Generating changelog entry...

## [1.3.0] - 2024-03-15

### Added
- OAuth2 login with Google and GitHub providers (#1234, #1245)

### Fixed
- Null response handling from payment gateway (#1289)
- Timezone handling in scheduled reports (#1301)

### Performance
- 40% faster user search via email index (#1278)

Generating release notes...
Creating tag v1.3.0...
Creating GitHub release...

Release v1.3.0 published: https://github.com/org/repo/releases/tag/v1.3.0
Changelog updated: CHANGELOG.md
Next step: /godmode:deploy to ship to production
```

### Setting up automated releases
```
User: /godmode:release --setup We want fully automated releases
       triggered by merges to main.

Release: Setting up automated release pipeline...

Recommended tool: release-please (Google)
  - Creates Release PR automatically from Conventional Commits
  - Merging the Release PR triggers version bump + tag + publish
  - Supports your Node.js project natively

Configuration:
  1. ✓ .release-please-manifest.json created
  2. ✓ release-please-config.json created
  3. ✓ .github/workflows/release.yml created
  4. ✓ Commit message convention verified (Conventional Commits)

Workflow:
  Developers merge PRs to main (using Conventional Commits)
  → release-please creates/updates a Release PR
  → PR shows pending version bump and changelog preview
  → Team merges Release PR when ready to release
  → CI bumps version, updates CHANGELOG, creates tag and GitHub Release
  → Publish job pushes to npm registry

Setup complete. Next merge to main will trigger the first Release PR.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full release assessment and execution |
| `--setup` | Set up automated release pipeline |
| `--bump <type>` | Force specific version bump (major/minor/patch) |
| `--pre-release <tag>` | Create pre-release (alpha/beta/rc) |
| `--hotfix` | Hotfix workflow for production emergency |
| `--notes` | Generate release notes only |
| `--changelog` | Update changelog only |
| `--dry-run` | Show what the release would do without executing |
| `--schedule` | Set up release train schedule |
| `--status` | Show release status and next scheduled release |
| `--history` | Show release history and metrics |

## Anti-Patterns

- **Do NOT release without a changelog.** Every release must have a human-readable summary of changes. "See git log" is not a changelog.
- **Do NOT manually bump versions.** Manual versioning leads to mistakes (forgetting to bump, bumping wrong component). Automate it from commit messages.
- **Do NOT batch unrelated changes into hotfixes.** A hotfix is for one specific production bug. Everything else waits for the next regular release.
- **Do NOT skip pre-releases for major versions.** Major versions (breaking changes) need alpha/beta/RC stages. Your users need time to test and adapt.
- **Do NOT delete published tags.** Tags that have been pushed and used by others are permanent. If you tagged wrong, create a new corrected tag.
- **Do NOT release on Fridays.** Schedule releases for Tuesday or Wednesday. If something goes wrong, you have the rest of the week to fix it.
- **Do NOT release without a rollback plan.** Every release must have a defined rollback procedure. If you cannot roll back, you are not ready to release.
