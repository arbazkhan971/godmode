# /godmode:type

Type system and schema validation covering TypeScript strict mode configuration, gradual typing strategies, Zod/Yup/Joi runtime validation, type narrowing and discriminated unions, branded types, and schema-first development. Every type improvement is justified by the bugs it prevents.

## Usage

```
/godmode:type                            # Full type safety audit and improvement
/godmode:type --audit                    # Audit type safety score without changes
/godmode:type --strict                   # Enable TypeScript strict mode
/godmode:type --schemas                  # Generate Zod schemas for domain entities
/godmode:type --validate                 # Add runtime validation at API boundaries
/godmode:type --eliminate-any            # Remove any types with proper replacements
/godmode:type --branded                  # Add branded types for domain identifiers
/godmode:type --migrate zod              # Migrate to Zod from another library
/godmode:type --env                      # Add environment variable validation
/godmode:type --factory                  # Generate test data factories from schemas
```

## What It Does

1. Audits type safety across the codebase (any count, strict flags, validation coverage)
2. Enables TypeScript strict mode (full or gradual adoption)
3. Selects and configures schema validation library (Zod, Yup, Joi, Valibot)
4. Defines schemas as single source of truth (types inferred, not duplicated)
5. Adds runtime validation middleware at API boundaries
6. Validates environment variables at startup
7. Replaces any types with proper typed alternatives
8. Introduces discriminated unions for state machines
9. Adds branded types for domain identifiers
10. Generates test data factories from schemas

## Output
- Updated tsconfig.json with strict mode flags
- Schema files at `src/schemas/`
- Validation middleware at `src/middleware/validate.ts`
- Environment validation at `src/config/env.ts`
- Type safety audit report with score
- Commit: `"type: <project> — type safety score <before> -> <after>"`

## Next Step
After type improvements: `/godmode:lint` to enforce type-related lint rules, `/godmode:test` to verify type safety with tests, or `/godmode:build` to continue building.

## Examples

```
/godmode:type                            # Full type safety improvement
/godmode:type --audit                    # Check current type safety score
/godmode:type --strict                   # Enable strict TypeScript
/godmode:type --schemas                  # Generate Zod schemas
/godmode:type --eliminate-any            # Remove all any types
```
