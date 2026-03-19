# /godmode:monorepo

Monorepo architecture and management covering tool selection (Turborepo, Nx, Lerna, Bazel, Rush), package boundary enforcement, selective builds and testing, dependency graph management, shared configuration patterns, and CI optimization with remote caching.

## Usage

```
/godmode:monorepo                        # Full monorepo assessment and optimization
/godmode:monorepo --init turborepo       # Initialize new Turborepo monorepo
/godmode:monorepo --init nx              # Initialize new Nx monorepo
/godmode:monorepo --audit                # Audit existing monorepo health
/godmode:monorepo --boundaries           # Check and enforce package boundaries
/godmode:monorepo --graph                # Generate dependency graph visualization
/godmode:monorepo --selective            # Configure selective builds and testing
/godmode:monorepo --cache                # Set up remote caching
/godmode:monorepo --shared-config        # Create shared configuration packages
/godmode:monorepo --migrate              # Migrate from multi-repo to monorepo
/godmode:monorepo --ci                   # Generate CI configuration for monorepo
```

## What It Does

1. Assesses current monorepo or multi-repo structure
2. Selects the right monorepo tool based on project size, language, and team needs
3. Defines package structure with apps/, packages/, and tools/ layout
4. Enforces package boundaries to prevent unauthorized cross-package imports
5. Configures selective builds that only build and test changed packages
6. Sets up remote caching for CI and local development
7. Manages dependency graph with circular dependency detection
8. Creates shared configuration packages (tsconfig, eslint, prettier)
9. Generates CI pipelines with path filtering and parallel jobs

## Output
- Monorepo configuration files (turbo.json, nx.json, pnpm-workspace.yaml)
- Package boundary enforcement rules
- Shared config packages at `packages/config/`
- CI pipeline at `.github/workflows/ci.yml`
- Dependency graph visualization
- Commit: `"monorepo: <project> — <tool> with <N> packages, selective builds, remote caching"`

## Next Step
After monorepo setup: `/godmode:lint` to configure shared linting, `/godmode:dx` to optimize dev experience, or `/godmode:build` to start building packages.

## Examples

```
/godmode:monorepo                        # Full assessment and optimization
/godmode:monorepo --init turborepo       # New monorepo with Turborepo
/godmode:monorepo --audit                # Health check existing monorepo
/godmode:monorepo --boundaries           # Find and fix boundary violations
/godmode:monorepo --graph                # Visualize dependency graph
```
