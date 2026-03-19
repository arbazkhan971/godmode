---
name: setup
description: |
  Configuration wizard skill. Activates when user needs to configure Godmode for a project, set up optimization targets, or define project-specific settings. Walks through goal, scope, metric, verify command, and guard rails with validation at each step. Triggers on: /godmode:setup, first-time Godmode use, or when optimize/fix skills need configuration that doesn't exist yet.
---

# Setup — Configuration Wizard

## When to Activate
- User invokes `/godmode:setup`
- First time using Godmode in a project (no `.godmode/` directory)
- Optimize skill needs a verify command but none is configured
- User wants to change optimization targets or project settings

## Workflow

### Step 1: Detect Project
Auto-detect the project environment:

```bash
# Language / framework detection
ls package.json pyproject.toml Cargo.toml go.mod Gemfile pom.xml build.gradle 2>/dev/null

# Test framework detection
ls jest.config* vitest.config* pytest.ini setup.cfg .pytest_cache Cargo.toml 2>/dev/null

# Lint tool detection
ls .eslintrc* .prettierrc* .flake8 .pylintrc .golangci.yml .rubocop.yml 2>/dev/null

# CI detection
ls .github/workflows/* .gitlab-ci.yml Jenkinsfile .circleci/config.yml 2>/dev/null
```

```
PROJECT DETECTED:
Name: <from package.json/Cargo.toml/etc or directory name>
Language: <TypeScript/Python/Rust/Go/etc>
Framework: <Express/Django/Actix/etc>
Test runner: <jest/pytest/cargo test/etc>
Lint: <eslint/flake8/clippy/etc>
CI: <GitHub Actions/GitLab CI/etc>
Package manager: <npm/pip/cargo/etc>
```

### Step 2: Configure Test Command
Find and validate the test command:

```
Detected test command: npm test

Let me verify it works...
Running: npm test
Result: ✓ 42 tests passing (3.2s)

Is this the correct test command? (yes / or provide alternative)
```

If no test command detected:
```
I couldn't detect a test command. What command runs your tests?
Example: "npm test", "pytest", "cargo test", "go test ./..."
```

**Validate the command by running it.** Never accept a test command without running it first.

### Step 3: Configure Lint Command
```
Detected lint command: npm run lint

Verifying... ✓ Lint passes

Is this correct? (yes / or provide alternative)
```

### Step 4: Configure Optimization Target (optional)
If the user is setting up for optimization:

```
What do you want to optimize?

Examples:
1. "API response time" → metric: ms, verify: curl timing
2. "Bundle size" → metric: bytes, verify: build + du
3. "Test execution time" → metric: seconds, verify: time test command
4. "Memory usage" → metric: bytes, verify: memory profiler
5. Custom metric → you provide the verify command

Choice (or describe your own):
```

For each choice, guide through:
```
OPTIMIZATION CONFIG:
Goal: <description>
Metric: <what's measured>
Verify command: <exact command>
Target: <desired value>
```

**Validate the verify command:**
```
Running verify command: <command>
Result: <output>
Parsed value: <number>

Does this look correct? The current value is <number> <unit>.
What's your target? (e.g., "< 200" or "> 90")
```

### Step 5: Configure Scope
Define what files are in scope for modifications:

```
SCOPE CONFIG:
Source files: <src/ or equivalent>
Test files: <tests/ or equivalent>
Config files: <list>
Out of scope: <node_modules/, dist/, .git/, etc>
```

### Step 6: Create Configuration File
Save all configuration:

```bash
mkdir -p .godmode
```

```yaml
# .godmode/config.yaml
project:
  name: <project name>
  language: <language>
  framework: <framework>

commands:
  test: "<test command>"
  lint: "<lint command>"
  typecheck: "<typecheck command>"
  build: "<build command>"

optimization:
  goal: "<description>"
  metric: "<metric name>"
  verify: "<verify command>"
  target: "<target value>"
  max_iterations: 25

scope:
  include:
    - "src/"
    - "tests/"
  exclude:
    - "node_modules/"
    - "dist/"
    - ".git/"

guard_rails:
  - command: "<test command>"
    name: "Tests"
    must_pass: true
  - command: "<lint command>"
    name: "Lint"
    must_pass: true
```

### Step 7: Validate Configuration
Run a full validation:

```
SETUP VALIDATION:
✓ Test command works: 42 tests passing
✓ Lint command works: clean
✓ Verify command works: 847ms (baseline)
✓ Config saved to .godmode/config.yaml

Setup complete! Godmode is configured for <project name>.

Quick start:
→ /godmode:think — Start designing a new feature
→ /godmode:optimize — Start optimizing with your configured target
→ /godmode — Let Godmode detect what to do next
```

Commit: `"setup: configure godmode for <project name>"`

## Key Behaviors

1. **Auto-detect first, ask second.** Try to detect everything automatically. Only ask when detection fails.
2. **Validate every command.** Run every configured command before accepting it. A wrong test command wastes hours.
3. **Sensible defaults.** Provide defaults for everything. The user should be able to accept defaults and go.
4. **One question at a time.** Don't present a form. Walk through step by step.
5. **Dry-run the verify command.** The optimization verify command is critical. Run it 3 times to confirm it's stable.
6. **Save to .godmode/.** All configuration lives in `.godmode/` which can be committed to the repo.

## Example Usage

### First-time setup
```
User: /godmode:setup

Setup: Detecting project...

PROJECT DETECTED:
Name: acme-api
Language: TypeScript
Framework: Express.js
Test runner: Jest (via npm test)
Lint: ESLint + Prettier
CI: GitHub Actions

Test command: npm test
Running... ✓ 127 tests passing (8.3s)

Lint command: npm run lint
Running... ✓ clean

Type check: npx tsc --noEmit
Running... ✓ no errors

What would you like to optimize? (or "skip" for now)

User: API response time for the /api/products endpoint

Setup: I'll set up a verify command for that.

Verify command: curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/products | awk '{printf "%.0f\n", $1*1000}'

Is the server running? Let me test...
Running... Result: 847ms

Current response time: 847ms
What's your target? (e.g., "< 200")

User: < 200

Setup: Configuration complete!

OPTIMIZATION CONFIG:
Goal: Reduce /api/products response time
Metric: Response time (ms)
Current: 847ms
Target: < 200ms
Verify: curl ... (validated)

Saved to .godmode/config.yaml
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full interactive setup wizard |
| `--detect` | Auto-detect and save without prompting |
| `--optimize` | Only configure optimization target |
| `--reset` | Reset all configuration |
| `--show` | Show current configuration |
| `--validate` | Re-validate existing configuration |

## Anti-Patterns

- **Do NOT accept commands without validation.** "npm test" might not work in this project. Run it.
- **Do NOT ask for information you can detect.** If `package.json` exists, the language is JavaScript/TypeScript. Don't ask.
- **Do NOT require setup for simple commands.** `/godmode:think` and `/godmode:debug` don't need setup. Only commands that need a verify command or test command require setup.
- **Do NOT create complex configuration.** The config file should be simple YAML. No nested objects, no fancy schemas.
- **Do NOT forget to commit the config.** The `.godmode/` directory should be version-controlled so teammates get the same configuration.
