# Godmode for Amp

**135 skills as of this writing. Amp-native project skills. No generated config.**

Godmode turns Amp into a disciplined engineering environment. Every change is measured, every bad change is reverted, and every experiment is committed.

---

## Installation

### Option A: Automated (recommended)

```bash
git clone https://github.com/arbazkhan971/godmode.git
cd godmode
bash adapters/amp/install.sh /path/to/your/project
```

Defaults to the current directory if no target is specified.

The installer is idempotent — every step is skip-if-present, so re-running it is always safe. One exception: while a user-authored `AGENTS.md` differs from godmode's, each re-run refreshes the `AGENTS.godmode.md` sidecar from source (hand-edits to the sidecar are not preserved — merge into your `AGENTS.md` instead). Re-run after moving or re-cloning godmode to re-report the wiring.

If the target already has a user-authored `AGENTS.md`, the installer never clobbers it. It writes godmode's content to `AGENTS.godmode.md` alongside your file instead. Amp does not auto-load that filename — merge the godmode sections into your `AGENTS.md` to activate them (see Troubleshooting).

### Option B: Manual

1. Copy `AGENTS.md` from the godmode repo root to your project root.
2. Wire Amp's project-skill directory to godmode's skills tree:

   ```bash
   mkdir -p .agents
   ln -s /path/to/godmode/skills .agents/skills
   ```

3. Optionally symlink `skills/` and `agents/` at your project root too — the installer does this so the `./skills/<name>/SKILL.md` paths referenced by `AGENTS.md` resolve:

   ```bash
   ln -s /path/to/godmode/skills skills
   ln -s /path/to/godmode/agents agents
   ```

4. Create `.godmode/` with a `config.yaml` (test/lint/build commands), or run the installer once to auto-detect your stack.

---

## How It Works

### AGENTS.md discovery

Amp loads `AGENTS.md` natively — no adapter glue required. Per [Amp's AGENTS.md documentation](https://ampcode.com/docs/customize/agents-md), it reads the file from:

- the current working directory
- every parent directory, up to `$HOME`
- subtrees

Two global files are always included: `~/.config/amp/AGENTS.md` and `~/.config/AGENTS.md`. If `AGENTS.md` is absent, Amp falls back to `AGENT.md`, then `CLAUDE.md`.

That is why the installer copies godmode's `AGENTS.md` to the target root: Amp picks up the full godmode workflow, skill catalog, and role table with zero configuration.

### Project skills

Amp loads project skills from `.agents/skills/`, committed with the project. Per [Amp's skills documentation](https://ampcode.com/docs/customize/skills):

- every skill is a directory holding a `SKILL.md`
- the directory name must equal the frontmatter `name:` value — mismatches are not loaded

The installer symlinks godmode's `skills/` tree to `.agents/skills/`, so every godmode skill (135 as of this writing — `verify.sh` counts the live total) appears to Amp as a native project skill.

### Skill resolution order

Amp resolves skills by frontmatter name, first match wins, in this order:

1. `~/.config/agents/skills/`
2. `~/.agents/skills/`
3. `~/.config/amp/skills/`
4. project `.agents/skills/` (and its parent directories)
5. `.claude/skills/` (and parents)
6. `~/.claude/skills/`
7. `~/.claude/plugins/cache/`
8. directories configured on `amp.skills.path`
9. Amp's built-in skills

Note the consequence: the first three user-global directories outrank your project's `.agents/skills/` by name — see Troubleshooting for the shadowing caveat.

### Subagents

Amp has its own subagent system, and there is no Amp format for godmode's seven role definitions in `agents/`. The installer links `agents/` for reference, but godmode's roles are not injected into Amp's subagents — see Capability.

---

## Capability

| Feature | Claude Code | Amp |
|---------|-------------|-----|
| Skills | 135 as of this writing | Same, via `.agents/skills/` |
| Instruction file | `AGENTS.md` (native) | `AGENTS.md` (native) |
| Subagent dispatch | Agent tool + worktrees | Not wired — prompt Amp's own subagents with godmode roles |
| Slash commands | `/godmode:skill` | No — invoke skills by name in the prompt |
| Per-child model routing | Env/profiles | Not wired |

### Works

- All 135 skills (as of this writing; `verify.sh` prints the live count) load as Amp-native project skills through `.agents/skills/`.
- The godmode workflow — the THINK/BUILD/OPTIMIZE/SHIP loop, status codes, DispatchContext contract, keep/revert discipline — arrives intact via the root `AGENTS.md` Amp reads natively.
- The `.godmode/` state layer (`config.yaml` plus the tracking TSVs) works unchanged: it is plain files that skills read and write on any platform.

### Not wired

- 7-subagent role dispatch. Amp's subagents are configured in Amp's own format; godmode's `agents/*.md` definitions are not injected. When a skill calls for dispatch, run the roles sequentially in one session, or prompt one of Amp's own subagents with the godmode role description from the `AGENTS.md` table.
- Slash commands. There is no `/godmode:skill` surface — invoke skills by name in your prompt (see Usage).
- Per-child model routing. godmode's `model`/`model_profile` hints are not wired through Amp; there is no per-child model pinning.

---

## Usage

Ask Amp to run a skill by name. The simplest entry point is the `godmode` router skill:

```text
Run the godmode skill — make this API faster
Run the secure skill to audit the auth module
Run the test skill to add coverage for src/services/
Run the optimize skill to reduce the build time
```

Amp resolves a skill name to `.agents/skills/<name>/SKILL.md` and follows the workflow defined there. The `godmode` router reads your task and routes to the right specialist skill.

### Multi-agent skills

Parallel subagent dispatch is not wired (see Capability). When a skill calls for dispatching multiple roles, execute them sequentially in a single session — planner, then builder, then reviewer — following [`adapters/shared/sequential-dispatch.md`](../shared/sequential-dispatch.md).

---

## Verify Installation

Run from the godmode repository after installing:

```bash
bash adapters/amp/verify.sh /path/to/your/project
```

The script defaults to the current directory if no target is given, and checks:

- `AGENTS.md` exists at the target root and carries the godmode instructions (marker check)
- `skills/`, `agents/`, and `.agents/skills` are wired as symlinks
- the live skill count under `.agents/skills/` matches the source clone (counted dynamically, never a hardcoded total)
- every skill's frontmatter `name:` equals its directory name — Amp drops mismatches
- `.godmode/` exists with a parseable `config.yaml`

The script's pass/fail summary is the verification of record — treat anything it does not check as unverified.

---

## Troubleshooting

### Skills stopped loading after moving the godmode clone

The installer symlinks absolute paths. Move or re-clone godmode and those links break, so Amp finds no project skills. Re-run the installer against the target; it reports each stale link as skip-with-reason. Remove the stale links it names, then re-run once more to relink them:

```bash
rm skills agents .agents/skills
bash adapters/amp/install.sh /path/to/your/project
```

### A godmode skill resolves to the wrong workflow (global shadowing)

Per the resolution order above, the user-global skill directories outrank project `.agents/skills/` by frontmatter name. A personal skill named `test`, `debug`, `build`, or any other godmode catalog name shadows the godmode skill in every project on the machine. Check the global directories:

```bash
ls ~/.config/agents/skills/ ~/.agents/skills/ ~/.config/amp/skills/ 2>/dev/null
```

Rename or remove the colliding global skill to let the godmode one load, or keep it and accept the override deliberately.

### Committing godmode for a team

The `.agents/skills` symlink keeps skills in sync with your clone but cannot be committed usefully — it points at an absolute path on your machine. For a committable install, replace the symlink with a dereferenced real copy:

```bash
rm -rf .agents/skills.real
cp -rL "$(readlink -f .agents/skills)" .agents/skills.real
rm .agents/skills
mv .agents/skills.real .agents/skills
```

The root `skills/` and `agents/` symlinks point at the same absolute path and are equally uncommittable — either give them the same `cp -rL` treatment or gitignore all three paths and document that teammates run the installer themselves.

Trade-off: the copy no longer tracks the clone — repeat the copy after updating godmode. (`verify.sh` counts skills through either form.)

### verify.sh fails the AGENTS.md marker check

The target already had a user-authored `AGENTS.md`, so the installer wrote godmode's content to `AGENTS.godmode.md` instead of overwriting yours. Amp only auto-loads `AGENTS.md` (with `AGENT.md`/`CLAUDE.md` fallbacks) — it never loads `AGENTS.godmode.md`. Merge the godmode sections from the sidecar into your `AGENTS.md`, then re-run `verify.sh`.

---

## License

MIT — see [LICENSE](../../LICENSE).
