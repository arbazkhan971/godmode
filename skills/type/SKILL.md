---
name: type
description: >
  Type system and schema validation. Strict TypeScript,
  runtime validation (Zod), type narrowing,
  schema-first development.
---

# Type -- Type System & Schema Validation

## Activate When
- `/godmode:type`, "type safety", "TypeScript strict"
- "Zod", "runtime validation", "schema validation"
- Type errors are frequent or `any` is widespread
- API boundaries lack runtime validation

## Workflow

### Step 1: Type Safety Audit
```bash
# Count any/unknown usage
grep -rn ": any" --include="*.ts" --include="*.tsx" \
  src/ | wc -l
grep -rn "as any" --include="*.ts" --include="*.tsx" \
  src/ | wc -l
grep -rn "@ts-ignore" --include="*.ts" \
  --include="*.tsx" src/ | wc -l

# Check tsconfig strictness
grep -A20 '"compilerOptions"' tsconfig.json \
  | grep -E "strict|noImplicit|noUnchecked"
```
```
TYPE SAFETY AUDIT:
| Metric            | Value          |
|------------------|---------------|
| Strict mode      | ON/OFF/PARTIAL |
| `any` count      | {N} explicit   |
| `as any` casts   | {N}            |
| @ts-ignore       | {N} suppressed |
| Runtime validation| YES/NO         |
| Schema library   | Zod/Yup/none   |
| Safety Score     | {N}/100        |
| Grade            | A/B/C/D/F      |

Score thresholds:
  90-100 = A (strict, zero any, schemas)
  80-89 = B (strict, few any, some schemas)
  60-79 = C (partial strict, moderate any)
  40-59 = D (no strict, many any)
  0-39 = F (widespread any, no validation)
```

### Step 2: Strict Mode Configuration
```jsonc
// tsconfig.json — Maximum type safety
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "exactOptionalPropertyTypes": true
  }
}
```
#### Gradual Adoption
```
Phase 1 (Week 1-2): Foundation
  noImplicitAny + strictNullChecks
  + noImplicitReturns + useUnknownInCatchVariables
Phase 2 (Week 3-4): Functions
  strictFunctionTypes + strictBindCallApply
Phase 3 (Week 5-6): Full strict
  "strict": true + noUncheckedIndexedAccess
Phase 4 (Week 7-8): Schemas
  Add Zod at API boundaries

IF enabling flag produces >200 errors:
  enable one flag at a time, fix, commit, next
```

### Step 3: Schema Validation Selection
```
| Library  | Size   | Best For              |
|---------|--------|----------------------|
| Zod     | ~13KB  | TypeScript-first, API |
| Valibot | ~1KB   | Bundle-conscious      |
| Yup     | ~15KB  | React forms, Formik   |

IF TypeScript project + API validation: Zod
IF bundle size critical (<5KB budget): Valibot
IF existing Yup codebase: keep Yup
WHEN tRPC or React Hook Form: Zod (ecosystem)
```

### Step 4: Validation at Boundaries
```typescript
// Validate API requests with Zod middleware
import { z, ZodSchema } from 'zod';
export function validate<T>(schema: ZodSchema<T>) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        errors: result.error.flatten()
      });
    }
    req.body = result.data;
    next();
  };
}
```
```
VALIDATION BOUNDARIES:
  API request handler: VALIDATE (Zod middleware)
  External API response: VALIDATE (parse response)
  Database read: VALIDATE (if schema can drift)
  Environment variables: VALIDATE (at startup)
  Service layer: TRUST types (no re-validation)
  Internal functions: TRUST types
```

### Step 5: Schema-First Development
```
1. Write Zod schemas for domain entities
2. Infer types: type User = z.infer<typeof UserSchema>
3. Build logic using inferred types
4. Test with schema-generated data

NEVER write types and schemas separately.
Derive TypeScript type from Zod schema always.
```

### Step 6: Discriminated Unions
```typescript
// Make illegal states unrepresentable
type Order =
  | { status: 'draft'; items: Item[] }
  | { status: 'submitted'; items: Item[];
      submittedAt: Date }
  | { status: 'shipped'; items: Item[];
      trackingNumber: string };
// TypeScript narrows on status check
```

## Key Behaviors
1. **Classify first.** Strict mode, then schemas.
2. **Derive types from schemas.** One source.
3. **Validate at boundaries, trust internally.**
4. **Discriminated unions for state machines.**
5. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER write types and schemas separately.
2. NEVER use `as` casts to silence errors.
3. NEVER use `any`. Use `unknown` instead.
4. NEVER use @ts-ignore. Use @ts-expect-error.
5. ALWAYS enable noUncheckedIndexedAccess.
6. ALWAYS validate at boundary, trust internally.
7. NEVER validate same data at every function.
8. ALWAYS enable strict: true in tsconfig.

## Auto-Detection
```bash
ls tsconfig.json tsconfig.*.json 2>/dev/null
grep -c ": any\|as any" --include="*.ts" -r src/
grep -E "zod|yup|joi|valibot" package.json 2>/dev/null
```

## TSV Logging
Log to `.godmode/type-results.tsv`:
`phase\taction\tany_before\tany_after\terrors_fixed\tscore\tstatus`

## Quality Targets
- Target: 0 TypeScript errors (strict mode enabled)
- Target: <30s type-check time for full project
- Target: <5% any-typed values in codebase

## Output Format
Print: `Type: score {before} -> {after}/100. any: {N} -> {N}. Strict: {status}. Schemas: {N}.`

## Keep/Discard Discipline
```
KEEP if: tsc passes AND tests pass
  AND any count decreased
DISCARD if: tsc errors increase OR tests fail
  OR auto-fix changed runtime behavior
```

## Stop Conditions
```
STOP when:
  - strict: true enabled
  - any count at zero (or reduction plan)
  - Runtime validation at all API boundaries
  - Score >= 80/100
  - User requests stop
```
