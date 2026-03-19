---
name: scaffold
description: |
  Code generation and scaffolding skill. Activates when the user needs to generate boilerplate code for projects, modules, CRUD operations, API endpoints, or any repetitive code structure. Supports any framework and language by analyzing existing project patterns and generating consistent code. Uses template-based generation with full customization. Triggers on: /godmode:scaffold, "generate a new", "scaffold", "create boilerplate", "new component/service/endpoint", or when /godmode:plan identifies tasks that are pure scaffolding.
---

# Scaffold — Code Generation & Scaffolding

## When to Activate
- User invokes `/godmode:scaffold`
- User says "scaffold a new service", "generate CRUD", "create a new endpoint"
- User asks for boilerplate: "set up a new project", "create a module"
- Plan skill identifies tasks that are standard scaffolding patterns
- User says "new component", "new controller", "new model"

## Workflow

### Step 1: Detect Project Context
Before generating anything, understand the existing project:

```bash
# Detect language and framework
ls package.json pyproject.toml Cargo.toml go.mod pom.xml Gemfile 2>/dev/null

# Detect project structure pattern
find . -maxdepth 3 -type d -not -path "*/node_modules/*" -not -path "*/.git/*" | head -30

# Find existing examples of what's being scaffolded
# e.g., if generating a new controller, find existing controllers
find . -name "*controller*" -o -name "*Controller*" | head -10

# Detect code style (linting, formatting)
ls .eslintrc* .prettierrc* .editorconfig pyproject.toml 2>/dev/null
```

```
PROJECT CONTEXT:
- Language: <detected language>
- Framework: <detected framework and version>
- Structure: <project layout pattern>
- Style: <coding conventions detected>
- Existing examples: <paths to similar code>
- Test framework: <detected test framework>
- ORM/Database: <if applicable>
```

### Step 2: Identify Scaffold Type
Determine what to generate:

```
SCAFFOLD TYPES:

PROJECT:
- Full project from scratch (any framework)
- Monorepo workspace package
- Library/package skeleton

MODULE:
- Service/provider
- Controller/route handler
- Model/entity
- Repository/data access layer
- Middleware
- Utility module

CRUD:
- Full CRUD for a resource (model + controller + routes + tests)
- Single endpoint
- Database migration

COMPONENT (Frontend):
- Page/view
- Component with props/state
- Hook/composable
- Store/state management slice

INFRASTRUCTURE:
- Docker configuration
- CI/CD pipeline
- Terraform/IaC module
- Kubernetes manifests
```

### Step 3: Analyze Existing Patterns
Study existing code to ensure generated code is consistent:

```bash
# Read an existing example of the same type
cat src/controllers/users.controller.ts

# Note patterns:
# - Import style (named vs default)
# - Export style (class vs function)
# - Error handling pattern
# - Dependency injection pattern
# - Naming convention
# - File organization
```

```
PATTERN ANALYSIS:
┌──────────────────────────────────────────────────────┐
│  Detected Conventions                                 │
├──────────────────┬───────────────────────────────────┤
│  Naming          │  kebab-case files, PascalCase cls │
│  Imports         │  Named imports, absolute paths    │
│  Exports         │  Default export class             │
│  Error handling  │  Custom AppError class, try-catch │
│  DI pattern      │  Constructor injection            │
│  Test naming     │  <name>.spec.ts alongside source  │
│  Validation      │  Zod schemas in <name>.schema.ts  │
└──────────────────┴───────────────────────────────────┘
```

### Step 4: Generate Code
Generate all files for the scaffold, following detected patterns exactly.

#### Example: CRUD Scaffold for "products"

**File 1: Model/Entity**
```typescript
// src/models/product.model.ts
// Generated following pattern from src/models/user.model.ts
```

**File 2: Schema/Validation**
```typescript
// src/schemas/product.schema.ts
// Generated following pattern from src/schemas/user.schema.ts
```

**File 3: Repository/Data Access**
```typescript
// src/repositories/product.repository.ts
// Generated following pattern from src/repositories/user.repository.ts
```

**File 4: Service/Business Logic**
```typescript
// src/services/product.service.ts
// Generated following pattern from src/services/user.service.ts
```

**File 5: Controller/Route Handler**
```typescript
// src/controllers/product.controller.ts
// Generated following pattern from src/controllers/user.controller.ts
```

**File 6: Routes**
```typescript
// src/routes/product.routes.ts
// Generated following pattern from src/routes/user.routes.ts
```

**File 7: Tests**
```typescript
// src/controllers/product.controller.spec.ts
// Generated following pattern from src/controllers/user.controller.spec.ts
```

**File 8: Database Migration (if applicable)**
```sql
-- migrations/<timestamp>-create-products-table.sql
```

For each generated file:
1. Match the exact style of existing code (indentation, quotes, semicolons)
2. Use the project's actual import paths and conventions
3. Include proper typing (no `any` types)
4. Add standard error handling matching existing patterns
5. Generate corresponding test file with basic test cases

### Step 5: Verify Generated Code
After generation, verify the code compiles and passes basic checks:

```bash
# Type check
npx tsc --noEmit 2>&1 | tail -20

# Lint check
npx eslint src/controllers/product.controller.ts 2>&1

# Run generated tests
npx jest src/controllers/product.controller.spec.ts 2>&1
```

```
VERIFICATION:
┌──────────────────────────────────────────────────────┐
│  Scaffold Verification                                │
├────────────────┬────────┬────────────────────────────┤
│  Check         │  Result│  Details                   │
├────────────────┼────────┼────────────────────────────┤
│  Type check    │  PASS  │  No errors                 │
│  Lint          │  PASS  │  Clean                     │
│  Tests         │  PASS  │  5/5 tests passing         │
│  Imports       │  PASS  │  All resolved              │
│  Patterns      │  PASS  │  Matches existing code     │
└────────────────┴────────┴────────────────────────────┘
```

### Step 6: Present Summary
Show what was generated:

```
SCAFFOLD COMPLETE:
┌──────────────────────────────────────────────────────┐
│  Generated: CRUD for "products"                       │
├──────────────────────────────────────────────────────┤
│  Files created:                                       │
│  ✓ src/models/product.model.ts              (42 loc) │
│  ✓ src/schemas/product.schema.ts            (28 loc) │
│  ✓ src/repositories/product.repository.ts   (67 loc) │
│  ✓ src/services/product.service.ts          (85 loc) │
│  ✓ src/controllers/product.controller.ts    (94 loc) │
│  ✓ src/routes/product.routes.ts             (18 loc) │
│  ✓ src/controllers/product.controller.spec.ts(120 loc)│
│  ✓ migrations/20240401-create-products.sql  (15 loc) │
│                                                       │
│  Total: 8 files, 469 lines of code                   │
│  Based on: users CRUD (src/controllers/users.*)      │
│                                                       │
│  TODO (requires manual work):                         │
│  • Add product-specific business logic to service     │
│  • Update route index to include product routes       │
│  • Review migration columns for your data model       │
└──────────────────────────────────────────────────────┘
```

### Step 7: Commit
```
git add <all generated files>
git commit -m "scaffold: <type> for <name> — <N> files generated"
```

## Key Behaviors

1. **Pattern-match, don't invent.** Generated code must look like it was written by the same developer who wrote the rest of the project. Study existing code before generating.
2. **Always generate tests.** Every scaffolded module gets a corresponding test file with at least basic CRUD test cases.
3. **No dead code.** Every generated function should be callable. Don't generate placeholder methods that throw "not implemented."
4. **TODO over guess.** If the scaffold can't determine the right behavior (e.g., business logic), insert a clear TODO comment rather than guessing.
5. **Verify before committing.** Run type checks and linting on generated code. Broken scaffolds waste more time than they save.
6. **List what's manual.** Always tell the user what requires manual work after scaffolding (business logic, route registration, environment variables).

## Example Usage

### Scaffolding a new CRUD resource
```
User: /godmode:scaffold CRUD for orders

Scaffold: Analyzing project structure...

PROJECT CONTEXT:
- Framework: Express + TypeScript
- ORM: Prisma
- Pattern: Controller → Service → Repository
- Tests: Jest with supertest
- Existing CRUD: users, products (using as templates)

Generating 8 files for orders CRUD...
[generates model, schema, repository, service, controller, routes, tests, migration]

All files pass type check and lint.
5 basic test cases generated and passing.

TODO: Add order-specific business logic and review migration columns.
```

### Scaffolding a new project
```
User: /godmode:scaffold New Express + TypeScript API project

Scaffold: Generating project structure...

project-name/
├── src/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── config/
│   └── server.ts
├── tests/
├── .eslintrc.json
├── .prettierrc
├── tsconfig.json
├── package.json
├── Dockerfile
├── docker-compose.yml
└── README.md

28 files generated. Run `npm install && npm run dev` to start.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive scaffolding |
| `--crud <resource>` | Generate full CRUD for a resource |
| `--endpoint <path>` | Generate a single API endpoint |
| `--component <name>` | Generate a frontend component |
| `--service <name>` | Generate a service/provider module |
| `--project <framework>` | Generate a new project skeleton |
| `--dry-run` | Show what would be generated without creating files |
| `--from <template>` | Use a specific existing file as the template |
| `--no-tests` | Skip test file generation (not recommended) |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check package.json for framework: next, express, fastify, nestjs, remix, sveltekit
2. Detect language: tsconfig.json (TypeScript), jsconfig.json (JavaScript), pyproject.toml, go.mod
3. Detect project structure: src/ layout, app/ layout, pages/ layout, flat structure
4. Check for existing generators: plop, hygen, yeoman configs
5. Detect naming conventions: scan existing files for camelCase, PascalCase, kebab-case patterns
6. Check for test patterns: *.test.ts, *.spec.ts, __tests__/, tests/ alongside source
7. Detect code style: .eslintrc, .prettierrc, biome.json, editorconfig
8. Check for barrel exports: index.ts files, re-export patterns
```

## Iterative Scaffold Generation Loop

```
current_iteration = 0
max_iterations = 10
items_to_scaffold = [list of resources/components/endpoints to generate]

WHILE items_to_scaffold is not empty AND current_iteration < max_iterations:
    item = items_to_scaffold.pop(0)
    1. Read existing similar code to match conventions (naming, structure, imports)
    2. Generate files: source, test, types, validation schema
    3. Update barrel exports (index.ts) if project uses them
    4. Run type check: tsc --noEmit (or equivalent)
    5. Run lint: eslint/biome (auto-fix style issues)
    6. Run generated tests to verify scaffold compiles and passes
    7. IF type check or lint fails → fix generated code
    8. IF passing → commit: "scaffold: generate <item> (<files created>)"
    9. current_iteration += 1

POST-LOOP: Verify all new files are properly imported and no circular deps exist
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (2 worktrees):
  Agent 1 — "scaffold-source": source files, types, validation schemas
  Agent 2 — "scaffold-tests": test files, fixtures, mocks

MERGE ORDER: source → tests (tests import from source)
CONFLICT ZONES: barrel exports/index.ts files (one agent handles barrel updates)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. ALWAYS read existing code before generating. Match the project's conventions exactly.
2. NEVER generate a file > 200 lines. If larger, split into multiple focused files.
3. EVERY generated endpoint must include a validation schema. No unvalidated inputs.
4. EVERY generated file must include a corresponding test file. No exceptions.
5. NEVER hardcode values in generated code. Use config, env vars, or constants.
6. ALWAYS detect the framework before generating. Express code in a Fastify project is a disaster.
7. NEVER generate code that doesn't compile. Run type check before committing.
8. Generated code MUST follow the project's existing directory structure, not impose a new one.
9. EVERY generated import must be verified to exist. No broken imports.
10. NEVER overwrite existing files without explicit confirmation.
```

## Anti-Patterns

- **Do NOT generate code without reading existing code.** Scaffolded code that doesn't match project conventions creates more work than writing from scratch.
- **Do NOT generate massive files.** If a scaffold produces a 500-line file, it's doing too much. Break it into smaller, focused files.
- **Do NOT hardcode values.** Generated code should use configuration, environment variables, and constants — not hardcoded strings.
- **Do NOT skip validation schemas.** Every endpoint that accepts input needs a validation schema. Generate it even if it's basic.
- **Do NOT generate without verifying.** Always run type check and lint before committing. A scaffold that doesn't compile is worse than useless.
- **Do NOT assume the framework.** Always detect the project's actual framework and version. Scaffolding Express code in a Fastify project is a disaster.
