# /godmode:rbac

Design and implement permission and access control systems. Covers RBAC, ABAC, and ReBAC permission models, role hierarchies, resource-based access control, permission inheritance and delegation, policy engines, and audit logging for every access decision.

## Usage

```
/godmode:rbac                          # Full access control design
/godmode:rbac --model rbac             # Role-based access control
/godmode:rbac --model abac             # Attribute-based access control
/godmode:rbac --model rebac            # Relationship-based access control (Zanzibar)
/godmode:rbac --hierarchy              # Role hierarchy design
/godmode:rbac --permissions            # Permission matrix design
/godmode:rbac --delegation             # Delegation and sharing model
/godmode:rbac --audit                  # Audit logging design
/godmode:rbac --policies               # Policy engine design
/godmode:rbac --review                 # Access review report (who has access to what)
/godmode:rbac --migrate                # Migrate between access control models
/godmode:rbac --test                   # Generate authorization test suite
/godmode:rbac --matrix                 # Permission matrix visualization
```

## What It Does

1. Discovers access control requirements (resources, user populations, multi-tenancy, delegation)
2. Selects permission model (RBAC, ABAC, ReBAC, or hybrid)
3. Designs role hierarchy with inheritance rules and constraints
4. Designs resource-based permissions (ownership, sharing, field-level access)
5. Designs permission inheritance and delegation (grant, impersonation, temporary elevation)
6. Designs policy engine (evaluation algorithm, caching, middleware integration)
7. Designs audit logging (every decision logged, alerting, SIEM integration, access reviews)
8. Generates implementation artifacts (models, middleware, services, migrations, seeds, tests)

## Output
- Access control documentation at `docs/auth/<feature>-access-control.md`
- Implementation code in `src/auth/` (models, middleware, policy engine, audit logger)
- Database migrations for roles, permissions, grants, and audit tables
- Authorization tests in `tests/auth/authorization/`
- Commit: `"rbac: <feature> — <model> with <N> roles, <N> permissions"`
- Verdict: PRODUCTION READY / NEEDS WORK / INCOMPLETE

## Next Step
If incomplete: Address remaining items, then re-run `/godmode:rbac`.
If production ready: `/godmode:build` to implement, or `/godmode:secure` to audit.

## Examples

```
/godmode:rbac                          # Full access control design
/godmode:rbac --model rebac            # Google Zanzibar-style permissions
/godmode:rbac --hierarchy --matrix     # Role hierarchy + permission matrix
/godmode:rbac --audit                  # Design audit logging for access decisions
/godmode:rbac --review                 # Generate who-has-access-to-what report
```
