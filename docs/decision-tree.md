# Decision Tree: "What Skill Do I Need?"

> Start at the top. Follow the branches. Find your skill.

---

## Master Decision Tree

```
                        What are you trying to do?
                                  |
            +-----------+---------+---------+-----------+
            |           |         |         |           |
        CREATE      IMPROVE    FIX/DEBUG   SHIP      LEARN
        something   something  something   something  something
            |           |         |         |           |
            v           v         v         v           v
       [THINK/BUILD] [OPTIMIZE] [REPAIR]  [DELIVER]  [DISCOVER]
```

---

## Branch 1: CREATE Something New

```
I want to CREATE something new
    |
    +-- Do you know WHAT to build?
    |       |
    |       +-- NO --> /godmode:think
    |       |           "Brainstorm and design first"
    |       |
    |       +-- YES, but need expert review --> /godmode:predict
    |       |           "Get 5 expert opinions"
    |       |
    |       +-- YES, but need edge case analysis --> /godmode:scenario
    |       |           "Explore 12 failure dimensions"
    |       |
    |       +-- YES, need to document the decision --> /godmode:adr
    |       |           "Create Architecture Decision Record"
    |       |
    |       +-- YES, need team buy-in --> /godmode:rfc
    |       |           "Write a technical proposal"
    |       |
    |       +-- YES --> Do you have a PLAN?
    |               |
    |               +-- NO --> /godmode:plan
    |               |           "Decompose into 2-5 min tasks"
    |               |
    |               +-- YES --> What are you building?
    |                       |
    |                       +-- Code (general) --> /godmode:build
    |                       |
    |                       +-- An API --> /godmode:api
    |                       |       then --> /godmode:contract (if microservices)
    |                       |
    |                       +-- Boilerplate / scaffolding --> /godmode:scaffold
    |                       |
    |                       +-- UI components --> /godmode:ui
    |                       |
    |                       +-- Mobile app --> /godmode:mobile
    |                       |
    |                       +-- Infrastructure --> /godmode:infra
    |                       |       then --> /godmode:k8s (if Kubernetes)
    |                       |
    |                       +-- Database migrations --> /godmode:migrate
    |                       |
    |                       +-- Data pipeline --> /godmode:pipeline
    |                       |
    |                       +-- ML model --> /godmode:ml
    |                       |
    |                       +-- Documentation --> /godmode:docs
    |                       |
    |                       +-- Tests --> /godmode:test
    |                       |       +-- E2E browser tests --> /godmode:e2e
    |                       |       +-- Load tests --> /godmode:loadtest
    |                       |       +-- Visual tests --> /godmode:visual
    |                       |
    |                       +-- Not sure --> /godmode
    |                               "Let the orchestrator decide"
```

---

## Branch 2: IMPROVE Existing Code

```
I want to IMPROVE existing code
    |
    +-- What kind of improvement?
        |
        +-- PERFORMANCE (make it faster)
        |       |
        |       +-- General code performance --> /godmode:optimize
        |       |
        |       +-- Database queries --> /godmode:query
        |       |
        |       +-- Need load testing --> /godmode:loadtest
        |       |
        |       +-- Cloud costs too high --> /godmode:cost
        |
        +-- CODE QUALITY
        |       |
        |       +-- Tech debt / complexity --> /godmode:quality
        |       |
        |       +-- Restructure code --> /godmode:refactor
        |       |
        |       +-- Code review --> /godmode:review
        |
        +-- SECURITY
        |       |
        |       +-- Security audit --> /godmode:secure
        |       |
        |       +-- Manage secrets --> /godmode:secrets
        |       |
        |       +-- Compliance check --> /godmode:comply
        |       |
        |       +-- Auth / RBAC review --> /godmode:secure --quick
        |
        +-- TESTING
        |       |
        |       +-- More unit tests --> /godmode:test
        |       |
        |       +-- E2E tests --> /godmode:e2e
        |       |
        |       +-- Visual regression --> /godmode:visual
        |       |
        |       +-- Load testing --> /godmode:loadtest
        |       |
        |       +-- Accessibility --> /godmode:a11y
        |       |
        |       +-- API contracts --> /godmode:contract
        |
        +-- OBSERVABILITY
        |       |
        |       +-- Add monitoring/logging --> /godmode:observe
        |       |
        |       +-- Analyze errors --> /godmode:errortrack
        |       |
        |       +-- Define SLOs --> /godmode:observe
        |
        +-- INTERNATIONALIZATION
        |       |
        |       +-- Add language support --> /godmode:i18n
        |
        +-- ACCESSIBILITY
        |       |
        |       +-- WCAG compliance --> /godmode:a11y
        |
        +-- DOCUMENTATION
                |
                +-- Generate/update docs --> /godmode:docs
                |
                +-- Create onboarding guide --> /godmode:onboard
```

---

## Branch 3: FIX or DEBUG Something

```
I want to FIX or DEBUG something
    |
    +-- What is broken?
        |
        +-- I DON'T KNOW (unexpected behavior)
        |       |
        |       +-- /godmode:debug
        |           "Scientific investigation with 7 techniques"
        |           then --> /godmode:fix (after root cause found)
        |
        +-- TESTS are failing
        |       |
        |       +-- Know the cause --> /godmode:fix --tests-only
        |       |
        |       +-- Don't know why --> /godmode:debug --test "test name"
        |
        +-- LINT / TYPE errors
        |       |
        |       +-- /godmode:fix --lint-only   (lint errors)
        |       +-- /godmode:fix --types-only  (type errors)
        |
        +-- PRODUCTION is down
        |       |
        |       +-- /godmode:incident
        |           "Classify severity, build timeline"
        |           then --> /godmode:debug
        |           then --> /godmode:fix
        |           then --> /godmode:deploy (with rollback plan)
        |
        +-- ERRORS spiking in monitoring
        |       |
        |       +-- /godmode:errortrack
        |           "Aggregate, categorize, prioritize"
        |           then --> /godmode:debug (for top errors)
        |
        +-- SECURITY vulnerability found
        |       |
        |       +-- /godmode:secure (for full audit)
        |       +-- /godmode:fix (for known vulnerability)
        |       +-- /godmode:secrets (for exposed credentials)
        |
        +-- DATABASE issues
        |       |
        |       +-- Slow queries --> /godmode:query
        |       +-- Schema needs change --> /godmode:migrate
        |
        +-- DEPLOYMENT failed
                |
                +-- /godmode:deploy --strategy canary
                    (or rollback with /godmode:ship --rollback)
```

---

## Branch 4: SHIP or DEPLOY Something

```
I want to SHIP or DEPLOY something
    |
    +-- What stage are you at?
        |
        +-- Code is READY, need to merge/deploy
        |       |
        |       +-- Create a PR --> /godmode:ship --pr
        |       |
        |       +-- Deploy to staging --> /godmode:ship --deploy staging
        |       |
        |       +-- Deploy to production --> /godmode:ship --deploy production
        |       |
        |       +-- Create a release --> /godmode:ship --release <version>
        |       |
        |       +-- Clean up branch --> /godmode:finish
        |
        +-- Need ADVANCED deployment
        |       |
        |       +-- Blue-green deploy --> /godmode:deploy
        |       |
        |       +-- Canary release --> /godmode:deploy --strategy canary
        |       |
        |       +-- Progressive rollout --> /godmode:deploy
        |       |
        |       +-- Need rollback plan --> /godmode:deploy
        |
        +-- Need PRE-SHIP checks
        |       |
        |       +-- Security audit --> /godmode:secure
        |       |
        |       +-- Performance validation --> /godmode:loadtest
        |       |
        |       +-- Contract compatibility --> /godmode:contract --can-i-deploy
        |       |
        |       +-- Accessibility check --> /godmode:a11y
        |       |
        |       +-- Visual regression --> /godmode:visual
        |       |
        |       +-- Compliance check --> /godmode:comply
        |
        +-- Need INFRASTRUCTURE first
        |       |
        |       +-- Provision cloud resources --> /godmode:infra
        |       |
        |       +-- Set up Kubernetes --> /godmode:k8s
        |       |
        |       +-- Configure environments --> /godmode:config
        |       |
        |       +-- Manage secrets --> /godmode:secrets
        |
        +-- Deploying ML MODEL
                |
                +-- /godmode:mlops
                    "Model serving, drift detection, retraining"
```

---

## Branch 5: LEARN or UNDERSTAND Something

```
I want to LEARN or UNDERSTAND something
    |
    +-- What do you want to understand?
        |
        +-- A new CODEBASE --> /godmode:onboard
        |       "Architecture walkthrough, code tours"
        |
        +-- Why a DECISION was made --> /godmode:adr
        |       "Find or create Architecture Decision Records"
        |
        +-- How the API WORKS --> /godmode:docs
        |       "Generate API documentation"
        |
        +-- What could go WRONG --> /godmode:scenario
        |       "12-dimension edge case exploration"
        |
        +-- Whether a design is GOOD --> /godmode:predict
        |       "5 expert persona evaluations"
        |
        +-- How to implement SOMETHING --> /godmode:pair
        |       "Collaborative coding with guidance"
        |
        +-- What GODMODE can do --> /godmode
                "Orchestrator recommends next action"
```

---

## Quick Decision Matrix

For the impatient — find your situation, get your skill:

| Your Situation | Skill | Command |
|---------------|-------|---------|
| "I have an idea but no spec" | think | `/godmode:think` |
| "I have a spec but no plan" | plan | `/godmode:plan` |
| "I have a plan but no code" | build | `/godmode:build` |
| "Code works but it's slow" | optimize | `/godmode:optimize` |
| "Code works but queries are slow" | query | `/godmode:query` |
| "Something is broken" | debug | `/godmode:debug` |
| "Tests are failing" | fix | `/godmode:fix` |
| "Production is down" | incident | `/godmode:incident` |
| "Need to deploy safely" | deploy | `/godmode:deploy` |
| "Ready to merge/release" | ship | `/godmode:ship` |
| "Need a security review" | secure | `/godmode:secure` |
| "New to this codebase" | onboard | `/godmode:onboard` |
| "No idea what to do next" | godmode | `/godmode` |

---

## See Also

- [Master Skill Index](skill-index.md) — Complete list of all 48 skills
- [Skill Chaining Reference](skill-chains.md) — Named workflows and chain syntax
- [Quick Reference Card](quick-reference.md) — All commands on one page
