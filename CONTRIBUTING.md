# Contributing to Godmode

Thank you for your interest in improving Godmode. This guide covers how to contribute new skills, improve existing ones, and work on the core plugin.

## Types of Contributions

### 1. New Skills
Add a new skill to the Godmode workflow.

### 2. Skill Improvements
Enhance an existing skill's workflow, examples, or anti-patterns.

### 3. Reference Documents
Add detailed reference material for existing skills.

### 4. Bug Fixes
Fix issues in skill logic, hook scripts, or plugin configuration.

### 5. Documentation
Improve guides, examples, or the README.

---

## Adding a New Skill

### Step 1: Create the Skill File
Create a new directory under `skills/` with a `SKILL.md`:

```
skills/your-skill/SKILL.md
```

### Step 2: Follow the SKILL.md Structure

Every skill MUST have this structure:

```markdown
---
name: your-skill-name
description: |
  When to use this skill. Max 1024 characters. Describe trigger conditions
  only — not the full workflow. This is what the orchestrator reads to
  decide whether to activate this skill.
---

# Skill Name — Short Description

## When to Activate
Explicit trigger conditions. When should this skill run?

## Workflow
Numbered steps with clear process. This is the main content.

## Key Behaviors
Critical rules and constraints. Non-negotiable behaviors.

## Example Usage
Concrete examples showing input and output.

## Flags & Options
If applicable — table of flags.

## Anti-Patterns
What NOT to do. Common mistakes to avoid.
```

### Step 3: Add a Command File (if applicable)
If the skill should have a `/godmode:your-skill` command:

```
commands/godmode/your-skill.md
```

Command files are shorter — they describe usage and link to the skill.

### Step 4: Register in marketplace.json
Add your skill to `.claude-plugin/marketplace.json`:

```json
{
  "skills": {
    "your-skill": "skills/your-skill/SKILL.md"
  },
  "commands": {
    "godmode:your-skill": {
      "file": "commands/godmode/your-skill.md",
      "description": "Brief description"
    }
  }
}
```

### Step 5: Add to the Design Doc
Update `docs/godmode-design.md` with your skill in the appropriate phase.

### Step 6: Update the README
Add your skill to the skills table in `README.md`.

---

## Quality Standards for Skills

### Every Skill Must:
- [ ] Have a clear trigger condition (when does it activate?)
- [ ] Have a numbered workflow (what does it do, step by step?)
- [ ] Have at least 2 concrete examples with realistic input/output
- [ ] Have at least 3 anti-patterns (what NOT to do)
- [ ] Reference other skills where relevant (skill chaining)
- [ ] Follow the existing naming conventions

### Every Workflow Step Must:
- [ ] Be specific enough to execute without ambiguity
- [ ] Include code examples or command examples
- [ ] State what happens on success AND failure
- [ ] Be testable (someone should be able to verify the step was done correctly)

### Anti-Patterns Must:
- [ ] Describe a specific bad behavior (not generic advice)
- [ ] Explain WHY it's bad
- [ ] Be based on real failure modes, not theoretical concerns

---

## Improving Existing Skills

1. Read the existing skill thoroughly
2. Identify the gap (missing edge case, unclear step, outdated example)
3. Make targeted changes — don't rewrite the whole skill
4. Ensure all existing examples still make sense
5. Add new examples if your change introduces new behavior

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
```

---

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `feat/your-skill-name`
3. Make your changes following the quality standards above
4. Test your skill by reading it as if you were Claude Code executing it
5. Update the README and marketplace.json
6. Submit a PR with:
   - Summary of what the skill does
   - Why it belongs in Godmode
   - Example usage

---

## Philosophy Check

Before contributing, ask yourself:

1. **Does this skill follow the discipline-before-speed principle?** It should encourage doing things right, not doing things fast.

2. **Does this skill produce evidence?** Every skill should produce a verifiable artifact (spec, plan, test, metric, report).

3. **Does this skill respect git-as-memory?** Changes should be committed. Results should be logged.

4. **Does this skill chain with others?** It should clearly state what comes before and after it in the workflow.

5. **Would someone actually use this?** Be honest. If the skill is too theoretical or too niche, it might not belong in the core plugin.

---

## Questions?

Open an issue with the `question` label and we'll help you get started.
