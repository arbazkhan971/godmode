# /godmode:changelog

Changelog and release notes management — Keep a Changelog format, Conventional Commits auto-generation, audience-specific release notes, breaking change communication, and migration guide generation.

## Usage

```
/godmode:changelog                              # Generate changelog entry for next release
/godmode:changelog --setup                      # Set up Conventional Commits and auto-changelog
/godmode:changelog --release 2.0.0              # Generate changelog for specific version
/godmode:changelog --migration v1 v2            # Generate migration guide between versions
/godmode:changelog --notes                      # Write user-facing release notes
/godmode:changelog --dev-notes                  # Write developer-facing release notes
/godmode:changelog --breaking                   # List and document breaking changes only
/godmode:changelog --full                       # Regenerate entire changelog from git history
/godmode:changelog --dry-run                    # Preview changelog without writing files
/godmode:changelog --format keepachangelog      # Output format (keepachangelog, conventional, github)
```

## What It Does

1. Analyzes commit history since the last release (types, counts, contributors)
2. Determines version bump from Conventional Commits (major, minor, patch)
3. Generates CHANGELOG.md entries in Keep a Changelog format
4. Writes audience-specific release notes (developers vs end users)
5. Documents breaking changes with before/after code examples
6. Generates migration guides with step-by-step upgrade instructions
7. Sets up tooling: commitlint, Commitizen, release-please
8. Configures auto-changelog generation via GitHub Actions

## Output
- CHANGELOG.md updated with new version entry
- Release notes (developer-facing and/or user-facing)
- Migration guide: MIGRATION-v<version>.md (for breaking changes)
- Tooling config: commitlint.config.js, .husky/commit-msg, release-please workflow
- Commit: `"changelog: generate CHANGELOG.md for v<version>"`

## Next Step
After changelog: `/godmode:ship` to publish the release, or `/godmode:opensource` for full project management.

## Examples

```
/godmode:changelog                              # Auto-generate from commits
/godmode:changelog --setup                      # Configure commit conventions
/godmode:changelog --migration v1 v2            # Write v1-to-v2 migration guide
/godmode:changelog --notes --release 2.0.0      # User-facing notes for v2.0.0
```
