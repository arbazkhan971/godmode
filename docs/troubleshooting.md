# Troubleshooting Guide

Common issues across all five platforms: Claude Code, Gemini CLI, OpenCode, Cursor, and Codex.

---

## 1. Installation Issues

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

### "/godmode: command not found"

Each platform resolves skills differently:
- **Claude Code:** `commands/godmode.md` and `commands/godmode/*.md`
- **Gemini CLI:** `GEMINI.md` referencing `skills/`
- **Cursor:** `.cursorrules` referencing `skills/`
- **Codex:** `AGENTS.md` and `.codex/agents/*.toml`
- **OpenCode:** `.opencode/plugins/godmode/plugin.json`

Verify the entry file exists in your project root. Re-run the installer if missing.

### ".godmode/ directory missing"

Run `/godmode:setup` or `bash hooks/init.sh`. Both create `.godmode/`, generate `config.yaml`, and touch the TSV tracking files.

---

## 2. Skill Runtime Issues

### "/godmode:optimize ran 20 iterations but kept 0 changes"

**Diagnosis:** Every attempted change either failed the guard (test_cmd) or produced no metric improvement.

**Fixes:**
1. Run your guard command manually first (`npm test` / `pytest` / `cargo test`). If tests already fail, run `/godmode:fix` before optimizing.
2. Run your metric command and confirm it outputs a single number. If it outputs tables or ANSI codes, wrap it in a script that extracts one number.
3. Check `.godmode/optimize-results.tsv` for patterns. If every row shows the same metric value, your metric may be returning a cached result.
4. Narrow the scope in `.godmode/config.yaml`:
   ```yaml
   scope:
     include: ["src/api/handler.ts", "src/db/queries.ts"]
   ```

### "/godmode:build produced no output"

**Diagnosis:** The build skill requires `.godmode/plan.yaml` with unimplemented tasks. No plan means nothing to build.

**Fixes:**
1. Check if the plan exists: `cat .godmode/plan.yaml`. If missing, run `/godmode:plan` first.
2. If the plan exists but all tasks are marked complete, there is nothing left to build. Run `/godmode:plan` again with a new scope.
3. Check that `build_cmd` is set in `.godmode/config.yaml`. If the stack was not detected, the skill has no build command to verify against and may exit silently. Run `/godmode:setup` to re-detect.

### "/godmode:test says 'no test framework detected'"

**Diagnosis:** Stack detection found no recognizable project file (package.json, pyproject.toml, Cargo.toml, go.mod, etc.) in the project root.

**Fixes:**
1. Confirm you are running from the project root, not a subdirectory.
2. Set the test command explicitly in `.godmode/config.yaml`:
   ```yaml
   test_cmd: "npx vitest run"                    # non-standard layout
   test_cmd: "cd packages/core && npm test"       # monorepo
   coverage_cmd: "zig build test 2>&1 | grep 'covered'"  # unsupported framework
   ```

### "/godmode:fix loops forever without fixing anything"

**Diagnosis:** The fix skill reverts each attempt because the error count does not decrease. This means every fix either introduces a new error or does not address the root cause.

**Fixes:**
1. Check `.godmode/fix-log.tsv` for the pattern. If you see the same error file:line repeated with `reverted` status, the skill is stuck on one error:
   ```bash
   column -t -s $'\t' .godmode/fix-log.tsv | tail -20
   ```
2. The fix skill processes errors in priority order: build > type > lint > test. If the build is broken, lint and test errors are unreachable. Fix the build error manually, then re-run.
3. If the skill hit its 3-attempt limit per error and skipped it, but the skipped error blocks everything downstream, fix it manually. The skill prints skipped errors at the end -- address those first.
4. Check that `test_cmd` actually exits non-zero on failure. Some custom scripts swallow errors. Test with: `your_test_cmd; echo "exit: $?"`.

### "/godmode:review gives only generic feedback"

**Diagnosis:** The review skill operates on `git diff main...HEAD`. If that diff is empty or tiny, there is not enough context.

**Fixes:**
1. Verify the diff is non-empty: `git diff main...HEAD --stat`. If empty, you are probably on main -- create a feature branch first.
2. For large diffs (500+ lines), the skill splits by directory. Each chunk may lack context. Review smaller PRs.
3. If `.godmode/spec.md` exists, the skill reviews against it. Without a spec, feedback defaults to general best practices. Write a spec with `/godmode:think` for targeted results.
4. Rule 1 requires every finding to include `file:line + suggested fix`. If output is vague, re-invoke with explicit scope: `/godmode:review src/api/`.

### "/godmode:secure finds 0 vulnerabilities (false negative)"

**Diagnosis:** The secure skill scans in layers: dependency audit, secret grep, STRIDE modeling, OWASP Top 10. Zero findings usually means one layer short-circuited.

**Fixes:**
1. Check that the dependency audit tool is installed:
   ```bash
   npm audit --json    # Node
   pip audit           # Python (install: pip install pip-audit)
   cargo audit         # Rust (install: cargo install cargo-audit)
   ```
   If the tool is missing, the skill skips that layer silently.
2. Verify the skill scanned actual routes. If your app has no running server and no route definitions the skill can grep for, it may find nothing to test. Point it at specific files:
   ```
   /godmode:secure src/routes/ src/middleware/auth.ts
   ```
3. Check `.godmode/security-findings.tsv`. If rows exist but all show `Low` severity, the skill did find issues but none rated Critical or High. The summary may say "PASS" even with low-severity findings.

### "/godmode:ship fails at preflight"

**Diagnosis:** The ship skill runs a 5-point checklist (build_cmd, lint_cmd, test_cmd, secrets grep, TODO/FIXME grep). Any single failure blocks the ship.

**Fixes:**
1. Identify which check failed from the output, then fix directly:
   ```bash
   npm run build                                    # build failure
   grep -rn 'API_KEY\|SECRET' $(git diff main..HEAD --name-only)  # secrets
   grep -n 'TODO\|FIXME' $(git diff main..HEAD --name-only)       # TODOs
   ```
2. Intentional TODOs must be removed or moved to a tracking issue before shipping.
3. If `gh` CLI is not authenticated, PR creation fails. Run `gh auth status` to verify.

### Skill says "stack not detected"

**Diagnosis:** The orchestrator checks the project root for known files (package.json, pyproject.toml, Cargo.toml, go.mod, Gemfile, pom.xml). No match triggers the prompt.

**Fixes:**
1. Make sure you are invoking the skill from the project root, not a parent or child directory.
2. For non-standard stacks or missing project files, set commands manually in `.godmode/config.yaml`:
   ```yaml
   stack: "custom"
   test_cmd: "make test"
   lint_cmd: "make lint"
   build_cmd: "make build"
   ```
3. Run `/godmode:setup` to re-trigger detection. The setup skill caches the result so subsequent skills skip detection.

### "TSV log file is empty or malformed"

**Diagnosis:** The TSV file exists but contains no data rows, or columns are misaligned.

**Fixes:**
1. Confirm the `.godmode/` directory is writable: `ls -la .godmode/`.
2. If the file is empty, a previous skill run may have crashed before logging. Check git log for evidence of work:
   ```bash
   git log --oneline -10
   ```
   If commits exist but the TSV is empty, the logging step was skipped. Re-running the skill will append to the file going forward.
3. If columns are misaligned, a field value may contain a tab character. Inspect with:
   ```bash
   cat -A .godmode/optimize-results.tsv | head -5
   ```
   Fix by editing the file to remove stray tabs from description fields.

### "Git revert failed during optimize loop"

**Diagnosis:** `git reset --hard HEAD~1` fails when the working tree has uncommitted changes or HEAD is in an unexpected state.

**Fixes:**
1. Check for uncommitted changes (`git status`) and stash them before running iterative skills.
2. Abort any in-progress merge or rebase: `git merge --abort` or `git rebase --abort`.
3. If the skill left a dirty state, find the last good commit and reset:
   ```bash
   git log --oneline -5          # find the last good commit
   git reset --hard <commit_sha> # reset to it
   ```
4. Clean orphaned worktrees: `git worktree list && git worktree prune`.

---

## 3. Multi-Agent Issues

### "Agent worktree merge conflict"

When parallel agents modify overlapping files, the sequential merge step will hit conflicts. This is expected behavior -- the skill discards the conflicting merge and logs it as `DISCARDED`.

**If conflicts happen every round:**
1. Check that tasks in `.godmode/plan.yaml` have non-overlapping `files` lists. If two tasks both touch `src/index.ts`, they will always conflict when merged in the same round.
2. Re-run `/godmode:plan` and ask it to sequence dependent tasks rather than parallelize them.
3. Manually reorder the plan so conflicting tasks run in separate rounds.

**Recovering from a stuck merge state:**
```bash
git merge --abort              # if merge is in progress
git worktree list              # find orphaned worktrees
git worktree remove <path> --force
git worktree prune
```

### "Agent timed out"

Each agent has a 5-minute timeout (optimize, build). If the task is too large or the verification suite is slow, agents will time out.

**Fixes:**
1. Break large tasks into smaller ones. Each build task should touch 1-3 files.
2. Speed up your test suite. If `npm test` takes 4 minutes, agents have almost no time for implementation. Consider running only relevant tests:
   ```yaml
   test_cmd: "npx vitest run --reporter=verbose"
   ```
3. For the optimize skill, ensure your metric command completes in under 30 seconds. A slow metric (e.g., full benchmark suite) burns most of the 5-minute budget on measurement alone.

### "Too many agents spawned"

Skills cap agents at 3 (optimize) or 5 (build) per round. If you see more, the loop counter may have reset due to a crash mid-round.

**Fixes:**
1. Check for orphaned worktrees that indicate a previous incomplete run:
   ```bash
   git worktree list
   ```
   Prune stale entries: `git worktree prune`.
2. Delete `.godmode/session-log.tsv` entries for the crashed session, then re-run. The skill reads the log to determine where to resume.
3. If the agent count is correct but the system feels overloaded, reduce parallelism by adding a note to your invocation: `/godmode:optimize -- max 1 agent per round`.

### "Sequential fallback not working on Gemini/OpenCode"

The sequential fallback (`adapters/shared/sequential-dispatch.md`) should activate automatically when `Agent()` and `EnterWorktree` are unavailable.

**Fixes:**
1. Verify the platform adapter is installed. Each platform needs its entry file:
   - Gemini CLI: `GEMINI.md` in project root
   - OpenCode: `.opencode/plugins/godmode/plugin.json`
   - Codex: `AGENTS.md` and `.codex/agents/*.toml`
2. Re-run the installer: `bash adapters/<platform>/install.sh .`
3. If the skill still tries to call `Agent()`, the SKILL.md file may not contain the Platform Fallback section. Pull the latest: `git pull origin master` from the godmode repo.
4. As a manual workaround, tell the model explicitly: "Run tasks sequentially, one at a time, using branch isolation instead of worktrees."

---

## 4. Reading the Logs

All logging goes to `.godmode/`. Commit this directory to version control so history persists across sessions and teammates.

### Skill result files: `.godmode/*-results.tsv`

Each iterative skill appends one row per iteration to its own TSV file:

| File | Columns |
|------|---------|
| `optimize-results.tsv` | round, agent, change_description, metric_before, metric_after, status |
| `fix-log.tsv` | iteration, error, file, fix_description, status |
| `test-results.tsv` | iteration, test_file, lines_covered, coverage_before, coverage_after, delta |
| `build-log.tsv` | round, task_id, agent_time_ms, status |
| `review-log.tsv` | timestamp, scope, category, severity, file_line, description, status |
| `security-findings.tsv` | iteration, category, persona, finding, severity, file_line, status |
| `ship-log.tsv` | timestamp, type, commit_sha, outcome, url |

View any TSV file in a readable format:
```bash
column -t -s $'\t' .godmode/optimize-results.tsv
```

### Session log: `.godmode/session-log.tsv`

The orchestrator appends one row per skill invocation:
```
timestamp    skill      iters    kept    discarded    outcome
```

Use this to see the history of all godmode activity in the project:
```bash
column -t -s $'\t' .godmode/session-log.tsv
```

### Status values: "kept", "discarded", "crash"

- **kept** -- The change passed the guard (tests) and improved the target metric (or completed the task). It was committed to the main branch.
- **discarded** -- The change either failed the guard, did not improve the metric, or caused a merge conflict. It was reverted with `git reset --hard HEAD~1` or `git merge --abort`. No trace remains in git history.
- **crash** -- The agent or skill crashed before completing verification. The working tree may be dirty. Run `git status` to check, and `git stash` or `git reset --hard HEAD` to recover if needed.

A healthy optimize run looks like: mostly `discarded` with occasional `kept` rows. A run that is all `discarded` means the metric or guard is misconfigured (see Section 2). A run with `crash` entries means something interrupted execution.

### Resuming from a partial run

If a skill was interrupted (terminal closed, timeout, crash), you can resume:

1. Check what was accomplished:
   ```bash
   column -t -s $'\t' .godmode/optimize-results.tsv | tail -10
   git log --oneline -10
   ```
2. Verify the repo is clean:
   ```bash
   git status
   git worktree prune
   ```
3. Re-invoke the same skill. It reads the TSV log and git history to determine the current state. For optimize, it re-measures the baseline from the current code. For build, it checks which plan tasks have commits.
4. If the repo is dirty, clean up first:
   ```bash
   git stash           # save uncommitted work
   git worktree prune  # remove orphaned worktrees
   ```

---

## 5. Getting Help

### Reporting issues

1. Run `/godmode:setup --validate` to check your configuration. Include the output in your report.
2. Collect the relevant log files:
   ```bash
   cat .godmode/session-log.tsv
   cat .godmode/optimize-results.tsv   # or whichever skill failed
   git log --oneline -20
   ```
3. Open an issue on the godmode repository with the `bug` label. Include:
   - Platform (Claude Code / Gemini CLI / OpenCode / Cursor / Codex)
   - Skill that failed and the exact invocation
   - TSV log output
   - Error message or unexpected behavior description

### Contributing fixes

1. Fork the repository and create a branch: `git checkout -b fix/description`.
2. Skill definitions live in `skills/<name>/SKILL.md`. Platform adapters live in `adapters/<platform>/`.
3. Test your change by running the affected skill on a real project.
4. Submit a PR with a clear description of the problem and fix.

### Quick reset

If nothing else works, start fresh:
```bash
rm -rf .godmode/
/godmode:setup
```
This re-detects your stack, regenerates `config.yaml`, and creates empty TSV files. Your git history is unaffected.
