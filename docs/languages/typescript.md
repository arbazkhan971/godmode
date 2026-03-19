# TypeScript Developer Guide

How to use Godmode's full workflow for TypeScript projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects TypeScript via tsconfig.json
# Test: npm test / npx vitest / npx jest
# Lint: npx eslint . / npm run lint
# Build: npx tsc --noEmit / npm run build
# Type check: npx tsc --noEmit
```

### Example `.godmode/config.yaml`
```yaml
language: typescript
framework: express          # or nestjs, fastify, next, etc.
test_command: npx vitest run
lint_command: npx eslint . --max-warnings 0
type_check_command: npx tsc --noEmit
build_command: npm run build
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/health
```

---

## How Each Skill Applies to TypeScript

### THINK Phase

| Skill | TypeScript Adaptation |
|-------|----------------------|
| **think** | Design types and interfaces first. A TypeScript spec should define the shape of data before any logic. Include `interface` and `type` definitions in the spec. |
| **predict** | Expert panel evaluates type safety, runtime performance, and DX. Request panelists with TypeScript depth (e.g., library author, Node.js core contributor). |
| **scenario** | Explore edge cases around `null`, `undefined`, union types, generic constraints, and async error boundaries. |

### BUILD Phase

| Skill | TypeScript Adaptation |
|-------|----------------------|
| **plan** | Each task should specify which types/interfaces it introduces. File paths use `.ts` / `.tsx` extensions. Tasks should note whether they touch shared types in a `types/` directory. |
| **build** | TDD with Vitest or Jest. RED step writes a `.test.ts` file with type-safe mocks. GREEN step implements the module. REFACTOR step tightens types (remove `any`, add generics). |
| **test** | Use `describe`/`it` blocks. Mock external dependencies with `vi.mock()` or `jest.mock()`. Type-check test files — do not use `@ts-ignore` in tests. |
| **review** | Check for `any` usage, missing return types on exported functions, proper error typing, and consistent naming conventions. |

### OPTIMIZE Phase

| Skill | TypeScript Adaptation |
|-------|----------------------|
| **optimize** | Target bundle size (tree-shaking), startup time, or API response time. Verify with `tsc --noEmit` as a guard rail on every iteration. |
| **debug** | Use source maps for stack trace mapping. Check `tsconfig.json` compiler options when debugging unexpected behavior. |
| **fix** | Autonomous fix loop handles type errors, test failures, and lint violations. Guard rail: `tsc --noEmit` must exit 0. |
| **secure** | Audit `@types/*` packages for known vulnerabilities. Check for `eval()`, `Function()`, and `as any` casts that bypass type safety. |

### SHIP Phase

| Skill | TypeScript Adaptation |
|-------|----------------------|
| **ship** | Pre-flight: `tsc --noEmit && npm test && npm run build`. Verify the compiled output exists and the build artifact is valid. |
| **finish** | Ensure `.d.ts` declaration files are generated if shipping a library. Verify `exports` field in `package.json`. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Type coverage | `npx type-coverage --at-least 95` | >= 95% |
| Strict mode violations | `npx tsc --noEmit 2>&1 \| grep -c "error TS"` | 0 |
| Bundle size (server) | `du -b dist/index.js \| cut -f1` | Project-specific |
| Bundle size (frontend) | `npm run build && du -b dist/assets/*.js \| awk '{s+=$1}END{print s}'` | < 500KB |
| Test coverage | `npx vitest run --coverage \| grep 'All files' \| awk '{print $4}'` | >= 80% |
| Lint errors | `npx eslint . --max-warnings 0 2>&1 \| tail -1` | 0 errors, 0 warnings |
| Build time | `/usr/bin/time -l npm run build 2>&1 \| grep real` | Project-specific |
| `any` count | `grep -rn ': any' src/ --include='*.ts' \| wc -l` | 0 (or decreasing) |

---

## Common Verify Commands

### Tests pass
```bash
npx vitest run
# or
npx jest --ci
```

### Type check clean
```bash
npx tsc --noEmit
```

### Lint clean
```bash
npx eslint . --max-warnings 0
```

### Build succeeds
```bash
npm run build
```

### Bundle size under threshold
```bash
npm run build && du -b dist/assets/index-*.js | cut -f1
```

### No `any` in source
```bash
grep -rn ': any\b' src/ --include='*.ts' --include='*.tsx' | wc -l
```

### API responds
```bash
curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/health
```

---

## Tool Integration

### tsc (TypeScript Compiler)

Use `tsc --noEmit` as a guard rail in every optimization and build step.

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: npx tsc --noEmit
    expect: exit code 0
  - command: npx vitest run
    expect: exit code 0
```

**Strict mode** — always enable in `tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### ESLint

Recommended config for Godmode projects:
```bash
# Verify lint is clean (used as guard rail)
npx eslint . --max-warnings 0

# Auto-fix safe issues during refactor step
npx eslint . --fix
```

Key rules to enforce:
- `@typescript-eslint/no-explicit-any` — error
- `@typescript-eslint/explicit-function-return-type` — warn on exported functions
- `@typescript-eslint/no-unused-vars` — error
- `@typescript-eslint/strict-boolean-expressions` — warn

### Vitest / Jest

Godmode's TDD cycle maps directly to test runners:

```bash
# RED step: run single test file, expect failure
npx vitest run src/services/user.test.ts

# GREEN step: run single test, expect pass
npx vitest run src/services/user.test.ts

# After GREEN: run full suite to catch regressions
npx vitest run

# Coverage check
npx vitest run --coverage
```

**Vitest** is preferred for modern TypeScript projects (native ESM, fast HMR, Vite-powered). **Jest** works well with `ts-jest` or `@swc/jest` for transformation.

### esbuild / webpack / Vite

Build tool integration for the optimize loop:

```bash
# esbuild — measure bundle size
npx esbuild src/index.ts --bundle --minify --outfile=dist/bundle.js && du -b dist/bundle.js

# Vite — production build with size report
npx vite build && du -b dist/assets/*.js | awk '{s+=$1}END{print s}'

# webpack — analyze bundle
npx webpack --mode production --json > stats.json && npx webpack-bundle-analyzer stats.json --mode static
```

---

## Example: Full Workflow for Building a TypeScript API

### Scenario
Build a REST API for a task management system using Express.js with TypeScript.

### Step 1: Think (Design)
```
/godmode:think I need a REST API for task management — CRUD operations,
user assignment, status transitions, and due date tracking.
Use Express.js with TypeScript and Prisma ORM.
```

Godmode produces a spec at `docs/specs/task-api.md` containing:
- Interface definitions: `Task`, `User`, `TaskStatus`, `CreateTaskDTO`, `UpdateTaskDTO`
- Endpoint design: `GET /tasks`, `POST /tasks`, `PATCH /tasks/:id`, `DELETE /tasks/:id`
- Error handling strategy: typed error classes extending `AppError`
- Validation approach: Zod schemas derived from TypeScript types

### Step 2: Plan (Decompose)
```
/godmode:plan
```

Produces `docs/plans/task-api-plan.md` with tasks:
1. Define shared types and Zod schemas (`src/types/task.ts`)
2. Create Prisma schema and migration (`prisma/schema.prisma`)
3. Implement task repository with typed queries (`src/repositories/task.repository.ts`)
4. Implement task service with business logic (`src/services/task.service.ts`)
5. Implement task controller with validation (`src/controllers/task.controller.ts`)
6. Add error handling middleware (`src/middleware/error-handler.ts`)
7. Wire routes and add integration tests (`src/routes/task.routes.ts`)
8. Add OpenAPI documentation generation

### Step 3: Build (TDD)
```
/godmode:build
```

Each task follows RED-GREEN-REFACTOR:

**Task 1 — RED:**
```typescript
// src/types/task.test.ts
import { CreateTaskSchema } from './task';

describe('Task types', () => {
  it('validates a correct CreateTaskDTO', () => {
    const result = CreateTaskSchema.safeParse({
      title: 'Fix login bug',
      assigneeId: 'user-123',
      dueDate: '2025-03-15',
    });
    expect(result.success).toBe(true);
  });

  it('rejects a task without title', () => {
    const result = CreateTaskSchema.safeParse({ assigneeId: 'user-123' });
    expect(result.success).toBe(false);
  });
});
```
Commit: `test(red): Task types — failing Zod schema validation tests`

**Task 1 — GREEN:**
```typescript
// src/types/task.ts
import { z } from 'zod';

export const TaskStatus = z.enum(['TODO', 'IN_PROGRESS', 'DONE']);
export type TaskStatus = z.infer<typeof TaskStatus>;

export const CreateTaskSchema = z.object({
  title: z.string().min(1).max(255),
  description: z.string().optional(),
  assigneeId: z.string().uuid(),
  dueDate: z.string().datetime().optional(),
});
export type CreateTaskDTO = z.infer<typeof CreateTaskSchema>;
```
Commit: `feat: Task types — Zod schemas and TypeScript types`

**Task 1 — REFACTOR:** Add JSDoc comments, tighten string constraints.
Commit: `refactor: Task types — add JSDoc, stricter validation`

Parallel agents handle tasks 3, 4, and 5 concurrently (no shared file dependencies).

### Step 4: Optimize
```
/godmode:optimize --goal "reduce response time" --verify "curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/tasks" --target "< 0.05"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | N+1 query on task list | Add Prisma `include` for relations | 120ms | 68ms | KEEP |
| 2 | No response compression | Add `compression` middleware | 68ms | 52ms | KEEP |
| 3 | Prisma client instantiated per request | Singleton pattern | 52ms | 48ms | KEEP |
| 4 | JSON serialization overhead | Switch to `fast-json-stringify` | 48ms | 49ms | REVERT |

Final: 120ms to 48ms (60% improvement). Target met.

### Step 5: Secure
```
/godmode:secure
```

Findings:
- MEDIUM: No rate limiting on POST endpoints — add `express-rate-limit`
- LOW: `assigneeId` not validated against existing users — add FK check
- INFO: Consider adding Helmet.js for HTTP security headers

### Step 6: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
tsc --noEmit          ✓ 0 errors
npx vitest run        ✓ 34/34 passing
npx eslint .          ✓ 0 errors, 0 warnings
npm run build         ✓ dist/ generated
type-coverage         ✓ 97.2%
```

PR created with full description, optimization log, and security audit summary.

---

## TypeScript-Specific Tips

### 1. Types are your spec
In the THINK phase, define interfaces and types before anything else. They serve as executable documentation and make the PLAN phase more precise.

### 2. Use `strict: true` from day one
Turning on strict mode later is painful. Start strict. Godmode's fix loop can resolve strict-mode errors incrementally if you are migrating an existing project.

### 3. Track `any` count as a metric
Every `any` is a hole in your type safety. Use the optimize loop to reduce `any` count to zero:
```
/godmode:optimize --goal "eliminate any types" --verify "grep -rn ': any' src/ --include='*.ts' | wc -l" --target "0"
```

### 4. Use path aliases
Configure `tsconfig.json` paths to keep imports clean:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

### 5. Guard rails should include type checking
Always include `tsc --noEmit` as a guard rail in the optimize loop. Type regressions from optimization attempts are common and must be caught immediately.
