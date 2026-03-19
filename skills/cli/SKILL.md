---
name: cli
description: |
  CLI tool development skill. Activates when building, polishing, or distributing command-line interfaces and terminal user interfaces. Covers argument parsing design (Commander, Clap, Cobra, Click), interactive prompts and TUI frameworks (Ink, Ratatui, Bubbletea, Rich), configuration management (config files, environment variables, XDG), shell completion generation, distribution strategies (npm, Homebrew, cargo, pip), and CLI UX best practices. Every recommendation includes concrete implementation and cross-platform considerations. Triggers on: /godmode:cli, "CLI tool", "command line", "terminal app", "TUI", "argument parser", "shell completion".
---

# CLI — CLI Tool Development

## When to Activate
- User invokes `/godmode:cli`
- User says "CLI tool", "command line", "terminal app", "console application"
- User mentions "TUI", "terminal UI", "interactive prompt"
- User mentions "Commander", "Clap", "Cobra", "Click", "yargs", "argparse"
- User mentions "Ink", "Ratatui", "Bubbletea", "Rich", "Textual"
- When designing argument parsing, subcommands, or flag interfaces
- When generating shell completions (bash, zsh, fish, PowerShell)
- When distributing CLI tools via package managers

## Workflow

### Step 1: CLI Project Assessment
Determine the CLI development approach:

```
CLI PROJECT ASSESSMENT:
Project type: <new CLI | adding CLI to existing project | TUI application>
Language: <Node.js/TypeScript | Rust | Go | Python | other>
Complexity: <simple (few commands) | medium (subcommands) | complex (TUI/interactive)>

Argument parsing:
  Node.js: <Commander | yargs | meow | oclif>
  Rust: <Clap (derive) | Clap (builder) | argh>
  Go: <Cobra | urfave/cli | kong>
  Python: <Click | Typer | argparse | Fire>

Interactive features:
  Prompts: <yes (inquirer/dialoguer/survey/questionary) | no>
  Progress bars: <yes | no>
  Spinners: <yes | no>
  Tables: <yes | no>
  TUI framework: <none | Ink | Ratatui | Bubbletea | Textual | Rich>

Distribution targets:
  npm: <yes | no>
  Homebrew: <yes | no>
  cargo: <yes | no>
  pip/pipx: <yes | no>
  GitHub Releases: <yes | no>
  Docker: <yes | no>
  Platform-specific: <apt/deb | rpm | snap | AUR | winget | scoop>

Configuration:
  Config file: <yes (TOML/YAML/JSON) | no>
  Environment variables: <yes | no>
  XDG compliance: <yes | no>
  Dotfile: <~/.toolrc | ~/.config/tool/config.toml | none>
```

### Step 2: CLI Architecture

#### Node.js/TypeScript CLI
```
TYPESCRIPT CLI STRUCTURE:
├── src/
│   ├── index.ts                 # Entry point, argument parsing setup
│   ├── commands/                # Subcommand implementations
│   │   ├── init.ts              # `tool init` command
│   │   ├── build.ts             # `tool build` command
│   │   └── deploy.ts            # `tool deploy` command
│   ├── lib/                     # Core business logic
│   │   ├── config.ts            # Configuration loading/saving
│   │   ├── api.ts               # API client (if needed)
│   │   └── utils.ts             # Shared utilities
│   ├── ui/                      # Terminal UI components
│   │   ├── spinner.ts           # Loading spinner
│   │   ├── prompt.ts            # Interactive prompts
│   │   └── table.ts             # Table formatting
│   └── types.ts                 # TypeScript type definitions
├── bin/
│   └── tool.js                  # Shebang entry: #!/usr/bin/env node
├── completions/                 # Shell completion scripts
│   ├── tool.bash                # Bash completions
│   ├── tool.zsh                 # Zsh completions
│   └── tool.fish                # Fish completions
├── package.json                 # bin field, dependencies
├── tsconfig.json                # TypeScript configuration
└── README.md

package.json essentials:
  "bin": { "tool": "./bin/tool.js" }
  "engines": { "node": ">=18" }
  "type": "module"
  "files": ["dist", "bin"]
```

#### Rust CLI
```
RUST CLI STRUCTURE:
├── src/
│   ├── main.rs                  # Entry point, clap setup
│   ├── cli.rs                   # CLI argument definitions (Clap derive)
│   ├── commands/                # Subcommand implementations
│   │   ├── mod.rs
│   │   ├── init.rs              # `tool init` handler
│   │   ├── build.rs             # `tool build` handler
│   │   └── deploy.rs            # `tool deploy` handler
│   ├── config.rs                # Configuration (serde + toml/yaml)
│   ├── error.rs                 # Error types (thiserror)
│   └── ui.rs                    # Terminal output (indicatif, console)
├── tests/                       # Integration tests
│   └── cli_tests.rs             # CLI invocation tests (assert_cmd)
├── completions/                 # Generated shell completions
├── Cargo.toml                   # Dependencies
└── build.rs                     # Completion generation at build time

Cargo.toml essentials:
  [dependencies]
  clap = { version = "4", features = ["derive", "env"] }
  serde = { version = "1", features = ["derive"] }
  toml = "0.8"
  anyhow = "1"       # Error handling
  indicatif = "0.17"  # Progress bars
  console = "0.15"    # Colors and styling
  dialoguer = "0.11"  # Interactive prompts

  [dev-dependencies]
  assert_cmd = "2"    # CLI integration testing
  predicates = "3"    # Assertion helpers
```

#### Go CLI
```
GO CLI STRUCTURE:
├── cmd/
│   ├── root.go                  # Root command (Cobra)
│   ├── init.go                  # `tool init` command
│   ├── build.go                 # `tool build` command
│   └── deploy.go                # `tool deploy` command
├── internal/                    # Private packages
│   ├── config/                  # Configuration management
│   │   └── config.go
│   ├── ui/                      # Terminal UI utilities
│   │   ├── spinner.go
│   │   └── table.go
│   └── client/                  # API client (if needed)
│       └── client.go
├── pkg/                         # Public library code (if any)
├── completions/                 # Shell completion scripts
├── main.go                      # Entry point
├── go.mod                       # Module definition
└── go.sum                       # Dependency checksums

Cobra essentials:
  rootCmd.AddCommand(initCmd)
  rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file")
  rootCmd.GenBashCompletionFileV2("completions/tool.bash", true)
  rootCmd.GenZshCompletionFile("completions/tool.zsh")
  rootCmd.GenFishCompletionFile("completions/tool.fish", true)
```

#### Python CLI
```
PYTHON CLI STRUCTURE:
├── src/
│   └── tool/
│       ├── __init__.py          # Package init
│       ├── __main__.py          # python -m tool entry
│       ├── cli.py               # Click/Typer app definition
│       ├── commands/            # Subcommand implementations
│       │   ├── __init__.py
│       │   ├── init.py          # `tool init` command
│       │   ├── build.py         # `tool build` command
│       │   └── deploy.py        # `tool deploy` command
│       ├── config.py            # Configuration management
│       └── ui.py                # Rich console output
├── tests/                       # Pytest tests
│   ├── test_cli.py              # CLI invocation tests
│   └── conftest.py              # Test fixtures
├── pyproject.toml               # Project metadata, build config
└── README.md

pyproject.toml essentials:
  [project.scripts]
  tool = "tool.cli:app"

  [build-system]
  requires = ["hatchling"]
  build-backend = "hatchling.build"
```

### Step 3: Argument Parsing Design

```
ARGUMENT DESIGN PRINCIPLES:

Command hierarchy:
  tool <command> <subcommand> [options] [arguments]
  tool init                           # Simple command
  tool deploy --env production        # Command with option
  tool config set key value           # Subcommand with positional args

Naming conventions:
  Commands: verb or noun (init, build, deploy, config, list)
  Flags: --long-form with short aliases (-v / --verbose)
  Boolean flags: --flag (enable), --no-flag (disable)
  Value flags: --output <path>, --format <json|table|csv>

Standard flags (include in every CLI):
  -h, --help           # Show help text
  -V, --version        # Show version
  -v, --verbose        # Increase verbosity (stackable: -vvv)
  -q, --quiet          # Suppress non-essential output
  --no-color           # Disable colored output
  --json               # Machine-readable JSON output
  --config <path>      # Override config file path

Flag precedence (highest to lowest):
  1. Command-line flags (--key value)
  2. Environment variables (TOOL_KEY=value)
  3. Config file (~/.config/tool/config.toml)
  4. Default values (hardcoded in code)

HELP TEXT FORMAT:
  tool — One line description of what the tool does.

  Usage:
    tool <command> [options]

  Commands:
    init        Create a new project
    build       Build the project
    deploy      Deploy to target environment
    config      Manage configuration

  Options:
    -h, --help      Show this help message
    -V, --version   Show version number
    -v, --verbose   Enable verbose output
    --no-color      Disable colored output

  Examples:
    tool init my-project
    tool build --release
    tool deploy --env production

  Run 'tool <command> --help' for more information on a command.
```

### Step 4: Interactive Prompts & TUI

```
INTERACTIVE PROMPT PATTERNS:

Text input:
  ? Project name: <user types>
  Validation: non-empty, valid characters, no conflicts

Select (single choice):
  ? Framework:
    > React
      Vue
      Svelte
  Navigation: arrow keys, type to filter

Multi-select:
  ? Features:
    [x] TypeScript
    [ ] ESLint
    [x] Prettier
  Navigation: space to toggle, enter to confirm

Confirm:
  ? Deploy to production? (y/N)
  Default clearly indicated by capitalization

Password:
  ? API key: ********
  Input hidden, no echo

TUI FRAMEWORKS:

Ink (Node.js) — React for the terminal:
  Best for: Complex interactive interfaces in Node.js CLIs
  Uses React component model with hooks
  Supports flexbox-like layout

Ratatui (Rust) — Immediate mode TUI:
  Best for: High-performance terminal UIs in Rust
  Full terminal control (layout, widgets, events)
  Backends: crossterm (cross-platform), termion (Unix)

Bubbletea (Go) — Elm Architecture for TUI:
  Best for: Interactive Go CLIs with complex state
  Model-Update-View architecture
  Composable components (Bubbles library)

Rich / Textual (Python) — Rich terminal output and TUI:
  Rich: Tables, progress bars, syntax highlighting, markdown
  Textual: Full TUI framework with widgets, CSS-like styling

PROGRESS AND STATUS PATTERNS:
  Spinner: for indeterminate operations
    ⠋ Installing dependencies...
    ✓ Dependencies installed (2.3s)

  Progress bar: for determinate operations
    Downloading  [████████░░░░░░░░]  52% (12.4 MB / 23.8 MB)

  Multi-step:
    ✓ Step 1/4 — Validate configuration
    ✓ Step 2/4 — Build project
    ⠋ Step 3/4 — Run tests...
    ○ Step 4/4 — Deploy

  Table output:
    ┌──────────┬─────────┬────────┐
    │ Name     │ Status  │ Size   │
    ├──────────┼─────────┼────────┤
    │ api      │ Running │ 12 MB  │
    │ web      │ Stopped │ 45 MB  │
    └──────────┴─────────┴────────┘
```

### Step 5: Configuration Management

```
CONFIGURATION STRATEGY:

File format selection:
  TOML: best for human-edited config (Rust ecosystem standard)
  YAML: best for structured config (DevOps ecosystem standard)
  JSON: best for machine-generated config (universal support)
  INI:  legacy, avoid for new projects

XDG Base Directory compliance (Linux/macOS):
  Config:  $XDG_CONFIG_HOME/tool/config.toml  (~/.config/tool/config.toml)
  Data:    $XDG_DATA_HOME/tool/               (~/.local/share/tool/)
  Cache:   $XDG_CACHE_HOME/tool/              (~/.cache/tool/)
  State:   $XDG_STATE_HOME/tool/              (~/.local/state/tool/)

Windows paths:
  Config:  %APPDATA%\tool\config.toml
  Data:    %LOCALAPPDATA%\tool\data\
  Cache:   %LOCALAPPDATA%\tool\cache\

Config file structure:
  # ~/.config/tool/config.toml
  [defaults]
  format = "json"
  verbose = false

  [auth]
  # token = "..." # Set via: tool auth login

  [deploy]
  default_env = "staging"
  confirm = true

Environment variable mapping:
  TOOL_FORMAT=json          → defaults.format
  TOOL_VERBOSE=true         → defaults.verbose
  TOOL_DEPLOY_ENV=staging   → deploy.default_env
  Convention: TOOL_ prefix + UPPER_SNAKE_CASE

Config commands:
  tool config list             # Show all config values with source
  tool config get <key>        # Get single value
  tool config set <key> <val>  # Set value in config file
  tool config reset            # Reset to defaults
  tool config path             # Show config file location
```

### Step 6: Shell Completion Generation

```
SHELL COMPLETION SETUP:

Bash:
  Generate: tool completion bash > /usr/local/etc/bash_completion.d/tool
  Or: tool completion bash >> ~/.bashrc
  Mechanism: complete -F / complete -C

Zsh:
  Generate: tool completion zsh > "${fpath[1]}/_tool"
  Or add to .zshrc: eval "$(tool completion zsh)"
  Mechanism: compdef / _arguments

Fish:
  Generate: tool completion fish > ~/.config/fish/completions/tool.fish
  Mechanism: complete -c tool -s <short> -l <long> -d <description>

PowerShell:
  Generate: tool completion powershell >> $PROFILE
  Mechanism: Register-ArgumentCompleter

FRAMEWORK-SPECIFIC GENERATION:
  Clap (Rust):    clap_complete crate, generate at build time in build.rs
  Cobra (Go):     rootCmd.GenBashCompletionV2, GenZshCompletion, GenFishCompletion
  Click (Python): shell_complete module, _TOOL_COMPLETE=bash_source tool
  Commander (JS): omelette or tabtab package for completion generation

INSTALLATION INSTRUCTIONS (include in --help):
  tool completion --help

  Install shell completions:

    Bash:
      tool completion bash >> ~/.bashrc
      source ~/.bashrc

    Zsh:
      tool completion zsh > "${fpath[1]}/_tool"
      rm -f ~/.zcompdump; compinit

    Fish:
      tool completion fish > ~/.config/fish/completions/tool.fish

    PowerShell:
      tool completion powershell >> $PROFILE
```

### Step 7: Distribution

```
DISTRIBUTION STRATEGIES:

npm (Node.js):
  Publish: npm publish
  Install: npm install -g tool / npx tool
  Config:
    package.json:
      "bin": { "tool": "./bin/tool.js" }
      "files": ["dist", "bin"]
  Users get: automatic dependency resolution, easy updates

Homebrew (macOS/Linux):
  Create formula or tap:
    brew tap org/tools
    brew install org/tools/tool
  For binaries: use GitHub Release URLs with SHA256
  For source: build from tarball
  Users get: native feel, auto-update via brew upgrade

Cargo (Rust):
  Publish: cargo publish
  Install: cargo install tool / cargo binstall tool
  Config: Cargo.toml with proper metadata
  Users get: source compilation or prebuilt binary (binstall)

pip/pipx (Python):
  Publish: python -m build && twine upload dist/*
  Install: pipx install tool (recommended) / pip install tool
  Config: pyproject.toml with [project.scripts]
  Users get: isolated environment (pipx), easy updates

GitHub Releases (universal):
  Attach prebuilt binaries for each platform:
    tool-x86_64-linux.tar.gz
    tool-aarch64-linux.tar.gz
    tool-x86_64-darwin.tar.gz
    tool-aarch64-darwin.tar.gz
    tool-x86_64-windows.zip
  Include SHA256SUMS file
  Users get: direct binary download, no runtime needed

Docker (containerized):
  FROM alpine:latest
  COPY tool /usr/local/bin/tool
  ENTRYPOINT ["tool"]
  Install: docker run --rm -v $(pwd):/work org/tool <command>
  Users get: zero installation, consistent environment

RELEASE AUTOMATION:
  CI/CD pipeline:
    1. Tag: git tag v1.2.3 && git push --tags
    2. Build: cross-compile for all targets
    3. Test: run integration tests on each platform
    4. Package: create archives, installers
    5. Publish: upload to GitHub Releases, npm, crates.io, PyPI
    6. Announce: update Homebrew formula, changelog
```

### Step 8: CLI Development Report

```
┌────────────────────────────────────────────────────────────────┐
│  CLI PROJECT — <tool name>                                      │
├────────────────────────────────────────────────────────────────┤
│  Language: <TypeScript | Rust | Go | Python>                     │
│  Parser: <Commander | Clap | Cobra | Click>                     │
│  Complexity: <simple | subcommands | TUI>                        │
│                                                                  │
│  Commands:                                                       │
│    <command>: <IMPLEMENTED | TESTED | DOCUMENTED>               │
│    <command>: <IMPLEMENTED | TESTED | DOCUMENTED>               │
│                                                                  │
│  Features:                                                       │
│    Shell completions: <bash | zsh | fish | powershell | all>     │
│    Config file: <TOML | YAML | JSON | none>                     │
│    Interactive prompts: <YES | NO>                               │
│    JSON output: <YES | NO>                                       │
│    Color support: <YES | NO>                                     │
│                                                                  │
│  Distribution:                                                   │
│    npm: <PUBLISHED | CONFIGURED | NO>                            │
│    Homebrew: <PUBLISHED | CONFIGURED | NO>                       │
│    Cargo: <PUBLISHED | CONFIGURED | NO>                          │
│    pip: <PUBLISHED | CONFIGURED | NO>                            │
│    GitHub Releases: <PUBLISHED | CONFIGURED | NO>                │
│                                                                  │
│  Testing:                                                        │
│    Unit tests: <N passing>                                       │
│    Integration tests: <N passing>                                │
│    CLI snapshot tests: <YES | NO>                                │
├────────────────────────────────────────────────────────────────┤
│  Next: /godmode:test — Test CLI commands and edge cases          │
│        /godmode:docs — Generate man pages and documentation      │
│        /godmode:ship — Publish to package managers               │
└────────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Commit CLI scaffold: `"cli: <language> — <tool> CLI scaffold with <parser>"`
2. Commit commands: `"cli: <command> — implement <description>"`
3. Commit distribution: `"cli: distribution — <package manager> packaging"`
4. If publish-ready: "CLI is tested and documented. Run `/godmode:ship` to publish."
5. If in progress: "CLI scaffold complete. Run `/godmode:build` to implement commands."

## Key Behaviors

1. **Error messages are UX.** A CLI that prints a stack trace on invalid input is hostile. Show what went wrong, why, and how to fix it. Include the correct usage example.
2. **Defaults should be safe.** Destructive commands require confirmation. Verbose mode is opt-in. Color respects NO_COLOR and terminal capability.
3. **Machine-readable output is a feature.** Always support --json for output that other tools may consume. Human-readable is the default; machine-readable is the option.
4. **Shell completions are expected.** Users who install CLIs via package managers expect tab completion to work. Generate completions for bash, zsh, fish, and PowerShell.
5. **Exit codes are meaningful.** 0 = success, 1 = general error, 2 = usage error. Document non-zero exit codes. Scripts depend on them.
6. **Respect the terminal.** Check if stdout is a TTY before using colors, spinners, or interactive prompts. Pipe-friendly output when not a TTY.

## Example Usage

### Building a Rust CLI tool
```
User: /godmode:cli Build a file management CLI in Rust

CLI: Assessing requirements...

CLI PROJECT:
Language: Rust
Parser: Clap (derive API)
Complexity: Subcommands with interactive features

Architecture:
  /src
    main.rs            — Entry point, Clap derive structs
    cli.rs             — Argument definitions
    /commands
      list.rs          — `fm list` — list files with filtering
      move.rs          — `fm move` — interactive file move with preview
      clean.rs         — `fm clean` — find and remove duplicates
    config.rs          — TOML config (~/.config/fm/config.toml)
    ui.rs              — indicatif progress, console colors

Features:
  - Tab completion (bash, zsh, fish, PowerShell)
  - --json output on all commands
  - Config file for default options
  - Interactive confirmation for destructive ops
  - Respects NO_COLOR environment variable

Distribution:
  - cargo install fm-tool
  - Homebrew formula (prebuilt binaries)
  - GitHub Releases (Linux x64/ARM, macOS Intel/Apple Si, Windows x64)

Next: /godmode:build to implement commands
      /godmode:test to add assert_cmd integration tests
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full CLI project assessment and setup |
| `--interactive` | Focus on interactive prompts and TUI |
| `--completion` | Shell completion generation only |
| `--distribute` | Distribution and packaging setup only |
| `--language <lang>` | Use specific language (typescript, rust, go, python) |
| `--parser <name>` | Use specific parser (commander, clap, cobra, click) |
| `--tui` | Full TUI application setup |

## Anti-Patterns

- **Do NOT print help on no arguments if the tool has a default action.** If `tool` with no args should do something useful, do that. Only show help when the user explicitly asks or when the input is ambiguous.
- **Do NOT require global installation.** Support npx/bunx (Node.js), pipx (Python), cargo install (Rust), or go install (Go) for one-shot usage without polluting global state.
- **Do NOT hardcode colors.** Check NO_COLOR environment variable, terminal capability (isatty), and provide --no-color flag. Respect the user's terminal preferences.
- **Do NOT swallow errors silently.** If a command fails, exit with non-zero code and print a clear error message to stderr. Callers (scripts, CI) depend on exit codes.
- **Do NOT break backwards compatibility in minor versions.** CLI tools are APIs for scripts. Changing flag names, output format, or behavior without a major version bump breaks automation.
- **Do NOT make interactive prompts mandatory.** Support non-interactive mode (--yes, --no-input) for CI/CD and scripting. Interactive prompts should be enhancements, not requirements.
- **Do NOT ignore stdin.** If your tool processes data, accept pipe input: `cat file | tool process` and `tool process < file` should work.
- **Do NOT forget man pages.** For tools distributed via Homebrew or system packages, man pages are expected. Generate them from your help text.
