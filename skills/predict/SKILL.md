---
name: predict
description: 3-persona + meta-expert evaluation. Independent assessment then synthesis. Gate before building.
---

## Activate When
- `/godmode:predict`, "will this work?", "evaluate this approach", "is this a good idea?", "risk assessment"
- Spec exists and user wants a confidence check before planning/building
- Called by `/godmode:plan` when >10 tasks detected (automatic risk gate)

## Auto-Detection
The godmode orchestrator routes here when:
- A `.godmode/spec.md` exists and no `.godmode/predict-results.tsv` entry for this feature
- User expresses uncertainty about feasibility, risk, or approach viability
- `/godmode:plan` recommends it for large task counts

## Step-by-step Workflow
```
# 1. DEFINE — What to evaluate?
spec = read(".godmode/spec.md")
IF spec does not exist:
    proposal = ask user for description
    IF proposal is empty:
        Print: "Predict: no spec or proposal found. Run /godmode:think first."
        STOP
ELSE:
    proposal = spec
codebase_context = `git ls-files | head -50` + read key config files (package.json, tsconfig.json, etc.)
Print: "Evaluating: {proposal_title} ({proposal_lines} lines)"

# 2. SCAN — Read files that the spec references.
#    For each file path in spec.files_to_modify: read the file.
#    For each new file in spec.files_to_create: read the parent directory.
#    Identify: dependencies, existing patterns, API contracts, test coverage of affected areas.

# 3. DISPATCH 3 PERSONAS (parallel, independent)
#    Each persona receives: the full spec, codebase context from step 2, and their specific focus area.
#    Each persona evaluates INDEPENDENTLY — no cross-talk.

personas = [
    Agent("Technical Architect", focus="Scalability, data model, API contracts, error handling, patterns, performance"),
    Agent("Security Researcher", focus="Attack surface, data exposure, auth/authz, injection, supply chain, secrets"),
    Agent("Release Lead",        focus="Shipping risk, rollback plan, monitoring, deployment, resource limits, failure modes")
]

FOR each persona:
    # Pass 1: Generate all findings
    Output format (mandatory — reject if missing any field):
        VERDICT: YES | REVISE | NO
        CONFIDENCE: 1-10 (integer)
        RISKS:
          - {risk_description} @ {file:line} — SEVERITY: {critical|high|medium|low}
            MITIGATION: {concrete code change or architectural change}
        PRAISE: {non-obvious positive only — max 2 items}

    # Pass 2: Validate findings
    FOR each risk:
        IF missing file:line OR missing concrete mitigation:
            Retry up to 2 times with: "Specify file:line and concrete mitigation."
            IF still vague after 2 retries:
                Mark finding as "incomplete" — do NOT gate on it.

    # PRAISE filter:
    #   "JWT rotation prevents token reuse" ✓ (non-obvious, specific)
    #   "looks clean" ✗ (removed — vague)
    #   "good structure" ✗ (removed — vague)
    #   Only keep praise that names a specific technique or decision and why it matters.

# 4. COLLECT — Gather all 3 persona outputs.
#    Every validated risk has file:line and concrete mitigation.
#    Incomplete findings are logged but excluded from gate calculation.

# 5. SYNTHESIZE — Meta-expert merges findings.
#    The meta-expert is NOT a 4th vote. It synthesizes the 3 personas:
#    - Deduplicate: same file:line from multiple personas → merge, keep highest severity.
#    - Classify: blockers (any NO verdict or critical severity), warnings (REVISE or high severity), notes (medium/low).
#    - Conflicts: if personas disagree on the same file:line, report both views — don't average.
#    - Incomplete findings: list separately, do not count toward gate.

yes_count = count(VERDICT == YES)
revise_count = count(VERDICT == REVISE)
no_count = count(VERDICT == NO)

# 6. GATE — Pure voting. No thresholds or averaging.
IF yes_count == 3:
    gate = "PROCEED"
    next_step = "/godmode:plan"
ELIF no_count == 0 AND (revise_count >= 1 AND revise_count <= 2):
    gate = "REVISE"
    next_step = "/godmode:think with all risks as constraints"
ELSE:  # any NO
    gate = "RETHINK"
    next_step = "/godmode:think with fundamental concerns"

# Gate summary:
#   PROCEED: all 3 YES
#   REVISE:  1-2 REVISE, 0 NO
#   RETHINK: any NO

# 7. REPORT — Print full findings.
Print findings table: persona, verdict, confidence, risk count.
Print all validated risks sorted by severity (critical → low).
Print incomplete findings separately (if any).
Print gate result and next step.

# 8. LOG — Append to .godmode/predict-results.tsv
FOR each persona:
    append_tsv(timestamp, feature, persona, verdict, confidence, risk_count, top_risk, mitigation, gate)

Print: "Predict: Gate: {gate}. Verdicts: {yes_count}Y {revise_count}R {no_count}N. Validated risks: {count}. Incomplete: {count}."
```

## Output Format
Each stage prints structured output:
- **Define:** `Evaluating: {title} ({N} lines)`
- **Persona results (per persona):**
  ```
  [{persona_name}] VERDICT: {YES|REVISE|NO} | CONFIDENCE: {N}/10
    RISKS:
      - {description} @ {file}:{line} — {severity}
        MITIGATION: {concrete action}
    PRAISE: {non-obvious positive}
  ```
- **Synthesis (meta-expert):**
  ```
| Persona | Verdict | Confidence | Risks |
|--|--|--|--|
| Technical Architect | YES | 8 | 2 |
| Security Researcher | YES | 8 | 1 |
| Release Lead | REVISE | 6 | 3 |
  Incomplete findings: 1 (excluded from gate)
  ```
- **Gate:** `Gate: {PROCEED|REVISE|RETHINK} → next: {/godmode:plan|/godmode:think}`
- **Final:** `Predict: Gate: {gate}. Verdicts: {Y}Y {R}R {N}N. Validated risks: {count}. Incomplete: {count}.`

## TSV Logging
Append to `.godmode/predict-results.tsv` after every evaluation. One row per persona. Columns:
```
timestamp	feature	persona	verdict	confidence	risk_count	top_risk	mitigation	gate
2024-01-15T10:30:00Z	jwt-refresh	technical_architect	YES	8	2	token storage race condition @ src/auth/token.ts:42	add mutex lock around token write	PROCEED
2024-01-15T10:30:00Z	jwt-refresh	security_researcher	YES	9	1	refresh token not bound to device @ src/auth/token.ts:30	include user-agent hash in claims	PROCEED
2024-01-15T10:30:00Z	jwt-refresh	release_lead	YES	7	1	no circuit breaker on auth service @ src/api/client.ts:90	add retry with exponential backoff	PROCEED
```

## Success Criteria
- [ ] All 3 personas produced verdicts with VERDICT, CONFIDENCE, RISKS, and PRAISE fields
- [ ] Every validated risk has a specific file:line reference (no vague "somewhere in the codebase")
- [ ] Every mitigation is a concrete action (code change, config change, or architectural decision)
- [ ] Vague findings retried twice then marked "incomplete" — not gated on
- [ ] PRAISE items are non-obvious and specific (no "looks clean", "good structure")
- [ ] Gate is pure voting: PROCEED = 3 YES, REVISE = 1-2 REVISE + 0 NO, RETHINK = any NO
- [ ] Meta-expert synthesized all 3 personas into final report with deduplication
- [ ] Disagreements between personas are reported as-is, not averaged or hidden
- [ ] `.godmode/predict-results.tsv` has 3 rows (one per persona) for this evaluation
- [ ] Next step recommendation is printed (PROCEED → plan, REVISE/RETHINK → think)

## Autonomous Operation
- Loop until target or budget. Never pause.
- Measure before/after. Guard: test_cmd && lint_cmd.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Error Recovery
- **If `.godmode/spec.md` does not exist:** Ask the user for a text description of the proposal. If they provide one, evaluate that directly. If not, recommend `/godmode:think` first and stop.
- **If a persona produces vague findings (no file:line):** Retry that finding with explicit instruction: "Specify file:line and concrete mitigation." Max 2 retries. If still vague, mark as "incomplete" in output and TSV. Do not gate on incomplete findings.
- **If all personas agree (3 YES or 3 NO):** Flag as potential groupthink. Print: "WARNING: unanimous verdict. Evaluate: is the proposal obviously good/bad, or are we missing edge cases?" Still proceed with the gate result.
- **If the codebase is new (no existing files referenced in spec):** Personas evaluate against the proposed architecture only. Technical Architect focuses on design patterns. Security Researcher focuses on planned auth/data flow. Release Lead focuses on deployment strategy. Note in output: "greenfield evaluation — risks are architectural, not code-specific."
- **If confidence scores vary widely (stddev > 2.5):** Print: "HIGH VARIANCE: personas disagree significantly. Review individual assessments carefully." Report each persona's reasoning.

## Hard Rules
1. Every risk must have file:line + concrete mitigation — vague risks get 2 retries then marked incomplete.
2. Gate is pure voting: PROCEED = 3 YES, REVISE = 1-2 REVISE + 0 NO, RETHINK = any NO.
3. Never gate on incomplete findings — exclude from gate calculation, log separately.
4. Each persona evaluates from their domain only — no cross-talk between persona outputs.
5. Praise must be non-obvious and specific — "looks clean" is rejected.

## Anti-Patterns
1. **Vague risks without file:line references.** "Add error handling" is rejected without specifics. "Missing null check on `user.id` at `src/auth/login.ts:42` causes crash when user is deleted mid-session" is accepted. Vague findings get 2 retries then marked incomplete.
2. **Averaging away disagreements.** If Technical Architect says YES (9/10) and Release Lead says NO (3/10), report both views. The disagreement itself is the signal.
3. **Skipping the gate.** The gate (PROCEED/REVISE/RETHINK) is mandatory. Never output findings without a gate result. Never proceed to `/godmode:plan` with a REVISE or RETHINK gate.
4. **Personas echoing each other.** Each persona evaluates from their domain expertise only. The Security Researcher should not comment on deployment strategy. The Release Lead should not comment on auth design.
5. **Vague praise.** "Looks good", "clean code", "nice approach" are all rejected. PRAISE must name a specific technique and why it matters: "Refresh token rotation prevents token theft replay attacks."
6. **Gating on incomplete findings.** If a finding has no file:line after 2 retries, it is logged but excluded from the gate decision. Do not block on unverifiable risks.

## Examples

### Example 1: PROCEED gate — all 3 YES
```
$ /godmode:predict
Evaluating: JWT refresh token rotation (42 lines)

[Technical Architect] VERDICT: YES | CONFIDENCE: 8/10
  RISKS:
    - Token storage race condition when concurrent requests refresh @ src/auth/token.ts:42 — critical
      MITIGATION: Add atomic compare-and-swap on token version column in DB
    - No token family tracking for replay detection @ src/auth/token.ts:60 — medium
      MITIGATION: Add token_family column to refresh_tokens table
  PRAISE: Rotation pattern prevents indefinite token reuse

[Security Researcher] VERDICT: YES | CONFIDENCE: 9/10
  RISKS:
    - Refresh token not bound to device fingerprint @ src/auth/token.ts:30 — medium
      MITIGATION: Include user-agent hash in refresh token claims
  PRAISE: Token family design detects stolen refresh tokens via reuse detection

[Release Lead] VERDICT: YES | CONFIDENCE: 7/10
  RISKS:
    - No circuit breaker on auth service calls @ src/api/client.ts:90 — high
      MITIGATION: Add retry with exponential backoff (3 attempts, 1s/2s/4s)
    - No rollback plan if token migration fails @ src/db/migrations/042.ts:1 — medium
      MITIGATION: Add down() migration that restores old token table schema

Meta-expert synthesis: 4 validated risks, 0 incomplete. No conflicts.
Gate: PROCEED → next: /godmode:plan
Predict: Gate: PROCEED. Verdicts: 3Y 0R 0N. Validated risks: 4. Incomplete: 0.
```

### Example 2: RETHINK gate — Release Lead says NO
```
$ /godmode:predict websocket-notifications
Evaluating: real-time WebSocket notifications (67 lines)

[Technical Architect] VERDICT: YES | CONFIDENCE: 7/10
  RISKS:
    - No connection pooling strategy for WebSocket server @ src/ws/server.ts:15 — high
      MITIGATION: Add connection limit per user (max 5) and idle timeout (30s)
  PRAISE: Event-driven architecture decouples notification from business logic

[Security Researcher] VERDICT: REVISE | CONFIDENCE: 6/10
  RISKS:
    - WebSocket upgrade has no auth check @ src/ws/server.ts:8 — critical
      MITIGATION: Validate JWT in upgrade handler before accepting connection
    - No rate limiting on incoming WebSocket messages @ src/ws/handler.ts:20 — high
      MITIGATION: Add per-connection rate limit (100 msg/min)

[Release Lead] VERDICT: NO | CONFIDENCE: 4/10
  RISKS:
    - No horizontal scaling plan for WebSocket state @ src/ws/server.ts:1 — critical
      MITIGATION: Add Redis pub/sub adapter for multi-instance support
    - No memory limit on per-connection message buffer @ src/ws/handler.ts:45 — critical
      MITIGATION: Cap buffer at 100 messages, drop oldest on overflow
    - No health check endpoint for WebSocket server (incomplete — no file:line after 2 retries)

Meta-expert synthesis: 4 validated risks, 1 incomplete (excluded from gate). 2 critical blockers from Release Lead.
Gate: RETHINK → next: /godmode:think (Release Lead voted NO, 2 critical risks)
Predict: Gate: RETHINK. Verdicts: 1Y 1R 1N. Validated risks: 4. Incomplete: 1.
```

### Example 3: Greenfield evaluation (no existing codebase)
```
$ /godmode:predict db-migration-cli
Evaluating: new CLI tool for database migrations (85 lines)
Note: greenfield evaluation — risks are architectural, not code-specific.

[Technical Architect] YES 7/10 — 2 risks (no rollback strategy @ proposed:migrations/runner.ts, schema diff unspecified @ proposed:migrations/diff.ts)
[Security Researcher] YES 8/10 — 1 risk (SQL injection via string concat in templates @ proposed:migrations/template.ts:15)
  PRAISE: Parameterized query builder in spec prevents most injection vectors
[Release Lead] REVISE 5/10 — 2 risks (no advisory lock for concurrent runs @ proposed:migrations/lock.ts:1 — critical, no dry-run mode @ proposed:cli/commands.ts:30)

Meta-expert synthesis: 5 validated risks, 0 incomplete. 1 critical from Release Lead.
Gate: REVISE → next: /godmode:think (1 critical risk, 0 NO votes)
Predict: Gate: REVISE. Verdicts: 2Y 1R 0N. Validated risks: 5. Incomplete: 0.
```

## Keep/Discard Discipline
```
After EACH persona finding:
  KEEP if: finding has file:line + concrete mitigation + at least 1 persona rates EXPLOITABLE
  DISCARD if: finding lacks file:line after 2 retries OR all personas rate NOT_EXPLOITABLE
  On discard: mark finding as "incomplete" — exclude from gate calculation.
  Never gate on incomplete or unverifiable findings.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: all 3 personas produced verdicts and gate result computed
  - budget_exhausted: max 2 retries per vague finding exhausted
  - diminishing_returns: re-evaluation produces 0 new findings
  - stuck: >5 findings discarded as incomplete with no actionable replacements
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Run the 3 persona evaluations **sequentially** instead of in parallel.
- Each persona: set system context to the persona's focus area, provide spec + codebase context, collect structured output.
- Verify each persona is evaluated independently -- do not include previous persona outputs in the next persona's context.
- After all 3 complete: meta-expert merges, deduplicates, synthesizes, and gates identically to the parallel version.
- ~3x slower but identical quality and output format.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
