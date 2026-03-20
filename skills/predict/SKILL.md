---
name: predict
description: 5-persona evaluation. Independent assessment then consensus. Gate before building.
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
# 1. DEFINE — What is being evaluated?
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

# 3. DISPATCH 5 PERSONAS (parallel agents)
#    Each persona receives: the full spec, codebase context from step 2, and their specific focus area.
#    Each persona evaluates INDEPENDENTLY — no cross-talk.

personas = [
    Agent("Backend Architect (15yr)", focus="Scalability, data model, API contracts, error handling, database schema, migration safety"),
    Agent("Frontend Lead (12yr)",     focus="UX, rendering performance, component design, accessibility, state management, bundle size"),
    Agent("SRE (10yr)",               focus="Reliability, monitoring, failure modes, recovery, resource limits, deployment risk"),
    Agent("Security Researcher (11yr)", focus="Attack surface, data exposure, auth/authz, injection, supply chain, secrets handling"),
    Agent("Product Manager (13yr)",   focus="User value, scope creep, timeline realism, MVP vs full scope, adoption risk")
]

FOR each persona:
    Output format (mandatory — reject if missing any field):
        VERDICT: YES | REVISE | NO
        CONFIDENCE: 1-10 (integer)
        RISKS:
          - {risk_description} @ {file:line} — SEVERITY: {critical|high|medium|low}
            MITIGATION: {concrete code change or architectural change}
        PRAISE: {what's good about this approach — max 2 items}

# 4. COLLECT — Gather all 5 persona outputs.
#    Validate: every risk has file:line. Every mitigation is a concrete action.
#    Reject vague findings: "add more tests" → rejected. "add test for null user.id at src/auth/login.ts:42" → accepted.

# 5. SYNTHESIZE — Merge findings.
#    Deduplicate: same file:line from multiple personas → merge, keep highest severity.
#    Classify: blockers (any NO verdict or critical severity), warnings (REVISE or high severity), notes (medium/low).
#    Conflicts: if personas disagree on the same file:line, report both views — don't average.

avg_confidence = mean(all confidence scores)
yes_count = count(VERDICT == YES)
revise_count = count(VERDICT == REVISE)
no_count = count(VERDICT == NO)
blocker_count = count(critical severity risks) + no_count

# 6. GATE — Determine outcome.
IF avg_confidence >= 7 AND no_count == 0:
    gate = "PROCEED"
    next_step = "/godmode:plan"
ELIF avg_confidence >= 4 OR (no_count == 0 AND revise_count > 0):
    gate = "REVISE"
    next_step = "/godmode:think with all risks as constraints"
ELSE:
    gate = "RETHINK"
    next_step = "/godmode:think with fundamental concerns"

# 7. REPORT — Print full findings.
Print findings table: persona, verdict, confidence, risk count.
Print all risks sorted by severity (critical → low).
Print gate result and next step.

# 8. LOG — Append to .godmode/predict-results.tsv
FOR each persona:
    append_tsv(timestamp, feature, persona, verdict, confidence, risk_count, top_risk, mitigation, gate)

Print: "Predict: Confidence {avg}/10. Blockers: {blocker_count}. Gate: {gate}. Verdicts: {yes_count}Y {revise_count}R {no_count}N."
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
    PRAISE: {what's good}
  ```
- **Synthesis:**
  ```
  ┌─────────────────────┬─────────┬────────────┬───────┐
  │ Persona             │ Verdict │ Confidence │ Risks │
  ├─────────────────────┼─────────┼────────────┼───────┤
  │ Backend Architect   │ YES     │ 8          │ 2     │
  │ Frontend Lead       │ YES     │ 7          │ 1     │
  │ SRE                 │ REVISE  │ 6          │ 3     │
  │ Security Researcher │ YES     │ 8          │ 1     │
  │ Product Manager     │ YES     │ 9          │ 0     │
  └─────────────────────┴─────────┴────────────┴───────┘
  ```
- **Gate:** `Gate: {PROCEED|REVISE|RETHINK} → next: {/godmode:plan|/godmode:think}`
- **Final:** `Predict: Confidence {avg}/10. Blockers: {count}. Gate: {gate}. Verdicts: {Y}Y {R}R {N}N.`

## TSV Logging
Append to `.godmode/predict-results.tsv` after every evaluation. One row per persona. Columns:
```
timestamp	feature	persona	verdict	confidence	risk_count	top_risk	mitigation	gate
2024-01-15T10:30:00Z	jwt-refresh	backend_architect	YES	8	2	token storage race condition @ src/auth/token.ts:42	add mutex lock around token write	PROCEED
2024-01-15T10:30:00Z	jwt-refresh	frontend_lead	YES	7	1	stale token in memory after refresh @ src/hooks/useAuth.ts:18	invalidate token cache on 401	PROCEED
2024-01-15T10:30:00Z	jwt-refresh	sre	REVISE	6	3	no circuit breaker on auth service @ src/api/client.ts:90	add retry with exponential backoff	PROCEED
```

## Success Criteria
- [ ] All 5 personas produced verdicts with VERDICT, CONFIDENCE, RISKS, and PRAISE fields
- [ ] Every risk has a specific file:line reference (no vague "somewhere in the codebase")
- [ ] Every mitigation is a concrete action (code change, config change, or architectural decision)
- [ ] Gate result is computed correctly from verdicts and confidence scores
- [ ] Disagreements between personas are reported as-is, not averaged or hidden
- [ ] `.godmode/predict-results.tsv` has 5 rows (one per persona) for this evaluation
- [ ] Next step recommendation is printed (PROCEED → plan, REVISE/RETHINK → think)

## Error Recovery
- **If `.godmode/spec.md` does not exist:** Ask the user for a text description of the proposal. If they provide one, evaluate that directly. If not, recommend `/godmode:think` first and stop.
- **If a persona produces vague findings (no file:line):** Reject the finding. Re-run that persona with explicit instruction: "Every risk must reference a specific file:line. Re-read the codebase context and be specific." Max 2 retries, then mark persona as "incomplete" in TSV.
- **If all personas agree (5 YES or 5 NO):** Flag as potential groupthink. Print: "WARNING: unanimous verdict. Consider: is the proposal obviously good/bad, or are we missing edge cases?" Still proceed with the gate result.
- **If the codebase is new (no existing files referenced in spec):** Personas evaluate against the proposed architecture only. Backend Architect and SRE focus on design patterns. Security Researcher focuses on planned auth/data flow. Note in output: "greenfield evaluation — risks are architectural, not code-specific."
- **If confidence scores vary widely (stddev > 2.5):** Print: "HIGH VARIANCE: personas disagree significantly. Review individual assessments carefully." Report each persona's reasoning, don't just show the average.

## Anti-Patterns
1. **Vague risks without file:line references.** "Consider error handling" is rejected. "Missing null check on `user.id` at `src/auth/login.ts:42` causes crash when user is deleted mid-session" is accepted.
2. **Averaging away disagreements.** If Backend Architect says YES (9/10) and SRE says NO (3/10), report both views. Don't report 6/10 average and call it REVISE. The disagreement itself is the signal.
3. **Skipping the gate.** The gate (PROCEED/REVISE/RETHINK) is mandatory. Never output findings without a gate result. Never proceed to `/godmode:plan` with a REVISE or RETHINK gate.
4. **Personas echoing each other.** Each persona must evaluate from their domain expertise only. The Security Researcher should not comment on UX. The Product Manager should not comment on database schemas.
5. **Praising without substance.** PRAISE field exists to acknowledge good design decisions, but "looks good" is rejected. "Using refresh token rotation prevents token theft replay attacks" is accepted.

## Examples

### Example 1: PROCEED gate — high confidence
```
$ /godmode:predict
Evaluating: JWT refresh token rotation (42 lines)
[Backend Architect] VERDICT: YES | CONFIDENCE: 8/10
  RISKS:
    - Token storage race condition when concurrent requests refresh @ src/auth/token.ts:42 — critical
      MITIGATION: Add atomic compare-and-swap on token version column in DB
    - No token family tracking for replay detection @ src/auth/token.ts:60 — medium
      MITIGATION: Add token_family column to refresh_tokens table
  PRAISE: Rotation pattern prevents indefinite token reuse

[Frontend Lead] VERDICT: YES | CONFIDENCE: 8/10
  RISKS:
    - Stale token in React state after background refresh @ src/hooks/useAuth.ts:18 — high
      MITIGATION: Subscribe to token change event, invalidate React Query cache on refresh

[SRE] VERDICT: YES | CONFIDENCE: 7/10
  RISKS:
    - No circuit breaker on auth service calls @ src/api/client.ts:90 — high
      MITIGATION: Add retry with exponential backoff (3 attempts, 1s/2s/4s)

[Security Researcher] VERDICT: YES | CONFIDENCE: 9/10
  RISKS:
    - Refresh token not bound to device fingerprint @ src/auth/token.ts:30 — medium
      MITIGATION: Include user-agent hash in refresh token claims

[Product Manager] VERDICT: YES | CONFIDENCE: 9/10
  RISKS: (none)
  PRAISE: Invisible to users, reduces support tickets for "logged out unexpectedly"
Gate: PROCEED → next: /godmode:plan
Predict: Confidence 8.2/10. Blockers: 0. Gate: PROCEED. Verdicts: 5Y 0R 0N.
```

### Example 2: REVISE gate — SRE raises concerns
```
$ /godmode:predict
Evaluating: real-time WebSocket notifications (67 lines)
[Backend Architect] VERDICT: YES | CONFIDENCE: 7/10
  RISKS:
    - No connection pooling strategy for WebSocket server @ src/ws/server.ts:15 — high
      MITIGATION: Add connection limit per user (max 5) and idle timeout (30s)
  PRAISE: Event-driven architecture decouples notification from business logic

[Frontend Lead] VERDICT: YES | CONFIDENCE: 7/10
  RISKS:
    - No reconnection strategy on disconnect @ src/hooks/useSocket.ts:22 — high
      MITIGATION: Implement exponential backoff reconnect with jitter
  PRAISE: Component subscription model is clean

[SRE] VERDICT: NO | CONFIDENCE: 4/10
  RISKS:
    - No horizontal scaling plan for WebSocket state @ src/ws/server.ts:1 — critical
      MITIGATION: Add Redis pub/sub adapter for multi-instance support
    - No memory limit on per-connection message buffer @ src/ws/handler.ts:45 — critical
      MITIGATION: Cap buffer at 100 messages, drop oldest on overflow
    - No health check endpoint for WebSocket server @ — high
      MITIGATION: Add /ws/health that reports connection count and memory usage

[Security Researcher] VERDICT: REVISE | CONFIDENCE: 6/10
  RISKS:
    - WebSocket upgrade has no auth check @ src/ws/server.ts:8 — critical
      MITIGATION: Validate JWT in upgrade handler before accepting connection
    - No rate limiting on incoming WebSocket messages @ src/ws/handler.ts:20 — high
      MITIGATION: Add per-connection rate limit (100 msg/min)

[Product Manager] VERDICT: YES | CONFIDENCE: 8/10
  RISKS:
    - Scope includes 6 notification types but MVP needs only 2 @ — medium
      MITIGATION: Ship with "message" and "alert" types only, add others in v2

Gate: RETHINK → next: /godmode:think (SRE voted NO, 3 critical risks)
Predict: Confidence 6.4/10. Blockers: 4. Gate: RETHINK. Verdicts: 3Y 1R 1N.
```

### Example 3: Greenfield evaluation (no existing codebase)
```
$ /godmode:predict
Evaluating: new CLI tool for database migrations (85 lines)
Note: greenfield evaluation — risks are architectural, not code-specific.
[Backend Architect] YES 7/10 — 2 risks (no rollback strategy @ proposed:migrations/runner.ts, schema diff unspecified)
[Frontend Lead] YES 8/10 — 0 risks (CLI tool, no frontend)
[SRE] REVISE 5/10 — 2 risks (no advisory lock for concurrent runs @ proposed:migrations/lock.ts — critical, no dry-run mode)
[Security Researcher] YES 8/10 — 1 risk (SQL injection via string concat in templates @ proposed:migrations/template.ts)
[Product Manager] REVISE 6/10 — 1 risk (no differentiator vs Prisma/Flyway/Alembic)
Gate: REVISE → next: /godmode:think (avg 6.8, 1 critical risk)
Predict: Confidence 6.8/10. Blockers: 1. Gate: REVISE. Verdicts: 3Y 2R 0N.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Run the 5 persona evaluations **sequentially** instead of in parallel.
- Each persona: set system context to the persona's focus area, provide spec + codebase context, collect structured output.
- Ensure each persona is evaluated independently — do not include previous persona outputs in the next persona's context.
- After all 5 complete: merge, deduplicate, synthesize, and gate identically to the parallel version.
- ~5x slower but identical quality and output format.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
