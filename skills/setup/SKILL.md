---
name: setup
description: >
  Configuration wizard. Auto-detects project stack,
  validates commands, saves .godmode/config.yaml.
---

# Setup -- Configuration Wizard

## Activate When
- `/godmode:setup`, first-time use (no .godmode/)
- A skill needs test/lint/build cmd but none exists
- "configure godmode", "set up", "initialize"

## Workflow

### Step 1: Detect Stack
```bash
# Check manifests (most specific first)
ls package.json pyproject.toml Cargo.toml go.mod \
  Gemfile pom.xml build.gradle composer.json 2>/dev/null

# Check framework configs
ls next.config.* nuxt.config.* angular.json \
  tsconfig.json vite.config.* 2>/dev/null

# Check lockfiles (determines package manager)
ls yarn.lock pnpm-lock.yaml package-lock.json \
  uv.lock poetry.lock Cargo.lock go.sum 2>/dev/null

# Check language versions
node --version 2>/dev/null
python3 --version 2>/dev/null
go version 2>/dev/null

# Detect Docker
docker --version 2>/dev/null
```
If Docker is present, note in `.godmode/config`.
When Docker is available and a Dockerfile exists: offer containerized metric runs.
```
DETECTION MATRIX:
package.json + next.config.* -> Next.js
  test: npm test | lint: eslint --fix | build: npm run build
package.json + vite.config.* -> Vite
  test: npx vitest | lint: eslint --fix | build: npx vite build
package.json + tsconfig.json -> TypeScript
  test: npx vitest | lint: eslint --fix | build: tsc --noEmit
pyproject.toml -> Python
  test: pytest | lint: ruff check . | build: --
Cargo.toml -> Rust
  test: cargo test | lint: cargo clippy | build: cargo build
go.mod -> Go
  test: go test ./... | lint: golangci-lint | build: go build

LOCKFILE -> PACKAGE MANAGER:
  yarn.lock -> yarn
  pnpm-lock.yaml -> pnpm
  package-lock.json -> npm
  uv.lock -> uv
  poetry.lock -> poetry
```

### Step 2: Detect Platform
```
PLATFORM DETECTION (first match):
  IF Agent() + EnterWorktree: Claude Code
  IF read_file + run_shell_command: Gemini CLI
  IF slash commands + no Agent(): OpenCode
  IF .codex/ directory: Codex
  IF .cursorrules file: Cursor
  ELSE: Unknown (sequential, manual worktrees)

| Platform    | Parallel | Worktrees    |
|------------|---------|-------------|
| Claude Code| yes     | native       |
| Gemini CLI | no      | manual       |
| Codex      | no      | branch-based |
| Cursor     | no      | manual       |
```

### Step 3: Validate Commands
```bash
# Run each command and capture exit code
{test_cmd}; echo "EXIT:$?"
{lint_cmd}; echo "EXIT:$?"
{build_cmd}; echo "EXIT:$?"
```
```
| Command | Value       | Status | Time |
|---------|-----------|--------|------|
| test    | npx vitest | PASS   | 4.2s |
| lint    | eslint --fix| PASS  | 1.8s |
| build   | tsc --noEmit| FAIL  | 0.3s |

FOR each FAIL:
  Print last 20 lines of error
  Ask user for alternative (one question at a time)
  IF skipped: set to -- (unavailable)
  Max 3 retries per command
```

### Step 4: Configure Optimization
Only if user wants `/godmode:optimize`:
```bash
# Run metric 3 times, take median
for i in 1 2 3; do {verify_cmd}; done
```
IF 3 runs differ by >10%: warn metric is unstable.
Collect: goal, metric command, direction, target,
max iterations (default 25).

### Step 5: Define Scope
```bash
# Auto-detect source directories
git ls-files | grep -oP '^[^/]+/' | sort -u

# Auto-detect excludes
ls -d node_modules dist build .git __pycache__ \
  .next .nuxt target vendor 2>/dev/null
```

### Step 6: Save Config
Write `.godmode/config.yaml` with keys:
project, commands, platform, optimization,
scope, guard_rails.

### Step 7: Final Validation
```bash
{test_cmd} && {lint_cmd} && {build_cmd}
python3 -c 'import yaml; yaml.safe_load(
  open(".godmode/config.yaml"))'
git add .godmode/config.yaml \
  && git commit -m "setup: configure godmode"
```

## Output Format
```
Setup: detected {language} ({framework}) with {pm}.
Setup: platform: {name}. Parallel: {yes|no}.
Setup: test ({cmd}) -- PASS ({time}s).
Setup: lint ({cmd}) -- PASS ({time}s).
Setup: build ({cmd}) -- PASS ({time}s).
Setup: wrote .godmode/config.yaml. Committed.
```

## TSV Logging
Append to `.godmode/setup-log.tsv`:
`timestamp\tlanguage\tframework\tplatform\ttest\tlint\tbuild`

<!-- tier-3 -->

## Quality Targets
- Target: <15min from git clone to running dev environment
- Target: <5 manual steps in setup process
- Target: 100% of required tools auto-installed

## Hard Rules
1. Auto-detect before asking. Never ask "what language?"
   when package.json exists.
2. Never store unvalidated commands.
3. Never put secrets in config.yaml.
4. Skills not needing commands (think, debug) skip setup.
5. Max 3 retries per command, then set to --.
6. Guard: test_cmd && lint_cmd.
7. On failure: git reset --hard HEAD~1.
8. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
KEEP if: command exits 0 AND produces output
  within timeout
DISCARD if: fails OR times out OR no output
  Max 3 retries, then set to --.
```

## Stop Conditions
```
STOP when FIRST of:
  - .godmode/config.yaml written and committed
  - 3 retries per command exhausted
  - User skips all remaining optional commands
```
