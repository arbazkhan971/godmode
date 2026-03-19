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
ls -la .husky/ .pre-commit-config.yaml .git/hooks/pre-commit 2>/dev/null

# Check package.json for lint scripts
grep -A5 '"lint"' package.json 2>/dev/null

# Count current violations
npx eslint . --format compact 2>/dev/null | wc -l
```

```
LINT ASSESSMENT:
┌──────────────────────────────────────────────────────────────┐
│  Project: <name>                                              │
│  Language(s): <detected>                                      │
├──────────────────┬───────────────────────────────────────────┤
│  Linter           │ <current tool or NONE>                    │
│  Formatter        │ <current tool or NONE>                    │
│  Pre-commit hooks │ <YES/NO>                                  │
│  Editor config    │ <YES/NO>                                  │
│  Current violations│ <N errors, N warnings>                   │
│  CI integration   │ <YES/NO>                                  │
├──────────────────┴───────────────────────────────────────────┤
│  Status: <CONFIGURED | PARTIAL | NONE>                        │
└──────────────────────────────────────────────────────────────┘
```

### Step 2: Tool Selection
Choose the right linting and formatting stack:

```
TOOL SELECTION BY LANGUAGE:
┌──────────────┬──────────────────┬──────────────────┬─────────────────┐
│  Language     │ Linter            │ Formatter         │ Type Checker     │
├──────────────┼──────────────────┼──────────────────┼─────────────────┤
│  TypeScript   │ ESLint            │ Prettier          │ tsc              │
│  TypeScript   │ Biome (all-in-one)│ Biome             │ tsc              │
│  JavaScript   │ ESLint            │ Prettier          │ —                │
│  Python       │ Ruff (all-in-one) │ Ruff / Black      │ mypy / pyright   │
│  Go           │ golangci-lint     │ gofmt / goimports │ go vet           │
│  Rust         │ clippy            │ rustfmt           │ rustc            │
│  Ruby         │ RuboCop           │ RuboCop           │ Sorbet           │
│  Java/Kotlin  │ checkstyle/ktlint │ google-java-format│ —                │
│  CSS/SCSS     │ Stylelint         │ Prettier          │ —                │
│  HTML         │ HTMLHint          │ Prettier          │ —                │
│  Markdown     │ markdownlint      │ Prettier          │ —                │
│  SQL          │ sqlfluff          │ sqlfluff          │ —                │
│  Shell        │ shellcheck        │ shfmt             │ —                │
└──────────────┴──────────────────┴──────────────────┴─────────────────┘

DECISION: ESLint + Prettier vs Biome
┌──────────────────┬────────────────────────────┬─────────────────────────┐
│  Criterion        │ ESLint + Prettier           │ Biome                    │
├──────────────────┼────────────────────────────┼─────────────────────────┤
│  Performance      │ Moderate (JS-based)         │ Fast (Rust-based, 100x)  │
│  Plugin ecosystem │ Massive (1000+ plugins)     │ Growing, limited          │
│  Custom rules     │ Full AST-based rule API     │ Not yet supported         │
│  Framework support│ React, Vue, Svelte, etc.    │ React, Vue (expanding)   │
│  Configuration    │ Complex (2 tools, conflicts)│ Single config file        │
│  Adoption         │ Industry standard           │ Growing rapidly           │
├──────────────────┼────────────────────────────┼─────────────────────────┤
│  Choose if...     │ Need plugins, custom rules  │ Want speed, simplicity   │
└──────────────────┴────────────────────────────┴─────────────────────────┘
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
import importPlugin from 'eslint-plugin-import';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  prettier,
  {
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    plugins: {
      react,
      'react-hooks': reactHooks,
      import: importPlugin,
    },
    rules: {
      // TypeScript-specific
      '@typescript-eslint/no-unused-vars': ['error', {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
      }],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-function-return-type': ['warn', {
        allowExpressions: true,
        allowTypedFunctionExpressions: true,
      }],
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',

      // Import ordering
      'import/order': ['error', {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'always',
        alphabetize: { order: 'asc' },
      }],
      'import/no-duplicates': 'error',

      // React
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',

      // General
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'prefer-const': 'error',
      'no-var': 'error',
      eqeqeq: ['error', 'always'],
    },
  },
  {
    ignores: ['dist/', 'build/', 'node_modules/', '*.config.js'],
  },
);
```

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "always",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "jsxSingleQuote": false
}
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
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExcessiveCognitiveComplexity": { "level": "error", "options": { "maxAllowedComplexity": 15 } }
      },
      "correctness": {
        "noUnusedVariables": "error",
        "noUnusedImports": "error",
        "useExhaustiveDependencies": "warn"
      },
      "suspicious": {
        "noExplicitAny": "error",
        "noConsoleLog": "warn"
      },
      "style": {
        "useConst": "error",
        "noVar": "error"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100,
    "lineEnding": "lf"
  },
  "javascript": {
    "formatter": {
      "semicolons": "always",
      "quoteStyle": "single",
      "trailingCommas": "all",
      "arrowParentheses": "always"
    }
  },
  "files": {
    "ignore": ["dist/", "build/", "node_modules/", "coverage/"]
  }
}
```

#### Ruff (Python)

```toml
# pyproject.toml
[tool.ruff]
target-version = "py312"
line-length = 100

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "UP",   # pyupgrade
    "ARG",  # flake8-unused-arguments
    "SIM",  # flake8-simplify
    "TCH",  # flake8-type-checking
    "PTH",  # flake8-use-pathlib
    "RUF",  # Ruff-specific rules
]
ignore = [
    "E501",  # line too long (handled by formatter)
]

[tool.ruff.lint.isort]
known-first-party = ["myproject"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
docstring-code-format = true
```

#### golangci-lint (Go)

```yaml
# .golangci.yml
run:
  timeout: 5m
  go: "1.22"

linters:
  enable:
    - errcheck        # unchecked errors
    - govet           # suspicious constructs
    - staticcheck     # advanced static analysis
    - unused          # unused code
    - gosimple        # simplification suggestions
    - ineffassign     # useless assignments
    - typecheck       # type checking
    - gocritic        # opinionated linter
    - gofumpt         # strict gofmt
    - misspell        # spelling errors
    - revive          # fast, configurable linter
    - exhaustive      # exhaustive enum switches
    - nilerr          # nil error returns
    - errorlint       # error wrapping
    - prealloc        # slice preallocation

linters-settings:
  gocritic:
    enabled-tags:
      - diagnostic
      - style
      - performance
  revive:
    rules:
      - name: exported
        severity: warning
      - name: unexported-return
        severity: warning
  govet:
    enable-all: true

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - gocritic
        - errcheck
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
      description: 'Disallow direct process.env access — use config module instead',
    },
    messages: {
      noDirectEnv: 'Direct process.env.{{name}} access is not allowed. Import from "@/config" instead.',
    },
    schema: [],
  },
  create(context) {
    return {
      MemberExpression(node) {
        if (
          node.object.type === 'MemberExpression' &&
          node.object.object.name === 'process' &&
          node.object.property.name === 'env'
        ) {
          // Allow in config files
          const filename = context.getFilename();
          if (filename.includes('/config/') || filename.includes('/config.')) return;

          context.report({
            node,
            messageId: 'noDirectEnv',
            data: { name: node.property.name || node.property.value },
          });
        }
      },
    };
  },
};
```

#### Ruff Custom Plugin (via ruff plugin system)
```python
# For Ruff, custom rules require contributing to Ruff or using flake8 plugins.
# Alternative: Use a custom flake8 plugin alongside Ruff.

# flake8_custom_rules/no_print.py
import ast
from typing import Generator

class NoPrintChecker:
    name = 'no-print'
    version = '1.0.0'

    def __init__(self, tree: ast.AST) -> None:
        self.tree = tree

    def run(self) -> Generator:
        for node in ast.walk(self.tree):
            if isinstance(node, ast.Call):
                if isinstance(node.func, ast.Name) and node.func.id == 'print':
                    yield (
                        node.lineno,
                        node.col_offset,
                        'P001 Use logger instead of print()',
                        type(self),
                    )
```

### Step 5: Auto-Fix Strategies
Maximize automated fixes to reduce manual work:

```
AUTO-FIX STRATEGY:
┌─────────────────────────────────────────────────────────────┐
│  Level 1: Format on Save (editor integration)                │
│  - Runs formatter (Prettier/Biome/gofmt) on every save      │
│  - Zero developer effort, instant feedback                   │
│                                                              │
│  Level 2: Lint Fix on Save (editor integration)              │
│  - Auto-fixes safe lint rules on save                        │
│  - import ordering, unused imports, const/let, etc.          │
│                                                              │
│  Level 3: Pre-commit Auto-fix (git hook)                     │
│  - Catches anything missed by editor                         │
│  - Runs on staged files only (fast)                          │
│                                                              │
│  Level 4: CI Enforcement (pipeline)                          │
│  - Final gate: fails PR if any violations remain             │
│  - No auto-fix — just enforcement                            │
└─────────────────────────────────────────────────────────────┘
```

#### Editor Integration (VS Code)
```jsonc
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": "explicit",
      "source.organizeImports": "explicit"
    }
  },
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go",
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },
  "editor.rulers": [100],
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true
}
```

#### Batch Auto-Fix
```bash
# Fix all existing violations in one pass
# TypeScript/JavaScript
npx eslint . --fix
npx prettier --write "**/*.{ts,tsx,js,jsx,json,css,md}"

# Python
ruff check --fix .
ruff format .

# Go
golangci-lint run --fix
goimports -w .

# Biome (all-in-one)
npx biome check --write .
```

```
BATCH FIX REPORT:
┌──────────────────────────────────────────────────────────────┐
│  Before: <N> errors, <N> warnings                             │
│  Auto-fixed: <N> issues                                       │
│  Remaining (manual): <N> issues                               │
│                                                               │
│  Auto-fixed breakdown:                                        │
│    Import ordering:     <N>                                   │
│    Unused imports:      <N>                                   │
│    Formatting:          <N>                                   │
│    const/let upgrades:  <N>                                   │
│    Trailing whitespace: <N>                                   │
│                                                               │
│  Manual review needed:                                        │
│    <file>:<line> — <rule>: <description>                      │
│    <file>:<line> — <rule>: <description>                      │
└──────────────────────────────────────────────────────────────┘
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
      "ruff check --fix",
      "ruff format"
    ],
    "*.go": [
      "golangci-lint run --fix",
      "goimports -w"
    ]
  }
}
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
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-added-large-files
        args: ['--maxkb=500']
      - id: no-commit-to-branch
        args: ['--branch', 'main']

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
        args: ['--fix']
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v9.10.0
    hooks:
      - id: eslint
        files: \.[jt]sx?$
        args: ['--fix', '--max-warnings=0']

  - repo: https://github.com/golangci/golangci-lint
    rev: v1.60.0
    hooks:
      - id: golangci-lint
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
┌──────────────────────────────────────────────────────────────┐
│  Area                │ Standard                     │ Enforced │
├──────────────────────┼──────────────────────────────┼──────────┤
│  Indentation         │ 2 spaces (no tabs)           │ Prettier │
│  Line length         │ 100 characters max           │ Prettier │
│  Quotes              │ Single quotes (JS/TS)        │ Prettier │
│  Semicolons          │ Always                       │ Prettier │
│  Trailing commas     │ All (functions included)     │ Prettier │
│  Import order        │ builtin > external > internal│ ESLint   │
│  Naming: variables   │ camelCase                    │ ESLint   │
│  Naming: functions   │ camelCase                    │ ESLint   │
│  Naming: classes     │ PascalCase                   │ ESLint   │
│  Naming: constants   │ UPPER_SNAKE_CASE             │ ESLint   │
│  Naming: files       │ kebab-case.ts                │ ESLint   │
│  Naming: types       │ PascalCase                   │ TSC      │
│  Naming: interfaces  │ PascalCase (no I- prefix)    │ ESLint   │
│  Error handling      │ Explicit, no silent catches  │ ESLint   │
│  Any type            │ Forbidden                    │ ESLint   │
│  Console.log         │ Warning (use logger)         │ ESLint   │
│  Unused variables    │ Error (prefix _ to ignore)   │ ESLint   │
│  Floating promises   │ Error (must await or void)   │ ESLint   │
└──────────────────────┴──────────────────────────────┴──────────┘
```

#### .editorconfig (Universal)
```ini
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
6. **Migrate incrementally.** Adding 50 new rules to an existing codebase generates thousands of violations. Enable rules one at a time, auto-fix, commit.

## Example Usage

### Setting up ESLint + Prettier for a TypeScript project
```
User: /godmode:lint Set up linting for our TypeScript React project

Lint: Scanning project...

ASSESSMENT:
  Language: TypeScript + React
  Current linter: None
  Current formatter: None
  Pre-commit hooks: None
  Files: 147 .ts/.tsx files

SETUP:
  Linter: ESLint 9 (flat config) + typescript-eslint strict
  Formatter: Prettier
  Hooks: Husky + lint-staged
  Editor: VS Code settings with format-on-save

INITIAL FIX:
  Total violations found: 312
  Auto-fixed: 287 (92%)
  Manual review: 25 (8%)
    - 12 @typescript-eslint/no-explicit-any
    - 8 @typescript-eslint/no-floating-promises
    - 5 no-console (intentional logging)

Commits:
  1. "lint: configure ESLint 9 + Prettier for TypeScript React"
  2. "lint: add Husky + lint-staged pre-commit hooks"
  3. "lint: auto-fix 287 existing violations"
```

### Migrating from ESLint + Prettier to Biome
```
User: /godmode:lint Migrate our project from ESLint + Prettier to Biome

Lint: Analyzing current configuration...

MIGRATION PLAN:
  Current: ESLint (47 rules) + Prettier
  Target: Biome
  Rule mapping: 41/47 rules have Biome equivalents
  Unmapped: 6 rules (React-specific, will use ESLint for those)

STEPS:
  1. Install Biome, create biome.json with equivalent rules
  2. Run Biome on codebase, fix formatting differences
  3. Remove ESLint + Prettier configs and deps
  4. Update pre-commit hooks and CI
  5. Update VS Code settings

RESULT:
  Lint time: 12.3s (ESLint) -> 0.18s (Biome) — 68x faster
  Config files: 3 (.eslintrc, .prettierrc, .prettierignore) -> 1 (biome.json)
  Rules enforced: 47 -> 41 (Biome) + 6 (ESLint for React)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full lint setup (linter + formatter + hooks + CI) |
| `--tool <name>` | Use specific tool (eslint, biome, ruff, golangci-lint) |
| `--fix` | Auto-fix all existing violations |
| `--hooks` | Set up pre-commit hooks only |
| `--ci` | Generate CI lint configuration only |
| `--custom-rule <name>` | Create a custom lint rule |
| `--migrate <from> <to>` | Migrate between lint tools |
| `--audit` | Count violations without fixing |
| `--strict` | Enable strictest rule set |
| `--style-guide` | Generate style guide document |

## Anti-Patterns

- **Do NOT debate formatting in code reviews.** Configure the formatter, automate it, and never discuss tabs vs spaces again. The tool decides.
- **Do NOT enable all rules at once.** Adding 200 rules to an existing codebase is overwhelming. Start with recommended, add rules incrementally.
- **Do NOT lint in CI without linting locally.** If developers discover violations only in CI, the feedback loop is 10 minutes instead of 1 second. Lint locally first.
- **Do NOT use `eslint-disable` as a strategy.** A file full of `// eslint-disable-next-line` comments is worse than no linting. Fix the code or adjust the rule.
- **Do NOT run the full linter in pre-commit.** Lint only staged files. Running the full linter makes commits take 30 seconds, and developers will skip the hook.
- **Do NOT skip the formatter.** Linting without formatting is half the job. Formatting eliminates 80% of style-related review comments.
- **Do NOT keep warnings around.** Warnings are noise that developers learn to ignore. Either promote to error or remove the rule.
- **Do NOT configure linting without team agreement.** Rules imposed without consensus will be circumvented. Discuss, agree, then automate.
