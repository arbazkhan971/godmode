---
name: cli
description: |
  CLI tool development skill. Activates when building, polishing, or distributing command-line interfaces and terminal
    user interfaces. Covers argument parsing design (Commander, Clap, Cobra, Click), interactive prompts and TUI
    frameworks (Ink, Ratatui, Bubbletea, Rich), configuration management (config files, environment variables, XDG),
    shell completion generation, distribution strategies (npm, Homebrew, cargo, pip), and CLI UX best practices. Every
    recommendation includes concrete implementation and cross-platform considerations. Triggers on: /godmode:cli, "CLI
    tool", "command line", "terminal app", "TUI", "argument parser", "shell completion".
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
```
### Step 8: CLI Development Report

```
  CLI PROJECT — <tool name>
  Language: <TypeScript | Rust | Go | Python>
  Parser: <Commander | Clap | Cobra | Click>
  Complexity: <simple | subcommands | TUI>
  Commands:
  <command>: <IMPLEMENTED | TESTED | DOCUMENTED>
  <command>: <IMPLEMENTED | TESTED | DOCUMENTED>
  Features:
  Shell completions: <bash | zsh | fish | powershell | all>
  Config file: <TOML | YAML | JSON | none>
  Interactive prompts: <YES | NO>
```
### Step 9: Commit and Transition
1. Commit CLI scaffold: `"cli: <language> — <tool> CLI scaffold with <parser>"`
2. Commit commands: `"cli: <command> — implement <description>"`
3. Commit distribution: `"cli: distribution — <package manager> packaging"`
4. If publish-ready: "CLI is tested and documented. Run `/godmode:ship` to publish."
5. If in progress: "CLI scaffold complete. Run `/godmode:build` to implement commands."

## Key Behaviors

```bash
# Test CLI tool end-to-end
npm test -- --grep "cli"
node dist/cli.js --help
node dist/cli.js --version
echo '{}' | node dist/cli.js --json  # pipe test
```
IF command execution > 5 seconds: add progress indicator.
WHEN exit code != 0: write to stderr, not stdout.
IF --json output is invalid JSON: treat as P1 bug.

1. **Error messages are UX.** Show what, why, and how to fix.
2. **Make defaults safe.** Destructive = confirmation. Respect NO_COLOR.
3. **Machine-readable output.** Support --json for piping.
4. **Shell completions expected.** bash, zsh, fish, PowerShell.
5. **Exit codes meaningful.** 0=success, 1=error, 2=usage.
6. **Respect the terminal.** TTY check before colors/spinners.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full CLI project assessment and setup |
| `--interactive` | Focus on interactive prompts and TUI |
| `--completion` | Shell completion generation only |

## Quality Targets
- Startup time: <200ms
- Binary size: <50MB compiled
- Target: >90% commands with --help

## HARD RULES

Never ask to continue. Loop autonomously until all commands pass tests and shell completions are generated.

1. **NEVER ship a CLI without `--help`, `--version`, and `--no-color`.**
2. **NEVER require global installation** — support npx/pipx/cargo install/go install.
3. **NEVER make interactive prompts mandatory** — support `--yes` / `--no-input` for CI.
4. **ALWAYS exit with meaningful codes** — 0 success, 1 error, 2 usage error.
5. **ALWAYS respect NO_COLOR and TTY detection.**
6. **ALWAYS generate shell completions** for at least bash and zsh.
7. **git commit BEFORE verify** — commit CLI scaffold, then run integration tests.
8. **TSV logging** — log CLI development progress:
   ```
   timestamp	command	status	tests_passing	completions	distribution
   ```

## Auto-Detection

On activation, automatically detect project context without asking:

```
AUTO-DETECT:
1. Language:
   ls package.json 2>/dev/null && echo "node"
   ls Cargo.toml 2>/dev/null && echo "rust"
```
