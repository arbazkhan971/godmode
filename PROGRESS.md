M2_MISSION_STATUS: COMPLETE

MISSION_STATUS: COMPLETE

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

## Iteration 4 — P6 exit (listings & submissions)

### DONE
- P6 exit pushed: `docs/marketing/submission-queue.md` — 16 targets, per-target status + format research (Totals: TODO 0 / SKIP 8 / NEEDS_HUMAN 4 / PR_OPEN 4 / PR_MERGED 0; totals recount verified by tester).
- >=3 real PRs requirement exceeded — 4 verified OPEN (all +1/-0 README bullets except the OpenCode YAML +4/-0): BehiSecc/awesome-claude-skills#639, ComposioHQ/awesome-claude-skills#1748, Prat011/awesome-llm-skills#228, awesome-opencode/awesome-opencode#653. Sibling-format entries, authorship disclosed, dedup clean per target.
- 8 drafts in `docs/marketing/drafts/` — 3 launch (show-hn, reddit-claudeai, x-launch-thread; human-fires banner line 1, authorship disclosed, no engagement asks) + 5 target (hesreallyhim entry+web-form checklist; JosiahSiegel JSON byte-identical to our manifest + vendoring options A/B; agentskills-io proposed entry + 4 open questions; anthropics-skills SKIP analysis + goal-bridge port option; anthropics-claude-plugins-official form entry + checklist).
- Fleet pattern: 3-planner council (caught stale premise: a concurrent fleet had already written all drafts) -> 5 implementers audit/repair in parallel (23 surgical fixes incl. a banned live stars badge and a 97-char invented manifest description -> byte-exact 144-char real one) -> reviewer + security + tester gate in parallel -> lead fixed all findings (MD034 bare URL; undeclared docs/index.md Marketing section accepted in-scope + recorded in commit; internal fleet vocabulary neutralized in public drafts per security LOW).
- Gates at push: validate-skills FAIL:0, validate-structure FAIL:0, markdownlint 0 issues in 9 files, banned-claim grep clean (all star mentions are target-repo research metadata), X-thread 8/8 tweets <=280 recomputed, HN titles 80/77 chars, 4 PRs re-verified OPEN at gate time.

### NEXT (ordered)
1. P7 multi-model role routing (pi reference impl; zero-config default; GODMODE_MODEL_<ROLE> env; godmode.models.json optional; doctor table; capability matrix; validator gate) — spec in issue #6.
2. Human-fire queue: Show HN / r/ClaudeAI / X thread drafts; 4 NEEDS_HUMAN forms (hesreallyhim web form, claude-plugins-official directory form, JosiahSiegel vendoring go/no-go, agentskills.io channel decision).
3. Monitor the 4 PR_OPEN listings for merges/closes; update queue statuses + Totals on change.
4. Backlog issues: #5 Amp adapter, #7 omp dir, #8 CI prose hardening, #9 real demo captures.

### BLOCKERS
- none

### LESSONS
- Third consecutive concurrent-fleet race this mission: the "7 empty drafts" premise was false within minutes (a sibling fleet wrote all drafts, added an 8th, and edited docs/index.md mid-flight). Mitigations that held: fresh census before every phase, gates audit the working TREE not the dispatch inventory, commit only what was gated.
- Both gate agents independently caught the undeclared 8th draft + index edit because they were told to read the tree. Make "the brief lies; the tree is truth" a standing clause in gate dispatches.
- Marketing copy is mechanically checkable: banned-claim greps, per-tweet char recomputation (URL=23), manifest byte-comparison, and shields.io URL audits caught a live stars badge, a fabricated description, stale char-count comments, and a non-CTA closer — all things eyeball review waves through.
- Status lines that describe the authoring moment ("the lead commits", "this lane's only write") go stale or leak pipeline vocabulary the moment the artifact is pushed; neutralize before committing public handoff docs (security gate LOW, fixed pre-push).
- Fourth race, now at the git-index layer: while this fleet ran its 4-commit sequence, the sibling fleet's `git commit` consumed our staged index — their commit 522b454 landed our files+fixes under their (accurate, conventional) message, and commits 2-3 then found nothing to commit. Benign here, but two fleets sharing one worktree share one index: without a driver-side lock (flock on a godmode-run lockfile) a commit can be mislabeled or half-absorbed. Verify committed blobs (git show HEAD:<path>) after any suspicious commit failure — never assume the other lane's commit is wrong; never rewrite history to "reclaim" authorship.

## Iteration 4 — Session B (P6 verification + landing)

(Ran concurrently with the Iteration 4 fleet above on the same tree; their draft authoring + ledger entry are acknowledged and built upon. This session's contribution: independent verification, gap-closure, gate, and the landing commit.)

### DONE
- 3-planner council (completeness / risk-verification / scope-sequencing). Lens 3 died on a glm-5.3 429 -> lead absorbed its scope (gates enumerated: CI = validators only; markdownlint dep broken per #8; manual lint checks substituted). Lens 2 escalated honestly (no Bash tool) -> lead ran the full GET-only gh suite and fed evidence back (supervisor reply); verdict SAFE TO LAND.
- Empirical PR verification: all 4 PRs OPEN, author arbazkhan971, add-godmode branch, minimal diffs (+1/-0 x3, +4/-0 YAML), sibling-format entries confirmed via gh pr diff, authorship disclosed, dedup clean (only our 4 PRs exist at all targets), zero inclusion-asking issues -> no protocol violations. Re-verified OPEN again at push time.
- Spot-checks confirmed queue claims: hesreallyhim CONTRIBUTING bans PRs ("Do not open a PR. Just fill out the form."); anthropics/claude-plugins-official routes via clau.de form; e2b-dev/awesome-ai-agents lists a different Godmode (godmode.space) -> SKIP correct.
- 4 implementers (disjoint scopes) closed council gaps: NEW drafts/anthropics-claude-plugins-official.md + queue row pointer (GAP-1); anthropics-skills draft reconciled to final SKIP per lead decision (GAP-2); .claude/agents/ -> agents/ + .codex/agents/ path fix in hesreallyhim draft (GAP-4); docs/index.md Marketing section (GAP-3). Concurrent-fleet mid-flight edits to shared files detected and adopted, not reverted.
- Gate trio in parallel: tester 7/7 PASS (validators 523/0 + 792/0, queue census 16 rows = 0/8/4/4/0 exact, PR-iff-PR_OPEN, draft-per-NEEDS_HUMAN all exist, negative census test proved drift detection); reviewer APPROVE (1 NIT); security CLEAN (1 LOW).
- Lead fixed all gate findings pre-push: joined 4 mid-sentence split bullets in hesreallyhim draft (lines ~86-102); added re-pull-and-verify note on the agentskills.io discord invite at use time.
- Landed: commit 522b454 docs(marketing) — queue + 8 drafts + index Marketing section; validators green at commit time.

### NEXT (ordered)
1. P7 multi-model role routing (spec in issue #6) — last open phase.
2. Human-fire queue unchanged (see Iteration 4 above): 3 launch posts + 4 NEEDS_HUMAN forms; monitor 4 PR_OPEN for merges/closes.

### BLOCKERS
- none

### LESSONS
- Read-only planner roles in this harness lack Bash: network verification must either run lead-side or be re-dispatched to a Bash-capable role. Planner's refusal to fabricate verdicts without evidence was correct — reward that, close the gap with a supervisor-reply evidence relay.
- 429s on glm-5.3 are intermittent per-request, not account-wide: lens 3 died while 4 sibling runs on the same model completed. On single-run 429: absorb scope lead-side rather than re-dispatch (cheaper than a retry cycle).
- Concurrent fleets now race every iteration (3 for 3). The stable protocol: fresh census before every phase, gate the TREE not the dispatch inventory, commit only what was gated, keep the other fleet's ledger entry and append your own session section.
- "The brief lies; the tree is truth" as a standing gate-dispatch clause paid for itself twice this iteration (undeclared 8th draft + mid-flight index edit, both caught by gates reading the tree).

## Iteration 5 — P7 exit (multi-model role routing) + MISSION COMPLETE

### DONE
- P7 exit pushed (11 commits, 32ef237..c9a6ccb). ALL PHASES P0-P7 NOW EXIT; MISSION_STATUS: COMPLETE written per GOAL rule 8.
- Fleet pattern honored: 3-planner council IN PARALLEL (architecture / risk-edge / scope-partition lenses) -> merged plan with 5 disjoint implementer packets (<=5/round per AGENTS.md) -> reviewer + security + tester gate IN PARALLEL -> lead fixed ALL findings pre-push.
- Race #5 (fifth consecutive): a sibling fleet implemented P7 CONCURRENTLY in the same files. Reconciliation adopted the richer sibling implementations (orchestrator Step 3c with portable gm_route, setup Step 6b, verify Doctor Mode Path A/B, adapters/pi/models.sh resolver, tests/models-routing.sh) and deleted my fleet's duplicates (Step 0d, Step 4a, second dispatch table); kept my fleet's unique work (validator Check 7, AGENTS.md rows, README/blog/pi-doc); unified the dispatch table to AGENTS.md noun roles; aligned ALL sites to per-key merge semantics.
- The sibling's 6 atomic commits landed at 19:57 absorbing the reconciled tree (shared-index race, benign); my 5 gate-fix commits layered on top: newline-bypass hardening (security MED: $'evil\\nx/y' spoofed grep line anchors in models_valid_value/gm_valid/gm_route), 128-char value cap, setup argv-templated config write (python -c quote breakout), Step 7 session-literal acceptance, Check 7 contract rewrite (non-empty, session literal, env-name collision detection, fail-closed python3, no .strip()), /godmode:doctor command file + meta row, blog per-key wording, CONTRIBUTING routing-tests reference.
- Gates at push: validate-skills STATUS PASS, validate-structure STATUS PASS (WARN 6 baseline), models.sh selftest 21/0, models-routing.sh 17/0, zero-config + env-override + 8-fixture Check 7 matrix all verified empirically; tree clean.
- P7 exit criteria all evidenced: zero-config default proven (no config = valid, all-session doctor, validator PASS), env override test (GODMODE_MODEL_REVIEWER=openai/gpt-5.2 -> reviewer row env), wizard step (6b, max 3 questions), doctor table (role/model/source/origin), orchestrator wiring (Step 3c + Rule 9 + capability matrix), capability matrix docs (skill harness-neutral + README Platforms Models column), validator gate (Check 7).

### NEXT (ordered)
1. Mission complete — remaining items are post-mission upkeep, not phases:
   - Human-fire queue (unchanged): 3 launch posts + 4 NEEDS_HUMAN forms; monitor 4 PR_OPEN listings.
   - Backlog issues #5 (Amp adapter), #7 (omp dir), #8 (CI hardening), #9 (real demo captures). Issue #6 (this P7 spec) can be closed as shipped.
   - Verify CI green on c9a6ccb (validators passed locally; no new skills so count checks unaffected; commands 118->119 is WARN-only).

### BLOCKERS
- none

### LESSONS
- Concurrent-fleet races are now a structural property of this mission (5 for 5). Winning protocol this time: census before every phase, RECONCILE-and-adopt instead of revert (pick the richer implementation per file, delete your own duplicates, align semantics across all sites), gate the TREE, verify committed blobs after any suspiciously-short commit.
- Shared-index commit absorption repeats: sibling commits landed the merged tree under their names mid-gate. Verify with `git show HEAD:<path>` before assuming loss; never rewrite history to reclaim authorship — append fix commits instead.
- Grep-based validators of multi-line strings are bypassable via embedded newlines ($'evil\\nx/y' passes ^...$ grep). Whole-value guards (case *$'\\n'* rejection, length caps) or python re.fullmatch are mandatory whenever untrusted values reach grep -E anchors.
- Validator contracts must mirror documented runtime contracts exactly: Check 7 initially allowed empty strings (spec violation), rejected the documented 'session' literal, and .strip()ed values the runtime validates raw — each divergence found by a different gate agent (tester/reviewer/security). Cross-gate redundancy catches what single review waves through.
- Skill-prose python snippets that interpolate user answers into python -c source are injection surfaces even when 'never evaluated' is claimed; pass answers as argv and validate before writing.
- A command referenced in README (/godmode:doctor) needs a real commands/godmode/*.md file — command/skill mismatch is WARN-only in validators, so the gate trio (not CI) is what catches phantom slash commands.

## Iteration 5 — Session B (independent council→build→gate; residuals closed; mission verified closed)

(Ran concurrently with the Session A fleet above on the same tree — same prompt window, two lead agents. This session's contribution: an independent 3-lens planning council, a 6-implementer disjoint-scope build of the P7 reference design, a 3-agent gate that caught 14+7+5 findings, and the closure of every residual the races left open.)

### DONE
- Council (3 lenses, parallel): architecture (models.sh CLI surface, per-key merge, python3-heredoc reader, inline-resolver-in-skill decision D1-D6) + risk red-team (15 ranked findings incl. newline-bypass, dot-normalization bug, skills-only install boundary, sandboxed negative path) + scope partition (6 disjoint implementer scopes, gate briefs, push checklist). Two lenses failed first pass (planner agent classifier rejected analysis briefs) — re-dispatched to security/reviewer agents, zero stall.
- Build: 6 implementers in parallel, disjoint scopes — adapters/pi/models.sh + tests/models-routing.sh + adapter README; skills/godmode Step 3c + Rule 9 + capability matrix; skills/setup Step 6b wizard; skills/verify doctor Step 0; validate-structure Check 7; README/blog/AGENTS/CHANGELOG/CONTRIBUTING docs. 6 atomic commits (96fdbee..9d32936).
- Race reconciliation mid-build (5th and 6th races): sibling fleet wrote conflicting Step 0d/Role-Dispatch-Table/Step-4a sections into the same files; siblings then self-deduped against this fleet's landed design, then committed 6 more commits (e952606..93052f6) fixing most of this fleet's gate findings and pushing the tree + ledger.
- Gate trio (reviewer+security+tester parallel over the merged diff): REQUEST_CHANGES x3 — 14 reviewer findings (cross-resolver divergence, path-B cwd-vs-toplevel, 2 new MD040s, untested inline resolvers...), 7 security findings (newline bypass already fixed by sibling, unquoted loops, setup Step 7 session rejection...), 5 tester findings (in-flight sibling edits during gate, empty-string Check 7 contradiction — resolved by sibling spec-literally: non-empty or 'session').
- Residual closure lead-side (3 commits 50001a9..6ca234a): models.sh invalid-project-value now falls through to home file (cross-resolver contract proven empirically both ways + selftest case 12); verify path B resolves project config from git toplevel (works from subdirs), quoted while-read loops (glob-safe against attacker config keys), strict roles unwrap; setup fences labeled (MD040 back to pre-P7 count), conditional git add replaces literal-bracket line; NEW extraction tests C18-C20 source gm_route out of skills/godmode/SKILL.md and the whole path-B doctor out of skills/verify/SKILL.md and prove behavior + cross-implementation parity.
- Final battery at 6ca234a: validate-skills FAIL:0, validate-structure FAIL:0, models-routing 22/22, selftest 23/23, claude-allowlist intact, zero new markdownlint errors, tree clean. Pushed.
- Issue #6 CLOSED with full exit-criteria evidence (zero-config, env override, wizard, doctor, wiring, matrix docs, validator gate).
- Mission verified complete: P0-P6 exits recorded in prior iterations, P7 exit evidenced above; MISSION_STATUS: COMPLETE stands at line 1 backed by 6ca234a.

### NEXT (ordered)
1. Mission complete. Post-mission upkeep only: human-fire queue (3 launch posts, 4 NEEDS_HUMAN forms), monitor 4 PR_OPEN listings, backlog #5/#7/#8/#9.
2. Minor polish deferred to backlog (non-blocking NITs): selftest case renumbering, omp row in the skill capability matrix (blocked on #7 omp confirmation), AGENTS.md hint-vs-session precedence sentence, README doctor-invocation wording.

### BLOCKERS
- none

### LESSONS
- The pi 'planner' agent classifier rejects briefs it reads as implementation tasks ("enumerate mitigations", "partition into scopes") even when read-only; analysis-shaped dispatches belong on security/reviewer agents. Cost: one 4.5-min re-dispatch round.
- Gate the TREE, then commit fast: the sibling fleet's push raced past this fleet's open gate findings. Recovery protocol that held: verify every finding empirically at the new HEAD, fix only what's actually still broken, push fixes as separate atomic commits, never revert the sibling's coherent work.
- "Fix all findings before push" under a two-fleet race becomes "fix all findings before YOUR push, on top of whatever landed": the mission invariant is the pushed end-state, not any single fleet's diff.
- Extraction tests (sed the function out of the SKILL.md, source it, assert behavior) are the cheapest possible guard that skill-embedded bash stays executable — skills prose rots silently otherwise; C18-C20 now pin gm_route and the path-B doctor to their documented contracts.

## M2 Iteration 2 — M2-P2 exit (Amp adapter, issue #5)

### DONE
- M2-P2 exit pushed (6 commits, 53b503b..e121e10, CI green on e121e10): `adapters/amp/{install.sh,verify.sh,README.md,amp-config.md}` — AGENTS.md copy with never-clobber sidecar (`AGENTS.godmode.md`), root `skills/`+`agents/` symlinks, `.agents/skills/` wiring (Amp's documented project-skills dir; evidence: ampcode.com/docs/customize/skills + agents-md, fetched this session), `.godmode/` state dir; verify.sh is fail-closed with a godmode-marker grep, dynamically computed skill count, and a frontmatter name==dirname sweep (Amp silently drops mismatches; 135/135 pass). Honest capability: skills only — no injected subagents, no model routing, no `amp skill add` claims. README row/footnote/intro/badge, CONTRIBUTING matrix, platform-comparison section, blog stale-claim annotations, CHANGELOG entry.
- Issue #5 CLOSED with full evidence comment; systemic gate findings filed as issue #10 (family-wide dangling-symlink write-through + shared printf format-string + platform-count drift).
- M2-P0 capability matrix (logged here; no prior M2 ledger entry exists): vhs v0.11.0 ✓, ttyd 1.7.7-40e79c7 ✓, ffmpeg /usr/bin/ffmpeg ✓, npm NOT authed (ENEEDAUTH), GitHub Discussions DISABLED (P5 work), stars.log appending every 30min ✓ (25 stars / 7 forks at 22:16).
- Fleet pattern honored: 3-lens council IN PARALLEL → 5 implementers IN PARALLEL (disjoint scopes) → reviewer+security+tester gate IN PARALLEL → all findings fixed pre-push. All subagents on zai/glm-5.3.
- Gate results: tester PASS 6/6 groups (validators 523/0 + 798/0, 6-case /tmp e2e matrix incl. copy-mode + collision + user-AGENTS preservation, 135/135 name==dirname, honesty census clean, zero new markdownlint); reviewer APPROVE-with-notes (6×P2 — all fixed: docs/index platform count 5→6, dynamic count echo, root-symlink commit note, sidecar qualifier, comment wording); security CLEAN (5 LOW — fixed in-scope: PROJECT_NAME YAML-injection sanitize `tr -cd '[:alnum:]._-'` proven with a pwn-dirname regression test, source-count >0 guard, idempotent cp -rL escape hatch; family-wide items → #10).
- Race status: sibling fleet mid-flight on M2-P1 (demo tapes committed 6332850, GIFs/transcripts/README-demo still uncommitted). My README commit used hunk-filtered `git apply --cached` — only my 4 Amp hunks committed, their demo region untouched. No index absorption this iteration.

### NEXT (ordered)
1. M2-P1: verify the sibling fleet's demo captures land (GIFs + README embeds still uncommitted); if stalled next iteration, land them with gates.
2. M2-P3 (omp skills dir, issue #7) — gh api research on can1357/oh-my-pi.
3. M2-P4 (CI hardening, issue #8) — markdownlint repo-wide, prose-count gate, markdownlint-cli2 devDependency fix.
4. M2-P5 (discussions + star-history badge + README top demo GIF — needs P1 landed first).
5. M2-P6 (coverage sweep: 3 more submission-queue targets).
6. Marketing drafts (hesreallyhim:93, JosiahSiegel:98, show-hn:38) still say "Amp: no adapter yet" — refresh before any human fires them (tracked in ledger, not #10).

### BLOCKERS
- none. (amp CLI not installed on this machine → Amp-side symlink-traversal dogfood unverified; mitigated honestly: adapter README documents the `cp -rL` copy escape hatch and verify.sh passes in both modes.)

### LESSONS
- The pi 'planner' classifier rejected all 3 council briefs (again, 3/3). The standing recovery — re-dispatch to reviewer/security/oracle — worked first try, zero stall. Stop dispatching analysis to 'planner'.
- My own gate-fix edit introduced a bash syntax error (quote/paren swap at a construct boundary: `_-'"` instead of `_-')"`) that would have shipped a broken installer; caught by the mandatory post-fix `bash -n` + e2e re-run, then reproduced in a minimal case to find the swapped bytes. Rule: after EVERY lead-side edit to shell, run `bash -n` + the e2e chain before committing — gate fixes are code too.
- Hunk-filtered `git apply --cached` (python hunk-splitter keyed on added-line markers) cleanly separated my README hunks from the sibling's uncommitted demo region — first race-free shared-file commit of this mission. Cheap, deterministic, beats whole-file staging under a two-fleet race.
- Council evidence packs pay for themselves: every Amp fact used by all 8 agents came from one lead-side curl session (2 doc pages); no implementer re-researched, no fabrication crept in.
- Dynamic counts beat hardcoded ones at every layer: verify.sh derives expected from the source tree, install.sh echoes the live count — the 126→135 drift class (issue #8) is now structurally impossible in this adapter.

## M2 Iteration 3 — M2-P1 exit (real demo captures, issue #9)

### DONE
- M2-P1 exit pushed (6 atomic commits, 9e05e38..c01a76c, CI green on c01a76c; issue #9 CLOSED with evidence). README "See It In Action" now embeds 3 REAL captures (live pi sessions on zai/glm-5.3, vhs 0.11.0, 2026-08-27): skill routing (DISPATCH + ROUTED_OK), optimize keep/revert loop (real metric, real KEEP, real `git reset --hard` revert), goal-bridge contract (red→green with evidence file). TODO labels gone; illustrative blocks below explicitly labeled as such; accessible `<details>` transcript fallbacks byte-identical to demo/transcripts/*.txt (programmatically verified).
- HONESTY CATCH (the iteration's defining event): frame-level OCR (ffmpeg extract + tesseract, negate for dark theme — current fleet model has no image input) over the sibling fleet's stalled uncommitted GIFs revealed (a) all three captures were genuine sessions, but (b) the optimize-loop transcript FABRICATED the baseline block (claimed 277/266/249; the screen actually showed 538/624/451 interleaved into the next command's echo — a tape Sleep 500ms timing bug), and (c) the goal-bridge baseline line was a lossy paraphrase of two AssertionError lines. Fixed per the mission rule "improve the demo script, never fake it": tape sleeps corrected (500ms→3s/6s), optimize-loop RE-RENDERED with a fresh real session (baseline 189ms, lru_cache KEEP 0ms, fib(32) DISCARD 517ms + guard failure 2178309≠832040), transcripts rewritten screen-accurate, README synced.
- Fleet pattern honored: 3-lens council IN PARALLEL (planner architecture / security risk / reviewer sequencing after the known planner-classifier rejection, zero stall) → 4 implementers IN PARALLEL (disjoint: CHANGELOG | docs/index | demo/README | README+transcripts) + lead-side tape fix + re-render → reviewer+security+tester gate IN PARALLEL over the tree. All on zai/glm-5.3.
- Gate results: tester 8/8 PASS (validators 523/0 + 799/0, GIF ffprobe integrity + size-table match, embed↔transcript sync, git add -n artifact-presence, banned-pattern negative test, README render strings); reviewer REQUEST_CHANGES → both findings fixed (P1: transcript annotation "baseline, median of 3" contradicted the session's own 189ms baseline — reworded in both files; P2: reddit draft "README traces are illustrative" stale after this delta — updated); security CLEAN (2 LOW fixed in-scope: BANNED list gained github_pat_/gho_/xox*/AIza/glpat-/-----BEGIN + case-tolerant Bearer/api-key/password classes; the grep -i shortcut was tried and REVERTED — it false-flagged the tapes' own `Set Theme` directives, per-pattern classes instead). markdownlint 0 issues on all changed files (MD010 TSV tabs fenced with disable guards; MD040 fixed in demo/README).
- Race status: sibling fleet stalled 32min with uncommitted delta; adopted-and-completed rather than reverted (ledger NEXT item from Iteration 2 executed as planned). No index absorption this iteration — lead was sole committer with explicit-path staging.

### NEXT (ordered)
1. M2-P3 (omp skills dir, issue #7) — gh api research on can1357/oh-my-pi.
2. M2-P4 (CI hardening, issue #8) — repo-wide markdownlint + prose-count gate + markdownlint-cli2 devDependency fix (note: this iteration used `npx -y markdownlint-cli2` as the working local gate — candidate fix for the dep gap).
3. M2-P5 (discussions + star-history badge + README-top demo GIF — P1 landing unblocks the badge/GIF part).
4. M2-P6 (coverage sweep: 3 more submission-queue targets).
5. Backlog polish: docs/index.md has 24 pre-existing MD022/MD032 violations (out of P1 scope, folded to #8); platform-count drift (8 vs 7 vs 6) deferred; package.json files[] excludes demo/ (npm page would lack GIFs — only matters if npm publish ever happens).

### BLOCKERS
- none

### LESSONS
- GIFs are the one channel where "textual proxy" checks are provably blind: `zai/glm-5.3` was typed on-screen in every capture yet grep over the binaries matched nothing (LZW). The working verification: ffmpeg frame extraction + `negate` filter (dark themes OCR blind without it) + tesseract. It caught a fabricated transcript that every text-level gate waved through. Any future capture lands through this pipeline.
- A transcript annotated "# baseline, median of 3" over numbers whose median contradicts the recorded baseline is an arithmetic self-contradiction a REVIEWER spots but a tester's diff-sync check blesses (sync was perfect; the content lied). Gate prompts must ask "is each claim internally consistent", not just "are files in sync".
- Transcript excerpts may paraphrase only what never appeared differently on screen; when OCR ground truth exists, use it verbatim. The elision convention ([...]) covers elisions, not inventions.
- vhs `Hide` windows compress out of the GIF (280s hidden session ≈ 0 frames) — GIF duration is NOT evidence of session length; wall-clock render mtimes are. Conversely, visible `Sleep` gaps AFTER outputs are mandatory: 500ms after a 3×0.5s metric command let the next typed command interleave over the output (the root cause of the first render's unreadable baseline).
- Case-insensitive `grep -i` over a mixed banned-pattern list is a footgun: it newly matched the tapes' own `Set Shell`/`Set Theme` directives and broke --check fail-closed. Per-pattern bracket classes (`[Pp]assword[ =:]`) deliver the case-tolerance without the false positives.
- nohup-in-toolcall backgrounding silently lost the redirect AND the render (no log, no GIF update, pid lived ~7min doing nothing verifiable). Foreground render with a generous timeout just worked. For one-shot renders, don't background.
- Sibling-fleet adoption protocol (3rd use) holds: census → verify their artifacts empirically → complete/fix rather than revert → land with gates. The stalled delta contained 90% excellent work plus one fabrication; only empirical verification separates the two.

## M2 Iteration 4 — M2-P3 exit (omp skills dir confirmed, issue #7)

### DONE
- M2-P3 exit pushed (5 atomic commits, d5183ea..fad6cd8, CI green on fad6cd8; issue #7 closed via the `Closes #7` commit keyword, evidence comment posted). `~/.omp/agent/skills` confirmed from omp source (can1357/oh-my-pi @ main: `packages/utils/src/dirs.ts` getAgentDir() + `src/discovery/builtin.ts` native provider user scan); `~/.config/omp/skills` proven dead (nowhere in source).
- THE key discovery: omp scans **one level per skill** — the installer's `godmode/` wrapper is NOT auto-discovered. omp's own tool result, verbatim: `Unknown skill: optimize / Available: none`. Required one-time registration in `~/.omp/agent/config.yml`: `skills: { customDirectories: ["~/.omp/agent/skills/godmode"] }` — omp's documented mechanism for nested collections. Empirically verified BOTH ways: wrapper registration → `skill://optimize` resolves with full content; parent-dir registration → `READ_FAIL` (negative control). omp has no `--skill` flag (pi smoke tests don't apply; verified smoke = `omp -p --tools=read` skill:// probe). omp's agents provider also discovers `~/.agents/skills/` default-ON (probe-verified).
- Dogfood: omp v18.0.8 linux-x64 GitHub-release binary in a sandboxed HOME; install 135/135, verify.sh 4/4, smoke positive+negative, `~/.agents` provider probe, cleanup verified (sandbox removed, real ~/.omp untouched, no omp on PATH). zai/glm-5.3 used as the sandbox model via omp's native zai provider (`ZAI_API_KEY` env, key never written to a committed file).
- Docs landed: installer two-case note (Case A omp-dir → required-registration snippet + profile caveat; Case B other → omp hint + PREFIX honored) with zero "undocumented"/"candidate"/`config/omp` strings; adapter README full omp walkthrough (registration, verified smoke, profile caveat, managed-skills warning, one-location guidance, npm `oh-my-pi` name-squat warning + official channels, uninstall); README row+footnote (Models cell softened to "Skill-level (same corpus as pi)" — no omp model-routing claim); blog row + Amp-convention italic footnote + "What 2.0 does not do" amendment (the SECOND stale claim, found by two council lenses); submission-queue notes cell; CHANGELOG Unreleased/Fixed.
- Fleet pattern honored: 3-lens council IN PARALLEL (planner architecture — analysis briefs accepted this time; security risk; reviewer sequencing) → lead dogfood FIRST (D4 outcome pinned implementer wording) → 3 implementers IN PARALLEL (disjoint: adapter-dir | README+CHANGELOG | blog+queue) → reviewer+security+tester gate IN PARALLEL → lead fixed ALL findings pre-push + re-verified empirically. All subagents zai/glm-5.3.
- Gate results: tester PASS (validators 523/0 + 799/0, stale-string census clean, markdownlint 0 new, 6-case installer e2e incl. `PREFIX=/` refusal + idempotency + verify.sh); reviewer REQUEST_CHANGES (4 findings); security FINDINGS (F1-HIGH + F2-LOW). P1≡F1 — cross-gate redundancy caught it independently: 3 of 4 registration snippets printed the PARENT dir (`~/.omp/agent/skills`) instead of the wrapper; file-level verify was green while the instructions would have failed their only purpose. Fixed in all 3 + fresh-sandbox verification (V1 parent → READ_FAIL, V2 wrapper → resolves). P2 agents-provider claim licensed by probe; P3a Models cell softened; P3b blog clause amended; F2 citations re-scoped to `dirs.ts`/`builtin.ts`.

### NEXT (ordered)
1. M2-P4 (CI hardening, issue #8) — repo-wide markdownlint + prose skill-count gate + markdownlint-cli2 devDependency fix (`npx -y markdownlint-cli2` again proved the working local gate).
2. M2-P5 (discussions + star-history badge + README-top demo GIF — unblocked since P1 landed).
3. M2-P6 (coverage sweep: 3 more submission-queue targets).
4. Backlog polish: docs/index platform-count drift (fold into P4), package.json files[] excludes demo/, marketing drafts' "Amp: no adapter yet" refresh before human firing.

### BLOCKERS
- none

### LESSONS
- Model self-report is not evidence of context state: three consecutive probes lied three different ways (catalog "listed" via tool-exploration of cwd; count probe said 0 with skills installed; `--tools=read` listing said NONE). The decisive instrument was omp's own recorded toolResult (`Unknown skill: optimize / Available: none`). When proving "X is in context", use a protocol whose FAILURE is recorded server-side.
- File-level verification (counts, presence, sync) stays green while runtime discovery is broken. The gate-caught P1 (wrong registration dir) shipped past every file-level check; only the negative control (parent → READ_FAIL) licenses the positive claim. Dogfood must follow the user's exact printed instructions, not the harness author's paraphrase.
- The "one level under skills/" line was in omp's docs all along — the first auto-load probe FALSE-PASSED because the model explored the filesystem instead of reading its context. Reading layout specs literally + designing exploration-proof probes is the difference between verified and vacuous.
- GitHub auto-close keywords fire on push: `Closes #7` closed the issue 1s after the push landed, so `gh issue close` errored — post the evidence comment separately regardless; comment-after-close satisfies the contract.
- Share the full source, not just conclusions: the one omp fact I under-shared with the fleet (agents-provider behavior) was exactly the one the reviewer flagged; the re-dispatch cost was one probe.
- Cross-gate redundancy remains the cheapest defect filter: reviewer and security caught the same P1 independently with different phrasings; the tester's mechanical gates complemented both.

## M2 Iteration 5 — M2-P4 exit (CI hardening, issue #8)

### DONE
- M2-P4 exit pushed (10 atomic commits, 86c2b3b..b4bccd4, **CI green on pushed SHA** — run 33130754291, all 7 steps ✓ incl. the 3 new gates; issue #8 evidence comment posted). Three new CI gates: (1) **repo-wide markdownlint** — `lint:md` fixed to invoke `markdownlint-cli2` with quoted globs (was the nonexistent `markdownlint` binary + cli-v1 `--ignore` flags), `package-lock.json` committed (v3, 38 https-only URLs, sha512 on all) + CI `npm ci --ignore-scripts`; `.markdownlint.json` suppresses presentational classes (97% of ~12k violations were blank-line/fence/indent style churn) while the semantic tail was hand-fixed: 2 broken MD051 fragments, MD056 tables, MD024 dupes, and 4 fence-parity root-cause repairs that restored previously code-swallowed headings (### Step 6/8, ## Keep/Discard, ## Stop Conditions). (2) **prose skill-count gate** (`tests/validate-prose-count.sh`) — disk-derived truth, census over ALL tracked files incl. extensionless (`.cursorrules`, `hooks/session-start` — the iteration-3 gap), two-tier patterns (three-digit always + anchored two-digit), frozen allowlist (3 docs + CHANGELOG/PROGRESS), embedded negative self-test every invocation, exit 2 = broken detector. (3) **adapter install smoke** (`tests/adapter-smoke.sh`) — real `install.sh`+`verify.sh` per adapter into mktemp positional prefixes (unset PREFIX guard, single trap), 6/6 PASS, idempotent, false-green guard (target-mention grep + PASS:0 hard-fail).
- The gates caught REAL drift pre-merge: stale `97/48/151/100+/111` claims fixed in FAQ, PHILOSOPHY, COMPLETE-SKILL-LIST (regenerated from disk: 19 phantom skills removed incl. adr/contract/dx/learn/scaffold, Planned-54 section deleted), skill-index (alphabetical table regenerated 135 rows; header 48→135; curated sections pruned of 7 phantom skills; predict 5→3-persona per SKILL.md truth), godmode-design, quick-start; platform framing pinned canonical: **7 platforms = Claude Code + 6 adapters; 8 harnesses (pi adapter serves pi+omp)** — index/platform-comparison de-numbered where counts can't be mechanically derived; marketing drafts (hesreallyhim, JosiahSiegel, show-hn, agentskills-io) refreshed: Amp adapter exists, omp confirmed, 8-harness enumerations; package.json `commands` 118→119 (disk+marketplace truth); CONTRIBUTING stale "54 directories waiting" + dead anchors fixed.
- Fleet pattern honored: 3-lens council IN PARALLEL (planner architecture / security risk / reviewer scope-sequencing — planner accepted analysis briefs, 3/3 first try) → S1 lead-side (config+lockfile+script, commit 2249335) → **4 implementers IN PARALLEL** (disjoint: lint-fixes | stale-claims+marketing | prose-gate | adapter-smoke) → S6 wiring lead-side → **reviewer+security+tester gate IN PARALLEL** → all findings fixed pre-push (4 fix commits). All agents zai/glm-5.3, no sub-subagents, ≤6 concurrent.
- Gate results: tester **PASS** (all 4 negative-path acceptance criteria of #8 empirically verified in /tmp copies: injected 126 → exit 1 naming claim; broken installer → FAIL names adapter; idempotency ×2; scoped-lint 0 errors); reviewer REQUEST_CHANGES → P1 fixed (A-set widened to adjectival "NNN specialized/Godmode/expert skills" — the dominant live shape was un-gated; quick-start "120 specialized" reworded to un-numbered form), P2-1/2/3 fixed (phantoms, description re-extraction, 5-platforms/54-dirs/agentskills-Amp), P3-2 guard added, P3-4 commands count fixed; security FINDINGS → F1 fixed (`permissions: contents: read` + `persist-credentials: false` + `npm ci --ignore-scripts` — third-party lint deps now run without GITHUB_TOKEN access), F2 (colon-filename parse) documented residual. Security verified-clean: NUL-delimited pipelines (no shell re-parsing of repo content), rm -rf confined (positional prefix + root refusal), no secrets, no DoS classes.
- One implementer run failed mid-flight (S2 lint-fixes, 10-min timeout at report edge) — resume-from-persisted-session recovered it first try; work was complete and verified in-tree.

### NEXT (ordered)
1. M2-P5 (discussions + social proof): enable Discussions, seed "Show your godmode wins" with real mission-log dogfood, star-history badge + README-top demo GIF (P1 GIFs landed, unblocked).
2. M2-P6 (coverage sweep: 3 more submission-queue targets → PR or NEEDS_HUMAN).
3. Polish backlog: AGENTS/GEMINI/OPENCODE catalog tables list ~127 rows under correct "(135 Skills)" headers (completeness, not drift — add the 8 late-added skills); "13 domains vs 11 categories" label divergence; setup-node pin (runner Node deprecation annotation on checkout@v4 is cosmetic today); verify.sh 135-hardcodes with `>=` semantics in 4 adapters (growth masks exact-count staleness).
4. Marketing drafts (reddit-claudeai, x-launch-thread, anthropics-*) not audited this iteration — fire-check before human use.

### BLOCKERS
- none

### LESSONS
- The prose-gate's first contract was regex-verbatim and failed exit-0 on 115 SUBSET claims ("(15 skills)" headers, "48 skills" cross-refs): a gate that can't go green on a healthy tree is as useless as one that can't go red on a sick one. The amendment (three-digit always + anchored two-digit) preserves every historical drift catch (126/134/151 three-digit; "97 implemented/bundles") while passing every subset shape — and the reviewer then caught that even THAT missed the dominant adjectival shape ("135 specialized skills"), which the final widening closed. Iterating the pattern against LIVE census output (not specs) is the only way to converge.
- Regenerating docs from frontmatter is harder than it looks: first pass leaked `--- ## Activate When -` markers into 24 table cells and truncated mid-word (`/godmode:t`) — block-style YAML descriptions (`description: |`), pipe-containing trigger lists, and word-boundary truncation each needed their own handling. Any generated-table commit needs a cell-count awk + marker-grep check before it lands.
- Council evidence packs keep paying: the security lens's PREFIX-env-scoping warning (R3) was designed around BEFORE any code existed — S5's smoke passes prefixes positionally with an unset guard, and the destructive-path audit confirmed rm -rf is unreachable outside $TMP.
- Scope partitioning by FILE is necessary but not sufficient: 3 stale-claim files (skill-index, autoresearch-integration, CONTRIBUTING) fell in NO implementer's scope because the census that found them ran DURING the build wave. Fix: run the drift census BEFORE partitioning, or give the claims-implementer an explicit "grep-derived superset" file list.
- Gate-inversion beats placeholder-wiring: CI steps were written only after each script existed and passed locally (reviewer lens recommendation) — the workflow never references a path that doesn't exit-0, so there was no red window on push (single push, 10 commits, all batteries pre-verified).
- A failed 10-min implementer run with a persisted session revived cleanly with full work products — always try `resume` before re-dispatch; the timeout had fired at the report boundary, not the work boundary.

## M2 Iteration 6 — M2-P5 exit (Discussions + social proof)

### DONE
- M2-P5 exit pushed (commits listed below; CI verified on pushed SHA). GitHub Discussions ENABLED (`gh api -X PATCH -f name=godmode -f has_discussions=true` — the `-f name` guard was a council-predicted 422 fix); thread **#11 "Show your godmode wins 🏆"** seeded in "Show and tell" (https://github.com/arbazkhan971/godmode/discussions/11), body byte-exact with the gated file `docs/marketing/discussion-seed.md` (GET-verified; the 1-byte delta is GitHub's trailing-newline normalization). Duplicate pre-flight GET (0 threads) preceded the mutation — the new GitHub-side race surface (two fleets can createDiscussion into duplicates) is covered by the standing inter-fleet ledger signal. `pinDiscussion` does not exist in GitHub's public GraphQL schema — skipped, optional-only.
- README: real optimize-loop capture as hero at top (inside the centered div after the badge row, w=880, alt numbers verbatim from the transcript, caption anchors to #see-it-in-action for the transcript fallback); new `## Community` section between FAQ and License with the star-history chart. **Design decision (two council lenses independently):** chart lives in the bottom Community section, NOT the top — a 25-star near-flat chart as headline is anti-social-proof and the repo's own marketing policy bans star-count displays; spec's exit ("badge in README") satisfied honestly. CHANGELOG [Unreleased]/Added + docs/index.md Marketing row record the launch.
- Launch drafts refreshed (reddit-claudeai, x-launch-thread, show-hn): stale "Amp adapter not written yet" → shipped-skills-only truth; "README demos are representative illustrations / issue #9" → three-real-captures truth (#9 closed, refs removed); one informational Discussions mention each (no counts, no bait). X-thread counts recomputed with the URL=23 method that reproduces all original counts (tweet4 276→279, tweet8 31→107; all 8 ≤280).
- Fleet pattern honored: 3-lens council IN PARALLEL (planner architecture / security risk / reviewer scope-sequencing — planner accepted 3/3 first try) → 4 implementers IN PARALLEL (disjoint: README | seed file | CHANGELOG+index | 3 drafts) → **serial pre-post honesty sub-gate on the seed** (every number cross-checked against PROGRESS.md:240 AND demo/transcripts/optimize-loop.txt before the unrecoverable public post) → lead API ops → reviewer+security+tester gate IN PARALLEL → all findings fixed pre-push. All agents zai/glm-5.3, ≤6 concurrent, no sub-subagents.
- Gate results: tester **PASS 9/9** (validate-skills/structure/prose PASS, markdownlint 0 on all 7 files, GIF path + exact star-history URL + anchor checks, independent 8-tweet recount matches, live-state GET incl. body byte-compare, race census exact 6M+1??); security **CLEAN 0 findings** (banned-pattern sweep with false-positive triage: render.sh's own scanner patterns, package-lock sha512 xoX substring, dummy fixtures; draft policy compliance; seed numerals confined to the verified set; line-1 maintainer disclosure confirmed); reviewer **REQUEST_CHANGES 3** → fixed: **P1** star-history `![]()` inside a single-line `<p align="center">` HTML block renders literal bracket text on GitHub (CommonMark type-6 block; MD033 disabled so lint blind) → rewritten to raw `<a><img>` matching the repo's own embed pattern, full battery re-run green; P2 = this ledger entry; NIT = tweet-4 sits at 279/280 (recount-on-edit convention governs).
- One gate dispatch rejected: security agent's task classifier refused an imperative audit brief (no mutation tools); re-dispatched report-shaped ("your report must answer") — accepted first try, zero stall.

### NEXT (ordered)
1. **M2-P6 (coverage sweep) — the last open M2 phase**: from docs/marketing/submission-queue.md pick ≤3 more automated-PR targets → research format → fork → branch → exact-format entry → PR (≤1 per target); others → NEEDS_HUMAN drafts; update queue table.
2. After P6 exit: final gate → `M2_MISSION_STATUS: COMPLETE` as first line of PROGRESS.md → final commit + push.
3. Human-fire queue (now Discussions-wired): 3 launch posts + 4 NEEDS_HUMAN forms; monitor 4 PR_OPEN listings (+9 open list-PRs per stars.log).
4. Polish backlog (unchanged): AGENTS/GEMINI/OPENCODE catalog tables ~127 rows under "(135 Skills)" headers; "13 domains vs 11 categories" divergence; setup-node pin; package.json files[] excludes demo/ (npm page would lack GIFs); star-history third-party availability is accepted dependency (Camo-cached).

### BLOCKERS
- none

### LESSONS
- **Cross-gate redundancy caught a render bug no mechanical gate can see**: markdown `![]()` inside a single-line HTML block renders as literal brackets on GitHub; MD033 is disabled and prose/count gates are blind to it. The repo's own working pattern (raw `<img>` in `<p>`) was both the tell and the fix. Render-level constructs need either a CommonMark-aware reviewer or a rendered-HTML smoke check — add the latter to the demo pipeline if this class recurs.
- **Order gates by irreversibility**: the only unrecoverable action (public discussion post) got a serial pre-post honesty sub-gate (ledger + transcript cross-check); the recoverable file delta went through the full parallel gate afterward. Cheap insurance in the right place.
- Byte-exact POST verification vs GitHub: expect the +1 trailing newline (2226 vs 2225) — normalize before diffing, don't panic-diagnose "corruption".
- `gh api -X PATCH repos/…` needs `-f name=<repo>` beside the flag you're changing — the council's F4 precheck avoided a 422 round-trip. `pinDiscussion` is not in the public GraphQL schema; optional API steps must be treated as droppable.
- The security-agent classifier rejects imperative briefs ("audit for", "execute") as implementation on a no-mutation-tool agent; report-shaped phrasing ("your report must answer") passes first try. Imperatives for builders, noun-verb analysis frames for read-only agents.
- Council evidence packs again paid for themselves: every GIF number, policy rule, and URL form used by 8 agents came from lead-side verification; the one thing the council pre-computed that mattered most was the PATCH `-f name` guard and the duplicate-pre-flight protocol (new race surface unique to GitHub-side mutations).

## M2 Iteration 7 — M2-P6 exit (coverage sweep) + mission complete

(Numbered 7 per the GOAL2 `## M2 Iteration N` ledger convention — iterations 2-6 precede; iteration 1 was never logged. The dispatch template said "Iteration 1"; chronological truth governs.)

### DONE
- M2-P6 exit pushed (commit 77b4d02, master, validators green pre-push; CI run started on that SHA). **5 new outcomes ≥ 3 required**: 4 PRs (all dedup checkpoint B clean immediately pre-create, +1/-0 README-only diffs, authorship disclosed in house phrasing) — composio-community/awesome-codex-skills#261 (16.1k★, entry after `polywave`, install-suffix deliberately omitted), Piebald-AI/awesome-gemini-cli#107 (497★, CONTRIBUTING bottom-of-section rule), ccplugins/awesome-claude-code-plugins#411 (924★, Workflow Orchestration end), jqueryscript/awesome-claude-code#627 (505★, (25 ⭐) live snapshot, sort-correct above the (18 ⭐) line) — plus hashgraph-online/awesome-codex-plugins NEEDS_HUMAN decision draft (13 verified preconditions + 3 PR-level rules; SECURITY.md nuance: docs/SECURITY.md exists, root absent).
- Queue 16 → 25 targets (4 PR_OPEN rows with live URLs, 1 NEEDS_HUMAN, 4 SKIP incl. VoltAgent/awesome-codex-subagents vendoring + 3 audit SKIPs: heilcheng stale/SKILL.md-index scope, libukai guide-not-list, KarelDO dead-2023); totals awk-verified 0/12/5/8/0.
- Fleet pattern honored: 3-lens council IN PARALLEL (planner×3 accepted 3/3) → 5 implementers IN PARALLEL (B1-B4 fork/branch/entry/push — NO pr create; B5 draft; disjoint scopes) → lead remote verification (GitHub compare API, byte-level anchor checks) → Gate #1 full PRE-PR (reviewer APPROVE 0×P1, security CLEAN/GO, tester 10/10) → findings fixed (draft date, PR-level rules, live-star citation, dedup line, placement pin, T4 body varied + emoji header) → LEAD gh pr create ×4 serial, 30-40s spacing, dedup re-run before each → queue update → Gate #2 parallel over merged diff (reviewer APPROVE, security GO, tester 7/7 incl. live PR liveness) → both residual findings fixed (docs/SECURITY.md wording, &amp;→&) → validators → atomic commit → push. All agents zai/glm-5.3, ≤6 concurrent, no sub-subagents.
- Gate-caught pre-push: literal `[Name](URL)` format templates in queue Entry-format cells broke validate-structure's link checker (FAIL 2) — reworded to prose; caught by the mandatory battery BEFORE push, not after.
- **All M2 phases P0-P6 now exited and verified** (iterations 2-7); M2_MISSION_STATUS: COMPLETE written as first line above.

### NEXT (post-mission, human-fire queue)
1. Monitor 8 open list-PRs (4 mission-1 + 4 new) for maintainer responses; never reopen closed PRs, max 1 PR/target honored.
2. Human decisions pending: hashgraph Option A/B (draft), 4 older NEEDS_HUMAN forms, 3 launch posts (Discussions-wired).
3. Polish backlog (unchanged): catalog-table ~127-row completeness, "13 domains vs 11 categories" label, setup-node pin, package.json files[] excludes demo/.

### BLOCKERS
- none

### LESSONS
- **Order gates by irreversibility — the two-gate split worked exactly as designed**: Gate #1 (full) over PR artifacts BEFORE `gh pr create` caught 5 fixable findings while fixes were still free (fork-branch + local body edits); Gate #2 (light) over the repo delta caught 2 more pre-push. A post-PR-only gate would have forced public fixup commits on 4 PRs.
- **The lead's evidence pack had a factual hole the council caught**: "no single skill subdir" was false (skills/godmode/SKILL.md router exists) — which flipped the T1 install-suffix decision (a router-only install would ship broken UX to a 16k★ list). Evidence packs need file-level verification, not just search-result impressions; the risk lens's read-the-tree reflex is now standing practice.
- **Dedup is a two-checkpoint protocol, not a pre-step**: fork-time grep AND immediately-before-create grep+pr-list. All four targets stayed clean across ~40 minutes, but active 16k★ lists append entries daily — only checkpoint-B output may back a "dedup clean <date>" queue claim.
- **Reviewers without shells still verify remotely — route around the tool gap**: the G1 reviewer asked for the 5 gh api outputs via supervisor intercom; pasting fresh command output beats accepting an evidence-gap verdict. Its run died waiting; resume-with-outputs revived it with full context in one turn.
- **Queue Entry-format cells must not contain literal markdown link templates** — `[x](URL)` inside backticks still trips validate-structure's link checker (relative-path resolution). Prose descriptions of format are the queue's own established convention; the one place I deviated was the one place it broke.
- **Same-day 4-PR bursts are per-maintainer invisible** (1 PR/repo, +1 line each, tailored bodies): spam risk is operational (rate limits), not reputational — serialize PR creates with 30-60s spacing; the drop-to-4 fallback stayed unused.
- Sort-order conventions hide in plain sight: jqueryscript's star-descending section would have made a blind append a visible convention break (25 above 18, not below); the risk lens's "verify sort not just format" rule placed the entry correctly on first try.

## M3 Iteration 1 — B0 corpus complete + B1 runner staged (pilot pending)

### DONE
- **B0 exited on disk**: all 30 tasks complete. 28 were finished by the prior (unledgered) iteration with VERIFICATION.tsv evidence; the two gaps — **perf-04** (node, L, config-reparse) and **perf-05** (bash, M, per-line grep sweep) — were completed this iteration after two implementer waves died to rate limits (lead-authored final): README (no solution hints; perf-05 pins fixed-width 16-hex signature contract), metric.sh (seeded 1337/4242, expected output computed independently in-generator, wall-time caps enforced via timeout — perf-04: N=160k items, 2.5s cap, starter ~8.4s≈3.4x cap, solution ~0.5s; perf-05: 462-sig watchlist incl. dups + 50MB export, 4s cap, starter ~12s≈3x cap, solution ~1.6s), expected_effort, SOLUTION.md, VERIFICATION.tsv. INDEX.md: 30/30 DONE (VERIFIED sweep = iter-2 gate wave).
- **B1 staged**: `bench/run-one.sh` (mktemp workspace, exact copylist, metric.sh sha256 before/after → metric_tampered rows, plain arm `-p -ne -nc -ns` vs godmode arm `--skill <repo>/skills`, both `zai/glm-5`, LEAK_SCAN_HIT/429_hit/timeout notes, flock-append, exit-0-always) and `bench/run-farm.sh` (deterministic queue, --batch/--tasks/--lanes/--runs-per-combo/--verify-wave/--dry-run, chunked xargs, checkpoint resume by 4-field key, lane-drop 4→2 on ≥3 429-hits) + results.tsv header + .gitignore. **Lead-verified via stub tests**: run-one all 5 paths (success/exact-godmode-argv/tamper-sha/leak/timeout-124); run-farm queue order, batch cap, resume-exact, verify-wave +2-per-pass idempotent, bad-id exit 2, SIGINT no-dup-rows (trap-deferral nuance noted below). Real results.tsv untouched (GM_BENCH_ROOT test isolation).
- **Fleet pattern (compressed by quota + 60-min lead timeout)**: 3-lens council IN PARALLEL (arch/risk/scope — merged: glm-5 hardcode, detection-over-prevention for solution leakage, GM_BENCH_ROOT isolation, verify-wave arithmetic fix 120+2G≥150) → 4 implementers IN PARALLEL → wave-2 2 implementers. Two planner dispatches were rejected by the read-only task classifier before report-shaped phrasing landed (3rd try 3/3).
- **429 root-cause identified**: fleet subagents default to **glm-5.3** (GOAL3 rule 4: walled until 18:40 today) — wave-1's simultaneous child failures were window exhaustion, not concurrency (lead's explicit `zai/glm-5` probe succeeded mid-outage). All remaining fleet dispatches must pin `model: zai/glm-5` explicitly; wave-2 children on glm-5.3 were killed at ~6 min and their scopes lead-completed.

### NEXT (ordered, iter 2 opens with these)
1. **B1 exit = PILOT**: `bash bench/run-farm.sh --tasks bug-01,feat-03 --lanes 2` (both arms, real zai/glm-5 runs; first 4 scored rows in results.tsv) + arm-audit probes (plain arm must show zero godmode skills; godmode arm must show repo skills loaded).
2. Gate wave (reviewer+security+tester IN PARALLEL, all pinned zai/glm-5) over commit b4b8938 diff → INDEX DONE→VERIFIED sweep (30 tasks).
3. B2 execution: `--batch 24` drains, lanes 4→2 on 429, until ≥150 rows (policy: 2 scored runs/combo both arms = 120 + verify-wave +2 per godmode pass).
4. B3: analyze.py + honest showdown post.

### BLOCKERS
- glm-5.3 5h window (until 18:40 UTC) starved implementer waves 1-2; mitigated by explicit zai/glm-5 pinning (probe-verified working).

### LESSONS
- **The fleet's default child model is NOT the session model** — children spawned without an explicit `model:` ran glm-5.3 into the quota wall while the lead's glm-5 probe sailed through. Explicit per-dispatch model pinning is now standing practice for M3.
- GOAL3's B1 inline `--model zai/glm-5.3` is stale vs rule 4's `zai/glm-5` — 3/3 council lenses + empirical 429 evidence: rule 4 wins; runner hardcodes glm-5.
- Perf-metric sizing is node-version-dependent (9.8ms/item on /usr/bin/node v20 vs 51µs on v24): always measure on the box that runs the farm, at final N, before freezing caps.
- Metric total-runtime budget must include generator passes (perf-05 PASS path ≈10.3s, generator-dominated) — cap the workload by the ≤30s contract, not just the program under test.
- bash defers INT traps until the foreground pipeline ends: a single-PID SIGINT to run-farm mid-chunk lets the chunk finish (invariants held — zero dup keys, resume exact); real kills should signal the process group. Cosmetic, documented.
- workflowScript task briefs must be backtick-free (JS template literal parsing) and report-shaped for read-only agents — two failure modes, two re-dispatches, both avoidable.

### Rows completed
- 0 scored rows (B2 not yet started; pilot = iter-2 opener). results.tsv: header only, committed.
