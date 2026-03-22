---
name: type
description: |
  Type system and schema validation skill. Activates when the user needs to strengthen type safety, configure strict TypeScript, set up runtime validation with Zod/Yup/Joi, or adopt schema-first development patterns. Covers TypeScript strict mode configuration and gradual typing strategies, runtime schema validation library selection and setup, type narrowing and discriminated unions, runtime type checking at API boundaries, and schema-first development workflows. Every type improvement is justified by the bugs it prevents. Triggers on: /godmode:type, "type safety", "TypeScript strict", "schema validation", "Zod", "runtime types", "type narrowing", or when type errors indicate a systemic type safety gap.
---

# Type — Type System & Schema Validation

## When to Activate
- User invokes `/godmode:type`
- User says "type safety", "TypeScript strict mode", "add types"
- User asks about "Zod", "Yup", "Joi", "runtime validation"
- User wants "schema validation", "type narrowing", "discriminated unions"
- Type errors are frequent or `any` type is widespread
- API boundaries lack runtime validation
- Migrating from JavaScript to TypeScript
- Schema-first development for a new project

## Workflow

### Step 1: Type Safety Audit
Assess the current state of type safety:

```bash
# Count any/unknown usage
grep -rn ": any" --include="*.ts" --include="*.tsx" | wc -l
grep -rn "as any" --include="*.ts" --include="*.tsx" | wc -l

# Check tsconfig strictness
grep -A20 '"compilerOptions"' tsconfig.json | grep -E "strict|noImplicit|noUnchecked"

# Find untyped function parameters
grep -rn "function.*([a-zA-Z_][a-zA-Z0-9_]*)" --include="*.ts" | grep -v ":"

# Check for @ts-ignore / @ts-expect-error
grep -rn "@ts-ignore\|@ts-expect-error" --include="*.ts" --include="*.tsx" | wc -l
```

```
TYPE SAFETY AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  Project: <name>                                              │
│  Language: TypeScript <version>                               │
├──────────────────┬───────────────────────────────────────────┤
│  Strict mode      │ <ON/OFF/PARTIAL>                          │
│  `any` count      │ <N> explicit + <N> `as any` casts         │
│  @ts-ignore       │ <N> suppressed type errors                │
│  Untyped params   │ <N> function parameters without types     │
│  Runtime validation│ <YES/NO> at API boundaries               │
│  Schema library   │ <Zod/Yup/Joi/none>                        │
│  Type coverage    │ <N%> of expressions have known types       │
├──────────────────┴───────────────────────────────────────────┤
│  Type Safety Score: <N>/100                                   │
│  Grade: <A | B | C | D | F>                                   │
│                                                               │
│  A (90-100): Strict mode, zero any, runtime validation        │
│  B (70-89):  Mostly strict, few any, some validation          │
│  C (50-69):  Partial strict, moderate any, no validation      │
│  D (30-49):  No strict, widespread any, no validation         │
│  F (0-29):   Effectively untyped TypeScript                   │
└──────────────────────────────────────────────────────────────┘
```

### Step 2: TypeScript Strict Mode Configuration
Enable full strict mode or adopt it gradually:

#### Full Strict Mode (New Projects)
```jsonc
// tsconfig.json — Maximum type safety
{
  "compilerOptions": {
    // Strict family (all enabled by "strict": true)
    "strict": true,
    //   includes:
    //   "noImplicitAny": true,
    //   "strictNullChecks": true,
    //   "strictFunctionTypes": true,
    //   "strictBindCallApply": true,
    //   "strictPropertyInitialization": true,
    //   "noImplicitThis": true,
    //   "useUnknownInCatchVariables": true,
    //   "alwaysStrict": true,

    // Additional strict checks (not included in "strict")
    "noUncheckedIndexedAccess": true,      // arr[0] is T | undefined
    "noImplicitReturns": true,             // all code paths must return
    "noFallthroughCasesInSwitch": true,    // switch cases must break
    "noImplicitOverride": true,            // override keyword required
    "exactOptionalPropertyTypes": true,    // undefined !== optional
    "noPropertyAccessFromIndexSignature": true, // bracket notation for index sigs
    "noUnusedLocals": true,
    "noUnusedParameters": true,

    // Module resolution
    "moduleResolution": "bundler",
    "module": "ESNext",
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],

    // Output
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  }
}
```

#### Gradual Typing Strategy (Existing Projects)
For projects migrating from loose TypeScript or JavaScript:

```
GRADUAL STRICTNESS ADOPTION:
Phase 1: Foundation (Week 1-2)
  ┌──────────────────────────────────────────────────────────┐
  │  Enable these first (low disruption, high value):         │
  │  "noImplicitAny": true           — force type annotations │
  │  "strictNullChecks": true        — catch null/undefined   │
  │  "noImplicitReturns": true       — complete return types  │
  │  "useUnknownInCatchVariables": true — safe error handling │
  └──────────────────────────────────────────────────────────┘

Phase 2: Functions (Week 3-4)
  ┌──────────────────────────────────────────────────────────┐
  │  "strictFunctionTypes": true      — contravariant params  │
  │  "strictBindCallApply": true      — correct bind/call     │
  │  "noFallthroughCasesInSwitch": true                       │
  └──────────────────────────────────────────────────────────┘

Phase 3: Full Strict (Week 5-6)
  ┌──────────────────────────────────────────────────────────┐
  │  Replace all individual flags with:                       │
  │  "strict": true                                           │
  │                                                           │
  │  Then add extra strictness:                               │
  │  "noUncheckedIndexedAccess": true                         │
  │  "exactOptionalPropertyTypes": true                       │
  └──────────────────────────────────────────────────────────┘

Phase 4: Zero Any (Ongoing)
  ┌──────────────────────────────────────────────────────────┐
  │  ESLint: "@typescript-eslint/no-explicit-any": "error"    │
  │  Track: any count should decrease every sprint            │
  │  Goal: 0 explicit any, 0 as any casts                     │
  └──────────────────────────────────────────────────────────┘
```

#### Eliminating `any`
Common `any` patterns and their typed replacements:

```typescript
// PATTERN 1: Unknown API responses
// BAD
const data: any = await fetch('/api/users').then(r => r.json());

// GOOD — validate at the boundary
const data = await fetch('/api/users').then(r => r.json());
const users = UserArraySchema.parse(data); // Zod validation

// PATTERN 2: Generic event handlers
// BAD
function handleEvent(event: any) { ... }

// GOOD — use the correct event type
function handleEvent(event: React.ChangeEvent<HTMLInputElement>) { ... }

// PATTERN 3: Dynamic object keys
// BAD
const config: any = {};

// GOOD — use Record or index signature
const config: Record<string, string> = {};
// or more specific:
const config: { [K in ConfigKey]: string } = {};

// PATTERN 4: Third-party library without types
// BAD
const result: any = legacyLib.doSomething();

// GOOD — create a declaration file
// src/types/legacy-lib.d.ts
declare module 'legacy-lib' {
  export function doSomething(): Result;
  interface Result {
    value: string;
    status: number;
  }
}

// PATTERN 5: JSON.parse
// BAD
const parsed: any = JSON.parse(rawString);

// GOOD — validate after parsing
const parsed: unknown = JSON.parse(rawString);
const validated = MySchema.parse(parsed);
```

### Step 3: Schema Validation Library Selection
Choose and configure runtime validation:

```
SCHEMA VALIDATION COMPARISON:
┌──────────────┬───────────────────────────────────────────────────────┐
│  Library      │ Characteristics                                       │
├──────────────┼───────────────────────────────────────────────────────┤
│  Zod          │ TypeScript-first, infers types from schemas           │
│               │ Bundle: ~13KB min+gzip                                │
│               │ Best for: TypeScript projects, API validation          │
│               │ Strengths: Type inference, transforms, refinements    │
│               │ Ecosystem: tRPC, React Hook Form, Astro               │
├──────────────┼───────────────────────────────────────────────────────┤
│  Yup          │ Mature, widely adopted, React ecosystem               │
│               │ Bundle: ~15KB min+gzip                                │
│               │ Best for: Formik/React forms, existing Yup codebases  │
│               │ Strengths: Conditional validation, localization       │
├──────────────┼───────────────────────────────────────────────────────┤
│  Joi          │ Feature-rich, Hapi ecosystem                          │
│               │ Bundle: ~30KB min+gzip (heavy)                        │
│               │ Best for: Node.js backends, complex validation        │
│               │ Strengths: Most validation rules, detailed errors     │
├──────────────┼───────────────────────────────────────────────────────┤
│  Valibot      │ Modular, tree-shakeable, tiny bundle                  │
│               │ Bundle: ~1-5KB (only what you use)                    │
│               │ Best for: Bundle-sensitive apps, Zod alternative      │
│               │ Strengths: Smallest bundle, Zod-compatible API        │
├──────────────┼───────────────────────────────────────────────────────┤
│  ArkType      │ Runtime-optimized, TypeScript syntax                  │
│               │ Bundle: ~20KB min+gzip                                │
### Step 4: Schema-First Development with Zod
Define schemas that serve as both runtime validators and TypeScript types:

#### Core Schema Patterns
```typescript
import { z } from 'zod';

// ─── Primitive Schemas ───────────────────────────────────────
const Email = z.string().email().toLowerCase().brand<'Email'>();
const UserId = z.string().uuid().brand<'UserId'>();
const NonEmptyString = z.string().min(1).max(1000);
const PositiveInt = z.number().int().positive();
const DateString = z.string().datetime();

// ─── Domain Schemas ──────────────────────────────────────────
const UserSchema = z.object({
  id: UserId,
  email: Email,
  name: NonEmptyString,
  role: z.enum(['admin', 'member', 'viewer']),
  createdAt: DateString,
  metadata: z.record(z.string(), z.unknown()).optional(),
});

// Infer the TypeScript type FROM the schema
type User = z.infer<typeof UserSchema>;
// Result:
// type User = {
//   id: string & BRAND<"UserId">;
//   email: string & BRAND<"Email">;
//   name: string;
//   role: "admin" | "member" | "viewer";
//   createdAt: string;
//   metadata?: Record<string, unknown> | undefined;
// }

// ─── Request/Response Schemas ────────────────────────────────
const CreateUserRequest = UserSchema.omit({ id: true, createdAt: true });
const UpdateUserRequest = UserSchema.partial().omit({ id: true, createdAt: true });
const UserResponse = UserSchema.extend({
  _links: z.object({
    self: z.string().url(),
    posts: z.string().url(),
  }),
});

type CreateUserRequest = z.infer<typeof CreateUserRequest>;
type UpdateUserRequest = z.infer<typeof UpdateUserRequest>;
type UserResponse = z.infer<typeof UserResponse>;
```

#### Validation at API Boundaries
```typescript
// src/middleware/validate.ts
import { z, ZodSchema } from 'zod';
import { Request, Response, NextFunction } from 'express';

export function validate<T>(schema: ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        error: 'VALIDATION_ERROR',
        message: 'Request body validation failed',
        details: result.error.issues.map(issue => ({
          path: issue.path.join('.'),
          message: issue.message,
          code: issue.code,
          expected: 'expected' in issue ? issue.expected : undefined,
          received: 'received' in issue ? issue.received : undefined,
        })),
      });
    }
    req.body = result.data; // Replace with validated + transformed data
    next();
  };
}

// Usage in routes
router.post('/users', validate(CreateUserRequest), createUserHandler);
router.patch('/users/:id', validate(UpdateUserRequest), updateUserHandler);
```

#### Environment Variable Validation
```typescript
// src/config/env.ts
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  DATABASE_URL: z.string().url().startsWith('postgres://'),
  REDIS_URL: z.string().url().startsWith('redis://'),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  API_KEY: z.string().min(1),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  CORS_ORIGINS: z.string().transform(s => s.split(',')).pipe(z.array(z.string().url())),
});

export type Env = z.infer<typeof EnvSchema>;

function validateEnv(): Env {
  const result = EnvSchema.safeParse(process.env);
  if (!result.success) {
    console.error('Environment validation failed:');
    for (const issue of result.error.issues) {
      console.error(`  ${issue.path.join('.')}: ${issue.message}`);
    }
    console.error('\nCheck .env.example for required variables.');
    process.exit(1);
  }
  return result.data;
}

export const env = validateEnv();
```

### Step 5: Type Narrowing & Discriminated Unions
Use the type system to make illegal states unrepresentable:

#### Discriminated Unions
```typescript
// ─── State Machines as Types ─────────────────────────────────
// BAD: All fields optional, any combination possible
interface Order {
  id: string;
  status: string;
  items: Item[];
  shippingAddress?: Address;
  trackingNumber?: string;
  cancelReason?: string;
  deliveredAt?: Date;
}

// GOOD: Each state explicitly declares its fields
type Order =
  | { status: 'draft'; id: string; items: Item[] }
  | { status: 'placed'; id: string; items: Item[]; shippingAddress: Address }
  | { status: 'shipped'; id: string; items: Item[]; shippingAddress: Address; trackingNumber: string }
  | { status: 'delivered'; id: string; items: Item[]; shippingAddress: Address; trackingNumber: string; deliveredAt: Date }
  | { status: 'cancelled'; id: string; items: Item[]; cancelReason: string };

// TypeScript narrows the type based on status check
function processOrder(order: Order) {
  switch (order.status) {
    case 'draft':
      // TypeScript knows: no shippingAddress, no trackingNumber
      return { canEdit: true, canShip: false };
    case 'placed':
      // TypeScript knows: shippingAddress exists
      return { canEdit: false, canShip: true, address: order.shippingAddress };
    case 'shipped':
      // TypeScript knows: trackingNumber exists
      return { canTrack: true, tracking: order.trackingNumber };
    case 'delivered':
      // TypeScript knows: deliveredAt exists
      return { complete: true, deliveredAt: order.deliveredAt };
    case 'cancelled':
      // TypeScript knows: cancelReason exists
      return { cancelled: true, reason: order.cancelReason };
  }
}
```

#### Result Types (Error Handling Without Exceptions)
```typescript
// ─── Result Type ─────────────────────────────────────────────
type Result<T, E = Error> =
### Step 6: Runtime Type Checking Strategy
Define where and how to validate at runtime:

```
RUNTIME VALIDATION BOUNDARIES:
┌──────────────────────────────────────────────────────────────┐
│                                                               │
│  EXTERNAL WORLD (untrusted)                                   │
│    │                                                          │
│    ▼                                                          │
│  ┌──────────────────────┐                                     │
│  │  API Request Handler  │ ← VALIDATE HERE (Zod middleware)    │
│  └──────────┬───────────┘                                     │
│             │ (validated, typed data)                          │
│             ▼                                                  │
│  ┌──────────────────────┐                                     │
│  │  Service Layer        │ ← Trust types, no re-validation     │
│  └──────────┬───────────┘                                     │
│             │                                                  │
│             ▼                                                  │
│  ┌──────────────────────┐                                     │
### Step 7: Schema-First Development Workflow
Design the data model before writing business logic:

```
SCHEMA-FIRST WORKFLOW:
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ 1. Define │────▶│ 2. Infer │────▶│ 3. Build │────▶│ 4. Test  │
│  Schemas  │     │  Types   │     │  Logic   │     │  Against │
│ (Zod)     │     │ (z.infer)│     │ (typed)  │     │  Schema  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘

Step 1: Write Zod schemas for all domain entities
Step 2: Infer TypeScript types (never write types manually)
Step 3: Build business logic using inferred types
Step 4: Test with schema-generated test data (faker + schema)
```

```typescript
// schemas/user.schema.ts — SINGLE SOURCE OF TRUTH
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['admin', 'member', 'viewer']),
### Step 8: Commit and Transition
1. Commit tsconfig changes: `"type: <project> — enable TypeScript strict mode (<phase>)"`
2. Commit schema library: `"type: <project> — add Zod schemas for <domain>"`
3. Commit any elimination: `"type: <project> — replace <N> any types with proper types"`
4. Commit validation middleware: `"type: <project> — add runtime validation at API boundaries"`
5. Commit branded types: `"type: <project> — add branded types for domain identifiers"`

## Key Behaviors

1. **Schema is the single source of truth.** Never write TypeScript types manually when you can infer them from a Zod schema. One schema generates the type, the validator, and the test factory.
2. **Validate at boundaries, trust within.** Every piece of external data (API requests, database reads, third-party responses) gets validated. Internal function calls trust the type system.
3. **Strict mode is non-negotiable for new projects.** The only reason to not use strict mode is migrating an existing codebase gradually.
4. **Any is a bug.** Every `any` type is a hole in your type safety. Track `any` count as a metric. Drive it to zero.
5. **Make illegal states unrepresentable.** Use discriminated unions to ensure that invalid combinations of data cannot exist at the type level.
6. **Types prevent bugs, schemas prevent crashes.** TypeScript catches bugs at compile time. Zod catches invalid data at runtime. You need both.

## Example Usage

### Enabling strict TypeScript on an existing project
```
User: /godmode:type Our TypeScript project has 340 any types and no strict mode

Type: Running type safety audit...

TYPE SAFETY AUDIT:
  Strict mode: OFF (only noImplicitAny partially enabled)
  any count: 287 explicit + 53 as any = 340 total
  @ts-ignore: 23 suppressed errors
  Runtime validation: NONE
  Type Safety Score: 22/100 (Grade: F)

GRADUAL STRICTNESS PLAN:
Phase 1 (Week 1): Enable noImplicitAny + strictNullChecks
  → Fixed 89 type errors, replaced 62 any types
  → Commit: "type: enable noImplicitAny and strictNullChecks"

Phase 2 (Week 2): Enable strictFunctionTypes + strictBindCallApply
  → Fixed 34 type errors
  → Commit: "type: enable function type strictness"

Phase 3 (Week 3): Enable full strict mode
  → Fixed 28 remaining type errors
  → Commit: "type: enable full strict mode"

Phase 4 (Ongoing): Eliminate remaining 216 any types
  → Priority: API handlers (67 any), utils (45 any), services (34 any)

AFTER Phase 1:
  Type Safety Score: 22 → 48/100 (Grade: D → C)
  any count: 340 → 278 (-18%)
```

### Setting up Zod for an API
```
User: /godmode:type Set up runtime validation for our Express API

Type: Analyzing API endpoints...

ANALYSIS:
  Endpoints: 24
  With validation: 0
  Request bodies: 18 (all unvalidated — any data accepted)
  Vulnerability: HIGH (any JSON payload is trusted)

SETUP:
  1. Created Zod schemas for all 12 domain entities
  2. Derived request/response schemas from entity schemas
  3. Created validate() middleware
  4. Applied to all 18 endpoints with request bodies
  5. Added env validation for startup

RESULT:
  Validated endpoints: 0 → 24
  Type-inferred request types: 0 → 18
  Invalid requests now return structured 400 errors
  Runtime safety: NONE → FULL
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full type safety audit and improvement plan |
| `--audit` | Audit type safety score without making changes |
| `--strict` | Enable TypeScript strict mode (gradual if existing project) |
| `--schemas` | Generate Zod schemas for domain entities |
| `--validate` | Add runtime validation at API boundaries |
| `--eliminate-any` | Remove any types with proper replacements |
| `--branded` | Add branded types for domain identifiers |
| `--migrate <lib>` | Migrate between validation libraries |
| `--env` | Add environment variable validation |
| `--factory` | Generate test data factories from schemas |

## Auto-Detection
On activation, detect type safety context automatically:
```
AUTO-DETECT:
1. Check for TypeScript config:
   - ls tsconfig.json tsconfig.*.json
   - Parse compilerOptions for strict flags
2. Count any/unknown usage:
   - grep for ": any", "as any", "@ts-ignore", "@ts-expect-error"
3. Detect schema validation library:
   - package.json → zod, yup, joi, valibot, arktype, io-ts
4. Detect existing schemas:
   - src/schemas/, src/types/, src/validation/
5. Detect API framework:
   - Express, Fastify, Koa, Hono → check for validation middleware
6. Detect runtime:
   - package.json type field, tsconfig module/target settings
7. Set: TYPE SAFETY AUDIT with detected values, proceed to Step 1.
```

## HARD RULES

1. **NEVER write types and schemas separately.** Derive the TypeScript type from the Zod/Valibot schema. Separate definitions will drift apart.
2. **NEVER use `as` casts to silence errors.** `as unknown as User` is not type safety -- it is hiding bugs. Fix the actual type mismatch.
3. **NEVER use `any`.** Use `unknown` instead. `unknown` requires narrowing; `any` bypasses all checking.
4. **NEVER use `@ts-ignore`.** Use `@ts-expect-error` only for genuine compiler limitations, with a comment explaining why.
5. **ALWAYS enable `noUncheckedIndexedAccess`.** Without it, `array[0]` returns `T` instead of `T | undefined`. This single flag catches the most real bugs.
6. **ALWAYS validate at the boundary, trust types internally.** Validate in API handlers and database reads. Inside service functions, the types are the contract.
7. **NEVER validate the same data at every function call.** Validate once at the boundary, then trust the type system downstream.
8. **ALWAYS enable `strict: true` in tsconfig.** Non-strict TypeScript is a false sense of safety.

## Iteration Protocol

For large-scale type safety improvements across a codebase:

```
current_phase = 0
phases = [audit, strict_mode, eliminate_any, add_schemas, add_validation, add_branded_types]

WHILE current_phase < len(phases):
  phase = phases[current_phase]
  1. Identify all files affected by this phase
  2. Apply changes (enable flags, replace types, add schemas)
  3. Run type checker -- fix all new errors
  4. Run test suite -- confirm no regressions
  current_phase += 1
  Report: "Type safety phase {current_phase}/{len(phases)}: {phase} -- {errors_fixed} errors resolved"

AFTER all phases:
  Calculate final type safety score
  Report improvement delta
```

## Output Format
Print on completion: `Type: safety score {before}/100 → {after}/100 (grade: {grade}). any count: {before_any} → {after_any}. Strict mode: {strict_status}. Runtime validation: {validation_status}. Schemas: {schema_count}.`

## TSV Logging
Log every type safety phase to `.godmode/type-results.tsv`:
```
phase	action	any_before	any_after	errors_fixed	tests_pass	safety_score	status
1	strict_null_checks	340	278	89	yes	48	improved
2	strict_function_types	278	244	34	yes	58	improved
3	full_strict	244	216	28	yes	68	improved
4	zod_schemas	216	180	36	yes	78	improved
```
Columns: phase, action, any_before, any_after, errors_fixed, tests_pass, safety_score, status(improved/blocked/regressed).

## Success Criteria
- TypeScript strict mode fully enabled (`"strict": true` plus `noUncheckedIndexedAccess`).
- Zero `any` types (or a documented reduction plan with sprint-level targets).
- Zero `@ts-ignore` directives (replaced with `@ts-expect-error` where genuinely needed).
- Runtime validation at all API boundaries (request handlers, database reads, external API responses).
- Schema library (Zod/Valibot) as single source of truth for domain types.
- All tests pass after each strictness phase (no regressions).
- Type safety score >= 80/100 (grade B or above).

## Error Recovery
- **Enabling strict flag produces hundreds of errors**: Do not enable all flags at once. Follow the gradual adoption phases (Phase 1-4). Enable one flag, fix errors, commit, then proceed to the next flag.
- **Third-party library lacks types**: Check DefinitelyTyped (`@types/library-name`). If not available, create a minimal `.d.ts` declaration file in `src/types/`. Do not use `any` as a workaround.
- **Zod schema and existing type diverge**: Delete the manually written TypeScript interface. Use `z.infer<typeof Schema>` as the single source of truth. Never maintain both.
- **Runtime validation is too slow**: Use `schema.parse()` only at boundaries. Inside service functions, trust the types. For hot paths, consider `schema.safeParse()` with early return instead of try/catch.
- **`noUncheckedIndexedAccess` produces too many errors**: Add explicit undefined checks where needed. Use `Array.at()` for safer access. Do not disable the flag — the errors it surfaces are real bugs.
- **Auto-fix changes semantics**: Review all `as` casts and type assertions after fixing. Run the full test suite. If behavior changes, the previous code was relying on incorrect types.

## Keep/Discard Discipline
```
After EACH type safety phase:
  1. MEASURE: Run tsc — how many errors remain? Run test suite — all passing?
  2. COMPARE: Is the type safety score higher than before? Did `any` count decrease?
  3. DECIDE:
     - KEEP if: type checker passes AND tests pass AND any count decreased
     - DISCARD if: type checker errors increase OR tests fail OR auto-fix changed runtime behavior
  4. COMMIT kept changes. Revert discarded changes before the next phase.

Never keep a type fix that changes runtime behavior — types should only affect compile-time safety.
```

## Stuck Recovery
```
IF >3 consecutive phases produce type errors that cannot be resolved:
  1. Check for third-party library type issues: install @types/library-name or create a minimal .d.ts file.
  2. Use `@ts-expect-error` (not `@ts-ignore`) with an explanation as a temporary workaround.
  3. Isolate the problematic module: enable strict mode project-wide but use path-specific overrides for the stuck module.
  4. If still stuck → log stop_reason=stuck, document the unresolvable type issues, move to the next phase.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - TypeScript strict mode fully enabled
  - `any` count at zero (or on a documented reduction trajectory with sprint targets)
  - Runtime validation at all API boundaries
  - Type safety score >= 80/100
  - User explicitly requests stop

DO NOT STOP just because:
  - Some `any` types are in third-party type definitions (those are not your code)
  - `@ts-expect-error` is used for genuine compiler limitations (document each one)
```

## Simplicity Criterion
```
PREFER the simpler type approach:
  - Zod (single library for types + validation) over separate TypeScript interfaces + Joi
  - z.infer<typeof Schema> over manually duplicated types
  - Discriminated unions over class hierarchies for variant types
  - unknown over any (always — unknown is safe, any is not)
  - Built-in TypeScript utility types (Pick, Omit, Partial) over custom type gymnastics
  - Validate once at the boundary, trust types internally — do not over-validate
```

## Multi-Agent Dispatch
For large-scale type safety improvements across a codebase:
```
DISPATCH parallel agents (one per phase):

Agent 1 (worktree: type-strict):
  - Enable strict mode flags incrementally
  - Fix all resulting type errors
  - Scope: tsconfig.json + all .ts/.tsx files
  - Output: Strict tsconfig + fixed type errors

Agent 2 (worktree: type-schemas):
  - Create Zod schemas for all domain entities
  - Derive types from schemas (z.infer)
  - Scope: src/schemas/, src/types/
  - Output: Schema library + inferred types

## Platform Fallback
Run tasks sequentially with branch isolation if `Agent()` or `EnterWorktree` unavailable. See `adapters/shared/sequential-dispatch.md`.