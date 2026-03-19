# /godmode:lint

Linting and code standards setup covering ESLint, Prettier, Biome, Ruff, golangci-lint configuration, custom rule creation, auto-fix strategies, pre-commit hooks with Husky and lint-staged, and style guide enforcement. Every rule is justified and every configuration choice is explained.

## Usage

```
/godmode:lint                            # Full lint setup (linter + formatter + hooks + CI)
/godmode:lint --tool eslint              # Use ESLint specifically
/godmode:lint --tool biome               # Use Biome (all-in-one)
/godmode:lint --tool ruff                # Use Ruff for Python
/godmode:lint --fix                      # Auto-fix all existing violations
/godmode:lint --hooks                    # Set up pre-commit hooks only
/godmode:lint --ci                       # Generate CI lint configuration only
/godmode:lint --custom-rule <name>       # Create a custom lint rule
/godmode:lint --migrate eslint biome     # Migrate from ESLint to Biome
/godmode:lint --audit                    # Count violations without fixing
/godmode:lint --strict                   # Enable strictest rule set
/godmode:lint --style-guide              # Generate style guide document
```

## What It Does

1. Assesses current linting and formatting state
2. Selects appropriate tools based on language and project needs
3. Configures linter with justified rule selections
4. Configures formatter with team-agreed style settings
5. Creates custom rules for project-specific conventions
6. Sets up auto-fix at three levels: editor, pre-commit, and CI
7. Installs pre-commit hooks (Husky + lint-staged or pre-commit framework)
8. Runs batch auto-fix on existing violations
9. Generates a coding standards document
10. Adds CI enforcement as a final gate

## Output
- Linter config (eslint.config.js, biome.json, pyproject.toml, .golangci.yml)
- Formatter config (.prettierrc or integrated)
- Pre-commit hooks (.husky/ or .pre-commit-config.yaml)
- Editor settings (.vscode/settings.json, .editorconfig)
- Style guide document
- Batch fix commit: `"lint: <project> — auto-fix <N> existing violations"`
- Config commit: `"lint: <project> — configure <tool> with <N> rules"`

## Next Step
After linting setup: `/godmode:type` to strengthen type safety, `/godmode:dx` to improve developer experience, or `/godmode:review` for code review.

## Examples

```
/godmode:lint                            # Full lint setup
/godmode:lint --tool biome               # Fast all-in-one setup
/godmode:lint --fix                      # Fix existing violations
/godmode:lint --hooks                    # Add pre-commit hooks
/godmode:lint --migrate eslint biome     # Migrate to Biome
```
