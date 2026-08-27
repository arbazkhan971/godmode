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

## Uninstall

```bash
rm -rf ~/.pi/agent/skills/godmode
```

For a custom target, remove that directory instead.

## License

MIT — see [LICENSE](../../LICENSE).
