# Tutorial: Create Your First Godmode Skill

> Step-by-step guide to creating a custom skill, from file format to testing to integration with the Godmode orchestrator.

---

## What You Will Build

In this tutorial, you will create a custom Godmode skill called `changelog` that automatically generates a changelog from git commit history. By the end, you will understand:

1. The skill file format (SKILL.md)
2. How skills are activated (triggers)
3. How to define a multi-step workflow
4. How skills produce artifacts for other skills to consume
5. How to test your skill
6. How to integrate with the Godmode orchestrator

**Prerequisites:** A working Godmode installation and a git-initialized project.

**Time:** 30 minutes.

---

## Step 1: Understand the Skill File Format

Every Godmode skill is defined in a single Markdown file called `SKILL.md` inside a directory under `skills/`. The file has two parts: YAML frontmatter (metadata) and Markdown body (the skill's behavior instructions).

```
skills/
  changelog/
    SKILL.md          ← This is the skill definition
    references/       ← Optional: reference documents the skill can consult
```

The frontmatter tells Godmode when and how to load the skill. The body tells Godmode what to do when the skill is activated.

### Frontmatter Structure

```yaml
---
name: changelog
description: |
  One or two sentences describing what this skill does. This is shown in
  skill listings and used by the orchestrator to decide when to activate
  the skill. Include trigger phrases that users might say.
---
```

The `name` field must match the directory name. The `description` is critical — the orchestrator reads it to decide when to suggest this skill.

### Body Structure

The Markdown body follows a consistent pattern across all skills:

```markdown
# Skill Name — Short Description

## When to Activate
- Trigger conditions (commands, phrases, situations)

## Workflow
### Step 1: ...
### Step 2: ...
### Step N: ...

## Key Behaviors
1. Rules the skill must always follow

## Example Usage
### Example scenario
```transcript```

## Flags & Options
| Flag | Description |
|------|-------------|

## Anti-Patterns
- Things the skill must never do
```

---

## Step 2: Create the Skill Directory

Create the directory structure for your new skill.

```bash
mkdir -p skills/changelog
```

---

## Step 3: Write the Frontmatter

Create `skills/changelog/SKILL.md` and start with the frontmatter.

```yaml
---
name: changelog
description: |
  Changelog generation skill. Produces a structured changelog from git commit
  history, grouped by type (features, fixes, breaking changes). Supports
  Conventional Commits, Keep a Changelog format, and semantic versioning.
  Triggers on: /godmode:changelog, "generate changelog", "what changed",
  "release notes", "prepare release".
---
```

**Tips for writing descriptions:**

- Include the trigger command (`/godmode:changelog`)
- Include natural language phrases users might say
- Describe the output format
- Mention the standards or conventions the skill follows
- Keep it under 5 lines — the orchestrator reads this for every skill on every invocation

---

## Step 4: Write the Activation Conditions

After the frontmatter, define when the skill should activate.

```markdown
# Changelog — Changelog Generation

## When to Activate
- User invokes `/godmode:changelog`
- User says "generate changelog", "what changed since last release"
- User says "prepare release notes", "write release notes"
- User runs `/godmode:ship` and no CHANGELOG.md exists (auto-suggested)
- When preparing a release tag or version bump
```

The "When to Activate" section serves two purposes:

1. **For humans:** tells developers when to use this skill
2. **For the orchestrator:** the `/godmode` command reads these conditions to suggest the right skill

---

## Step 5: Write the Workflow

This is the core of the skill. Define each step the skill follows when activated.

```markdown
## Workflow

### Step 1: Detect Commit Convention

Analyze the git history to determine the commit convention in use:

```
COMMIT CONVENTION DETECTION:
If > 80% of commits match "type(scope): description":
  Convention = Conventional Commits
  Types: feat, fix, chore, docs, style, refactor, perf, test, build, ci

If > 80% of commits match "TYPE-123 description":
  Convention = Jira-linked
  Extract ticket numbers for linking

If no pattern detected:
  Convention = freeform
  Group by keyword heuristic (add/new = feature, fix/bug = fix, etc.)

Detected convention: <convention>
Analyzed: <N> commits since <last tag or initial commit>
```

### Step 2: Determine Version Range

Identify which commits to include:

```
VERSION RANGE:
  Last release tag: <tag or "none">
  Commits since last tag: <N>
  Date range: <start> to <end>

  If --from flag provided: use specified starting point
  If --to flag provided: use specified ending point
  If no flags: from last tag to HEAD
```

### Step 3: Categorize Commits

Group commits by type and significance:

```
COMMIT CATEGORIZATION:

Breaking Changes:
  - <commit hash> <description>

Features (feat):
  - <commit hash> <description>

Bug Fixes (fix):
  - <commit hash> <description>

Performance (perf):
  - <commit hash> <description>

Documentation (docs):
  - <commit hash> <description>

Other:
  - <commit hash> <description>

Excluded (chore, style, ci, build — internal only):
  - <N> commits excluded from public changelog
```

### Step 4: Suggest Version Bump

Based on the categorized changes, suggest a semantic version:

```
VERSION SUGGESTION:
  Current version: <current>

  Breaking changes found: <yes/no>
  New features found: <yes/no>
  Bug fixes only: <yes/no>

  Recommended bump: <major | minor | patch>
  Suggested version: <next version>
```

Rules:
- Breaking changes → major bump (1.x.x → 2.0.0)
- New features (no breaking) → minor bump (1.1.x → 1.2.0)
- Bug fixes only → patch bump (1.1.1 → 1.1.2)

### Step 5: Generate Changelog Entry

Produce the formatted changelog entry:

```markdown
## [<version>] - <date>

### Breaking Changes
- <description> ([commit hash])

### Added
- <description> ([commit hash])

### Fixed
- <description> ([commit hash])

### Performance
- <description> ([commit hash])
```

Format follows [Keep a Changelog](https://keepachangelog.com/) convention.

### Step 6: Write and Commit

1. If CHANGELOG.md exists: prepend the new entry after the header
2. If CHANGELOG.md does not exist: create it with header and first entry
3. Commit: `"docs: changelog for v<version>"`
4. If --tag flag: create git tag `v<version>`
```

---

## Step 6: Define Key Behaviors

Key behaviors are the rules that the skill must always follow, regardless of context.

```markdown
## Key Behaviors

1. **Never fabricate commits.** Every changelog entry must correspond to an actual git commit. Include the commit hash as a link.
2. **Respect the existing format.** If CHANGELOG.md already exists with a specific format, match that format exactly. Do not switch from Keep a Changelog to Conventional Changelog mid-file.
3. **Exclude internal commits by default.** Commits tagged as chore, ci, build, or style are developer-internal. They do not belong in a user-facing changelog unless --all is specified.
4. **Group breaking changes first.** Breaking changes are the most important information in a changelog. They always appear at the top.
5. **Suggest, do not force, version bumps.** Show the recommendation and reasoning. The developer decides the final version.
6. **Produce artifacts for the ship skill.** Save the changelog entry to a predictable location so `/godmode:ship` can include it in the release.
```

---

## Step 7: Add Example Usage

Include concrete examples that show the skill in action.

```markdown
## Example Usage

### Generating a changelog for a release
```
User: /godmode:changelog

Changelog: Analyzing git history...

Detected: Conventional Commits (94% match)
Range: v1.2.0..HEAD (23 commits)

CATEGORIZED:
  Breaking Changes: 1
    - abc1234 Remove deprecated /api/v1/users endpoint
  Features: 4
    - def5678 Add bulk import for products
    - ghi9012 Add webhook delivery retry
    - jkl3456 Add CSV export for reports
    - mno7890 Add dark mode support
  Fixes: 6
    - pqr1234 Fix pagination overflow on last page
    - stu5678 Fix email validation rejecting valid TLDs
    [... 4 more ...]
  Performance: 1
    - vwx9012 Optimize product search index
  Excluded: 11 (chore, ci, build commits)

Version suggestion: 1.2.0 → 2.0.0 (MAJOR — breaking change detected)

Written to: CHANGELOG.md
Commit: "docs: changelog for v2.0.0"

Next: /godmode:ship --tag v2.0.0 to create release
```

### Generating changelog for a date range
```
User: /godmode:changelog --from 2025-01-01 --to 2025-01-31

Changelog: Generating January 2025 changelog...
Range: 47 commits from Jan 1 to Jan 31
[... output ...]
```
```

---

## Step 8: Add Flags and Anti-Patterns

```markdown
## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Generate changelog from last tag to HEAD |
| `--from <ref>` | Start from specific tag, commit, or date |
| `--to <ref>` | End at specific tag, commit, or date |
| `--version <version>` | Override the suggested version |
| `--tag` | Create a git tag after generating changelog |
| `--all` | Include internal commits (chore, ci, etc.) |
| `--format <format>` | Output format: keepachangelog (default), conventional, json |
| `--dry-run` | Show changelog without writing to file |
| `--stdout` | Print to stdout instead of writing to file |

## Anti-Patterns

- **Do NOT include merge commits in the changelog.** They are noise. Use --no-merges internally.
- **Do NOT rewrite existing changelog entries.** Only prepend new entries. The history of a changelog is sacred.
- **Do NOT guess what a commit did from a vague message.** If the commit message is "fix stuff", include it verbatim. Do not invent a better description.
- **Do NOT skip the version bump suggestion.** Even if the developer will override it, showing the reasoning helps them make the right choice.
- **Do NOT generate changelogs with zero entries.** If there are no user-facing changes since the last tag, say so clearly rather than producing an empty section.
```

---

## Step 9: Assemble the Complete Skill File

Now combine all the sections into the final `SKILL.md`. Here is the complete structure:

```
skills/changelog/SKILL.md

  ---
  name: changelog
  description: |
    [description from Step 3]
  ---

  # Changelog — Changelog Generation

  ## When to Activate
  [content from Step 4]

  ## Workflow
  ### Step 1: Detect Commit Convention
  [content from Step 5]
  ### Step 2: Determine Version Range
  [content from Step 5]
  [... remaining steps ...]

  ## Key Behaviors
  [content from Step 6]

  ## Example Usage
  [content from Step 7]

  ## Flags & Options
  [content from Step 8]

  ## Anti-Patterns
  [content from Step 8]
```

---

## Step 10: Test Your Skill

### Manual Testing

Test that the skill activates correctly:

```bash
# Direct invocation — should activate the changelog skill
/godmode:changelog

# Orchestrator detection — should suggest changelog skill
/godmode "I need to prepare release notes for v2.0"
```

### Verification Checklist

```
SKILL TESTING CHECKLIST:

  File structure:
    [ ] skills/changelog/SKILL.md exists
    [ ] Frontmatter has name and description
    [ ] Name matches directory name

  Activation:
    [ ] /godmode:changelog activates the skill
    [ ] Natural language triggers are recognized by orchestrator
    [ ] /godmode suggests this skill in appropriate contexts

  Workflow:
    [ ] Each step produces the documented output format
    [ ] Steps execute in order
    [ ] Output matches the examples in the skill file

  Artifacts:
    [ ] CHANGELOG.md is created or updated
    [ ] Commit is created with correct message format
    [ ] Output can be consumed by /godmode:ship

  Flags:
    [ ] Each flag works as documented
    [ ] --dry-run does not modify any files
    [ ] --help shows skill-specific help

  Edge cases:
    [ ] Works with zero commits since last tag
    [ ] Works with no tags in repository
    [ ] Works with non-Conventional Commit messages
    [ ] Handles merge commits correctly (excludes by default)
```

---

## Step 11: Add Reference Documents (Optional)

If your skill needs reference material (specifications, standards, examples), add them to a `references/` directory:

```
skills/changelog/
  SKILL.md
  references/
    keep-a-changelog-spec.md    # The Keep a Changelog specification
    conventional-commits.md      # Conventional Commits specification
    semver.md                    # Semantic Versioning rules
```

Reference documents give the skill additional context without bloating the main SKILL.md file. The skill can consult them when needed.

---

## Step 12: Register with the Orchestrator

The orchestrator (`/godmode`) automatically discovers skills by scanning the `skills/` directory. No manual registration is needed. However, to make your skill appear in the skill index:

1. The skill directory must contain a `SKILL.md` file
2. The frontmatter must have `name` and `description` fields
3. The description should include trigger phrases for auto-detection

To verify your skill is discovered:

```bash
# The orchestrator should list your skill
/godmode:setup --validate

# Or check the skill index
# Your skill should appear in docs/skill-index.md after updating it
```

---

## Skill File Format Reference

Here is the complete reference for all sections of a SKILL.md file.

```
SKILL.MD FORMAT REFERENCE:

Required:
  ---
  name: <skill-name>          # Must match directory name
  description: |               # Multi-line description with trigger phrases
    <description>
  ---

  # <Name> — <Short Description>

  ## When to Activate            # Trigger conditions
  ## Workflow                     # Step-by-step behavior
  ## Key Behaviors                # Rules the skill must always follow

Recommended:
  ## Example Usage               # Concrete examples with transcripts
  ## Flags & Options             # Table of supported flags
  ## Anti-Patterns               # Things the skill must never do

Optional:
  ## See Also                    # Links to related skills/docs
  ## Configuration               # Skill-specific config options
  ## Integration                 # How this skill chains with others
```

---

## Skill Design Tips

### 1. Start with the output
Before writing the workflow, define exactly what the skill produces. A changelog entry? A configuration file? A test suite? Work backward from the output.

### 2. Define artifact boundaries
Skills communicate through artifacts (files, commits, logs). Define what your skill reads (input artifacts) and what it writes (output artifacts). This is how skills chain together.

### 3. Be specific in workflows
Vague: "Analyze the codebase."
Specific: "Read package.json for dependencies. Read tsconfig.json for TypeScript configuration. Search for test files matching *.test.ts. Count test coverage from coverage/lcov.info."

### 4. Include the output format
Show exactly what the output looks like in the workflow steps. Use code blocks with placeholder values. Developers should know what to expect before running the skill.

### 5. Test with edge cases
Every skill should handle: empty input, missing files, conflicting state, and previously run state (idempotency). Document these in anti-patterns.

### 6. Write anti-patterns from experience
The anti-patterns section is what prevents the skill from doing something harmful. Each anti-pattern should describe a specific mistake and why it is wrong.

---

## What to Build Next

Now that you know how to create a skill, here are some ideas:

| Skill Idea | Description |
|-----------|-------------|
| `changelog` | The one you just built |
| `license` | Add/update LICENSE file, check dependency license compatibility |
| `env` | Generate .env.example from .env, validate all vars are set |
| `benchmark` | Run benchmarks, compare with baseline, report regressions |
| `diagram` | Generate architecture diagrams from code (Mermaid, PlantUML) |
| `deps` | Audit dependencies: outdated, vulnerable, unused, duplicated |
| `pr-review` | Automated pull request review with checklist |
| `migration` | Generate database migration from schema diff |

---

## See Also

- [Master Skill Index](../skill-index.md) — All 48 built-in skills
- [Skill Chains](../skill-chains.md) — How skills communicate through artifacts
- [Architecture Overview](../architecture.md) — System design and skill loading
- [Getting Started](../getting-started.md) — First-time Godmode setup
