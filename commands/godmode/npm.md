# /godmode:npm

Package management skill for JavaScript/TypeScript projects. Covers npm, yarn, pnpm, and bun comparison and selection, lock file management, workspace/monorepo configuration, package publishing, security auditing (npm audit), and version resolution strategies.

## Usage

```
/godmode:npm                              # Full package management assessment
/godmode:npm --audit                      # Run security audit with remediation
/godmode:npm --outdated                   # Check for outdated dependencies
/godmode:npm --dedupe                     # Find and resolve duplicate packages
/godmode:npm --workspace                  # Configure monorepo workspaces
/godmode:npm --publish                    # Prepare and publish a package
/godmode:npm --migrate <to>               # Migrate package manager (npm/pnpm/yarn/bun)
/godmode:npm --compare                    # Compare package managers for this project
/godmode:npm --cleanup                    # Remove unused dependencies
/godmode:npm --lockfix                    # Regenerate corrupted lock file
/godmode:npm --overrides                  # Manage version overrides/resolutions
/godmode:npm --ci                         # CI-friendly output (exit code 1 on issues)
```

## What It Does

1. Assesses project's dependency landscape (package manager, deps, vulnerabilities)
2. Recommends the best package manager for the project context
3. Manages lock files correctly (commit, freeze in CI, resolve conflicts)
4. Configures workspaces and monorepo structure (pnpm, Turborepo, Nx)
5. Prepares packages for publishing (exports, types, versioning, dry-run)
6. Runs security audits with actionable remediation steps
7. Resolves version conflicts, peer dependency issues, and duplicates
8. Produces a package management report with health metrics

## Output
- Package manager configuration
- Workspace/monorepo setup (if applicable)
- Security audit report with fixes
- Dependency health report
- Commit: `"deps: <add|update|remove> <package> — <reason>"`

## Next Step
After package management: `/godmode:build` to start coding, or `/godmode:secure` for a full security audit.

## Examples

```
/godmode:npm                              # Full dependency assessment
/godmode:npm --audit                      # Fix 3 critical vulnerabilities
/godmode:npm --workspace                  # Set up pnpm monorepo with Turborepo
/godmode:npm --migrate pnpm              # Migrate from npm to pnpm
/godmode:npm --publish                    # Prepare and publish @myorg/utils
```
