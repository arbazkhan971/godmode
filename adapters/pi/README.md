# Godmode for pi

**135 skills. 7 subagents. One global directory.**

This adapter installs all godmode skills into the [pi](https://github.com/badlogic/pi-mono) agent CLI's global skills directory. Skills placed there auto-load at the start of every pi session — no per-project setup, no config files, no symlinks.

---

## Installation

```bash
git clone https://github.com/arbazkhan971/godmode.git
cd godmode
bash adapters/pi/install.sh
```

This copies every skill to `~/.pi/agent/skills/godmode/`, the pi CLI's global skills dir. pi reads that directory automatically, so the full catalog is available in every session on the machine.

### Custom target directory

Install elsewhere with a positional argument or the `PREFIX` env var:

```bash
bash adapters/pi/install.sh /some/dir
PREFIX="$HOME/.omp/agent/skills" bash adapters/pi/install.sh
```

### Using the skills with omp

omp is a pi fork served by this same installer. Its user skills dir is `~/.omp/agent/skills`, but omp scans only one level per skill (`<skills-root>/<skill-name>/SKILL.md`), so the installer's `godmode/` wrapper is not auto-discovered. Register the collection once in `~/.omp/agent/config.yml` — `skills.customDirectories` is omp's documented mechanism for nested collections.

```bash
PREFIX="$HOME/.omp/agent/skills" bash adapters/pi/install.sh
```

Required one-time registration — add to `~/.omp/agent/config.yml` if not present. Without it, omp reports `Unknown skill: optimize`. Confirmed from upstream source (can1357/oh-my-pi @ main, 2026-08-27) and verified against omp v18.0.8 (linux-x64):

```yaml
skills:
  customDirectories:
    - ~/.omp/agent/skills/godmode
```

omp has no `--skill` flag, so the pi smoke test above does not apply. Verified omp smoke test:

```bash
omp -p --tools=read "Use your read tool on skill://optimize and reply with its frontmatter description line. If unreadable, reply READ_FAIL."
```

A working install replies with the optimize description: `Autonomous optimization loop. 3 parallel agents per round, mechanical metrics only.`

- **Profiles:** with an active omp profile, `getAgentDir()` resolves to `~/.omp/profiles/<name>/agent` — skills load from `~/.omp/profiles/<name>/agent/skills` instead.
- **Never point PREFIX at `~/.omp/agent/managed-skills`** — that directory is omp's autolearn-only provider.
- **One location only:** omp also discovers user- and project-level `.agent[s]/skills` by default (agents provider; `~/.agents/skills` verified on omp v18.0.8). Install godmode for omp in exactly one location; generic skill names (`test`, `review`, `build`, ...) take precedence over same-named skills in omp's lower-priority providers (per omp's priority-first name dedup).
- **Skills only:** this adapter ships the skills catalog — no godmode subagent injection, no omp model-routing wiring.
- **Name-squat warning:** the npm package `oh-my-pi` (v0.2.0, `acidsugarx`) is unrelated. Official omp channels: `curl -fsSL https://omp.sh/install | sh`, `brew install can1357/tap/omp`, `bun install -g @oh-my-pi/pi-coding-agent`, GitHub releases.

Uninstall: `rm -rf ~/.omp/agent/skills/godmode` and remove the `customDirectories` entry from `~/.omp/agent/config.yml`.

---

## Verify Installation

```bash
bash adapters/pi/verify.sh
```

Then run the dogfood smoke test in a real pi session:

```bash
pi -p -ne --skill ~/.pi/agent/skills/godmode/optimize/SKILL.md "Reply GODMODE_SKILL_OK if the optimize skill description is in your context"
```

If the installed optimize skill is actually in the agent's context, pi replies `GODMODE_SKILL_OK`.

---

## Multi-model routing

Per-role model routing ships inside the installed skills: the godmode
orchestrator skill resolves each role's model at dispatch time. A reference
implementation lives at `adapters/pi/models.sh`.

Zero-config by default: with no env vars and no config file, every role
inherits the session model. Resolution order, per role: `GODMODE_MODEL_<ROLE>`
env -> `godmode.models.json` at the current project root ->
`~/.config/godmode/models.json` -> session model. "Project root" means the
user's current project (cwd-based), not the godmode repo.

Env override — role uppercased, with `.`, `_`, and `-` all mapped to `_`
(`code-review` and `v2.review` become `GODMODE_MODEL_CODE_REVIEW` and
`GODMODE_MODEL_V2_REVIEW`):

```bash
GODMODE_MODEL_REVIEW=anthropic/claude-sonnet-4.5
```

Config file — `godmode.models.json`. Commit it at a repo root to share that
project's routing with everyone who clones it, or keep it under
`~/.config/godmode/` for personal defaults; the project file wins per key:

```json
{"roles": {"review": "anthropic/claude-sonnet-4.5", "optimize": "openai/gpt-5.2"}}
```

Diagnostics (the installed verify skill prints the same doctor table):

```bash
bash adapters/pi/models.sh resolve review   # "<model>\t<source>"
bash adapters/pi/models.sh doctor           # one TSV row per role
bash adapters/pi/models.sh selftest         # internal routing tests
```

---

## Uninstall

```bash
rm -rf ~/.pi/agent/skills/godmode
```

For a custom target, remove that directory instead.

## License

MIT — see [LICENSE](../../LICENSE).
