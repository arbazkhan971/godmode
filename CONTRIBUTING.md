# Contributing to Godmode

Thank you for your interest in improving Godmode. This guide covers how to contribute new skills, improve existing ones, test your work, and submit pull requests.

---

## Table of Contents

- [Types of Contributions](#types-of-contributions)
- [Complete Skill Creation Guide](#complete-skill-creation-guide)
- [Testing Your Skill](#testing-your-skill)
- [Improving Existing Skills](#improving-existing-skills)
- [Quality Standards](#quality-standards)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Philosophy Check](#philosophy-check)
- [High-Value Contributions](#high-value-contributions)

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

---

## Questions?

Open an issue with the `question` label and we will help you get started.
