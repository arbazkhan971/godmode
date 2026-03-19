# Quick Reference Card

> Every Godmode command on a single page. Grouped by use case.

---

## Orchestrator

```
/godmode                    Auto-detect phase, suggest next skill
/godmode --status           Show project status without acting
/godmode --loop             Continuous mode: execute, re-evaluate, repeat
/godmode --chain <name>     Run a named chain (e.g., full-stack, hotfix)
```

---

## Design and Planning

```
/godmode:think <topic>                 Brainstorm and design, produce a spec
/godmode:think --quick <topic>         Skip deep codebase research
/godmode:think --spec-only <desc>      Skip brainstorming, write spec directly
/godmode:think --predict               Run expert evaluation after design
/godmode:think --scenario              Run edge case exploration after design

/godmode:predict                       5 expert personas evaluate your design
/godmode:predict --panel ml            ML-specific expert panel
/godmode:predict --panel frontend      Frontend-specific expert panel
/godmode:predict --panel devops        DevOps-specific expert panel

/godmode:scenario                      Explore edge cases across 12 dimensions

/godmode:plan                          Decompose spec into tasks
/godmode:plan --from-spec <path>       Plan from a specific spec file
/godmode:plan --max-tasks 20           Override 15-task max
/godmode:plan --parallel               Mark parallelizable tasks
/godmode:plan --estimate               Add time estimates

/godmode:adr                           Create Architecture Decision Record
/godmode:rfc                           Write technical proposal / RFC
```

---

## Building and Coding

```
/godmode:build                         Execute all remaining tasks with TDD
/godmode:build --task 5                Execute only task 5
/godmode:build --phase 2               Execute only phase 2
/godmode:build --continue              Resume from last stopping point
/godmode:build --no-parallel           Disable parallel agents
/godmode:build --no-review             Skip code review gates
/godmode:build --dry-run               Show plan without changes

/godmode:scaffold                      Generate boilerplate from project patterns
/godmode:pair                          Pair programming with driver/navigator roles
```

---

## Testing

```
/godmode:test                          Write tests, enforce TDD discipline

/godmode:e2e                           End-to-end browser tests (Playwright/Cypress)

/godmode:visual                        Visual regression testing
/godmode:visual --changed-only         Test only affected components
/godmode:visual --component Button     Test specific component
/godmode:visual --update-baselines     Accept current as new baselines
/godmode:visual --ci                   CI-friendly output

/godmode:loadtest                      Load/stress/performance testing (k6/Artillery)

/godmode:contract                      Consumer-driven contract testing
/godmode:contract --consumer <name>    Generate contract for consumer
/godmode:contract --provider <name>    Verify contracts for provider
/godmode:contract --breaking           Breaking change detection only
/godmode:contract --mock               Start mock server from contracts
/godmode:contract --can-i-deploy       Check deployment safety
/godmode:contract --ci                 CI pipeline configuration
```

---

## Code Review and Quality

```
/godmode:review                        2-stage code review (automated + agent)

/godmode:quality                       Code quality analysis
                                       (complexity, duplication, tech debt)

/godmode:refactor                      Large-scale code refactoring
                                       (extract, inline, move, rename)
```

---

## Optimization and Performance

```
/godmode:optimize                               Interactive setup + autonomous loop
/godmode:optimize --goal "reduce latency"        Set goal directly
/godmode:optimize --verify "curl ..."            Set verify command
/godmode:optimize --target "< 200"               Set target value
/godmode:optimize --max 30                       Maximum iterations
/godmode:optimize --resume                       Resume paused optimization
/godmode:optimize --report                       Show results from last run
/godmode:optimize --dry-run                      Show plan without executing

/godmode:query                                   Database query optimization
                                                 (EXPLAIN plans, indexes, N+1)
```

---

## Debugging and Fixing

```
/godmode:debug                         Investigate current failures
/godmode:debug --error "TypeError..."  Investigate specific error
/godmode:debug --test "test name"      Investigate failing test
/godmode:debug --bisect                Jump to git bisect
/godmode:debug --trace                 Add trace logging, re-run
/godmode:debug --quick                 Quick hypothesis from error

/godmode:fix                           Fix all errors autonomously
/godmode:fix --tests-only              Fix failing tests only
/godmode:fix --lint-only               Fix lint errors only
/godmode:fix --types-only              Fix type errors only
/godmode:fix --file src/user.ts        Fix errors in specific file
/godmode:fix --max 20                  Maximum fix iterations
/godmode:fix --dry-run                 Show what would be fixed
/godmode:fix --from-debug              Use root cause from debug
```

---

## Security and Compliance

```
/godmode:secure                        Full STRIDE + OWASP security audit
/godmode:secure --quick                OWASP Top 10 only
/godmode:secure --stride               STRIDE analysis only
/godmode:secure --owasp                OWASP checklist only
/godmode:secure --red-team             Red team simulation only
/godmode:secure --deps                 Dependency vulnerability scan
/godmode:secure --fix                  Auto-fix findings after audit

/godmode:comply                        Regulatory compliance audit
                                       (GDPR, HIPAA, SOC2, PCI-DSS)

/godmode:secrets                       Secrets management
                                       (Vault, AWS/GCP/Azure, rotation, leaks)
```

---

## Accessibility and i18n

```
/godmode:a11y                          Full WCAG 2.1 AA accessibility audit
/godmode:a11y --aaa                    Audit against stricter AAA level
/godmode:a11y --component DatePicker   Audit specific component
/godmode:a11y --page /checkout         Audit specific page
/godmode:a11y --contrast-only          Color contrast analysis only
/godmode:a11y --keyboard-only          Keyboard navigation audit only
/godmode:a11y --screen-reader          Screen reader compatibility
/godmode:a11y --fix                    Auto-fix after audit
/godmode:a11y --ci                     CI-friendly output

/godmode:i18n                          Internationalization audit
                                       (strings, locales, RTL, formatting)
```

---

## API Design

```
/godmode:api                           Full API design workflow
/godmode:api --type rest               Design REST API (default)
/godmode:api --type graphql            Design GraphQL API
/godmode:api --type grpc               Design gRPC API
/godmode:api --validate                Validate existing API spec or routes
/godmode:api --spec                    Generate OpenAPI spec only
/godmode:api --versioning url          Force URL path versioning
/godmode:api --pagination cursor       Force cursor-based pagination
/godmode:api --diff v1 v2              Compare two API versions
/godmode:api --mock                    Generate mock server from spec
```

---

## Infrastructure and DevOps

```
/godmode:infra                         Infrastructure as Code
                                       (Terraform, CloudFormation, Pulumi, CDK)

/godmode:k8s                           Kubernetes management
                                       (Helm, deployments, scaling, troubleshooting)

/godmode:config                        Environment and config management
                                       (feature flags, A/B tests, env parity)

/godmode:cost                          Cloud cost optimization
                                       (right-sizing, waste detection, budgets)
```

---

## Monitoring and Incidents

```
/godmode:observe                       Monitoring, logging, tracing, SLOs
                                       (Prometheus, DataDog, OpenTelemetry)

/godmode:errortrack                    Error tracking and analysis
/godmode:errortrack --budget           Error budget status
/godmode:errortrack --trends           Trend analysis (30 days)
/godmode:errortrack --triage           Prioritized triage list
/godmode:errortrack --since 4h         Errors since duration
/godmode:errortrack --env staging      Target environment
/godmode:errortrack --export           Export as JSON

/godmode:incident                      Incident response
/godmode:incident --classify           Classify severity only
/godmode:incident --timeline           Build/update incident timeline
/godmode:incident --postmortem         Generate post-mortem
/godmode:incident --retro              Retrospective on past incident
/godmode:incident --actions            Track action items
/godmode:incident --metrics            Incident metrics dashboard
```

---

## Machine Learning

```
/godmode:ml                            ML experiment tracking and evaluation
                                       (datasets, hyperparameters, bias, models)

/godmode:mlops                         ML model deployment
                                       (serving, versioning, drift, retraining)

/godmode:pipeline                      Data pipeline and ETL
                                       (Airflow, dbt, Spark, Dagster, Kafka)
```

---

## Database

```
/godmode:query                         Query optimization and profiling
                                       (EXPLAIN, indexes, N+1, slow queries)

/godmode:migrate                       Database migration and schema management
                                       (Prisma, Django, Rails, Alembic, Flyway)
```

---

## Mobile

```
/godmode:mobile                        Mobile development
                                       (iOS, Android, React Native, Flutter)
```

---

## UI and Frontend

```
/godmode:ui                            UI component architecture
/godmode:ui --component DataTable      Audit specific component
/godmode:ui --tokens                   Design token audit
/godmode:ui --storybook                Storybook coverage audit
/godmode:ui --css-decision             CSS architecture recommendation
/godmode:ui --structure                Component directory structure
/godmode:ui --patterns                 Component API consistency
/godmode:ui --fix                      Auto-fix violations
/godmode:ui --init                     Initialize component library
/godmode:ui --generate Button          Generate new component
```

---

## Documentation and Knowledge

```
/godmode:docs                          Generate and maintain documentation
                                       (API docs, READMEs, runbooks)

/godmode:onboard                       Codebase onboarding
                                       (walkthroughs, dependencies, code tours)

/godmode:adr                           Architecture Decision Records

/godmode:rfc                           Technical proposals and RFCs
```

---

## Shipping and Deployment

```
/godmode:ship                          Full 8-phase shipping workflow
/godmode:ship --pr                     Create a pull request
/godmode:ship --deploy staging         Deploy to staging
/godmode:ship --deploy production      Deploy to production
/godmode:ship --release 1.2.0          Create a tagged release
/godmode:ship --skip-checklist         Skip pre-ship checklist
/godmode:ship --rollback               Roll back last deployment
/godmode:ship --status                 Show last shipment status

/godmode:deploy                        Advanced deployment strategies
                                       (blue-green, canary, progressive rollout)

/godmode:finish                        Branch finalization
                                       (merge, PR, keep, or discard)
```

---

## Configuration and Verification

```
/godmode:setup                         Configure Godmode for this project
                                       (goal, scope, metric, verify, guard rails)

/godmode:verify                        Evidence gate — prove claims mechanically
```

---

## Common Workflows (Named Chains)

| Chain | Skills | Use When |
|-------|--------|----------|
| `full-stack` | think > plan > build > test > review > optimize > ship | New feature, full quality |
| `hotfix` | debug > fix > verify > ship | Production bug, fast |
| `security-hardening` | secure > fix > verify > review > ship | Pre-launch security |
| `performance` | optimize > loadtest > verify > ship | Code is too slow |
| `new-api` | api > contract > build > test > docs > ship | New API endpoint |
| `incident` | incident > debug > fix > verify > deploy | Production down |
| `ml-pipeline` | ml > pipeline > mlops > observe > ship | ML model to production |

---

## The Godmode Loop

```
THINK  ───>  BUILD  ───>  OPTIMIZE  ───>  SHIP
  |                                          |
  +<─────────────── REPEAT ─────────────────+
```

Not sure where you are? Just run `/godmode` and the orchestrator will tell you.

---

## See Also

- [Master Skill Index](skill-index.md) — Full skill details and cross-references
- [Skill Chaining Reference](skill-chains.md) — Named chains and custom syntax
- [Decision Tree](decision-tree.md) — "What skill do I need?"
- [Domain Guide](domain-guide.md) — Backend, frontend, ML, DevOps workflows
