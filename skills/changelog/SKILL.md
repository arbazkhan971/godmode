---
name: changelog
description: |
  Changelog and release notes management skill. Activates when user needs to create, maintain, or auto-generate
    changelogs and release notes. Supports Keep a Changelog format, Conventional Commits for auto-generation,
    audience-specific release notes (developers vs end users), breaking change communication, and migration guide
    generation. Triggers on: /godmode:changelog, "update changelog", "write release notes", "generate migration
    guide", or when preparing a release.
---

# Changelog — Changelog & Release Notes

## When to Activate
- User invokes `/godmode:changelog`
- User says "update changelog", "write release notes", "what changed?"
- User says "generate migration guide", "breaking change documentation"
- User says "set up conventional commits", "auto-generate changelog"
- Preparing a release (often chained from `/godmode:release` or `/godmode:ship`)
- Recent commits introduced breaking changes that need communication
- Team publishes a new version to a package registry

## Workflow

### Step 1: Analyze Change History
Examine commits, PRs, and tags since the last release:

```
CHANGE ANALYSIS:
  Last release: <tag> (<date>)
```
Commands to gather data:
```bash
# Commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

```

### Step 2: Conventional Commits Setup
If not already configured, set up Conventional Commits for automatic changelog generation:

#### Commit Message Format
```
<type>(<scope>)!: <description>

[optional body]
```

Types:
```
CONVENTIONAL COMMIT TYPES:
| Type | Description | Changelog? |
```

#### Commitlint Setup
```bash
# Install commitlint
npm install --save-dev @commitlint/cli @commitlint/config-conventional

```

### Step 3: Keep a Changelog Format
Generate or update CHANGELOG.md following the Keep a Changelog standard:

```markdown
# Changelog

This file documents all notable changes to this project.
```
#### Keep a Changelog Rules
```
CHANGELOG RULES:
1. Changelogs are for humans, not machines
2. Include an entry for every version
```

### Step 4: Auto-Generate Changelog
Use tools to generate changelog from Conventional Commits:

#### conventional-changelog
```bash
# Install
npm install --save-dev conventional-changelog-cli

```

#### standard-version / release-please
```bash
# Option A: standard-version (local tool)
npm install --save-dev standard-version

```

```yaml
# .github/workflows/release-please.yml
name: Release Please
on:
```
### Step 5: Release Notes for Different Audiences
Write release notes tailored to who reads them:

#### Developer-Facing Release Notes
```markdown
# v2.0.0 Release Notes

## Breaking Changes
```

**After (v2.0):**
```typescript
const client = createClient({
  baseUrl: 'https://api.example.com',
  apiKey: 'my-api-key',
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
```

#### Release Notes Template
```
RELEASE NOTES STRUCTURE:

For developers:
```

### Step 6: Breaking Change Communication
When breaking changes are introduced, communicate them thoroughly:

```
BREAKING CHANGE COMMUNICATION PLAN:

1. ADVANCE NOTICE (1-2 releases before)
```

### Step 7: Migration Guide Generation
Create detailed migration guides for breaking changes:

```markdown
# Migration Guide: v1.x to v2.0

## Overview
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
|--|--|
| `client.get(path)` | `client.request('GET', path)` |
| `client.headers` | `client.getHeaders()` |
| `client.onError` | `client.on('error', handler)` |

### 4. Update TypeScript types
```typescript
// Before
import { ClientOptions } from '<package>';

```

### 5. Test your changes
```bash
npm test
```

## Common Issues

### "TypeError: createClient is not a function"
Check if a named import is used instead of default import:
```typescript
// Wrong
import { createClient } from '<package>';

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

### Step 8: Commit and Transition

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
```
## Key Behaviors

IF breaking changes > 0: write migration guide before release.
WHEN commits don't follow conventional format: parse PR titles as fallback.
IF changelog entry count < commit count * 0.5: review for missed changes.

## Quality Targets
- Target: 100% PRs tagged with changelog category
- Generation time: <5min for release notes
- Target: 0 breaking changes without BREAKING CHANGE tag

## HARD RULES

1. **NEVER STOP** until all commits since last release are categorized and the changelog entry is written.
2. **git commit BEFORE verify** — commit the changelog/release notes, then verify formatting.
3. **Automatic revert on regression** — if the generated changelog has incorrect version numbers or dates,
revert and regenerate.
4. **TSV logging** — log every changelog generation run:
   ```
   timestamp	version	commits_analyzed	entries_generated	breaking_changes	status
   ```
5. **NEVER include internal-only changes** (refactor, test, chore, ci) in user-facing changelogs.
6. **NEVER backdate release entries** — use the actual publication date.
7. **ALWAYS link PRs/issues** — every entry must have a reference.

## Explicit Loop Protocol

When processing commits for changelog generation:

```
current_iteration = 0
unprocessed_commits = all commits since last tag
changelog_entries = []
```
## Output Format

After each changelog skill invocation, emit a structured report:

```
CHANGELOG REPORT:
| Last release | <tag> (<date>) |
```
