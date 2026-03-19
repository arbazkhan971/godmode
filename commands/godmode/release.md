# /godmode:release

Release management. Handles semantic versioning, release notes generation, changelog automation, release branching and tagging, hotfix workflows, and release train scheduling.

## Usage

```
/godmode:release                       # Full release assessment and execution
/godmode:release --setup               # Set up automated release pipeline
/godmode:release --bump major          # Force major version bump
/godmode:release --bump minor          # Force minor version bump
/godmode:release --bump patch          # Force patch version bump
/godmode:release --pre-release alpha   # Create alpha pre-release
/godmode:release --pre-release rc      # Create release candidate
/godmode:release --hotfix              # Hotfix workflow for production emergency
/godmode:release --notes               # Generate release notes only
/godmode:release --changelog           # Update changelog only
/godmode:release --dry-run             # Show what the release would do without executing
/godmode:release --schedule            # Set up release train schedule
/godmode:release --status              # Show release status and next scheduled release
/godmode:release --history             # Show release history and metrics
```

## What It Does

1. **Assess** — Analyze commits since last release, determine version bump
2. **Version** — Apply semantic versioning based on Conventional Commits
3. **Changelog** — Generate or update CHANGELOG.md with grouped entries
4. **Notes** — Create audience-appropriate release notes
5. **Tag** — Create annotated git tag with release metadata
6. **Publish** — Create GitHub Release, publish to registry, upload artifacts
7. **Automate** — Set up release-please, semantic-release, or changesets

## Output
- Version bump (semver-compliant)
- Updated CHANGELOG.md
- Release notes (user-facing and developer-facing)
- Git tag and GitHub Release
- Published package (if applicable)
- Release automation configuration (if --setup)

## Next Step
After release: `/godmode:deploy` to ship to production or `/godmode:ship` for distribution.

## Examples

```
/godmode:release                       # Create a new release
/godmode:release --setup               # Set up automated releases with release-please
/godmode:release --hotfix              # Emergency production fix workflow
/godmode:release --dry-run             # Preview the release without executing
/godmode:release --schedule            # Configure bi-weekly release train
```
