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
```

```
TYPE SAFETY AUDIT:
  Project: <name>
  Language: TypeScript <version>
| Strict mode | <ON/OFF/PARTIAL> |
|--|--|
| `any` count | <N> explicit + <N> `as any` casts |
| @ts-ignore | <N> suppressed type errors |
| Untyped params | <N> function parameters without types |
| Runtime validation | <YES/NO> at API boundaries |
| Schema library | <Zod/Yup/Joi/none> |
| Type coverage | <N%> of expressions have known types |
  Type Safety Score: <N>/100
  Grade: <A | B | C | D | F>
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

```

#### Gradual Typing Strategy (Existing Projects)
For projects migrating from loose TypeScript or JavaScript:

```
GRADUAL STRICTNESS ADOPTION:
Phase 1: Foundation (Week 1-2)
  Enable these first (low disruption, high value):
  "noImplicitAny": true           — force type annotations
  "strictNullChecks": true        — catch null/undefined
  "noImplicitReturns": true       — complete return types
  "useUnknownInCatchVariables": true — safe error handling

Phase 2: Functions (Week 3-4)
  "strictFunctionTypes": true      — contravariant params
  "strictBindCallApply": true      — correct bind/call
  "noFallthroughCasesInSwitch": true
```

#### Eliminating `any`
Common `any` patterns and their typed replacements:

```typescript
// PATTERN 1: Unknown API responses
// BAD
const data: any = await fetch('/api/users').then(r => r.json());

// GOOD — validate at the boundary
const data = await fetch('/api/users').then(r => r.json());
```

### Step 3: Schema Validation Library Selection
Choose and configure runtime validation:

```
SCHEMA VALIDATION COMPARISON:
| Library | Characteristics |
|--|--|
| Zod | TypeScript-first, infers types from schemas |
|  | Bundle: ~13KB min+gzip |
|  | Best for: TypeScript projects, API validation |
|  | Strengths: Type inference, transforms, refinements |
|  | Ecosystem: tRPC, React Hook Form, Astro |
| Yup | Mature, widely adopted, React ecosystem |
|  | Bundle: ~15KB min+gzip |
|  | Best for: Formik/React forms, existing Yup codebases |
|  | Strengths: Conditional validation, localization |
```

#### Validation at API Boundaries
```typescript
// src/middleware/validate.ts
import { z, ZodSchema } from 'zod';
import { Request, Response, NextFunction } from 'express';

export function validate<T>(schema: ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
```

#### Environment Variable Validation
```typescript
// src/config/env.ts
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
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
```

#### Result Types (Error Handling Without Exceptions)
```typescript
// ─── Result Type ─────────────────────────────────────────────
type Result<T, E = Error> =
### Step 6: Runtime Type Checking Strategy
Define where and how to validate at runtime:

```
RUNTIME VALIDATION BOUNDARIES:
  EXTERNAL WORLD (untrusted)
  ▼
|  | API Request Handler | ← VALIDATE HERE (Zod middleware) |
  └──────────┬───────────┘
|  | (validated, typed data) |
  ▼
|  | Service Layer | ← Trust types, no re-validation |
  └──────────┬───────────┘
  ▼
### Step 7: Schema-First Development Workflow
Design the data model before writing business logic:

```
SCHEMA-FIRST WORKFLOW:
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
| 1. Define | ────▶ | 2. Infer | ────▶ | 3. Build | ────▶ | 4. Test |
|--|--|--|--|--|--|---|
| Schemas |  | Types |  | Logic |  | Against |
| (Zod) |  | (z.infer) |  | (typed) |  | Schema |
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
9. **Never ask to continue. Loop autonomously until type safety score >= 80 or budget exhausted.**

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
- **Runtime validation is too slow**: Use `schema.parse()` only at boundaries. Inside service functions, trust the types. For hot paths, use `schema.safeParse()` with early return instead of try/catch.
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

DO NOT STOP only because:
  - `any` types exist in third-party type definitions (those are not your code)
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

