---
name: rbac
description: |
  Permission and access control skill. Activates when user needs to design or implement role-based access control (RBAC), attribute-based access control (ABAC), relationship-based access control (ReBAC), role hierarchies, resource-based permissions, permission inheritance and delegation, or audit logging for access decisions. Produces permission models, policy engines, enforcement middleware, and audit infrastructure. Triggers on: /godmode:rbac, "permissions", "access control", "roles", "who can access", "authorization model", or when building features that restrict what authenticated users can do.
---

# RBAC — Permission & Access Control

## When to Activate
- User invokes `/godmode:rbac`
- User says "permissions", "access control", "roles", "who can access what"
- User says "authorization model", "role hierarchy", "permission inheritance"
- Building features that restrict actions based on user identity or attributes
- After `/godmode:auth` establishes authentication — authorization is the next step
- Pre-ship check when `/godmode:secure` detects missing access controls
- Designing multi-tenant systems with tenant-scoped permissions

## Workflow

### Step 1: Access Control Requirements Discovery
Determine the authorization model requirements:

```
ACCESS CONTROL REQUIREMENTS:
Application type: <monolith | microservices | multi-tenant SaaS | platform>
Authorization complexity:
  - [ ] Simple roles (admin, user, viewer) — use RBAC
  - [ ] Dynamic attributes (time, location, department) — use ABAC
  - [ ] Resource relationships (owner, member, shared-with) — use ReBAC
  - [ ] Combination of the above — use Hybrid

Resources to protect:
  - <resource-1>: <description, sensitivity level>
  - <resource-2>: <description, sensitivity level>
  - ...

User populations:
  - End users: <roles and typical permissions>
```

### Step 2: Permission Model Selection
Select and design the appropriate authorization model:

#### Model: RBAC (Role-Based Access Control)
For systems with well-defined, stable role structures:

```
RBAC DESIGN:
┌──────────────────────────────────────────────────────────────┐
│                    ROLE HIERARCHY                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  super_admin                                                 │
│  ├── org_admin                                               │
│  │   ├── team_admin                                          │
│  │   │   ├── member                                          │
│  │   │   │   └── viewer                                      │
│  │   │   └── contributor                                     │
│  │   │       └── viewer                                      │
│  │   └── billing_admin                                       │
│  └── support_admin                                           │
│                                                              │
```

#### Model: ABAC (Attribute-Based Access Control)
For systems requiring dynamic, context-aware authorization:

```
ABAC DESIGN:
Policy evaluation: (Subject attributes, Resource attributes, Action, Environment) -> PERMIT | DENY

Subject attributes (who):
  - user.id, user.role, user.department, user.clearance_level
  - user.tenant_id, user.org_id, user.team_ids
  - user.mfa_verified, user.email_verified
  - user.ip_address, user.location

Resource attributes (what):
  - resource.type, resource.id, resource.owner_id
  - resource.tenant_id, resource.sensitivity
  - resource.classification (public | internal | confidential | restricted)
  - resource.created_at, resource.tags

```

#### Model: ReBAC (Relationship-Based Access Control)
For systems where access depends on resource relationships (Google Zanzibar model):

```
ReBAC DESIGN:
Core concept: Authorization is determined by the RELATIONSHIP between a user and a resource.

Relationship tuples:
  Format: <user> has <relation> on <resource>
  Examples:
    user:alice  has  owner    on  document:doc1
    user:bob    has  editor   on  document:doc1
    team:eng    has  viewer   on  folder:specs
    user:alice  has  member   on  team:eng     (transitive: alice can view folder:specs)

Type definitions (schema):
  type user {}

  type document {
```

### Step 3: Role Hierarchy Design
Define the complete role hierarchy with inheritance rules:

```
ROLE HIERARCHY DESIGN:
┌──────────────────────────────────────────────────────────────┐
│                    HIERARCHY RULES                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. STRICT HIERARCHY (tree structure)                        │
│     Each role has exactly one parent.                        │
│     Permissions flow DOWN (parent inherits child perms).     │
│     Use when: Simple organizational structure.               │
│                                                              │
│  2. LATTICE HIERARCHY (DAG structure)                        │
│     Roles can have multiple parents.                         │
│     Permissions are the UNION of all ancestor permissions.   │
│     Use when: Cross-functional roles needed.                 │
│                                                              │
```
RESOURCE-BASED ACCESS CONTROL:

Resource ownership model:
  Every resource has:
    - owner_id: User who created it (full control)
    - tenant_id: Tenant that owns it (isolation boundary)
    - visibility: private | team | organization | public

Permission evaluation chain:
  1. Is user the resource owner? -> ALLOW (all actions)
  2. Is user a super_admin? -> ALLOW (all actions, audit logged)
  3. Does user have explicit permission on this resource? -> Check
  4. Does user have role-based permission? -> Check role hierarchy
  5. Does user have attribute-based permission? -> Evaluate ABAC policy
  6. Does user have relationship-based access? -> Check relationship graph
  7. Default: DENY

Resource-level sharing:
  Table: resource_grants
    id, resource_type, resource_id, grantee_type (user | team | role),
    grantee_id, permission (read | write | admin), granted_by,
    granted_at, expires_at, revoked_at
### Step 5: Permission Inheritance & Delegation
Design how permissions flow through the hierarchy:

```
PERMISSION INHERITANCE:
┌──────────────────────────────────────────────────────────────┐
│                  INHERITANCE RULES                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ORGANIZATIONAL INHERITANCE:                                 │
│  Organization -> Team -> Project -> Resource                 │
│  Org admin has admin on ALL teams, projects, resources       │
│  Team admin has admin on team's projects and resources       │
│  Project admin has admin on project's resources              │
│                                                              │
│  FOLDER/CONTAINER INHERITANCE:                               │
│  Folder permissions cascade to all documents within          │
│  Subfolder permissions can RESTRICT but not EXPAND parent    │
│  Breaking inheritance: Mark resource as "custom permissions" │
```
POLICY ENGINE:
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  REQUEST                POLICY ENGINE             DECISION   │
│  ┌──────────┐          ┌──────────────┐          ┌────────┐ │
│  │ Subject  │          │              │          │ ALLOW  │ │
│  │ Resource │ -------> │ Evaluate     │ -------> │  or    │ │
│  │ Action   │          │ Policies     │          │ DENY   │ │
│  │ Context  │          │              │          │  +     │ │
│  └──────────┘          └──────────────┘          │ Reason │ │
│                              |                   └────────┘ │
│                              v                              │
│                     ┌──────────────┐                        │
│                     │ Audit Log    │                        │
│                     │ (every       │                        │
│                     │  decision)   │                        │
│                     └──────────────┘                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Evaluation algorithm:
  function evaluate(subject, resource, action, context):
    // 1. Check explicit denials
    denials = findMatchingPolicies(DENY, subject, resource, action, context)
    if denials.length > 0:
      return { decision: DENY, reason: denials[0].reason, policy: denials[0].id }

    // 2. Check explicit allows
    allows = findMatchingPolicies(ALLOW, subject, resource, action, context)
    if allows.length > 0:
      return { decision: ALLOW, reason: allows[0].reason, policy: allows[0].id }

### Step 7: Audit Logging for Access Decisions
Design comprehensive audit logging:

```
AUDIT LOGGING:
LOG every authorization decision.

Audit log schema:
  {
    id: "<uuid>",
    timestamp: "<ISO-8601 UTC>",
    event_type: "authorization_decision",
    decision: "ALLOW" | "DENY",
    subject: {
      user_id: "<user-id>",
      role: "<effective-role>",
      ip_address: "<client-ip>",
      user_agent: "<browser/client>",
      session_id: "<session-id>"
```
IMPLEMENTATION ARTIFACTS:
┌──────────────────────────────────────────────────────────────┐
│ File                              │ Purpose                  │
├──────────────────────────────────────────────────────────────┤
│ src/auth/models/role              │ Role definitions + hierarchy│
│ src/auth/models/permission        │ Permission definitions    │
│ src/auth/models/resource-grant    │ Resource-level grants     │
│ src/auth/middleware/authorize      │ Permission check middleware│
│ src/auth/services/policy-engine   │ Policy evaluation engine  │
│ src/auth/services/role-resolver   │ Role hierarchy resolution │
│ src/auth/services/audit-logger    │ Access decision audit log │
│ src/auth/controllers/roles        │ CRUD for roles            │
### Step 9: Access Control Report

```
┌────────────────────────────────────────────────────────────┐
│  ACCESS CONTROL REPORT                                      │
├────────────────────────────────────────────────────────────┤
│  Model: <RBAC | ABAC | ReBAC | Hybrid>                     │
│  Roles defined: <N>                                         │
│  Permissions defined: <N>                                   │
│  Resources protected: <N>                                   │
│  Policies configured: <N>                                   │
│                                                             │
│  Hierarchy:                                                 │
│    Type: <strict | lattice | scoped>                        │
│    Depth: <N levels>                                        │
│    Inheritance: <enabled/disabled>                           │
│                                                             │
│  Delegation:                                                │
```
resources = list_all_protected_resources()
roles = list_all_defined_roles()
current_resource = 0
max_iterations = len(resources) * len(roles) + 10   # buffer

WHILE current_resource < len(resources) AND iteration < max_iterations:
    resource = resources[current_resource]
    iteration += 1

    FOR each role IN roles:
        PHASE 1 — ENUMERATE:
          List all permissions this role has on this resource (direct + inherited)
          Record: role | resource | permissions[] | source (direct | inherited | delegated)

        PHASE 2 — VERIFY LEAST PRIVILEGE:
          FOR each permission:
            CHECK: Is this permission actually used by users with this role? (audit log evidence)
            CHECK: Is this permission necessary for the role's documented responsibilities?
            CHECK: Does this permission grant more access than needed? (read vs read+write)
            IF unused for 90+ days AND not a break-glass permission:
              FLAG as EXCESSIVE — recommend revocation

## Least-Privilege Verification Protocol

```
FOR each user/service account:
  1. COLLECT effective permissions (resolve role hierarchy + direct grants + delegation)
  2. COMPARE against actual usage (from audit logs, last 90 days):
     - Permissions used: KEEP
     - Permissions never used: FLAG as candidate for revocation
     - Permissions used once (emergency): FLAG as candidate for just-in-time elevation
  3. GENERATE least-privilege recommendation:
     current_permissions - unused_permissions = recommended_permissions
  4. VERIFY no critical workflow breaks under recommended set:
     - Map each role's workflows to required permissions
     - Confirm recommended set covers all documented workflows
     - IF gap found: add back the specific missing permission (not the entire role)
  5. LOG to .godmode/rbac-least-privilege.tsv:
     timestamp	subject_type	subject_id	current_perms_count	used_perms_count	recommended_perms_count	excessive_count	verdict

```
FOR each permission audit finding:
  KEEP if:
    - Permission is excessive (unused 90+ days with audit log evidence)
    - Role violates separation of duties constraint
    - Delegation exceeds max depth or lacks expiry
    - tenant_id scoping is missing on any query
  DISCARD if:
    - Permission is used regularly (audit log confirms active use)
    - Permission is a documented break-glass/emergency access
    - Finding is in a non-production environment with no prod data access
    - Already remediated in previous audit cycle (check .godmode/rbac-decisions.tsv)
  RECORD: Every discard logged with justification to .godmode/rbac-discards.tsv:
    timestamp	finding_type	subject	resource	discard_reason
```

## Auto-Detection

Before prompting the user, automatically detect existing auth and access control:

```
AUTO-DETECT SEQUENCE:
1. Detect authentication layer:
   - JWT: jsonwebtoken, jose in dependencies
   - Session: express-session, cookie-session, Rails sessions
   - OAuth: passport, next-auth, devise, omniauth
   - Managed: Auth0, Clerk, Firebase Auth, Supabase Auth SDK
2. Detect existing authorization:
   - RBAC models: roles table, user_roles table in migrations/schema
   - Policy libraries: pundit (Ruby), casbin, casl (JS), django-guardian
   - Middleware: authorize, requireRole, @Roles decorator patterns
   - External: SpiceDB, Ory Keto, Auth0 FGA, AWS Verified Permissions
3. Detect multi-tenancy:
   - tenant_id columns in database schema
   - Row-level security policies in PostgreSQL
   - Subdomain-based routing
   - Organization/workspace models
4. Detect audit logging:
   - audit_logs or access_logs tables
   - PaperTrail (Rails), django-auditlog, audit packages
   - SIEM integration config (Datadog, Splunk, ELK)
5. Detect permission patterns in code:
   - Grep for: isAdmin, hasRole, canAccess, authorize, permit
   - Check middleware chains for auth checks
   - Identify unprotected routes (no auth middleware)
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. DEFAULT DENY — if no policy grants access, the answer is DENY. Always.
2. NEVER check roles in application code — check permissions. Roles map to permissions.
3. NEVER implement authorization in the frontend only — backend MUST enforce.
4. NEVER create a role that bypasses the policy engine — even super_admin goes through it.
5. NEVER allow permission escalation through delegation — validate against delegator's perms.
6. NEVER grant permanent admin access — use time-limited elevation with auto-expiry.
7. ALWAYS log BOTH allow and deny decisions with full context.
8. ALWAYS scope all queries by tenant_id in multi-tenant systems.
9. ALWAYS use immutable, append-only storage for audit logs.
10. NEVER use string matching for permission checks (e.g., includes("admin") matches "billing_admin").
11. ALWAYS separate authentication from authorization — they are different concerns.
12. ALWAYS test that users CANNOT access what they should not — not just that they CAN access what they should.
```

## Key Behaviors

1. **Default deny.** If no policy explicitly grants access, the answer is DENY. Never default to ALLOW. This is the single most important security principle in access control.
2. **Least privilege.** Every role should have the minimum permissions needed to perform its function. Start with zero permissions and add only what is required. It is easier to grant additional permissions than to revoke excessive ones.
3. **Separation of duties.** Critical operations should require multiple roles. The person who creates an invoice should not be the person who approves payment. Encode these constraints in the role model.
4. **Audit everything.** Log every authorization decision — ALLOW and DENY — with enough context to reconstruct what happened during a security investigation. If it is not logged, it did not happen.
5. **Roles are not permissions.** Roles are collections of permissions assigned to users. Permissions are fine-grained actions on resources. Check permissions in code, not roles. `if (can(user, "delete", project))` is correct. `if (user.role === "admin")` is fragile.
6. **Resource ownership matters.** The owner of a resource should always have full control. Ownership is a relationship, not a role. Combine RBAC (role-based) with resource ownership (relationship-based) for practical systems.
7. **Test authorization, not authentication.** Write tests that verify: users CAN access what they should, users CANNOT access what they should not, permission changes take effect, and audit logs are generated.

## Flags & Options

| Flag | Description |
|------|-------------|
```
┌────────────────────────────────────────────────────────────┐
│  RBAC RESULT                                                │
├────────────────────────────────────────────────────────────┤
│  Model: <RBAC | ABAC | ReBAC | Hybrid>                     │
│  Roles: <N defined>                                         │
│  Permissions: <N defined>                                   │
│  Resources protected: <N>                                   │
│  Audit logging: <YES | PARTIAL | NO>                        │
│  Verdict: <PRODUCTION READY | NEEDS WORK | INCOMPLETE>      │
└────────────────────────────────────────────────────────────┘
```

## TSV Logging

Log every RBAC design or audit to `.godmode/rbac-decisions.tsv`:

```
timestamp	feature	model	roles_count	permissions_count	resources_count	audit_logging	verdict
```

Append one row per invocation. Never overwrite previous rows.

## Success Criteria

```
PASS if ALL of the following:
  - Default deny is enforced (no policy match = DENY)
  - Application code checks permissions, not role names
  - Backend enforces authorization on every endpoint (frontend is cosmetic only)
  - Every authorization decision (ALLOW and DENY) is logged with subject, resource, action, and timestamp
  - Audit logs are immutable (append-only or write-once storage)
  - Multi-tenant queries are scoped by tenant_id
  - No permanent admin grants exist (all elevated access has expiry)
  - Delegation cannot escalate beyond the delegator's own permissions

FAIL if ANY of the following:
  - Default allow is used anywhere
  - Roles are checked in application code instead of permissions
  - Any API endpoint lacks server-side authorization
  - Authorization decisions are not logged
  - super_admin bypasses the policy engine entirely
  - String matching is used for permission checks (e.g., includes("admin"))
  - tenant_id filtering is missing in a multi-tenant system
```

## Error Recovery

```
IF policy engine denies a legitimate request:
  1. Check the audit log for the denial reason and matching policy
  2. Verify the user's effective permissions (role hierarchy resolution)
  3. Add or adjust the specific permission — do not create a bypass
  4. Test both the fixed access AND ensure other restrictions still hold
  5. Log the policy change with who, what, when, and why

IF role hierarchy produces unexpected inheritance:
  1. Print the full resolved permission set for the problematic role
  2. Trace the inheritance path from the role to each inherited permission
  3. Fix at the correct hierarchy level — do not patch at the leaf
  4. Re-run authorization tests for all roles affected by the change

IF audit logging fails or loses events:
  1. Switch to synchronous logging until the async pipeline is fixed
  2. Check for full disks, network partitions, or SIEM ingestion failures
  3. Replay any buffered events after the pipeline is restored
  4. Verify no authorization decisions occurred during the gap without logging
  5. File an incident report — unlogged authorization is a compliance violation
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All resources have defined permissions and role mappings
  - Default deny enforced on every endpoint
  - Audit logging covers all ALLOW and DENY decisions
  - User explicitly requests stop

DO NOT STOP just because:
  - One role has complex inheritance (resolve it)
  - Audit logging works for denials only (must log allows too)
```
## Output Format
Print: `RBAC: {roles} roles, {permissions} permissions. Audit log: {active|missing}. Tests: {pass|fail}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH RBAC change:
  KEEP if: all permission checks pass AND no privilege escalation possible AND audit log captures allow/deny
  DISCARD if: any unauthorized access possible OR audit logging broken OR existing permissions regressed
  On discard: revert immediately. RBAC bugs are security bugs.
```
