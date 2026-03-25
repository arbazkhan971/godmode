---
name: rbac
description: Permission and access control (RBAC/ABAC/ReBAC).
---

## Activate When
- `/godmode:rbac`, "permissions", "access control"
- "roles", "who can access", "authorization model"
- Building features restricting authenticated user actions

## Workflow

### 1. Requirements Discovery
```
App type: monolith|microservices|multi-tenant SaaS
Complexity:
  Simple roles (admin/user/viewer) -> RBAC
  Dynamic attributes (time/location) -> ABAC
  Resource relationships (owner/member) -> ReBAC
  Combination -> Hybrid
```
```bash
# Detect existing auth/authz
grep -rl "role\|permission\|authorize\|can\?" \
  --include="*.ts" --include="*.rb" --include="*.py" src/
```

### 2. Permission Model Selection

**RBAC (Role-Based):**
```
Role hierarchy:
  super_admin -> org_admin -> team_admin -> member
Permissions: create|read|update|delete per resource
Role-permission mapping table
```
IF roles < 10 and stable: pure RBAC is sufficient.

**ABAC (Attribute-Based):**
```
Policy: (Subject, Resource, Action, Environment) -> PERMIT|DENY
Subject: user.role, user.department, user.clearance
Resource: resource.owner, resource.classification
Environment: time, IP, MFA status
```
IF decisions depend on context (time, location): ABAC.

**ReBAC (Relationship-Based):**
```
Tuples: user:alice has owner on document:doc1
Inheritance: owner implies editor implies viewer
Tools: OpenFGA, SpiceDB, Ory Keto
```
IF Google Docs-style sharing model: ReBAC.

### 3. Role Hierarchy
```
Strict (tree): each role has one parent
Lattice (DAG): roles can have multiple parents
Scoped: roles apply within scope (org/team/project)
```
IF > 20 roles: audit for overlap and consolidate.
IF unused permissions for 90+ days: flag as excessive.

### 4. Resource-Based Access
```
Every resource has:
  owner_id (full control)
  tenant_id (isolation boundary)
  visibility: private|team|organization|public
Evaluation chain:
  1. Owner? -> ALLOW
  2. Super admin? -> ALLOW (audit logged)
  3. Explicit permission? -> Check
  4. Role-based? -> Check hierarchy
  5. ABAC policy? -> Evaluate
  6. Default: DENY
```

### 5. Policy Engine
```
function evaluate(subject, resource, action, context):
  denials = findMatchingPolicies(DENY, ...)
  IF denials.length > 0: return DENY
  allows = findMatchingPolicies(ALLOW, ...)
  IF allows.length > 0: return ALLOW
  return DENY  # default deny
```
LOG every decision (ALLOW and DENY) with full context.

### 6. Audit Logging
```
Every authorization decision logged:
  timestamp, subject, resource, action,
  decision (allow/deny), policy_id, reason
Storage: append-only or write-once
Retention: minimum 1 year for compliance
```
IF audit log not append-only: security risk.
IF no audit log: MUST implement before launch.

## Quality Targets
- Target: <10ms permission check latency
- Target: 0 privilege escalation paths in role hierarchy
- Policy evaluation: <50ms for complex multi-role checks
- Target: 100% of endpoints covered by authorization middleware

## Hard Rules
1. DEFAULT DENY — no policy match = DENY.
2. NEVER check roles in code — check permissions.
3. NEVER frontend-only authorization (backend enforces).
4. NEVER bypass policy engine (even super_admin).
5. NEVER allow escalation via delegation.
6. NEVER grant permanent admin (use time-limited).
7. ALWAYS log ALLOW and DENY decisions.

## TSV Logging
Append `.godmode/rbac-decisions.tsv`:
```
timestamp	model	roles	permissions	resources	audit	verdict
```

## Keep/Discard
```
KEEP if: permission checks pass AND no escalation
  AND audit captures allow/deny.
DISCARD if: unauthorized access possible OR
  audit broken OR permissions regressed.
```

## Stop Conditions
```
STOP when FIRST of:
  - All resources have permission mappings
  - Default deny enforced every endpoint
  - Audit logging covers all decisions
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Legitimate request denied | Check audit log, verify hierarchy |
| Escalation possible | Fix policy, test both directions |
| Missing audit entries | Verify middleware, check async flush |
