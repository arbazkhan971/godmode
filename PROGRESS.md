# PROGRESS — godmode 2.0 mission ledger

Append-only log per GOAL.md standing rule 7. One section per iteration: DONE / NEXT / BLOCKERS / LESSONS.

## Iteration 1

### DONE
- P0 exit: both validators green on the clone (`bash tests/validate-skills.sh` exit 0, `bash tests/validate-structure.sh` exit 0).
- P0 exit: push access proven — branch up to date with origin/master, prior overnight-session commits landed (f0bc987…8dceddc).
- PROGRESS.md ledger created (this file).

### NEXT (ordered)
1. P1 universal core (this iteration): de-Claude 5 skill bodies (tutorial, setup, research, tokens, agent) + add allowlisted "claude" wording gate to `tests/validate-structure.sh`.
2. P2 pi/omp adapter (`adapters/pi/install.sh`, `verify.sh`) + dogfood gate on this machine.
3. P3 goal-bridge skill + verify/ship amendments.
4. P4 README 2.0 (one-sentence intro, support matrix).
5. P5 release engineering (CHANGELOG 2.0.0, tag, blog, 5 roadmap issues).
6. P6 listings & submissions (submission queue, ≥3 PRs, 3 launch drafts).

### BLOCKERS
- none

### LESSONS
- (appended at end of iteration)

## Iteration 2

### DONE
- P1 exit: pushed (3883053 de-Claude tutorial/setup/agent; c4430ab claude-wording gate with allowlist). research (CLAUDE.md filename pattern) + tokens (tokenizer fact) kept as justified allowlist entries per exit criterion "0 or allowlisted".
- P2 exit: `adapters/pi/` shipped (install.sh / verify.sh / README.md). PREFIX env + positional override for omp forks; omp dir remains undocumented -> installer prints both candidate paths (~/.omp/agent/skills, ~/.config/omp/skills), TODO stands. DOGFOOD GATE PASSED on this machine: real install 135/135, verify.sh 4/4, `pi -p -ne --skill ~/.pi/agent/skills/godmode/optimize/SKILL.md ...` printed GODMODE_SKILL_OK.
- P3 exit: `skills/goal-bridge/SKILL.md` created (metric command / threshold / evidence path / rollback trigger; exit-0 contract); verify + ship emit the byte-identical contract block as mandatory final output; skill count bumped to 135 across README, AGENTS.md, GEMINI.md, OPENCODE.md, CONTRIBUTING.md, package.json, marketplace.json, token-bench.sh; goal-bridge registered in marketplace.json + all catalogs. Validators green (skills exit 0 FAIL:0, structure exit 0), route-eval accuracy 100.
- Fleet usage: Round A 3 scouts (pi mechanics / adapter conventions / P3 insertion points) -> Round B 5 implementers (install.sh, verify.sh, adapter README, goal-bridge, verify+ship amendments; disjoint scopes) -> Round C reviewer + tester parallel over merged diff -> lead fixed all findings.

### NEXT (ordered)
1. P4 README 2.0: one-sentence intro (keep/revert hook), support matrix table, honest demo labeling + GIF TODO.
2. P5 release engineering: CHANGELOG 2.0.0, version bumps + tag v2.0.0 + gh release, docs/blog/godmode-2.0-universal.md, 5 roadmap issues.
3. P6 listings & submissions: submission-queue.md, per-target research + >=3 real PRs, Show HN / r/ClaudeAI / X drafts in docs/marketing/drafts/.
4. P7 multi-model role routing (pi = reference implementation; zero-config default, GODMODE_MODEL_<ROLE> env, godmode.models.json optional).

### BLOCKERS
- none. (omp skill dir undocumented on this machine and in docs - handled per no-silent-guessing protocol; unblocks nothing.)

### LESSONS
- `tests/validate-skills.sh` Check 4 hard-fails any on-disk skill missing from `.claude-plugin/marketplace.json` - register new skills at creation time, not at gate time (caught by reviewer, would have red CI).
- Skill-count live sites: README, AGENTS.md, GEMINI.md, OPENCODE.md, CONTRIBUTING.md, package.json (2), marketplace.json description, token-bench.sh comment. After ANY skill add, grep the old count everywhere; point-in-time docs (promises-audit, session reports) stay frozen.
- Adding a skill costs ~+114 Tier-1 routing tokens (13902 -> 14016); route accuracy held at 100%. Fold into the next description-trim pass.
- Round-C gate value proven: reviewer caught the marketplace.json blocker + 2 LOW script defects (stale-dest reinstall, find -type f asymmetry) before push; tester's negative-path sandbox test proved verify.sh fails loudly on empty dirs.
