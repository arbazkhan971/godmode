---
name: lint
description: |
  Linting and code standards skill. Activates when the user needs to set up, configure, or enforce code linting, formatting, and style standards. Covers ESLint, Prettier, Biome, Ruff, golangci-lint, and other language-specific tools. Includes custom rule creation, auto-fix strategies, pre-commit hook setup with Husky and lint-staged, and style guide enforcement. Every configuration choice is justified and every rule is explained. Triggers on: /godmode:lint, "linting", "code style", "prettier", "eslint", "formatter", "pre-commit hooks", "code standards", or when inconsistent formatting is detected.
---

# Lint — Linting & Code Standards

## When to Activate
- User invokes `/godmode:lint`
- User says "set up linting", "fix code style", "enforce standards"
- User asks about "ESLint", "Prettier", "Biome", "Ruff", "golangci-lint"
- User wants "pre-commit hooks", "auto-fix", "consistent formatting"
- Codebase has inconsistent formatting or style
- New project needs linting infrastructure from scratch
- Migrating between linting tools (e.g., ESLint + Prettier to Biome)

## Workflow

### Step 1: Assess Current State
Scan the project for existing linting and formatting configuration:

```bash
# Detect existing configurations
ls -la .eslintrc* .prettierrc* biome.json .editorconfig .stylelintrc* \
       .golangci.yml .golangci.yaml pyproject.toml setup.cfg .flake8 \
       .rubocop.yml .clang-format .clang-tidy 2>/dev/null

# Check for pre-commit hooks
```
```
LINT ASSESSMENT:
  Project: <name>
  Language(s): <detected>
| Linter | <current tool or NONE> |
|--|--|
| Formatter | <current tool or NONE> |
| Pre-commit hooks | <YES/NO> |
| Editor config | <YES/NO> |
| Current violations | <N errors, N warnings> |
| CI integration | <YES/NO> |
  Status: <CONFIGURED | PARTIAL | NONE>
```
### Step 2: Tool Selection
Choose the right linting and formatting stack:

```
TOOL SELECTION BY LANGUAGE:
| Language | Linter | Formatter | Type Checker |
|--|--|--|--|
| TypeScript | ESLint | Prettier | tsc |
| TypeScript | Biome (all-in-one) | Biome | tsc |
| JavaScript | ESLint | Prettier | — |
| Python | Ruff (all-in-one) | Ruff / Black | mypy / pyright |
| Go | golangci-lint | gofmt / goimports | go vet |
| Rust | clippy | rustfmt | rustc |
| Ruby | RuboCop | RuboCop | Sorbet |
| Java/Kotlin | checkstyle/ktlint | google-java-format | — |
| CSS/SCSS | Stylelint | Prettier | — |
  ...
```
### Step 3: Configuration

#### ESLint + Prettier (TypeScript/JavaScript)

```javascript
// eslint.config.js (flat config, ESLint 9+)
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import prettier from 'eslint-config-prettier';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
```
```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
```
```
// .prettierignore
dist/
build/
node_modules/
coverage/
*.min.js
pnpm-lock.yaml
package-lock.json
```
#### Biome (All-in-One Alternative)

```json
// biome.json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
```
#### golangci-lint (Go)

```yaml
# .golangci.yml
run:
  timeout: 5m
  go: "1.22"

linters:
```
### Step 4: Custom Rule Creation
Write project-specific lint rules:

#### ESLint Custom Rule
```javascript
// eslint-rules/no-direct-env-access.js
// Enforce using config module instead of process.env directly
module.exports = {
  meta: {
    type: 'problem',
    docs: {
```
AUTO-FIX STRATEGY:
  Level 1: Format on Save (editor integration)
  - Runs formatter (Prettier/Biome/gofmt) on every save
  - Zero developer effort, instant feedback
  Level 2: Lint Fix on Save (editor integration)
  - Auto-fixes safe lint rules on save
  - import ordering, unused imports, const/let, etc.
  Level 3: Pre-commit Auto-fix (git hook)
  - Catches anything missed by editor
  - Runs on staged files only (fast)
  Level 4: CI Enforcement (pipeline)
  - Final gate: fails PR if any violations remain
  - No auto-fix — enforcement only
```

#### Editor Integration (VS Code)
```jsonc
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[typescript]": {
# Fix all existing violations in one pass
# TypeScript/JavaScript
npx eslint . --fix
npx prettier --write "**/*.{ts,tsx,js,jsx,json,css,md}"
  ...
```

```
BATCH FIX REPORT:
  Before: <N> errors, <N> warnings
  Auto-fixed: <N> issues
  Remaining (manual): <N> issues
  Auto-fixed breakdown:
  Import ordering:     <N>
  Unused imports:      <N>
  Formatting:          <N>
  const/let upgrades:  <N>
  Trailing whitespace: <N>
  Manual review needed:
  <file>:<line> — <rule>: <description>
  ...
```

### Step 6: Pre-Commit Hooks Setup
Catch violations before they enter the repository:

#### Husky + lint-staged (JavaScript/TypeScript)
```bash
# Install
npm install -D husky lint-staged
npx husky init
```

```jsonc
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix --max-warnings=0",
      "prettier --write"
    ],
    "*.{js,jsx}": [
      "eslint --fix --max-warnings=0",
      "prettier --write"
    ],
    "*.{json,css,scss,md}": [
  ...
```

```bash
# .husky/pre-commit
npx lint-staged
```

#### pre-commit Framework (Python / Multi-language)
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
```

```bash
# Install pre-commit
pip install pre-commit
pre-commit install
pre-commit run --all-files  # Initial run on entire codebase
```

### Step 7: Style Guide Enforcement
Define and enforce team coding standards:

#### Style Guide Document
```
CODING STANDARDS:
| Area | Standard | Enforced |
|--|--|--|
| Indentation | 2 spaces (no tabs) | Prettier |
| Line length | 100 characters max | Prettier |
| Quotes | Single quotes (JS/TS) | Prettier |
| Semicolons | Always | Prettier |
| Trailing commas | All (functions included) | Prettier |
| Import order | builtin > external > internal | ESLint |
| Naming: variables | camelCase | ESLint |
| Naming: functions | camelCase | ESLint |
| Naming: classes | PascalCase | ESLint |
  ...
```

#### .editorconfig (Universal)
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[*.go]
indent_style = tab

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

### Step 8: Commit and Transition
1. Commit linter config: `"lint: <project> — configure <tool> with <N> rules"`
2. Commit formatter config: `"lint: <project> — configure <formatter>"`
3. Commit pre-commit hooks: `"lint: <project> — add pre-commit hooks (Husky + lint-staged)"`
4. Commit auto-fixes: `"lint: <project> — auto-fix <N> existing violations"`
5. Commit style guide: `"lint: <project> — enforce coding standards"`

## Key Behaviors

1. **Format on save, lint on commit, enforce in CI.** Three layers of defense. If any layer is missing, violations will accumulate.
2. **Auto-fix everything possible.** Developers should not spend time on formatting. Machines handle formatting; humans handle logic.
  ...
```
AUTO-DETECT:
1. Detect language(s):
   - package.json → JavaScript/TypeScript
   - pyproject.toml, setup.cfg → Python
   - go.mod → Go
   - Cargo.toml → Rust
   - Gemfile → Ruby
   - pom.xml, build.gradle → Java/Kotlin
2. Linter: .eslintrc*/eslint.config.*→ESLint, biome.json→Biome, pyproject.toml→Ruff, .golangci.yml→golangci-lint
3. Formatter: .prettierrc*→Prettier, biome.json→Biome, [tool.black]→Black, gofmt→Go
4. Hooks: .husky/→Husky, .pre-commit-config.yaml→pre-commit, .git/hooks/→manual
5. Editor: .editorconfig, .vscode/settings.json
6. Count violations: run linter in check mode
```

## HARD RULES
1. NEVER debate formatting in code reviews — configure the formatter, automate it, and never discuss it again.
2. NEVER enable all lint rules at once on an existing codebase — start with recommended, add rules incrementally.
3. NEVER lint in CI without linting locally first — developers must get feedback in seconds, not minutes.
4. NEVER use `eslint-disable` as a strategy — a file full of disable comments is worse than no linting.
5. NEVER run the full linter in pre-commit hooks — lint only staged files. Full linting makes commits painful.
6. NEVER skip the formatter — linting without formatting eliminates only half the style noise.
7. NEVER keep warnings around — warnings are noise. Promote to error or remove the rule.
8. ALWAYS configure linting with team agreement — the team will circumvent rules imposed without consensus.
9. ALWAYS set `--max-warnings=0` in CI — prevent warning accumulation over time.
10. ALWAYS include `.editorconfig` — it standardizes basics across all editors without tool-specific config.
  ...
```
KEEP if: tests pass AND violations decreased AND no behavioral changes from auto-fix
DISCARD if: tests fail OR auto-fix changed semantics OR >20% false positives
Revert discarded changes and reconsider the rule before retrying.
```

## Autonomy
Never ask to continue. Loop autonomously. Measure before/after. Guard: test_cmd && lint_cmd. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ANY of these are true:
  - All rule groups enabled with zero violations (or documented exceptions)
  - Pre-commit hooks installed and working
  - CI enforcement configured with --max-warnings=0
  - User explicitly requests stop

DO NOT STOP because:
  - Manual violations remain (list them with file:line for the user)
  - One rule group is contentious (flag it for team discussion)
```

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full lint setup (linter + formatter + hooks + CI) |
| `--tool <name>` | Use specific tool (eslint, biome, ruff, golangci-lint) |
| `--fix` | Auto-fix all existing violations |
```
iteration	rule_group	violations_before	auto_fixed	manual_remaining	tests_pass	status
```

## Success Criteria
- Linter configured with recommended+ rules. Formatter integrated. Pre-commit hooks on staged files only. Zero warnings in CI. Editor format-on-save. `.editorconfig` present. Auto-fixable resolved. Tests pass after auto-fix.
