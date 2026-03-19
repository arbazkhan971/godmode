# Recipe: Building a Developer CLI Tool

> From concept to published npm/Homebrew package. Build a CLI that developers actually want to use.

---

## Context

Developer tools live and die on the command line. A well-built CLI tool can save thousands of hours across a team or community. This recipe covers the full lifecycle: designing the command interface, building with proper argument parsing and error handling, testing, writing man pages, and publishing to npm and Homebrew so others can install it with a single command.

## The Chain

```
cli → think → plan → build → test → docs → release → ship
```

## When to Use This Recipe

- Building an internal CLI tool for your team's workflow
- Creating an open-source developer tool
- Adding a CLI interface to an existing library or service
- Building a scaffolding/code generation tool
- Any tool where the primary interface is the terminal

---

## Session Transcript

### Phase 1: CLI Design

Design the command structure before writing any code.

```
> /godmode:think I want to build a CLI tool called "scaffold" that generates
  project boilerplate from templates. Users should be able to list available
  templates, generate a project from a template, and create custom templates.
  It should work like create-react-app or cargo-generate.

Godmode: Researching CLI patterns...

One question: Should templates be local only (shipped with the CLI) or
should users be able to pull templates from a remote registry (like GitHub
repos or a template registry)?

> Start with local templates bundled with the CLI, but design for remote
  templates in v2.

Godmode: Writing spec...

CLI DESIGN:

  Name: scaffold
  Binary: scaffold (or scf for short alias)

  Commands:
    scaffold new <template> [project-name]   — Generate project from template
    scaffold list                             — List available templates
    scaffold info <template>                  — Show template details
    scaffold add <path>                       — Add custom template from directory
    scaffold remove <template>                — Remove custom template
    scaffold update                           — Update built-in templates
    scaffold config                           — Show/set configuration
    scaffold completion <shell>               — Generate shell completions

  Global flags:
    --help, -h          Show help
    --version, -v       Show version
    --verbose           Verbose output
    --quiet, -q         Suppress non-essential output
    --no-color          Disable colored output
    --yes, -y           Skip all prompts (accept defaults)
    --dry-run           Show what would be generated without writing

  Template variables:
    scaffold new nextjs my-app
      → Prompts: "Project description?" "Author name?" "License?"
      → Variables: {{project_name}}, {{description}}, {{author}}, {{license}}
      → Transforms: {{project_name | kebab-case}}, {{project_name | PascalCase}}

  Configuration:
    ~/.config/scaffold/config.toml
      default_author = "Alice Smith"
      default_license = "MIT"
      template_dir = "~/.config/scaffold/templates"

  Exit codes:
    0 — success
    1 — general error
    2 — invalid usage (wrong arguments)
    3 — template not found
    4 — file conflict (target directory not empty)

Saved: docs/specs/scaffold-cli.md
Commit: "spec: scaffold CLI — project generation from templates"
```

### Phase 2: Technology Selection

```
> /godmode:think What should I build this CLI in?

Godmode: Evaluating CLI frameworks...

TECHNOLOGY OPTIONS:

  Node.js + Commander/Oclif:
    + Largest ecosystem (npm packages)
    + Easy template engine (Handlebars, EJS)
    + Cross-platform without compilation
    - Requires Node.js runtime installed
    - Startup time: ~200-500ms (acceptable)

  Rust + Clap:
    + Single binary, no runtime dependency
    + Fastest startup (~5ms)
    + Cross-compile for all platforms
    - Steeper learning curve
    - Harder to work with template engines

  Go + Cobra:
    + Single binary, no runtime dependency
    + Fast startup (~10ms)
    + Cross-compile built-in
    + Good template engine (text/template)
    - Less npm ecosystem access

  Python + Click/Typer:
    + Rapid development
    + Rich ecosystem
    - Requires Python runtime
    - Distribution harder (pyinstaller, pipx)

RECOMMENDATION: Node.js with Commander
  Why: Template engines (Handlebars) are first-class in Node.js.
  npm distribution is trivial. Most developer machines have Node.js.
  If single-binary distribution matters, switch to Go.

  Alternative: Go with Cobra if you want zero-dependency distribution
  and your templates are simpler (Go's text/template is sufficient).
```

### Phase 3: Plan

```
> /godmode:plan

Godmode: Decomposing into tasks...

IMPLEMENTATION PLAN: 12 tasks in 3 phases

Phase 1: Foundation (Tasks 1-4)
  Task 1: CLI skeleton — Commander setup, global flags, help text
  Task 2: Configuration system — TOML config, XDG directories, defaults
  Task 3: Template engine — Handlebars with custom helpers and transforms
  Task 4: Built-in templates — nextjs, express-api, react-lib (3 starters)

Phase 2: Commands (Tasks 5-9)
  Task 5: scaffold new — interactive prompts, variable substitution, file generation
  Task 6: scaffold list — table output with name, description, tags
  Task 7: scaffold info — detailed template view (files, variables, dependencies)
  Task 8: scaffold add/remove — custom template management
  Task 9: scaffold completion — bash, zsh, fish shell completions

Phase 3: Polish (Tasks 10-12)
  Task 10: Dry-run mode — show file tree without writing
  Task 11: Conflict handling — prompt on non-empty directory
  Task 12: Progress output — spinner, file write log, summary

Branch: feat/scaffold-cli
Saved: docs/plans/scaffold-cli-plan.md
Commit: "plan: 12 tasks for scaffold CLI"
```

### Phase 4: Build

```
> /godmode:build

Godmode: Building CLI...

PROJECT STRUCTURE:
  /src
    /commands
      new.ts              # scaffold new <template> [name]
      list.ts             # scaffold list
      info.ts             # scaffold info <template>
      add.ts              # scaffold add <path>
      remove.ts           # scaffold remove <template>
      completion.ts       # scaffold completion <shell>
      config.ts           # scaffold config
    /lib
      template-engine.ts  # Handlebars rendering with transforms
      config.ts           # Configuration loading and saving
      prompts.ts          # Interactive prompts (inquirer)
      output.ts           # Colored output, spinners, tables
      fs.ts               # File system utilities
    /templates
      /nextjs             # Built-in Next.js template
      /express-api        # Built-in Express API template
      /react-lib          # Built-in React library template
    index.ts              # CLI entry point
  /test
    /commands             # Command tests
    /lib                  # Library tests
    /fixtures             # Test templates and expected outputs
  /bin
    scaffold              # Executable entry point (#!/usr/bin/env node)
  package.json
  tsconfig.json

BUILDING (TDD):
  Task 1: CLI skeleton
    RED:   test_help_flag_shows_usage
    GREEN: Commander setup with all commands registered
    COMMIT: "feat: CLI skeleton — Commander setup with global flags"

  Task 5: scaffold new (core command)
    RED:   test_new_generates_project_from_template
    GREEN: Interactive prompts → template rendering → file writing
    RED:   test_new_with_dry_run_shows_tree
    GREEN: --dry-run flag shows file tree without writing
    RED:   test_new_replaces_all_template_variables
    GREEN: Handlebars rendering with {{project_name}}, {{author}}, etc.
    COMMIT: "feat: scaffold new — generate project from template"

  [continues through all 12 tasks]

BUILD COMPLETE:
  12 tasks, 34 tests, all passing
  CLI binary: ./bin/scaffold

Commit: "build: scaffold CLI — all commands implemented and tested"
```

### Phase 5: Test

```
> /godmode:test --coverage

Godmode: Running comprehensive test suite...

UNIT TESTS (34 tests):
  Commands:
    ✓ new: generates project from template (5 tests)
    ✓ new: prompts for missing variables (3 tests)
    ✓ new: dry-run shows tree without writing (2 tests)
    ✓ new: aborts on non-empty directory unless --force (2 tests)
    ✓ list: shows all templates in table format (2 tests)
    ✓ info: shows template details (2 tests)
    ✓ add: imports template from local directory (3 tests)
    ✓ remove: removes custom template (2 tests)
    ✓ completion: generates valid bash/zsh/fish completions (3 tests)
    ✓ config: reads and writes configuration (2 tests)

  Library:
    ✓ template-engine: renders variables and transforms (4 tests)
    ✓ config: loads from XDG path with defaults (2 tests)
    ✓ output: respects --no-color flag (2 tests)

INTEGRATION TESTS (8 tests):
  ✓ Full flow: scaffold new nextjs my-app → creates working Next.js project
  ✓ Full flow: scaffold add ./my-template → scaffold new my-template → works
  ✓ Full flow: scaffold new with --yes → skips all prompts, uses defaults
  ✓ Full flow: scaffold new with --dry-run → no files written
  ✓ Error: scaffold new nonexistent → exit code 3, clear error message
  ✓ Error: scaffold new nextjs existing-dir → exit code 4, conflict prompt
  ✓ Config: custom default_author used when not prompted
  ✓ Completion: generated bash completion script is valid

COVERAGE: 91% (target: 85%) ✓
  Uncovered: edge cases in template conflict resolution (acceptable)

EXIT CODES VERIFIED:
  ✓ Exit 0 on success
  ✓ Exit 1 on general error
  ✓ Exit 2 on invalid arguments
  ✓ Exit 3 on template not found
  ✓ Exit 4 on file conflict

Commit: "test: 42 tests — unit + integration, 91% coverage"
```

### Phase 6: Documentation

```
> /godmode:docs --cli

Godmode: Generating CLI documentation...

DOCUMENTATION GENERATED:

  README.md:
    - Installation (npm, npx, Homebrew)
    - Quick start (scaffold new in 30 seconds)
    - Command reference (all commands with examples)
    - Template authoring guide
    - Configuration reference
    - Contributing guide

  Man page:
    scaffold.1             # man scaffold
    scaffold-new.1         # man scaffold-new

  Shell completions:
    completions/bash/scaffold.bash
    completions/zsh/_scaffold
    completions/fish/scaffold.fish

  Built-in help:
    scaffold --help          → general usage
    scaffold new --help      → command-specific help
    scaffold list --help     → command-specific help

  Help text style:
    Short description on first line
    Usage pattern with required/optional args
    Flag table with descriptions and defaults
    Examples section with 2-3 real commands

  Example:
    $ scaffold new --help

    Generate a new project from a template.

    USAGE:
      scaffold new <template> [project-name] [flags]

    ARGUMENTS:
      template       Template name (run 'scaffold list' to see options)
      project-name   Name for the new project (defaults to template name)

    FLAGS:
      -y, --yes      Skip all prompts, use defaults
      --dry-run      Show what would be generated without writing files
      --force        Overwrite existing directory

    EXAMPLES:
      scaffold new nextjs my-app
      scaffold new express-api --yes
      scaffold new react-lib --dry-run

Commit: "docs: README, man pages, shell completions, built-in help"
```

### Phase 7: Release

```
> /godmode:release --npm --homebrew

Godmode: Preparing release...

PRE-RELEASE CHECKS:
  ✓ All 42 tests passing
  ✓ TypeScript compiles without errors
  ✓ Lint clean (ESLint + Prettier)
  ✓ No known vulnerabilities (npm audit)
  ✓ package.json version: 1.0.0
  ✓ CHANGELOG.md written
  ✓ LICENSE file present (MIT)
  ✓ .npmignore configured (excludes tests, src, tsconfig)
  ✓ Binary field configured: "bin": { "scaffold": "./bin/scaffold" }

NPM PUBLISH:
  Package: scaffold-cli@1.0.0
  Registry: https://registry.npmjs.org
  ✓ Published successfully

  Install: npm install -g scaffold-cli
  Run without install: npx scaffold-cli new nextjs my-app

HOMEBREW FORMULA:
  Created: homebrew-tap/Formula/scaffold.rb
  ✓ Formula tested (brew install --build-from-source)
  ✓ brew test scaffold passes
  ✓ brew audit scaffold passes

  Install:
    brew tap yourname/tap
    brew install scaffold

GITHUB RELEASE:
  Tag: v1.0.0
  Release notes: auto-generated from CHANGELOG.md
  Assets: none (installed via npm or Homebrew)

Commit: "release: v1.0.0 — npm + Homebrew distribution"
```

### Phase 8: Ship

```
> /godmode:ship --verify

Godmode: Verifying release...

INSTALLATION VERIFICATION:
  ✓ npm install -g scaffold-cli → installs, scaffold --version shows 1.0.0
  ✓ npx scaffold-cli --help → shows help without global install
  ✓ brew install scaffold → installs, scaffold --version shows 1.0.0

SMOKE TESTS:
  ✓ scaffold list → shows 3 built-in templates
  ✓ scaffold new nextjs test-project → generates working Next.js project
  ✓ scaffold new express-api test-api --yes → generates without prompts
  ✓ scaffold completion bash → outputs valid bash completion script
  ✓ scaffold config → shows default configuration

SHIP STATUS: ✓ RELEASED
  npm: https://www.npmjs.com/package/scaffold-cli
  Homebrew: brew install yourname/tap/scaffold
  GitHub: https://github.com/yourname/scaffold-cli/releases/tag/v1.0.0
```

---

## CLI Design Principles

### 1. Respect the user's terminal

```
TERMINAL RESPECT:
  - --no-color: always support disabling color (also respect NO_COLOR env var)
  - --quiet: suppress non-essential output (only errors and final result)
  - --verbose: show debug information for troubleshooting
  - Stderr for errors and progress, stdout for data (enables piping)
  - Exit codes: 0 = success, non-zero = failure (specific codes per error type)
  - Respect terminal width: wrap long output, truncate tables
```

### 2. Be predictable

```
PREDICTABILITY:
  - Same input → same output (deterministic)
  - --dry-run: show what will happen without doing it
  - --yes: skip prompts for automation (CI/CD compatibility)
  - Confirm destructive actions (delete, overwrite)
  - Never modify files outside the expected scope
```

### 3. Fail loudly and helpfully

```
ERROR HANDLING:
  Bad:  "Error: ENOENT"
  Good: "Error: Template 'react-app' not found.
         Available templates: nextjs, express-api, react-lib
         Run 'scaffold list' to see all templates."

  Rules:
  - Say what went wrong
  - Say why it went wrong (if known)
  - Suggest what to do next
  - Include the command to fix it
```

### 4. Support automation

```
AUTOMATION-FRIENDLY:
  - --json flag: output structured JSON instead of human-readable text
  - --yes flag: non-interactive mode (no prompts)
  - Stdin: accept input from pipes (echo "my-project" | scaffold new nextjs)
  - Exit codes: specific codes per error type (not just 0/1)
  - No interactive prompts in CI (detect CI env vars: CI, GITHUB_ACTIONS, etc.)
```

---

## Homebrew Formula Template

```ruby
# Formula/scaffold.rb
class Scaffold < Formula
  desc "Generate project boilerplate from templates"
  homepage "https://github.com/yourname/scaffold-cli"
  url "https://registry.npmjs.org/scaffold-cli/-/scaffold-cli-1.0.0.tgz"
  sha256 "abc123..."  # SHA256 of the npm tarball
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Install shell completions
    generate_completions_from_executable(bin/"scaffold", "completion")
  end

  test do
    assert_match "1.0.0", shell_output("#{bin}/scaffold --version")
    assert_match "nextjs", shell_output("#{bin}/scaffold list")
  end
end
```

---

## npm Package Configuration

```json
{
  "name": "scaffold-cli",
  "version": "1.0.0",
  "description": "Generate project boilerplate from templates",
  "bin": {
    "scaffold": "./bin/scaffold",
    "scf": "./bin/scaffold"
  },
  "files": [
    "bin/",
    "dist/",
    "templates/"
  ],
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["cli", "scaffold", "generator", "template", "boilerplate"],
  "license": "MIT"
}
```

---

## Release Automation

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm test

  publish-npm:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

  publish-homebrew:
    needs: publish-npm
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          repository: yourname/homebrew-tap
          token: ${{ secrets.TAP_TOKEN }}
      - name: Update formula
        run: |
          # Update version and SHA in Formula/scaffold.rb
          # Commit and push to homebrew-tap
```

---

## See Also

- [Master Skill Index](../skill-index.md) — `/godmode:cli`, `/godmode:docs`, `/godmode:release`
- [Skill Chains](../skill-chains.md) — full-stack chain
- [Building an MVP](startup-mvp.md) — If the CLI is the product
- [Building an API Gateway](api-gateway.md) — If the CLI wraps an API
