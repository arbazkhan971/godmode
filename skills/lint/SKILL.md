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
# ... (condensed)
```

```
LINT ASSESSMENT:
  Project: <name>
  Language(s): <detected>
| Linter | <current tool or NONE> |
|---|---|
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
|---|---|---|---|
| TypeScript | ESLint | Prettier | tsc |
| TypeScript | Biome (all-in-one) | Biome | tsc |
| JavaScript | ESLint | Prettier | — |
| Python | Ruff (all-in-one) | Ruff / Black | mypy / pyright |
| Go | golangci-lint | gofmt / goimports | go vet |
| Rust | clippy | rustfmt | rustc |
| Ruby | RuboCop | RuboCop | Sorbet |
| Java/Kotlin | checkstyle/ktlint | google-java-format | — |
| CSS/SCSS | Stylelint | Prettier | — |
| HTML | HTMLHint | Prettier | — |
| Markdown | markdownlint | Prettier | — |
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
# ... (condensed)
```

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
# ... (condensed)
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
# ... (condensed)
```

#### golangci-lint (Go)

```yaml
# .golangci.yml
run:
  timeout: 5m
  go: "1.22"

linters:
# ... (condensed)
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
# ... (condensed)
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
  - No auto-fix — just enforcement
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

# Python
ruff check --fix .
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
  <file>:<line> — <rule>: <description>
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
      "prettier --write"
    ],
    "*.py": [
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
# ... (condensed)
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
|---|---|---|
| Indentation | 2 spaces (no tabs) | Prettier |
| Line length | 100 characters max | Prettier |
| Quotes | Single quotes (JS/TS) | Prettier |
| Semicolons | Always | Prettier |
| Trailing commas | All (functions included) | Prettier |
| Import order | builtin > external > internal | ESLint |
| Naming: variables | camelCase | ESLint |
| Naming: functions | camelCase | ESLint |
| Naming: classes | PascalCase | ESLint |
| Naming: constants | UPPER_SNAKE_CASE | ESLint |
| Naming: files | kebab-case.ts | ESLint |
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
3. **Zero warnings in CI.** Warnings are future errors. Set `--max-warnings=0` in CI to prevent warning accumulation.
4. **Lint only staged files in pre-commit.** Running the linter on the entire codebase in a pre-commit hook makes commits painful. Use lint-staged.
5. **Agree on rules as a team, then automate enforcement.** Style debates happen once during configuration. After that, the tools enforce the decision.
```
AUTO-DETECT:
1. Detect language(s):
   - package.json → JavaScript/TypeScript
   - pyproject.toml, setup.cfg → Python
   - go.mod → Go
   - Cargo.toml → Rust
   - Gemfile → Ruby
   - pom.xml, build.gradle → Java/Kotlin
2. Detect existing linter config:
   - .eslintrc*, eslint.config.* → ESLint
   - biome.json → Biome
   - .prettierrc* → Prettier
   - pyproject.toml [tool.ruff] → Ruff
   - .flake8, setup.cfg [flake8] → Flake8
   - .golangci.yml → golangci-lint
   - .rubocop.yml → RuboCop
3. Detect formatter:
   - .prettierrc* → Prettier
   - biome.json → Biome formatter
   - pyproject.toml [tool.ruff.format] or [tool.black] → Ruff/Black
   - gofmt / goimports → Go fmt
4. Detect pre-commit hooks:
   - .husky/ → Husky
   - .pre-commit-config.yaml → pre-commit framework
   - .git/hooks/pre-commit → manual hook
5. Detect editor config:
   - .editorconfig → EditorConfig
   - .vscode/settings.json → VS Code settings
6. Count current violations:
   - Run linter in check mode, count errors + warnings
```

## Iterative Lint Fix Protocol
Lint adoption on existing codebases is iterative — enable, fix, commit, repeat:
```
current_rule_group = 0
rule_groups = [sorted by auto-fix ratio: highest first]

WHILE current_rule_group < len(rule_groups):
  group = rule_groups[current_rule_group]
  1. ENABLE rule group: {group} (e.g., "import ordering", "unused variables")
  2. RUN linter in check mode — count violations
  3. RUN auto-fix: eslint --fix / ruff check --fix / biome check --write
  4. COUNT remaining (manual) violations
  5. IF manual violations > 0:
     - REPORT: "{N} violations require manual review"
     - LIST each with file:line and suggested fix
     - FIX manually or flag for user
  6. RUN full test suite — verify no regressions from auto-fix
  7. IF tests fail → revert auto-fix, investigate
  8. COMMIT: "lint: enable {group} — auto-fixed {N}, manual {M}"
  9. current_rule_group += 1

EXIT when all rule groups enabled and violations resolved
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

## Keep/Discard Discipline
```
After EACH rule group is enabled and auto-fixed:
  1. MEASURE: Run the full test suite — do all tests pass?
  2. COMPARE: Are violations reduced? Did auto-fix introduce regressions?
  3. DECIDE:
     - KEEP if: tests pass AND violation count decreased AND no behavioral changes from auto-fix
     - DISCARD if: tests fail OR auto-fix changed code semantics OR rule produces excessive false positives
  4. COMMIT kept changes. Revert discarded changes and reconsider the rule before retrying.

Never keep a rule that produces >20% false positives — developers circumvent it with disable comments.
```

## Stuck Recovery
```
IF >3 consecutive rule groups cause test failures after auto-fix:
  1. Stop auto-fixing. Run the linter in check-only mode to understand violations before fixing.
  2. Apply fixes manually for the first 5 violations to verify the fix pattern is safe.
  3. Check for ESLint/Prettier conflicts: run `npx eslint-config-prettier path/to/file.ts`.
  4. If still stuck → enable the rule as warning (not error), log stop_reason=needs_manual_review.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All rule groups enabled with zero violations (or documented exceptions)
  - Pre-commit hooks installed and working
  - CI enforcement configured with --max-warnings=0
  - User explicitly requests stop

DO NOT STOP just because:
  - Manual violations remain (list them with file:line for the user)
  - One rule group is contentious (flag it for team discussion)
```

## Simplicity Criterion
```
PREFER the simpler linting approach:
  - Biome (single tool) over ESLint + Prettier (two tools) for new projects without heavy plugin needs
  - Recommended preset over custom rule set (customize only when the team has a specific need)
  - Auto-fix for formatting rules over manual enforcement
  - Single .editorconfig over per-editor settings for cross-editor basics
  - lint-staged (staged files only) over full-codebase linting in pre-commit
  - Fewer strict rules correctly enforced over many loose rules that produce warnings
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full lint setup (linter + formatter + hooks + CI) |
| `--tool <name>` | Use specific tool (eslint, biome, ruff, golangci-lint) |
| `--fix` | Auto-fix all existing violations |
```
iteration	rule_group	violations_before	auto_fixed	manual_remaining	tests_pass	status
1	import-ordering	89	89	0	yes	clean
2	unused-variables	45	38	7	yes	partial
3	no-explicit-any	34	0	34	yes	manual
```
Columns: iteration, rule_group, violations_before, auto_fixed, manual_remaining, tests_pass, status(clean/partial/manual).

## Success Criteria
- Linter configured with recommended+ rule set for the detected language.
- Formatter configured and integrated with linter (no conflicts).
- Pre-commit hooks installed and running on staged files only.
- Zero warnings in CI (`--max-warnings=0`).
- Editor integration configured (format-on-save, lint-on-save).
- `.editorconfig` present for cross-editor consistency.
- All auto-fixable violations resolved. Manual violations listed with file:line.
- Full test suite passes after auto-fix (no regressions).

## Error Recovery
- **ESLint and Prettier conflict**: Install `eslint-config-prettier` to disable conflicting ESLint rules. Run Prettier last in lint-staged. Verify with `npx eslint-config-prettier path/to/file.ts`.
- **Auto-fix introduces bugs**: Run the full test suite after auto-fix. If tests fail, revert the auto-fix (`git checkout .`), identify the breaking rule, and exclude it from auto-fix. Fix those violations manually.
- **Pre-commit hook too slow**: Ensure lint-staged is configured to lint only staged files, not the entire codebase. Check that the linter is not type-checking during pre-commit (remove `--project` flag from eslint in hooks).
- **Rule produces false positives**: Add a targeted `eslint-disable-next-line` with a comment explaining why. If the rule generates many false positives, reconsider whether it is appropriate for the project.
- **Migration breaks existing CI**: Run the linter in warning mode first (`--max-warnings=999`), fix violations incrementally, then tighten to `--max-warnings=0`.
- **Team disagrees on rules**: Use the recommended preset as the baseline. Only discuss additions or overrides. Document the decision in a team ADR. Automate enforcement so the debate only happens once.


## Output Format
Print: `Lint: {violations_before} -> {violations_after} violations. Auto-fixed: {N}. Rules: {total}. Status: {DONE|PARTIAL}.`

## TSV Logging
Append to `.godmode/lint-results.tsv`:
```
timestamp	tool	violations_before	violations_after	auto_fixed	rules_added	status
```
One row per lint pass. Never overwrite previous rows.
