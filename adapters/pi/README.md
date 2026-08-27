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

The omp agent also reads a global skills directory, but its exact location is undocumented. The known candidates are `~/.omp/agent/skills` and `~/.config/omp/skills`. Install with `PREFIX` pointing at one of them and check whether omp picks the skills up — this has not been confirmed on every omp build.

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
