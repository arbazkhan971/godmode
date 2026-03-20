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
  Async validation: YES/NO (email uniqueness, username availability)
  Server-side validation: YES/NO
  File uploads: YES/NO (max size, types, multiple)
  Autosave: YES/NO

State management: <React Hook Form / Formik / native / Zod + server actions>
Validation library: <Zod / Yup / Joi / custom>
Recommended approach: <see Step 2>
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

IF < 5 fields, no validation complexity → Native (useState/FormData)
IF React project, any complexity → React Hook Form + Zod
IF React project, existing Formik → Keep Formik, migrate incrementally
IF Next.js 14+ with server actions → Server actions + Zod + useActionState
IF Vue/Angular/Svelte → Framework-native form handling + Zod
```

#### React Hook Form + Zod Setup
```typescript
// schemas/registration.ts
import { z } from 'zod';

export const registrationSchema = z.object({
  name: z.string()
    .min(2, 'Name must be at least 2 characters')
    .max(100, 'Name must be under 100 characters'),
  email: z.string()
    .email('Please enter a valid email address'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  confirmPassword: z.string(),
  role: z.enum(['user', 'admin', 'editor'], {
    errorMap: () => ({ message: 'Please select a role' }),
  }),
  agreeToTerms: z.literal(true, {
    errorMap: () => ({ message: 'You must agree to the terms' }),
  }),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

export type RegistrationFormData = z.infer<typeof registrationSchema>;
```

```typescript
// components/RegistrationForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { registrationSchema, type RegistrationFormData } from '../schemas/registration';

export function RegistrationForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting, isValid },
    setError,
    watch,
  } = useForm<RegistrationFormData>({
    resolver: zodResolver(registrationSchema),
    mode: 'onBlur',        // Validate on blur for immediate feedback
    reValidateMode: 'onChange', // Re-validate on change after first error
  });

  const onSubmit = async (data: RegistrationFormData) => {
    try {
      const response = await fetch('/api/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        const serverErrors = await response.json();
        // Map server errors to form fields
        for (const [field, message] of Object.entries(serverErrors.errors)) {
          setError(field as keyof RegistrationFormData, {
            type: 'server',
            message: message as string,
          });
        }
        return;
      }

      // Success handling
    } catch (error) {
      setError('root', { message: 'An unexpected error occurred. Please try again.' });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <FormField
        label="Full Name"
        error={errors.name?.message}
        required
      >
        <input
          {...register('name')}
          type="text"
          aria-invalid={!!errors.name}
          aria-describedby={errors.name ? 'name-error' : undefined}
          autoComplete="name"
        />
      </FormField>

      <FormField
        label="Email"
        error={errors.email?.message}
        required
      >
        <input
          {...register('email')}
          type="email"
          aria-invalid={!!errors.email}
          autoComplete="email"
        />
      </FormField>

      {errors.root && (
        <div role="alert" className="form-error-banner">
          {errors.root.message}
        </div>
      )}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating account...' : 'Create Account'}
      </button>
    </form>
  );
}
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

interface WizardStep<T extends z.ZodType> {
  id: string;
  title: string;
  schema: T;
  component: React.ComponentType<{ form: UseFormReturn<z.infer<T>> }>;
}

export function useWizardForm<T extends z.ZodObject<any>>({
  steps,
  fullSchema,
  onComplete,
  storageKey,
}: {
  steps: WizardStep<any>[];
  fullSchema: T;
  onComplete: (data: z.infer<T>) => Promise<void>;
  storageKey?: string;
}) {
  const [currentStep, setCurrentStep] = useState(0);
  const [formData, setFormData] = useState<Partial<z.infer<T>>>(() => {
    if (storageKey && typeof window !== 'undefined') {
      const saved = sessionStorage.getItem(storageKey);
      return saved ? JSON.parse(saved) : {};
    }
    return {};
  });

  const currentSchema = steps[currentStep].schema;
  const form = useForm({
    resolver: zodResolver(currentSchema),
    defaultValues: formData,
    mode: 'onBlur',
  });

  const persistData = useCallback((data: Partial<z.infer<T>>) => {
    const merged = { ...formData, ...data };
    setFormData(merged);
    if (storageKey) {
      sessionStorage.setItem(storageKey, JSON.stringify(merged));
    }
    return merged;
  }, [formData, storageKey]);

  const goNext = async () => {
    const isValid = await form.trigger();
    if (!isValid) return false;

    const stepData = form.getValues();
    const merged = persistData(stepData);

    if (currentStep === steps.length - 1) {
      await onComplete(merged as z.infer<T>);
      if (storageKey) sessionStorage.removeItem(storageKey);
      return true;
    }

    setCurrentStep((s) => s + 1);
    return true;
  };

  const goBack = () => {
    if (currentStep > 0) {
      persistData(form.getValues());
      setCurrentStep((s) => s - 1);
    }
  };

  return {
    currentStep,
    totalSteps: steps.length,
    step: steps[currentStep],
    form,
    goNext,
    goBack,
    isFirst: currentStep === 0,
    isLast: currentStep === steps.length - 1,
    formData,
    progress: ((currentStep + 1) / steps.length) * 100,
  };
}
```

#### Step Progress Indicator
```typescript
// components/StepProgress.tsx
export function StepProgress({
  steps,
  currentStep,
}: {
  steps: { id: string; title: string }[];
  currentStep: number;
}) {
  return (
    <nav aria-label="Form progress">
      <ol role="list" className="step-progress">
        {steps.map((step, index) => {
          const status = index < currentStep ? 'complete' : index === currentStep ? 'current' : 'upcoming';
          return (
            <li
              key={step.id}
              className={`step-progress__item step-progress__item--${status}`}
              aria-current={status === 'current' ? 'step' : undefined}
            >
              <span className="step-progress__number" aria-hidden="true">
                {status === 'complete' ? '\u2713' : index + 1}
              </span>
              <span className="step-progress__title">{step.title}</span>
              <span className="sr-only">
                {status === 'complete' ? '(completed)' : status === 'current' ? '(current step)' : ''}
              </span>
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
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
  state: z.string().length(2, 'Use 2-letter state code'),
  zip: z.string().regex(/^\d{5}(-\d{4})?$/, 'Enter a valid ZIP code'),
  country: z.string().min(1, 'Country is required'),
});

export const paymentSchema = z.object({
  cardNumber: z.string()
    .transform((val) => val.replace(/\s/g, ''))
    .pipe(z.string().regex(/^\d{13,19}$/, 'Enter a valid card number')),
  expiry: z.string()
    .regex(/^(0[1-9]|1[0-2])\/\d{2}$/, 'Use MM/YY format')
    .refine((val) => {
      const [month, year] = val.split('/').map(Number);
      const expiry = new Date(2000 + year, month);
      return expiry > new Date();
    }, 'Card has expired'),
  cvv: z.string().regex(/^\d{3,4}$/, 'Enter a valid CVV'),
  nameOnCard: z.string().min(1, 'Name on card is required'),
});
```

#### Async Validation (Debounced)
```typescript
// hooks/useAsyncValidation.ts
import { useCallback, useRef } from 'react';

export function useAsyncValidation<T>(
  validator: (value: T) => Promise<string | null>,
  debounceMs = 500,
) {
  const timeoutRef = useRef<NodeJS.Timeout>();
  const abortRef = useRef<AbortController>();

  return useCallback(async (value: T): Promise<string | null> => {
    // Cancel previous request
    abortRef.current?.abort();
    clearTimeout(timeoutRef.current);

    return new Promise((resolve) => {
      timeoutRef.current = setTimeout(async () => {
        abortRef.current = new AbortController();
        try {
          const error = await validator(value);
          resolve(error);
        } catch (err) {
          if (err instanceof DOMException && err.name === 'AbortError') {
            resolve(null); // Aborted, ignore
          }
          resolve('Validation failed. Please try again.');
        }
      }, debounceMs);
    });
  }, [validator, debounceMs]);
}

// Usage: Check email uniqueness
const validateEmail = useAsyncValidation(async (email: string) => {
  const res = await fetch(`/api/check-email?email=${encodeURIComponent(email)}`);
  const { available } = await res.json();
  return available ? null : 'This email is already registered';
});
```

#### Server-Side Validation
```typescript
// app/api/register/route.ts (Next.js App Router)
import { registrationSchema } from '@/schemas/registration';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const body = await request.json();

  // Server-side validation with same schema
  const result = registrationSchema.safeParse(body);
  if (!result.success) {
    const errors: Record<string, string> = {};
    for (const issue of result.error.issues) {
      const field = issue.path.join('.');
      errors[field] = issue.message;
    }
    return NextResponse.json({ errors }, { status: 422 });
  }

  // Additional server-only checks
  const emailExists = await db.user.findUnique({ where: { email: result.data.email } });
  if (emailExists) {
    return NextResponse.json({
      errors: { email: 'This email is already registered' },
    }, { status: 422 });
  }

  // Process valid data
  const user = await db.user.create({ data: result.data });
  return NextResponse.json({ user }, { status: 201 });
}
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
   - Color: Red text + red border (never color alone)
   - Icon: Error icon alongside text for visual scanning
   - ARIA: aria-invalid="true" on field, role="alert" on error message

4. FOCUS management:
   - On submit with errors: Focus first invalid field
   - On async error: Focus the field with server error
   - On step change: Focus first field of new step
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
  maxFiles?: number;
  multiple?: boolean;
  onUpload: (files: File[]) => Promise<void>;
  onError?: (error: string) => void;
}

interface UploadedFile {
  file: File;
  preview?: string;
  progress: number;
  status: 'pending' | 'uploading' | 'complete' | 'error';
  error?: string;
}

export function FileUpload({
  accept = 'image/*',
  maxSize = 5 * 1024 * 1024, // 5MB
  maxFiles = 5,
  multiple = false,
  onUpload,
  onError,
}: FileUploadProps) {
  const [files, setFiles] = useState<UploadedFile[]>([]);
  const [isDragging, setIsDragging] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const validateFile = useCallback((file: File): string | null => {
    if (file.size > maxSize) {
      return `File exceeds ${(maxSize / 1024 / 1024).toFixed(0)}MB limit`;
    }
    if (accept && !accept.split(',').some((type) => {
      const trimmed = type.trim();
      if (trimmed.endsWith('/*')) {
        return file.type.startsWith(trimmed.replace('/*', '/'));
      }
      return file.type === trimmed || file.name.endsWith(trimmed);
    })) {
      return `File type not accepted. Accepted: ${accept}`;
    }
    return null;
  }, [accept, maxSize]);

  const handleFiles = useCallback((fileList: FileList | File[]) => {
    const newFiles = Array.from(fileList).slice(0, maxFiles - files.length);

    const validated: UploadedFile[] = newFiles.map((file) => {
      const error = validateFile(file);
      return {
        file,
        preview: file.type.startsWith('image/') ? URL.createObjectURL(file) : undefined,
        progress: 0,
        status: error ? 'error' : 'pending',
        error: error ?? undefined,
      };
    });

    setFiles((prev) => [...prev, ...validated]);

    const validFiles = validated.filter((f) => f.status === 'pending').map((f) => f.file);
    if (validFiles.length > 0) {
      onUpload(validFiles);
    }

    const errors = validated.filter((f) => f.error);
    if (errors.length > 0 && onError) {
      onError(errors.map((f) => `${f.file.name}: ${f.error}`).join('; '));
    }
  }, [files.length, maxFiles, validateFile, onUpload, onError]);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback(() => setIsDragging(false), []);

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    handleFiles(e.dataTransfer.files);
  }, [handleFiles]);

  const removeFile = useCallback((index: number) => {
    setFiles((prev) => {
      const file = prev[index];
      if (file.preview) URL.revokeObjectURL(file.preview);
      return prev.filter((_, i) => i !== index);
    });
  }, []);

  return (
    <div className="file-upload">
      <div
        className={`file-upload__dropzone ${isDragging ? 'file-upload__dropzone--active' : ''}`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        onClick={() => inputRef.current?.click()}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') inputRef.current?.click(); }}
        aria-label={`Upload files. Accepted: ${accept}. Max size: ${(maxSize / 1024 / 1024).toFixed(0)}MB`}
      >
        <input
          ref={inputRef}
          type="file"
          accept={accept}
          multiple={multiple}
          onChange={(e) => e.target.files && handleFiles(e.target.files)}
          className="sr-only"
          aria-hidden="true"
        />
        <p>Drag files here or click to browse</p>
        <p className="file-upload__hint">
          {accept} — Max {(maxSize / 1024 / 1024).toFixed(0)}MB
          {multiple && ` — Up to ${maxFiles} files`}
        </p>
      </div>

      {files.length > 0 && (
        <ul className="file-upload__list" aria-label="Uploaded files">
          {files.map((f, i) => (
            <li key={`${f.file.name}-${i}`} className="file-upload__item">
              {f.preview && <img src={f.preview} alt="" className="file-upload__preview" />}
              <span className="file-upload__name">{f.file.name}</span>
              <span className="file-upload__size">{(f.file.size / 1024).toFixed(0)}KB</span>
              {f.status === 'uploading' && (
                <progress value={f.progress} max={100} aria-label={`Uploading ${f.file.name}`}>
                  {f.progress}%
                </progress>
              )}
              {f.status === 'error' && (
                <span className="file-upload__error" role="alert">{f.error}</span>
              )}
              <button
                onClick={() => removeFile(i)}
                aria-label={`Remove ${f.file.name}`}
                className="file-upload__remove"
              >
                Remove
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
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
  hint?: string;
  required?: boolean;
  children: React.ReactElement;
}

export function FormField({ label, error, hint, required, children }: FormFieldProps) {
  const id = useId();
  const errorId = `${id}-error`;
  const hintId = `${id}-hint`;

  const describedBy = [
    hint ? hintId : null,
    error ? errorId : null,
  ].filter(Boolean).join(' ') || undefined;

  return (
    <div className={`form-field ${error ? 'form-field--error' : ''}`}>
      <label htmlFor={id} className="form-field__label">
        {label}
        {required && <span aria-hidden="true" className="form-field__required">*</span>}
        {required && <span className="sr-only">(required)</span>}
      </label>

      {hint && (
        <p id={hintId} className="form-field__hint">
          {hint}
        </p>
      )}

      {/* Clone child to inject accessibility props */}
      {React.cloneElement(children, {
        id,
        'aria-invalid': error ? true : undefined,
        'aria-describedby': describedBy,
        'aria-required': required,
      })}

      {error && (
        <p id={errorId} className="form-field__error" role="alert">
          <span aria-hidden="true" className="form-field__error-icon">!</span>
          {error}
        </p>
      )}
    </div>
  );
}
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
- [ ] Focus moves to first error on submit failure
- [ ] Inline errors use role="alert" for screen reader announcement
- [ ] Error messages are specific and actionable ("Enter a valid email" not "Invalid")

Keyboard:
- [ ] All fields reachable via Tab key
- [ ] Tab order matches visual order
- [ ] Custom components (date picker, combobox) follow WAI-ARIA patterns
- [ ] Enter submits the form from any field
- [ ] Escape closes dropdowns/popovers without losing data
- [ ] Focus visible on all interactive elements

Screen Reader:
- [ ] Form has accessible name (aria-label or aria-labelledby)
- [ ] Field type is announced (text, email, password, checkbox)
- [ ] Required state is announced
- [ ] Error state is announced on focus
- [ ] Submit button text describes the action ("Create Account" not "Submit")
- [ ] Loading state is announced (aria-busy or live region)
- [ ] Success/failure result is announced

Visual:
- [ ] Labels are always visible (no floating label that disappears)
- [ ] Error states have high contrast (4.5:1 ratio)
- [ ] Focus indicators are visible (3:1 contrast, 2px+ thickness)
- [ ] Touch targets are at least 44x44 CSS pixels
- [ ] Form works at 200% zoom without horizontal scroll
```

#### Focus Management
```typescript
// hooks/useFocusOnError.ts
import { useEffect, useRef } from 'react';
import { FieldErrors } from 'react-hook-form';

export function useFocusOnError(errors: FieldErrors, isSubmitted: boolean) {
  const prevSubmitCount = useRef(0);

  useEffect(() => {
    if (!isSubmitted) return;

    const errorKeys = Object.keys(errors);
    if (errorKeys.length === 0) return;

    // Focus first field with error
    const firstErrorField = document.querySelector(
      `[name="${errorKeys[0]}"], #${errorKeys[0]}`
    );

    if (firstErrorField instanceof HTMLElement) {
      firstErrorField.focus();
      firstErrorField.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, [errors, isSubmitted]);
}
```

#### Error Summary Component
```typescript
// components/ErrorSummary.tsx
export function ErrorSummary({ errors }: { errors: Record<string, string> }) {
  const errorEntries = Object.entries(errors);
  if (errorEntries.length === 0) return null;

  return (
    <div role="alert" aria-labelledby="error-summary-title" className="error-summary">
      <h2 id="error-summary-title" className="error-summary__title">
        There {errorEntries.length === 1 ? 'is 1 error' : `are ${errorEntries.length} errors`} in this form
      </h2>
      <ul className="error-summary__list">
        {errorEntries.map(([field, message]) => (
          <li key={field}>
            <a href={`#${field}`} className="error-summary__link">
              {message}
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### Step 7: Advanced Patterns

#### Conditional Fields
```typescript
// Show/hide fields based on other field values
const watchRole = watch('role');

return (
  <form>
    <FormField label="Role" required>
      <select {...register('role')}>
        <option value="">Select a role</option>
        <option value="user">User</option>
        <option value="admin">Admin</option>
      </select>
    </FormField>

    {watchRole === 'admin' && (
      <FormField label="Admin Access Code" required>
        <input {...register('adminCode')} type="text" />
      </FormField>
    )}
  </form>
);
```

#### Dynamic Field Arrays
```typescript
// Add/remove fields dynamically
import { useFieldArray } from 'react-hook-form';

function PhoneNumbersForm() {
  const { control, register } = useForm({
    defaultValues: { phones: [{ number: '', type: 'mobile' }] },
  });

  const { fields, append, remove } = useFieldArray({ control, name: 'phones' });

  return (
    <fieldset>
      <legend>Phone Numbers</legend>
      {fields.map((field, index) => (
        <div key={field.id} className="field-array-row">
          <FormField label={`Phone ${index + 1}`}>
            <input {...register(`phones.${index}.number`)} type="tel" />
          </FormField>
          <FormField label="Type">
            <select {...register(`phones.${index}.type`)}>
              <option value="mobile">Mobile</option>
              <option value="home">Home</option>
              <option value="work">Work</option>
            </select>
          </FormField>
          {fields.length > 1 && (
            <button type="button" onClick={() => remove(index)} aria-label={`Remove phone ${index + 1}`}>
              Remove
            </button>
          )}
        </div>
      ))}
      <button type="button" onClick={() => append({ number: '', type: 'mobile' })}>
        Add Phone Number
      </button>
    </fieldset>
  );
}
```

#### Autosave
```typescript
// hooks/useAutosave.ts
import { useEffect, useRef } from 'react';
import { UseFormWatch } from 'react-hook-form';

export function useAutosave<T extends Record<string, any>>({
  watch,
  onSave,
  debounceMs = 2000,
  enabled = true,
}: {
  watch: UseFormWatch<T>;
  onSave: (data: T) => Promise<void>;
  debounceMs?: number;
  enabled?: boolean;
}) {
  const timeoutRef = useRef<NodeJS.Timeout>();
  const [saveStatus, setSaveStatus] = useState<'idle' | 'saving' | 'saved' | 'error'>('idle');

  useEffect(() => {
    if (!enabled) return;

    const subscription = watch((data) => {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = setTimeout(async () => {
        try {
          setSaveStatus('saving');
          await onSave(data as T);
          setSaveStatus('saved');
          setTimeout(() => setSaveStatus('idle'), 2000);
        } catch {
          setSaveStatus('error');
        }
      }, debounceMs);
    });

    return () => {
      subscription.unsubscribe();
      clearTimeout(timeoutRef.current);
    };
  }, [watch, onSave, debounceMs, enabled]);

  return saveStatus;
}
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
│   Schema shared: YES / NO (client + server same schema)       │
│                                                               │
│ Accessibility:                                                │
│   Labels: <N>/<N> fields have visible labels                  │
│   Errors: <N>/<N> fields have aria-describedby errors         │
│   Focus management: YES / NO                                  │
│   Error summary: YES / NO                                     │
│   Keyboard navigable: YES / NO                                │
│   Screen reader tested: YES / NO                              │
│                                                               │
│ UX Patterns:                                                  │
│   Autosave: YES / NO                                          │
│   Progress persistence: YES / NO                              │
│   File uploads: YES / NO                                      │
│   Conditional fields: YES / NO                                │
│   Dynamic arrays: YES / NO                                    │
│                                                               │
│ Verdict: SOLID / NEEDS WORK / FRAGILE                         │
└──────────────────────────────────────────────────────────────┘
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
4. **Every field has a visible label.** Placeholder text is not a label. Floating labels that disappear are not acceptable. Labels must be always visible, always associated via htmlFor/id.
5. **Multi-step forms persist state.** Navigating back must restore previous values. Page refresh should not lose progress (use sessionStorage). Only clear on successful submission.
6. **File uploads need comprehensive validation.** Check file type, file size, and file count before uploading. Show progress. Provide preview for images. Make the drop zone keyboard-accessible.
7. **Form state libraries exist for a reason.** For anything beyond 3 fields, use React Hook Form (or equivalent). Manual state management with useState leads to re-render storms, validation inconsistency, and lost edge cases.

## Example Usage

### Build a multi-step registration form
```
User: /godmode:forms

Forms: Analyzing form requirements...

FORM REQUIREMENTS ASSESSMENT:
Form: User Registration
Fields: 12 total
Steps: 3 (Personal Info, Account Setup, Preferences)
File uploads: 1 (avatar, optional)
Async validation: 1 (email uniqueness)
Autosave: No (security — contains password)

Building form architecture...
  Schema: schemas/registration.ts (Zod, 3 step schemas + full)
  Hook: hooks/useWizardForm.ts (step navigation, persistence)
  Components:
    RegistrationWizard.tsx (orchestrator)
    PersonalInfoStep.tsx (name, email, phone)
    AccountSetupStep.tsx (username, password, confirm)
    PreferencesStep.tsx (role, avatar, notifications)
    ReviewStep.tsx (summary before submit)
    StepProgress.tsx (visual step indicator)

Accessibility:
  All fields: visible labels, aria-describedby errors
  Focus management: auto-focus first field on step change
  Error summary: shown on submit failure
  Keyboard: full tab navigation, Enter to advance
  Screen reader: step progress announced, errors announced

Validation:
  Client: Zod schema per step + full schema on review
  Server: Same Zod schema in API route
  Async: Email uniqueness check (debounced 500ms)

Verdict: SOLID — fully accessible, validated, multi-step form.
```

### Audit an existing form
```
User: /godmode:forms --audit

Forms: Auditing existing forms...

Found 4 forms:
1. Login form (2 fields) — SOLID
2. Registration form (8 fields) — NEEDS WORK
   - Missing: aria-invalid on error fields
   - Missing: Focus on first error on submit
   - Missing: Server-side validation
3. Settings form (15 fields) — FRAGILE
   - No form library (manual useState x15)
   - No validation schema
   - Placeholder text used as labels
   - No error messages
4. Checkout form (12 fields) — NEEDS WORK
   - Good: React Hook Form + Zod
   - Missing: Multi-step persistence
   - Missing: Error summary component

Priority fixes:
1. Settings form: Migrate to React Hook Form, add labels and validation
2. Registration: Add aria-invalid, focus management, server validation
3. Checkout: Add sessionStorage persistence, error summary
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full form architecture — build or audit |
| `--audit` | Audit all existing forms for completeness |
| `--wizard` | Build a multi-step wizard form |
| `--validation` | Focus on validation patterns (client + server + async) |
| `--upload` | File upload implementation |
| `--a11y` | Form accessibility audit only |
| `--schema <name>` | Generate a Zod validation schema |
| `--migrate` | Migrate from manual state to React Hook Form |
| `--autosave` | Add autosave to an existing form |

## Auto-Detection

On activation, automatically detect the form development context:

```
AUTO-DETECT SEQUENCE:
1. Detect UI framework: React (react-dom), Vue, Angular, Svelte, vanilla
2. Check for form library: react-hook-form, formik, @angular/forms, vee-validate
3. Detect validation library: zod, yup, joi, class-validator, valibot
4. Scan for existing form components: *Form.tsx, *Form.vue, *-form.component.ts
5. Check for schema definitions: *.schema.ts, *.validation.ts files
6. Detect Next.js server actions (useActionState, useFormState imports)
7. Scan for file upload patterns: <input type="file">, drag-and-drop libraries
8. Check for accessibility: aria-invalid, aria-describedby, role="alert" usage
9. Detect multi-step patterns: step/wizard state management, sessionStorage usage
10. Check for server-side validation: API route handlers with schema validation
```

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
       b. CHECK: errors use aria-describedby and role="alert"
       c. CHECK: focus moves to first error on submit failure
       d. CHECK: server-side validation exists with same schema
       e. CHECK: keyboard navigation works (Tab order, Enter submit)
       f. REPORT findings as SOLID / NEEDS WORK / FRAGILE
  4. RUN accessibility checklist (Step 6)
  5. current_iteration += 1
  6. REPORT: "Form <N>/<total>: <name> — <verdict>"

ON COMPLETION:
  REPORT: "<N> forms processed, <M> SOLID, <K> NEEDS WORK, <J> FRAGILE"
```

## Multi-Agent Dispatch

For large form-heavy applications, dispatch parallel agents:

```
PARALLEL FORM AGENTS:
When building multiple complex forms simultaneously:

Agent 1 (worktree: forms-schemas):
  - Design all Zod schemas (shared between client and server)
  - Create reusable validation patterns (email, phone, address, payment)
  - Build schema tests (valid input, invalid input, edge cases)

Agent 2 (worktree: forms-components):
  - Build reusable form components (FormField, ErrorSummary, StepProgress, FileUpload)
  - Implement useWizardForm, useAutosave, useAsyncValidation hooks
  - Ensure WCAG 2.1 AA compliance on all components

Agent 3 (worktree: forms-pages):
  - Assemble page-level forms using schemas and components
  - Implement server-side validation in API routes
  - Write E2E tests for complete form flows (submit, validation, multi-step)

MERGE STRATEGY: Schemas merge first. Components rebase onto schemas.
  Pages rebase onto components. Final: run full accessibility audit and E2E tests.
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

## Anti-Patterns

- **Do NOT use placeholder as a label.** Placeholder text disappears on focus, is low contrast, and is not announced by all screen readers as a label. Every field needs a real `<label>`.
- **Do NOT validate only on submit.** Waiting until the user presses submit to show 8 errors is hostile. Validate on blur for immediate, field-level feedback.
- **Do NOT skip server-side validation.** Client-side validation is bypassed by disabling JavaScript, using curl, or modifying the DOM. Server validation is the only validation that matters for security.
- **Do NOT use onChange validation for first visit.** Showing "Email is required" as the user types their first character is annoying. Use onBlur for first validation, onChange for re-validation after an error.
- **Do NOT lose wizard form data on back navigation.** Users expect to go back and see their previous answers. Persist step data in state and restore it when they return to a previous step.
- **Do NOT use alert() for form errors.** Alerts block the UI, are not accessible, and cannot be styled. Use inline errors with aria-describedby and an error summary component.
- **Do NOT accept any file upload without validation.** Check file type (MIME + extension), file size, and count. A 500MB file or a .exe disguised as a .jpg will cause problems.
- **Do NOT manage 10+ fields with useState.** Manual state management for complex forms leads to stale closures, re-render cascades, and missed validations. Use a form library.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run form tasks sequentially: schemas/validation, then components, then page integration.
- Use branch isolation per task: `git checkout -b godmode-forms-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
