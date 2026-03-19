# /godmode:forms

Form architecture covering state management (React Hook Form, Formik, native), multi-step wizard forms, validation patterns (client + server, async with debounce), file upload handling with drag-and-drop, and accessible form design with labels, error messages, and focus management.

## Usage

```
/godmode:forms                                # Full form architecture — build or audit
/godmode:forms --audit                        # Audit all existing forms
/godmode:forms --wizard                       # Build a multi-step wizard form
/godmode:forms --validation                   # Validation patterns (client + server + async)
/godmode:forms --upload                       # File upload implementation
/godmode:forms --a11y                         # Form accessibility audit only
/godmode:forms --schema registration          # Generate a Zod validation schema
/godmode:forms --migrate                      # Migrate from manual state to React Hook Form
/godmode:forms --autosave                     # Add autosave to an existing form
```

## What It Does

1. Assesses form requirements (field count, complexity, validation needs)
2. Recommends form state management (React Hook Form + Zod, Formik, native, server actions)
3. Implements validation with shared Zod schemas (client + server)
4. Builds multi-step wizard with step validation, persistence, and progress indicator
5. Implements async validation with debounce (email uniqueness, username availability)
6. Builds file upload with drag-and-drop, progress, preview, and validation
7. Ensures accessibility: visible labels, aria-describedby errors, focus management, error summary
8. Audits existing forms for accessibility, validation coverage, and UX patterns

## Output
- Form components and schemas
- Form architecture report at `docs/forms/<form-name>-architecture.md`
- Verdict: SOLID / NEEDS WORK / FRAGILE

## Next Step
After form architecture: `/godmode:a11y` for accessibility audit, `/godmode:test` for form testing, `/godmode:responsive` for responsive layout, or `/godmode:e2e` for end-to-end form flow testing.

## Examples

```
/godmode:forms                                # Build or audit form architecture
/godmode:forms --wizard                       # Build multi-step registration form
/godmode:forms --a11y                         # Audit form accessibility
/godmode:forms --schema checkout              # Generate checkout validation schema
/godmode:forms --upload                       # Build file upload component
```
