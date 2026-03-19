# /godmode:cli

CLI tool development — argument parsing design (Commander, Clap, Cobra, Click), interactive prompts and TUI frameworks (Ink, Ratatui, Bubbletea, Rich), configuration management (config files, env vars, XDG), shell completion generation, and distribution via package managers (npm, Homebrew, cargo, pip).

## Usage

```
/godmode:cli                               # Full CLI project assessment
/godmode:cli --interactive                 # Interactive prompts and TUI focus
/godmode:cli --completion                  # Shell completion generation
/godmode:cli --distribute                  # Distribution and packaging setup
/godmode:cli --language rust               # Use Rust with Clap
/godmode:cli --parser cobra                # Use Go with Cobra
/godmode:cli --tui                         # Full TUI application setup
```

## What It Does

1. Assesses CLI project requirements (language, complexity, distribution targets)
2. Sets up CLI architecture with chosen parser:
   - TypeScript: Commander/yargs with subcommands and flag parsing
   - Rust: Clap derive API with typed arguments
   - Go: Cobra with persistent flags and subcommands
   - Python: Click/Typer with decorators and type hints
3. Designs argument interface (commands, subcommands, flags, positional args)
4. Implements interactive features:
   - Prompts (text, select, multi-select, confirm, password)
   - Progress indicators (spinners, progress bars, multi-step)
   - Table output, colored text, terminal-aware formatting
5. Configures configuration management:
   - Config file (TOML/YAML/JSON) with XDG compliance
   - Environment variable mapping with TOOL_ prefix
   - Flag precedence chain (CLI > env > config > defaults)
6. Generates shell completions (bash, zsh, fish, PowerShell)
7. Sets up distribution (npm publish, Homebrew formula, cargo publish, pip/pipx)

## Output
- CLI scaffold with argument parsing and subcommand structure
- Interactive prompt and progress indicator components
- Configuration system with file, env, and flag support
- Shell completion scripts for all major shells
- Commit: `"cli: <language> — <description>"`

## Next Step
After scaffold: `/godmode:build` to implement commands.
After building: `/godmode:test` to add CLI integration tests.
When ready: `/godmode:ship` to publish to package managers.

## Examples

```
/godmode:cli                               # Full project assessment and setup
/godmode:cli --language rust               # Rust CLI with Clap
/godmode:cli --tui                         # Full TUI application
/godmode:cli --completion                  # Generate shell completions
/godmode:cli --distribute                  # Package manager distribution
```
