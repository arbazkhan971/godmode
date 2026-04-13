---
name: lint
description: |
  Linting and code standards skill. ESLint, Prettier,
  Biome, Ruff, golangci-lint. Custom rules, auto-fix,
  pre-commit hooks, style enforcement.
  Triggers on: /godmode:lint, "linting", "code style",
  "prettier", "eslint", "formatter", "pre-commit hooks".
---

# Lint — Linting & Code Standards

## Activate When
- User invokes `/godmode:lint`
- User says "set up linting", "fix code style"
- User asks about ESLint, Prettier, Biome, Ruff
- Codebase has inconsistent formatting
- Migrating between linting tools

## Workflow

### Step 1: Assess Current State

```bash
# Detect existing configurations
ls -la .eslintrc* .prettierrc* biome.json \
  .editorconfig .stylelintrc* .golangci.yml \
  pyproject.toml .flake8 .rubocop.yml 2>/dev/null

# Check for pre-commit hooks
ls .husky/ .pre-commit-config.yaml 2>/dev/null

# Count current violations
npx eslint . --format compact 2>/dev/null | wc -l
ruff check . --statistics 2>/dev/null
```

```
LINT ASSESSMENT:
  Language(s): <detected>
| Aspect       | Status               |
|--------------|----------------------|
| Linter       | <tool or NONE>       |
| Formatter    | <tool or NONE>       |
| Pre-commit   | YES/NO               |
| Editor config| YES/NO               |
| Violations   | <N errors, N warns>  |
| CI enforce   | YES/NO               |

IF no linter: install recommended for language
IF no formatter: add Prettier/Biome/gofmt
IF no hooks: set up Husky + lint-staged
IF warnings > 0 in CI: set --max-warnings=0
```

### Step 2: Tool Selection

```
TOOL SELECTION:
| Language   | Linter        | Formatter     |
|------------|---------------|---------------|
| TypeScript | ESLint/Biome  | Prettier/Biome|
| Python     | Ruff          | Ruff/Black    |
| Go         | golangci-lint | gofmt         |
| Rust       | clippy        | rustfmt       |
| Ruby       | RuboCop       | RuboCop       |
| CSS/SCSS   | Stylelint     | Prettier      |

IF project has ESLint+Prettier: consider Biome
IF Python with flake8+black: migrate to Ruff
```

### Step 3: Configuration
ESLint 9+ flat config with typescript-eslint, prettier.
Biome: single biome.json for lint+format+imports.
Ruff: pyproject.toml `[tool.ruff]` section.
Go: `.golangci.yml` with 5m timeout.

### Step 4: Auto-Fix Strategy

```
AUTO-FIX LAYERS:
  Level 1: Format on Save (editor, zero effort)
  Level 2: Lint Fix on Save (safe rules only)
  Level 3: Pre-commit (staged files, catches misses)
  Level 4: CI Enforcement (final gate, no auto-fix)

THRESHOLDS:
  Batch fix target: resolve 100% of auto-fixable
  Manual remaining: list with file:line for user
  IF auto-fix changes semantics: DISCARD fix
  IF false positive rate > 20%: disable rule
```

```bash
# Batch fix all existing violations
npx eslint . --fix
npx prettier --write "**/*.{ts,tsx,js,json,css,md}"
ruff check . --fix && ruff format .
```

### Step 5: Pre-Commit Hooks

```bash
# JavaScript/TypeScript: Husky + lint-staged
npm install -D husky lint-staged
npx husky init
echo "npx lint-staged" > .husky/pre-commit

# Python: pre-commit framework
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

```
LINT-STAGED CONFIG:
  *.{ts,tsx}: eslint --fix --max-warnings=0, prettier
  *.{json,css,md}: prettier --write
  *.py: ruff check --fix, ruff format

RULES:
  Lint only staged files (fast commits)
  Full lint runs in CI only
  IF commit takes > 10s: check scope
```

### Step 6: Style Guide & .editorconfig

```
CODING STANDARDS:
| Area         | Standard         | Tool     |
|--------------|------------------|----------|
| Indentation  | 2 spaces (no tab)| Prettier |
| Line length  | 100 chars max    | Prettier |
| Quotes       | Single (JS/TS)   | Prettier |
| Semicolons   | Always           | Prettier |
| Trailing comma| All             | Prettier |
| Import order | builtin>ext>int  | ESLint   |
```

### Step 7: Commit
1. Config: `"lint: configure <tool> with <N> rules"`
2. Hooks: `"lint: add pre-commit hooks"`
3. Fixes: `"lint: auto-fix <N> violations"`

## Key Behaviors
Never ask to continue. Loop autonomously until done.

1. **Format on save, lint on commit, enforce in CI.**
2. **Auto-fix everything possible.** Humans handle logic.
3. **Zero warnings in CI.** `--max-warnings=0`.
4. **Team agreement on rules.** Imposed rules get bypassed.

## HARD RULES
1. Never debate formatting in code reviews — automate it.
2. Never enable all rules at once on existing codebase.
3. Never lint in CI without linting locally first.
4. Never use `eslint-disable` as a strategy.
5. Never run full linter in pre-commit — staged files only.
6. Never skip the formatter alongside the linter.
7. Never keep warnings — promote to error or remove rule.
8. Always set `--max-warnings=0` in CI.
9. Always include `.editorconfig`.
10. Always configure with team agreement.

## Auto-Detection
```
1. Language: package.json, pyproject.toml, go.mod
2. Linter: .eslintrc*, biome.json, [tool.ruff]
3. Formatter: .prettierrc*, biome.json, [tool.black]
4. Hooks: .husky/, .pre-commit-config.yaml
5. Editor: .editorconfig, .vscode/settings.json
6. Violations: run linter in check mode
```

## Output Format
Print: `Lint: {tool} configured, {N} rules.
  Violations: {before} -> {after}. Hooks: {status}.
  Verdict: {verdict}.`

## TSV Logging
```
iteration	rule_group	violations_before	auto_fixed	manual_remaining	tests_pass	status
```

## Keep/Discard Discipline
```
KEEP if: tests pass AND violations decreased
  AND no behavioral changes from auto-fix
DISCARD if: tests fail OR auto-fix changed semantics
  OR > 20% false positives
```

## Stop Conditions
```
STOP when ANY of:
  - All rule groups enabled with zero violations
  - Pre-commit hooks installed and working
  - CI enforcement with --max-warnings=0
  - User requests stop
```

<!-- tier-3 -->

## Error Recovery
- Rule conflicts: check eslint-config-prettier compat.
- Auto-fix breaks tests: revert, narrow fix scope.
- Hook too slow: lint only staged files, not full repo.
- False positives: disable rule, document reason.

