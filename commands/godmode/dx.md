# /godmode:dx

Developer experience optimization covering dev environment setup automation, hot reload and fast feedback loops, error message improvement, CLI tool design, and developer portal and internal tooling. Every recommendation is measurable with before/after DX scores.

## Usage

```
/godmode:dx                              # Full DX audit across all dimensions
/godmode:dx --setup                      # Focus on environment setup automation
/godmode:dx --feedback                   # Focus on feedback loop optimization
/godmode:dx --errors                     # Focus on error message improvement
/godmode:dx --cli                        # Focus on CLI tool design
/godmode:dx --portal                     # Focus on developer portal setup
/godmode:dx --audit-only                 # Run audit without making changes
/godmode:dx --quick-wins                 # Show only improvements under 1 hour
/godmode:dx --before-after               # Compare DX scores before and after
```

## What It Does

1. Audits developer experience across 5 dimensions (setup, feedback, errors, CLI, docs)
2. Measures time-to-first-build, save-to-result latency, and error actionability
3. Creates one-command setup scripts and devcontainer configurations
4. Configures hot reload, watch modes, and fast test runners
5. Transforms cryptic error messages into actionable diagnostics with context
6. Designs CLI tools with help text, autocomplete, progress indicators, and JSON output
7. Sets up developer portals with API catalogs, service dashboards, and runbook libraries
8. Produces prioritized improvement plan with quick wins and strategic investments

## Output
- DX audit report with scores per dimension
- Setup script at `scripts/setup.sh`
- Devcontainer at `.devcontainer/devcontainer.json`
- Error class hierarchy at `src/errors/`
- DX improvement plan with before/after comparison
- Commit: `"dx: <project> — DX score <before> -> <after> (<N> improvements)"`

## Next Step
After DX improvements: `/godmode:lint` to enforce code standards, `/godmode:onboard` to update onboarding, or `/godmode:ship` to deploy.

## Examples

```
/godmode:dx                              # Full DX audit and improvements
/godmode:dx --setup                      # Fix slow environment setup
/godmode:dx --errors                     # Make error messages actionable
/godmode:dx --cli                        # Design a CLI tool
/godmode:dx --quick-wins                 # Low-effort, high-impact fixes
```
