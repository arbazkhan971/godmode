---
name: vscode
description: |
  IDE and editor configuration skill. Activates when user needs to optimize VS Code settings, select extensions by project type, configure debug and launch configurations, set up tasks, manage workspace settings and multi-root workspaces, or configure Vim/Neovim/JetBrains IDEs. Triggers on: /godmode:vscode, "VS Code settings", "editor config", "debug configuration", "launch.json", "IDE setup", "extensions", "Neovim config", "JetBrains", or when the developer wants to optimize their editor experience.
---

# VS Code — IDE & Editor Configuration

## When to Activate
- User invokes `/godmode:vscode`
- User says "VS Code settings", "editor config", "IDE setup"
- User says "debug configuration", "launch.json", "tasks.json"
- User says "extensions", "workspace settings", "multi-root workspace"
- User says "Neovim config", "JetBrains IDE", "Vim setup"
- User needs to set up debugging for a specific framework
- User wants to optimize editor performance
- Godmode orchestrator detects missing IDE configuration during `/godmode:setup`

## Workflow

### Step 1: Assess IDE Context
Understand the project and current editor state:

```
IDE CONTEXT ASSESSMENT:
Project:
  Language(s): <TypeScript | Python | Go | Rust | Java | multi-language>
  Framework: <React | Next.js | Django | Spring | etc.>
  Build system: <npm | pip | gradle | cargo | make>
  Monorepo: <yes (N packages) | no>
  Test framework: <Jest | pytest | go test | etc.>

Editor:
  Primary IDE: <VS Code | Neovim | JetBrains | Vim | Emacs>
  Version: <version>
  Extensions installed: <N>
  Settings scope: <user | workspace | both>
  .vscode/ checked in: <yes | no>

Current configuration:
  settings.json: <exists | missing>
  launch.json: <exists | missing>
  tasks.json: <exists | missing>
  extensions.json: <exists | missing>
  .editorconfig: <exists | missing>

Team:
  Shared settings: <yes | no>
  Formatter: <Prettier | Black | gofmt | rustfmt | none>
  Linter: <ESLint | pylint | golangci-lint | clippy | none>
  Formatting on save: <enabled | disabled>
```

### Step 2: VS Code Settings Optimization
Configure settings for productivity and performance:

```jsonc
// .vscode/settings.json — Project-level settings
{
  // ============================================================
  // Editor: Core editing experience
  // ============================================================
  "editor.fontSize": 14,
  "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "editor.fontLigatures": true,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.wordWrap": "off",
  "editor.minimap.enabled": false,           // Saves horizontal space
  "editor.renderWhitespace": "boundary",     // Show leading/trailing
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.stickyScroll.enabled": true,       // Sticky function headers
  "editor.inlineSuggest.enabled": true,      // AI completions
  "editor.linkedEditing": true,              // Rename HTML tags together

  // ============================================================
  // Formatting: Consistent code style
  // ============================================================
  "editor.formatOnSave": true,
  "editor.formatOnPaste": false,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },

  // Language-specific formatters
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.tabSize": 4
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go"
  },
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer"
  },

  // ============================================================
  // Files: Exclude noise, auto-save
  // ============================================================
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    "**/.next": true,
    "**/dist": true,
    "**/__pycache__": true,
    "**/.pytest_cache": true,
    "**/coverage": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.next": true,
    "**/coverage": true,
    "**/*.min.js": true,
    "**/package-lock.json": true
  },

  // ============================================================
  // Terminal: Integrated terminal
  // ============================================================
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.scrollback": 10000,
  "terminal.integrated.defaultProfile.osx": "zsh",

  // ============================================================
  // Performance: Keep VS Code fast
  // ============================================================
  "typescript.tsserver.maxTsServerMemory": 4096,
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true,
    "**/dist/**": true,
    "**/.next/**": true
  }
}
```

```
VS CODE PERFORMANCE OPTIMIZATION:
┌─────────────────────────────────────────────────────────────┐
│ Setting                          │ Impact                    │
├──────────────────────────────────┼───────────────────────────┤
│ Disable minimap                  │ Reduces rendering load    │
│ files.watcherExclude             │ Reduces file system watch │
│ search.exclude                   │ Faster search results     │
│ files.exclude                    │ Cleaner explorer panel    │
│ Limit extensions to workspace    │ Reduces startup time      │
│ Disable unused language servers  │ Reduces memory usage      │
│ typescript.tsserver.maxMemory    │ Prevents OOM on large TS  │
│ telemetry.telemetryLevel: off    │ Reduces background IO     │
└──────────────────────────────────┴───────────────────────────┘
```

### Step 3: Extension Recommendations by Project Type
Select extensions based on project needs:

```
EXTENSION RECOMMENDATIONS:
┌─────────────────────────────────────────────────────────────┐
│ Category: Universal (every project)                         │
├─────────────────────────────────────────────────────────────┤
│ GitLens                    │ Git blame, history, comparison  │
│ Error Lens                 │ Inline error display            │
│ EditorConfig               │ Cross-editor settings           │
│ Todo Tree                  │ Track TODO/FIXME comments       │
│ Path Intellisense          │ File path autocompletion        │
│ Better Comments            │ Color-coded comment types       │
└────────────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Category: TypeScript / JavaScript                           │
├─────────────────────────────────────────────────────────────┤
│ ESLint                     │ Linting with auto-fix           │
│ Prettier                   │ Code formatting                 │
│ TypeScript Importer        │ Auto-import suggestions         │
│ Pretty TypeScript Errors   │ Human-readable TS errors        │
│ Console Ninja              │ Inline console.log output       │
└────────────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Category: React / Next.js                                   │
├─────────────────────────────────────────────────────────────┤
│ ES7+ React Snippets        │ Component/hook snippets         │
│ Tailwind CSS IntelliSense  │ Tailwind class autocompletion   │
│ Auto Rename Tag            │ Rename HTML/JSX tags together   │
│ CSS Modules                │ CSS module autocompletion       │
└────────────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Category: Python                                            │
├─────────────────────────────────────────────────────────────┤
│ Python (Microsoft)         │ Language support, debugging     │
│ Ruff                       │ Fast linting and formatting     │
│ Python Test Explorer       │ Test discovery and running      │
│ Jupyter                    │ Notebook support                │
│ autoDocstring              │ Docstring generation            │
└────────────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Category: Go                                                │
├─────────────────────────────────────────────────────────────┤
│ Go (official)              │ Full language support           │
│ Go Test Explorer           │ Test discovery and running      │
└────────────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Category: Rust                                              │
├─────────────────────────────────────────────────────────────┤
│ rust-analyzer              │ Full language support           │
│ crates                     │ Crate version management        │
│ Even Better TOML           │ TOML file support               │
│ CodeLLDB                   │ Native debugging                │
└────────────────────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Category: Docker / DevOps                                   │
├─────────────────────────────────────────────────────────────┤
│ Docker                     │ Dockerfile, Compose support     │
│ Kubernetes                 │ K8s manifest support            │
│ YAML                       │ YAML language support           │
│ HashiCorp Terraform        │ Terraform HCL support           │
│ Remote - SSH               │ Remote development              │
│ Dev Containers             │ Container-based development     │
└────────────────────────────┴─────────────────────────────────┘
```

```jsonc
// .vscode/extensions.json — Recommended extensions for the team
{
  "recommendations": [
    // Universal
    "eamodio.gitlens",
    "usernamehw.errorlens",
    "editorconfig.editorconfig",
    "gruntfuggly.todo-tree",
    // TypeScript
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    // React
    "bradlc.vscode-tailwindcss",
    "formulahendry.auto-rename-tag"
  ],
  "unwantedRecommendations": []
}
```

### Step 4: Debug Configuration
Set up debugging for common frameworks:

```jsonc
// .vscode/launch.json — Debug configurations
{
  "version": "0.2.0",
  "configurations": [
    // ============================================================
    // Node.js / TypeScript
    // ============================================================
    {
      "name": "Debug Server",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/src/index.ts",
      "preLaunchTask": "npm: build",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "env": {
        "NODE_ENV": "development",
        "PORT": "3000"
      },
      "console": "integratedTerminal"
    },
    {
      "name": "Debug Current File",
      "type": "node",
      "request": "launch",
      "program": "${file}",
      "sourceMaps": true,
      "console": "integratedTerminal"
    },
    {
      "name": "Attach to Process",
      "type": "node",
      "request": "attach",
      "port": 9229,
      "restart": true,
      "sourceMaps": true
    },
    {
      "name": "Debug Jest Tests",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": [
        "${relativeFile}",
        "--no-coverage",
        "--runInBand"
      ],
      "console": "integratedTerminal"
    },

    // ============================================================
    // Next.js
    // ============================================================
    {
      "name": "Debug Next.js (Server)",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/next",
      "runtimeArgs": ["dev"],
      "env": { "NODE_OPTIONS": "--inspect" },
      "console": "integratedTerminal"
    },
    {
      "name": "Debug Next.js (Client)",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000"
    },

    // ============================================================
    // Python
    // ============================================================
    {
      "name": "Debug Python File",
      "type": "debugpy",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "justMyCode": false
    },
    {
      "name": "Debug Django",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/manage.py",
      "args": ["runserver", "0.0.0.0:8000", "--noreload"],
      "django": true,
      "console": "integratedTerminal"
    },
    {
      "name": "Debug pytest",
      "type": "debugpy",
      "request": "launch",
      "module": "pytest",
      "args": ["${file}", "-v", "--no-header"],
      "console": "integratedTerminal"
    },

    // ============================================================
    // Go
    // ============================================================
    {
      "name": "Debug Go",
      "type": "go",
      "request": "launch",
      "mode": "auto",
      "program": "${workspaceFolder}/cmd/server/main.go",
      "env": { "ENV": "development" }
    },
    {
      "name": "Debug Go Test",
      "type": "go",
      "request": "launch",
      "mode": "test",
      "program": "${fileDirname}"
    }
  ],

  // ============================================================
  // Compound configurations (run multiple debuggers)
  // ============================================================
  "compounds": [
    {
      "name": "Full Stack (Server + Client)",
      "configurations": ["Debug Next.js (Server)", "Debug Next.js (Client)"]
    }
  ]
}
```

### Step 5: Tasks and Build Configuration
Automate common operations:

```jsonc
// .vscode/tasks.json — Task automation
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build",
      "type": "npm",
      "script": "build",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": ["$tsc"]
    },
    {
      "label": "Test",
      "type": "npm",
      "script": "test",
      "group": {
        "kind": "test",
        "isDefault": true
      },
      "problemMatcher": []
    },
    {
      "label": "Lint",
      "type": "npm",
      "script": "lint",
      "problemMatcher": ["$eslint-compact"]
    },
    {
      "label": "Type Check",
      "type": "npm",
      "script": "typecheck",
      "problemMatcher": ["$tsc-watch"]
    },
    {
      "label": "Docker Build",
      "type": "shell",
      "command": "docker build -t ${input:imageName} .",
      "problemMatcher": []
    },
    {
      "label": "Docker Compose Up",
      "type": "shell",
      "command": "docker compose up -d",
      "problemMatcher": []
    },
    {
      "label": "Docker Compose Down",
      "type": "shell",
      "command": "docker compose down",
      "problemMatcher": []
    }
  ],
  "inputs": [
    {
      "id": "imageName",
      "type": "promptString",
      "description": "Docker image name:tag",
      "default": "myapp:latest"
    }
  ]
}
```

```
TASK KEYBOARD SHORTCUTS:
┌──────────────────────────┬───────────────────────────────────┐
│ Action                   │ Shortcut                          │
├──────────────────────────┼───────────────────────────────────┤
│ Run Build Task           │ Cmd+Shift+B (Ctrl+Shift+B)       │
│ Run Test Task            │ Cmd+Shift+T (custom)              │
│ Run Any Task             │ Cmd+Shift+P > "Run Task"          │
│ Rerun Last Task          │ Cmd+Shift+P > "Rerun Last Task"   │
│ Toggle Terminal          │ Ctrl+` (backtick)                 │
│ New Terminal             │ Ctrl+Shift+` (backtick)           │
└──────────────────────────┴───────────────────────────────────┘
```

### Step 6: Workspace and Multi-Root Configuration
Set up workspaces for monorepos and multi-project setups:

```jsonc
// myproject.code-workspace — Multi-root workspace
{
  "folders": [
    {
      "name": "Frontend",
      "path": "./packages/web"
    },
    {
      "name": "Backend API",
      "path": "./packages/api"
    },
    {
      "name": "Shared Library",
      "path": "./packages/shared"
    },
    {
      "name": "Infrastructure",
      "path": "./infra"
    },
    {
      "name": "Root",
      "path": "."
    }
  ],
  "settings": {
    // Workspace-wide settings override user settings
    "typescript.tsdk": "node_modules/typescript/lib",
    "editor.formatOnSave": true
  },
  "extensions": {
    "recommendations": [
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode"
    ]
  }
}
```

```
WORKSPACE STRATEGY:
┌─────────────────────────────────────────────────────────────┐
│ Strategy            │ When to Use                            │
├─────────────────────┼────────────────────────────────────────┤
│ Single folder       │ Simple projects, single language       │
│ Multi-root workspace│ Monorepos, microservices, full-stack   │
│ Remote SSH          │ Development on powerful remote machine │
│ Dev Containers      │ Reproducible environments, onboarding  │
│ GitHub Codespaces   │ Zero-setup cloud development           │
└─────────────────────┴────────────────────────────────────────┘

SETTINGS PRECEDENCE (lowest to highest):
  1. Default settings (VS Code built-in)
  2. User settings (~/.config/Code/User/settings.json)
  3. Workspace settings (.code-workspace file)
  4. Folder settings (.vscode/settings.json)

WHAT TO CHECK INTO .vscode/:
  settings.json       YES — Project-specific settings
  extensions.json     YES — Recommended extensions
  launch.json         YES — Debug configurations
  tasks.json          YES — Build/test tasks
  *.code-snippets     YES — Project-specific snippets

WHAT NOT TO CHECK INTO .vscode/:
  *.code-workspace    MAYBE — Only for multi-root setups
  state.vscdb         NO — Editor state
  workspaceStorage/   NO — Cached data
```

### Step 7: Vim/Neovim and JetBrains Configuration
Alternative editor setups:

```
NEOVIM CONFIGURATION (modern Lua-based):
┌─────────────────────────────────────────────────────────────┐
│ Component          │ Plugin / Tool                           │
├────────────────────┼─────────────────────────────────────────┤
│ Plugin manager     │ lazy.nvim                               │
│ LSP                │ nvim-lspconfig + mason.nvim             │
│ Completion         │ nvim-cmp + cmp-nvim-lsp                 │
│ Syntax             │ nvim-treesitter                         │
│ File explorer      │ neo-tree.nvim or oil.nvim               │
│ Fuzzy finder       │ telescope.nvim                          │
│ Git integration    │ gitsigns.nvim + fugitive.vim            │
│ Status line        │ lualine.nvim                            │
│ Theme              │ catppuccin or tokyonight                │
│ Debugging          │ nvim-dap + nvim-dap-ui                  │
│ Formatting         │ conform.nvim                            │
│ Linting            │ nvim-lint                               │
│ Snippets           │ LuaSnip + friendly-snippets             │
│ AI completion      │ copilot.lua or codeium.nvim             │
└────────────────────┴─────────────────────────────────────────┘

NEOVIM DIRECTORY STRUCTURE:
  ~/.config/nvim/
  ├── init.lua                 # Entry point
  ├── lua/
  │   ├── config/
  │   │   ├── lazy.lua         # Plugin manager setup
  │   │   ├── keymaps.lua      # Key mappings
  │   │   └── options.lua      # Editor options
  │   └── plugins/
  │       ├── lsp.lua          # LSP configuration
  │       ├── cmp.lua          # Autocompletion
  │       ├── treesitter.lua   # Syntax highlighting
  │       ├── telescope.lua    # Fuzzy finder
  │       └── git.lua          # Git integration
  └── after/
      └── ftplugin/            # Filetype-specific settings

JETBRAINS IDE OPTIMIZATION:
┌─────────────────────────────────────────────────────────────┐
│ Setting                      │ Impact                        │
├──────────────────────────────┼───────────────────────────────┤
│ Increase heap memory         │ -Xmx4096m in vmoptions       │
│ Enable new UI                │ Modern, cleaner interface     │
│ Disable unused plugins       │ Faster startup, less memory   │
│ Index only project files     │ Faster indexing               │
│ Enable save on focus lost    │ Auto-save like VS Code        │
│ Configure code style         │ Team consistency              │
│ Set up run configurations    │ One-click run/debug           │
│ Live templates               │ Custom code snippets          │
│ File watchers                │ Auto-format on save           │
│ Shared run configs (.idea/)  │ Team shares debug setups      │
└──────────────────────────────┴───────────────────────────────┘

.editorconfig (CROSS-EDITOR CONSISTENCY):
  # .editorconfig — works in VS Code, JetBrains, Vim, etc.
  root = true

  [*]
  indent_style = space
  indent_size = 2
  end_of_line = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true

  [*.py]
  indent_size = 4

  [*.go]
  indent_style = tab

  [*.md]
  trim_trailing_whitespace = false

  [Makefile]
  indent_style = tab
```

### Step 8: IDE Configuration Report

```
┌────────────────────────────────────────────────────────────┐
│  IDE CONFIGURATION REPORT                                  │
├────────────────────────────────────────────────────────────┤
│  Editor: <VS Code | Neovim | JetBrains>                   │
│  Version: <version>                                        │
│                                                            │
│  Settings configured:                                      │
│    .vscode/settings.json: <created | updated>              │
│    .vscode/launch.json: <created | updated>                │
│    .vscode/tasks.json: <created | updated>                 │
│    .vscode/extensions.json: <created | updated>            │
│    .editorconfig: <created | updated>                      │
│                                                            │
│  Extensions:                                               │
│    Recommended: <N>                                        │
│    Installed: <N>                                          │
│    Missing: <list>                                         │
│                                                            │
│  Debug configurations: <N>                                 │
│    - <list of debug targets>                               │
│                                                            │
│  Tasks: <N>                                                │
│    - <list of task labels>                                 │
│                                                            │
│  Formatting: <Prettier | Ruff | gofmt | rustfmt>          │
│  Linting: <ESLint | Ruff | golangci-lint | clippy>        │
│  Format on save: <enabled | disabled>                      │
│                                                            │
│  Ready for: /godmode:build or /godmode:setup               │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Commit IDE config: `"config(ide): VS Code — settings, debug, tasks, extensions"`
2. Commit .editorconfig: `"config: editorconfig — cross-editor formatting rules"`
3. After IDE setup: "IDE configured. Use `/godmode:build` to start coding or `/godmode:terminal` for shell optimization."

## Key Behaviors

1. **Project settings over user settings.** Always configure at the workspace level (`.vscode/`) so the team shares the same experience. User settings are personal preference.
2. **Format on save is non-negotiable.** Formatting debates end when the formatter runs automatically. Configure once, forget forever.
3. **Debug configurations unlock productivity.** Console.log debugging is 10x slower than breakpoint debugging. Set up launch.json for every project.
4. **Extensions should be minimal.** More extensions mean slower startup and more conflicts. Recommend only what the project needs.
5. **Check in .vscode/ to version control.** Settings, launch, tasks, and extensions files belong in the repo. The whole team benefits from a consistent setup.
6. **.editorconfig for cross-editor teams.** When team members use different editors, .editorconfig ensures basic formatting consistency everywhere.
7. **Keyboard shortcuts are force multipliers.** Learn 10 shortcuts and save hours per week. Focus on navigation, refactoring, and debugging shortcuts.

## Example Usage

### Setting up VS Code for a Next.js project
```
User: /godmode:vscode We're starting a Next.js project with TypeScript and Tailwind.

VS Code: Assessing project context...

IDE CONTEXT:
Language: TypeScript
Framework: Next.js + Tailwind CSS
Test: Jest + React Testing Library

Configuring VS Code...

1. Settings (.vscode/settings.json):
   - Prettier as default formatter
   - ESLint auto-fix on save
   - TypeScript strict mode
   - Tailwind CSS class sorting
   - File exclusions for .next/, node_modules/

2. Extensions (.vscode/extensions.json):
   - ESLint, Prettier, Tailwind CSS IntelliSense
   - ES7+ React Snippets, Auto Rename Tag
   - GitLens, Error Lens, Todo Tree

3. Debug configurations (.vscode/launch.json):
   - Next.js server-side debugging
   - Next.js client-side debugging (Chrome)
   - Jest test debugging
   - Full-stack compound config

4. Tasks (.vscode/tasks.json):
   - Build, test, lint, type-check
   - Docker compose up/down

5. .editorconfig for cross-editor consistency

All files ready to commit.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full IDE assessment and configuration |
| `--settings` | Optimize VS Code settings.json |
| `--extensions` | Recommend and configure extensions |
| `--debug` | Set up debug/launch configurations |
| `--tasks` | Configure build and test tasks |
| `--workspace` | Set up multi-root workspace |
| `--neovim` | Neovim/Vim configuration |
| `--jetbrains` | JetBrains IDE configuration |
| `--editorconfig` | Create .editorconfig for cross-editor |
| `--snippets` | Create project-specific code snippets |
| `--keybindings` | Optimize keyboard shortcuts |
| `--performance` | Diagnose and fix VS Code performance |

## HARD RULES

1. **NEVER configure user-level settings for project-specific needs.** Use workspace settings (`.vscode/`) so every team member gets the same experience.
2. **NEVER leave `.vscode/` in `.gitignore`.** Settings, launch, tasks, and extension recommendations are project configuration and belong in version control.
3. **ALWAYS set up debug configurations.** Console.log is not a debugging strategy. Spend 10 minutes on launch.json, save hours over the project lifetime.
4. **ALWAYS enable format-on-save.** Pick one formatter (Prettier, Ruff, gofmt), configure it, and never manually format code again.
5. **NEVER use deprecated extensions.** TSLint (use ESLint), Vetur (use Vue Official), etc. Check extension status before recommending.
6. **ALWAYS use workspace extension recommendations** (`extensions.json`) so project-specific extensions are installed only when needed.
7. **ALWAYS configure multi-root workspaces for monorepos** with per-folder settings to prevent configuration conflicts.
8. **NEVER ignore keyboard shortcuts.** Reaching for the mouse for common actions costs minutes per hour. Configure keybindings for the most common operations.

## Anti-Patterns

- **Do NOT configure user-level settings for project-specific needs.** Workspace settings (`.vscode/`) ensure every team member has the same experience without overriding personal preferences.
- **Do NOT install extensions globally when they are project-specific.** Use workspace extension recommendations so they are installed only when needed.
- **Do NOT skip debug configurations.** Console.log is not a debugging strategy. Spend 10 minutes setting up launch.json, save hours over the project lifetime.
- **Do NOT fight the formatter.** Pick one (Prettier, Ruff, gofmt), configure it, enable format-on-save, and never manually format code again.
- **Do NOT leave .vscode/ in .gitignore.** Settings, launch, tasks, and extensions files are project configuration. They belong in version control.
- **Do NOT use deprecated extensions.** TSLint (use ESLint), Vetur (use Volar/Vue Official), Python (ms-python.python is current). Check extension status before installing.
- **Do NOT ignore keyboard shortcuts.** Reaching for the mouse for common actions (rename, go to definition, find references) costs minutes per hour.
- **Do NOT use VS Code without a workspace settings strategy in monorepos.** Multi-root workspaces with per-folder settings prevent configuration conflicts between packages.
