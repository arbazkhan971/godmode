---
name: setup
description: |
  Configuration wizard. Auto-detects project stack, validates commands, saves .godmode/config.yaml. Triggers on: /godmode:setup, first-time use (no .godmode/), or when a skill needs config that doesn't exist.
---

# Setup — Configuration Wizard

## Activate When
- User invokes `/godmode:setup`
- First time using Godmode (no `.godmode/` directory)
- A skill needs a verify/test/lint command but none is configured
- User says "configure godmode", "set up", "initialize"
- User wants to change optimization targets or settings

## Auto-Detection
The godmode orchestrator routes here when:
- `.godmode/` directory does not exist
- `.godmode/config.yaml` does not exist or is invalid YAML
- A downstream skill (build, test, optimize) fails because `test_cmd`, `lint_cmd`, or `build_cmd` is missing
- User explicitly requests reconfiguration

## Step-by-step Workflow

### Step 1: DETECT Stack
Scan the project root for manifest files. First match wins:

```bash
# Check for project manifests (order matters — most specific first)
ls package.json pyproject.toml Cargo.toml go.mod Gemfile pom.xml build.gradle composer.json 2>/dev/null

# Check for framework-specific configs
ls next.config.* nuxt.config.* angular.json tsconfig.json vite.config.* 2>/dev/null

# Check for lockfiles (determines package manager)
ls yarn.lock pnpm-lock.yaml package-lock.json uv.lock Pipfile.lock poetry.lock Cargo.lock go.sum Gemfile.lock 2>/dev/null

# Check language versions
node --version 2>/dev/null; python3 --version 2>/dev/null; go version 2>/dev/null; rustc --version 2>/dev/null
```

Detection matrix:
```
package.json + next.config.*  → Next.js     | npm test       | eslint --fix  | npm run build
package.json + nuxt.config.*  → Nuxt        | npm test       | eslint --fix  | npm run build
package.json + angular.json   → Angular     | ng test        | eslint --fix  | ng build
package.json + vite.config.*  → Vite        | npx vitest     | eslint --fix  | npx vite build
package.json + tsconfig.json  → TypeScript  | npx vitest     | eslint --fix  | tsc --noEmit
package.json                  → JavaScript  | npm test       | eslint --fix  | npm run build
pyproject.toml                → Python      | pytest         | ruff check .  | —
Cargo.toml                    → Rust        | cargo test     | cargo clippy  | cargo build
go.mod                        → Go          | go test ./...  | golangci-lint | go build ./...
Gemfile                       → Ruby        | rspec          | rubocop -A    | —
pom.xml                       → Java        | mvn test       | checkstyle    | mvn package
build.gradle                  → Java/Kotlin | gradle test    | —             | gradle build
composer.json                 → PHP/Laravel | php artisan test | phpstan     | —
```

Lockfile → package manager: `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `package-lock.json` → npm, `uv.lock` → uv, `poetry.lock` → poetry.

Print: `Detected: {language} ({framework}) with {package_manager}. Test: {test_cmd}. Lint: {lint_cmd}. Build: {build_cmd}.`

### Step 2: DETECT Platform
Identify the host AI coding platform:

```
PLATFORM DETECTION (first match wins):
1. Claude Code  — Agent() tool and EnterWorktree tool available
2. Gemini CLI   — read_file, write_file, run_shell_command tools available
3. OpenCode     — slash command support present, no Agent() tool
4. Codex        — batch mode active or .codex/ directory exists
5. Cursor       — .cursorrules file present or background agents available
6. Unknown      — none of the above; default to sequential, manual worktrees
```

Print exactly: `Detected platform: {platform}. Parallel agents: {yes/no}. Worktrees: {native/manual/branch-based}.`

| Platform    | Parallel agents | Worktrees    |
|-------------|-----------------|--------------|
| Claude Code | yes             | native       |
| Gemini CLI  | no              | manual       |
| OpenCode    | no              | manual       |
| Codex       | no              | branch-based |
| Cursor      | no              | manual       |

### Step 3: VALIDATE Commands
For each detected command (`test_cmd`, `lint_cmd`, `build_cmd`), run it and verify:

```bash
# Run each command and capture exit code
{test_cmd}; echo "EXIT:$?"
{lint_cmd}; echo "EXIT:$?"
{build_cmd}; echo "EXIT:$?"
```

```
COMMAND VALIDATION:
┌──────────┬──────────────────┬────────┬──────────┐
│ Command  │ Value            │ Status │ Time     │
├──────────┼──────────────────┼────────┼──────────┤
│ test     │ npx vitest       │ PASS   │ 4.2s     │
│ lint     │ eslint --fix     │ PASS   │ 1.8s     │
│ build    │ tsc --noEmit     │ FAIL   │ 0.3s     │
└──────────┴──────────────────┴────────┴──────────┘
```

For each FAIL:
- Print the error output (last 20 lines)
- Ask user for alternative command (one question at a time)
- Run the alternative, repeat until PASS or user says "skip"
- If skipped, set to `—` (unavailable) — downstream skills will omit this check

### Step 4: CONFIGURE Optimization (if needed)
Only run this step if user wants `/godmode:optimize` or explicitly asks:

```bash
# Run verify command 3 times, take median
for i in 1 2 3; do {verify_cmd}; done
```

Collect: goal (what to optimize), metric command (outputs single number), direction (higher/lower is better), target value, max iterations (default 25).

Verify stability: if the 3 runs differ by more than 10%, warn user that metric is unstable and suggest a more stable measurement approach.

### Step 5: DEFINE Scope
Determine what files godmode should touch and what to ignore:

```bash
# Auto-detect source directories
git ls-files | grep -oP '^[^/]+/' | sort -u

# Auto-detect common excludes
ls -d node_modules dist build .git __pycache__ .next .nuxt target vendor 2>/dev/null
```

Auto-populate include from `git ls-files` top-level dirs. Exclude: `node_modules/`, `dist/`, `.git/`, `__pycache__/`, `build/`, `target/`, `vendor/`.

### Step 6: SAVE Config
Write `.godmode/config.yaml` with keys: `project` (name, language, framework, package_manager), `commands` (test, lint, typecheck, build), `platform` (name, parallel_agents, worktree_mode), `optimization` (goal, metric, direction, target, max_iterations), `scope` (include, exclude), `guard_rails` (list of {command, name, must_pass}).

### Step 7: FINAL Validation
Run all configured commands once more, validate YAML with `python3 -c 'import yaml; yaml.safe_load(open(...))'`, then commit:

```bash
{test_cmd} && {lint_cmd} && {build_cmd}
python3 -c 'import yaml; yaml.safe_load(open(".godmode/config.yaml"))'
git add .godmode/config.yaml && git commit -m "setup: configure godmode for {language}/{framework}"
```

## Output Format
Print at each stage:

```
Setup: scanning project root...
Setup: detected TypeScript (Next.js) with pnpm.
Setup: detected platform: Claude Code. Parallel agents: yes. Worktrees: native.
Setup: validating commands...
Setup: test (npx vitest) — PASS (4.2s).
Setup: lint (eslint --fix) — PASS (1.8s).
Setup: build (npm run build) — PASS (12.1s).
Setup: wrote .godmode/config.yaml.
Setup: all guards passed. Configuration committed.
```

## TSV Logging
Append to `.godmode/setup-log.tsv` (create if missing, never overwrite):

```
timestamp	language	framework	package_manager	platform	test_cmd_status	lint_cmd_status	build_cmd_status	config_path
2025-01-15T13:00:00Z	TypeScript	Next.js	pnpm	claude-code	pass	pass	pass	.godmode/config.yaml
```

Columns: `timestamp`, `language`, `framework`, `package_manager`, `platform`, `test_cmd_status`, `lint_cmd_status`, `build_cmd_status`, `config_path`.

## Success Criteria
Setup is done when ALL of the following are true:
- [ ] `.godmode/config.yaml` exists and parses as valid YAML
- [ ] Language, framework, and package manager are detected (or manually provided)
- [ ] Platform is detected with parallel agent and worktree capabilities noted
- [ ] `test_cmd` validated by running it (or set to `—` if unavailable)
- [ ] `lint_cmd` validated by running it (or set to `—` if unavailable)
- [ ] `build_cmd` validated by running it (or set to `—` if unavailable)
- [ ] Scope include/exclude lists are populated
- [ ] Config is committed to git
- [ ] TSV log row appended

## Error Recovery
- **No manifest files found:** Ask user for language and framework. Set commands to `—` for any that cannot be determined. Proceed with manual config.
- **Test command fails on first run:** Print last 20 lines of output. Common fixes: missing dependencies (`npm install`, `pip install -e .`), missing env vars, wrong working directory. Suggest the fix, run it, retry. Max 3 retries.
- **Existing `.godmode/config.yaml` found:** Print current config. Ask user: "Overwrite or update?" If update, merge new detections with existing values (existing values win unless user overrides). Never silently overwrite.
- **YAML write fails (permissions):** Check directory permissions. If `.godmode/` does not exist, `mkdir -p .godmode`. If still fails, print the error and suggest `chmod` or running from a writable directory.
- **Unstable metric (>10% variance across 3 runs):** Warn user. Suggest: run with more iterations, warm up caches first, or use a different metric. Do not proceed with optimization config until metric is stable or user acknowledges instability.

## Anti-Patterns
1. **Asking before detecting:** Never ask the user "what language is this?" when `package.json` is sitting in the root. Auto-detect first, ask second.
2. **Accepting unvalidated commands:** Never store a test command without running it. A broken `test_cmd` wastes every downstream skill's time.
3. **Storing secrets in config:** Never put API keys, tokens, or passwords in `.godmode/config.yaml`. Use environment variables or a secrets manager. If a command needs a secret, reference the env var name: `API_KEY=$MY_API_KEY npm test`.
4. **Requiring setup for simple skills:** `/godmode:think` and `/godmode:debug` work without config. Do not force setup as a prerequisite for skills that do not need `test_cmd`/`lint_cmd`/`build_cmd`.
5. **Over-configuring:** Do not ask 10 questions. Detect everything possible, validate by running, and present the result. User should be able to accept defaults and go.

## Examples

### Example 1: Node.js Project
```
User: /godmode:setup
Setup: scanning project root...
Setup: detected TypeScript (Next.js) with pnpm.
Setup: detected platform: Claude Code. Parallel agents: yes. Worktrees: native.
Setup: validating commands...
Setup: test (npx vitest) — PASS (3.8s).
Setup: lint (eslint --fix) — PASS (2.1s).
Setup: build (pnpm run build) — PASS (15.4s).
Setup: wrote .godmode/config.yaml. Committed.
```

### Example 2: Python Project with Failing Lint
```
User: /godmode:setup
Setup: scanning project root...
Setup: detected Python (FastAPI) with uv.
Setup: detected platform: Gemini CLI. Parallel agents: no. Worktrees: manual.
Setup: validating commands...
Setup: test (pytest) — PASS (6.1s).
Setup: lint (ruff check .) — FAIL.
  → 3 fixable errors found. Run `ruff check . --fix` to auto-fix.
Setup: trying `ruff check . --fix && ruff check .`...
Setup: lint (ruff check .) — PASS (0.4s).
Setup: build — not applicable (set to —).
Setup: wrote .godmode/config.yaml. Committed.
```

### Example 3: Reconfiguration
```
User: "I switched from Jest to Vitest, update godmode config"
Setup: existing .godmode/config.yaml found.
  Current test_cmd: npx jest
Setup: updating test_cmd to: npx vitest.
Setup: validating... test (npx vitest) — PASS (2.3s).
Setup: updated .godmode/config.yaml. Committed.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Setup itself requires no parallel agents — runs identically on all platforms.
- Platform detection in Step 2 will identify the current platform and record its capabilities.
- Sequential fallback note is stored in config: `platform.parallel_agents: false`.
- All downstream skills read this config to decide between parallel and sequential dispatch.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
