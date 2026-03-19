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
│               │ Best for: Performance-critical validation              │
│               │ Strengths: Fastest runtime, TypeScript-like syntax    │
├──────────────┼───────────────────────────────────────────────────────┤
│  io-ts        │ Functional programming style, fp-ts ecosystem         │
│               │ Bundle: ~5KB min+gzip                                 │
│               │ Best for: FP codebases, Either-based error handling   │
│               │ Strengths: Composable, functional patterns            │
└──────────────┴───────────────────────────────────────────────────────┘

RECOMMENDATION DECISION TREE:
  New TypeScript project?
    YES → Zod (best type inference, largest ecosystem)
  Bundle size critical (< 5KB budget)?
    YES → Valibot (tree-shakeable, modular)
  Using Formik for forms?
    YES → Yup (native Formik integration)
  Node.js backend with complex rules?
    YES → Joi (most validation rules) or Zod (better TypeScript)
  FP codebase with fp-ts?
    YES → io-ts (native Either, composable)
```

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
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage
type UserError =
  | { code: 'NOT_FOUND'; userId: string }
  | { code: 'INVALID_EMAIL'; email: string }
  | { code: 'DUPLICATE'; field: string; value: string };

async function createUser(input: CreateUserRequest): Promise<Result<User, UserError>> {
  const existing = await db.users.findByEmail(input.email);
  if (existing) {
    return err({ code: 'DUPLICATE', field: 'email', value: input.email });
  }

  const user = await db.users.create(input);
  return ok(user);
}

// Caller must handle both cases
const result = await createUser(input);
if (result.ok) {
  // TypeScript knows: result.value is User
  return res.status(201).json(result.value);
} else {
  // TypeScript knows: result.error is UserError
  switch (result.error.code) {
    case 'NOT_FOUND':
      return res.status(404).json({ error: result.error.userId });
    case 'INVALID_EMAIL':
      return res.status(400).json({ error: result.error.email });
    case 'DUPLICATE':
      return res.status(409).json({ error: `${result.error.field} already exists` });
  }
}
```

#### Type Guard Functions
```typescript
// ─── Type Guards ─────────────────────────────────────────────
// Custom type guards for runtime narrowing
function isUser(value: unknown): value is User {
  return UserSchema.safeParse(value).success;
}

function isApiError(error: unknown): error is { code: string; message: string } {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    'message' in error &&
    typeof (error as Record<string, unknown>).code === 'string' &&
    typeof (error as Record<string, unknown>).message === 'string'
  );
}

// Assertion functions (TypeScript 3.7+)
function assertDefined<T>(value: T | null | undefined, name: string): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(`Expected ${name} to be defined, got ${value}`);
  }
}

// Usage
const user = await db.users.find(id);
assertDefined(user, `user with id ${id}`);
// TypeScript knows: user is User (not User | null)
console.log(user.name); // safe
```

#### Branded Types for Domain Safety
```typescript
// ─── Branded Types ───────────────────────────────────────────
// Prevent mixing up primitive types that represent different things

declare const __brand: unique symbol;
type Brand<T, B> = T & { [__brand]: B };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;
type Email = Brand<string, 'Email'>;
type Cents = Brand<number, 'Cents'>;
type Dollars = Brand<number, 'Dollars'>;

// Constructor functions with validation
function UserId(value: string): UserId {
  if (!value.match(/^usr_[a-z0-9]{20}$/)) {
    throw new Error(`Invalid UserId format: ${value}`);
  }
  return value as UserId;
}

function Cents(value: number): Cents {
  if (!Number.isInteger(value) || value < 0) {
    throw new Error(`Cents must be a non-negative integer, got ${value}`);
  }
  return value as Cents;
}

// Now TypeScript prevents accidental mixing
function getUser(id: UserId): Promise<User> { ... }
function getOrder(id: OrderId): Promise<Order> { ... }

const userId = UserId('usr_abc123...');
const orderId = OrderId('ord_xyz789...');

getUser(userId);   // OK
getUser(orderId);  // TYPE ERROR: OrderId is not assignable to UserId
```

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
│  │  Database Layer       │ ← VALIDATE on read (untrusted data) │
│  └──────────┬───────────┘                                     │
│             │                                                  │
│             ▼                                                  │
│  ┌──────────────────────┐                                     │
│  │  External API Client  │ ← VALIDATE responses (untrusted)    │
│  └──────────────────────┘                                     │
│                                                               │
│  RULE: Validate at boundaries, trust within boundaries.        │
│  RULE: Every piece of data entering your system gets validated.│
│  RULE: Data inside your system is trusted (typed, validated).  │
└──────────────────────────────────────────────────────────────┘
```

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
  createdAt: z.date(),
});

// Types derived from schema
export type User = z.infer<typeof UserSchema>;
export type CreateUser = z.infer<typeof CreateUserSchema>;
export type UpdateUser = z.infer<typeof UpdateUserSchema>;

// Request schemas derived from entity schema
export const CreateUserSchema = UserSchema.omit({ id: true, createdAt: true });
export const UpdateUserSchema = UserSchema.partial().omit({ id: true, createdAt: true });

// Response schema with computed fields
export const UserResponseSchema = UserSchema.extend({
  displayName: z.string(),
  avatarUrl: z.string().url().nullable(),
});

// Test data factory derived from schema
import { faker } from '@faker-js/faker';

export function buildUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    role: faker.helpers.arrayElement(['admin', 'member', 'viewer'] as const),
    createdAt: faker.date.past(),
    ...overrides,
  };
}
```

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

## Anti-Patterns

- **Do NOT write types and schemas separately.** If you have a TypeScript interface AND a Zod schema for the same entity, they will drift apart. Derive the type from the schema.
- **Do NOT validate inside business logic.** Validate at the boundary (API handler, database read). Inside service functions, trust the types.
- **Do NOT use `as` casts to silence errors.** `as unknown as User` is not type safety — it is hiding bugs. Fix the actual type mismatch.
- **Do NOT use `@ts-ignore` instead of fixing types.** Every `@ts-ignore` is a ticking time bomb. Use `@ts-expect-error` only when there is a genuine compiler limitation, and add a comment explaining why.
- **Do NOT skip `noUncheckedIndexedAccess`.** Without it, `array[0]` returns `T` instead of `T | undefined`. This is the single flag that catches the most real bugs.
- **Do NOT use `any` for "I'll type this later."** Use `unknown` instead. `unknown` is safe (requires narrowing), `any` is unsafe (bypasses all checking).
- **Do NOT over-validate.** Validating the same data at every function call is wasteful. Validate once at the boundary, then trust the types.
- **Do NOT create overly complex union types.** If a discriminated union has 15 variants and each handler is trivial, the type complexity is not paying for itself. Keep types proportional to the problem.
