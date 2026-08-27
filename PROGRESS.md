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
