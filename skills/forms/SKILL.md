---
name: forms
description: |
  Form architecture skill. Multi-step wizards,
  validation (client + server, async), file uploads,
  accessible form design. Triggers on: /godmode:forms,
  "form validation", "multi-step form", "wizard",
  "file upload", "form accessibility".
---

# Forms — Form Architecture

## When to Activate
- User invokes `/godmode:forms`
- User says "form validation", "multi-step form", "wizard"
- When building any form beyond a simple single input
- When handling file uploads or auditing form a11y

## Workflow

### Step 1: Assess Form Requirements

```bash
# Detect form libraries
grep -l "react-hook-form\|formik\|@hookform" \
  package.json 2>/dev/null

# Detect validation libraries
grep -l "zod\|yup\|joi\|superstruct" \
  package.json 2>/dev/null

# Count existing form components
find src/ -name "*form*" -o -name "*Form*" \
  2>/dev/null | wc -l
```

```
FORM REQUIREMENTS:
Purpose: <registration/checkout/settings/survey>
Framework: <React/Vue/Angular/Svelte>
Fields: <N> total
Multi-step: YES/NO (<N> steps)
File uploads: YES/NO (<types, max size>)
Async validation: YES/NO (uniqueness checks)

IF fields > 5: use React Hook Form (not useState)
IF multi-step: persist state in sessionStorage
IF file uploads: validate MIME, size, count client-side
```

### Step 2: Form State Management

```
DECISION MATRIX:
| Criterion     | RHF    | Formik | Native |
|--------------|--------|--------|--------|
| Re-renders   | Min    | Freq   | Min    |
| Bundle size  | ~9KB   | ~15KB  | 0KB    |
| TypeScript   | Excl.  | Good   | Manual |
| Complex forms| Excl.  | Good   | Verbose|

IF fields <= 3 AND no validation: native useState OK
IF fields > 3 OR has validation: React Hook Form
IF existing Formik codebase: keep Formik
```

### Step 3: Validation Patterns

```
VALIDATION TIMING:
  On blur (first visit): show after user leaves field
  On change (after error): re-validate immediately
  On submit: validate all, focus first error
  Never on mount: no errors before interaction

CLIENT + SERVER SHARED SCHEMA (Zod):
  Single schema shared between client and server
  Client: fast UX feedback
  Server: security (never trust client)

ASYNC VALIDATION:
  Debounce: 500ms minimum
  Show loading indicator during check
  Cancel previous request on new input

THRESHOLDS:
  Debounce delay: 300-500ms for async validation
  Max file size: 10MB default (configurable)
  Max file count: 10 per upload field
  Form submission timeout: 30 seconds
```

### Step 4: Multi-Step Wizard

```
WIZARD ARCHITECTURE:
  Step 1 → Step 2 → Step 3 → Review → Submit
  Each step has its own Zod schema
  Full schema validates on final submit
  State persists in sessionStorage (survives refresh)

RULES:
  IF user navigates back: restore previous values
  IF browser refreshes: restore from sessionStorage
  IF submit succeeds: clear sessionStorage
  Progress indicator shows current step
```

### Step 5: File Upload Handling

```
FILE VALIDATION CHECKLIST:
  MIME type: validate against allowlist
  Extension: cross-check with MIME type
  File size: reject > max before upload starts
  File count: enforce maximum per field
  Preview: show for images (use createObjectURL)
  Progress: show upload percentage
  Drop zone: must be keyboard-accessible

THRESHOLDS:
  Image max: 5MB
  Document max: 10MB
  Total upload max: 50MB per form submission
```

### Step 6: Accessible Form Design

```
FORM ACCESSIBILITY CHECKLIST:
Labels:
  [ ] Every input has visible <label> with htmlFor
  [ ] Required fields marked (asterisk + sr text)
  [ ] Placeholder is NOT used as label substitute
  [ ] Related fields grouped in <fieldset>/<legend>

Errors:
  [ ] Errors via aria-describedby on field
  [ ] aria-invalid="true" on fields with errors
  [ ] Error summary at top on submit failure
  [ ] role="alert" on error messages

Focus:
  [ ] On submit failure: focus first invalid field
  [ ] On step change: focus first field of new step
  [ ] Tab order follows visual order
  [ ] All form controls keyboard-accessible
```

### Step 7: Report

```
Form: <name>, Fields: <N>, Steps: <N>
Library: <RHF/Formik/native>
Validation: <Zod/Yup>, Mode: <onBlur/onChange>
A11y: <PASS|FAIL>, Tests: <pass>/<total>
```

Commit: `"forms: <form-name> — <library> + <validation>"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Validation on both client and server.**
   Share the schema (Zod) between both.
2. **Errors on blur, not on mount.**
3. **Focus management mandatory.** Focus first invalid
   field on submit failure.
4. **Every field has a visible label.**
5. **Multi-step forms persist state.**
6. **File uploads need full validation.**
7. **Use RHF for 5+ fields.** Manual useState leads
   to re-render storms.

## HARD RULES

1. Every input must have a visible `<label>`.
2. Never show errors before user interaction.
3. Always validate on both client and server.
4. Always focus first invalid field on submit.
5. Never use alert() for form errors.
6. Always persist multi-step data in sessionStorage.
7. Always validate file MIME, extension, size, count.
8. Never manage 5+ fields with raw useState.
9. Always use aria-invalid and aria-describedby.
10. Always share same Zod schema client and server.

## Auto-Detection
```
1. Libraries: react-hook-form, formik, zod, yup
2. Components: *Form*, *Wizard*, *Step* files
3. Validation: inline vs schema-based
```

## Output Format
Print: `Forms: {name} — {fields} fields,
  {validation}, a11y {PASS|FAIL}. Status: {status}.`

## TSV Logging
```
timestamp	form_name	fields	validation	a11y	status
```

## Keep/Discard Discipline
```
KEEP if: validation timing correct AND a11y passes
  AND server matches client schema
DISCARD if: errors on first keystroke OR focus lost
  OR schemas diverge between client/server
```

## Stop Conditions
```
STOP when ANY of:
  - All forms have labels, inline errors, shared schemas
  - Multi-step persists across steps and refresh
  - Keyboard navigation works for all interactions
  - User requests stop
```

## Error Recovery
- Fires every keystroke: switch to onBlur mode.
- State lost on navigation: persist in sessionStorage.
- Server errors not shown: map server fields to form.
- Multi-step loses progress: save per step, restore.

