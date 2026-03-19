# Godmode for Gemini CLI

@./skills/godmode/SKILL.md

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

Godmode has **171 skills** and **7 subagents**. The orchestrator (`/godmode`) auto-detects which to invoke. Users can also invoke directly: `/godmode:skillname`.

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

## Skill Catalog (171 skills)

| Skill | Description |
|---|---|
| a11y | Accessibility testing and auditing |
| adr | Architecture Decision Records |
| agent | AI agent development |
| aiops | AI Operations and safety |
| analytics | Analytics implementation |
| angular | Angular architecture |
| animation | Animation and motion design |
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
| contract | Contract testing |
| cost | Cloud cost optimization |
| crypto | Cryptography implementation |
| ddd | Domain-Driven Design |
| debug | Scientific debugging |
| deploy | Advanced deployment strategies |
| designsystem | Design system architecture |
| desktop | Desktop application development |
| devsecops | DevSecOps pipeline |
| distributed | Distributed systems design |
| django | Django and FastAPI development |
| docker | Docker mastery |
| docs | Documentation generation and maintenance |
| dx | Developer experience optimization |
| e2e | End-to-end testing |
| edge | Edge computing and serverless |
| email | Email and notification systems |
| embeddings | Embeddings and semantic search |
| errorhandling | Error handling architecture |
| errortrack | Error tracking and analysis |
| estimate | Effort estimation |
| eval | AI/LLM evaluation |
| event | Event-driven architecture |
| extension | Browser extension development |
| fastapi | FastAPI mastery |
| finetune | Model fine-tuning |
| finish | Branch finalization |
| fix | Autonomous error fixing |
| forms | Form architecture |
| gamedev | Game development |
| gdpr | GDPR deep compliance |
| git | Advanced Git workflows |
| godmode | Orchestrator (auto-detect phase and route) |
| graphql | GraphQL API development |
| grpc | gRPC and Protocol Buffers |
| hipaa | HIPAA deep compliance |
| i18n | Internationalization and localization |
| incident | Incident response and post-mortem |
| infra | Infrastructure as Code |
| integration | Integration testing |
| iot | IoT and embedded systems |
| k8s | Kubernetes and container orchestration |
| laravel | Laravel mastery |
| learn | Learning and teaching |
| legacy | Legacy code modernization |
| license | License management |
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
| multimodal | Multimodal AI |
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
| pair | Pair programming assistance |
| pattern | Design pattern recommendation |
| pay | Payment and billing integration |
| pentest | Penetration testing |
| perf | Performance profiling and optimization |
| pipeline | Data pipeline and ETL |
| plan | Planning and task decomposition |
| postgres | PostgreSQL mastery |
| pr | Pull request excellence |
| predict | Multi-persona prediction and evaluation |
| prioritize | Task prioritization |
| prompt | Prompt engineering |
| pwa | Progressive Web App |
| quality | Code quality and analysis |
| query | Query optimization and data analysis |
| queue | Message queue and job processing |
| rag | RAG (Retrieval-Augmented Generation) |
| rails | Ruby on Rails mastery |
| rbac | Permission and access control |
| react | React architecture |
| realtime | Real-time communication |
| redis | Redis architecture and design |
| refactor | Large-scale refactoring |
| release | Release management |
| reliability | Site reliability engineering |
| report | Report generation |
| resilience | System resilience |
| responsive | Responsive and adaptive design |
| retro | Retrospective and team health |
| review | Code review |
| rfc | RFC and technical proposal writing |
| scaffold | Code generation and scaffolding |
| scale | Scalability engineering |
| scenario | Edge case and scenario exploration |
| schema | Data modeling and schema design |
| scope | Scope management and MVP definition |
| search | Search implementation |
| secrets | Secrets management |
| secure | Security audit |
| seo | SEO optimization and auditing |
| setup | Configuration wizard |
| ship | Shipping workflow |
| snapshot | Snapshot and approval testing |
| soc2 | SOC 2 deep compliance |
| spring | Spring Boot mastery |
| standup | Daily standup and progress tracking |
| state | State management design |
| storage | File storage and CDN |
| svelte | Svelte and SvelteKit mastery |
| tailwind | Tailwind CSS mastery |
| terminal | Terminal and shell productivity |
| test | TDD enforcement |
| think | Brainstorming and design |
| three | 3D web development |
| type | Type system and schema validation |
| ui | UI component architecture |
| unittest | Unit testing mastery |
| verify | Evidence gate |
| visual | Visual regression testing |
| vscode | IDE and editor configuration |
| vue | Vue.js mastery |
| wasm | WebAssembly development |
| web3 | Blockchain and Web3 development |
| webperf | Web performance optimization |
| apidocs | OpenAPI/Swagger documentation generation |
| cron | Scheduled tasks and job queue management |
| dependencies | Dependency management and supply chain security |
| experiment | A/B testing and statistical analysis |
| feature | Feature flags and gradual rollouts |
| ghactions | GitHub Actions workflow design and optimization |
| notify | Push, SMS, and in-app notifications |
| pm | Product management — PRDs, user stories, prioritization |
| ratelimit | Rate limiting algorithms and middleware |
| research | User research — personas, journey mapping, JTBD |
| seed | Database seeding and factory patterns |
| slo | SLO/SLI definition and error budget tracking |
| strategy | Product strategy — roadmaps, growth models |
| upload | File uploads and media processing |
| uxdesign | UI/UX design — personas, heuristics, user flows |
| webhook | Webhook design, delivery, and retry logic |
| wireframe | Wireframing, prototyping, component layout |

## Core Behaviors

1. **Slash commands**: When the user types `/godmode`, follow the orchestrator workflow above. When they type `/godmode:<name>`, read `./skills/<name>/SKILL.md` and follow it.
2. **Auto-detection**: If the user describes a task without a slash command, match it to the most relevant skill from the catalog, read its SKILL.md, and execute.
3. **Phase loop**: The ideal flow is THINK -> BUILD -> OPTIMIZE -> SHIP. After completing a skill, suggest the next logical step.
4. **Always investigate first**: Run `git status`, check for tests, read project files before recommending actions.
5. **One skill at a time**: Load and follow one skill's full workflow. Do not mix instructions from multiple skills simultaneously.
