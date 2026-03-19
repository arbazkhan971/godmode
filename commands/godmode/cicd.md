# /godmode:cicd

Design, create, and optimize CI/CD pipelines. Supports GitHub Actions, GitLab CI, CircleCI, and Jenkins with caching, sharding, matrix builds, and deployment gates.

## Usage

```
/godmode:cicd                           # Analyze existing pipeline, suggest improvements
/godmode:cicd --create                  # Generate new pipeline from scratch
/godmode:cicd --optimize                # Focus on performance optimization
/godmode:cicd --platform github         # Target platform (github, gitlab, circleci, jenkins)
/godmode:cicd --add-stage security      # Add a specific stage
/godmode:cicd --matrix                  # Set up multi-version matrix builds
/godmode:cicd --template                # Create reusable pipeline components
/godmode:cicd --fix                     # Diagnose and fix failing pipeline
/godmode:cicd --dry-run                 # Show changes without writing files
```

## What It Does

1. Discovers project CI/CD requirements (language, tests, deploy targets)
2. Designs pipeline architecture (lint, test, build, security, deploy)
3. Generates platform-specific pipeline configuration
4. Configures caching (dependencies, Docker layers, build artifacts)
5. Sets up test sharding for parallel execution
6. Creates matrix builds for multi-version testing
7. Builds reusable pipeline templates and composite actions
8. Optimizes existing pipelines with performance analysis

## Output
- Pipeline configuration in `.github/workflows/`, `.gitlab-ci.yml`, etc.
- Reusable components in `.github/actions/` or equivalent
- Performance analysis with before/after timing comparison
- Commit: `"cicd: <description> — <platform> pipeline (<N> stages, <estimated time>)"`

## Next Step
After pipeline is set up: `/godmode:build` to execute, or `/godmode:ship` to deploy.

## Examples

```
/godmode:cicd --create --platform github    # New GitHub Actions pipeline
/godmode:cicd --optimize                    # Speed up slow pipeline
/godmode:cicd --add-stage security          # Add security scanning stage
/godmode:cicd --fix                         # Debug failing CI
```
