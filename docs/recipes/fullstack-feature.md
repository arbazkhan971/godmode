# Recipe: Adding a Full-Stack Feature

> From design to deployment. A complete Godmode workflow for building a feature that spans database, API, and frontend.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `think → plan → schema → api → ui → build → test → e2e → review → ship` |
| **Timeline** | 3-5 days for a medium-complexity feature |
| **Team size** | 1-2 engineers (full-stack) |
| **Example feature** | "Team Workspaces" — multi-user workspaces with roles, invitations, and shared resources in a project management app |

---

## The Scenario

You are adding Team Workspaces to "TaskFlow," a project management SaaS:
- **Current state:** Single-user accounts, each user sees only their own projects
- **Goal:** Users can create workspaces, invite team members, assign roles, and share projects within a workspace
- **Stack:** Next.js 14 (App Router) + tRPC + Prisma + PostgreSQL + Tailwind CSS
- **Scope:** Database schema, API layer, and full UI (settings, invitations, role management)

---

## Phase 1: Design (Day 1)

### Step 1: Think — Design the Feature

```
> /godmode:think I need to add team workspaces to TaskFlow. Users should be
  able to create a workspace, invite members via email, assign roles
  (owner, admin, member, viewer), and share projects within the workspace.
  Each user can belong to multiple workspaces.

Godmode: Researching codebase...

CODEBASE CONTEXT:
- Next.js 14 with App Router
- tRPC for API layer
- Prisma ORM with PostgreSQL
- Auth: NextAuth.js with email/password + Google OAuth
- Current models: User, Project, Task, Comment
- No multi-tenancy currently

Two questions:
1. Should workspace switching be instant (like Slack) or require page reload?
2. Free plan: how many workspace members? (Affects pricing logic)

> Instant switching. Free plan: up to 5 members.

Godmode: Writing spec...

SPEC: Team Workspaces

User stories:
  - As a user, I can create a workspace and become its owner
  - As a workspace owner, I can invite members via email
  - As an invited user, I receive an email and join via invitation link
  - As a workspace admin, I can change member roles
  - As a workspace owner, I can remove members
  - As a workspace member, I see all shared projects in the workspace
  - As a user, I can switch between workspaces instantly
  - As a user, I see a "Personal" workspace for my private projects

UI requirements:
  - Workspace switcher in the sidebar (dropdown)
  - Settings page: /workspace/settings (name, avatar, members)
  - Invitation flow: email → landing page → join
  - Role badges on member list
  - Workspace-scoped navigation (projects, members, settings)

Edge cases:
  - User invited to workspace they are already in
  - Owner tries to leave (must transfer ownership first)
  - Invitation expired (7-day expiry)
  - Free plan limit reached (show upgrade prompt)
  - Last admin cannot be downgraded to member

Saved: docs/specs/team-workspaces.md
Commit: "spec: team workspaces — multi-user workspaces with roles and invitations"
```

### Step 2: Plan — Break Down the Work

```
> /godmode:plan

Godmode: Reading spec... Analyzing codebase...

IMPLEMENTATION PLAN: 18 tasks in 4 phases

Phase 1: Database (Tasks 1-4)
  Task 1: Add Workspace, WorkspaceMember, Invitation models to Prisma schema
  Task 2: Add workspace_id foreign key to Project model
  Task 3: Create migration + seed default "Personal" workspace for existing users
  Task 4: Add database indexes for workspace queries

Phase 2: API (Tasks 5-10)
  Task 5: Workspace CRUD tRPC router (create, update, delete)
  Task 6: Member management router (invite, remove, updateRole)
  Task 7: Invitation router (accept, decline, resend)
  Task 8: Workspace middleware (inject current workspace into context)
  Task 9: Update Project router to scope by workspace
  Task 10: Add workspace plan limits (member count enforcement)

Phase 3: Frontend (Tasks 11-16)
  Task 11: Workspace switcher component (sidebar dropdown)
  Task 12: Workspace settings page (/workspace/settings)
  Task 13: Member list with role management
  Task 14: Invitation form (email input, role selection)
  Task 15: Invitation acceptance page (/invite/[token])
  Task 16: Update project list to show workspace-scoped projects

Phase 4: Polish (Tasks 17-18)
  Task 17: Invitation email template (SendGrid)
  Task 18: Free plan upgrade prompt when member limit reached

Branch: feat/team-workspaces
Saved: docs/plans/team-workspaces-plan.md
```

---

## Phase 2: Database Layer (Day 1-2)

### Step 3: Schema — Design and Implement

```
> /godmode:schema

Godmode: Designing database schema changes...

SCHEMA CHANGES:

New models:
  Workspace:
    id            String   @id @default(cuid())
    name          String
    slug          String   @unique
    avatarUrl     String?
    plan          Plan     @default(FREE)
    ownerId       String
    owner         User     @relation("WorkspaceOwner")
    members       WorkspaceMember[]
    projects      Project[]
    invitations   Invitation[]
    createdAt     DateTime @default(now())
    updatedAt     DateTime @updatedAt

  WorkspaceMember:
    id            String   @id @default(cuid())
    workspaceId   String
    workspace     Workspace @relation
    userId        String
    user          User     @relation
    role          Role     @default(MEMBER)
    joinedAt      DateTime @default(now())
    @@unique([workspaceId, userId])
    @@index([userId])

  Invitation:
    id            String   @id @default(cuid())
    workspaceId   String
    workspace     Workspace @relation
    email         String
    role          Role     @default(MEMBER)
    token         String   @unique @default(cuid())
    status        InviteStatus @default(PENDING)
    invitedById   String
    invitedBy     User     @relation
    expiresAt     DateTime
    createdAt     DateTime @default(now())
    @@index([email, workspaceId])

  enum Role { OWNER ADMIN MEMBER VIEWER }
  enum Plan { FREE PRO ENTERPRISE }
  enum InviteStatus { PENDING ACCEPTED DECLINED EXPIRED }

Modified models:
  Project:
    + workspaceId  String
    + workspace    Workspace @relation
    @@index([workspaceId])

  User:
    + activeWorkspaceId  String?
    + workspaces         WorkspaceMember[]
    + ownedWorkspaces    Workspace[] @relation("WorkspaceOwner")

Migration plan:
  1. Add new tables (non-breaking)
  2. Add nullable workspaceId to Project
  3. Create "Personal" workspace for each existing user
  4. Backfill Project.workspaceId to personal workspace
  5. Make Project.workspaceId required

Saved: prisma/schema.prisma (updated)
Generated: prisma/migrations/20260319_add_workspaces/migration.sql
Commit: "schema: add Workspace, WorkspaceMember, Invitation models"
Commit: "migrate: backfill personal workspaces for existing users"
```

---

## Phase 3: API Layer (Day 2-3)

### Step 4: API — Implement tRPC Routers

```
> /godmode:build --phase 2

Godmode: Building API layer (Tasks 5-10)...

Task 5: RED — Writing test for workspace CRUD...
  Test: "should create workspace and add creator as owner"
  Test: "should update workspace name and slug"
  Test: "should prevent non-owner from deleting workspace"
  ✓ Tests fail (no implementation)

Task 5: GREEN — Implementing workspace router...
  File: src/server/routers/workspace.ts
  Endpoints: create, update, delete, getById, list
  ✓ All tests pass

Task 6: RED → GREEN — Member management...
  File: src/server/routers/workspace-member.ts
  Endpoints: invite, remove, updateRole, listMembers
  Authorization: owner can do everything, admin can invite/remove members
  Tests: 12 new tests covering role-based permissions

Task 7: RED → GREEN — Invitation handling...
  File: src/server/routers/invitation.ts
  Endpoints: accept, decline, resend, listPending
  Logic: Token validation, expiry check, duplicate prevention
  Tests: 8 tests including edge cases (expired, already-member)

Task 8: Workspace context middleware...
  File: src/server/middleware/workspace.ts
  Reads activeWorkspaceId from user, injects workspace into tRPC context
  All downstream routers can access ctx.workspace

Task 9: Update project router...
  File: src/server/routers/project.ts (modified)
  All project queries now filtered by ctx.workspace.id
  Tests updated: 6 modified to include workspace context

Task 10: Plan limits enforcement...
  File: src/server/middleware/plan-limits.ts
  FREE plan: max 5 members (checked on invite)
  Returns error with upgrade prompt when limit reached

BUILD PHASE 2 COMPLETE:
  ✓ 6 tasks, 42 new tests, all passing
  ✓ Lint: clean
  ✓ Type check: clean

Commit: "feat: workspace tRPC routers — CRUD, members, invitations"
Commit: "feat: workspace context middleware and plan limit enforcement"
```

---

## Phase 4: Frontend (Day 3-4)

### Step 5: UI — Build the Interface

```
> /godmode:ui --analyze

Godmode: Analyzing existing UI patterns...

EXISTING UI PATTERNS:
  Component library: Custom components with Tailwind CSS
  Layout: Sidebar + main content area
  Navigation: Sidebar with icon + text items
  Forms: React Hook Form + Zod validation
  Data fetching: tRPC hooks (useQuery, useMutation)
  Toast notifications: Sonner
  Modals: Radix Dialog
  State: Zustand for client state, tRPC for server state

COMPONENT PLAN:
  New components:
    WorkspaceSwitcher    — dropdown in sidebar header
    MemberList           — table with role badges and actions
    InviteForm           — email + role selector modal
    RoleBadge            — colored badge for OWNER/ADMIN/MEMBER/VIEWER
    UpgradePrompt        — shown when plan limit reached

  New pages:
    /workspace/settings  — workspace name, avatar, danger zone
    /workspace/members   — member list + invite button
    /invite/[token]      — invitation acceptance page

  Modified components:
    Sidebar              — add WorkspaceSwitcher at top
    ProjectList          — scoped to current workspace
    Layout               — workspace context provider

> /godmode:build --phase 3

Godmode: Building frontend (Tasks 11-16)...

Task 11: WorkspaceSwitcher component
  File: src/components/workspace-switcher.tsx
  Features:
    - Dropdown showing all user workspaces
    - Current workspace highlighted
    - "Create workspace" option at bottom
    - Instant switching (updates Zustand store + URL)
  Tests: 4 component tests (render, switch, create)

Task 12: Workspace settings page
  File: src/app/workspace/settings/page.tsx
  Sections:
    - General: name, slug, avatar upload
    - Danger zone: delete workspace (owner only)
  Form: React Hook Form with zod schema matching API
  Tests: 3 tests (render, update, delete confirmation)

Task 13: Member list with role management
  File: src/components/member-list.tsx
  Features:
    - Table: avatar, name, email, role badge, actions
    - Role dropdown (admin+ can change roles)
    - Remove button (with confirmation dialog)
    - Owner transfer option
  Tests: 5 tests (render, role change, remove, owner protection)

Task 14: Invitation form
  File: src/components/invite-form.tsx
  Features:
    - Modal with email input + role selector
    - Bulk invite (comma-separated emails)
    - Shows remaining seats on free plan
    - Upgrade prompt when limit reached
  Tests: 4 tests (single invite, bulk, limit reached)

Task 15: Invitation acceptance page
  File: src/app/invite/[token]/page.tsx
  Features:
    - Token validation on page load
    - Shows workspace name and inviter
    - Accept/decline buttons
    - Auto-redirect to workspace after acceptance
    - Error states: expired, already-member, invalid token
  Tests: 4 tests (accept, decline, expired, invalid)

Task 16: Workspace-scoped project list
  File: src/app/workspace/projects/page.tsx (modified)
  Change: useQuery now passes workspace.id
  Shows: Only projects in the current workspace
  Tests: 2 tests (correct workspace filter, empty state)

BUILD PHASE 3 COMPLETE:
  ✓ 6 tasks, 22 new component tests, all passing
  ✓ Lint: clean
  ✓ Type check: clean
  ✓ Visual: components match existing design language

Commit: "feat: workspace UI — switcher, settings, members, invitations"
```

---

## Phase 5: Testing and Quality (Day 4-5)

### Step 6: Test — Unit and Integration Tests

```
> /godmode:test --coverage-target 90

Godmode: Analyzing coverage for workspace feature...

COVERAGE ANALYSIS:
  Workspace router: 94% covered
  Member router: 91% covered
  Invitation router: 88% covered ← needs improvement
  UI components: 85% covered ← needs improvement

Gap analysis:
  1. Invitation expiry edge case not tested
  2. Concurrent invitation acceptance race condition
  3. Workspace deletion cascade (projects, members, invitations)
  4. UI: empty states for new workspace (no projects, no members)
  5. UI: error states for network failures

Writing tests...

Tests added: 11 new tests
Coverage: 88% → 93% ✓ TARGET MET

Commit: "test: workspace feature coverage gaps — expiry, cascade, empty states"
```

### Step 7: E2E — End-to-End Browser Tests

```
> /godmode:e2e

Godmode: Writing end-to-end tests with Playwright...

E2E TEST SUITE: Team Workspaces

Test 1: "Complete workspace creation flow"
  → Login → Create workspace → Verify sidebar shows new workspace
  → Verify redirect to workspace dashboard

Test 2: "Invite member and they join"
  → Login as owner → Invite member@test.com
  → Open invitation email link → Accept invitation
  → Verify member appears in member list
  → Login as member → Verify workspace visible in switcher

Test 3: "Role-based permissions"
  → Login as member → Verify no "Settings" link
  → Login as admin → Verify "Settings" visible but no "Delete"
  → Login as owner → Verify full settings access

Test 4: "Workspace switching"
  → Create 2 workspaces → Add projects to each
  → Switch workspace → Verify project list changes
  → Verify URL updates to new workspace slug

Test 5: "Plan limit enforcement"
  → Invite 5 members (free plan limit)
  → Try to invite 6th → Verify upgrade prompt shown
  → Verify invitation NOT sent

Test 6: "Owner cannot leave without transferring ownership"
  → Login as owner → Try to leave workspace
  → Verify error: "Transfer ownership first"
  → Transfer ownership to admin → Now can leave

Test 7: "Invitation expiry"
  → Create invitation → Manually expire it in DB
  → Open invitation link → Verify "expired" message
  → Verify "Request new invitation" button

All 7 E2E tests passing.
Execution time: 45 seconds (parallel across 3 browser contexts)

Commit: "e2e: workspace feature — 7 end-to-end Playwright tests"
```

### Step 8: Review — Code Review

```
> /godmode:review

Godmode: Running 2-stage code review...

STAGE 1: Automated checks
  ✓ Lint: clean
  ✓ Types: zero errors
  ✓ Tests: 75 new tests + 7 E2E, all passing
  ✓ Coverage: 93%
  ✓ Dependencies: no new vulnerabilities
  ✓ Bundle size: +12 KB (acceptable)
  ✓ Accessibility: workspace switcher keyboard-navigable

STAGE 2: Agent review

REVIEW REPORT:
Overall: 8.8/10

MUST FIX (1 item):
  1. Invitation token is cuid() — while unique, it is not cryptographically
     random. Replace with crypto.randomBytes(32).toString('hex') for
     security-sensitive invitation links.

SHOULD FIX (2 items):
  1. WorkspaceSwitcher re-renders on every sidebar update. Wrap in
     React.memo() and extract workspace list query.
  2. Workspace deletion should be a soft-delete (add deletedAt column)
     to allow recovery and comply with data retention requirements.

NICE TO HAVE (2 items):
  1. Add optimistic updates for invitation acceptance (instant UI feedback).
  2. Consider adding a workspace activity log for audit purposes.

Verdict: APPROVED after MUST FIX resolved

> /godmode:fix

Godmode: Fixing review items...

Fix 1: ✓ Replaced cuid() with crypto.randomBytes(32) for invitation tokens
Fix 2: ✓ Added React.memo to WorkspaceSwitcher, extracted query
Fix 3: ✓ Added deletedAt column for soft-delete

Commit: "fix: secure invitation tokens, memo workspace switcher, soft-delete"
```

---

## Phase 6: Ship (Day 5)

### Step 9: Ship — Deploy the Feature

```
> /godmode:ship --pr

Godmode: Starting 8-phase shipping workflow...

Phase 1: INVENTORY
  14 commits on feat/team-workspaces
  Files: 32 new, 8 modified
  Migrations: 2 (add workspace tables, backfill personal workspaces)

Phase 2: CHECKLIST
  ✓ Tests: 75 unit + 7 E2E, all passing
  ✓ Lint: clean
  ✓ Types: clean
  ✓ Coverage: 93%
  ✓ Review: APPROVED
  ✓ Migration: tested on staging DB copy
  ✓ Feature flag: WORKSPACE_FEATURE ready for gradual rollout

Phase 3: PREPARE
  ✓ Built production bundle
  ✓ Migration dry-run on staging: 847ms (fast enough for zero-downtime)

Phase 4: DRY RUN
  ✓ Staging deployment: all features working
  ✓ E2E tests on staging: 7/7 passing

Phase 5: PR
  PR #312 created: "feat: team workspaces — multi-user workspaces with roles and invitations"
  Description:
    - Database: 3 new tables, 1 modified table
    - API: 3 new tRPC routers (workspace, member, invitation)
    - UI: workspace switcher, settings, members, invite flow
    - Tests: 75 unit + 7 E2E
    - Migration: backward-compatible, zero-downtime

Phase 6: VERIFY
  ✓ CI: all checks green
  ✓ Preview deployment: working

Phase 7: LOG
  Ship log: .godmode/ship-log.tsv

Phase 8: MONITOR (post-merge)
  Deploy behind feature flag → enable for team → 10% rollout → 100%

PR #312: https://github.com/org/taskflow/pull/312
```

---

## Full-Stack Feature Anatomy

### Files Created/Modified

```
Database layer:
  prisma/schema.prisma                           — 3 new models, 2 modified
  prisma/migrations/20260319_add_workspaces/      — migration SQL

API layer:
  src/server/routers/workspace.ts                 — workspace CRUD
  src/server/routers/workspace-member.ts          — member management
  src/server/routers/invitation.ts                — invitation handling
  src/server/middleware/workspace.ts               — workspace context
  src/server/middleware/plan-limits.ts             — plan enforcement

Frontend:
  src/components/workspace-switcher.tsx            — sidebar dropdown
  src/components/member-list.tsx                   — member table with actions
  src/components/invite-form.tsx                   — invitation modal
  src/components/role-badge.tsx                    — role indicator
  src/components/upgrade-prompt.tsx                — plan limit prompt
  src/app/workspace/settings/page.tsx              — settings page
  src/app/workspace/members/page.tsx               — members page
  src/app/invite/[token]/page.tsx                  — invitation acceptance

Tests:
  tests/server/workspace.test.ts                  — 18 API tests
  tests/server/workspace-member.test.ts           — 16 API tests
  tests/server/invitation.test.ts                 — 12 API tests
  tests/components/workspace-switcher.test.tsx     — 4 UI tests
  tests/components/member-list.test.tsx            — 5 UI tests
  tests/components/invite-form.test.tsx            — 4 UI tests
  tests/components/invite-acceptance.test.tsx      — 4 UI tests
  tests/e2e/workspaces.spec.ts                    — 7 E2E tests
  tests/coverage-gaps.test.ts                     — 11 gap tests
```

### Total Stats

| Metric | Value |
|--------|-------|
| Tasks completed | 18 |
| Files created | 18 |
| Files modified | 8 |
| Lines added | ~2,400 |
| Unit tests | 75 |
| E2E tests | 7 |
| Test coverage | 93% |
| Time | ~4 days |

---

## The Workflow Pattern

For any full-stack feature, the pattern is:

```
1. THINK    — What are we building? What are the edge cases?
2. PLAN     — Break it into tasks by layer (DB → API → UI)
3. SCHEMA   — Database changes first (foundation)
4. API      — Build API endpoints with TDD
5. UI       — Build frontend consuming the API
6. TEST     — Fill coverage gaps
7. E2E      — End-to-end browser tests for critical flows
8. REVIEW   — Automated + agent code review
9. SHIP     — PR, deploy, monitor
```

Each layer builds on the previous one. Database changes are stable before API code depends on them. API is tested before the UI calls it. E2E tests verify the full integration.

---

## Custom Chain for Full-Stack Features

```yaml
# .godmode/chains.yaml
chains:
  full-stack-feature:
    description: "Complete full-stack feature from design to deploy"
    steps:
      - think
      - plan
      - schema
      - build     # API layer with TDD
      - ui        # analyze patterns
      - build     # UI layer with TDD
      - test:
          args: "--coverage-target 90"
      - e2e
      - review:
          on_fail: fix
          retry: true
      - ship

  quick-feature:
    description: "Small feature, skip E2E and deep review"
    steps:
      - plan
      - build
      - test
      - ship
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [API Feature Example](../examples/api-feature.md) — Backend-only feature walkthrough
- [Greenfield SaaS Recipe](greenfield-saas.md) — When you are building the whole app
- [Performance Optimization Recipe](performance-optimization.md) — Making your feature fast
