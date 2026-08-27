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

## Iteration 3

(Note: this fleet ran concurrently with the iteration-2 fleet on the same prompt window; its P2/P3 landing (8f46a05..8bd56a1) is acknowledged and built upon, not duplicated.)

### DONE
- P1 strengthened to its strongest form: tokens/SKILL.md tokenizer rationale reworded harness-neutral ("mainstream BPE tokenizers (GPT-4 and Llama families)"); CLAUDE_ALLOWLIST shrunk 2 -> 1 (only skills/research/SKILL.md, justified: functional `find -name CLAUDE.md` reference). `grep -ril claude skills/` == exactly the allowlist. Committed 37bf8a8.
- P3 polish: goal-bridge marketplace.json entry moved to correct alphabetical slot (git < goal-bridge < godmode) with description byte-identical to SKILL.md frontmatter. Committed 425ae4f.
- P2 dogfood gate re-verified first-hand on this machine: fresh backup -> install.sh (135/135) -> verify.sh 4/4 -> `pi -p -ne --skill ~/.pi/agent/skills/godmode/optimize/SKILL.md ...` printed GODMODE_SKILL_OK (exit 0). Live install now carries the harness-neutral tokens wording; test artifacts cleaned (no session delta).
- GATE round over the delta: reviewer APPROVE (1 NIT fixed in-commit: allowlist comment verb), security CLEAN (F1 LOW tokens emit-persistence + F2/F3 INFO hardening ideas logged below), tester 10/10 checks incl. negative test proving Check 6 still fails an empty allowlist.
- Validators green at push time: validate-skills FAIL:0 (PASS 523), validate-structure FAIL:0 (PASS 786, allowlist size 1).

### NEXT (ordered)
1. P4 README 2.0: one-sentence intro (keep/revert hook), support matrix (pi row exists; omp row after dir confirmed), honest demo labeling + GIF TODO. Also fold in the 134->135 sweep targets iteration 2 missed (if any remain) + demo label TODO.
2. P5 release engineering: CHANGELOG 2.0.0, version bumps + tag v2.0.0 + gh release, docs/blog/godmode-2.0-universal.md, 5 roadmap issues.
3. P6 listings & submissions: docs/marketing/submission-queue.md, >=3 real PRs, Show HN / r/ClaudeAI / X drafts.
4. P7 multi-model role routing (pi reference impl; zero-config default; GODMODE_MODEL_<ROLE>; godmode.models.json optional; doctor table; capability matrix).
5. Hardening backlog (from security gate, non-blocking): (a) optional PREFIX=/ rejection in adapters/pi/install.sh; (b) recommend projects gitignore .godmode/last-round-emit.txt in tokens SKILL.md guidance; (c) verify-common.sh:230 python3 -c filename interpolation -> switch to python3 - <<'EOF' or json.tool form.

### BLOCKERS
- none

### LESSONS
- Duplicate driver instances can race the same milestone: a concurrent fleet pushed P2/P3 (16:16-16:17) while this fleet planned. Protocol that worked: re-check `git fetch` + reflog before build, treat pushed state as authority, rebuild scopes around the delta, build on instead of revert. Consider driver-side locking (flock on a godmode-run lockfile) before launch.
- Build scopes must be derived from a freshly-pulled tree, not a stale one: 2 of 3 implementer tasks shrank to "verify-only" because the concurrent fleet had already landed the files. Cheap `git fetch origin && git log HEAD..origin/master --oneline` at council time would have revealed it.
- Reviewer NITs are cheap to fix pre-commit when the file is already in the delta scope; security INFO findings go to a hardening backlog, not into an unrelated diff (surgical-changes rule).

## Iteration 3 — Session B (P4 exit + P5 exit)

### DONE
- P4 exit: README 2.0 pushed (d4f785f) — one-sentence intro with the keep/revert hook, 8-harness support matrix (every install command verified against real adapter scripts), honest demo labeling + GIF TODO, `.markdownlint.json`, codex Quick Start parity line. markdownlint green via changed-files gate (README/CHANGELOG/blog).
- Adopted a prior concurrent fleet's uncommitted delta (README/CHANGELOG/pi-hardening/blog) instead of stashing: 3-planner council fact-checked every claim, lead re-verified empirically (PREFIX guard exit-1 matrix, json.tool semantics, 135 count) before building on it.
- Council-discovered functional bug fixed: all 4 adapter `verify.sh` scripts + `verify-common.sh` default hard-coded expected skill count 126 and FAILED against the 135-skill corpus (906a0f3, df8e7a0) — invisible to CI until now (issue #8).
- Count sweep: 22+ live files 126/134 → 135, incl. root `SKILL.md`, `adapters/cursor/.cursorrules` (+9 missing catalog rows; table now 135/135 verified), adapter install echoes + READMEs, 7 docs pages, opencode plugin.json description (869824c, fb9eb17).
- P5 exit: CHANGELOG 2.0.0 dated 2026-08-27 with [Unreleased] moved to canonical top (45bc44a); blog `docs/blog/godmode-2.0-universal.md` 689 words, all claims evidence-checked, indexed from docs/index.md (265c9d3); all FOUR manifests bumped to 2.0.0 (9e6d8e9); tag `v2.0.0` pushed; release live: https://github.com/arbazkhan971/godmode/releases/tag/v2.0.0; 5 roadmap issues filed: #5 (Amp adapter), #6 (P7 multi-model routing), #7 (omp dir), #8 (CI prose hardening), #9 (real demo captures).
- Gate trio over merged diff vs 198bb73: tester 12-group matrix — 11 outright PASS, 1 BLOCKER found and fixed (`.cursorrules` leak); reviewer REQUEST_CHANGES items F1–F3 fixed, F4 disproven against base blob; security secrets/injection scan clean; validators FAIL:0 ×2 + markdownlint clean at push. 10 atomic conventional commits, 3 pushes total (master, tag, ledger).

### NEXT (ordered)
1. P6 listings & submissions: `docs/marketing/submission-queue.md`, per-target format research + ≥3 real PRs (fork → branch `add-godmode` → sibling-format entry → `gh pr create`), Show HN / r/ClaudeAI / X launch drafts in `docs/marketing/drafts/`.
2. P7 multi-model role routing (pi = reference implementation; zero-config default; GODMODE_MODEL_<ROLE>; godmode.models.json optional; doctor table; capability matrix) — spec filed as issue #6.
3. Backlog tracked as issues: #5 Amp adapter, #7 omp dir confirmation, #8 CI hardening (lint:md dep fix, repo-wide markdownlint, prose-count gate incl. extensionless files), #9 real demo captures.
4. Verify CI green on pushed SHA fb9eb17.

### BLOCKERS
- none

### LESSONS
- Census greps with `--include` extension globs miss extensionless adapter artifacts: `.cursorrules` ships verbatim into Cursor users' repos and its catalog TABLE drifts independently of prose counts — gate table row count against the disk skill count (lesson filed into #8).
- Version-bump surface must be enumerated by repo-wide grep (`"version":`), not memory: the 4th manifest (`adapters/opencode/plugin.json` at 1.0.0) was caught only at gate review.
- An implementer reported `.cursorrules` fixed but had not touched it; the tester's "classify EVERY remaining census hit" mandate caught the false completion claim. Gate redundancy pays — keep the census mandate explicit.
- Reviewer F4 suspected two CHANGELOG Planned bullets were newly added; `git show 198bb73:CHANGELOG.md` disproved it (pre-existing content, relocated). Check the base blob before accepting an additions-claim.
- opencode plugin.json "9 subagents" is correct as-is (7 dispatch roles + code-reviewer + spec-reviewer, matching its own agents.definitions); taxonomy drift (11 categories / 12 plugin keys / 13 domains) deferred to #8 as a content task, not silently edited during a count sweep.
