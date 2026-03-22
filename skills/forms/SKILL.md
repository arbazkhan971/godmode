---
name: forms
description: |
  Form architecture skill. Activates when user needs to build complex forms including multi-step wizards, validation patterns (client + server, async), file uploads, and accessible form design. Covers form state management (React Hook Form, Formik, native), error handling, focus management, and form UX best practices. Triggers on: /godmode:forms, "form validation", "multi-step form", "wizard form", "file upload", "form accessibility", or when building any non-trivial form.
---

# Forms — Form Architecture

## When to Activate
- User invokes `/godmode:forms`
- User says "form validation," "multi-step form," "wizard," "file upload"
- When building any form beyond a simple single-field input
- When implementing client-side and server-side validation
- When building multi-step or wizard-style forms
- When handling file uploads with progress and preview
- When auditing form accessibility (labels, errors, focus management)
- When choosing a form state management library

## Workflow

### Step 1: Assess Form Requirements
Determine the complexity and constraints of the form:

```
FORM REQUIREMENTS ASSESSMENT:
Form purpose: <registration/checkout/settings/survey/data entry>
Framework: <React/Vue/Angular/Svelte/vanilla>
Fields: <N> total
  Text inputs: <N>
  Selects/dropdowns: <N>
  Checkboxes/radios: <N>
  File uploads: <N>
  Custom components: <N>

Complexity:
  Multi-step: YES/NO (<N> steps)
  Conditional fields: YES/NO
  Dynamic fields (add/remove): YES/NO
  Dependent fields: YES/NO (field B depends on field A value)
```

### Step 2: Form State Management
Choose and implement the right form state management approach:

#### Decision Matrix
```
FORM STATE MANAGEMENT DECISION:
┌──────────────────────────────────────────────────────────────────────────┐
│ Criterion           │ React Hook Form │ Formik    │ Native       │ Server │
├──────────────────────────────────────────────────────────────────────────┤
│ Re-renders          │ Minimal         │ Frequent  │ Minimal      │ Zero   │
│ Bundle size         │ ~9KB            │ ~15KB     │ 0KB          │ 0KB    │
│ TypeScript          │ Excellent       │ Good      │ Manual       │ Good   │
│ Validation          │ Resolver-based  │ Built-in  │ Manual       │ Server │
│ Performance         │ Excellent       │ Good      │ Depends      │ N/A    │
│ Complex forms       │ Excellent       │ Good      │ Verbose      │ Limited│
│ File uploads        │ Good            │ Good      │ Manual       │ Good   │
│ Multi-step          │ Excellent       │ Good      │ Complex      │ Complex│
│ Server integration  │ Good            │ Good      │ Good         │ Native │
│ Learning curve      │ Medium          │ Low       │ Low          │ Low    │
└──────────────────────────────────────────────────────────────────────────┘
```

#### React Hook Form + Zod Setup
```typescript
// schemas/registration.ts
import { z } from 'zod';

export const registrationSchema = z.object({
  name: z.string()
    .min(2, 'Name requires at least 2 characters')
# ... (condensed)
```

```typescript
// components/RegistrationForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { registrationSchema, type RegistrationFormData } from '../schemas/registration';

export function RegistrationForm() {
# ... (condensed)
```

### Step 3: Multi-Step Wizard Forms
Implement wizard-style forms with step navigation, validation per step, and state persistence:

#### Wizard Architecture
```
WIZARD ARCHITECTURE:
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Step 1   │───>│ Step 2   │───>│ Step 3   │───>│ Review   │
│ Personal │    │ Address  │    │ Payment  │    │ Confirm  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │
  Schema 1       Schema 2      Schema 3      Full schema
  validates      validates     validates     validates all
  step 1         step 2        step 3

State persistence: sessionStorage (survives refresh, clears on tab close)
Navigation: Linear (can go back, cannot skip ahead without valid current step)
URL sync: /signup/step/1, /signup/step/2 (supports direct linking)
```

#### Multi-Step Form Implementation
```typescript
// hooks/useWizardForm.ts
import { useState, useCallback } from 'react';
import { useForm, UseFormReturn } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

# ... (condensed)
```

#### Step Progress Indicator
```typescript
// components/StepProgress.tsx
export function StepProgress({
  steps,
  currentStep,
}: {
  steps: { id: string; title: string }[];
# ... (condensed)
```

### Step 4: Validation Patterns
Implement comprehensive validation covering client-side, server-side, and async:

#### Client-Side Validation
```typescript
// schemas/checkout.ts — Comprehensive validation example
import { z } from 'zod';

export const addressSchema = z.object({
  street: z.string().min(1, 'Street address is required'),
  city: z.string().min(1, 'City is required'),
# ... (condensed)
```

#### Async Validation (Debounced)
```typescript
// hooks/useAsyncValidation.ts
import { useCallback, useRef } from 'react';

export function useAsyncValidation<T>(
  validator: (value: T) => Promise<string | null>,
  debounceMs = 500,
# ... (condensed)
```

#### Server-Side Validation
```typescript
// app/api/register/route.ts (Next.js App Router)
import { registrationSchema } from '@/schemas/registration';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const body = await request.json();
# ... (condensed)
```

#### Error Display Strategy
```
VALIDATION ERROR DISPLAY RULES:

1. WHEN to show errors:
   - On blur (first visit): Show after user leaves the field
   - On change (after first error): Re-validate immediately after error shown
   - On submit: Validate all, focus first error field
   - Never on mount: Do not show errors before user interaction

2. WHERE to show errors:
   - Inline: Below the field, associated via aria-describedby
   - Summary: At top of form for submit-time errors, linked to fields
   - Toast: For server/network errors only

3. HOW to show errors:
   - Text: Clear, actionable message ("Enter a valid email" not "Invalid")
```

### Step 5: File Upload Handling
Implement file uploads with validation, progress, preview, and drag-and-drop:

#### File Upload Component
```typescript
// components/FileUpload.tsx
import { useCallback, useState, useRef } from 'react';

interface FileUploadProps {
  accept?: string;
  maxSize?: number; // bytes
# ... (condensed)
```

### Step 6: Accessible Form Design
Ensure every form meets WCAG 2.1 AA accessibility requirements:

#### Accessible FormField Component
```typescript
// components/FormField.tsx
import { useId } from 'react';

interface FormFieldProps {
  label: string;
  error?: string;
# ... (condensed)
```

#### Form Accessibility Checklist
```
FORM ACCESSIBILITY CHECKLIST:

Labels & Instructions:
- [ ] Every input has a visible <label> associated via htmlFor/id
- [ ] Required fields are indicated (asterisk + screen reader text)
- [ ] Placeholder text is NOT used as a label substitute
- [ ] Group related fields with <fieldset> and <legend>
- [ ] Instructions appear before the form, not after
- [ ] Input format hints are provided (e.g., "MM/YY" for expiry)

Error Handling:
- [ ] Errors are associated with fields via aria-describedby
- [ ] Errors appear as text, not only color/icon
- [ ] aria-invalid="true" set on fields with errors
- [ ] Error summary at top of form on submit (linked to fields)
```

#### Focus Management
```typescript
// hooks/useFocusOnError.ts
import { useEffect, useRef } from 'react';
import { FieldErrors } from 'react-hook-form';

export function useFocusOnError(errors: FieldErrors, isSubmitted: boolean) {
  const prevSubmitCount = useRef(0);
# ... (condensed)
```

#### Error Summary Component
```typescript
// components/ErrorSummary.tsx
export function ErrorSummary({ errors }: { errors: Record<string, string> }) {
  const errorEntries = Object.entries(errors);
  if (errorEntries.length === 0) return null;

  return (
# ... (condensed)
```

### Step 7: Advanced Patterns

#### Conditional Fields
```typescript
// Show/hide fields based on other field values
const watchRole = watch('role');

return (
  <form>
    <FormField label="Role" required>
# ... (condensed)
```

#### Dynamic Field Arrays
```typescript
// Add/remove fields dynamically
import { useFieldArray } from 'react-hook-form';

function PhoneNumbersForm() {
  const { control, register } = useForm({
    defaultValues: { phones: [{ number: '', type: 'mobile' }] },
# ... (condensed)
```

#### Autosave
```typescript
// hooks/useAutosave.ts
import { useEffect, useRef } from 'react';
import { UseFormWatch } from 'react-hook-form';

export function useAutosave<T extends Record<string, any>>({
  watch,
# ... (condensed)
```

### Step 8: Form Architecture Report

```
FORM ARCHITECTURE REPORT:
┌──────────────────────────────────────────────────────────────┐
│ Form: <name/purpose>                                         │
│ Fields: <N> total (<N> required)                              │
│ Steps: <N> (or single page)                                   │
│                                                               │
│ State Management:                                             │
│   Library: <React Hook Form / Formik / native>                │
│   Validation: <Zod / Yup / custom>                            │
│   Mode: <onBlur / onChange / onSubmit>                         │
│                                                               │
│ Validation Coverage:                                          │
│   Client-side: <N>/<N> fields validated                       │
│   Server-side: YES / NO                                       │
│   Async validation: <N> fields                                │
```

### Step 9: Commit and Transition
1. If form components were created: `"forms: implement <form-name> with <library> + <validation>"`
2. If wizard was built: `"forms: add multi-step wizard with <N> steps and session persistence"`
3. If accessibility was fixed: `"forms: fix <N> form accessibility issues (labels, errors, focus)"`
4. Save report: `docs/forms/<form-name>-architecture.md`
5. Transition: "Form architecture complete. Run `/godmode:a11y` for accessibility audit, `/godmode:test` for form testing, or `/godmode:responsive` for responsive layout."

## Key Behaviors

1. **Validation runs on both client and server.** Client-side validation is for UX (fast feedback). Server-side validation is for security (never trust the client). Share the schema (Zod) between both.
2. **Errors are shown on blur, not on mount.** Showing errors before the user has interacted with a field is hostile UX. Validate on blur for first visit, on change after the first error is shown.
3. **Focus management is mandatory.** On submit failure, focus must move to the first invalid field. On step transition, focus must move to the first field of the new step. Lost focus means lost users.
4. **Every field has a visible label.** Placeholder text is not a label. Floating labels that disappear are not acceptable. Keep labels always visible, always associated via htmlFor/id.
5. **Multi-step forms persist state.** Navigating back must restore previous values. Page refresh should not lose progress (use sessionStorage). Only clear on successful submission.
6. **File uploads need comprehensive validation.** Check file type, file size, and file count before uploading. Show progress. Provide preview for images. Make the drop zone keyboard-accessible.
7. **Form state libraries exist for a reason.** For anything beyond 3 fields, use React Hook Form (or equivalent). Manual state management with useState leads to re-render storms, validation inconsistency, and lost edge cases.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full form architecture — build or audit |
| `--audit` | Audit all existing forms for completeness |
| `--wizard` | Build a multi-step wizard form |

## Explicit Loop Protocol

When building or auditing multiple forms:

```
FORM BUILD/AUDIT LOOP:
current_iteration = 0
forms = [form_1, form_2, ...]  // discovered or requested forms

WHILE current_iteration < len(forms) AND NOT user_says_stop:
  1. ASSESS form: field count, complexity, multi-step, file uploads, async validation
  2. IF building new form:
       a. CREATE Zod schema (or chosen validation library)
       b. IMPLEMENT form with chosen library (React Hook Form recommended)
       c. ADD accessibility: labels, aria-invalid, aria-describedby, focus management
       d. ADD server-side validation using shared schema
       e. IF multi-step: implement wizard with session persistence
       f. IF file upload: implement with validation, progress, preview
  3. IF auditing existing form:
       a. CHECK: every field has visible label (not just placeholder)
```

## Hard Rules

```
HARD RULES — FORMS:
1. EVERY input field MUST have a visible <label> associated via htmlFor/id. Placeholder is NOT a label.
2. NEVER show validation errors before the user has interacted with the field. Validate on blur first, onChange after.
3. ALWAYS validate on BOTH client and server. Client validation is UX; server validation is security.
4. ALWAYS move focus to the first invalid field on submit failure. Lost focus = lost users.
5. NEVER use alert() for form errors. Use inline errors with aria-describedby and error summary.
6. ALWAYS persist multi-step form data across steps and on browser refresh (sessionStorage).
7. ALWAYS validate file uploads: check MIME type, file extension, file size, and count before uploading.
8. NEVER manage more than 5 fields with raw useState. Use React Hook Form or equivalent.
9. ALWAYS use aria-invalid="true" on fields with errors and role="alert" on error messages.
10. ALWAYS share the same schema (Zod) between client and server validation. Two schemas = two sources of bugs.
```

## Output Format

After each forms skill invocation, emit a structured report:

```
FORMS BUILD REPORT:
┌──────────────────────────────────────────────────────┐
│  Forms created      │  <N>                            │
│  Forms updated      │  <N>                            │
│  Fields total       │  <N>                            │
│  Validation schemas │  <N> (Zod/Yup)                  │
│  Client validation  │  YES / NO                       │
│  Server validation  │  YES / NO (shared schema)       │
│  A11y (labels+aria) │  PASS / <N> violations          │
│  Error messages     │  <N> fields with inline errors  │
│  Multi-step         │  <N> steps / N/A                │
│  Tests              │  <N> passing, <N> failing       │
│  Verdict            │  PASS | NEEDS REVISION          │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every form creation for tracking:

```
timestamp	skill	form_name	fields	validation	a11y_pass	tests_pass	status
2026-03-20T14:00:00Z	forms	signup	5	zod_client+server	yes	8/8	pass
2026-03-20T14:10:00Z	forms	checkout_wizard	12	zod_client+server	yes	15/15	pass
```

## Success Criteria

The forms skill is complete when ALL of the following are true:
1. Every field has a visible `<label>` element (not just placeholder text)
2. Validation schema is shared between client and server (single source of truth)
3. Every field shows inline error messages with `aria-describedby` and `aria-invalid`
4. Form validates on blur (first touch) and on change (after first error)
5. Form submission is protected against double-submit (disable button + debounce)
6. Multi-step forms persist data across steps and survive browser back navigation
7. File uploads validate MIME type, extension, file size, and count
8. All form interactions are keyboard-accessible (tab order, enter to submit, escape to cancel)
9. Tests cover: valid submission, each validation rule, error display, and edge cases

## Keep/Discard Discipline
```
After EACH form implementation or audit fix:
  1. MEASURE: Submit the form with valid data, invalid data, and edge cases — does validation fire correctly?
  2. COMPARE: Are errors inline with aria-describedby, focus on first error, labels visible?
  3. DECIDE:
     - KEEP if: validation timing correct (blur first, change after) AND all a11y checks pass AND server validation matches client
     - DISCARD if: errors show on first keystroke OR focus lost on submit failure OR server/client schemas diverge
  4. COMMIT kept changes. Run `git reset --hard` on discarded changes before the next form.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All forms have visible labels, inline errors with aria-describedby, and shared Zod schemas
  - Multi-step forms persist data across steps and survive browser refresh
  - Keyboard navigation works for all form interactions
  - User explicitly requests stop

DO NOT STOP just because:
  - Autosave is not yet implemented (explicit save is acceptable)
  - Error message wording scores below 7/7 on every field (5+ is acceptable for first pass)
```

## Form UX Audit Loop

Autoresearch-grade iterative audit for form user experience. Covers validation pattern correctness, error messaging quality, and submission flow robustness through measured, repeatable cycles.

```
FORM UX AUDIT PROTOCOL:

Phase 1 — Validation Pattern Audit
  FOR EACH form: map all fields, test validation timing:
    a. Focus → blur empty optional field → NO error shown
    b. Focus → type invalid → blur → error shown on blur
    c. See error → type valid → error clears on change
    d. Submit with empty required → all errors shown
    e. Fix one field → that error clears independently

  Classify patterns:
    CORRECT: onBlur first, onChange after error
    BAD: first keystroke | submit-only | no validation | async without loading state
  Record: form | field | current_timing | correct_timing | status
  TARGET: 100% correct validation timing across all forms
```

### Form UX Audit TSV Logging

Append one row per finding to `.godmode/forms-audit.tsv`:

```
timestamp	project	form	phase	field	finding	before	after	status
2024-01-15T10:30:00Z	my-app	checkout	validation	card_number	validates_on_keystroke	onChange	onBlur	fixed
2024-01-15T10:35:00Z	my-app	checkout	error_msg	card_number	"Invalid"	"Enter valid 16-digit number"	fixed
2024-01-15T10:40:00Z	my-app	checkout	submission	submit_btn	no_double_submit_protection	none	disable+debounce	fixed
```

### Form UX Audit Hard Rules

See the main **Hard Rules** section above — all rules apply to the audit loop. Additionally: log every form UX finding in TSV format for tracking improvements across releases.


## Error Recovery
| Failure | Action |
|---------|--------|
| Validation fires on every keystroke | Use `onBlur` validation for most fields. Only validate `onChange` for fields with instant feedback (e.g., password strength). Debounce async validation. |
| Form state lost on navigation | Persist form state in sessionStorage or URL params. Use `beforeunload` event to warn about unsaved changes. |
| Server validation errors not displayed | Map server error field names to form field names. Display inline next to the relevant field, not just as a toast. |
| Multi-step form loses progress on refresh | Save each step's data to sessionStorage on advancement. Restore on page load. Clear on successful submission. |
