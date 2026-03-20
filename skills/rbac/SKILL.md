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
  - Admin users: <admin levels, super-admin vs scoped admin>
  - Service accounts: <what services access what resources>
  - External partners: <limited access patterns>

Multi-tenancy:
  Tenant isolation: <shared database | schema-per-tenant | DB-per-tenant>
  Cross-tenant access: <never | admin only | configurable sharing>
  Tenant-scoped roles: <same roles all tenants | custom roles per tenant>

Delegation requirements:
  - [ ] Users can share resources with other users
  - [ ] Users can delegate permissions temporarily
  - [ ] Admins can create custom roles
  - [ ] Organization hierarchy affects permissions
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
│  Inheritance: Child roles inherit ALL permissions of parent  │
│  Direction: More specific roles are LOWER in hierarchy       │
│  Assignment: Users get ONE primary role per scope            │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Role definitions:
┌─────────────────┬────────────────────────────────────────────┐
│ Role            │ Permissions                                │
├─────────────────┼────────────────────────────────────────────┤
│ super_admin     │ * (all permissions, all tenants)           │
│ org_admin       │ org:*, users:*, billing:*, settings:*      │
│ team_admin      │ team:*, projects:*, members:manage         │
│ member          │ projects:read, projects:write, comments:*  │
│ contributor     │ projects:read, projects:write              │
│ viewer          │ projects:read, comments:read               │
│ billing_admin   │ billing:*, invoices:*, plans:*             │
│ support_admin   │ users:read, tickets:*, logs:read           │
└─────────────────┴────────────────────────────────────────────┘

Permission format: <resource>:<action>
  Actions: create, read, update, delete, list, manage, *
  Resources: projects, users, teams, billing, settings, ...
  Wildcard: resource:* = all actions on resource
  Global: * = all permissions (super_admin only)

Data model:
  Table: roles
    id, name, description, parent_role_id, tenant_id, is_system, created_at

  Table: permissions
    id, resource, action, description, created_at

  Table: role_permissions
    role_id, permission_id

  Table: user_roles
    user_id, role_id, scope_type (global | org | team), scope_id, granted_by, granted_at, expires_at
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

Action attributes (how):
  - action.type (create | read | update | delete | share | export)
  - action.bulk (true | false)
  - action.fields (which fields are being accessed/modified)

Environment attributes (context):
  - env.time (business hours, maintenance window)
  - env.ip_range (office network, VPN, public)
  - env.device_trust (managed device, BYOD)
  - env.risk_score (from threat detection system)

Policy examples:
  POLICY: "Confidential documents require MFA"
  RULE: IF resource.classification == "confidential"
        AND user.mfa_verified == false
        THEN DENY
        MESSAGE: "MFA required for confidential resources"

  POLICY: "Data export only during business hours from trusted networks"
  RULE: IF action.type == "export"
        AND (env.time NOT IN business_hours OR env.ip_range != "office")
        THEN DENY
        MESSAGE: "Data export restricted to business hours from office network"

  POLICY: "Bulk operations require admin role"
  RULE: IF action.bulk == true
        AND user.role NOT IN ["admin", "super_admin"]
        THEN DENY
        MESSAGE: "Bulk operations require admin privileges"

Policy evaluation order:
  1. Explicit DENY rules (highest priority)
  2. Explicit PERMIT rules
  3. Default DENY (if no rule matches, deny access)

Policy storage:
  Format: JSON | YAML | Rego (Open Policy Agent) | Cedar (AWS)
  Location: Database (dynamic) | Config files (static) | Policy service (centralized)
  Caching: Cache evaluated policies with TTL (5 minutes)
  Versioning: Policy changes tracked with author, timestamp, reason
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
    relation owner: user
    relation editor: user | team#member
    relation viewer: user | team#member | document#editor | document#owner

    permission can_read = viewer
    permission can_write = editor + owner
    permission can_delete = owner
    permission can_share = owner
  }

  type folder {
    relation owner: user
    relation editor: user | team#member
    relation viewer: user | team#member

    permission can_read = viewer + editor + owner
    permission can_create_document = editor + owner
  }

  type team {
    relation admin: user
    relation member: user

    permission can_manage = admin
    permission can_invite = admin
  }

  type organization {
    relation owner: user
    relation admin: user
    relation member: user | team#member

    permission can_manage = owner + admin
    permission can_read = member
  }

Relationship inheritance:
  document#owner -> document#editor -> document#viewer (implicit upward)
  folder#editor -> folder/documents#editor (parent to child)
  team#member -> team's resources (transitive through membership)

Implementation options:
  - SpiceDB (open-source Zanzibar) — recommended for self-hosted
  - Auth0 FGA (managed Zanzibar)
  - Ory Keto (open-source)
  - AWS Verified Permissions (Cedar language)
  - Custom: Tuple store in PostgreSQL with recursive CTE queries

Check API:
  check(user: "alice", permission: "can_read", resource: "document:doc1") -> ALLOWED
  check(user: "bob", permission: "can_delete", resource: "document:doc1") -> DENIED
  list_objects(user: "alice", permission: "can_read", type: "document") -> [doc1, doc2, doc5]
  list_users(permission: "can_read", resource: "document:doc1") -> [alice, bob, team:eng members]

Performance:
  Lookup latency target: < 10ms at p99
  Caching: Cache permission checks with short TTL (30s-60s)
  Consistency: Tunable — immediate for writes, eventual for reads
  Indexing: Composite index on (resource_type, resource_id, relation, user_type, user_id)
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
│  3. SCOPED ROLES (role + scope)                              │
│     Same role name has different permissions per scope.       │
│     Example: admin of Team A != admin of Team B.             │
│     Use when: Multi-tenant or multi-team systems.            │
│                                                              │
│  Constraint rules:                                           │
│  - Separation of duties: user cannot hold role A AND role B  │
│  - Maximum role count: user can hold at most N roles         │
│  - Prerequisite roles: role A requires role B first          │
│  - Temporal constraints: role expires after time period       │
│  - Cardinality: at most N users can hold a specific role     │
│                                                              │
└──────────────────────────────────────────────────────────────┘

Role assignment workflow:
  1. Request: User or admin requests role assignment
  2. Validate: Check constraints (separation of duties, prerequisites)
  3. Approve: Auto-approve (within policy) or require approval workflow
  4. Assign: Create user_role record with scope and expiry
  5. Audit: Log assignment with who, what, when, why, approved_by
  6. Notify: Inform user of new role and permissions
  7. Review: Periodic access review (quarterly recommended)
```

### Step 4: Resource-Based Access Control
Design resource-level permissions:

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

  Share operations:
    GRANT: Owner adds permission for another user/team
    REVOKE: Owner removes previously granted permission
    TRANSFER: Owner transfers ownership to another user
    RESTRICT: Admin overrides to limit access regardless of grants

Field-level access control:
  For sensitive fields within a resource:
  ┌────────────────────┬──────────┬──────────┬──────────────┐
  │ Field              │ Viewer   │ Member   │ Admin        │
  ├────────────────────┼──────────┼──────────┼──────────────┤
  │ name               │ READ     │ READ     │ READ/WRITE   │
  │ email              │ HIDDEN   │ READ     │ READ/WRITE   │
  │ phone              │ HIDDEN   │ HIDDEN   │ READ/WRITE   │
  │ salary             │ HIDDEN   │ HIDDEN   │ READ         │
  │ ssn                │ HIDDEN   │ HIDDEN   │ HIDDEN       │
  └────────────────────┴──────────┴──────────┴──────────────┘

  Implementation: Response filtering middleware that strips fields
  based on the requester's effective permissions.
```

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
│                                                              │
│  ROLE INHERITANCE:                                           │
│  super_admin inherits org_admin permissions                  │
│  org_admin inherits team_admin permissions                   │
│  team_admin inherits member permissions                      │
│  member inherits viewer permissions                          │
│                                                              │
│  OVERRIDES:                                                  │
│  Explicit DENY at any level overrides inherited ALLOW        │
│  Explicit ALLOW at resource level overrides role-based DENY  │
│  Admin override: super_admin can bypass all restrictions     │
│                                                              │
└──────────────────────────────────────────────────────────────┘

DELEGATION MODEL:
  Types of delegation:
    1. GRANT delegation: User can grant their own permissions to others
       Constraint: Cannot delegate permissions they don't hold
       Constraint: Cannot delegate higher than their own level
       Example: Editor can grant viewer access, but not editor access

    2. IMPERSONATION: Admin acts as another user (for support)
       Constraint: Requires super_admin or support_admin role
       Constraint: All actions logged as "admin acting as user"
       Constraint: Time-limited (max 1 hour per session)
       Audit: Both admin and target user IDs logged

    3. TEMPORARY ELEVATION: User requests temporary higher permissions
       Flow: Request -> Approval -> Time-limited grant -> Auto-revoke
       Example: Developer requests prod access for 2 hours to debug
       Constraint: Requires approval from role holder or admin
       Audit: Elevation reason, approver, duration, actions taken

    4. API KEY DELEGATION: Service acts on behalf of user
       Scope: API key inherits user's permissions (or subset)
       Constraint: Key cannot exceed granting user's permissions
       Audit: Actions attributed to both key and user

  Delegation constraints:
    - Maximum delegation depth: 2 (A delegates to B, B cannot delegate further)
    - Delegation expiry: Required (no permanent delegations)
    - Revocation: Delegator can revoke at any time
    - Cascade: Revoking delegation revokes all sub-delegations
```

### Step 6: Policy Engine Design
Design the authorization decision engine:

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

    // 3. Check role-based permissions (with hierarchy traversal)
    roles = getUserRoles(subject, resource.scope)
    effectivePermissions = resolveRoleHierarchy(roles)
    if effectivePermissions.includes(resource.type + ":" + action):
      return { decision: ALLOW, reason: "role-based", role: roles }

    // 4. Check relationship-based access
    if hasRelationship(subject, resource, action):
      return { decision: ALLOW, reason: "relationship-based" }

    // 5. Default deny
    return { decision: DENY, reason: "no matching policy (default deny)" }

Performance requirements:
  Authorization check latency: < 5ms at p99
  Policy evaluation: Cache compiled policies in memory
  Role resolution: Cache user roles with 60-second TTL
  Relationship lookups: Index-optimized queries, < 10ms
  Batch operations: Support bulk permission checks for list views

Middleware integration:
  // Express/Koa style
  app.get("/projects/:id", authenticate, authorize("projects:read"), handler)
  app.put("/projects/:id", authenticate, authorize("projects:update"), handler)
  app.delete("/projects/:id", authenticate, authorize("projects:delete"), handler)

  // Decorator style (NestJS, Python)
  @RequirePermission("projects:read")
  async getProject(id) { ... }

  // Programmatic check
  if (await can(user, "delete", project)) { ... }
```

### Step 7: Audit Logging for Access Decisions
Design comprehensive audit logging:

```
AUDIT LOGGING:
Every authorization decision MUST be logged.

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
    },
    resource: {
      type: "<resource-type>",
      id: "<resource-id>",
      tenant_id: "<tenant-id>",
      owner_id: "<owner-id>"
    },
    action: "<action-attempted>",
    context: {
      policy_id: "<matching-policy>",
      reason: "<why allowed/denied>",
      evaluation_time_ms: <N>,
      request_id: "<correlation-id>"
    }
  }

Log levels by event:
┌──────────────────────────────────────┬────────────┬─────────┐
│ Event                                │ Log Level  │ Alert   │
├──────────────────────────────────────┼────────────┼─────────┤
│ Normal access (ALLOW)                │ INFO       │ No      │
│ Access denied (DENY)                 │ WARN       │ No      │
│ Repeated denials (same user, 5+)     │ ERROR      │ YES     │
│ Privilege escalation attempt         │ ERROR      │ YES     │
│ Admin impersonation started          │ WARN       │ YES     │
│ Role assignment / revocation         │ INFO       │ No      │
│ Permission delegation                │ INFO       │ No      │
│ Bulk data access                     │ WARN       │ Monitor │
│ Access from unusual IP/location      │ WARN       │ Monitor │
│ Access outside business hours        │ WARN       │ Monitor │
│ Super_admin action                   │ WARN       │ YES     │
└──────────────────────────────────────┴────────────┴─────────┘

Audit log requirements:
  - Immutable: Append-only storage (no updates, no deletes)
  - Tamper-resistant: Cryptographic hash chain or write-once storage
  - Retention: Minimum 1 year (or per compliance requirement)
  - Searchable: Query by user, resource, action, time range, decision
  - Real-time: Stream to SIEM for alerting (Splunk, Datadog, ELK)
  - Separated: Audit logs stored separately from application logs
  - No PII: Log user IDs, not names or emails (join at query time)

Access review automation:
  Periodic reports (quarterly recommended):
    - Users with no activity in 90 days -> Flag for deactivation
    - Users with admin roles who haven't used admin features -> Flag for downgrade
    - Resources with no access in 180 days -> Flag for archive
    - Permissions granted but never used -> Flag for revocation
    - Unusual access patterns -> Flag for investigation
```

### Step 8: Implementation Artifacts
Generate the authorization implementation:

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
│ src/auth/controllers/permissions  │ Permission management     │
│ src/auth/controllers/grants       │ Resource sharing/grants   │
│ src/auth/controllers/delegation   │ Permission delegation     │
│ migrations/create_roles_tables    │ Database schema migration │
│ migrations/create_audit_tables    │ Audit log table migration │
│ seeds/default_roles               │ Default role + permission │
│ tests/auth/authorization/         │ Authorization tests       │
│ tests/auth/audit/                 │ Audit logging tests       │
│ docs/auth/access-control-model.md │ Authorization documentation│
└──────────────────────────────────────────────────────────────┘
```

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
│    Grant delegation: <enabled/disabled>                      │
│    Impersonation: <enabled/disabled>                         │
│    Temporary elevation: <enabled/disabled>                   │
│                                                             │
│  Audit logging:                                             │
│    All decisions logged: <YES/NO>                           │
│    Alert rules configured: <N>                              │
│    Retention period: <N months/years>                        │
│    SIEM integration: <YES/NO>                               │
│                                                             │
│  Verdict: <PRODUCTION READY | NEEDS WORK | INCOMPLETE>      │
├────────────────────────────────────────────────────────────┤
│  REMAINING WORK:                                            │
│  1. <item>                                                  │
│  2. <item>                                                  │
└────────────────────────────────────────────────────────────┘
```

### Step 10: Commit and Transition
1. Save architecture as `docs/auth/<feature>-access-control.md`
2. Commit: `"rbac: <feature> — <model> with <N> roles, <N> permissions"`
3. If INCOMPLETE: "Access control model needs additional work. Address remaining items, then re-run `/godmode:rbac`."
4. If PRODUCTION READY: "Access control model complete. Run `/godmode:build` to implement, or `/godmode:secure` to audit."

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

## Multi-Agent Dispatch

For comprehensive access control implementation:

```
PARALLEL AGENTS:
Agent 1 — Permission Model & Schema (worktree: rbac-model)
  - Design role hierarchy and permission definitions
  - Create database migrations for roles, permissions, user_roles
  - Implement role resolution with hierarchy traversal
  - Seed default roles and permissions

Agent 2 — Policy Engine & Middleware (worktree: rbac-engine)
  - Build policy evaluation engine (RBAC/ABAC/ReBAC)
  - Create authorization middleware for all routes
  - Implement field-level access control
  - Add resource ownership checks

Agent 3 — Audit & Compliance (worktree: rbac-audit)
  - Design audit log schema (immutable, tamper-resistant)
  - Implement audit logging for all authorization decisions
  - Build access review reports
  - Configure alerting for suspicious patterns

Agent 4 — Admin & Delegation (worktree: rbac-admin)
  - Build role management API (CRUD for roles/permissions)
  - Implement delegation and sharing flows
  - Build impersonation with audit trail
  - Create admin UI for permission management

MERGE ORDER: Agent 1 first (schema), Agent 2 (engine), then Agent 3 + 4 in parallel.
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
4. **Audit everything.** Every authorization decision — ALLOW and DENY — must be logged with enough context to reconstruct what happened during a security investigation. If it is not logged, it did not happen.
5. **Roles are not permissions.** Roles are collections of permissions assigned to users. Permissions are fine-grained actions on resources. Check permissions in code, not roles. `if (can(user, "delete", project))` is correct. `if (user.role === "admin")` is fragile.
6. **Resource ownership matters.** The owner of a resource should always have full control. Ownership is a relationship, not a role. Combine RBAC (role-based) with resource ownership (relationship-based) for practical systems.
7. **Test authorization, not just authentication.** Write tests that verify: users CAN access what they should, users CANNOT access what they should not, permission changes take effect, and audit logs are generated.

## Example Usage

### Designing RBAC for a SaaS platform
```
User: /godmode:rbac Design access control for our multi-tenant project management SaaS

RBAC: Discovering requirements...

ACCESS CONTROL REQUIREMENTS:
Application type: Multi-tenant SaaS
Resources: Organizations, Teams, Projects, Tasks, Files, Comments
User populations: Org owners, admins, members, guests
Multi-tenancy: Shared database with tenant_id isolation

ROLE HIERARCHY:
  org_owner
  ├── org_admin
  │   ├── project_admin
  │   │   ├── project_member
  │   │   │   └── project_viewer
  │   │   └── project_contributor
  │   └── team_admin
  └── billing_admin

PERMISSION MATRIX:
┌─────────────────┬───────┬───────┬────────┬────────┬────────┐
│ Resource        │ Owner │ Admin │ Member │ Contrib│ Viewer │
├─────────────────┼───────┼───────┼────────┼────────┼────────┤
│ Project CRUD    │ CRUD  │ CRUD  │ RU     │ R      │ R      │
│ Task CRUD       │ CRUD  │ CRUD  │ CRUD   │ CRU    │ R      │
│ File upload     │ YES   │ YES   │ YES    │ YES    │ NO     │
│ Member invite   │ YES   │ YES   │ NO     │ NO     │ NO     │
│ Settings        │ YES   │ YES   │ NO     │ NO     │ NO     │
│ Billing         │ YES   │ bill  │ NO     │ NO     │ NO     │
└─────────────────┴───────┴───────┴────────┴────────┴────────┘

Generating implementation artifacts...
```

### Adding ReBAC to an existing system
```
User: /godmode:rbac Add document sharing with "shared with me" functionality

RBAC: Analyzing existing access control...
  Found: RBAC with roles in src/auth/
  Missing: Relationship-based access for document sharing

ReBAC EXTENSION:
  Relationship types:
    document:owner — full control
    document:editor — read + write
    document:viewer — read only
    document:commenter — read + comment

  Sharing flow:
    Owner clicks "Share" -> Selects user/team -> Chooses permission level
    Creates relationship tuple: user:bob has editor on document:doc123
    Bob sees document in "Shared with me" via list_objects query

  Implementation:
    Table: resource_relationships (type, resource_id, relation, subject_type, subject_id)
    Middleware: Check ownership OR relationship before resource access
    Query: "Shared with me" = list all resources where user has any relation
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full access control design and implementation |
| `--model rbac` | RBAC model design |
| `--model abac` | ABAC model design |
| `--model rebac` | ReBAC model design |
| `--hierarchy` | Role hierarchy design only |
| `--permissions` | Permission matrix design only |
| `--delegation` | Delegation and sharing model only |
| `--audit` | Audit logging design only |
| `--policies` | Policy engine design only |
| `--review` | Access review report (who has access to what) |
| `--migrate` | Migrate between access control models |
| `--test` | Generate authorization test suite |
| `--matrix` | Generate permission matrix visualization |

## Anti-Patterns

- **Do NOT check roles in application code.** `if (user.role === "admin")` breaks when you add new roles. Check permissions: `if (can(user, "delete", resource))`. Roles map to permissions; code checks permissions.
- **Do NOT create a "god mode" role that bypasses all checks.** Even super_admin should go through the policy engine. The policy engine ALLOWS everything for super_admin, but the decision is still logged and auditable.
- **Do NOT implement authorization in the frontend only.** Frontend hides UI elements for usability. Backend enforces permissions for security. Every API endpoint must check authorization server-side.
- **Do NOT use string concatenation for permission checks.** `user.permissions.includes("admin")` matches "billing_admin" too. Use exact matching or structured permission objects.
- **Do NOT skip audit logging for ALLOW decisions.** Logging only denials misses the most important information: what data was accessed by whom. Both ALLOW and DENY decisions must be logged.
- **Do NOT grant permanent admin access.** Temporary elevation with auto-expiry is safer. If someone needs admin access "just in case," they do not need admin access.
- **Do NOT copy another application's role structure.** Your roles should reflect YOUR application's resources and actions. A generic admin/user/viewer hierarchy rarely fits real-world requirements without customization.
- **Do NOT forget multi-tenancy isolation.** In a multi-tenant system, EVERY query must be scoped by tenant_id. A missing tenant filter is a data breach, not a bug.
- **Do NOT allow permission escalation through delegation.** A user must not be able to delegate permissions they do not hold. Validate delegation requests against the delegator's effective permissions.


## Output Format

Every RBAC invocation must produce a structured report:

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

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run RBAC tasks sequentially: permission model/schema, then policy engine/middleware, then audit/compliance, then admin/delegation.
- Use branch isolation per task: `git checkout -b godmode-rbac-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
