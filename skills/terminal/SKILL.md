---
name: terminal
description: |
  Terminal and shell productivity skill. Activates when user needs to optimize their command-line workflow, write shell scripts, manage dotfiles, configure terminal multiplexers (tmux, screen), create shell aliases and functions, or select modern CLI tools. Covers bash/zsh scripting best practices, dotfile management, tool selection (fd, ripgrep, bat, exa, jq, yq), and terminal customization. Triggers on: /godmode:terminal, "shell script", "bash script", "dotfiles", "tmux", "terminal setup", "CLI tools", "shell alias", or when the developer wants to optimize their terminal workflow.
---

# Terminal — Terminal & Shell Productivity

## When to Activate
- User invokes `/godmode:terminal`
- User says "shell script", "bash script", "zsh config", "dotfiles"
- User says "tmux", "terminal multiplexer", "terminal setup"
- User says "CLI tools", "shell alias", "shell function"
- User needs to write or debug a shell script
- User wants to optimize their development environment
- User asks about modern CLI tool alternatives
- Godmode orchestrator detects shell script issues during `/godmode:review`

## Workflow

### Step 1: Assess Terminal Context
Understand the current shell environment:

```
TERMINAL CONTEXT ASSESSMENT:
Shell:
  Current: <bash | zsh | fish | nushell>
  Version: <version>
  Config files: <.bashrc | .zshrc | .config/fish/config.fish>
  Framework: <oh-my-zsh | prezto | starship | powerlevel10k | none>
  Plugin manager: <zinit | antigen | fisher | none>

Dotfile management:
  Strategy: <git bare repo | symlinks (stow) | chezmoi | yadm | none>
  Location: <~/.dotfiles | ~/dotfiles | none>

Terminal:
  Emulator: <iTerm2 | Alacritty | kitty | WezTerm | Windows Terminal | default>
  Multiplexer: <tmux | screen | zellij | none>
  Font: <Nerd Font | monospace | default>

Modern tools installed:
  fd (find):        <yes | no>
  ripgrep (grep):   <yes | no>
  bat (cat):        <yes | no>
  eza (ls):         <yes | no>
  delta (diff):     <yes | no>
  fzf (fuzzy find): <yes | no>
  jq (JSON):        <yes | no>
  yq (YAML):        <yes | no>
  zoxide (cd):      <yes | no>
  tldr (man):       <yes | no>
  starship (prompt): <yes | no>

Productivity:
  Aliases defined: <N>
  Functions defined: <N>
  Scripts in PATH: <N>
  Completion: <enabled | partial | none>
```

### Step 2: Shell Scripting Best Practices
Write robust, portable shell scripts:

```bash
#!/usr/bin/env bash
# ============================================================
# Script: deploy.sh
# Purpose: Deploy application to target environment
# Usage: ./deploy.sh <environment> [--dry-run] [--force]
# ============================================================

# STRICT MODE — always use these four lines
set -euo pipefail
IFS=$'\n\t'

# -e: exit on error (non-zero exit code)
# -u: error on undefined variables
# -o pipefail: pipe fails if any command in pipe fails
# IFS: prevent word splitting on spaces (only newlines and tabs)
```

```
SHELL SCRIPTING RULES:
┌─────────────────────────────────────────────────────────────┐
│ Rule                                │ Example                │
├─────────────────────────────────────┼────────────────────────┤
│ Always use strict mode              │ set -euo pipefail      │
│ Quote all variables                 │ "$variable" not $var   │
│ Use [[ ]] not [ ] for tests        │ [[ -f "$file" ]]       │
│ Use $(command) not backticks        │ $(date +%Y)            │
│ Use readonly for constants          │ readonly VERSION="1.0" │
│ Use local in functions              │ local result=""        │
│ Trap for cleanup                    │ trap cleanup EXIT      │
│ Use shellcheck for linting          │ shellcheck script.sh   │
│ Use printf not echo for portability │ printf '%s\n' "$msg"   │
│ Use arrays for lists                │ files=("a" "b" "c")   │
└─────────────────────────────────────┴────────────────────────┘

SCRIPT TEMPLATE:
  #!/usr/bin/env bash
  set -euo pipefail
  IFS=$'\n\t'

  # Constants
  readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

  # Colors (only if stdout is a terminal)
  if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m'
  else
    readonly RED='' GREEN='' YELLOW='' NC=''
  fi

  # Logging
  log()   { printf "${GREEN}[INFO]${NC} %s\n" "$*"; }
  warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2; }
  error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
  die()   { error "$*"; exit 1; }

  # Usage
  usage() {
    cat <<EOF
  Usage: $SCRIPT_NAME [options] <argument>

  Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -n, --dry-run   Show what would be done

  Examples:
    $SCRIPT_NAME deploy staging
    $SCRIPT_NAME --dry-run deploy production
  EOF
  }

  # Cleanup on exit
  cleanup() {
    # Remove temp files, restore state, etc.
    rm -rf "${TMPDIR:-/tmp}/${SCRIPT_NAME}.$$"
  }
  trap cleanup EXIT

  # Argument parsing
  main() {
    local verbose=false
    local dry_run=false

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help) usage; exit 0 ;;
        -v|--verbose) verbose=true; shift ;;
        -n|--dry-run) dry_run=true; shift ;;
        --) shift; break ;;
        -*) die "Unknown option: $1" ;;
        *) break ;;
      esac
    done

    [[ $# -eq 0 ]] && { usage; exit 1; }

    # Script logic here
    log "Starting $SCRIPT_NAME..."
  }

  main "$@"

COMMON PITFALLS:
┌─────────────────────────────────┬───────────────────────────────┐
│ Bad                             │ Good                          │
├─────────────────────────────────┼───────────────────────────────┤
│ cd $dir                         │ cd "$dir" || exit 1           │
│ for f in $(ls *.txt)            │ for f in *.txt                │
│ cat file | grep pattern         │ grep pattern file             │
│ [ $var = "value" ]              │ [[ "$var" = "value" ]]        │
│ echo $var                       │ printf '%s\n' "$var"          │
│ result=`command`                │ result=$(command)             │
│ if [ $? -eq 0 ]                │ if command; then              │
│ rm -rf $DIR/*                   │ rm -rf "${DIR:?}/"*           │
└─────────────────────────────────┴───────────────────────────────┘
```

### Step 3: Dotfile Management
Set up a maintainable, portable dotfile system:

```
DOTFILE MANAGEMENT STRATEGIES:
┌─────────────────────────────────────────────────────────────┐
│ Strategy        │ Pros                 │ Cons               │
├─────────────────┼──────────────────────┼────────────────────┤
│ Git bare repo   │ Simple, no deps      │ Manual setup       │
│ GNU Stow        │ Symlink management   │ Extra dependency   │
│ chezmoi         │ Templates, secrets,  │ Learning curve     │
│                 │ multi-machine        │                    │
│ yadm            │ Git-based, encryption│ Less popular       │
│ Nix Home Manager│ Declarative, reprod. │ Steep learning     │
└─────────────────┴──────────────────────┴────────────────────┘

GIT BARE REPO (simplest, no dependencies):
  # Initial setup
  git init --bare $HOME/.dotfiles
  alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
  dotfiles config --local status.showUntrackedFiles no

  # Add files
  dotfiles add ~/.zshrc ~/.gitconfig ~/.tmux.conf
  dotfiles commit -m "initial dotfiles"
  dotfiles remote add origin git@github.com:user/dotfiles.git
  dotfiles push -u origin main

  # Clone on new machine
  git clone --bare git@github.com:user/dotfiles.git $HOME/.dotfiles
  alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
  dotfiles checkout

GNU STOW (symlink management):
  ~/dotfiles/
  ├── git/
  │   └── .gitconfig
  ├── zsh/
  │   └── .zshrc
  ├── tmux/
  │   └── .tmux.conf
  └── vim/
      └── .vimrc

  cd ~/dotfiles
  stow git zsh tmux vim    # Creates symlinks in $HOME

CHEZMOI (advanced, multi-machine):
  chezmoi init
  chezmoi add ~/.zshrc ~/.gitconfig ~/.tmux.conf
  chezmoi edit ~/.zshrc      # Edit the source, not the target
  chezmoi apply              # Apply changes to $HOME
  chezmoi cd                 # Enter the source directory

  # Templates for machine-specific config:
  # .zshrc.tmpl
  export EDITOR={{ if eq .chezmoi.hostname "work-laptop" }}"code"{{ else }}"vim"{{ end }}
```

### Step 4: Terminal Multiplexer Configuration
Set up tmux for productive development sessions:

```
TMUX ESSENTIAL CONFIGURATION (~/.tmux.conf):

  # Better prefix key (Ctrl+a instead of Ctrl+b)
  unbind C-b
  set -g prefix C-a
  bind C-a send-prefix

  # Mouse support
  set -g mouse on

  # Start windows and panes at 1, not 0
  set -g base-index 1
  setw -g pane-base-index 1

  # Renumber windows when one is closed
  set -g renumber-windows on

  # Increase scrollback buffer
  set -g history-limit 50000

  # Faster key repetition
  set -sg escape-time 0

  # True color support
  set -g default-terminal "tmux-256color"
  set -ag terminal-overrides ",xterm-256color:RGB"

  # Split panes with | and -
  bind | split-window -h -c "#{pane_current_path}"
  bind - split-window -v -c "#{pane_current_path}"
  unbind '"'
  unbind %

  # Navigate panes with vim keys
  bind h select-pane -L
  bind j select-pane -D
  bind k select-pane -U
  bind l select-pane -R

  # Resize panes with vim keys
  bind -r H resize-pane -L 5
  bind -r J resize-pane -D 5
  bind -r K resize-pane -U 5
  bind -r L resize-pane -R 5

  # Reload config
  bind r source-file ~/.tmux.conf \; display "Config reloaded"

TMUX SESSION MANAGEMENT:
┌──────────────────────────────┬──────────────────────────────┐
│ Action                       │ Key / Command                │
├──────────────────────────────┼──────────────────────────────┤
│ New session                  │ tmux new -s <name>           │
│ Attach to session            │ tmux attach -t <name>        │
│ List sessions                │ tmux ls                      │
│ Kill session                 │ tmux kill-session -t <name>  │
│ Detach                       │ prefix + d                   │
│ New window                   │ prefix + c                   │
│ Next/prev window             │ prefix + n / p               │
│ Split horizontal             │ prefix + |  (custom)         │
│ Split vertical               │ prefix + -  (custom)         │
│ Navigate panes               │ prefix + h/j/k/l (custom)   │
│ Zoom pane (toggle)           │ prefix + z                   │
│ Copy mode (scroll)           │ prefix + [                   │
└──────────────────────────────┴──────────────────────────────┘

TMUX DEVELOPMENT LAYOUT SCRIPT:
  #!/usr/bin/env bash
  SESSION="dev"
  tmux new-session -d -s $SESSION -n "editor"
  tmux send-keys -t $SESSION:editor "vim ." Enter

  tmux new-window -t $SESSION -n "server"
  tmux send-keys -t $SESSION:server "npm run dev" Enter

  tmux new-window -t $SESSION -n "shell"

  tmux select-window -t $SESSION:editor
  tmux attach -t $SESSION
```

### Step 5: Shell Aliases and Functions
Create a productive alias and function library:

```bash
# ============================================================
# ALIASES — Short, memorable, frequently used
# ============================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git (most impactful aliases)
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull --rebase'

# Modern tool replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias find='fd'
alias grep='rg'
alias diff='delta'
alias cd='z'    # zoxide

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dclean='docker system prune -af --volumes'

# Development
alias serve='python3 -m http.server 8000'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me'
alias weather='curl -s wttr.in/?format=3'

# Safety nets
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# ============================================================
# FUNCTIONS — Complex operations, argument handling
# ============================================================

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extract any archive
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Cannot extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find and kill process by port
killport() {
  local pid
  pid=$(lsof -ti :"$1" 2>/dev/null)
  if [[ -n "$pid" ]]; then
    kill -9 "$pid"
    echo "Killed process $pid on port $1"
  else
    echo "No process found on port $1"
  fi
}

# Quick HTTP server with optional port
serve() { python3 -m http.server "${1:-8000}"; }

# Git: add, commit, push in one command
acp() {
  git add -A
  git commit -m "$*"
  git push
}

# fzf-powered git branch switcher
fbr() {
  local branch
  branch=$(git branch --all | fzf --height 40% --reverse | sed 's/^[* ]*//' | sed 's|remotes/origin/||')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# fzf-powered file opener
fopen() {
  local file
  file=$(fzf --height 40% --reverse --preview 'bat --color=always {}')
  [[ -n "$file" ]] && "${EDITOR:-vim}" "$file"
}

# fzf-powered process killer
fkill() {
  local pid
  pid=$(ps aux | fzf --height 40% --reverse --header='Select process to kill' | awk '{print $2}')
  [[ -n "$pid" ]] && kill -9 "$pid"
}
```

### Step 6: Modern CLI Tool Selection
Replace legacy tools with faster, more ergonomic alternatives:

```
MODERN CLI TOOL REPLACEMENTS:
┌──────────────┬──────────────┬────────────────────────────────┐
│ Legacy       │ Modern       │ Why Switch                     │
├──────────────┼──────────────┼────────────────────────────────┤
│ find         │ fd           │ 5x faster, sane defaults,      │
│              │              │ respects .gitignore             │
│ grep         │ ripgrep (rg) │ 10x faster, recursive default, │
│              │              │ respects .gitignore             │
│ cat          │ bat          │ Syntax highlighting, line nums, │
│              │              │ git integration                 │
│ ls           │ eza          │ Icons, git status, tree view,   │
│              │              │ color by file type              │
│ diff         │ delta        │ Syntax highlighting, side-by-   │
│              │              │ side, git integration           │
│ cd           │ zoxide       │ Frecency-based, learns your     │
│              │              │ most-used directories           │
│ man          │ tldr         │ Community examples, practical   │
│              │              │ usage, not exhaustive reference │
│ curl (JSON)  │ jq           │ Parse, filter, transform JSON  │
│ curl (YAML)  │ yq           │ Parse, filter, transform YAML  │
│ top          │ htop/btop    │ Better UI, mouse support,       │
│              │              │ process tree                    │
│ du           │ dust         │ Visual directory sizes, faster  │
│ wc -l        │ tokei        │ Code statistics by language     │
│ sed          │ sd           │ Simpler syntax, no escaping     │
│ cut          │ choose       │ Human-friendly field selection  │
│ Ctrl+R       │ atuin/fzf    │ Better history search, sync     │
└──────────────┴──────────────┴────────────────────────────────┘

INSTALLATION (macOS):
  brew install fd ripgrep bat eza delta zoxide tldr jq yq \
    htop dust tokei sd choose-rust fzf atuin starship

INSTALLATION (Ubuntu/Debian):
  # Some tools need cargo or the latest repos
  sudo apt install fd-find ripgrep bat jq
  cargo install eza delta zoxide

FZF CONFIGURATION (the most impactful single tool):
  # ~/.zshrc or ~/.bashrc
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_DEFAULT_OPTS='
    --height 40%
    --reverse
    --border
    --preview "bat --color=always --line-range :200 {}"
    --bind "ctrl-d:preview-page-down,ctrl-u:preview-page-up"
  '
  # Ctrl+T: fuzzy file finder
  # Ctrl+R: fuzzy history search
  # Alt+C: fuzzy directory changer
```

### Step 7: Terminal Productivity Report

```
┌────────────────────────────────────────────────────────────┐
│  TERMINAL PRODUCTIVITY REPORT                              │
├────────────────────────────────────────────────────────────┤
│  Shell: <bash | zsh | fish>                                │
│  Framework: <oh-my-zsh | starship | none>                  │
│  Multiplexer: <tmux | zellij | none>                       │
│                                                            │
│  Dotfiles: <managed | unmanaged>                           │
│  Strategy: <bare repo | stow | chezmoi>                    │
│                                                            │
│  Modern tools:                                             │
│    Installed: <N> / 15                                     │
│    Missing: <list>                                         │
│                                                            │
│  Aliases: <N> configured                                   │
│  Functions: <N> configured                                 │
│  Scripts in PATH: <N>                                      │
│                                                            │
│  Shell scripts audited: <N>                                │
│  ShellCheck issues: <N>                                    │
│                                                            │
│  Improvements applied:                                     │
│    - <list of changes made>                                │
│                                                            │
│  Estimated time saved: <N minutes/day>                     │
└────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Commit dotfiles: `"config: shell — <N aliases, N functions, dotfile management>"`
2. Commit scripts: `"feat(scripts): <script name> — <purpose>"`
3. After terminal setup: "Terminal optimized. Use `/godmode:vscode` for IDE configuration or `/godmode:setup` for full project setup."

## Key Behaviors

1. **Strict mode is non-negotiable.** Every bash script starts with `set -euo pipefail`. No exceptions. Scripts without strict mode are ticking time bombs.
2. **Quote everything.** Unquoted variables are the most common source of shell script bugs. When in doubt, quote it. `"$var"` not `$var`.
3. **Modern tools save hours.** Replacing `find` with `fd` and `grep` with `ripgrep` saves minutes per day. Over a year, that is days of productivity.
4. **Aliases are muscle memory.** Keep aliases short (2-3 characters), memorable, and consistent. Git aliases alone save thousands of keystrokes per week.
5. **Dotfiles are infrastructure.** Treat dotfiles like code: version controlled, documented, and portable across machines.
6. **tmux is essential for remote work.** Persistent sessions survive SSH disconnects. Layouts eliminate window management. Everyone working on servers needs tmux.
7. **ShellCheck catches what humans miss.** Run ShellCheck on every shell script. It catches quoting issues, portability problems, and subtle bugs.

## Example Usage

### Setting up a new development machine
```
User: /godmode:terminal I just got a new MacBook. Set up my terminal for maximum productivity.

Terminal: Assessing current terminal state...

TERMINAL CONTEXT:
Shell: zsh (default macOS)
Framework: none
Multiplexer: none
Modern tools: 0/15 installed

Setting up terminal stack...

1. Installing modern CLI tools via Homebrew:
   fd, ripgrep, bat, eza, delta, zoxide, fzf, jq, yq, starship

2. Configuring shell:
   - Starship prompt (fast, cross-shell, informative)
   - fzf key bindings (Ctrl+T, Ctrl+R, Alt+C)
   - zoxide for smart directory navigation
   - 25 git aliases, 10 utility aliases
   - 8 shell functions (mkcd, extract, killport, etc.)

3. Setting up tmux:
   - Vim-style navigation
   - Mouse support
   - Development layout script

4. Initializing dotfile management:
   - Git bare repo at ~/.dotfiles
   - Tracking .zshrc, .gitconfig, .tmux.conf

Estimated time saved: 15-20 minutes per day
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full terminal assessment and optimization |
| `--shell` | Shell configuration and scripting focus |
| `--dotfiles` | Set up dotfile management |
| `--tmux` | tmux configuration and session management |
| `--aliases` | Alias and function library setup |
| `--tools` | Install and configure modern CLI tools |
| `--script <name>` | Create a new shell script with best practices |
| `--audit` | Audit existing shell scripts with ShellCheck |
| `--fzf` | fzf integration and fuzzy finder setup |
| `--prompt` | Configure shell prompt (starship, p10k) |
| `--completions` | Set up tab completions for all tools |

## Anti-Patterns

- **Do NOT write shell scripts without strict mode.** `set -euo pipefail` catches errors that would otherwise silently corrupt data or produce wrong results.
- **Do NOT leave variables unquoted.** `rm -rf $DIR/*` with an empty `$DIR` becomes `rm -rf /*`. Always quote: `"${DIR:?}/"*`.
- **Do NOT use backticks for command substitution.** Use `$(command)` instead. Backticks don't nest, are hard to read, and are deprecated.
- **Do NOT accumulate shell history without search.** Install fzf or atuin for fuzzy history search. Pressing up-arrow 50 times is not a workflow.
- **Do NOT maintain dotfiles manually across machines.** Use a version-controlled dotfile strategy. Manual syncing leads to drift and lost configurations.
- **Do NOT alias commands that change destructive behavior.** `alias rm='rm -rf'` is dangerous. Use `-i` for safety, never `-rf` by default.
- **Do NOT ignore ShellCheck warnings.** Every SC warning has a rationale. Suppressing warnings without understanding them creates fragile scripts.
- **Do NOT use `eval` with user input.** `eval` executes arbitrary code. It is almost never necessary and is a security vulnerability.
