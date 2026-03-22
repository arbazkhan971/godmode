# Godmode Adapter for Cursor

**126 skills. 7 subagents. Zero configuration.**

Godmode turns Cursor into a disciplined engineering environment. Every change is measured, every bad change is reverted, and every experiment is committed.

---

## Installation

### Option A: Automated (recommended)

```bash
cd your-project
bash /path/to/godmode/adapters/cursor/install.sh .
```

This copies `.cursorrules` into your project root, creates `.godmode/` with auto-detected project config, and symlinks the skills and agents directories.

### Option B: Manual

1. Copy `.cursorrules` to your project root:

```bash
cp /path/to/godmode/adapters/cursor/.cursorrules ./.cursorrules
```

2. Symlink the skills and agents directories:

```bash
ln -s /path/to/godmode/skills ./skills
ln -s /path/to/godmode/agents ./agents
```

3. Create `.godmode/` and run the session-start hook or create `config.yaml` manually.

Cursor automatically reads `.cursorrules` from the project root on startup.

---

## Usage

Invoke skills with `@godmode` in Cursor chat or command palette:

```
@godmode think         -- brainstorm and design
@godmode optimize      -- autonomous performance iteration loop
@godmode secure        -- STRIDE + OWASP security audit
@godmode build         -- TDD build with test-first workflow
@godmode test          -- write tests with RED-GREEN-REFACTOR
@godmode ship          -- pre-flight checks, deploy, verify
@godmode               -- auto-detect phase and route
```

Slash syntax also works:

```
/godmode:optimize
/godmode:secure
/godmode:build
```

Natural language works too:

```
"make this API faster"     -> routes to optimize
"fix the failing tests"    -> routes to fix
"review my auth module"    -> routes to review
```

---

## Parallel Execution with Background Agents

Cursor supports background agents, which Godmode uses for parallel task dispatch. Unlike sequential-only platforms (Gemini CLI, OpenCode), Cursor can run multiple agents concurrently:

- **Parallel builders:** The `build` skill dispatches up to 5 builder agents per round. In Cursor, these run as background agents simultaneously.
- **Parallel optimization:** The `optimize` skill tries 3 approaches per round in parallel background agents, keeping only the best result.
- **Parallel review:** The `review` skill runs 4 review passes (correctness, security, performance, style) as concurrent background agents.

All 126 skills work in Cursor. Parallel features use Cursor's background agent capability for concurrent execution.

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

In Cursor, subagents dispatch as background agents for parallel execution. The planner decomposes work into rounds, and builders run concurrently within each round.

---

## File Structure

After installation, your project will contain:

```
your-project/
  .cursorrules                       # Godmode instructions for Cursor
  .godmode/
    config.yaml                      # Auto-detected project configuration
    optimize-results.tsv             # Optimization tracking
    fix-log.tsv                      # Fix tracking
    ship-log.tsv                     # Ship tracking
  skills/ -> /path/to/godmode/skills # Symlinked skill definitions
  agents/ -> /path/to/godmode/agents # Symlinked agent definitions
```

---

## Troubleshooting

### Skills not loading or "unknown command"

1. Confirm `.cursorrules` exists in the project root:
   ```bash
   test -f .cursorrules && echo "OK" || echo "MISSING"
   ```
2. Verify skill files are accessible:
   ```bash
   ls skills/godmode/SKILL.md
   ```
3. If using symlinks, confirm they resolve:
   ```bash
   file skills/godmode/SKILL.md   # should show "ASCII text", not "broken symbolic link"
   ```
4. Restart Cursor after installation -- `.cursorrules` is read on project open.

### Symlinks broken after moving the Godmode repo

If you moved or re-cloned the Godmode source, symlinks in `skills/` and `agents/` will break. Fix by re-running the installer:

```bash
bash /path/to/godmode/adapters/cursor/install.sh .
```

### Background agents not dispatching

Cursor's background agent support depends on your Cursor plan and version. If parallel dispatch is not working:
1. Verify your Cursor version supports background agents.
2. Check that Cursor settings allow background agent execution.
3. Fall back to sequential mode -- Godmode skills degrade gracefully. Read `adapters/shared/sequential-dispatch.md` for the protocol.

### Different results than Claude Code

If you observe different outcomes between Cursor and Claude Code, check:
1. Both are using the same `.godmode/config.yaml` (same test_cmd, lint_cmd, build_cmd).
2. Both are running against the same git commit.
3. No environment differences (Node version, Python version, etc.).
4. Background agent isolation -- ensure agents are not writing to the same files concurrently without worktree isolation.

## Verification

After installation, confirm everything is wired correctly:

```bash
bash /path/to/godmode/adapters/cursor/install.sh --verify .
```

Or verify manually:

```bash
# 1. .cursorrules exists and is non-empty
wc -l .cursorrules

# 2. Skills are readable
head -5 skills/godmode/SKILL.md

# 3. Agents are readable
head -5 agents/planner.md

# 4. Config file exists
cat .godmode/config.yaml

# 5. Test a skill invocation in Cursor chat
# @godmode verify claim="setup works" cmd="echo ok"
```

The key checks:
- `.cursorrules` is present and contains the Godmode instruction set
- `skills/` symlink resolves to the Godmode skills directory
- `agents/` symlink resolves to the Godmode agents directory
- `.godmode/config.yaml` exists with valid test/lint/build commands

## Reference

- `.cursorrules` (loaded by Cursor): [.cursorrules](./.cursorrules)
- All skills: [../../skills/](../../skills/)
- All agents: [../../agents/](../../agents/)
- Shared sequential dispatch protocol: [../shared/sequential-dispatch.md](../shared/sequential-dispatch.md)

---

## License

MIT -- see [LICENSE](../../LICENSE).
