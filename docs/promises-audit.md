# Promise Audit

**Generated:** 2026-04-26
**Scope:** numeric/measurable claims in `README.md`, `SKILL.md`, `AGENTS.md`.
**Method:** for each claim, run a verification command. No claim is marked
delivered without a reproduced number.

## Claim 1: 134 skills

- **Source:** `README.md:7,10,118,229,231,276`; `SKILL.md:3,36`; `AGENTS.md:3,343`; `package.json:61`.
- **Verification:** `find skills -name SKILL.md -type f | wc -l`
- **Actual:** **134**
- **Status:** ✅ delivered
- **Notes:** `CONTRIBUTING.md:477,791`, `GEMINI.md:35,64`, `OPENCODE.md:22,51` still say "126 skills" — stale-doc drift in adapter docs. Mechanical sed required.

## Claim 2: ~90% routing-time context reduction

- **Source:** `README.md:7,133,195,369`; `SKILL.md:315`; `AGENTS.md:114`; `skills/godmode/SKILL.md:107`.
- **Verification:** total chars/lines through Tier 1 extractor vs. full read.
- **Actual:**
  - Full read: **27,260 lines** (matches "~27k")
  - Documented awk extractor (buggy fallthrough `{print}`): **1,867 lines** → **93.2% reduction**
  - Corrected extractor (used in `tests/route-eval.sh`): **563 lines** → **97.9% reduction**
  - The cited "~2,700 lines" reproduces with **neither** extractor; appears back-computed.
- **Status:** ✅ headline 90% over-delivered (both extractors clear it). ❌ "~2,700 lines" mid-figure unbacked.

## Claim 3: 40-60% emit-side reduction (terse mode)

- **Source:** `README.md:133,197,254,371`; `skills/terse/SKILL.md:6,14`.
- **Verification:** look for benchmark output, run `skills/terse/SKILL.md:148-153` verify command.
- **Actual:** **No benchmark data anywhere in the repo.** Verify command never run.
- **Status:** ❌ unbacked
- **Notes:** Internal contradiction — `skills/terse/SKILL.md:135-156` § Success Criterion sets the bar at "≥30% reduction. Accept ≥20% as success for short loops." The README claim of 40-60% is **above the skill's own success bar.**

## Claim 4: >95% correct skill match on natural language input

- **Source:** `skills/godmode/SKILL.md:208` § Quality Targets.
- **Verification:** `bash tests/route-eval.sh` (102-prompt eval).
- **Actual:** **68%** at audit time (now 67% after eval-set cleanup, optimize loop in progress).
- **Status:** ❌ unbacked at 95%; metric live and tracked.

## Claim 5a: <2s skill routing time

- **Source:** `skills/godmode/SKILL.md:206` § Quality Targets.
- **Verification:** no timing harness exists. Adjacent: route-eval.sh runs 102 prompts in ~61s (≈600ms/prompt mean) — but that's the bash runner, not the orchestrator's actual route step in agent context.
- **Status:** 🔒 unverifiable end-to-end.

## Claim 5b: <5s stack detection

- **Source:** `skills/godmode/SKILL.md:207`.
- **Verification:** no timing harness. Mechanically Step 1 is two `ls` and a couple `--version` probes — well under 5s on any disk.
- **Status:** 🔒 unverifiable.

## Claim 6: All 8 pipeline skills inherit Default Activations via Rule 0

- **Source:** `README.md:211`; `SKILL.md:343-351`.
- **Verification:** `grep -nE "Inherits Default Activations" skills/{think,plan,build,test,fix,optimize,secure,ship}/SKILL.md`
- **Actual:** all 8 carry the `0. Inherits Default Activations` line:
  - `skills/think/SKILL.md:139`, `plan/:83`, `build/:100`, `test/:68`, `fix/:87`, `optimize/:102`, `secure/:113`, `ship/:108`
- **Status:** ✅ delivered

## Claim 7: 134 skills routable via Tier 1 (only `principles` exempt)

- **Source:** `skills/godmode/SKILL.md:152-156`.
- **Verification:** `grep -L "## Activate When" skills/*/SKILL.md`
- **Actual:** only `skills/principles/SKILL.md`.
- **Status:** ✅ delivered

## Claim 8: 7 subagents

- **Source:** `README.md:11,118,215`; `SKILL.md:3`; `AGENTS.md:3,48,302`.
- **Verification:** 9 files in `agents/`, but `AGENTS.md:64` explicitly counts 7 built-in (planner, builder, reviewer, optimizer, explorer, security, tester) plus 2 specialists (code-reviewer, spec-reviewer).
- **Status:** ✅ delivered

## Claim 9: Max 5 parallel agents per round

- **Source:** `README.md:127,178`; `SKILL.md:149`; `AGENTS.md:262,313`.
- **Verification:** runtime constraint — not statically checkable.
- **Status:** 🔒 unverifiable from repo alone.

## Claim 10: README demo numerics (847ms→198ms, 47 tests, 7 findings)

- **Source:** `README.md:32-43, 47-60, 64-79`.
- **Status:** 🔒 illustrative; not asserted as reproducible.

## Summary

| Status | Count | Claims |
|---|---|---|
| ✅ delivered | 5 | 134 skills, Rule 0 in 8 pipelines, principles-only-exempt, 7 subagents, headline 90% routing reduction |
| ⚠️ partial | 1 | <2s routing (adjacent data) |
| ❌ unbacked | 3 | terse 40-60%, ≥95% accuracy (live), "~2,700 lines" figure |
| 🔒 unverifiable | 3 | <5s stack detection, runtime 5-agent cap, demo numerics |

## Recommendations

### Measure (build the harness)

1. **Terse 40-60%** — wire `skills/terse/SKILL.md:148-153` verify command into `tests/terse-bench.sh`. Run synthetic 10-round optimize loop in two modes; write reduction% to `.godmode/terse-bench.tsv`. If actual lands at 35-45%, soften README. The README currently claims more than the skill's own success criterion.
2. **Routing/stack timing** — wrap orchestrator Step 1 and Step 2 in `printf + date +%N` harness. Log to `.godmode/timing.tsv`. <2s and <5s become trivially verifiable on every call.

### Soften (rephrase the claim)

3. **>95% routing accuracy** — replace with `"Target: >95%, current: <N>% on tests/route-eval-prompts.tsv; tracked, improving."` Don't advertise the target while the eval prints lower.
4. **"~2,700 lines"** — cite the actual number from whichever extractor stays canonical. Either ~570 (corrected) or ~1,870 (documented-but-buggy). Current ~2,700 is back-solved.

### Fix (not soften)

5. **126 vs 134 drift** in `CONTRIBUTING.md`, `GEMINI.md`, `OPENCODE.md`. Mechanical.
6. **Buggy awk in `skills/godmode/SKILL.md:103`** — replace with the runner's three-line form so docs and tests agree.

### Remove

None. Every claim has a basis or a live eval; soften and measure rather than remove.
