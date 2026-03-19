# /godmode:vscode

IDE and editor configuration skill for optimizing the development environment. Covers VS Code settings, extension recommendations by project type, debug configurations, tasks, workspace settings, multi-root workspaces, and Vim/Neovim/JetBrains IDE configuration.

## Usage

```
/godmode:vscode                           # Full IDE assessment and configuration
/godmode:vscode --settings                # Optimize VS Code settings.json
/godmode:vscode --extensions              # Recommend and configure extensions
/godmode:vscode --debug                   # Set up debug/launch configurations
/godmode:vscode --tasks                   # Configure build and test tasks
/godmode:vscode --workspace               # Set up multi-root workspace
/godmode:vscode --neovim                  # Neovim/Vim configuration
/godmode:vscode --jetbrains               # JetBrains IDE configuration
/godmode:vscode --editorconfig            # Create .editorconfig for cross-editor
/godmode:vscode --snippets                # Create project-specific code snippets
/godmode:vscode --keybindings             # Optimize keyboard shortcuts
/godmode:vscode --performance             # Diagnose and fix VS Code performance
```

## What It Does

1. Assesses project context (language, framework, current IDE state)
2. Configures VS Code settings for productivity and performance
3. Recommends extensions based on project type (TypeScript, Python, Go, Rust, etc.)
4. Sets up debug/launch configurations for the project's framework
5. Creates task configurations for build, test, lint, and Docker workflows
6. Configures multi-root workspaces for monorepos
7. Provides Neovim and JetBrains IDE configuration guidance
8. Creates .editorconfig for cross-editor formatting consistency

## Output
- .vscode/settings.json (project-level settings)
- .vscode/launch.json (debug configurations)
- .vscode/tasks.json (build and test tasks)
- .vscode/extensions.json (recommended extensions)
- .editorconfig (cross-editor formatting)
- Configuration commit: `"config(ide): VS Code — settings, debug, tasks, extensions"`

## Next Step
After IDE setup: `/godmode:build` to start coding, or `/godmode:terminal` for shell optimization.

## Examples

```
/godmode:vscode                           # Full IDE setup for current project
/godmode:vscode --debug                   # Set up debugging for Next.js + Jest
/godmode:vscode --extensions              # Get extension recommendations
/godmode:vscode --workspace               # Configure monorepo multi-root workspace
/godmode:vscode --neovim                  # Set up Neovim with LSP and treesitter
```
