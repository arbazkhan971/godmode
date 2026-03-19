---
name: changelog
description: |
  Changelog and release notes management skill. Activates when user needs to create, maintain, or auto-generate changelogs and release notes. Supports Keep a Changelog format, Conventional Commits for auto-generation, audience-specific release notes (developers vs end users), breaking change communication, and migration guide generation. Triggers on: /godmode:changelog, "update changelog", "write release notes", "generate migration guide", or when preparing a release.
---

# Changelog — Changelog & Release Notes

## When to Activate
- User invokes `/godmode:changelog`
- User says "update changelog", "write release notes", "what changed?"
- User says "generate migration guide", "breaking change documentation"
- User says "set up conventional commits", "auto-generate changelog"
- Preparing a release (often chained from `/godmode:release` or `/godmode:ship`)
- Breaking changes have been introduced and need communication
- New version is being published to a package registry

## Workflow

### Step 1: Analyze Change History
Examine commits, PRs, and tags since the last release:

```
CHANGE ANALYSIS:
┌──────────────────────────────────────────────────────────┐
│  Last release: <tag> (<date>)                            │
│  Commits since: <N>                                      │
│  PRs merged: <N>                                         │
│  Contributors: <N>                                       │
│                                                          │
│  Commit Categories:                                      │
│  feat:     <N> (new features)                            │
│  fix:      <N> (bug fixes)                               │
│  perf:     <N> (performance improvements)                │
│  refactor: <N> (code refactoring)                        │
│  docs:     <N> (documentation)                           │
│  test:     <N> (tests)                                   │
│  chore:    <N> (maintenance)                             │
│  ci:       <N> (CI/CD changes)                           │
│                                                          │
│  Breaking changes: <N> (commits with BREAKING CHANGE)    │
│  Deprecations: <N>                                       │
│                                                          │
│  Version bump: <major | minor | patch>                   │
│  Suggested version: <x.y.z>                              │
└──────────────────────────────────────────────────────────┘
```

Commands to gather data:
```bash
# Commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Conventional commits parsed
git log $(git describe --tags --abbrev=0)..HEAD --format="%s" | \
  grep -E "^(feat|fix|perf|refactor|docs|test|chore|ci|build|style)(\(.+\))?!?:"

# Breaking changes
git log $(git describe --tags --abbrev=0)..HEAD --format="%B" | \
  grep -E "BREAKING CHANGE:|^[a-z]+(\(.+\))?!:"

# Contributors
git log $(git describe --tags --abbrev=0)..HEAD --format="%aN" | sort -u
```

### Step 2: Conventional Commits Setup
If not already configured, set up Conventional Commits for automatic changelog generation:

#### Commit Message Format
```
<type>(<scope>)!: <description>

[optional body]

[optional footer(s)]
BREAKING CHANGE: <description>
```

Types:
```
CONVENTIONAL COMMIT TYPES:
┌──────────┬───────────────────────────────┬──────────────┐
│ Type     │ Description                   │ Changelog?   │
├──────────┼───────────────────────────────┼──────────────┤
│ feat     │ New feature                   │ YES (Added)  │
│ fix      │ Bug fix                       │ YES (Fixed)  │
│ perf     │ Performance improvement       │ YES (Changed)│
│ refactor │ Code refactoring              │ NO           │
│ docs     │ Documentation changes         │ NO*          │
│ test     │ Test additions or fixes       │ NO           │
│ chore    │ Maintenance tasks             │ NO           │
│ ci       │ CI/CD changes                 │ NO           │
│ build    │ Build system changes          │ NO           │
│ style    │ Code style (formatting, etc.) │ NO           │
│ revert   │ Revert a previous commit      │ YES          │
└──────────┴───────────────────────────────┴──────────────┘
* docs may appear in changelog for user-facing documentation
```

#### Commitlint Setup
```bash
# Install commitlint
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# Create config
cat > commitlint.config.js << 'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'perf', 'refactor', 'docs',
      'test', 'chore', 'ci', 'build', 'style', 'revert'
    ]],
    'subject-case': [2, 'always', 'lower-case'],
    'header-max-length': [2, 'always', 100],
    'body-max-line-length': [2, 'always', 100],
  },
};
EOF

# Set up Husky hook
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

#### Commitizen Setup (Interactive Commits)
```bash
# Install Commitizen
npm install --save-dev commitizen cz-conventional-changelog

# Configure
npx commitizen init cz-conventional-changelog --save-dev --save-exact

# Usage: `npx cz` or `npm run commit` instead of `git commit`
```

### Step 3: Keep a Changelog Format
Generate or update CHANGELOG.md following the Keep a Changelog standard:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature descriptions here

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security vulnerability fixes

## [x.y.z] — YYYY-MM-DD

### Added
- Feature A: description (#PR)
- Feature B: description (#PR)

### Changed
- Changed behavior X to Y for reason Z (#PR)

### Fixed
- Fixed bug where condition caused error (#PR)
- Fixed regression in feature from vX.Y.Z (#PR)

### Security
- Upgraded dependency X to fix CVE-YYYY-NNNNN (#PR)

## [x.y.z-1] — YYYY-MM-DD
...

[Unreleased]: https://github.com/<org>/<repo>/compare/vx.y.z...HEAD
[x.y.z]: https://github.com/<org>/<repo>/compare/vx.y.z-1...vx.y.z
[x.y.z-1]: https://github.com/<org>/<repo>/releases/tag/vx.y.z-1
```

#### Keep a Changelog Rules
```
CHANGELOG RULES:
1. Changelogs are for humans, not machines
2. There should be an entry for every version
3. The same types of changes should be grouped
4. Versions and sections should be linkable
5. The latest version comes first
6. The release date of each version is displayed
7. Mention whether you follow Semantic Versioning

SECTION ORDER:
  Added       — new features
  Changed     — changes in existing functionality
  Deprecated  — soon-to-be removed features
  Removed     — now removed features
  Fixed       — bug fixes
  Security    — vulnerability fixes

GUIDELINES:
- Write for the reader, not the author
- One entry per change, not per commit
- Group related changes into a single entry
- Link to PRs and issues for context
- Use imperative mood: "Add feature" not "Added feature"
- Include migration notes for breaking changes
```

### Step 4: Auto-Generate Changelog
Use tools to generate changelog from Conventional Commits:

#### conventional-changelog
```bash
# Install
npm install --save-dev conventional-changelog-cli

# Generate changelog (appends to existing)
npx conventional-changelog -p angular -i CHANGELOG.md -s

# Generate from scratch (full history)
npx conventional-changelog -p angular -i CHANGELOG.md -s -r 0

# Custom preset
npx conventional-changelog -p conventionalcommits -i CHANGELOG.md -s
```

#### standard-version / release-please
```bash
# Option A: standard-version (local tool)
npm install --save-dev standard-version

# Bump version, update changelog, create tag
npx standard-version                    # auto-detect bump
npx standard-version --release-as major # force major
npx standard-version --release-as 1.2.3 # specific version
npx standard-version --dry-run          # preview changes

# Option B: release-please (GitHub Action)
# .github/workflows/release-please.yml
```

```yaml
# .github/workflows/release-please.yml
name: Release Please
on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node  # or: python, go, rust, etc.
          changelog-types: |
            [
              {"type": "feat", "section": "Features", "hidden": false},
              {"type": "fix", "section": "Bug Fixes", "hidden": false},
              {"type": "perf", "section": "Performance", "hidden": false},
              {"type": "deps", "section": "Dependencies", "hidden": false},
              {"type": "docs", "section": "Documentation", "hidden": true},
              {"type": "chore", "section": "Miscellaneous", "hidden": true}
            ]
```

### Step 5: Release Notes for Different Audiences
Write release notes tailored to who reads them:

#### Developer-Facing Release Notes
```markdown
# v2.0.0 Release Notes

## Breaking Changes

### `createClient()` API signature changed
The `createClient()` function now requires an options object instead of
positional arguments.

**Before (v1.x):**
```typescript
const client = createClient('https://api.example.com', 'my-api-key');
```

**After (v2.0):**
```typescript
const client = createClient({
  baseUrl: 'https://api.example.com',
  apiKey: 'my-api-key',
  timeout: 30000,  // new: configurable timeout
  retries: 3,      // new: automatic retries
});
```

**Migration:** See [Migration Guide](#migration-from-1x-to-2x) below.

### Minimum Node.js version raised to 20
Node.js 18 is no longer supported. Node.js 20 LTS is now the minimum.

## New Features

### Automatic request retries (#234)
Failed requests are now automatically retried with exponential backoff.
Configure via the `retries` option (default: 3).

```typescript
const client = createClient({ retries: 5, retryDelay: 1000 });
```

### Streaming responses (#256)
New `client.stream()` method for Server-Sent Events:

```typescript
for await (const event of client.stream('/events')) {
  console.log(event.data);
}
```

## Bug Fixes
- Fixed memory leak in connection pool when requests timeout (#278)
- Fixed race condition in concurrent batch requests (#291)
- Fixed incorrect Content-Type header for multipart uploads (#303)

## Performance
- Reduced cold start time by 40% through lazy initialization (#312)
- Improved JSON parsing performance for large payloads (#318)

## Dependencies
- Upgraded `undici` to 6.x (HTTP client)
- Removed `node-fetch` dependency (replaced by native fetch)
```

#### User-Facing Release Notes
```markdown
# What's New in v2.0

## Highlights

### Faster and more reliable
Requests are now automatically retried when they fail, and the
library starts up 40% faster. Your integrations are more resilient
with zero code changes.

### Real-time streaming
You can now receive events in real-time using the new streaming API.
Perfect for live dashboards, notifications, and real-time updates.

### Simplified setup
The new configuration format makes it easier to set up the client
with all options in one place.

## Upgrade Notice
This is a major release with breaking changes. If you are upgrading
from v1.x, please follow the [Migration Guide](./MIGRATION-v2.md)
before updating.

**Minimum requirements:** Node.js 20 or later.

## Full Changelog
See [CHANGELOG.md](./CHANGELOG.md) for the complete list of changes.
```

#### Release Notes Template
```
RELEASE NOTES STRUCTURE:

For developers:
  1. Breaking changes (with before/after code, migration steps)
  2. New features (with code examples)
  3. Bug fixes (with issue references)
  4. Performance improvements (with metrics)
  5. Dependency changes
  6. Deprecation notices

For users:
  1. Highlights (plain language, benefit-focused)
  2. New capabilities (what you can do now)
  3. Improvements (what got better)
  4. Upgrade notice (if breaking changes)
  5. Link to full changelog
```

### Step 6: Breaking Change Communication
When breaking changes are introduced, communicate them thoroughly:

```
BREAKING CHANGE COMMUNICATION PLAN:

1. ADVANCE NOTICE (1-2 releases before)
   - Add deprecation warnings in code
   - Document deprecated APIs in changelog
   - Add @deprecated JSDoc/docstring annotations
   - Log deprecation warnings at runtime

2. MIGRATION GUIDE (released with breaking version)
   - Step-by-step upgrade instructions
   - Before/after code examples for every change
   - Automated migration scripts (codemods) if possible
   - Estimated migration time
   - Rollback instructions

3. RELEASE COMMUNICATION
   - Changelog entry with BREAKING CHANGE section
   - GitHub Release with prominent breaking change banner
   - Blog post or announcement for major breaking changes
   - Discord/Slack announcement
   - Social media for widely-used projects

4. SUPPORT WINDOW
   - Maintain previous major version for N months
   - Backport critical security fixes
   - Clearly communicate end-of-support date
```

### Step 7: Migration Guide Generation
Create detailed migration guides for breaking changes:

```markdown
# Migration Guide: v1.x to v2.0

## Overview
This guide covers all breaking changes in v2.0 and how to update
your code. Estimated migration time: 15-30 minutes for most projects.

## Prerequisites
- Node.js 20 or later (was 18+)
- npm 10 or later

## Step-by-Step Migration

### 1. Update the package
```bash
npm install <package>@2
```

### 2. Update client initialization
**Find all occurrences of:**
```typescript
createClient(url, apiKey)
```

**Replace with:**
```typescript
createClient({ baseUrl: url, apiKey })
```

**Automated:** Run the codemod:
```bash
npx @<package>/codemods v2-client-init
```

### 3. Update deprecated method calls
| v1.x Method | v2.0 Replacement |
|-------------|-----------------|
| `client.get(path)` | `client.request('GET', path)` |
| `client.headers` | `client.getHeaders()` |
| `client.onError` | `client.on('error', handler)` |

### 4. Update TypeScript types
```typescript
// Before
import { ClientOptions } from '<package>';

// After — renamed for clarity
import { ClientConfig } from '<package>';
```

### 5. Test your changes
```bash
npm test
```

## Common Issues

### "TypeError: createClient is not a function"
You may be using a named import instead of default import:
```typescript
// Wrong
import { createClient } from '<package>';

// Correct
import createClient from '<package>';
```

### "Error: Node.js 18 is not supported"
Update to Node.js 20: `nvm install 20 && nvm use 20`

## Rollback
If you need to rollback:
```bash
npm install <package>@1
```

## Getting Help
- [GitHub Issues](https://github.com/<org>/<repo>/issues)
- [Discord](https://discord.gg/<invite>)
```

### Step 8: Changelog Entry Generation
For each change, generate a properly formatted entry:

```
CHANGELOG ENTRY FORMAT:

Single entry:
  - <Imperative verb> <what changed> (<reason/impact>) (#<PR>)

Examples:
  - Add streaming response support for real-time data (#256)
  - Change createClient() to accept options object instead of positional args (#234)
  - Fix memory leak in connection pool during timeout (#278)
  - Remove deprecated `legacyMode` option (#301)
  - Deprecate `client.headers` property in favor of `client.getHeaders()` (#289)
  - Fix security issue in token refresh flow (CVE-2026-12345) (#310)

QUALITY CHECKLIST:
- [ ] Entry describes the change from the user's perspective
- [ ] Entry starts with imperative verb (Add, Change, Fix, Remove, Deprecate)
- [ ] Entry references the PR or issue number
- [ ] Breaking changes are clearly marked
- [ ] Security fixes reference the CVE
- [ ] Entry is one line (details go in PR description, not changelog)
```

### Step 9: Commit and Transition

```
1. If setting up Conventional Commits:
   Commit: "changelog: configure conventional commits and commitlint"

2. If generating changelog:
   Commit: "changelog: generate CHANGELOG.md for v<version>"

3. If writing release notes:
   Commit: "changelog: write release notes for v<version>"

4. If creating migration guide:
   Commit: "changelog: add migration guide for v<old> to v<new>"

5. Transition:
   - If preparing release: "Changelog ready. Proceed with /godmode:ship to publish."
   - If migration needed: "Migration guide created. Share with users before releasing."
   - If setting up automation: "Auto-changelog configured. Future releases will generate changelogs from commits."
```

## Key Behaviors

1. **Changelogs are for humans.** Write for the person upgrading, not the person who wrote the code. "Fix race condition in batch processor" is better than "Fix #291".
2. **One entry per user-visible change.** Five commits that fix one bug become one changelog entry. Refactoring commits do not appear.
3. **Breaking changes are prominent.** They go first, they include migration steps, and they link to a full migration guide for major versions.
4. **Conventional Commits enable automation.** Consistent commit messages allow tools to generate changelogs automatically. The upfront discipline pays for itself.
5. **Different audiences need different notes.** Developers want code examples and API changes. End users want plain language and highlights. Write both.
6. **Deprecation before removal.** Warn users at least one release before removing functionality. Give them time to migrate.
7. **Semantic Versioning means something.** Major = breaking changes. Minor = new features. Patch = bug fixes. Do not ship breaking changes in a patch release.

## Example Usage

### Generate changelog for a release
```
User: /godmode:changelog Generate changelog for our next release

Changelog: Analyzing commits since v1.5.2...

CHANGE ANALYSIS:
  Last release: v1.5.2 (2026-02-15)
  Commits since: 34
  PRs merged: 12
  Contributors: 5

  feat: 4, fix: 6, perf: 1, docs: 3, chore: 8, test: 5, ci: 2
  refactor: 5
  Breaking changes: 0
  Version bump: minor
  Suggested version: v1.6.0

Generated CHANGELOG.md entry:

## [1.6.0] — 2026-03-19

### Added
- Add batch processing API for bulk operations (#145)
- Add configurable request timeout option (#152)
- Add TypeScript strict mode support (#158)
- Add OpenTelemetry tracing integration (#163)

### Fixed
- Fix connection pool exhaustion under high concurrency (#147)
- Fix incorrect error code mapping for 429 responses (#149)
- Fix memory leak in event listener cleanup (#155)
- Fix race condition in cache invalidation (#160)
- Fix incorrect Content-Length for UTF-8 payloads (#162)
- Fix TypeScript type inference for generic responses (#165)

### Performance
- Reduce JSON serialization overhead by 25% (#157)

Changelog updated. Ready for /godmode:ship.
```

### Set up auto-generated changelogs
```
User: /godmode:changelog --setup

Changelog: Setting up Conventional Commits and auto-changelog...

Installed:
  - @commitlint/cli + @commitlint/config-conventional
  - commitizen + cz-conventional-changelog
  - release-please GitHub Action

Created:
  - commitlint.config.js
  - .husky/commit-msg (commitlint hook)
  - .github/workflows/release-please.yml
  - CHANGELOG.md (initial)

All future commits will be validated against Conventional Commits format.
Use `npx cz` for interactive commit creation.
Changelogs will be auto-generated on release.
```

### Write migration guide
```
User: /godmode:changelog --migration v1 v2

Changelog: Analyzing breaking changes between v1.x and v2.0...

Breaking changes found: 3
  1. createClient() API signature changed
  2. Minimum Node.js version raised to 20
  3. Removed deprecated legacyMode option

Created: MIGRATION-v2.md
  - Step-by-step upgrade instructions
  - Before/after code for all 3 breaking changes
  - Codemod command for automated migration
  - Common issues and troubleshooting
  - Rollback instructions

Share this guide with users before releasing v2.0.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Generate changelog entry for next release |
| `--setup` | Set up Conventional Commits, commitlint, and auto-changelog |
| `--release <version>` | Generate changelog for specific version |
| `--migration <from> <to>` | Generate migration guide between versions |
| `--notes` | Write user-facing release notes (non-technical) |
| `--dev-notes` | Write developer-facing release notes (technical) |
| `--breaking` | List and document breaking changes only |
| `--full` | Regenerate entire changelog from git history |
| `--dry-run` | Preview changelog without writing files |
| `--format <fmt>` | Output format (keepachangelog, conventional, github) |

## Anti-Patterns

- **Do NOT use git log as a changelog.** A list of commit messages is not a changelog. Changelogs summarize user-visible changes, not implementation details.
- **Do NOT ship breaking changes without a migration guide.** Users will file issues instead of reading code. Save everyone time by writing the guide.
- **Do NOT skip the unreleased section.** Changes should be documented as they are merged, not retroactively at release time.
- **Do NOT mix audiences.** Developer release notes and user-facing release notes serve different purposes. Write both when needed.
- **Do NOT forget PR/issue references.** Every changelog entry should link to the PR for context. "Fixed a bug" is not helpful.
- **Do NOT backdate entries.** The release date is when the version was published, not when the code was written.
- **Do NOT include internal changes.** Refactoring, test additions, and CI changes are invisible to users and do not belong in a public changelog.
- **Do NOT version without Semantic Versioning.** If your project claims to use SemVer, follow it strictly. Breaking changes in patch releases destroy trust.
