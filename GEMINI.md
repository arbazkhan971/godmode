# Godmode for Gemini CLI

@./skills/godmode/SKILL.md

## Verify Installation

After running the install script, confirm everything is set up correctly:

```bash
bash adapters/gemini/verify.sh
```

This checks that Gemini CLI can find the Godmode configuration, skill files, and agent definitions. If any check fails, the script reports what is missing and how to fix it.

## Tool Mapping

Gemini CLI tools map to Godmode skill references as follows:

| Skill Reference | Gemini Tool |
|---|---|
| Read | `read_file` |
| Write | `write_file` |
| Edit | `replace` |
| Bash | `run_shell_command` |
| Grep | `grep_search` |
| Glob | `glob` |
| TodoWrite | `write_todos` |
| Skill | `activate_skill` |

When a skill says "use Read to examine the file," use `read_file`. When it says "use Bash to run tests," use `run_shell_command`. Apply this mapping throughout.

## How to Use Skills

Godmode has **126 skills** and **7 subagents**. The orchestrator (`/godmode`) auto-detects which to invoke. Users can also invoke directly: `/godmode:skillname`.

**When a user invokes a skill** (e.g., `/godmode:secure`), read the full skill file before executing:
```
read_file("./skills/secure/SKILL.md")
```
Then follow that skill's workflow exactly.

**General pattern:**
```
read_file("./skills/<skill-name>/SKILL.md")
```

## Subagents (7 Built-in)

Godmode ships with 7 specialized agents. For complex tasks, use the planner to decompose, then dispatch builders in parallel.

| Agent | Role | Read agents/*.md for full instructions |
|---|---|---|
| **planner** | Decomposes goals → parallel tasks mapped to skills | `read_file("./agents/planner.md")` |
| **builder** | Implements a task following a skill workflow | `read_file("./agents/builder.md")` |
| **reviewer** | Reviews code for correctness + security | `read_file("./agents/reviewer.md")` |
| **optimizer** | Autonomous measure → modify → verify loop | `read_file("./agents/optimizer.md")` |
| **explorer** | Read-only codebase recon | `read_file("./agents/explorer.md")` |
| **security** | STRIDE + OWASP audit | `read_file("./agents/security.md")` |
| **tester** | TDD test generation | `read_file("./agents/tester.md")` |

Note: Gemini CLI does not support parallel subagent dispatch. Execute agent roles sequentially: plan → explore → build → review → optimize.

## Skill Catalog (126 skills)

| Skill | Description |
|---|---|
| a11y | Accessibility testing and auditing |
| agent | AI agent development |
| analytics | Analytics implementation |
| angular | Angular architecture |
| api | API design and specification |
| apidocs | OpenAPI/Swagger documentation generation |
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
| cron | Scheduled tasks and job queue management |
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
| experiment | A/B testing and statistical analysis |
| fastapi | FastAPI mastery |
| feature | Feature flags and gradual rollouts |
| finish | Branch finalization |
| fix | Autonomous error fixing |
| forms | Form architecture |
| ghactions | GitHub Actions workflow design and optimization |
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
| notify | Push, SMS, and in-app notifications |
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
| ratelimit | Rate limiting algorithms and middleware |
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
| seed | Database seeding and factory patterns |
| seo | SEO optimization and auditing |
| setup | Configuration wizard |
| ship | Shipping workflow |
| slo | SLO/SLI definition and error budget tracking |
| spring | Spring Boot mastery |
| state | State management design |
| storage | File storage and CDN |
| svelte | Svelte and SvelteKit mastery |
| tailwind | Tailwind CSS mastery |
| test | TDD enforcement |
| think | Brainstorming and design |
| type | Type system and schema validation |
| ui | UI component architecture |
| upload | File uploads and media processing |
| verify | Evidence gate |
| vue | Vue.js mastery |
| webperf | Web performance optimization |
| webhook | Webhook design, delivery, and retry logic |

## Command Definitions

Gemini CLI discovers `/godmode` as a slash command via the `commands/` directory:

- `commands/godmode.md` — top-level `/godmode` command (orchestrator)
- `commands/godmode/<skill>.md` — each sub-command (e.g., `/godmode:optimize`, `/godmode:secure`)

When a user types `/godmode:optimize`, Gemini CLI reads `commands/godmode/optimize.md` for usage info, then loads the full skill from `skills/optimize/SKILL.md` for execution.

## Core Behaviors

1. **Slash commands**: When the user types `/godmode`, read `./commands/godmode.md` for routing, then follow the orchestrator workflow. When they type `/godmode:<name>`, read `./commands/godmode/<name>.md` for usage, then read `./skills/<name>/SKILL.md` and follow it.
2. **Auto-detection**: If the user describes a task without a slash command, match it to the most relevant skill from the catalog, read its SKILL.md, and execute.
3. **Phase loop**: The ideal flow is THINK -> BUILD -> OPTIMIZE -> SHIP. After completing a skill, suggest the next logical step.
4. **Always investigate first**: Run `git status`, check for tests, read project files before recommending actions.
5. **One skill at a time**: Load and follow one skill's full workflow. Do not mix instructions from multiple skills simultaneously.

## Sequential Execution (Gemini CLI Limitation)

Gemini CLI does not support parallel agent dispatch or native worktrees. When a skill says "dispatch N agents in parallel" or "isolation: worktree":

1. **Parallel agents → sequential**: Execute each agent's task one at a time in the current session. Complete fully (implement, test, commit) before starting the next.
2. **Worktree isolation → branches**: Use `run_shell_command("git checkout -b godmode-{task}")` instead of EnterWorktree. Merge back with `run_shell_command("git checkout main && git merge godmode-{task}")`.
3. **Skills with `## Platform Fallback` sections**: `build`, `optimize`, `review`, and the `godmode` orchestrator include specific sequential execution instructions. Follow those when present.

For the full protocol, read: `read_file("./adapters/shared/sequential-dispatch.md")`
