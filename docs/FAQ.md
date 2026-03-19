# Frequently Asked Questions

> Everything you need to know about Godmode, answered.

---

## General

### 1. What is Godmode?

Godmode is a skill plugin for Claude Code that provides a complete, disciplined development workflow -- from initial idea to optimized, shipped product. It bundles 97 implemented skills (with 54 more planned) that cover every phase of software development: design, planning, building, testing, optimization, security, and deployment.

Instead of generating code and hoping for the best, Godmode enforces structure: design before code, tests before implementation, evidence before claims, and git commits at every step.

### 2. How is Godmode different from Copilot, Cursor, or other AI coding tools?

Most AI coding tools focus on **code generation** -- they autocomplete lines or generate functions. Godmode focuses on **workflow orchestration** -- it manages the entire development lifecycle.

Key differences:
- **Full lifecycle:** Godmode covers ideation through production deployment, not just code completion
- **Autonomous optimization:** The `/godmode:optimize` loop measures, experiments, and proves improvements with data
- **Mechanical verification:** Every claim is backed by running a real command and reading the output -- never "it should work"
- **TDD enforcement:** Tests are written before implementation. Always
- **Git-as-memory:** Every experiment is committed, every bad change is auto-reverted, every decision is traceable
- **97 specialized skills:** Dedicated workflows for security audits, load testing, database migrations, infrastructure-as-code, and dozens more

Copilot helps you write code. Godmode helps you build software.

### 3. Is Godmode free?

Godmode is open-source under the MIT License. The plugin itself is free. You need a Claude Code subscription or API access to use it, as Godmode runs inside Claude Code.

### 4. What platforms does Godmode support?

Godmode works anywhere Claude Code runs:
- **Claude Code** (full support)
- **Cursor** (compatible)
- **Codex** (compatible)
- **OpenCode** (compatible)
- **Gemini CLI** (compatible)

---

## Skills and Usage

### 5. Can I use just some skills?

Yes. Every skill is independent. You can invoke any individual skill without using the full workflow:

```bash
/godmode:secure       # Just run a security audit
/godmode:optimize     # Just run the optimization loop
/godmode:test         # Just write tests
```

You do not need to run `think -> plan -> build` in order. However, skills are designed to chain -- the output of one becomes the input of the next. The full chain produces the best results.

### 6. How do I know which skill to use?

Three options:
1. **Let Godmode decide:** Run `/godmode` with a description of what you want. The orchestrator auto-detects the appropriate phase and skill.
2. **Use the phase model:** Are you designing (THINK), building (BUILD), improving (OPTIMIZE), or deploying (SHIP)?
3. **Search the skill list:** See [COMPLETE-SKILL-LIST.md](COMPLETE-SKILL-LIST.md) for every skill organized by category.

### 7. Does Godmode work with my language or framework?

Godmode is language-agnostic. It auto-detects your project's language, framework, test runner, and linter during setup. Supported languages include:

- JavaScript / TypeScript (Node.js, React, Next.js, Vue, Angular, Svelte)
- Python (Django, FastAPI, Flask)
- Rust
- Go
- Ruby (Rails)
- Java (Spring)
- C# (.NET)
- PHP (Laravel)
- Swift / Kotlin (mobile)
- Solidity (Web3)

If your language has a test command and a way to measure results, Godmode works with it.

### 8. How do I create custom skills?

1. Create a directory: `skills/your-skill/`
2. Create `skills/your-skill/SKILL.md` following the required structure:
   - YAML frontmatter with `name` and `description`
   - Sections: When to Activate, Workflow, Key Behaviors, Example Usage, Anti-Patterns
3. Optionally create a command file at `commands/godmode/your-skill.md`
4. Submit a PR

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full guide with templates and quality standards.

### 9. What are "planned" skills?

The 54 planned skills are directories that have been reserved for future implementation. They exist as empty directories under `skills/`. They represent skills the community has identified as valuable but that nobody has written the `SKILL.md` for yet. Contributing a planned skill is one of the best ways to help the project.

### 10. Can I override or customize a skill's behavior?

Yes. Skills read from `.godmode/config.yaml` for project-specific settings. You can:
- Set custom test commands
- Define optimization targets and guard rails
- Configure iteration limits
- Set language-specific preferences

Run `/godmode:setup` to generate or update your configuration.

---

## The Autonomous Loop

### 11. How does the autonomous optimization loop work?

The `/godmode:optimize` skill runs a disciplined iteration cycle:

1. **Measure baseline** -- Run the verify command, record the starting metric
2. **Hypothesize** -- Identify one specific change that should improve the metric
3. **Modify** -- Make exactly one change
4. **Verify** -- Run the same verify command, record the new metric
5. **Decide** -- If the metric improved, commit and keep. If it regressed, revert
6. **Repeat** -- Continue until the target is met, the iteration limit is reached, or no more improvements are found

Every iteration produces a git commit. Every revert is also committed. The full history is logged to `.godmode/optimize-results.tsv`.

### 12. Is it safe to run Godmode unattended?

Godmode is designed for supervised autonomy. Safety mechanisms include:

- **Guard rails:** You define a metric that must never regress (e.g., "all tests must pass"). If the guard rail is violated, the change is reverted immediately
- **Iteration limits:** The loop has a configurable maximum (default: 20 iterations)
- **Git-as-memory:** Every change is committed before verification. If anything goes wrong, you can always revert to any previous state
- **No destructive operations:** Godmode does not delete branches, force-push, or modify history without explicit instructions
- **Dry-run support:** The `/godmode:ship` workflow includes a dry-run phase before any real deployment

That said, you should review the results before deploying to production. Godmode optimizes code -- it does not make business decisions.

### 13. What happens if the optimization loop makes things worse?

It reverts. Every change is committed before verification. If the metric regresses, the change is automatically reverted with a git commit that explains what was tried and why it was rolled back. Your codebase is never left in a worse state than where it started.

### 14. How does Godmode measure "improvement"?

You define the metric. Examples:
- Response time: `curl -w '%{time_total}' http://localhost:3000/api/products`
- Test execution time: `time npm test`
- Bundle size: `du -sh dist/`
- Lighthouse score: `lighthouse --output=json`
- Custom script: `./scripts/benchmark.sh`

The metric must be a number that Godmode can extract from command output. It compares each iteration's result to the baseline and decides whether to keep or revert.

---

## Development Workflow

### 15. What is the THINK-BUILD-OPTIMIZE-SHIP loop?

It is Godmode's core philosophy, organizing all work into four phases:

- **THINK** -- Design before you code. Brainstorm approaches, get expert predictions, explore edge cases, write a spec
- **BUILD** -- Plan, then execute with TDD. Break the spec into atomic tasks, write failing tests first, implement, review
- **OPTIMIZE** -- Improve with evidence. Measure, hypothesize, modify one thing, verify, keep or revert. Repeat
- **SHIP** -- Deploy with confidence. Pre-flight checklist, dry run, deploy, smoke test, monitor, rollback plan ready

You can enter at any phase. If your code already works but is slow, go straight to OPTIMIZE. If you need to deploy, go to SHIP. The orchestrator (`/godmode`) auto-detects where you are based on your git history and project state.

### 16. How does TDD enforcement work?

The `/godmode:build` and `/godmode:test` skills enforce the RED-GREEN-REFACTOR cycle:

1. **RED** -- Write a failing test that defines the expected behavior
2. **GREEN** -- Write the minimum code to make the test pass
3. **REFACTOR** -- Clean up without changing behavior

Each step is committed separately. If a developer tries to write implementation code before a failing test, the skill redirects them. This is enforced by workflow, not by tooling -- Godmode instructs the AI to follow TDD discipline at every step.

### 17. What is "Git-as-memory"?

Every experiment, iteration, and decision is recorded as a git commit. This means:
- You can bisect to find when a regression was introduced
- You can revert any individual optimization attempt
- The full history of what was tried, what worked, and what failed is preserved
- Results logs (`.godmode/optimize-results.tsv`, `.godmode/fix-log.tsv`) provide structured records

Git is not just version control in Godmode -- it is the system's memory.

### 18. How does skill chaining work?

Skills produce artifacts that downstream skills consume:

```
think (spec) -> plan (task list) -> build (code + tests) -> optimize (metrics) -> ship (deployment)
```

Each skill reads the artifacts from the previous skill. For example:
- `think` produces `docs/specs/<name>.md`
- `plan` reads the spec and produces `docs/plans/<name>-plan.md`
- `build` reads the plan and executes each task

Common chains:
- **Full feature:** `think -> predict -> scenario -> plan -> build -> optimize -> secure -> ship -> finish`
- **Quick feature:** `think -> plan -> build -> ship`
- **Bug fix:** `debug -> fix -> review -> ship`
- **Performance:** `optimize -> review -> ship`

See [Skill Chaining Guide](chaining.md) for all patterns.

---

## Security

### 19. How does the security audit work?

The `/godmode:secure` skill performs a structured audit:

1. **Scope definition** -- Identify authentication, authorization, user input, data storage, external API, and secrets handling code
2. **STRIDE analysis** -- Evaluate each area for Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, and Elevation of Privilege
3. **OWASP Top 10 check** -- Verify against current OWASP Top 10 vulnerabilities
4. **Red-team personas** -- Four simulated attackers (script kiddie, insider threat, organized crime, nation-state) attempt to find exploits
5. **Report** -- Every finding has code evidence, severity rating (Critical/High/Medium/Low), and remediation steps

### 20. Does Godmode access my secrets or credentials?

No. Godmode is a set of Markdown skill files that instruct the AI agent. It does not have its own runtime, network access, or data collection. It runs entirely within Claude Code's existing sandbox. If your project has `.env` files or credentials, Godmode's skills explicitly instruct the agent not to commit those files.

---

## Contributing

### 21. How do I contribute a new skill?

1. Fork the repository
2. Create `skills/your-skill/SKILL.md` following the template in [CONTRIBUTING.md](../CONTRIBUTING.md)
3. Add a command file if needed at `commands/godmode/your-skill.md`
4. Update `README.md` skill tables
5. Submit a PR with a summary, rationale, and usage example

Every skill must have: clear trigger conditions, a numbered workflow, at least 2 examples with realistic input/output, at least 3 anti-patterns, and references to related skills.

### 22. Can I contribute to a planned skill?

Absolutely. The 54 planned skill directories are specifically waiting for contributors. Pick any empty directory from the [planned skills list](COMPLETE-SKILL-LIST.md#planned-skills-54-directories-reserved), create a `SKILL.md`, and submit a PR. These are some of the highest-value contributions you can make.

### 23. How do I test a skill before submitting?

Skills are Markdown files -- there is no compilation step. To test:
1. Read your `SKILL.md` as if you were Claude Code executing it
2. Verify that every workflow step is specific enough to execute without ambiguity
3. Check that examples have realistic input and output
4. Ensure anti-patterns describe real failure modes, not theoretical concerns
5. Run Claude Code with your skill installed and try the trigger conditions

### 24. What commit message format should I use?

```
<type>: <description>

Types: skill, command, ref, agent, hook, docs, fix, meta
```

Examples:
- `skill: add /godmode:migrate database migration skill`
- `docs: update FAQ with security questions`
- `fix: correct typo in optimize loop stopping conditions`

---

## Troubleshooting

### 25. Godmode is not detecting my project language

Run `/godmode:setup` to manually configure your project. Godmode reads from `.godmode/config.yaml`. If auto-detection fails, you can specify your language, test command, lint command, and build command directly in this file.

### 26. The optimization loop is not converging

Common causes:
- **Metric is noisy:** Use the median of multiple runs instead of a single measurement
- **Target is unrealistic:** Lower your target or increase the iteration limit
- **Guard rail is too strict:** Ensure the guard rail metric can coexist with improvements
- **Changes are too large:** Each iteration should modify exactly one thing

### 27. A skill is producing unexpected output

Skills are instructions, not code. The AI agent interprets them. If output is unexpected:
1. Check that your `.godmode/config.yaml` is correct
2. Verify that prerequisite artifacts exist (e.g., a spec file for `plan`)
3. Try running the skill with a more specific prompt
4. File an issue with the unexpected output and expected behavior

### 28. How do I reset Godmode configuration?

Delete the `.godmode/` directory and run `/godmode:setup` again:
```bash
rm -rf .godmode/
/godmode:setup
```

---

## Philosophy

### 29. Why "discipline before speed"?

Because rework is slower than doing it right the first time. Writing a 5-minute spec saves hours of building the wrong thing. Writing a failing test first catches bugs before they compound. Measuring before optimizing prevents wasted effort on bottlenecks that do not matter.

Speed without discipline is chaos. Discipline enables sustainable speed.

### 30. Why "evidence before claims"?

Because "it should work" is not the same as "it works." Every Godmode skill that claims a result (tests pass, performance improved, vulnerability fixed) must prove it by running a command and reading the output. The `/godmode:verify` skill enforces this as a gate: no claim is accepted without mechanical verification.

This principle eliminates the class of bugs where an AI says "done" but the tests are actually failing.

---

## More Questions?

Open an issue with the `question` label on the [Godmode repository](https://github.com/godmode-team/godmode/issues) and we will answer it and add it to this FAQ.
