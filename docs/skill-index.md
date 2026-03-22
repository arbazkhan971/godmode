# Master Skill Index

> Complete reference for all Godmode skills. 48 implemented skills organized by phase, domain, and use case.

---

## Alphabetical Skill List

| # | Skill | Command | One-Line Description |
|---|-------|---------|---------------------|
| 1 | a11y | `/godmode:a11y` | Accessibility testing and WCAG 2.1 AA/AAA compliance auditing |
| 2 | adr | `/godmode:adr` | Architecture Decision Records — document, discover, maintain decisions |
| 3 | api | `/godmode:api` | API design — REST, GraphQL, gRPC specs with versioning and validation |
| 4 | build | `/godmode:build` | Execute implementation plan with TDD and parallel agents |
| 5 | comply | `/godmode:comply` | Regulatory compliance — GDPR, HIPAA, SOC2, PCI-DSS auditing |
| 6 | config | `/godmode:config` | Environment and configuration management with feature flags |
| 7 | contract | `/godmode:contract` | Consumer-driven contract testing with Pact framework |
| 8 | cost | `/godmode:cost` | Cloud cost optimization across AWS, GCP, and Azure |
| 9 | debug | `/godmode:debug` | Scientific bug investigation using 7 systematic techniques |
| 10 | deploy | `/godmode:deploy` | Advanced deployment — blue-green, canary, progressive rollout |
| 11 | docs | `/godmode:docs` | Documentation generation — API docs, READMEs, runbooks |
| 12 | e2e | `/godmode:e2e` | End-to-end browser testing with Playwright, Cypress, Selenium |
| 13 | errortrack | `/godmode:errortrack` | Error aggregation, analysis, and budget tracking |
| 14 | finish | `/godmode:finish` | Branch finalization — merge, PR, keep, or discard |
| 15 | fix | `/godmode:fix` | Autonomous error remediation loop until zero errors |
| 16 | godmode | `/godmode` | Orchestrator — auto-detects phase and routes to correct skill |
| 17 | i18n | `/godmode:i18n` | Internationalization — string extraction, locales, RTL support |
| 18 | incident | `/godmode:incident` | Incident response — SEV classification, timelines, post-mortems |
| 19 | infra | `/godmode:infra` | Infrastructure as Code — Terraform, CloudFormation, Pulumi, CDK |
| 20 | k8s | `/godmode:k8s` | Kubernetes — Helm charts, deployments, scaling, troubleshooting |
| 21 | loadtest | `/godmode:loadtest` | Load and performance testing — k6, Artillery, Locust, JMeter |
| 22 | migrate | `/godmode:migrate` | Database migration and schema management across ORMs |
| 23 | ml | `/godmode:ml` | ML experiment tracking, dataset validation, model evaluation |
| 24 | mlops | `/godmode:mlops` | ML model deployment — serving, versioning, drift detection |
| 25 | mobile | `/godmode:mobile` | Mobile development — iOS, Android, React Native, Flutter |
| 26 | observe | `/godmode:observe` | Monitoring and observability — metrics, logging, tracing, SLOs |
| 27 | onboard | `/godmode:onboard` | Codebase onboarding — architecture walkthroughs, code tours |
| 28 | optimize | `/godmode:optimize` | Autonomous improvement loop — the core of Godmode |
| 29 | pair | `/godmode:pair` | Pair programming with structured driver/navigator roles |
| 30 | pipeline | `/godmode:pipeline` | Data pipeline and ETL — Airflow, dbt, Spark, Dagster |
| 31 | plan | `/godmode:plan` | Decompose spec into 2-5 min tasks with file paths and tests |
| 32 | predict | `/godmode:predict` | Multi-persona expert consensus on a design or decision |
| 33 | quality | `/godmode:quality` | Code quality — duplication, complexity, tech debt, dependencies |
| 34 | query | `/godmode:query` | Query optimization — EXPLAIN plans, indexing, N+1 detection |
| 35 | refactor | `/godmode:refactor` | Large-scale refactoring with impact analysis and migration |
| 36 | review | `/godmode:review` | 2-stage code review — automated checks + agent-based review |
| 37 | rfc | `/godmode:rfc` | RFC and technical proposal writing with stakeholder workflow |
| 38 | scaffold | `/godmode:scaffold` | Code generation — boilerplate, CRUD, API endpoints, components |
| 39 | scenario | `/godmode:scenario` | Edge case exploration across 12 failure dimensions |
| 40 | secrets | `/godmode:secrets` | Secrets management — Vault, AWS/GCP/Azure secret stores |
| 41 | secure | `/godmode:secure` | Security audit — STRIDE + OWASP Top 10 + red-team personas |
| 42 | setup | `/godmode:setup` | Configuration wizard — goal, scope, metric, verify, guard rails |
| 43 | ship | `/godmode:ship` | 8-phase shipping workflow — PR, deploy, release, monitor |
| 44 | test | `/godmode:test` | TDD enforcement — RED-GREEN-REFACTOR discipline |
| 45 | think | `/godmode:think` | Brainstorm and design — produces a written specification |
| 46 | ui | `/godmode:ui` | UI component architecture, design systems, Storybook |
| 47 | verify | `/godmode:verify` | Evidence gate — prove claims with mechanical verification |
| 48 | visual | `/godmode:visual` | Visual regression testing — screenshots, pixel diffs, browsers |

---

## Skills by Phase

### Phase 1: THINK (Design and Discovery)

| Skill | Cmd | Purpose |
|--|--|--|
| think | `/godmode:think` | Brainstorm ideas, design features, produce specifications |
| predict | `/godmode:predict` | Get 5 expert persona evaluations of a design or decision |
| scenario | `/godmode:scenario` | Explore edge cases, failure modes across 12 dimensions |
| adr | `/godmode:adr` | Document architectural decisions with structured templates |
| rfc | `/godmode:rfc` | Write technical proposals requiring broader team input |

### Phase 2: BUILD (Plan and Implement)

| Skill | Cmd | Purpose |
|--|--|--|
| plan | `/godmode:plan` | Decompose spec into ordered, testable tasks |
| build | `/godmode:build` | Execute plan with TDD, parallel agents, code review |
| test | `/godmode:test` | Write tests, improve coverage, enforce TDD |
| review | `/godmode:review` | Automated + agent-based code review |
| scaffold | `/godmode:scaffold` | Generate boilerplate code from project patterns |
| pair | `/godmode:pair` | Collaborative coding with driver/navigator roles |

### Phase 3: OPTIMIZE (Autonomous Iteration)

| Skill | Cmd | Purpose |
|--|--|--|
| optimize | `/godmode:optimize` | Autonomous measure-modify-verify-keep/revert loop |
| debug | `/godmode:debug` | Scientific root cause investigation |
| fix | `/godmode:fix` | Autonomous error remediation until zero errors |
| secure | `/godmode:secure` | STRIDE + OWASP security audit with red-team |
| refactor | `/godmode:refactor` | Large-scale structural code transformation |
| quality | `/godmode:quality` | Code quality analysis — complexity, duplication, debt |
| query | `/godmode:query` | Database query optimization and profiling |

### Phase 4: SHIP (Deliver and Monitor)

| Skill | Cmd | Purpose |
|--|--|--|
| ship | `/godmode:ship` | 8-phase shipping: inventory, checklist, dry-run, deploy, verify |
| finish | `/godmode:finish` | Branch cleanup: merge, PR, keep, or discard |
| deploy | `/godmode:deploy` | Advanced deployment strategies (blue-green, canary) |

### META (Always Available)

| Skill | Cmd | Purpose |
|--|--|--|
| godmode | `/godmode` | Orchestrator — detects phase, suggests next skill |
| setup | `/godmode:setup` | Configure Godmode for your project |
| verify | `/godmode:verify` | Evidence-before-claims verification gate |

---

## Skills by Domain

### API and Backend

| Skill | Purpose |
|--|--|
| api | Design and validate REST/GraphQL/gRPC APIs |
| contract | Consumer-driven contract testing |
| query | Query optimization, EXPLAIN plans, indexing |
| migrate | Database schema migrations |
| secrets | API key and credential management |

### Frontend and UI

| Skill | Purpose |
|--|--|
| ui | Component architecture, design systems |
| visual | Visual regression testing |
| a11y | Accessibility compliance |
| i18n | Internationalization and localization |
| e2e | End-to-end browser testing |

### Infrastructure and DevOps

| Skill | Purpose |
|--|--|
| infra | Infrastructure as Code (Terraform, CDK) |
| k8s | Kubernetes and container orchestration |
| deploy | Blue-green, canary, progressive rollout |
| config | Environment configs, feature flags |
| cost | Cloud cost optimization |
| observe | Monitoring, logging, tracing, SLOs |

### Quality and Security

| Skill | Purpose |
|--|--|
| secure | STRIDE + OWASP security auditing |
| comply | Regulatory compliance (GDPR, HIPAA, SOC2) |
| quality | Code complexity, duplication, tech debt |
| errortrack | Error aggregation, budgets, trends |
| secrets | Secret rotation, leak detection |
| review | Automated + agent code review |

### Machine Learning

| Skill | Purpose |
|--|--|
| ml | Experiment tracking, dataset validation, model eval |
| mlops | Model serving, drift detection, retraining |
| pipeline | Data pipeline and ETL workflows |

### Mobile

| Skill | Purpose |
|--|--|
| mobile | iOS/Android/React Native/Flutter development |

### Documentation and Knowledge

| Skill | Purpose |
|--|--|
| docs | API docs, READMEs, runbooks, doc audits |
| adr | Architecture Decision Records |
| rfc | Technical proposals and RFCs |
| onboard | Codebase walkthroughs and code tours |

### Testing

| Skill | Purpose |
|--|--|
| test | Unit test writing with TDD enforcement |
| e2e | End-to-end browser testing |
| visual | Visual regression screenshots and diffs |
| loadtest | Load, stress, spike, and soak testing |
| contract | Consumer-driven contract testing |
| scenario | Edge case and failure mode exploration |

### Incident Management

| Skill | Purpose |
|--|--|
| incident | Severity classification, timelines, post-mortems |
| debug | Scientific root cause investigation |
| errortrack | Error aggregation and trend analysis |
| observe | Monitoring, alerting, SLO tracking |

---

## Cross-Reference: Skills That Work Together

Skills are designed to chain. This table shows which skills commonly feed into or follow each other.

| Skill | Feeds Into | Receives From |
|-------|-----------|---------------|
| think | plan, predict, scenario, adr, rfc | godmode (orchestrator) |
| predict | think (refine), plan | think |
| scenario | test, plan | think |
| adr | think (context), review | think, rfc |
| rfc | think (context), plan | think, adr |
| plan | build, scaffold | think, predict, scenario |
| build | optimize, review, secure, ship | plan |
| test | build, review | scenario, build |
| review | fix, ship | build, refactor, fix |
| scaffold | build | plan |
| pair | build, test, debug | any |
| optimize | ship, review | build, fix |
| debug | fix | incident, errortrack |
| fix | optimize, review, secure (re-audit) | debug, secure, review |
| secure | fix (if FAIL), ship (if PASS) | build |
| refactor | review, test | quality, review |
| quality | refactor, fix | build, review |
| query | optimize, fix | debug, observe |
| ship | finish, deploy | optimize, secure, review |
| finish | (terminal) | ship |
| deploy | observe, ship | ship, config |
| api | contract, plan | think |
| contract | build, ship (can-i-deploy) | api |
| infra | k8s, deploy, cost | plan, think |
| k8s | deploy, observe | infra |
| config | deploy, ship | setup |
| cost | infra (right-size) | observe |
| observe | incident, errortrack, cost | deploy, ship |
| incident | debug, fix | observe, errortrack |
| errortrack | debug, incident | observe |
| ml | mlops, pipeline | think, plan |
| mlops | observe, ship | ml |
| pipeline | ml, observe | plan |
| migrate | build, deploy | plan |
| docs | ship, onboard | build, api |
| onboard | (informational) | docs |
| mobile | ship, test | plan, build |
| ui | visual, a11y | plan, build |
| visual | fix, ship | ui, build |
| a11y | fix, ship | ui, build |
| i18n | build, test | think, plan |
| e2e | ship, review | build, scenario |
| loadtest | ship, optimize | build, deploy |
| comply | fix, ship | secure |
| secrets | secure, config | setup, secure |
| verify | (internal gate) | optimize, fix, ship, secure |
| setup | all skills | (first-time) |

---

## "I Want To..." Quick Reference

| I want to... | Use this skill | Command |
|--------------|---------------|---------|
| Design a new feature | think | `/godmode:think` |
| Get expert opinions on my design | predict | `/godmode:predict` |
| Explore edge cases and failure modes | scenario | `/godmode:scenario` |
| Document an architecture decision | adr | `/godmode:adr` |
| Write a technical proposal / RFC | rfc | `/godmode:rfc` |
| Break a feature into tasks | plan | `/godmode:plan` |
| Start implementing code | build | `/godmode:build` |
| Write or improve tests | test | `/godmode:test` |
| Review code before merging | review | `/godmode:review` |
| Generate boilerplate code | scaffold | `/godmode:scaffold` |
| Code with a pair partner | pair | `/godmode:pair` |
| Make code faster | optimize | `/godmode:optimize` |
| Find why something is broken | debug | `/godmode:debug` |
| Fix failing tests or lint errors | fix | `/godmode:fix` |
| Run a security audit | secure | `/godmode:secure` |
| Restructure code at scale | refactor | `/godmode:refactor` |
| Assess code quality and tech debt | quality | `/godmode:quality` |
| Optimize slow database queries | query | `/godmode:query` |
| Deploy to production | ship | `/godmode:ship` |
| Clean up a branch | finish | `/godmode:finish` |
| Do blue-green or canary deploy | deploy | `/godmode:deploy` |
| Design a REST/GraphQL/gRPC API | api | `/godmode:api` |
| Test API contracts between services | contract | `/godmode:contract` |
| Provision cloud infrastructure | infra | `/godmode:infra` |
| Manage Kubernetes deployments | k8s | `/godmode:k8s` |
| Manage environment configs | config | `/godmode:config` |
| Reduce cloud spending | cost | `/godmode:cost` |
| Add monitoring, logging, tracing | observe | `/godmode:observe` |
| Handle a production incident | incident | `/godmode:incident` |
| Analyze error patterns and trends | errortrack | `/godmode:errortrack` |
| Train or evaluate ML models | ml | `/godmode:ml` |
| Deploy ML models to production | mlops | `/godmode:mlops` |
| Build a data pipeline / ETL | pipeline | `/godmode:pipeline` |
| Create database migrations | migrate | `/godmode:migrate` |
| Generate documentation | docs | `/godmode:docs` |
| Onboard to a new codebase | onboard | `/godmode:onboard` |
| Build a mobile app | mobile | `/godmode:mobile` |
| Design UI components / design system | ui | `/godmode:ui` |
| Catch visual regressions | visual | `/godmode:visual` |
| Check accessibility compliance | a11y | `/godmode:a11y` |
| Add multi-language support | i18n | `/godmode:i18n` |
| Write end-to-end browser tests | e2e | `/godmode:e2e` |
| Run load/stress/performance tests | loadtest | `/godmode:loadtest` |
| Check GDPR/HIPAA/SOC2 compliance | comply | `/godmode:comply` |
| Manage secrets and credentials | secrets | `/godmode:secrets` |
| Verify a claim with evidence | verify | `/godmode:verify` |
| Configure Godmode for a project | setup | `/godmode:setup` |
| Auto-detect what to do next | godmode | `/godmode` |

---

## See Also

- [Skill Chaining Reference](skill-chains.md) — All valid skill chains with examples
- [Decision Tree](decision-tree.md) — Flowchart: "What skill do I need?"
- [Quick Reference Card](quick-reference.md) — All commands on one page
- [Architecture Overview](architecture.md) — System design and data flow
- [Chaining Guide](chaining.md) — How skills communicate through artifacts
- [Domain Guide](domain-guide.md) — Using Godmode across backend, frontend, ML, DevOps
