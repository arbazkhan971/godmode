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

  ...
```
### Step 2: Permission Model Selection
Select and design the appropriate authorization model:

#### Model: RBAC (Role-Based Access Control)
For systems with well-defined, stable role structures:

```
RBAC DESIGN:
  ROLE HIERARCHY
  super_admin
  ├── org_admin
|  | ├── team_admin |
|  |  | ├── member |
|  |  |  | └── viewer |
|  |  | └── contributor |
  ...
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
  ...
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
  ...
```
### Step 3: Role Hierarchy Design
Define the complete role hierarchy with inheritance rules:

```
ROLE HIERARCHY DESIGN:
  HIERARCHY RULES
  1. STRICT HIERARCHY (tree structure)
  Each role has exactly one parent.
  Permissions flow DOWN (parent inherits child perms).
  Use when: Simple organizational structure.
  2. LATTICE HIERARCHY (DAG structure)
  Roles can have multiple parents.
  ...
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
  INHERITANCE RULES
  ORGANIZATIONAL INHERITANCE:
  Organization -> Team -> Project -> Resource
  Org admin has admin on ALL teams, projects, resources
  Team admin has admin on team's projects and resources
  Project admin has admin on project's resources
  FOLDER/CONTAINER INHERITANCE:
  ...
```
POLICY ENGINE:
  REQUEST                POLICY ENGINE             DECISION
  ┌──────────┐          ┌──────────────┐          ┌────────┐
|  | Subject |  |  |  | ALLOW |  |
|  | Resource | -------> | Evaluate | -------> | or |  |
|  | Action |  | Policies |  | DENY |  |
|  | Context |  |  |  | + |  |
| └──────────┘          └──────────────┘ | Reason |  |
  |                   └────────┘
  v
|  | Audit Log |  |
|  | (every |  |
|  | decision) |  |

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
  ...
```
IMPLEMENTATION ARTIFACTS:
| File | Purpose |
|--|--|
| src/auth/models/role | Role definitions + hierarchy |
| src/auth/models/permission | Permission definitions |
| src/auth/models/resource-grant | Resource-level grants |
| src/auth/middleware/authorize | Permission check middleware |
| src/auth/services/policy-engine | Policy evaluation engine |
| src/auth/services/role-resolver | Role hierarchy resolution |
| src/auth/services/audit-logger | Access decision audit log |
| src/auth/controllers/roles | CRUD for roles |
### Step 9: Access Control Report

```
  ACCESS CONTROL REPORT
  Model: <RBAC | ABAC | ReBAC | Hybrid>
  Roles defined: <N>
  Permissions defined: <N>
  Resources protected: <N>
  Policies configured: <N>
  Hierarchy:
  Type: <strict | lattice | scoped>
  ...
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
  ...
```

## Key Behaviors

1. **Default deny.** If no policy explicitly grants access, the answer is DENY. Never default to ALLOW. This is the single most important security principle in access control.
2. **Least privilege.** Every role should have the minimum permissions needed to perform its function. Start with zero permissions and add only what is required. It is easier to grant additional permissions than to revoke excessive ones.
3. **Separation of duties.** Critical operations should require multiple roles. The person who creates an invoice should not be the person who approves payment. Encode these constraints in the role model.
4. **Audit everything.** Log every authorization decision — ALLOW and DENY — with enough context to reconstruct what happened during a security investigation. If it is not logged, it did not happen.
## Flags & Options
  ...
```
  RBAC RESULT
  Model: <RBAC | ABAC | ReBAC | Hybrid>
  Roles: <N defined>
  Permissions: <N defined>
  Resources protected: <N>
  Audit logging: <YES | PARTIAL | NO>
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
## Error Recovery

```
IF policy engine denies a legitimate request:
  1. Check the audit log for the denial reason and matching policy
  2. Verify the user's effective permissions (role hierarchy resolution)
  3. Add or adjust the specific permission — do not create a bypass
  4. Test both the fixed access AND ensure other restrictions still hold
  5. Log the policy change with who, what, when, and why
## Stop Conditions
```
STOP when ANY of these are true:
  - All resources have defined permissions and role mappings
  - Default deny enforced on every endpoint
  - Audit logging covers all ALLOW and DENY decisions
  - User explicitly requests stop

DO NOT STOP just because:
  - One role has complex inheritance (resolve it)
  ...
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
