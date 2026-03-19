# /godmode:opensource

Open source project management — repository scaffolding, community health files, issue/PR templates, GitHub Actions automation, maintainer workflows, and governance models. Everything needed to run a healthy open source project.

## Usage

```
/godmode:opensource                              # Full health audit and scaffolding
/godmode:opensource --audit                      # Audit only, do not create files
/godmode:opensource --governance bdfl             # Set BDFL governance model
/godmode:opensource --governance consensus        # Set consensus governance model
/godmode:opensource --governance committee        # Set steering committee governance
/godmode:opensource --templates                   # Create issue and PR templates only
/godmode:opensource --automation                  # Set up GitHub Actions workflows only
/godmode:opensource --community                   # Configure community channels only
/godmode:opensource --security                    # Create SECURITY.md and workflows only
/godmode:opensource --minimal                     # LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT only
/godmode:opensource --no-automation               # Skip GitHub Actions workflow creation
```

## What It Does

1. Audits repository health (LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, templates)
2. Scaffolds missing community health files with best-practice content
3. Creates structured issue templates (bug report, feature request) and PR template
4. Sets up GitHub Actions for auto-labeling, stale issue management, welcome messages, and release drafting
5. Configures CODEOWNERS for automatic reviewer assignment
6. Designs maintainer workflows: triage, review, and release processes
7. Generates governance model (BDFL, consensus, or steering committee)
8. Sets up community channels (Discussions, Discord/Slack structure, funding)

## Output
- Community health files: LICENSE, CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md, GOVERNANCE.md
- Templates: .github/ISSUE_TEMPLATE/*.yml, .github/PULL_REQUEST_TEMPLATE.md
- Automation: .github/workflows/labeler.yml, stale.yml, welcome.yml, release-drafter.yml
- Config: .github/CODEOWNERS, .github/FUNDING.yml, .github/labeler.yml
- Commit: `"opensource: <project> — scaffold community health files (<N> files)"`

## Next Step
After scaffolding: `/godmode:license` for detailed license management, `/godmode:changelog` for changelog setup, or `/godmode:cicd` for CI/CD pipeline.

## Examples

```
/godmode:opensource                              # Full setup for new open source project
/godmode:opensource --audit                      # Check health without changing anything
/godmode:opensource --governance committee        # Add steering committee governance
/godmode:opensource --templates --automation      # Just templates and workflows
```
