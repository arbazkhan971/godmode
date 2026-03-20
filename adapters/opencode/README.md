# Godmode for OpenCode

**126 skills. 7 subagents. Zero configuration.**

Godmode turns OpenCode into a disciplined engineering environment. Every change is measured, every bad change is reverted, and every experiment is committed.

---

## Installation

### Option A: Automated (recommended)

```bash
git clone https://github.com/arbazkhan971/godmode.git
cd godmode
bash adapters/opencode/install.sh /path/to/your/project
```

### Option B: Install script only

If you already have Godmode cloned:

```bash
bash install.sh /path/to/your/project
```

Defaults to the current directory if no target is specified.

### Option C: Manual

1. Copy `AGENTS.md` to your project root.
2. Create `.godmode/` in your project root and run the install script's stack detection (or create `config.yaml` manually).
3. Copy `adapters/opencode/plugin.json` to `.opencode/plugins/godmode/plugin.json` in your project.

---

## Usage

OpenCode supports native slash commands. Invoke any Godmode skill with:

```
/godmode:skillname
```

### Examples

```
/godmode:optimize    # Autonomous performance iteration loop
/godmode:build       # TDD build with test-first workflow
/godmode:secure      # STRIDE + OWASP security audit
/godmode:ship        # Pre-flight checks, deploy, verify, monitor
/godmode:test        # Write tests with RED-GREEN-REFACTOR
/godmode:debug       # Scientific bug investigation
/godmode:fix         # Autonomous error remediation loop
/godmode:review      # 4-perspective code review
```

Or let the orchestrator route automatically:

```
/godmode make this API faster       # routes to optimize
/godmode fix the failing tests      # routes to fix
/godmode build a rate limiter       # routes to think -> plan -> build
```

---

## Platform Limitations

OpenCode runs in sequential execution mode. This affects two areas:

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| Parallel agents | Yes (Agent tool + worktrees) | No — sequential only |
| Git worktrees | Native support | Not available |
| Slash commands | `/godmode:skill` | `/godmode:skill` (native) |
| Skill count | 126 | 126 |
| Subagent definitions | 7 | 7 (sequential dispatch) |

**What this means in practice:**

- Multi-agent workflows (e.g., `plan` dispatching 3 builders in parallel) execute one task at a time instead of concurrently. The planner still decomposes work the same way — builders just run sequentially.
- Worktree-based isolation is not available. Agents work on the active branch directly. Atomic commits and automatic rollback still function normally.
- All 126 skills work identically. No skill is degraded or unavailable.

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

In OpenCode, subagents execute sequentially. The planner still decomposes work into rounds, but each builder runs one at a time rather than in parallel.

---

## File Structure

After installation, your project will contain:

```
your-project/
  AGENTS.md                          # Main instruction file
  .godmode/
    config.yaml                      # Auto-detected project configuration
  .opencode/
    plugins/
      godmode/
        plugin.json                  # OpenCode plugin manifest
```

The skills, agents, and commands directories are referenced from the Godmode source installation, not copied into your project.

---

## License

MIT — see [LICENSE](../../LICENSE).
