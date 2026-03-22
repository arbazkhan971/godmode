# Contributing to Godmode

Thank you for your interest in improving Godmode. This guide covers how to contribute new skills, improve existing ones, add platform adapters, test your work, and submit pull requests.

---

## Table of Contents

- [Types of Contributions](#types-of-contributions)
- [Complete Skill Creation Guide](#complete-skill-creation-guide)
- [Skill Quality Checklist](#skill-quality-checklist)
- [Skill Writing Style Guide](#skill-writing-style-guide)
- [Adding a New Platform Adapter](#adding-a-new-platform-adapter)
- [Testing Your Skill](#testing-your-skill)
- [Testing Your Changes](#testing-your-changes)
- [Improving Existing Skills](#improving-existing-skills)
- [Quality Standards](#quality-standards)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Philosophy Check](#philosophy-check)
- [Design Principles (from autoresearch)](#design-principles-from-autoresearch)
- [High-Value Contributions](#high-value-contributions)
- [Multi-Platform Compatibility](#multi-platform-compatibility)

---

## Types of Contributions

### 1. New Skills
Add a new skill to the Godmode workflow. This is the most impactful contribution. There are 54 planned skill directories waiting for implementation.

### 2. Skill Improvements
Enhance an existing skill's workflow, examples, or anti-patterns.

### 3. Reference Documents
Add detailed reference material for existing skills (e.g., `skills/optimize/references/`).

### 4. Bug Fixes
Fix issues in skill logic, hook scripts, or plugin configuration.

### 5. Documentation
Improve guides, examples, tutorials, or the README.

### 6. Command Files
Add or improve `/godmode:<skill>` command definitions in `commands/godmode/`.

### 7. Platform Adapters
Add or improve support for new AI coding platforms in `adapters/`.

---

## Complete Skill Creation Guide

This is the step-by-step process for creating a new Godmode skill from scratch.

### Step 1: Choose Your Skill

Check the [planned skills list](docs/COMPLETE-SKILL-LIST.md#planned-skills-54-directories-reserved) for unclaimed skill directories, or propose a new one. If the directory already exists (e.g., `skills/redis/`), you can implement it directly. If it does not exist, create it.

Good skills are:
- **Actionable** -- They produce a concrete artifact (code, config, report, plan)
- **Repeatable** -- They work across different projects, not just one specific codebase
- **Composable** -- They chain with other skills (their output feeds another skill's input)
- **Verifiable** -- Their success can be measured or confirmed mechanically

### Step 2: Create the Directory Structure

```bash
mkdir -p skills/your-skill
touch skills/your-skill/SKILL.md
```

Optionally, add reference materials and templates:

```
skills/your-skill/
  SKILL.md                    # Required: the skill definition
  references/                 # Optional: detailed reference docs
    best-practices.md
    tool-comparison.md
  templates/                  # Optional: templates the skill produces
    report-template.md
```

### Step 3: Write the SKILL.md

Every SKILL.md **must** follow this structure exactly:

```markdown
---
name: your-skill-name
description: |
  When to use this skill. Max 1024 characters. Describe trigger conditions
  only -- not the full workflow. This is what the orchestrator reads to
  decide whether to activate this skill. Be specific about what phrases,
  keywords, or conditions should trigger this skill.
---

# Skill Name -- Short Description

## When to Activate
Explicit trigger conditions. List every scenario where this skill should run:
- User invokes `/godmode:your-skill`
- User says "specific trigger phrase"
- As part of another skill's chain (e.g., after `/godmode:build`)
- When certain project conditions are detected

## Workflow

### Step 1: Title
Detailed description of what to do.
- Include code examples
- Specify input and output
- State what happens on success AND failure

### Step 2: Title
Continue with numbered steps...

### Step N: Commit and Log
Record results in git and any relevant log file.

## Key Behaviors
Critical rules and constraints. Non-negotiable behaviors:
- ALWAYS do X
- NEVER do Y
- IF condition THEN behavior

## Example Usage

### Example 1: Common Case
```
Input: what the user says
Output: what the skill produces (with realistic detail)
```

### Example 2: Edge Case
```
Input: unusual but valid input
Output: how the skill handles it
```

## Flags & Options
| Flag | Description | Default |
|------|-------------|---------|
| `--flag` | What it does | default value |

## Anti-Patterns

### Anti-Pattern 1: Name of the bad behavior
**Bad:** Description of what NOT to do.
**Why:** Explanation of why it is bad.
**Good:** What to do instead.

### Anti-Pattern 2: Another bad behavior
...

### Anti-Pattern 3: A third bad behavior
...
```

### Step 4: Write the Description (Frontmatter)

The `description` field in the YAML frontmatter is critical. The orchestrator (`/godmode`) reads this to decide whether to activate your skill. Rules:

- Maximum 1024 characters
- Describe **trigger conditions only** -- not the full workflow
- Include keywords that users might say (e.g., "security audit", "find vulnerabilities")
- Start with a one-sentence summary of what the skill does
- End with the trigger phrases

Example:
```yaml
description: |
  Security audit skill. Activates when code needs security review before
  shipping or when user wants to identify vulnerabilities. Uses STRIDE
  threat modeling and OWASP Top 10, plus 4 red-team personas. Every
  finding has code evidence, severity rating, and remediation steps.
  Triggers on: /godmode:secure, "security audit", "is this secure?",
  "find vulnerabilities", or as pre-ship check.
```

### Step 5: Add a Command File

If your skill should be invocable as `/godmode:your-skill`, create a command file:

```bash
touch commands/godmode/your-skill.md
```

Command files are shorter than skill files. They describe usage and reference the skill:

```markdown
# /godmode:your-skill

Short description of what this command does.

## Usage

```
/godmode:your-skill [options] [description]
```

## Options

| Flag | Description |
|------|-------------|
| `--flag` | What it does |

## Examples

```
/godmode:your-skill Do the thing
/godmode:your-skill --flag Do the thing with flag
```

## Details

This command activates the `your-skill` skill. See `skills/your-skill/SKILL.md` for the complete workflow.
```

### Step 6: Register the Skill

Add your skill to `.claude-plugin/marketplace.json`:

```json
{
  "skills": {
    "your-skill": "skills/your-skill/SKILL.md"
  },
  "commands": {
    "godmode:your-skill": {
      "file": "commands/godmode/your-skill.md",
      "description": "Brief one-line description"
    }
  }
}
```

### Step 7: Update Documentation

1. **README.md** -- Add your skill to the appropriate category table in the Skill Map section
2. **docs/godmode-design.md** -- Add your skill to the appropriate phase
3. **docs/COMPLETE-SKILL-LIST.md** -- Add your skill to the alphabetical list and category section

### Step 8: Define Skill Chaining

In your SKILL.md, explicitly state:
- **What comes before:** Which skills produce artifacts your skill consumes
- **What comes after:** Which skills consume your skill's output
- **Artifacts produced:** What files or outputs your skill creates

Example:
```markdown
## Skill Chaining
- **Precedes:** `/godmode:fix` (for remediations), `/godmode:ship` (as pre-ship check)
- **Follows:** `/godmode:build` (to audit newly written code)
- **Produces:** `docs/security/<name>-audit.md`
```

---

## Skill Quality Checklist

Use this checklist before submitting any new or modified skill. Every item is required.

### Skill PR Gate

Every skill PR must pass this gate before review:

- [ ] Has all standard sections: Activate When, Auto-Detection, Workflow, Output Format, TSV Logging, Success Criteria, Error Recovery, Anti-Patterns
- [ ] Loop skills follow meta-protocol (REVIEW --> IDEATE --> MODIFY --> VERIFY --> DECIDE --> LOG)
- [ ] Has explicit stop conditions (target/budget/diminishing/stuck)
- [ ] Output format matches: `<Skill>: <before> --> <after> (<delta>%)`
- [ ] TSV schema documented with column names and example row

### SKILL.md Structure

- [ ] **Frontmatter** -- Has `name` and `description` fields in YAML frontmatter
- [ ] **Description** -- Under 1024 characters, describes trigger conditions only
- [ ] **When to Activate** -- Lists every trigger scenario (slash command, natural language, chaining)
- [ ] **Workflow** -- Numbered steps with enough detail to execute without ambiguity
- [ ] **Key Behaviors** -- Non-negotiable rules (ALWAYS/NEVER/IF-THEN format)
- [ ] **Example Usage** -- At least 2 examples with realistic input and output
- [ ] **Flags & Options** -- Table of all supported flags with defaults
- [ ] **Anti-Patterns** -- At least 3 anti-patterns with Bad/Why/Good format
- [ ] **Skill Chaining** -- States what comes before, what comes after, what artifacts are produced

### Workflow Step Quality

- [ ] Every step has a clear title and detailed instructions
- [ ] Every step includes code examples or command examples where relevant
- [ ] Every step states what happens on success AND failure
- [ ] Every step is testable (someone can verify the step was done correctly)
- [ ] The final step commits results to git and logs to results.tsv (for iterative skills)

### Anti-Pattern Quality

- [ ] Each anti-pattern describes a specific bad behavior (not generic advice)
- [ ] Each anti-pattern explains WHY it is bad (with concrete consequences)
- [ ] Each anti-pattern is based on a real failure mode, not a theoretical concern
- [ ] Each anti-pattern includes a "Good" alternative with specific instructions

### Cross-Platform Compatibility

- [ ] Skill works without `Agent()` calls OR includes a `## Platform Fallback` section
- [ ] File paths use `./` relative notation (not absolute paths)
- [ ] Commands use portable syntax (no platform-specific shell features)

### Documentation Updates

- [ ] README.md updated with new skill in the appropriate category table
- [ ] docs/COMPLETE-SKILL-LIST.md updated
- [ ] docs/godmode-design.md updated
- [ ] Command file created in `commands/godmode/`

---

## Skill Writing Style Guide

Skills are instructions that AI agents execute. Writing for an AI agent is different from writing documentation for humans. Follow these rules to ensure your skill is executed reliably.

### Be Imperative, Not Descriptive

AI agents execute instructions. They do not read descriptions for context.

**Bad:** "This step involves examining the codebase for potential issues."
**Good:** "Run `grep -r 'TODO\|FIXME\|HACK' src/` to find all flagged issues. Record the count."

### Be Specific About Tools

Name the exact tool or command. Do not say "check the file" when you mean "use Read to open `package.json`."

**Bad:** "Check the configuration."
**Good:** "Read `./package.json` and extract the `scripts.test` value. If it does not exist, STOP and report: no test command configured."

### State Success and Failure for Every Step

Every step must say what happens when it works and what happens when it does not.

**Bad:** "Run the tests."
**Good:** "Run `npm test`. If exit code is 0, proceed to Step 4. If exit code is non-zero, STOP the loop -- do not commit broken code. Record the failure in `.godmode/results.tsv` and revert with `git reset --hard HEAD~1`."

### Use ALWAYS/NEVER for Non-Negotiable Rules

Conditional language ("should", "consider", "might want to") gets ignored by AI agents. Use absolute language for things that must always happen.

**Bad:** "You should probably commit before running tests."
**Good:** "ALWAYS commit before running the verify command. This ensures you can revert with `git reset --hard HEAD~1` if verification fails."

### Provide Exact Output Formats

If the skill produces a file, show the exact format. Do not describe it abstractly.

**Bad:** "Write the results to a log file."
**Good:** "Append one line to `.godmode/results.tsv` in this format: `{round}\t{metric_value}\t{status}\t{description}\t{commit_hash}`"

### One Action Per Step

Each workflow step should do one thing. If a step contains "and" connecting two distinct actions, split it into two steps.

**Bad:** "Step 3: Run tests and fix any failures."
**Good:** "Step 3: Run tests. Step 4: If tests fail, identify the root cause. Step 5: Apply the fix."

### Write Examples That Look Real

Examples should use realistic project names, file paths, metric values, and error messages. Generic examples ("do the thing") teach the agent nothing about real usage.

**Bad:** `Input: do something with the code`
**Good:** `Input: /godmode:optimize --metric "npm test 2>&1 | tail -1" --guard "npm run lint" Reduce test suite runtime`

### Avoid Hedge Words

Words like "typically", "usually", "in most cases", "might", "perhaps" weaken instructions. The agent either does something or it does not.

**Bad:** "You might want to check if there are existing tests."
**Good:** "Check for existing tests: `find . -name '*.test.*' -o -name '*.spec.*' | head -20`. If none exist, create the test file first."

---

## Adding a New Platform Adapter

Godmode runs on multiple AI coding platforms. This guide covers how to add support for a new one.

### Prerequisites

Before starting, understand:
- How the target platform discovers and loads custom instructions
- Whether the platform supports parallel agent dispatch
- Whether the platform supports git worktrees natively
- What tool names the platform uses (Read, Write, Bash, etc.)

### Step 1: Create the Adapter Directory

```bash
mkdir -p adapters/your-platform
```

### Step 2: Create Required Files

Every adapter directory must contain these files:

| File | Purpose |
|------|---------|
| `README.md` | Setup instructions and platform-specific notes |
| `install.sh` | Installation script (must be idempotent) |
| `verify.sh` | Verification script to confirm correct installation |
| Platform config | Platform-specific configuration file |

### Step 3: Write install.sh

The install script must be idempotent -- running it twice produces the same result as running it once.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Guard against duplicate entries
# Use mkdir -p instead of mkdir
# Check for existing files before overwriting
# Print clear success/failure messages

echo "=== Godmode for YourPlatform ==="

# 1. Check prerequisites
if ! command -v your-platform &>/dev/null; then
  echo "ERROR: your-platform CLI not found. Install it first."
  exit 1
fi

# 2. Create config directory
mkdir -p "$HOME/.your-platform"

# 3. Copy or symlink configuration
# (platform-specific logic here)

# 4. Verify
echo "SUCCESS: Godmode installed for YourPlatform"
echo "Run 'bash adapters/your-platform/verify.sh' to confirm."
```

### Step 4: Write verify.sh

The verification script confirms that the adapter was installed correctly.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying Godmode for YourPlatform ==="

PASS=0
FAIL=0

# Check 1: Config file exists
if [ -f "$HOME/.your-platform/godmode-config" ]; then
  echo "PASS: Config file found"
  ((PASS++))
else
  echo "FAIL: Config file not found"
  ((FAIL++))
fi

# Check 2: Skills directory accessible
# Check 3: Platform-specific checks

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && echo "Godmode is ready for YourPlatform." || exit 1
```

### Step 5: Write the Platform Doc

If your platform needs a top-level Markdown guide (like `GEMINI.md` or `OPENCODE.md`), create one in the repository root. This file should contain:

1. A reference to the godmode orchestrator skill (`@./skills/godmode/SKILL.md`)
2. A tool mapping table (if tool names differ from Claude Code)
3. The full skill catalog (126 skills)
4. Sequential execution instructions (if the platform does not support parallel agents)
5. A "Verify Installation" section pointing to `adapters/your-platform/verify.sh`

Use `GEMINI.md` or `OPENCODE.md` as your template.

### Step 6: Update Documentation

1. Add your platform to the **Platforms** table in `README.md`
2. Add your platform to the **Platform Support Matrix** in `CONTRIBUTING.md`
3. Add your platform to `docs/platform-comparison.md`

### Step 7: Test on the Target Platform

Do not submit an adapter you have not tested on the target platform. If you do not have access, note this in your PR and request help testing.

Test these scenarios:
- Fresh install on a clean system
- Reinstall (idempotency)
- Running `verify.sh` after install
- Invoking a simple skill (e.g., `/godmode:think`)
- Invoking an iterative skill (e.g., `/godmode:optimize`)
- Invoking a skill that uses agents (e.g., `/godmode:build`) to verify sequential fallback

---

## Testing Your Skill

Since skills are Markdown files, testing is manual but systematic.

### Test 1: Readability Check
Read your SKILL.md aloud. If any step is ambiguous, rewrite it.

### Test 2: Execution Simulation
Read the skill as if you were Claude Code executing it:
1. Start at "When to Activate" -- would the trigger conditions correctly identify when to use this skill?
2. Walk through each workflow step -- is there enough detail to execute without guessing?
3. Check examples -- are the inputs realistic and the outputs accurate?
4. Review anti-patterns -- are they based on real failure modes?

### Test 3: Chaining Verification
Verify that your skill's inputs and outputs connect properly:
1. Can the skill run standalone?
2. Does it consume the correct artifacts from upstream skills?
3. Does it produce artifacts in the expected format for downstream skills?

### Test 4: Live Testing
Install the skill and test it with Claude Code:

```bash
# Install the plugin (or use local development)
claude plugin install . --local

# Test trigger conditions
/godmode:your-skill Do the thing

# Test with the orchestrator
/godmode I need to [description that should trigger your skill]
```

### Test 5: Edge Cases
Test with:
- Minimal input (just the command, no description)
- Maximum input (long, complex description)
- Wrong context (trigger that should NOT activate your skill)
- Missing prerequisites (what if the expected artifact does not exist?)

### Test 6: Cross-Reference Check
Verify all references to other skills:
- Do the referenced skills actually exist?
- Are the skill names spelled correctly?
- Do the artifact paths match what the referenced skills actually produce?

---

## Testing Your Changes

Beyond testing individual skills, verify that your changes do not break existing functionality.

### For Skill Changes

```bash
# 1. Verify the skill file parses correctly (has valid frontmatter)
head -20 skills/your-skill/SKILL.md  # Should start with ---

# 2. Verify the command file exists and references the skill
cat commands/godmode/your-skill.md   # Should reference skills/your-skill/SKILL.md

# 3. Verify documentation is updated
grep "your-skill" README.md          # Should appear in skill table
grep "your-skill" docs/COMPLETE-SKILL-LIST.md  # Should appear in list

# 4. Run the platform verify scripts to confirm nothing is broken
bash adapters/gemini/verify.sh
bash adapters/opencode/verify.sh
bash adapters/cursor/verify.sh
bash adapters/codex/verify.sh
```

### For Adapter Changes

```bash
# 1. Run install on the target platform
bash adapters/your-platform/install.sh

# 2. Run verify to confirm installation
bash adapters/your-platform/verify.sh

# 3. Run install again to confirm idempotency
bash adapters/your-platform/install.sh
bash adapters/your-platform/verify.sh
```

### For Documentation Changes

```bash
# 1. Check that all internal links resolve
# (look for broken anchors and file references)
grep -r '\[.*\](.*\.md)' README.md CONTRIBUTING.md | head -20

# 2. Verify skill counts match
ls skills/*/SKILL.md | wc -l    # Should match the count in README.md
```

---

## Improving Existing Skills

1. Read the existing skill thoroughly
2. Identify the gap (missing edge case, unclear step, outdated example)
3. Make targeted changes -- do not rewrite the whole skill
4. Ensure all existing examples still make sense
5. Add new examples if your change introduces new behavior
6. Run the same testing process described above

---

## Quality Standards

### Every Skill Must:
- [ ] Have a clear trigger condition (when does it activate?)
- [ ] Have a numbered workflow (what does it do, step by step?)
- [ ] Have at least 2 concrete examples with realistic input/output
- [ ] Have at least 3 anti-patterns (what NOT to do)
- [ ] Reference other skills where relevant (skill chaining)
- [ ] Follow the existing naming conventions
- [ ] Produce a verifiable artifact (spec, plan, test, metric, report, code)

### Every Workflow Step Must:
- [ ] Be specific enough to execute without ambiguity
- [ ] Include code examples or command examples
- [ ] State what happens on success AND failure
- [ ] Be testable (someone should be able to verify the step was done correctly)

### Anti-Patterns Must:
- [ ] Describe a specific bad behavior (not generic advice)
- [ ] Explain WHY it is bad
- [ ] Be based on real failure modes, not theoretical concerns
- [ ] Include a "Good" alternative

### The Description (Frontmatter) Must:
- [ ] Be under 1024 characters
- [ ] Describe trigger conditions, not the workflow
- [ ] Include relevant keywords and phrases
- [ ] Start with a one-sentence summary

---

## Commit Message Convention

```
<type>: <description>

Types:
  skill:    New or modified skill
  command:  New or modified command
  ref:      New or modified reference document
  agent:    New or modified agent definition
  hook:     New or modified hook
  adapter:  New or modified platform adapter
  docs:     Documentation changes
  fix:      Bug fix in existing content
  meta:     Plugin configuration, build, or CI changes
```

Examples:
```
skill: add /godmode:migrate database migration skill
skill: improve optimize loop stopping conditions
command: add --verbose flag to /godmode:debug
ref: add connection pooling guide to optimize references
adapter: add Windsurf platform adapter
docs: update README with new skill count
fix: correct typo in security STRIDE checklist
meta: add CI workflow for skill validation
```

---

## Pull Request Process

### Before You Start
1. Check existing issues and PRs to avoid duplicate work
2. For new skills, check the [planned skills list](docs/COMPLETE-SKILL-LIST.md#planned-skills-54-directories-reserved) first
3. For large changes, open an issue to discuss the approach before implementing

### Creating Your PR
1. Fork the repository
2. Create a feature branch: `feat/your-skill-name`
3. Make your changes following the quality standards above
4. Test your skill using the testing process described in this guide
5. Update all documentation (README, design doc, skill list)
6. Commit with the proper message format

### PR Requirements
Your PR must include:
- [ ] Summary of what the skill does
- [ ] Why it belongs in Godmode (which gap does it fill?)
- [ ] At least one example of expected usage
- [ ] Confirmation that you have tested the skill (describe how)
- [ ] All documentation updates (README, design doc, skill list)

### PR Template

```markdown
## Summary
[1-2 sentence description of the change]

## Motivation
[Why does this skill/change belong in Godmode?]

## Testing
[How did you test this? Which of the 6 test steps did you perform?]

## Checklist
- [ ] SKILL.md follows the required structure
- [ ] Description is under 1024 characters
- [ ] At least 2 examples with realistic I/O
- [ ] At least 3 anti-patterns
- [ ] Skill chaining is documented
- [ ] Command file created (if applicable)
- [ ] README.md updated
- [ ] docs/godmode-design.md updated
- [ ] docs/COMPLETE-SKILL-LIST.md updated
- [ ] Commit messages follow convention
- [ ] Platform verify scripts still pass
```

### Review Process
1. A maintainer reviews the PR for quality standards compliance
2. The skill is tested by executing it in a real project
3. Feedback is provided within 5 business days
4. Once approved, the skill is merged and the skill count is updated

---

## Philosophy Check

Before contributing, ask yourself:

1. **Does this skill follow the discipline-before-speed principle?** It should encourage doing things right, not doing things fast.

2. **Does this skill produce evidence?** Every skill should produce a verifiable artifact (spec, plan, test, metric, report).

3. **Does this skill respect git-as-memory?** Changes should be committed. Results should be logged.

4. **Does this skill chain with others?** It should clearly state what comes before and after it in the workflow.

5. **Would someone actually use this?** Be honest. If the skill is too theoretical or too niche, it might not belong in the core plugin.

---

## Design Principles (from autoresearch)

- Every instruction must be mechanically executable by an AI agent
- If you can't measure it, don't optimize for it
- Simpler is always better at equal performance
- Every decision is binary: keep or discard
- Log everything, overwrite nothing

---

## High-Value Contributions

These are the contributions that have the most impact right now:

### 1. Implement a Planned Skill
54 skill directories are waiting for SKILL.md files. Pick one from the [planned skills list](docs/COMPLETE-SKILL-LIST.md#planned-skills-54-directories-reserved). Some high-priority ones:

| Skill | Why It Matters |
|-------|---------------|
| `react` | Most popular frontend framework |
| `nextjs` | Most popular React meta-framework |
| `redis` | Used in nearly every production stack |
| `postgres` | Most popular open-source database |
| `logging` | Observability is incomplete without it |
| `cli` | CLI tools are a core developer workflow |
| `nosql` | MongoDB, DynamoDB, and similar are widely used |
| `pwa` | Progressive Web Apps are increasingly common |
| `legacy` | Legacy modernization is a universal need |

### 2. Add Reference Documents
Existing skills benefit from deeper reference material. For example:
- `skills/optimize/references/profiling-tools.md`
- `skills/secure/references/owasp-checklist.md`
- `skills/k8s/references/helm-chart-patterns.md`

### 3. Add Real-World Examples
The best examples come from real projects. If you have used a skill and can share the input/output (sanitized), add it to the skill's Example Usage section.

### 4. Fix Anti-Patterns
If you have encountered a failure mode that a skill does not warn about, add it as an anti-pattern. Real failure modes are more valuable than theoretical ones.

### 5. Add a Platform Adapter
If you use an AI coding tool that Godmode does not support yet, adding an adapter makes all 126 skills available on that platform. See [Adding a New Platform Adapter](#adding-a-new-platform-adapter) for the guide.

---

## Multi-Platform Compatibility

Godmode runs on multiple AI coding platforms. If your contribution touches agents, adapters, or parallel execution features, follow these guidelines to keep things working everywhere.

### When Writing New Skills

**Single-threaded skills are already cross-platform.** If your skill does not use `Agent()` calls or worktree features (no parallel agents, no worktree checkouts), it works on every supported platform with no additional effort.

**Skills that use `Agent()` or worktrees need a fallback.** If your skill dispatches parallel agents or uses worktree isolation, add a `## Platform Fallback` section to your SKILL.md. This section must describe how the skill degrades gracefully on platforms that do not support multi-agent or worktree features. Reference [`adapters/shared/sequential-dispatch.md`](adapters/shared/sequential-dispatch.md) for the standard fallback protocol -- it defines how parallel agent dispatches are converted to sequential execution on single-threaded platforms.

Example `## Platform Fallback` section:

```markdown
## Platform Fallback
This skill dispatches 3 parallel review agents. On platforms without Agent()
support, fall back to sequential dispatch per adapters/shared/sequential-dispatch.md:
1. Run the security review step first
2. Run the performance review step second
3. Run the correctness review step third
4. Merge results identically to the parallel path
```

### When Adding Platform Adapters

Adapter files live in `adapters/{platform}/`. Each adapter directory must contain:

| File | Purpose |
|------|---------|
| `README.md` | Setup instructions and platform-specific notes |
| `install.sh` | Installation script for the adapter (must be idempotent) |
| `verify.sh` | Verification script to confirm correct installation |
| Platform config | A platform-specific configuration file (e.g., `gemini-config.md`, `plugin.json`) |

Rules for adapters:

- **Install scripts must be idempotent.** Running `install.sh` twice must produce the same result as running it once. Guard against duplicate entries, check for existing files before overwriting, and use `mkdir -p` instead of `mkdir`.
- **Verify scripts must be included.** Every adapter needs a `verify.sh` that confirms the installation is correct. Users run this after install to confirm everything works.
- **Test on the target platform before submitting.** Do not submit an adapter you have only tested on a different platform. If you do not have access to the target platform, note this in your PR and request help testing.
- **Follow the existing directory structure.** Look at `adapters/gemini/`, `adapters/opencode/`, and `adapters/cursor/` for reference implementations.

### Agent Definitions

Godmode maintains agent definitions in two formats:

| Format | Location | Used By |
|--------|----------|---------|
| Markdown | `agents/*.md` | Claude Code |
| TOML | `.codex/agents/*.toml` | Codex |

When adding a new agent:

1. **Create both files.** Every agent needs a definition in `agents/your-agent.md` AND `.codex/agents/your-agent.toml`.
2. **Keep behavior identical.** The agent's role, constraints, and output format must match across both definitions. Differences in syntax are expected; differences in behavior are not.
3. **Use existing agents as templates.** Compare `agents/builder.md` with `.codex/agents/builder.toml` to see how the same agent is expressed in both formats.
4. **Name consistently.** The filename must match between formats (e.g., `security.md` and `security.toml`).

### Platform Support Matrix

| Platform | Skills | Agents | Worktrees | Parallel Dispatch | Adapter Location |
|----------|--------|--------|-----------|-------------------|------------------|
| **Claude Code** | Full | Full (`agents/*.md`) | Full | Full | Native (no adapter) |
| **Codex** | Full | Full (`.codex/agents/*.toml`) | Full | Full | `adapters/codex/` |
| **Gemini CLI** | Full | Sequential only | Not supported | Sequential fallback | `adapters/gemini/` |
| **OpenCode** | Full | Sequential only | Not supported | Sequential fallback | `adapters/opencode/` |
| **Cursor** | Full | Sequential only | Not supported | Sequential fallback | `adapters/cursor/` |

**Key:** "Sequential only" means the platform runs one agent at a time using the fallback protocol in `adapters/shared/sequential-dispatch.md`. "Full" means the platform supports the feature natively.

---

## Questions?

Open an issue with the `question` label and we will help you get started.
