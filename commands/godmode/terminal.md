# /godmode:terminal

Terminal and shell productivity skill for optimizing command-line workflows. Covers shell scripting best practices (bash, zsh), dotfile management, terminal multiplexers (tmux, screen), shell aliases and functions, and modern CLI tool selection (fd, ripgrep, bat, eza, jq, yq, fzf, zoxide).

## Usage

```
/godmode:terminal                         # Full terminal assessment and optimization
/godmode:terminal --shell                 # Shell configuration and scripting focus
/godmode:terminal --dotfiles              # Set up dotfile management
/godmode:terminal --tmux                  # tmux configuration and session management
/godmode:terminal --aliases               # Alias and function library setup
/godmode:terminal --tools                 # Install and configure modern CLI tools
/godmode:terminal --script <name>         # Create a new shell script with best practices
/godmode:terminal --audit                 # Audit existing shell scripts with ShellCheck
/godmode:terminal --fzf                   # fzf integration and fuzzy finder setup
/godmode:terminal --prompt                # Configure shell prompt (starship, p10k)
/godmode:terminal --completions           # Set up tab completions for all tools
```

## What It Does

1. Assesses current shell environment (shell, tools, dotfiles, multiplexer)
2. Applies shell scripting best practices (strict mode, quoting, error handling)
3. Sets up dotfile management (git bare repo, stow, or chezmoi)
4. Configures tmux with development-friendly layout and key bindings
5. Creates alias and function library for common operations
6. Installs and configures modern CLI tool replacements
7. Sets up fzf for fuzzy file finding, history search, and directory navigation
8. Produces a terminal productivity report with estimated time savings

## Output
- Shell configuration files (.zshrc, .bashrc)
- tmux configuration (.tmux.conf)
- Shell scripts with best practices
- Dotfile management setup
- Configuration commit: `"config: shell — <N aliases, N functions, dotfile management>"`

## Next Step
After terminal setup: `/godmode:vscode` for IDE configuration, or `/godmode:setup` for full project setup.

## Examples

```
/godmode:terminal                         # Full terminal optimization
/godmode:terminal --tools                 # Install fd, ripgrep, bat, eza, fzf
/godmode:terminal --tmux                  # Set up tmux for development
/godmode:terminal --script deploy         # Create a deploy.sh with best practices
/godmode:terminal --audit                 # ShellCheck all scripts in the project
```
