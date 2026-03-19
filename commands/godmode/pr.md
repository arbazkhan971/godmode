# /godmode:pr

Pull request excellence. Optimizes PR size, generates description templates, manages stacked PRs for large features, configures auto-labeling and auto-assignment, and tracks PR cycle time metrics.

## Usage

```
/godmode:pr                            # Full PR assessment, sizing, and creation
/godmode:pr --template                 # Generate PR description template only
/godmode:pr --split                    # Analyze and recommend PR splitting strategy
/godmode:pr --stack                    # Create stacked PRs for current feature
/godmode:pr --metrics                  # Show PR cycle time metrics for the team
/godmode:pr --labels                   # Set up auto-labeling configuration
/godmode:pr --codeowners               # Generate CODEOWNERS file from git history
/godmode:pr --size-check               # Check if current diff is too large
/godmode:pr --self-review              # Run self-review checklist before requesting
/godmode:pr --retarget                 # Retarget stacked PRs after a merge
```

## What It Does

1. **Assess** — Analyze change size, categorize, determine risk level
2. **Optimize** — Split large PRs into small, focused, reviewable units
3. **Template** — Generate comprehensive PR description with context
4. **Stack** — Create dependent, sequential PRs for large features
5. **Automate** — Configure auto-labeling, auto-assignment, CODEOWNERS
6. **Measure** — Track cycle time, review rounds, size distribution

## Output
- Optimally-sized PR(s) with complete descriptions
- Stacked PR plan with merge order and base branches
- Auto-labeling and assignment configuration
- PR metrics dashboard with improvement recommendations

## Next Step
After PR creation: `/godmode:review` for pre-merge review or `/godmode:ship` to finalize.

## Examples

```
/godmode:pr                            # Create a well-structured PR
/godmode:pr --stack                    # Break feature into stacked PRs
/godmode:pr --metrics                  # See team PR cycle time stats
/godmode:pr --split                    # Get advice on splitting a large diff
/godmode:pr --codeowners               # Generate CODEOWNERS from git history
```
