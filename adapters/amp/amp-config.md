# Amp Configuration Guide for Godmode

## No Generated Config File

Unlike the Codex adapter, which generates `.codex/config.toml` and per-agent TOML files, the Amp adapter generates no config file at all. Amp's platform configuration for godmode consists of exactly two wirings, both created by `adapters/amp/install.sh`:

1. The root `AGENTS.md` — godmode's own instruction file, copied to the target root. Amp loads it natively.
2. The `.agents/skills/` directory — a symlink to godmode's skills tree. This is the directory Amp loads project skills from.

There is no TOML, JSON, or YAML platform config to tune and nothing to hand-edit to activate godmode. The only YAML in play is `.godmode/config.yaml`, which is godmode's own state layer (test/lint commands, tracking TSVs), not an Amp setting.

## AGENTS.md Discovery

Per [Amp's AGENTS.md documentation](https://ampcode.com/docs/customize/agents-md), Amp reads `AGENTS.md` natively from the current working directory, every parent directory up to `$HOME`, and subtrees. Two global files are always included: `~/.config/amp/AGENTS.md` and `~/.config/AGENTS.md`. When `AGENTS.md` is absent, `AGENT.md` and `CLAUDE.md` are fallbacks.

This is why the installer copies godmode's `AGENTS.md` to the target root: root placement guarantees pickup regardless of where in the repository Amp starts. It also explains the sidecar rule below — a file named anything other than `AGENTS.md` (or its two fallbacks) is never auto-loaded.

## Install Footprint

Every step of the installer is skip-if-present, so the footprint is idempotent. After installing, the target project contains:

| Target path | What lives there | Who reads it |
|-------------|------------------|--------------|
| `AGENTS.md` | godmode's full instruction file — workflow, skill catalog, role table | Amp, via native AGENTS.md discovery |
| `AGENTS.godmode.md` | godmode content sidecar; written only when the target already has a user-authored `AGENTS.md` | Nothing automatically — merge it into your `AGENTS.md` |
| `.agents/skills/` | Symlink to the godmode clone's `skills/` tree | Amp's project-skill loader |
| `skills/` | Symlink to the godmode clone's `skills/` tree | Skill workflows and docs referencing `./skills/<name>/SKILL.md` |
| `agents/` | Symlink to the godmode clone's `agents/` role definitions | Reference only — not injected into Amp's subagents |
| `.godmode/` | `config.yaml` (stack auto-detection: test/lint commands) plus tracking TSVs | godmode skills, on any platform |

## The AGENTS.godmode.md Sidecar

The installer never clobbers an existing `AGENTS.md`. The flow when the target already has one:

1. The installer detects a user-authored `AGENTS.md` at the target root.
2. It writes godmode's content to `AGENTS.godmode.md` alongside it.
3. Amp does not auto-load that filename — `AGENTS.md` is the only first-choice file, with `AGENT.md` and `CLAUDE.md` as fallbacks.
4. You merge the godmode sections from `AGENTS.godmode.md` into your `AGENTS.md`, then re-run `verify.sh`, which checks that `AGENTS.md` carries the godmode marker text.

## Manual Wiring

To reproduce the installer's footprint by hand (the config-relevant parts only):

```bash
# 1. The instruction file Amp loads natively
cp /path/to/godmode/AGENTS.md AGENTS.md

# 2. Amp's project-skill directory
mkdir -p .agents
ln -s /path/to/godmode/skills .agents/skills

# 3. Root symlinks so ./skills/<name>/SKILL.md paths resolve
ln -s /path/to/godmode/skills skills
ln -s /path/to/godmode/agents agents
```

The `.godmode/` state directory is optional glue for godmode skills, not an Amp requirement — the two wirings above are what make Amp load godmode. If a user-authored `AGENTS.md` already exists, skip step 1 and merge instead of copying (see the sidecar flow above).

## Skills Mechanics

Project skills live in `.agents/skills/`, committed with the project. Per [Amp's skills documentation](https://ampcode.com/docs/customize/skills), each skill directory holds a `SKILL.md`, and the directory name must equal the frontmatter `name:` value — Amp silently drops mismatches. This is why `verify.sh` enforces the name-equals-directory rule across the whole tree.

Amp resolves a skill by frontmatter name, first match wins, in this order:

1. `~/.config/agents/skills/`
2. `~/.agents/skills/`
3. `~/.config/amp/skills/`
4. project `.agents/skills/` (and its parent directories)
5. `.claude/skills/` (and parents)
6. `~/.claude/skills/`
7. `~/.claude/plugins/cache/`
8. directories configured on `amp.skills.path`
9. Amp's built-in skills

Because the project directory sits fourth, the user-global directories above it shadow godmode skills by name. `verify.sh` cannot detect that shadowing — it only proves the project skills are present and loadable.

## Global Files (informational)

Amp always includes the global instruction files `~/.config/amp/AGENTS.md` and `~/.config/AGENTS.md`, and you can keep personal skills in `~/.config/agents/skills/` — the top of the resolution order. Godmode installs nothing globally and needs nothing there; the shell installer (`adapters/amp/install.sh`) is the supported install path.

One caveat before using global skills: they outrank project skills by frontmatter name, everywhere on the machine. A personal skill named `test`, `debug`, or any other godmode catalog name shadows the godmode skill of the same name in every project. Keep global skill names disjoint from the godmode catalog, or accept the shadowing deliberately.
