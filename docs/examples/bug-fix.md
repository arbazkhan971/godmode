# Example: Debugging and Fixing a Production Bug

This example shows using Godmode to investigate and fix a bug reported by users.

## Context
- **Project:** SaaS dashboard (React + Node.js)
- **Bug:** Users report seeing other users' data after login
- **Severity:** Critical — data leak

## Session Transcript

### Phase 1: Debug

```
> /godmode:debug Users are seeing other users' dashboard data after logging in.
  This was reported by 3 users in the last hour.

Godmode: Reproducing the bug...

BUG REPORT:
Symptom: After login, dashboard shows another user's data
Reproduce: Login as user A, navigate to /dashboard, see user B's data
Reproducible: YES (intermittent — depends on login order)

Gathering evidence...
- Recent deploys: v2.3.1 deployed 4 hours ago
- Recent changes: Auth middleware refactored in commit e4f2a1b

Applying Technique 6: Diff Analysis...
git diff v2.3.0..v2.3.1 -- src/middleware/

FOUND: In the auth middleware refactor, the session store was changed from
per-request to a module-level cache for "performance."

File: src/middleware/auth.ts:12
- const sessionCache = new Map(); // MODULE LEVEL — shared across all requests!

This Map persists between requests. When user A logs in, their session is
cached. When user B logs in, if the cache key collides (both hitting the
same server instance), user B sees user A's cached session data.

Applying Technique 4: State Inspection...
Added logging at session lookup.
Confirmed: sessionCache.get() returns wrong user's session 1 in 8 requests.

HYPOTHESIS:
Root cause: Module-level session cache shared across requests causes
session cross-contamination between concurrent users.
Location: src/middleware/auth.ts:12
Evidence: Cache returns wrong user's session when key collides
Confidence: HIGH

ROOT CAUSE ANALYSIS:
Bug: Users see other users' dashboard data
Root cause: Auth middleware refactor (commit e4f2a1b) introduced a module-level
Map as a session cache. This cache is shared across all HTTP requests, causing
session data from one user to leak to another when requests overlap.
Introduced by: commit e4f2a1b "refactor: optimize auth middleware with caching"
Why not caught: No concurrent user tests exist. Single-user tests all pass.
```

### Phase 2: Fix

```
> /godmode:fix --from-debug

Godmode: Applying fix from root cause analysis...

FIX ITERATION 1:
Error: Module-level session cache causing data leak
Location: src/middleware/auth.ts:12
Fix: Remove module-level cache. Sessions should be looked up per-request
from the session store (Redis), not cached in application memory.

Applied fix:
- Removed: const sessionCache = new Map()
- Changed: getSession() now always queries Redis
- Added: per-request memoization (only caches within a single request lifecycle)

Regression test:
  "concurrent logins return correct user data for each session"
  - Simulates 10 concurrent login requests with different users
  - Verifies each response contains the correct user's data
  - This test FAILS on the old code, PASSES on the new code ✓

Verification:
✓ Specific bug: Fixed (concurrent sessions return correct data)
✓ Full test suite: 128/128 passing
✓ Regression test: passes
✓ Performance: Session lookup +2ms (acceptable tradeoff for correctness)

Commit: "fix: remove shared session cache causing data leak between users"
Commit: "test: regression test for concurrent session isolation"
```

### Phase 3: Secure (Post-Fix Audit)

```
> /godmode:secure --quick

OWASP Quick Check:
✓ A01: Access control — session isolation confirmed
✓ A07: Auth — sessions correctly scoped per-request
No additional findings.

Verdict: PASS
```

### Phase 4: Ship (Hotfix)

```
> /godmode:ship --deploy production

Ship: HOTFIX workflow activated (critical security fix)

Phase 1: Inventory — 2 commits, 2 files changed
Phase 2: Checklist — ✓ all passing
Phase 3: Prepare — ✓ built
Phase 4: Dry run — ✓ clean
Phase 5: Deploy to production — ✓ v2.3.2 deployed
Phase 6: Verify — ✓ health check OK
Phase 7: Log — ✓ recorded
Phase 8: Monitor —
  T+0:  ✓ Deployed
  T+5:  ✓ Error rate 0.00%, no session leaks detected
  T+15: ✓ All clear. Hotfix confirmed stable.
```

## Results
- **Time to fix:** 20 minutes (from report to deployed hotfix)
- **Root cause:** Shared session cache across requests
- **Fix:** Per-request session lookup from Redis
- **Regression test:** Concurrent session isolation test added
- **Impact:** Zero data leaks after deploy
