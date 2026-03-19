---
name: dx
description: |
  Developer experience optimization skill. Activates when the user needs to improve dev environment setup, feedback loops, error messages, CLI tooling, or internal developer portals. Covers environment automation (Docker, devcontainers, Nix), hot reload and fast feedback loop configuration, error message improvement for actionable diagnostics, CLI tool design with argument parsing and help systems, and internal tooling and developer portal setup. Every recommendation is concrete and measurable. Triggers on: /godmode:dx, "developer experience", "dev environment", "hot reload", "error messages", "CLI tool", "internal tooling", or when onboarding friction is identified.
---

# DX — Developer Experience Optimization

## When to Activate
- User invokes `/godmode:dx`
- User says "developer experience", "dev setup is slow", "improve DX"
- User asks about "hot reload", "fast feedback", "dev environment"
- User wants better error messages, CLI tooling, or internal tools
- Onboarding a new developer takes more than 30 minutes
- Build times, test cycles, or feedback loops are too slow
- Error messages are cryptic, missing context, or not actionable

## Workflow

### Step 1: DX Audit
Assess the current developer experience across five dimensions:

```
DX AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  Project: <name>                                              │
│  Language(s): <detected>                                      │
│  Team size: <N developers>                                    │
├──────────────────┬────────┬──────────────────────────────────┤
│  Dimension        │ Score  │ Details                          │
├──────────────────┼────────┼──────────────────────────────────┤
│  Environment Setup│  /10   │ Time to first build: <N min>     │
│  Feedback Loops   │  /10   │ Save-to-result: <N sec>          │
│  Error Messages   │  /10   │ Actionable: <N%> of errors       │
│  CLI & Tooling    │  /10   │ Commands documented: <N%>        │
│  Documentation    │  /10   │ Onboarding guide: <exists/none>  │
├──────────────────┼────────┼──────────────────────────────────┤
│  Overall DX Score │  /50   │ <grade>                          │
└──────────────────┴────────┴──────────────────────────────────┘

Grade thresholds:
  40-50: EXCELLENT — new devs productive in < 15 min
  30-39: GOOD — minor friction points
  20-29: FAIR — notable pain points, improvement needed
  10-19: POOR — significant developer friction
   0-9:  CRITICAL — developers actively fighting the toolchain
```

### Step 2: Environment Setup Automation
Eliminate "works on my machine" problems:

#### Detect Current Setup
```bash
# Check for existing environment definitions
ls -la Dockerfile docker-compose.yml .devcontainer/ flake.nix shell.nix Vagrantfile Makefile 2>/dev/null

# Check for setup scripts
ls -la scripts/setup* scripts/bootstrap* scripts/dev* bin/setup* 2>/dev/null

# Measure time to first build
time npm install && npm run build  # or equivalent
```

#### Environment Strategies

```
STRATEGY SELECTION:
┌──────────────────┬──────────────────────────────────────────┐
│  Strategy         │ Best For                                 │
├──────────────────┼──────────────────────────────────────────┤
│  Devcontainer     │ VS Code teams, consistent envs           │
│  Docker Compose   │ Multi-service projects, CI parity        │
│  Nix / Nix Flakes │ Reproducible builds, mixed languages     │
│  Makefile         │ Universal task runner, any language       │
│  mise / asdf      │ Runtime version management               │
│  just             │ Modern command runner (Makefile alt)      │
└──────────────────┴──────────────────────────────────────────┘
```

#### Devcontainer Setup
```json
// .devcontainer/devcontainer.json
{
  "name": "<project>-dev",
  "image": "mcr.microsoft.com/devcontainers/<language>:<version>",
  "features": {
    // Language-specific tools
  },
  "postCreateCommand": "scripts/setup.sh",
  "forwardPorts": [3000, 5432],
  "customizations": {
    "vscode": {
      "extensions": [
        // Project-specific extensions
      ],
      "settings": {
        // Consistent editor settings
      }
    }
  }
}
```

#### One-Command Setup Script
Every project MUST have a single command that takes a developer from zero to running:

```bash
#!/usr/bin/env bash
# scripts/setup.sh — Zero to running in one command
set -euo pipefail

echo "=== Setting up <project> development environment ==="

# 1. Check prerequisites
check_prereqs() {
  local missing=()
  command -v node >/dev/null || missing+=("node")
  command -v docker >/dev/null || missing+=("docker")
  if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Missing prerequisites: ${missing[*]}"
    echo "Install with: brew install ${missing[*]}"
    exit 1
  fi
}

# 2. Install dependencies
install_deps() {
  echo "--- Installing dependencies..."
  npm ci --prefer-offline
}

# 3. Set up environment
setup_env() {
  echo "--- Setting up environment..."
  if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from .env.example — review and update values"
  fi
}

# 4. Set up database
setup_db() {
  echo "--- Setting up database..."
  docker compose up -d postgres
  sleep 2
  npm run db:migrate
  npm run db:seed
}

# 5. Verify everything works
verify() {
  echo "--- Verifying setup..."
  npm test -- --bail --silent 2>&1 | tail -3
  echo "--- Setup complete! Run 'npm run dev' to start."
}

check_prereqs
install_deps
setup_env
setup_db
verify
```

### Step 3: Hot Reload & Fast Feedback Loops
Minimize the time between saving a file and seeing the result:

#### Feedback Loop Benchmarks
```
FEEDBACK LOOP ANALYSIS:
┌─────────────────────┬──────────┬──────────┬──────────────┐
│  Action              │ Current  │ Target   │ Strategy     │
├─────────────────────┼──────────┼──────────┼──────────────┤
│  Save → UI update    │ <N>s     │ < 1s     │ HMR / Vite   │
│  Save → test result  │ <N>s     │ < 3s     │ Watch mode   │
│  Save → type check   │ <N>s     │ < 2s     │ Incremental  │
│  Save → lint result  │ <N>s     │ < 1s     │ Editor integ │
│  Commit → CI result  │ <N>min   │ < 5min   │ Parallel CI  │
│  PR → review ready   │ <N>hrs   │ < 1hr    │ Auto-review  │
└─────────────────────┴──────────┴──────────┴──────────────┘
```

#### Hot Reload Configuration

**Frontend (Vite / webpack):**
```typescript
// vite.config.ts — Optimized for fast HMR
export default defineConfig({
  server: {
    hmr: true,
    watch: {
      // Ignore large directories that don't affect the app
      ignored: ['**/node_modules/**', '**/dist/**', '**/.git/**'],
    },
  },
  optimizeDeps: {
    // Pre-bundle heavy dependencies
    include: ['react', 'react-dom', 'lodash-es'],
  },
});
```

**Backend (Node.js):**
```bash
# Use tsx for instant TypeScript execution with watch mode
npx tsx watch --clear-screen=false src/server.ts

# Or node --watch (Node 18+)
node --watch --experimental-specifier-resolution=node src/server.ts
```

**Test Watch Mode:**
```bash
# Jest — watch mode with filter
npx jest --watch --changedSince=main

# Vitest — near-instant re-runs
npx vitest --reporter=dot

# pytest — watch with pytest-watch
ptw -- --tb=short -q
```

#### File Watcher Optimization
```bash
# Check current watch limits
cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || sysctl fs.inotify.max_user_watches 2>/dev/null

# If hitting limits, increase
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# macOS: check for fsevents issues
# Ensure .watchmanconfig exists for projects using Watchman
echo '{"ignore_dirs": ["node_modules", ".git", "dist"]}' > .watchmanconfig
```

### Step 4: Error Message Improvement
Transform cryptic errors into actionable diagnostics:

#### Error Message Audit
```
ERROR MESSAGE AUDIT:
Method: Scan all throw/Error/panic/raise statements
Total error sites: <N>
Analyzed: <N>

Classification:
  GOOD    (actionable, includes context): <N> (<percentage>)
  FAIR    (descriptive but missing context): <N> (<percentage>)
  POOR    (cryptic, no guidance):          <N> (<percentage>)
  MISSING (bare throw, no message):        <N> (<percentage>)
```

#### Error Message Framework
Every error message MUST contain these elements:

```
┌──────────────────────────────────────────────────────────────┐
│  WHAT happened:    Clear description of the failure           │
│  WHY it happened:  Root cause or likely trigger               │
│  WHERE it happened: File, function, line, input that caused   │
│  HOW to fix it:    Specific remediation steps                 │
│  CONTEXT:          Request ID, user, timestamp, input values  │
└──────────────────────────────────────────────────────────────┘
```

**Before (cryptic):**
```typescript
throw new Error("Invalid input");
```

**After (actionable):**
```typescript
throw new ValidationError(
  `Invalid email format: "${input.email}" does not match RFC 5322. ` +
  `Expected format: user@domain.tld. ` +
  `Received at: POST /api/users, field: "email".`,
  {
    field: 'email',
    received: input.email,
    expected: 'RFC 5322 email format',
    docs: 'https://internal.docs/api/users#email-validation',
  }
);
```

#### Structured Error Classes
```typescript
// src/errors/base.ts
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number,
    public readonly context: Record<string, unknown> = {},
    public readonly remediation?: string,
  ) {
    super(message);
    this.name = this.constructor.name;
  }

  toJSON() {
    return {
      error: this.code,
      message: this.message,
      remediation: this.remediation,
      context: this.context,
      timestamp: new Date().toISOString(),
    };
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, identifier: string) {
    super(
      `${resource} not found: "${identifier}"`,
      'RESOURCE_NOT_FOUND',
      404,
      { resource, identifier },
      `Verify the ${resource} ID exists. List available: GET /api/${resource.toLowerCase()}s`,
    );
  }
}

export class ConfigError extends AppError {
  constructor(key: string, expected: string, received: unknown) {
    super(
      `Configuration error: "${key}" is ${received === undefined ? 'missing' : `"${received}"`}. Expected: ${expected}.`,
      'CONFIG_ERROR',
      500,
      { key, expected, received },
      `Set ${key} in .env or environment variables. See .env.example for reference.`,
    );
  }
}
```

### Step 5: CLI Tool Design
Design developer-facing CLI tools with excellent UX:

#### CLI Design Principles
```
CLI DESIGN CHECKLIST:
[ ] Help text on --help and -h (auto-generated from command definitions)
[ ] Version flag --version / -V
[ ] Colored output (respects NO_COLOR environment variable)
[ ] Progress indicators for long operations
[ ] Exit codes: 0 = success, 1 = user error, 2 = system error
[ ] Autocomplete support (bash, zsh, fish)
[ ] Machine-readable output with --json flag
[ ] Quiet mode with --quiet / -q flag
[ ] Verbose mode with --verbose / -v flag
[ ] Dry run mode with --dry-run flag
[ ] Respects stdin/stdout piping
[ ] Configuration file support (project-local and user-global)
```

#### CLI Framework Selection
```
┌──────────────────┬──────────────────────────────────────────┐
│  Framework        │ Best For                                 │
├──────────────────┼──────────────────────────────────────────┤
│  commander (Node) │ Simple CLIs, quick setup                 │
│  oclif (Node)     │ Complex multi-command CLIs, plugins      │
│  yargs (Node)     │ Middleware-based, flexible parsing       │
│  clap (Rust)      │ High-perf CLIs, derive-based definitions │
│  cobra (Go)       │ Standard Go CLI pattern                  │
│  click (Python)   │ Decorator-based, composable commands     │
│  typer (Python)   │ Type-hint-based, auto-generated help     │
└──────────────────┴──────────────────────────────────────────┘
```

#### CLI Output Patterns
```typescript
// Good CLI output patterns
import ora from 'ora';
import chalk from 'chalk';

// Progress spinner for long operations
const spinner = ora('Building project...').start();
// ... work ...
spinner.succeed('Build complete in 3.2s');

// Structured table output
console.table(results);

// JSON mode for piping
if (flags.json) {
  console.log(JSON.stringify(results, null, 2));
  process.exit(0);
}

// Color-aware output (respects NO_COLOR)
const c = process.env.NO_COLOR ? { red: (s: string) => s, green: (s: string) => s } : chalk;
console.log(c.green('Success:'), 'Operation completed');
console.error(c.red('Error:'), 'Operation failed —', message);
```

### Step 6: Developer Portal & Internal Tooling
Build self-service developer platforms:

#### Developer Portal Structure
```
DEVELOPER PORTAL COMPONENTS:
┌──────────────────────────────────────────────────────────────┐
│  Component              │ Purpose                             │
├─────────────────────────┼─────────────────────────────────────┤
│  API Catalog            │ Discover and test internal APIs      │
│  Service Dashboard      │ Health, ownership, dependencies      │
│  Scaffolding Wizard     │ Generate new services/components     │
│  Documentation Hub      │ Searchable docs across all services  │
│  Runbook Library        │ Incident response procedures         │
│  Environment Manager    │ Provision dev/staging environments   │
│  Secret Management      │ Self-service secret rotation         │
│  CI/CD Dashboard        │ Build status, deployment history     │
│  Feature Flag Console   │ Toggle features per environment      │
│  Dependency Graph       │ Visualize service dependencies       │
└─────────────────────────┴─────────────────────────────────────┘
```

#### Internal Tool Patterns
```
INTERNAL TOOL DESIGN:
1. Self-service over tickets — Developers should never wait for someone else
2. Convention over configuration — Sensible defaults, escape hatches for power users
3. Discoverable — If it exists, developers can find it without asking
4. Observable — Every tool logs what it did, why, and whether it succeeded
5. Idempotent — Running a tool twice produces the same result
6. Fast — If it takes more than 30 seconds, add a progress indicator
7. Documented — Every command has --help that actually helps
```

#### Service Catalog Template
```yaml
# catalog-info.yaml (Backstage-compatible)
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: <service-name>
  description: <one-line description>
  annotations:
    github.com/project-slug: <org>/<repo>
    backstage.io/techdocs-ref: dir:.
  tags:
    - <language>
    - <domain>
  links:
    - url: <runbook-url>
      title: Runbook
    - url: <dashboard-url>
      title: Grafana Dashboard
spec:
  type: service
  lifecycle: production
  owner: <team-name>
  system: <system-name>
  providesApis:
    - <api-name>
  dependsOn:
    - component:<dependency-name>
```

### Step 7: DX Improvement Plan
Prioritize improvements by impact and effort:

```
DX IMPROVEMENT PLAN:
┌───┬─────────────────────────────────┬────────┬────────┬──────────┐
│ # │ Improvement                     │ Impact │ Effort │ Priority │
├───┼─────────────────────────────────┼────────┼────────┼──────────┤
│ 1 │ <highest priority item>         │ HIGH   │ LOW    │ DO NOW   │
│ 2 │ <second priority item>          │ HIGH   │ MEDIUM │ DO NEXT  │
│ 3 │ <third priority item>           │ MEDIUM │ LOW    │ DO NEXT  │
│ 4 │ <fourth priority item>          │ MEDIUM │ MEDIUM │ BACKLOG  │
│ 5 │ <fifth priority item>           │ LOW    │ HIGH   │ BACKLOG  │
└───┴─────────────────────────────────┴────────┴────────┴──────────┘

Quick wins (< 1 hour, high impact):
  1. <item>
  2. <item>

Strategic investments (> 1 day, transformative):
  1. <item>
  2. <item>
```

### Step 8: Commit and Transition
1. Commit setup files: `"dx: <project> — automated dev environment setup"`
2. Commit error improvements: `"dx: <project> — improve error messages (<N> errors made actionable)"`
3. Commit CLI enhancements: `"dx: <project> — CLI tooling improvements"`
4. Final report with before/after DX scores

## Key Behaviors

1. **Measure first.** Time the setup process, time the feedback loops, count the cryptic errors. Numbers before opinions.
2. **One-command setup is non-negotiable.** If a new developer cannot go from clone to running in one command, the DX is broken.
3. **Sub-second feedback wins.** Every second added to the save-to-result loop multiplies across every developer, every day. Optimize ruthlessly.
4. **Error messages are UI.** Developers read error messages more than documentation. Make every error message a mini-tutorial.
5. **Self-service over tickets.** If a developer needs to ask someone else to do something routine, automate it into a tool.
6. **Defaults matter more than options.** Most developers never change defaults. Make the defaults excellent.

## Example Usage

### Auditing and improving a Node.js project
```
User: /godmode:dx Our dev setup takes 20 minutes and the error messages are terrible

DX: Running DX audit...

DX AUDIT:
  Environment Setup: 3/10 — Time to first build: 22 min
  Feedback Loops:    6/10 — Save-to-test: 8.3s (Jest cold start)
  Error Messages:    2/10 — 67% of errors are "Something went wrong"
  CLI & Tooling:     5/10 — Makefile exists but incomplete
  Documentation:     4/10 — README has setup steps but they're outdated
  Overall: 20/50 (POOR)

IMPROVEMENT PLAN:
Priority 1: Create one-command setup script (Impact: HIGH, Effort: LOW)
  → Created scripts/setup.sh — setup time: 22 min → 3 min
  → Added .devcontainer for VS Code users

Priority 2: Fix error messages (Impact: HIGH, Effort: MEDIUM)
  → Audited 47 error throw sites
  → Improved 31 errors with context and remediation
  → Created AppError base class with structured errors

Priority 3: Speed up test feedback (Impact: MEDIUM, Effort: LOW)
  → Switched to Vitest — save-to-test: 8.3s → 0.4s
  → Added --watch mode to npm scripts

AFTER:
  Environment Setup: 8/10 — Time to first build: 3 min
  Feedback Loops:    9/10 — Save-to-test: 0.4s
  Error Messages:    7/10 — 93% of errors now actionable
  CLI & Tooling:     6/10 — Setup script + Makefile updated
  Documentation:     5/10 — README updated with new setup
  Overall: 35/50 (GOOD) — improved from 20 (+75%)
```

### Designing a CLI tool
```
User: /godmode:dx Design a CLI for our database migration tool

DX: Designing CLI with developer-first UX...

CLI DESIGN:
  Name: migrate
  Framework: commander (Node.js)

  Commands:
    migrate up                    Run pending migrations
    migrate down [--steps N]      Roll back N migrations (default: 1)
    migrate create <name>         Generate new migration file
    migrate status                Show migration status table
    migrate reset                 Roll back all and re-run
    migrate seed                  Run seed data

  Flags (global):
    --env <name>        Target environment (default: development)
    --dry-run           Show SQL without executing
    --json              Machine-readable output
    --verbose / -v      Show detailed SQL output
    --quiet / -q        Suppress non-error output

  [Generates CLI implementation with help text, autocomplete, and error handling]
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full DX audit across all dimensions |
| `--setup` | Focus on environment setup only |
| `--feedback` | Focus on feedback loop optimization only |
| `--errors` | Focus on error message improvement only |
| `--cli` | Focus on CLI tool design only |
| `--portal` | Focus on developer portal setup |
| `--audit-only` | Run audit without making changes |
| `--quick-wins` | Show only improvements under 1 hour effort |
| `--before-after` | Compare DX scores before and after changes |

## Anti-Patterns

- **Do NOT skip the audit.** Improving DX without measuring first means you might optimize the wrong thing. Audit, then prioritize, then improve.
- **Do NOT make setup depend on tribal knowledge.** "Ask Sarah how to set up Redis" is not documentation. Automate it or write it down.
- **Do NOT ignore Windows/Linux/macOS differences.** If the team is multi-platform, test setup on all platforms or use containers.
- **Do NOT over-engineer internal tools.** A 200-line script that solves the problem is better than a microservice with a React frontend. Start simple, add complexity only when needed.
- **Do NOT throw bare errors.** `throw new Error("fail")` is never acceptable. Every error needs context.
- **Do NOT leave broken npm scripts.** If `npm run test` doesn't work, developers lose trust in all the other scripts. Keep every script working.
- **Do NOT build a developer portal before you have documentation.** A portal without content is just an empty website. Write the docs first, then build the portal to organize them.
- **Do NOT optimize feedback loops you haven't measured.** "It feels slow" is not a measurement. Time it, then decide if it needs optimization.
