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
┌──────────┬───────────────────────────────┬──────────────┐
│ Type     │ Description                   │ Changelog?   │
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

All notable changes to this project will be documented in this file.
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
|-------------|-----------------|
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
   - If setting up automation: "Auto-changelog configured. Future releases will generate changelogs from commits."
```

## Key Behaviors

```

### Write migration guide
```
User: /godmode:changelog --migration v1 v2

Changelog: Analyzing breaking changes between v1.x and v2.0...
```

## HARD RULES

1. **NEVER STOP** until all commits since last release are categorized and the changelog entry is written.
2. **git commit BEFORE verify** — commit the changelog/release notes, then verify formatting.
3. **Automatic revert on regression** — if the generated changelog has incorrect version numbers or dates, revert and regenerate.
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
┌──────────────────────────────────────────────────────┐
│  Last release        │  <tag> (<date>)                │
```

## TSV Logging

Log every changelog generation for tracking (as referenced in Hard Rules):

```
timestamp	skill	version	commits_analyzed	entries_generated	breaking_changes	status
2026-03-20T14:00:00Z	changelog	v1.6.0	34	11	0	ready
2026-03-20T14:30:00Z	changelog	v2.0.0	52	18	3	needs_migration_guide
```

## Success Criteria

The changelog skill is complete when ALL of the following are true:
1. All commits since last release are categorized (feat, fix, perf, breaking, skip)
2. Every user-visible change has a changelog entry
3. Every entry includes a PR/issue reference
4. Breaking changes are documented first with migration steps
5. Version number follows semantic versioning correctly
6. Changelog entry uses imperative mood ("Add feature" not "Added feature")
7. Internal changes (refactor, test, ci, chore) are excluded from user-facing changelog
8. Migration guide exists for any breaking changes (major version bumps)

## Keep/Discard Discipline
```
After EACH changelog generation or update:
  1. MEASURE: Verify all commits since last release are categorized. Count entries.
  2. COMPARE: Does every user-visible change have an entry? Are PR references present?
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All commits since last release are categorized
  - Every user-visible change has a changelog entry with PR reference
```

## Error Recovery
| Failure | Action |
|---------|--------|
| Commit messages do not follow conventional format | Parse what exists. Use PR titles as fallback. Flag non-conforming commits for manual categorization. |
| Duplicate entries from merge commits | Filter merge commits (`--no-merges`). Deduplicate by PR number or commit hash. |
| Breaking change not flagged | Scan for `BREAKING CHANGE:` in commit body and `!` after type. Also check for API removals in diff. |
| Changelog generation misses commits | Verify tag range is correct. Check for squash merges that lose individual commit messages. |
