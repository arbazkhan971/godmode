# Godmode for Codex (OpenAI)

**126 skills. 7 subagents. Zero configuration.**

Godmode turns Codex into a disciplined engineering environment. Every change is measured, every bad change is reverted, and every experiment is committed.

---

## Installation

### Option A: Automated (recommended)

```bash
git clone https://github.com/arbazkhan971/godmode.git
cd godmode
bash adapters/codex/install.sh /path/to/your/project
```

### Option B: Install script only

If you already have Godmode cloned:

```bash
bash install.sh /path/to/your/project
```

Defaults to the current directory if no target is specified.

### Option C: Manual

1. Copy `AGENTS.md` to your project root.
2. Copy the `.codex/` directory (with `config.toml` and `agents/*.toml`) to your project root.
3. Create `.godmode/` in your project root and run the install script's stack detection (or create `config.yaml` manually).

---

## How It Works

Codex loads its system prompt from `AGENTS.md` in the repository root. This file contains the full Godmode workflow, skill catalog, and subagent definitions. The `.codex/config.toml` configures agent threading and runtime limits, while `.codex/agents/*.toml` defines the 7 specialized subagents.

The repo already ships with native Codex agent configurations:

```
.codex/
  config.toml              # Agent threading, depth, and runtime config
  agents/
    planner.toml           # Decomposes goals into parallel tasks
    builder.toml           # Executes implementation tasks
    reviewer.toml          # Reviews code for correctness and security
    optimizer.toml         # Runs the autonomous optimization loop
    explorer.toml          # Maps codebase structure (read-only)
    security.toml          # STRIDE + OWASP security audit (read-only)
    tester.toml            # Writes tests following TDD
```

---

## Usage

Codex runs in batch mode. There are no interactive features -- you provide a task and Codex executes it to completion.

### Invoking Skills

Tell Codex which skill to use in your prompt:

```
codex "Run /godmode:optimize to improve API response time"
codex "Run /godmode:secure to audit the auth module"
codex "Run /godmode:test to add coverage for src/services/"
codex "Run /godmode:build to implement the rate limiter"
```

Or let the orchestrator auto-route:

```
codex "Run /godmode -- make this API faster"
codex "Run /godmode -- fix the failing tests"
codex "Run /godmode -- build a webhook handler"
```

Codex will read `AGENTS.md`, locate the skill file at `./skills/<skill-name>/SKILL.md`, and follow the workflow defined there.

### Subagents

Codex supports agent dispatch via the `.codex/agents/*.toml` definitions. When a skill calls for subagent work (e.g., the planner dispatching builders), Codex can spawn the appropriate agent.

However, parallel dispatch is not supported. Codex processes agent tasks single-threaded -- one at a time, sequentially. The planner still decomposes work into rounds, but each builder runs one at a time rather than in parallel.

See `adapters/shared/sequential-dispatch.md` for the full sequential execution protocol.

---

## Platform Limitations

Codex runs in batch mode with single-threaded execution. This affects two areas:

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| Parallel agents | Yes (Agent tool + worktrees) | No -- sequential only |
| Git worktrees | Native support | Not available |
| Interactive mode | Yes | No -- batch mode only |
| Skill count | 126 | 126 |
| Subagent definitions | 7 (agents/*.md) | 7 (.codex/agents/*.toml) |

**What this means in practice:**

- Multi-agent workflows (e.g., `plan` dispatching 3 builders in parallel) execute one task at a time instead of concurrently. The planner still decomposes work the same way -- builders just run sequentially.
- Worktree-based isolation is not available. Agents work on the active branch directly. Atomic commits and automatic rollback still function normally.
- All 126 skills work identically. No skill is degraded or unavailable.
- Codex does not support interactive prompts mid-execution. All input must be provided upfront in the task description.

---

## Skills (126)

### Core Workflow (15)

`godmode` `think` `predict` `scenario` `plan` `build` `test` `review` `optimize` `debug` `fix` `ship` `finish` `setup` `verify`

### Architecture & Design (10)

`architect` `rfc` `ddd` `pattern` `schema` `concurrent` `distributed` `scale` `legacy` `migration`

### API & Backend (14)

`api` `graphql` `grpc` `orm` `query` `cache` `queue` `event` `realtime` `edge` `micro` `search` `ratelimit` `webhook`

### Frameworks (12)

`react` `nextjs` `vue` `svelte` `angular` `node` `fastapi` `django` `rails` `laravel` `spring` `tailwind`

### Databases (3)

`postgres` `redis` `nosql`

### Security & Compliance (8)

`secure` `auth` `rbac` `secrets` `crypto` `pentest` `devsecops` `comply`

### Testing (7)

`e2e` `integration` `loadtest` `lint` `type` `perf` `webperf`

### DevOps & Infrastructure (16)

`deploy` `k8s` `infra` `cicd` `ghactions` `pipeline` `docker` `backup` `incident` `observe` `logging` `network` `resilience` `config` `cost` `cron`

### Frontend & UI (9)

`ui` `a11y` `seo` `mobile` `chart` `state` `designsystem` `forms` `responsive`

### AI & ML (5)

`ml` `mlops` `rag` `prompt` `eval`

### Developer Experience (12)

`docs` `onboard` `refactor` `git` `pr` `monorepo` `npm` `changelog` `opensource` `analytics` `apidocs` `reliability` `slo`

### Integrations (14)

`i18n` `email` `pay` `cli` `automate` `migrate` `storage` `agent` `feature` `notify` `experiment` `seed` `upload` `chaos`

---

## Subagents (7)

| Agent | Role | Mode |
|-------|------|------|
| **planner** | Decomposes goals into tasks, maps each to a skill | Read-only |
| **builder** | Executes implementation following a skill workflow | Read-write |
| **reviewer** | Reviews code for correctness, security, skill adherence | Read-only |
| **optimizer** | Runs measure, modify, verify, keep/revert loop | Read-write |
| **explorer** | Maps codebase structure, traces code paths | Read-only |
| **security** | STRIDE + OWASP audit with adversarial personas | Read-only |
| **tester** | Writes tests following TDD RED-GREEN-REFACTOR | Read-write |

In Codex, subagents execute sequentially. The planner still decomposes work into rounds, but each builder runs one at a time rather than in parallel.

---

## File Structure

After installation, your project will contain:

```
your-project/
  AGENTS.md                          # Main instruction file (system prompt)
  .godmode/
    config.yaml                      # Auto-detected project configuration
  .codex/
    config.toml                      # Codex agent config
    agents/
      planner.toml                   # 7 subagent TOML definitions
      builder.toml
      reviewer.toml
      optimizer.toml
      explorer.toml
      security.toml
      tester.toml
```

The skills, agents, and commands directories are referenced from the Godmode source installation, not copied into your project.

---

## Troubleshooting

### Codex not reading AGENTS.md

1. Confirm `AGENTS.md` is in the repository root:
   ```bash
   test -f AGENTS.md && echo "OK" || echo "MISSING"
   ```
2. Codex reads the system prompt from the repo root. If `AGENTS.md` is nested in a subdirectory, it will not be found. Move it to the root.

### Agent TOML files not loading

1. Verify the `.codex/` directory structure:
   ```bash
   ls .codex/config.toml .codex/agents/*.toml
   ```
2. Validate TOML syntax:
   ```bash
   python3 -c "import tomllib; tomllib.load(open('.codex/config.toml', 'rb'))" && echo "OK"
   ```
3. If files are missing, re-run the installer:
   ```bash
   bash adapters/codex/install.sh .
   ```

### Skill files not found

1. Check that skill files are accessible from the repo root:
   ```bash
   ls skills/godmode/SKILL.md
   ```
2. If using symlinks, confirm they resolve:
   ```bash
   file skills/godmode/SKILL.md   # should show "ASCII text", not "broken symbolic link"
   ```
3. Codex runs in a sandbox -- ensure symlinks point to paths inside the repo, not to external absolute paths that the sandbox cannot access.

### Batch job timing out

Long-running skills (optimize with 25 iterations, large builds with many tasks) may exceed the default runtime limit. Increase `job_max_runtime_seconds` in `.codex/config.toml`:

```toml
job_max_runtime_seconds = 3600   # 60 minutes
```

### Sequential mode producing different results

It should not. If you observe different outcomes between Codex and Claude Code, check:
1. Both are using the same `.godmode/config.yaml` (same test_cmd, lint_cmd, build_cmd).
2. Both are running against the same git commit.
3. No environment differences (Node version, Python version, etc.).
4. Codex sandbox restrictions -- some commands may fail in the sandbox that succeed locally.

## Verification

Run the verification script after installation:

```bash
bash adapters/codex/verify.sh
```

The script checks:
- `AGENTS.md` exists in the repository root
- `skills/` directory is accessible and contains SKILL.md files
- `agents/` directory is accessible and contains agent definitions
- `.codex/config.toml` exists and is valid TOML
- `.codex/agents/` contains all 7 agent TOML files
- `.godmode/config.yaml` exists with valid test/lint/build commands

**Manual verification** (if the script is unavailable):

```bash
# 1. Config file exists
cat .godmode/config.yaml

# 2. Skills are readable
head -5 skills/godmode/SKILL.md

# 3. Agent TOMLs are present
ls .codex/agents/

# 4. Codex config is valid
cat .codex/config.toml

# 5. Test with a simple invocation
codex "Run /godmode:verify claim='setup works' cmd='echo ok'"
```

---

## License

MIT -- see [LICENSE](../../LICENSE).
