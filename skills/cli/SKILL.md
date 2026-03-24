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

1. **Error messages are UX.** A CLI that prints a stack trace on invalid input is hostile. Show what went wrong, why, and how to fix it. Include the correct usage example.
2. **Make defaults safe.** Destructive commands require confirmation. Verbose mode is opt-in. Color respects NO_COLOR and terminal capability.
3. **Machine-readable output is a feature.** Always support --json for output that other tools may consume. Human-readable is the default; machine-readable is the option.
4. **Shell completions are expected.** Users who install CLIs via package managers expect tab completion to work. Generate completions for bash, zsh, fish, and PowerShell.
5. **Exit codes are meaningful.** 0 = success, 1 = general error, 2 = usage error. Document non-zero exit codes. Scripts depend on them.
6. **Respect the terminal.** Check if stdout is a TTY before using colors, spinners, or interactive prompts. Pipe-friendly output when not a TTY.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full CLI project assessment and setup |
| `--interactive` | Focus on interactive prompts and TUI |
| `--completion` | Shell completion generation only |

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
   ls go.mod 2>/dev/null && echo "go"
   ls pyproject.toml setup.py 2>/dev/null && echo "python"

2. Existing CLI framework:
   grep -r "commander\|yargs\|meow\|oclif" package.json 2>/dev/null  # Node
   grep "clap\|argh" Cargo.toml 2>/dev/null  # Rust
   grep "cobra\|urfave" go.mod 2>/dev/null  # Go
   grep "click\|typer\|argparse" pyproject.toml requirements.txt 2>/dev/null  # Python

3. Existing bin/entry point:
   grep '"bin"' package.json 2>/dev/null
```

## Keep/Discard Discipline
```
After EACH command implementation or output format change:
  1. MEASURE: Run integration tests — does the command produce correct output, exit codes, and stderr/stdout separation?
  2. COMPARE: Does the change improve UX without breaking existing callers (scripts, CI)?
  3. DECIDE:
     - KEEP if: tests pass AND --json output is valid AND exit codes are correct AND --help is present
     - DISCARD if: tests fail OR backwards-incompatible change OR output breaks pipe usage
  4. COMMIT kept changes. Revert discarded changes before implementing the next command.

Never ship a command that breaks existing scripts relying on its output format.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All planned commands implemented with passing tests and help text
  - Shell completions generated for bash and zsh
  - Distribution configured for at least one package manager
  - User explicitly requests stop

DO NOT STOP just because:
  - man pages are not yet generated (ship first, add man pages later)
  - Only one distribution channel is configured (one is enough to ship)
```

## Iteration Protocol
Loop: REVIEW state -> IMPLEMENT next command with tests -> TEST (unit + integration) -> VERIFY (exit codes, stderr/stdout). If tests pass: commit, next command. If fail: fix (max 3 attempts). Stop when all commands implemented, tests pass, distribution configured.

## TSV Logging
Append to `.godmode/cli-results.tsv`:
```
STEP	COMMAND	LANGUAGE	STATUS	DETAILS
```
Print: `CLI: {tool_name}, language: {lang}, commands: {N}. Parser: {library}. Distribution: {methods}. Tests: {pass}/{total}. Completions: {yes/no}.`

## Success Criteria
1. All planned commands work with correct argument parsing (required args, optional flags, defaults).
2. `--help` output present for every command and subcommand with descriptions and examples.
3. Exit codes are correct: 0 for success, 1 for user error, 2 for system error.
4. stdout contains only program output (machine-parseable). stderr contains errors, warnings, and progress.
5. `--json` flag (or equivalent) produces valid JSON for all list/show commands.
6. `NO_COLOR` environment variable is respected. `--no-color` flag works. Colors only when isatty.
7. Non-interactive mode works (`--yes` or equivalent skips all prompts) for CI/CD usage.
8. Tests cover: argument parsing, happy path output, error conditions, exit codes.

## Error Recovery
| Failure | Action |
|--|--|
| Parser library not detected | Check package manager files for known parsers. If none, ask user preference. |
| Command fails silently | All error paths: write to stderr + non-zero exit code. |
| Output encoding issues | Force UTF-8. Test with pipe: `tool list | cat` must not break. |

