---
name: designsystem
description: |
  Design system architecture skill. Activates when user needs to build, maintain, or audit a design system including token architecture (colors, spacing, typography, shadows), component API standards, theme systems (light/dark, custom), design-to-code pipelines (Figma tokens to CSS variables), versioning and distribution, and Storybook documentation. Triggers on: /godmode:designsystem, "design system", "design tokens", "theme architecture", "Figma to code", or when building a shared component library.
---

# Design System — Design System Architecture

## When to Activate
- User invokes `/godmode:designsystem`
- User says "design system," "design tokens," "theme architecture," "Figma to code"
- When creating a new shared component library or design system package
- When establishing token architecture (colors, spacing, typography, shadows)
- When building theme support (light/dark mode, multi-brand theming)
- When setting up a design-to-code pipeline from Figma
- When versioning and distributing a design system package
- When auditing an existing design system for consistency and coverage

## Workflow

### Step 1: Assess Current State
Survey the existing design system (or absence of one):

```
DESIGN SYSTEM ASSESSMENT:
Project: <project name>
Framework: <React/Vue/Angular/Svelte/Web Components>
Existing system: <none/partial/mature>

Token coverage:
  Colors:     <defined/partial/none>
  Spacing:    <defined/partial/none>
  Typography: <defined/partial/none>
  Shadows:    <defined/partial/none>
  Borders:    <defined/partial/none>
  Motion:     <defined/partial/none>
  Z-index:    <defined/partial/none>
  Breakpoints:<defined/partial/none>

Theme support: <none/light-dark/multi-brand>
Component count: <N>
Storybook: <yes (version)/no>
Distribution: <monorepo/npm package/CDN/none>
Figma integration: <yes/no>

Maturity: <NONE | STARTER | GROWING | MATURE>
```

Maturity definitions:
- **NONE**: No tokens, no shared components, ad-hoc styling everywhere.
- **STARTER**: Some tokens exist, a handful of shared components, inconsistent usage.
- **GROWING**: Comprehensive tokens, growing component library, partial Storybook, no formal distribution.
- **MATURE**: Complete tokens, documented components, full Storybook, versioned distribution, Figma sync.

### Step 2: Token Architecture
Design or audit the token system — the foundation of every design system.

#### Token Taxonomy
Tokens follow a three-tier architecture:

```
TIER 1: PRIMITIVE TOKENS (raw values)
  --primitive-blue-500: #3b82f6;
  --primitive-gray-100: #f3f4f6;
  --primitive-space-4: 1rem;
  --primitive-font-size-lg: 1.125rem;
  --primitive-shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);

TIER 2: SEMANTIC TOKENS (meaning mapped to primitives)
  --color-primary: var(--primitive-blue-500);
  --color-surface: var(--primitive-gray-100);
  --spacing-md: var(--primitive-space-4);
  --font-size-body: var(--primitive-font-size-lg);
  --shadow-card: var(--primitive-shadow-md);

TIER 3: COMPONENT TOKENS (component-specific, mapped to semantic)
  --button-bg: var(--color-primary);
  --button-padding-x: var(--spacing-md);
  --card-shadow: var(--shadow-card);
  --input-font-size: var(--font-size-body);
```

#### Color Token Architecture
```css
/* primitives/colors.css */
:root {
  /* Neutral scale */
  --primitive-gray-50: #f9fafb;
  --primitive-gray-100: #f3f4f6;
  --primitive-gray-200: #e5e7eb;
  --primitive-gray-300: #d1d5db;
  --primitive-gray-400: #9ca3af;
  --primitive-gray-500: #6b7280;
  --primitive-gray-600: #4b5563;
  --primitive-gray-700: #374151;
  --primitive-gray-800: #1f2937;
  --primitive-gray-900: #111827;
  --primitive-gray-950: #030712;

  /* Brand scale */
  --primitive-brand-50: #eff6ff;
  --primitive-brand-100: #dbeafe;
  --primitive-brand-200: #bfdbfe;
  --primitive-brand-300: #93c5fd;
  --primitive-brand-400: #60a5fa;
  --primitive-brand-500: #3b82f6;
  --primitive-brand-600: #2563eb;
  --primitive-brand-700: #1d4ed8;
  --primitive-brand-800: #1e40af;
  --primitive-brand-900: #1e3a8a;

  /* Feedback colors */
  --primitive-red-500: #ef4444;
  --primitive-red-600: #dc2626;
  --primitive-green-500: #22c55e;
  --primitive-green-600: #16a34a;
  --primitive-amber-500: #f59e0b;
  --primitive-amber-600: #d97706;
}

/* semantic/colors.css */
:root {
  /* Surface and background */
  --color-bg: var(--primitive-gray-50);
  --color-surface: white;
  --color-surface-raised: white;
  --color-surface-overlay: white;

  /* Text */
  --color-text-primary: var(--primitive-gray-900);
  --color-text-secondary: var(--primitive-gray-600);
  --color-text-tertiary: var(--primitive-gray-400);
  --color-text-inverse: white;
  --color-text-link: var(--primitive-brand-600);

  /* Brand / action */
  --color-primary: var(--primitive-brand-600);
  --color-primary-hover: var(--primitive-brand-700);
  --color-primary-active: var(--primitive-brand-800);

  /* Feedback */
  --color-error: var(--primitive-red-600);
  --color-error-bg: var(--primitive-red-50, #fef2f2);
  --color-success: var(--primitive-green-600);
  --color-success-bg: var(--primitive-green-50, #f0fdf4);
  --color-warning: var(--primitive-amber-600);
  --color-warning-bg: var(--primitive-amber-50, #fffbeb);

  /* Borders */
  --color-border: var(--primitive-gray-200);
  --color-border-strong: var(--primitive-gray-300);
  --color-border-focus: var(--primitive-brand-500);
}
```

#### Spacing Token Architecture
```css
/* semantic/spacing.css */
:root {
  --spacing-0: 0;
  --spacing-px: 1px;
  --spacing-0-5: 0.125rem;  /* 2px */
  --spacing-1: 0.25rem;     /* 4px */
  --spacing-1-5: 0.375rem;  /* 6px */
  --spacing-2: 0.5rem;      /* 8px */
  --spacing-3: 0.75rem;     /* 12px */
  --spacing-4: 1rem;        /* 16px — base unit */
  --spacing-5: 1.25rem;     /* 20px */
  --spacing-6: 1.5rem;      /* 24px */
  --spacing-8: 2rem;        /* 32px */
  --spacing-10: 2.5rem;     /* 40px */
  --spacing-12: 3rem;       /* 48px */
  --spacing-16: 4rem;       /* 64px */
  --spacing-20: 5rem;       /* 80px */
  --spacing-24: 6rem;       /* 96px */
}
```

#### Typography Token Architecture
```css
/* semantic/typography.css */
:root {
  /* Font families */
  --font-sans: 'Inter', system-ui, -apple-system, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace;

  /* Font sizes (modular scale 1.25) */
  --font-size-xs: 0.75rem;    /* 12px */
  --font-size-sm: 0.875rem;   /* 14px */
  --font-size-base: 1rem;     /* 16px */
  --font-size-lg: 1.125rem;   /* 18px */
  --font-size-xl: 1.25rem;    /* 20px */
  --font-size-2xl: 1.5rem;    /* 24px */
  --font-size-3xl: 1.875rem;  /* 30px */
  --font-size-4xl: 2.25rem;   /* 36px */
  --font-size-5xl: 3rem;      /* 48px */

  /* Font weights */
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  /* Line heights */
  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;

  /* Letter spacing */
  --letter-spacing-tight: -0.025em;
  --letter-spacing-normal: 0;
  --letter-spacing-wide: 0.025em;

  /* Composite text styles */
  --text-heading-1: var(--font-weight-bold) var(--font-size-4xl)/var(--line-height-tight) var(--font-sans);
  --text-heading-2: var(--font-weight-bold) var(--font-size-3xl)/var(--line-height-tight) var(--font-sans);
  --text-heading-3: var(--font-weight-semibold) var(--font-size-2xl)/var(--line-height-tight) var(--font-sans);
  --text-body: var(--font-weight-normal) var(--font-size-base)/var(--line-height-normal) var(--font-sans);
  --text-caption: var(--font-weight-normal) var(--font-size-sm)/var(--line-height-normal) var(--font-sans);
}
```

#### Shadow Token Architecture
```css
/* semantic/shadows.css */
:root {
  --shadow-xs: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-sm: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
  --shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);
  --shadow-none: 0 0 #0000;

  /* Focused elements */
  --shadow-focus: 0 0 0 3px var(--color-border-focus);
}
```

### Step 3: Component API Design Standards
Define the conventions every component in the system must follow:

#### Component API Contract
```
COMPONENT API STANDARDS:

1. PROP NAMING:
   - variant: Visual style — "primary" | "secondary" | "ghost" | "danger"
   - size: Dimensions — "sm" | "md" | "lg" | "xl"
   - color: Color intent — "brand" | "neutral" | "error" | "success" | "warning"
   - children: Content via composition, never "text" or "content" props
   - className: Style escape hatch, always accepted
   - asChild: Render delegation (Radix pattern) for polymorphism

2. TYPING:
   - Extend native HTML element props (ButtonHTMLAttributes, InputHTMLAttributes)
   - Export all prop types from <Component>.types.ts
   - Use discriminated unions for variant-dependent props
   - Never use `any` — use `unknown` with type guards if needed

3. REF FORWARDING:
   - Every component wrapping a native element must use forwardRef
   - Set displayName on all forwardRef components

4. COMPOSITION:
   - Prefer compound components: <Card><Card.Header /><Card.Body /></Card>
   - Use context for compound component communication
   - Support render props for advanced customization
   - Slot pattern for content injection

5. DEFAULTS:
   - Every optional prop has a sensible default
   - variant defaults to "primary" or "default"
   - size defaults to "md"
   - Disabled defaults to false

6. EVENTS:
   - Follow on<Event> convention: onClick, onChange, onClose
   - Event handlers receive native event plus component-specific data
   - Provide controlled and uncontrolled modes for stateful components
```

#### Compound Component Pattern
```typescript
// Card.tsx — Compound component example
import { createContext, useContext, forwardRef } from 'react';

interface CardContextValue {
  variant: 'elevated' | 'outlined' | 'filled';
}

const CardContext = createContext<CardContextValue>({ variant: 'elevated' });

export const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ variant = 'elevated', children, className, ...props }, ref) => (
    <CardContext.Provider value={{ variant }}>
      <div ref={ref} className={clsx(styles.card, styles[variant], className)} {...props}>
        {children}
      </div>
    </CardContext.Provider>
  )
);

Card.Header = forwardRef<HTMLDivElement, CardHeaderProps>(
  ({ children, className, ...props }, ref) => {
    const { variant } = useContext(CardContext);
    return (
      <div ref={ref} className={clsx(styles.header, styles[`header-${variant}`], className)} {...props}>
        {children}
      </div>
    );
  }
);

Card.Body = forwardRef<HTMLDivElement, CardBodyProps>(
  ({ children, className, ...props }, ref) => (
    <div ref={ref} className={clsx(styles.body, className)} {...props}>
      {children}
    </div>
  )
);

Card.Footer = forwardRef<HTMLDivElement, CardFooterProps>(
  ({ children, className, ...props }, ref) => (
    <div ref={ref} className={clsx(styles.footer, className)} {...props}>
      {children}
    </div>
  )
);

Card.displayName = 'Card';
Card.Header.displayName = 'Card.Header';
Card.Body.displayName = 'Card.Body';
Card.Footer.displayName = 'Card.Footer';
```

### Step 4: Theme System
Build or audit the theming infrastructure:

#### Light/Dark Theme via CSS Custom Properties
```css
/* themes/light.css */
:root, [data-theme="light"] {
  --color-bg: #ffffff;
  --color-surface: #ffffff;
  --color-surface-raised: #ffffff;
  --color-text-primary: var(--primitive-gray-900);
  --color-text-secondary: var(--primitive-gray-600);
  --color-border: var(--primitive-gray-200);
  --color-primary: var(--primitive-brand-600);
  --shadow-card: var(--shadow-sm);
}

/* themes/dark.css */
[data-theme="dark"] {
  --color-bg: var(--primitive-gray-950);
  --color-surface: var(--primitive-gray-900);
  --color-surface-raised: var(--primitive-gray-800);
  --color-text-primary: var(--primitive-gray-50);
  --color-text-secondary: var(--primitive-gray-400);
  --color-border: var(--primitive-gray-700);
  --color-primary: var(--primitive-brand-400);
  --shadow-card: 0 4px 6px -1px rgb(0 0 0 / 0.3);
}
```

#### Theme Provider (React)
```typescript
// ThemeProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'light' | 'dark' | 'system';

interface ThemeContextValue {
  theme: Theme;
  resolvedTheme: 'light' | 'dark';
  setTheme: (theme: Theme) => void;
}

const ThemeContext = createContext<ThemeContextValue | undefined>(undefined);

export function ThemeProvider({ children, defaultTheme = 'system' }: { children: React.ReactNode; defaultTheme?: Theme }) {
  const [theme, setTheme] = useState<Theme>(() => {
    if (typeof window === 'undefined') return defaultTheme;
    return (localStorage.getItem('theme') as Theme) ?? defaultTheme;
  });

  const resolvedTheme = theme === 'system'
    ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
    : theme;

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', resolvedTheme);
    localStorage.setItem('theme', theme);
  }, [theme, resolvedTheme]);

  useEffect(() => {
    if (theme !== 'system') return;
    const mql = window.matchMedia('(prefers-color-scheme: dark)');
    const handler = () => setTheme('system'); // triggers re-resolve
    mql.addEventListener('change', handler);
    return () => mql.removeEventListener('change', handler);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme, resolvedTheme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}
```

#### Multi-Brand Theming
```css
/* For white-label / multi-brand products */
[data-brand="acme"] {
  --primitive-brand-500: #e11d48;
  --primitive-brand-600: #be123c;
  --primitive-brand-700: #9f1239;
  --font-sans: 'Poppins', system-ui, sans-serif;
  --border-radius-md: 0.75rem;
}

[data-brand="globex"] {
  --primitive-brand-500: #059669;
  --primitive-brand-600: #047857;
  --primitive-brand-700: #065f46;
  --font-sans: 'DM Sans', system-ui, sans-serif;
  --border-radius-md: 0.25rem;
}
```

```
THEME SYSTEM AUDIT:
┌──────────────────────────────────────────────────────────────┐
│ Capability               │ Status    │ Notes                 │
├──────────────────────────────────────────────────────────────┤
│ Light theme              │ YES/NO    │                       │
│ Dark theme               │ YES/NO    │                       │
│ System preference        │ YES/NO    │ prefers-color-scheme  │
│ Theme persistence        │ YES/NO    │ localStorage          │
│ No flash on load         │ YES/NO    │ Blocking script/SSR   │
│ Multi-brand support      │ YES/NO    │ data-brand attribute  │
│ All tokens themed        │ YES/NO    │ <N> hardcoded values  │
│ Smooth transitions       │ YES/NO    │ color transitions     │
│ Storybook theme toggle   │ YES/NO    │ Theme addon           │
│ Theme-aware components   │ YES/NO    │ Use tokens not colors │
└──────────────────────────────────────────────────────────────┘
```

### Step 5: Design-to-Code Pipeline
Establish the Figma tokens to CSS variables pipeline:

#### Pipeline Architecture
```
DESIGN-TO-CODE PIPELINE:

Figma (source of truth)
  │
  ├── Figma Variables / Tokens Studio plugin
  │     └── Exports: tokens.json (W3C Design Token Format)
  │
  ├── Style Dictionary (transformer)
  │     ├── Input: tokens.json
  │     ├── Transforms: name/cti, size/rem, color/css
  │     └── Outputs:
  │           ├── css/variables.css (CSS custom properties)
  │           ├── js/tokens.ts (TypeScript constants)
  │           ├── scss/variables.scss (SCSS variables)
  │           └── tailwind/tokens.js (Tailwind config extension)
  │
  ├── CI/CD automation
  │     ├── Figma webhook → trigger pipeline
  │     ├── Generate outputs → PR to design-system repo
  │     └── Visual regression test → approve/reject
  │
  └── Consumers
        ├── App imports CSS: @import '@acme/tokens/css/variables.css'
        ├── App imports TS: import { colorPrimary } from '@acme/tokens'
        └── Tailwind extends config: require('@acme/tokens/tailwind')
```

#### Style Dictionary Configuration
```javascript
// style-dictionary.config.js
module.exports = {
  source: ['tokens/**/*.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'dist/css/',
      files: [{
        destination: 'variables.css',
        format: 'css/variables',
        options: { outputReferences: true },
      }],
    },
    typescript: {
      transformGroup: 'js',
      buildPath: 'dist/ts/',
      files: [{
        destination: 'tokens.ts',
        format: 'javascript/es6',
      }],
    },
    tailwind: {
      transformGroup: 'js',
      buildPath: 'dist/tailwind/',
      files: [{
        destination: 'tokens.js',
        format: 'javascript/module',
      }],
    },
  },
};
```

#### Figma Sync Automation
```bash
# Install Figma token tools
npm install --save-dev style-dictionary token-transformer

# Extract tokens from Figma Tokens Studio export
npx token-transformer tokens/figma-export.json tokens/transformed.json

# Build all platforms
npx style-dictionary build --config style-dictionary.config.js

# Verify output
ls dist/css/variables.css dist/ts/tokens.ts dist/tailwind/tokens.js
```

```
PIPELINE STATUS:
┌────────────────────────────────────────────────────────┐
│ Stage                │ Status │ Tool                   │
├────────────────────────────────────────────────────────┤
│ Figma token export   │ OK/MISSING │ Tokens Studio / Variables │
│ Token format         │ OK/MISSING │ W3C Design Token Format   │
│ Transformer          │ OK/MISSING │ Style Dictionary          │
│ CSS output           │ OK/MISSING │ variables.css             │
│ TS output            │ OK/MISSING │ tokens.ts                 │
│ Tailwind output      │ OK/MISSING │ tailwind config           │
│ CI automation        │ OK/MISSING │ GitHub Action / webhook   │
│ Visual regression    │ OK/MISSING │ Chromatic / Percy         │
└────────────────────────────────────────────────────────┘
```

### Step 6: Versioning and Distribution
Set up the design system as a versioned, distributable package:

#### Package Structure
```
@acme/design-system/
├── package.json
├── CHANGELOG.md
├── dist/
│   ├── css/
│   │   ├── tokens.css        # All CSS custom properties
│   │   └── components.css    # Component styles (if CSS-based)
│   ├── js/
│   │   ├── index.js          # Component exports (CJS)
│   │   ├── index.mjs         # Component exports (ESM)
│   │   └── index.d.ts        # TypeScript declarations
│   └── tokens/
│       ├── tokens.css
│       ├── tokens.ts
│       └── tailwind.js
├── src/
│   ├── components/
│   ├── tokens/
│   └── themes/
└── .storybook/
```

#### Semantic Versioning for Design Systems
```
VERSIONING RULES:
MAJOR (X.0.0) — Breaking changes:
  - Removing a token
  - Renaming a component
  - Changing a component's default behavior
  - Removing a prop from a component API
  - Changing token values that affect layout (spacing, sizing)

MINOR (0.X.0) — New features:
  - Adding a new component
  - Adding a new token
  - Adding a new variant to an existing component
  - Adding a new prop (with default value)
  - Adding a new theme

PATCH (0.0.X) — Bug fixes:
  - Fixing a token value (color correction, spacing fix)
  - Fixing a component rendering bug
  - Fixing accessibility issues
  - Fixing documentation
```

#### Release Workflow
```bash
# 1. Version bump
npm version minor -m "Release %s — add DatePicker component"

# 2. Build
npm run build

# 3. Generate changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s

# 4. Publish
npm publish --access public

# 5. Deploy Storybook
npm run storybook:build && npx chromatic --project-token=$TOKEN

# 6. Notify consumers
# CI sends PR to consuming repos bumping dependency version
```

### Step 7: Storybook Documentation
Configure Storybook as the living documentation for the design system:

#### Storybook Configuration
```bash
# Initialize Storybook
npx storybook@latest init

# Add essential addons
npm install --save-dev \
  @storybook/addon-a11y \
  @storybook/addon-viewport \
  @storybook/addon-docs \
  @storybook/addon-designs \
  @storybook/addon-measure \
  @storybook/addon-outline
```

#### Documentation Pages
```
STORYBOOK STRUCTURE:
├── Introduction
│   ├── Getting Started
│   ├── Installation
│   └── Design Principles
├── Foundations
│   ├── Colors (token swatches + usage)
│   ├── Typography (scale + examples)
│   ├── Spacing (scale + usage)
│   ├── Shadows (examples)
│   ├── Icons (icon set + usage)
│   └── Motion (easing + duration tokens)
├── Components
│   ├── Atoms (Button, Input, Label, Badge, Icon, Avatar)
│   ├── Molecules (FormField, SearchBar, Card, Alert, Toast)
│   ├── Organisms (Header, Sidebar, DataTable, Modal, Drawer)
│   └── Templates (DashboardLayout, AuthLayout, SettingsLayout)
├── Patterns
│   ├── Forms (validation, layout, multi-step)
│   ├── Navigation (tabs, breadcrumbs, sidebar)
│   ├── Data Display (tables, lists, charts)
│   └── Feedback (loading, errors, empty states)
└── Theming
    ├── Light/Dark Toggle
    ├── Custom Theme Guide
    └── Brand Customization
```

#### Token Documentation Story
```typescript
// stories/Foundations/Colors.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';

const meta: Meta = {
  title: 'Foundations/Colors',
  parameters: {
    docs: {
      description: {
        component: 'Color tokens define the visual language. Use semantic tokens in components, never primitive values directly.',
      },
    },
  },
};

export default meta;

function ColorSwatch({ name, variable }: { name: string; variable: string }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '0.5rem' }}>
      <div style={{
        width: 48, height: 48, borderRadius: 8,
        backgroundColor: `var(${variable})`,
        border: '1px solid var(--color-border)',
      }} />
      <div>
        <div style={{ fontWeight: 600 }}>{name}</div>
        <code style={{ fontSize: '0.875rem', color: 'var(--color-text-secondary)' }}>{variable}</code>
      </div>
    </div>
  );
}

export const SemanticColors: StoryObj = {
  render: () => (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
      <div>
        <h3>Text</h3>
        <ColorSwatch name="Primary" variable="--color-text-primary" />
        <ColorSwatch name="Secondary" variable="--color-text-secondary" />
        <ColorSwatch name="Tertiary" variable="--color-text-tertiary" />
        <ColorSwatch name="Link" variable="--color-text-link" />
      </div>
      <div>
        <h3>Feedback</h3>
        <ColorSwatch name="Error" variable="--color-error" />
        <ColorSwatch name="Success" variable="--color-success" />
        <ColorSwatch name="Warning" variable="--color-warning" />
      </div>
    </div>
  ),
};
```

### Step 8: Design System Audit Report

```
DESIGN SYSTEM AUDIT:
┌──────────────────────────────────────────────────────────────┐
│ Token Coverage                                                │
│   Colors:     <N>/<N> used (<X>% coverage, <N> hardcoded)     │
│   Spacing:    <N>/<N> used (<X>% coverage, <N> hardcoded)     │
│   Typography: <N>/<N> used (<X>% coverage, <N> hardcoded)     │
│   Shadows:    <N>/<N> used (<X>% coverage, <N> hardcoded)     │
│                                                               │
│ Component API Compliance                                      │
│   Standards-compliant: <N>/<N> components                     │
│   Missing ref forwarding: <N>                                 │
│   Missing TypeScript types: <N>                               │
│   Inconsistent prop naming: <N>                               │
│                                                               │
│ Theme System                                                  │
│   Light theme: COMPLETE / PARTIAL / NONE                      │
│   Dark theme: COMPLETE / PARTIAL / NONE                       │
│   System preference: YES / NO                                 │
│   Persistence: YES / NO                                       │
│   Flash-free: YES / NO                                        │
│                                                               │
│ Pipeline                                                      │
│   Figma sync: AUTOMATED / MANUAL / NONE                       │
│   Token transformation: YES / NO                              │
│   CI integration: YES / NO                                    │
│                                                               │
│ Documentation                                                 │
│   Storybook coverage: <X>%                                    │
│   Token docs: YES / NO                                        │
│   Usage guidelines: YES / NO                                  │
│                                                               │
│ Distribution                                                  │
│   Versioned package: YES / NO                                 │
│   Semantic versioning: YES / NO                               │
│   Changelog: YES / NO                                         │
│                                                               │
│ Maturity: NONE / STARTER / GROWING / MATURE                   │
│ Score: <N>/100                                                │
└──────────────────────────────────────────────────────────────┘
```

Scoring:
- Token architecture: 0-25 points
- Component API standards: 0-20 points
- Theme system: 0-15 points
- Pipeline: 0-15 points
- Documentation: 0-15 points
- Distribution: 0-10 points

### Step 9: Remediation Plan
For each gap found in the audit:

```
REMEDIATION PLAN:
Priority 1 (Critical — blocks adoption):
  - [ ] <action> — <files to create/modify>
  - [ ] <action> — <files to create/modify>

Priority 2 (High — degrades consistency):
  - [ ] <action> — <files to create/modify>
  - [ ] <action> — <files to create/modify>

Priority 3 (Medium — improves DX):
  - [ ] <action> — <files to create/modify>

Priority 4 (Low — polish):
  - [ ] <action> — <files to create/modify>

Estimated effort: <N> days
```

### Step 10: Commit and Transition
1. If tokens were created: `"designsystem: establish token architecture (colors, spacing, typography, shadows)"`
2. If theme system was built: `"designsystem: add light/dark theme support with system preference detection"`
3. If pipeline was configured: `"designsystem: configure Figma-to-CSS token pipeline with Style Dictionary"`
4. If Storybook was set up: `"designsystem: set up Storybook with foundations documentation"`
5. Save report: `docs/designsystem/<project>-design-system-audit.md`
6. Transition: "Design system architecture established. Run `/godmode:ui` for component audit, `/godmode:a11y` for accessibility, or `/godmode:responsive` for responsive design."

## Key Behaviors

1. **Tokens are the single source of truth.** Every visual decision (color, spacing, type, shadow) is a token. Components consume tokens, never raw values. When a designer changes a color, one token update propagates everywhere.
2. **Three-tier token architecture is mandatory.** Primitives define raw values. Semantic tokens map meaning to primitives. Component tokens map components to semantics. Skipping tiers creates coupling that breaks theming.
3. **Component APIs must be predictable.** Every component follows the same prop naming (variant, size, children), the same composition patterns (compound components), and the same TypeScript typing. Consistency reduces cognitive load.
4. **Theming is infrastructure, not decoration.** Dark mode is not "invert the colors." It requires a complete semantic token layer where every surface, text, and border color is a token that maps to different primitives per theme.
5. **The pipeline must be automated.** Manual token syncing between Figma and code is a guaranteed source of drift. Style Dictionary + CI automation ensures the design system and the codebase speak the same language.
6. **Version your design system like a product.** Semantic versioning, changelogs, and migration guides are not optional. Consumers need to know what changed, why, and how to update.
7. **Storybook is the documentation.** If a component is not in Storybook with interactive controls, token documentation, and usage examples, it does not exist. The catalog is the contract.

## Example Usage

### Build a design system from scratch
```
User: /godmode:designsystem

DesignSystem: Analyzing project...

DESIGN SYSTEM ASSESSMENT:
Project: Acme Dashboard
Framework: React 18 + Next.js 14
Existing system: NONE
Token coverage: 0 defined, 47 hardcoded values detected
Theme support: none
Storybook: not installed

Maturity: NONE

Building token architecture...
  Created: tokens/primitives/colors.css (10 color scales)
  Created: tokens/semantic/colors.css (24 semantic tokens)
  Created: tokens/semantic/spacing.css (16 spacing tokens)
  Created: tokens/semantic/typography.css (fonts, sizes, weights)
  Created: tokens/semantic/shadows.css (8 shadow tokens)

Building theme system...
  Created: themes/light.css
  Created: themes/dark.css
  Created: ThemeProvider.tsx with system preference detection

Configuring pipeline...
  Created: style-dictionary.config.js
  Created: .github/workflows/tokens-sync.yml

Setting up Storybook...
  Initialized Storybook v8
  Created: Colors, Typography, Spacing foundation stories

Score: 72/100 (GROWING)
Remaining: Replace 47 hardcoded values, add component token layer.
```

### Audit an existing design system
```
User: /godmode:designsystem --audit

DesignSystem: Auditing existing design system...

Token Coverage: 78% (22 hardcoded values remaining)
Component API Compliance: 14/20 components standards-compliant
Theme System: Light only — dark theme missing
Pipeline: Manual — no automation
Storybook: 65% coverage

Score: 54/100 (GROWING — needs work)

Priority 1: Build dark theme (12 tokens need dark variants)
Priority 2: Automate token pipeline (Style Dictionary + CI)
Priority 3: Fix 6 component API violations (missing ref, inconsistent props)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full design system architecture — build or audit |
| `--audit` | Audit existing design system maturity and coverage |
| `--tokens` | Token architecture only (create or audit) |
| `--theme` | Theme system setup (light/dark/multi-brand) |
| `--pipeline` | Design-to-code pipeline setup (Figma to CSS) |
| `--storybook` | Storybook documentation setup |
| `--version` | Distribution and versioning setup |
| `--api-standards` | Component API standards audit |
| `--init` | Initialize complete design system from scratch |
| `--migrate` | Migrate from hardcoded values to tokens |

## HARD RULES
- NEVER use raw hex/rgb values in component code — always reference semantic tokens
- NEVER skip the semantic token layer — components reference semantics, semantics reference primitives
- NEVER create a component without a corresponding Storybook story
- NEVER publish a design system version without a CHANGELOG entry
- NEVER modify existing token values without a MAJOR version bump if it affects layout
- NEVER allow Figma and code tokens to diverge — pipeline must be automated
- ALL components MUST forward refs and accept className
- ALL token changes MUST go through the three-tier architecture (primitive -> semantic -> component)

## Iterative Audit Loop Protocol
When auditing or building a design system across a large codebase:
```
current_iteration = 0
audit_queue = [all_components_and_files]
WHILE audit_queue is not empty:
    current_iteration += 1
    batch = audit_queue.pop(next 5 files)
    FOR each file in batch:
        scan for hardcoded values (colors, spacing, typography, shadows)
        replace with token references
        verify component API compliance (variant, size, className, ref forwarding)
        log violations found and fixed
    run build + visual regression check
    IF new violations discovered in dependencies:
        add to audit_queue
    report: "Iteration {current_iteration}: {N} files processed, {M} violations fixed, {remaining} files remaining"
```

## Multi-Agent Dispatch
For large design system builds spanning many components, dispatch parallel agents:
```
DISPATCH 4 agents in separate worktrees:
  Agent 1 (tokens):     Build/audit token architecture — primitives, semantics, component tokens, themes
  Agent 2 (components): Audit component API compliance — ref forwarding, prop naming, typing, composition
  Agent 3 (pipeline):   Configure Figma-to-code pipeline — Style Dictionary, CI automation, token sync
  Agent 4 (docs):       Set up Storybook — foundation stories, component stories, theme documentation

SYNC point: All agents complete
  Merge worktrees
  Run full visual regression test
  Generate unified design system audit report
```

## Auto-Detection
On activation, automatically detect the design system context:
```
1. Check for existing design system:
   - Scan for tailwind.config.{js,ts} → extract theme tokens
   - Scan for CSS files with :root or [data-theme] → extract CSS custom properties
   - Scan for tokens.json, tokens.css, design-tokens.* → detect token format
   - Check for style-dictionary.config.* → detect pipeline
   - Check for .storybook/ → detect documentation setup
2. Check for component library:
   - Detect shadcn/ui, radix, chakra, mantine, ant-design, MUI
   - Count components in src/components/ or packages/ui/
   - Scan for compound component patterns (Context + Provider)
3. Check for Figma integration:
   - Look for .figma*, figma-tokens.json, tokens-studio config
4. Determine maturity level automatically:
   - NONE: No tokens found, >10 hardcoded values
   - STARTER: Some tokens, <50% coverage
   - GROWING: Comprehensive tokens, partial Storybook
   - MATURE: Full tokens + themes + Storybook + pipeline
5. Set assessment fields from detection and proceed to Step 1
```

## Output Format

After each design system skill invocation, emit a structured report:

```
DESIGN SYSTEM REPORT:
┌──────────────────────────────────────────────────────┐
│  Tokens             │  <N> primitive / <N> semantic    │
│  Components         │  <N> created / <N> updated       │
│  Themes             │  <N> (light, dark, etc.)         │
│  Storybook stories  │  <N> total                       │
│  Visual tests       │  <N> snapshots                   │
│  Coverage (audit)   │  <N>% of UI uses design tokens   │
│  Figma sync         │  IN SYNC / DRIFTED / N/A         │
│  Bundle impact      │  <N> KB (tokens + components)    │
│  Verdict            │  PASS | NEEDS REVISION           │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every design system action for tracking:

```
timestamp	skill	target	action	tokens_count	components_count	coverage_pct	status
2026-03-20T14:00:00Z	designsystem	tokens	create	48 primitive/24 semantic	0	0	pass
2026-03-20T14:10:00Z	designsystem	Button	create	0	1	85	pass
```

## Success Criteria

The design system skill is complete when ALL of the following are true:
1. All design tokens are defined in a single source (Style Dictionary, Figma Tokens, or equivalent)
2. Semantic token layer exists between primitive tokens and components
3. Every component references only semantic tokens (no hardcoded values)
4. At least two themes work (light + dark) by swapping token values only
5. Every component has a Storybook story with all variants documented
6. Visual regression snapshots are captured for all component states
7. Token pipeline generates CSS custom properties and any other needed formats
8. Token coverage audit shows >= 90% of UI elements using design tokens

## Error Recovery

```
IF tokens are out of sync with Figma:
  1. Re-export tokens from Figma using the token plugin (Tokens Studio or equivalent)
  2. Run the Style Dictionary build pipeline to regenerate outputs
  3. Diff the generated CSS against the previous version
  4. Update components only if token values actually changed

IF theme switching breaks components:
  1. Check that the component uses semantic tokens, not primitive tokens
  2. Verify the theme CSS class or data attribute is applied to the root element
  3. Inspect computed styles to confirm token values are resolving correctly
  4. If a component hardcodes a color, replace it with the appropriate semantic token

IF Storybook fails to build:
  1. Check for import errors in story files (missing components or broken paths)
  2. Verify Storybook addons are compatible with the current Storybook version
  3. Clear the Storybook cache: `npx storybook@latest upgrade --check` or delete node_modules/.cache
  4. Run Storybook in verbose mode to identify the failing story

IF visual regression tests show false positives:
  1. Check if the diff is caused by font rendering differences across environments
  2. Update baseline snapshots if the change is intentional
  3. Use a threshold tolerance (e.g., 0.1% pixel difference) to reduce flakiness
  4. Run visual tests in Docker for consistent rendering environment
```

## Anti-Patterns

- **Do NOT skip the semantic token layer.** Mapping components directly to primitive tokens (`--button-bg: var(--primitive-blue-500)`) breaks theming. Always go through semantic tokens (`--button-bg: var(--color-primary)`).
- **Do NOT store tokens only in JavaScript.** CSS custom properties are the universal distribution format. They work in CSS, SCSS, CSS-in-JS, Tailwind, and plain HTML. JS-only tokens lock out non-JS consumers.
- **Do NOT let designers and developers maintain separate token lists.** One source (Figma), one pipeline (Style Dictionary), one output (CSS custom properties). Two sources means drift.
- **Do NOT theme by overriding component styles.** Theme by changing token values. If you need `button.dark { background: #1e3a8a; }`, your token architecture is wrong.
- **Do NOT publish without a changelog.** Consumers upgrading from v2.3.0 to v2.4.0 need to know what changed. "Various improvements" is not a changelog entry.
- **Do NOT create tokens for every possible value.** A spacing scale of 16 steps is complete. A color palette with 200 shades is noise. Tokens should constrain choices, not enumerate them.
- **Do NOT treat Storybook as an afterthought.** Storybook is not a developer tool you set up last. It is the component development environment, the documentation, the visual testing target, and the design review surface. Set it up first.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run design system tasks sequentially: tokens, then components, then pipeline, then docs/Storybook.
- Use branch isolation per task: `git checkout -b godmode-designsystem-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
