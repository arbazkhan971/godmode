# Troubleshooting Guide

Common issues across all five platforms: Claude Code, Gemini CLI, OpenCode, Cursor, and Codex.

---

## Installation Issues

### "Skill not found" when invoking `/godmode:skillname`

The `skills/` directory is not symlinked into your project. Re-run the installer for your platform:
```bash
bash adapters/<platform>/install.sh /path/to/your/project
```
Verify with `ls -la skills/` -- it should point to the godmode repository's `skills/` directory. Broken symlink? Remove it and re-run.

### "Permission denied" when running install.sh

The script lacks execute permission. Either `chmod +x adapters/<platform>/install.sh` or invoke it with `bash adapters/<platform>/install.sh`.

### Symlink errors on Windows

Windows does not support POSIX symlinks outside WSL. Run the installer from a WSL terminal:
```bash
cd /mnt/c/Users/you/projects/your-project
bash /mnt/c/Users/you/godmode/adapters/cursor/install.sh .
```
Without WSL, copy instead of symlinking: `cp -r /path/to/godmode/skills ./skills`

### "GEMINI.md not found" during Gemini CLI install

The installer validates `GEMINI.md` at the godmode repo root. Confirm it exists (`ls /path/to/godmode/GEMINI.md`). If missing, pull the latest: `git pull origin master`.

---

## Runtime Issues

### "/godmode: command not found"

Each platform resolves skills differently:
- **Claude Code:** `commands/godmode.md` and `commands/godmode/*.md`
- **Gemini CLI:** `GEMINI.md` referencing `skills/`
- **Cursor:** `.cursorrules` referencing `skills/`
- **Codex:** `AGENTS.md` and `.codex/agents/*.toml`
- **OpenCode:** `.opencode/plugins/godmode/plugin.json`

Verify the entry file exists in your project root. Re-run the installer if missing.

### "Agent() tool not available"

Expected on non-Claude-Code platforms. `Agent()` is Claude Code only. Skills fall back to sequential execution automatically -- same results, slower throughput. See `adapters/shared/sequential-dispatch.md`.

### "EnterWorktree not found"

Worktree isolation is Claude Code only. Other platforms use branch-based isolation:
```bash
git checkout -b godmode-{task}
# work, test, commit
git checkout main && git merge godmode-{task}
git branch -d godmode-{task}
```
This is handled automatically by the sequential dispatch protocol.

### Tests failing after merge

Tasks built in separate branches can conflict when merged. Follow `adapters/shared/sequential-dispatch.md`:
1. Merge conflicts: `git merge --abort`, log as DISCARDED, move on.
2. Tests fail post-merge: `git reset --hard HEAD~1`, log as DISCARDED, move on.

### ".godmode/ directory missing"

Run `/godmode:setup` or `bash hooks/init.sh`. Both create `.godmode/`, generate `config.yaml`, and touch the TSV tracking files.

### "config.yaml not found"

Run `/godmode:setup` to regenerate, or run the platform installer which auto-detects your stack. See `docs/architecture.md` for the full config schema.

---

## Optimization Loop Issues

### "Metric command not outputting a number"

The verify command must produce a single number. Test it manually:
```bash
# Good -- outputs "0.142"
curl -s -w '%{time_total}' -o /dev/null http://localhost:3000/api

# Bad -- outputs a table
npm run bench
```
Wrap complex commands in a script that extracts one number:
```bash
#!/bin/bash
# .godmode/measure.sh
npm run bench 2>/dev/null | grep "ops/sec" | awk '{print $1}'
```
Set `verify: "bash .godmode/measure.sh"` in `config.yaml`.

### "Guard keeps failing"

The guard rail command (`test_cmd`) fails after every attempt.

1. Run the guard manually first (`npm test`). Fix pre-existing failures before optimizing.
2. The skill never modifies test files -- verify `scope.include` in `config.yaml` does not overlap with test directories.

### "Stuck: >5 consecutive discards"

Handled automatically. After 5 consecutive discards, the skill tries the opposite approach (simplifying vs. adding complexity, inlining vs. extracting). If still stuck, it moves to radical changes, then stops. The easy wins are exhausted -- consider `/godmode:think` to redesign.

### "Diminishing returns: early stop"

Three consecutive kept changes with <1% improvement triggers this sequence:
1. Try a radical change (different algorithm)
2. Try compounding previous small gains
3. Stop if neither breaks through

Re-run with a different goal or narrower scope if you believe more gains exist.

---

## Platform-Specific Issues

### Gemini CLI: tool name mismatch

Gemini uses different tool names. The mapping in `GEMINI.md` handles this automatically:

| Skill says | Gemini uses |
|---|---|
| Read | `read_file` |
| Write | `write_file` |
| Edit | `replace` |
| Bash | `run_shell_command` |

If tools are not resolving, verify `GEMINI.md` is in your project root.

### OpenCode: slash command not registering

OpenCode needs `.opencode/plugins/godmode/plugin.json`. Re-run `bash adapters/opencode/install.sh` and verify the manifest exists with `skills/`, `agents/`, `commands/` symlinked inside the plugin directory.

### Cursor: .cursorrules not loading

1. Confirm the file exists: `ls -la .cursorrules`
2. Restart Cursor -- it reads `.cursorrules` on workspace open, not dynamically.
3. If you had a pre-existing `.cursorrules`, the installer skipped it. Manually merge the Godmode rules.

### Codex: batch mode limitations

Codex runs single-threaded with no interactive prompts. For skills that ask questions (like `/godmode:think`), provide all context upfront: `codex "Run /godmode:think -- rate limiter, per-user, Redis, 100 req/min"`.

### Claude Code: worktree conflicts

Orphaned worktrees from previous sessions can cause conflicts:
```bash
git worktree list    # see all worktrees
git worktree prune   # remove stale entries
git worktree remove /path/to/worktree --force  # force-remove locked ones
```

---

## TSV/Logging Issues

### "TSV file empty"

Run `/godmode:setup` or `bash hooks/init.sh` to create the tracking files. Or manually:
```bash
touch .godmode/optimize-results.tsv .godmode/fix-log.tsv .godmode/ship-log.tsv
```

### "Results not persisting"

1. Confirm `.godmode/` exists and is writable: `ls -la .godmode/`
2. Check `.godmode/` is not in `.gitignore`
3. Commit `.godmode/` to version control so history persists across sessions and teammates

---

## Still Stuck?

1. Run `/godmode:setup --validate` to check configuration
2. Delete `.godmode/` and re-run `/godmode:setup` for a clean reset
3. Open an issue with the `question` label on the repository
