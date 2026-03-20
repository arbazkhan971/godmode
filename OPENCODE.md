# Godmode for OpenCode

@./skills/godmode/SKILL.md

## Tool Compatibility

OpenCode uses the same tool names as Claude Code — no mapping needed. Skills reference `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `TodoWrite`, and `Skill` directly, and OpenCode supports all of these natively.

## How to Use Skills

Godmode has **126 skills** and **7 subagents**. The orchestrator (`/godmode`) auto-detects which to invoke. Users can also invoke directly: `/godmode:skillname`.

**When a user invokes a skill** (e.g., `/godmode:secure`), read the full skill file before executing:
```
Read("./skills/secure/SKILL.md")
```
Then follow that skill's workflow exactly.

**General pattern:**
```
Read("./skills/<skill-name>/SKILL.md")
```

## Subagents (7 Built-in)

Godmode ships with 7 specialized agents. For complex tasks, use the planner to decompose, then dispatch builders sequentially.

| Agent | Role | Read agents/*.md for full instructions |
|---|---|---|
| **planner** | Decomposes goals → parallel tasks mapped to skills | `Read("./agents/planner.md")` |
| **builder** | Implements a task following a skill workflow | `Read("./agents/builder.md")` |
| **reviewer** | Reviews code for correctness + security | `Read("./agents/reviewer.md")` |
| **optimizer** | Autonomous measure → modify → verify loop | `Read("./agents/optimizer.md")` |
| **explorer** | Read-only codebase recon | `Read("./agents/explorer.md")` |
| **security** | STRIDE + OWASP audit | `Read("./agents/security.md")` |
| **tester** | TDD test generation | `Read("./agents/tester.md")` |

Note: OpenCode does not support parallel subagent dispatch. Execute agent roles sequentially: plan → explore → build → review → optimize.

## Skill Catalog (126 skills)

| Skill | Description |
|---|---|
| a11y | Accessibility testing and auditing |
| agent | AI agent development |
| analytics | Analytics implementation |
| angular | Angular architecture |
| api | API design and specification |
| architect | Software architecture |
| auth | Authentication and authorization |
| automate | Task automation |
| backup | Backup and disaster recovery |
| build | Build and execution |
| cache | Caching strategy |
| changelog | Changelog and release notes management |
| chaos | Chaos engineering |
| chart | Data visualization |
| cicd | CI/CD pipeline design |
| cli | CLI tool development |
| comply | Compliance and governance |
| concurrent | Concurrency and parallelism |
| config | Environment and configuration management |
| cost | Cloud cost optimization |
| crypto | Cryptography implementation |
| ddd | Domain-Driven Design |
| debug | Scientific debugging |
| deploy | Advanced deployment strategies |
| designsystem | Design system architecture |
| devsecops | DevSecOps pipeline |
| distributed | Distributed systems design |
| django | Django and FastAPI development |
| docker | Docker mastery |
| docs | Documentation generation and maintenance |
| e2e | End-to-end testing |
| edge | Edge computing and serverless |
| email | Email and notification systems |
| eval | AI/LLM evaluation |
| event | Event-driven architecture |
| fastapi | FastAPI mastery |
| finish | Branch finalization |
| fix | Autonomous error fixing |
| forms | Form architecture |
| git | Advanced Git workflows |
| godmode | Orchestrator (auto-detect phase and route) |
| graphql | GraphQL API development |
| grpc | gRPC and Protocol Buffers |
| i18n | Internationalization and localization |
| incident | Incident response and post-mortem |
| infra | Infrastructure as Code |
| integration | Integration testing |
| k8s | Kubernetes and container orchestration |
| laravel | Laravel mastery |
| legacy | Legacy code modernization |
| lint | Linting and code standards |
| loadtest | Load testing and performance testing |
| logging | Logging and structured logging |
| micro | Microservices design and management |
| migrate | Database migration and schema management |
| migration | System migration |
| ml | ML development and experimentation |
| mlops | MLOps and model deployment |
| mobile | Mobile app development |
| monorepo | Monorepo management |
| network | Network and DNS |
| nextjs | Next.js mastery |
| node | Node.js backend development |
| nosql | NoSQL database design |
| npm | Package management |
| observe | Monitoring and observability |
| onboard | Codebase onboarding |
| opensource | Open source project management |
| optimize | Core autonomous iteration loop |
| orm | ORM and data access optimization |
| pattern | Design pattern recommendation |
| pay | Payment and billing integration |
| pentest | Penetration testing |
| perf | Performance profiling and optimization |
| pipeline | Data pipeline and ETL |
| plan | Planning and task decomposition |
| postgres | PostgreSQL mastery |
| pr | Pull request excellence |
| predict | Multi-persona prediction and evaluation |
| prompt | Prompt engineering |
| query | Query optimization and data analysis |
| queue | Message queue and job processing |
| rag | RAG (Retrieval-Augmented Generation) |
| rails | Ruby on Rails mastery |
| rbac | Permission and access control |
| react | React architecture |
| realtime | Real-time communication |
| redis | Redis architecture and design |
| refactor | Large-scale refactoring |
| reliability | Site reliability engineering |
| resilience | System resilience |
| responsive | Responsive and adaptive design |
| review | Code review |
| rfc | RFC and technical proposal writing |
| scale | Scalability engineering |
| scenario | Edge case and scenario exploration |
| schema | Data modeling and schema design |
| search | Search implementation |
| secrets | Secrets management |
| secure | Security audit |
| seo | SEO optimization and auditing |
| setup | Configuration wizard |
| ship | Shipping workflow |
| spring | Spring Boot mastery |
| state | State management design |
| storage | File storage and CDN |
| svelte | Svelte and SvelteKit mastery |
| tailwind | Tailwind CSS mastery |
| test | TDD enforcement |
| think | Brainstorming and design |
| type | Type system and schema validation |
| ui | UI component architecture |
| verify | Evidence gate |
| vue | Vue.js mastery |
| webperf | Web performance optimization |
| apidocs | OpenAPI/Swagger documentation generation |
| cron | Scheduled tasks and job queue management |
| experiment | A/B testing and statistical analysis |
| feature | Feature flags and gradual rollouts |
| ghactions | GitHub Actions workflow design and optimization |
| notify | Push, SMS, and in-app notifications |
| ratelimit | Rate limiting algorithms and middleware |
| seed | Database seeding and factory patterns |
| slo | SLO/SLI definition and error budget tracking |
| upload | File uploads and media processing |
| webhook | Webhook design, delivery, and retry logic |

## Core Behaviors

1. **Slash commands**: When the user types `/godmode`, follow the orchestrator workflow above. When they type `/godmode:<name>`, read `./skills/<name>/SKILL.md` and follow it.
2. **Auto-detection**: If the user describes a task without a slash command, match it to the most relevant skill from the catalog, read its SKILL.md, and execute.
3. **Phase loop**: The ideal flow is THINK -> BUILD -> OPTIMIZE -> SHIP. After completing a skill, suggest the next logical step.
4. **Always investigate first**: Run `git status`, check for tests, read project files before recommending actions.
5. **One skill at a time**: Load and follow one skill's full workflow. Do not mix instructions from multiple skills simultaneously.

## Sequential Execution (OpenCode Limitation)

OpenCode does not support parallel agent dispatch or native worktrees. When a skill says "dispatch N agents in parallel" or "isolation: worktree":

1. **Parallel agents → sequential**: Execute each agent's task one at a time in the current session. Complete fully (implement, test, commit) before starting the next.
2. **Worktree isolation → branches**: Use `Bash("git checkout -b godmode-{task}")` instead of EnterWorktree. Merge back with `Bash("git checkout main && git merge godmode-{task}")`.
3. **Skills with `## Platform Fallback` sections**: `build`, `optimize`, `review`, and the `godmode` orchestrator include specific sequential execution instructions. Follow those when present.

For the full protocol, read: `Read("./adapters/shared/sequential-dispatch.md")`
