---
name: tailwind
description: |
  Tailwind CSS mastery skill. Activates when user needs to configure, optimize, or build with Tailwind CSS. Covers configuration and customization, custom plugin creation, responsive design patterns, dark mode implementation, performance optimization (purging, JIT), and component patterns that avoid class soup. Triggers on: /godmode:tailwind, "set up Tailwind", "Tailwind config", "responsive design", "dark mode CSS", or when the orchestrator detects Tailwind-related work.
---

# Tailwind — Tailwind CSS Mastery

## When to Activate
- User invokes `/godmode:tailwind`
- User says "set up Tailwind", "configure Tailwind", "Tailwind config"
- User mentions "responsive design", "dark mode", "utility CSS"
- User says "Tailwind plugin", "custom utilities", "design tokens"
- When setting up styling for any frontend project
- When `/godmode:plan` identifies styling or design system tasks
- When `/godmode:review` flags CSS architecture issues

## Workflow

### Step 1: Project Discovery & Assessment
Survey the current styling approach:

```
TAILWIND ASSESSMENT:
Tailwind version: <3.x / 4.x>
Framework: <React / Vue / Svelte / Angular / Astro / plain HTML>
Build tool: <Vite / Webpack / PostCSS CLI / Turbopack>
Current CSS approach: <Tailwind / SCSS / CSS Modules / CSS-in-JS / plain CSS / none>
Design system: <existing tokens / Figma / none>
Component library: <shadcn/ui / DaisyUI / Headless UI / Radix / custom / none>
Dark mode: <class strategy / media strategy / none>
Custom config: <minimal / moderate / extensive>
Plugin count: <N>
Custom utilities: <N>
Bundle size (CSS): <N> KB

Configuration:
  tailwind.config: <TS / JS / ESM / CJS>
  postcss.config: <present / missing>
  content paths: <configured / misconfigured>
  theme extension: <minimal / extensive>
  plugins: [<list>]

Quality score: <HIGH / MEDIUM / LOW>
Issues detected: <N>
```

If starting fresh, ask: "What framework are you using? Do you have an existing design system or Figma file?"

### Step 2: Configuration & Customization
Set up a production-grade Tailwind configuration:

#### Tailwind 4.x (CSS-first configuration)
```css
/* app.css — Tailwind 4 uses CSS-based configuration */
@import "tailwindcss";

/* Theme customization */
@theme {
  /* Colors — use CSS custom properties */
  --color-brand-50: oklch(0.97 0.02 250);
  --color-brand-100: oklch(0.93 0.04 250);
  --color-brand-500: oklch(0.55 0.20 250);
  --color-brand-600: oklch(0.48 0.20 250);
  --color-brand-700: oklch(0.40 0.18 250);
  --color-brand-900: oklch(0.25 0.12 250);

  /* Semantic colors */
  --color-primary: var(--color-brand-600);
  --color-primary-hover: var(--color-brand-700);
  --color-surface: oklch(0.99 0 0);
  --color-surface-dark: oklch(0.15 0 0);
  --color-text: oklch(0.15 0 0);
  --color-text-muted: oklch(0.45 0 0);

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;

  /* Spacing scale extension */
  --spacing-18: 4.5rem;
  --spacing-88: 22rem;

  /* Breakpoints */
  --breakpoint-xs: 475px;

  /* Shadows */
  --shadow-soft: 0 2px 8px oklch(0 0 0 / 0.06);
  --shadow-card: 0 1px 3px oklch(0 0 0 / 0.08), 0 4px 12px oklch(0 0 0 / 0.04);

  /* Border radius */
  --radius-button: 0.5rem;
  --radius-card: 0.75rem;
  --radius-modal: 1rem;

  /* Animations */
  --animate-slide-in: slide-in 0.3s ease-out;
  --animate-fade-in: fade-in 0.2s ease-out;
}

@keyframes slide-in {
  from { transform: translateY(8px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}
```

#### Tailwind 3.x (JS configuration)
```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';
import defaultTheme from 'tailwindcss/defaultTheme';

export default {
  content: [
    './src/**/*.{html,js,ts,jsx,tsx,svelte,vue}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],

  darkMode: 'class',  // or 'media' for OS preference

  theme: {
    extend: {
      // Colors — design token-driven
      colors: {
        brand: {
          50: 'oklch(0.97 0.02 250)',
          100: 'oklch(0.93 0.04 250)',
          500: 'oklch(0.55 0.20 250)',
          600: 'oklch(0.48 0.20 250)',
          700: 'oklch(0.40 0.18 250)',
          900: 'oklch(0.25 0.12 250)',
        },
        surface: {
          DEFAULT: 'var(--color-surface)',
          dark: 'var(--color-surface-dark)',
        },
      },

      // Typography
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono', ...defaultTheme.fontFamily.mono],
      },

      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '0.875rem' }],
      },

      // Spacing
      spacing: {
        18: '4.5rem',
        88: '22rem',
      },

      // Breakpoints
      screens: {
        xs: '475px',
      },

      // Shadows
      boxShadow: {
        soft: '0 2px 8px rgba(0,0,0,0.06)',
        card: '0 1px 3px rgba(0,0,0,0.08), 0 4px 12px rgba(0,0,0,0.04)',
      },

      // Border radius
      borderRadius: {
        button: '0.5rem',
        card: '0.75rem',
        modal: '1rem',
      },

      // Animations
      keyframes: {
        'slide-in': {
          from: { transform: 'translateY(8px)', opacity: '0' },
          to: { transform: 'translateY(0)', opacity: '1' },
        },
        'fade-in': {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
      },
      animation: {
        'slide-in': 'slide-in 0.3s ease-out',
        'fade-in': 'fade-in 0.2s ease-out',
      },
    },
  },

  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/container-queries'),
  ],
} satisfies Config;
```

Rules for configuration:
- **Extend, don't override** — use `theme.extend` to add tokens without losing defaults
- **Use `oklch` for colors** — perceptually uniform, better for generated palettes
- **CSS custom properties for semantic tokens** — `var(--color-primary)` enables runtime theme switching
- **One config, all projects** — shared Tailwind preset for design system consistency across repos
- **Type the config** — use `satisfies Config` for TypeScript validation

### Step 3: Custom Plugin Creation
Create plugins for project-specific utilities:

```typescript
// tailwind-plugins/typography.ts
import plugin from 'tailwindcss/plugin';

export const typographyPlugin = plugin(({ addBase, addComponents, addUtilities, theme }) => {
  // Base styles
  addBase({
    'h1': {
      fontSize: theme('fontSize.4xl'),
      fontWeight: theme('fontWeight.bold'),
      lineHeight: theme('lineHeight.tight'),
      letterSpacing: theme('letterSpacing.tight'),
    },
    'h2': {
      fontSize: theme('fontSize.3xl'),
      fontWeight: theme('fontWeight.semibold'),
      lineHeight: theme('lineHeight.tight'),
    },
  });

  // Component classes
  addComponents({
    '.btn': {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      borderRadius: theme('borderRadius.button'),
      fontWeight: theme('fontWeight.medium'),
      fontSize: theme('fontSize.sm'),
      lineHeight: theme('lineHeight.5'),
      paddingLeft: theme('spacing.4'),
      paddingRight: theme('spacing.4'),
      paddingTop: theme('spacing.2'),
      paddingBottom: theme('spacing.2'),
      transition: 'all 150ms ease',
      '&:focus-visible': {
        outline: `2px solid ${theme('colors.brand.500')}`,
        outlineOffset: '2px',
      },
      '&:disabled': {
        opacity: '0.5',
        cursor: 'not-allowed',
      },
    },
    '.btn-primary': {
      backgroundColor: theme('colors.brand.600'),
      color: 'white',
      '&:hover:not(:disabled)': {
        backgroundColor: theme('colors.brand.700'),
      },
    },
    '.btn-secondary': {
      backgroundColor: 'transparent',
      border: `1px solid ${theme('colors.gray.300')}`,
      color: theme('colors.gray.700'),
      '&:hover:not(:disabled)': {
        backgroundColor: theme('colors.gray.50'),
      },
    },
  });

  // Custom utilities
  addUtilities({
    '.text-balance': {
      textWrap: 'balance',
    },
    '.text-pretty': {
      textWrap: 'pretty',
    },
    '.scrollbar-hidden': {
      scrollbarWidth: 'none',
      '&::-webkit-scrollbar': { display: 'none' },
    },
  });
});
```

#### Variant Plugin
```typescript
// tailwind-plugins/variants.ts
import plugin from 'tailwindcss/plugin';

export const variantPlugin = plugin(({ addVariant }) => {
  // Custom variants
  addVariant('hocus', ['&:hover', '&:focus-visible']);
  addVariant('group-hocus', [':merge(.group):hover &', ':merge(.group):focus-visible &']);
  addVariant('not-first', '&:not(:first-child)');
  addVariant('not-last', '&:not(:last-child)');
  addVariant('aria-selected', '&[aria-selected="true"]');
  addVariant('aria-expanded', '&[aria-expanded="true"]');
  addVariant('data-active', '&[data-active="true"]');
});
```

Rules for plugins:
- **Use `addComponents` for multi-property classes** — `.btn`, `.card`, `.badge`
- **Use `addUtilities` for single-purpose classes** — `.text-balance`, `.scrollbar-hidden`
- **Use `addBase` for element defaults** — typography reset, heading styles
- **Reference theme values** — `theme('colors.brand.500')` not hardcoded values
- **Use `addVariant` for state variants** — `hocus:`, `aria-selected:`, custom data attributes

### Step 4: Responsive Design Patterns
Establish responsive design conventions:

```
RESPONSIVE BREAKPOINTS:
┌────────────────────────────────────────────────────────────────────┐
│  Breakpoint  │  Min Width  │  Target Devices           │  Prefix  │
├──────────────┼─────────────┼───────────────────────────┼──────────┤
│  Default     │  0px        │  Mobile (portrait)        │  (none)  │
│  xs          │  475px      │  Mobile (landscape)       │  xs:     │
│  sm          │  640px      │  Small tablets            │  sm:     │
│  md          │  768px      │  Tablets                  │  md:     │
│  lg          │  1024px     │  Laptops                  │  lg:     │
│  xl          │  1280px     │  Desktops                 │  xl:     │
│  2xl         │  1536px     │  Large desktops           │  2xl:    │
└──────────────┴─────────────┴───────────────────────────┴──────────┘

STRATEGY: Mobile-first (always). Default styles target mobile.
Breakpoints add complexity for larger screens.
```

#### Responsive Component Patterns
```html
<!-- Grid that adapts: 1 col mobile -> 2 col tablet -> 3 col desktop -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
  <!-- Cards -->
</div>

<!-- Sidebar layout: stacked on mobile, side-by-side on desktop -->
<div class="flex flex-col lg:flex-row gap-6">
  <aside class="w-full lg:w-64 lg:shrink-0">
    <!-- Sidebar -->
  </aside>
  <main class="flex-1 min-w-0">
    <!-- Main content -->
  </main>
</div>

<!-- Responsive typography -->
<h1 class="text-2xl sm:text-3xl lg:text-4xl xl:text-5xl font-bold">
  Responsive Heading
</h1>

<!-- Container queries (Tailwind v3.3+ / v4) -->
<div class="@container">
  <div class="flex flex-col @md:flex-row @lg:grid @lg:grid-cols-3 gap-4">
    <!-- Responds to container width, not viewport -->
  </div>
</div>

<!-- Responsive spacing -->
<section class="px-4 sm:px-6 lg:px-8 py-8 sm:py-12 lg:py-16">
  <!-- Content -->
</section>

<!-- Show/hide by breakpoint -->
<nav class="hidden lg:flex gap-4">Desktop nav</nav>
<button class="lg:hidden">Mobile menu</button>
```

Rules:
- **Mobile-first always** — write default styles for mobile, add breakpoints for larger screens
- **Container queries over media queries** — for reusable components that adapt to their container, not the viewport
- **Avoid fixed widths** — use `max-w-*`, `min-w-*`, and `flex-1` instead of `w-[500px]`
- **Test all breakpoints** — resize browser to each breakpoint during development
- **Fluid typography** — use `clamp()` via arbitrary values for truly fluid text sizes

### Step 5: Dark Mode Implementation
Design a robust dark mode system:

#### Class-Based Strategy (Recommended)
```html
<!-- Toggle dark mode via class on html element -->
<html class="dark">

<!-- Component with dark mode -->
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">
  <h2 class="text-gray-900 dark:text-white">Title</h2>
  <p class="text-gray-600 dark:text-gray-400">Description</p>
  <div class="border border-gray-200 dark:border-gray-700 rounded-card p-4">
    <span class="text-gray-500 dark:text-gray-400">Muted text</span>
  </div>
</div>
```

#### Semantic Color Tokens (Better Approach)
```css
/* Use CSS custom properties for automatic dark mode */
@layer base {
  :root {
    --color-bg: theme('colors.white');
    --color-bg-secondary: theme('colors.gray.50');
    --color-text: theme('colors.gray.900');
    --color-text-muted: theme('colors.gray.600');
    --color-border: theme('colors.gray.200');
    --color-ring: theme('colors.brand.500');
  }

  .dark {
    --color-bg: theme('colors.gray.950');
    --color-bg-secondary: theme('colors.gray.900');
    --color-text: theme('colors.gray.100');
    --color-text-muted: theme('colors.gray.400');
    --color-border: theme('colors.gray.800');
    --color-ring: theme('colors.brand.400');
  }
}
```

```typescript
// tailwind.config.ts — reference CSS variables
{
  theme: {
    extend: {
      colors: {
        bg: 'var(--color-bg)',
        'bg-secondary': 'var(--color-bg-secondary)',
        text: 'var(--color-text)',
        'text-muted': 'var(--color-text-muted)',
        border: 'var(--color-border)',
        ring: 'var(--color-ring)',
      },
    },
  },
}
```

```html
<!-- Now components use semantic tokens — no dark: prefix needed -->
<div class="bg-bg text-text border-border rounded-card p-4">
  <h2 class="text-text">Title</h2>
  <p class="text-text-muted">Description</p>
</div>
```

#### Dark Mode Toggle
```typescript
// utils/theme.ts
type Theme = 'light' | 'dark' | 'system';

export function getTheme(): Theme {
  return (localStorage.getItem('theme') as Theme) || 'system';
}

export function setTheme(theme: Theme) {
  localStorage.setItem('theme', theme);
  applyTheme(theme);
}

export function applyTheme(theme: Theme) {
  const root = document.documentElement;
  const isDark =
    theme === 'dark' ||
    (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

  root.classList.toggle('dark', isDark);
}

// Initialize on page load (in <head> to prevent flash)
// <script>
//   const theme = localStorage.getItem('theme') || 'system';
//   const isDark = theme === 'dark' || (theme === 'system' && matchMedia('(prefers-color-scheme: dark)').matches);
//   document.documentElement.classList.toggle('dark', isDark);
// </script>
```

Rules:
- **Class strategy over media strategy** — class strategy supports user preference toggle and system detection
- **Semantic color tokens** — use CSS custom properties so components don't need `dark:` prefixes everywhere
- **Prevent flash of wrong theme** — inline script in `<head>` reads localStorage before render
- **Three modes: light, dark, system** — always support "follow system preference"
- **Test both modes** — every component must look correct in both light and dark

### Step 6: Performance Optimization
Optimize Tailwind for production:

```
TAILWIND PERFORMANCE AUDIT:
┌──────────────────────────────────────────────────────────────────────┐
│  Area                       │  Current         │  Target             │
├─────────────────────────────┼──────────────────┼─────────────────────┤
│  CSS bundle (gzipped)       │  <N> KB          │  < 15 KB            │
│  Unused CSS removed         │  <yes / no>      │  Yes (content scan) │
│  JIT mode                   │  <enabled / off>  │  Enabled (default)  │
│  Content paths correct      │  <yes / no>      │  All sources covered│
│  Arbitrary values count     │  <N>             │  Minimize            │
│  Duplicate utilities        │  <N>             │  Zero                │
│  @apply usage               │  <N> occurrences │  Minimal             │
│  Important modifier usage   │  <N>             │  Zero or near-zero  │
│  Safelisted classes         │  <N>             │  Minimal             │
└─────────────────────────────┴──────────────────┴─────────────────────┘
```

#### Content Path Configuration
```typescript
// Ensure ALL template files are covered
content: [
  // Framework components
  './src/**/*.{html,js,ts,jsx,tsx,svelte,vue,astro}',
  // UI library (if classes come from node_modules)
  './node_modules/@your-ui-lib/src/**/*.{js,ts,jsx,tsx}',
  // Storybook stories
  './.storybook/**/*.{js,ts,jsx,tsx}',
  // Markdown content (if using class names)
  './content/**/*.md',
],

// Classes that are dynamically constructed and can't be detected
safelist: [
  // Only safelist when absolutely necessary
  { pattern: /^bg-(red|green|blue|yellow)-(100|500)$/ },
],
```

#### Avoiding Bloat
```typescript
// BAD: Dynamic class names (can't be detected by JIT)
const color = 'red';
<div class={`bg-${color}-500`}>  // WON'T WORK — not in output

// GOOD: Full class names (detectable by JIT)
const colorClasses = {
  red: 'bg-red-500',
  green: 'bg-green-500',
  blue: 'bg-blue-500',
} as const;
<div class={colorClasses[color]}>  // WORKS — full strings detected

// BAD: Excessive arbitrary values
<div class="w-[347px] mt-[13px] text-[#1a2b3c]">

// GOOD: Use theme values or extend config
<div class="w-88 mt-3 text-brand-700">
```

#### PostCSS Optimization
```javascript
// postcss.config.js
export default {
  plugins: {
    'tailwindcss/nesting': {},   // CSS nesting support
    tailwindcss: {},
    autoprefixer: {},
    ...(process.env.NODE_ENV === 'production'
      ? { cssnano: { preset: 'default' } }
      : {}),
  },
};
```

Rules:
- **JIT is default in Tailwind 3+/4** — it generates only the classes you use
- **Content paths must cover all files** — missing a path means missing utilities in production
- **Never construct class names dynamically** — use complete strings or object maps
- **Minimize safelist** — safelisted classes are always in the bundle; use sparingly
- **Minimize `@apply`** — it defeats the purpose of utility-first; use only in base/component layers
- **Audit with tooling** — use `npx tailwindcss --help` or build size analysis to detect bloat

### Step 7: Component Patterns — Avoiding Class Soup
Establish patterns for readable, maintainable Tailwind:

#### Pattern 1: CVA (Class Variance Authority)
```typescript
// components/Button/button.variants.ts
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '$lib/utils';

export const buttonVariants = cva(
  // Base classes (always applied)
  'inline-flex items-center justify-center rounded-button font-medium text-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none',
  {
    variants: {
      variant: {
        primary: 'bg-brand-600 text-white hover:bg-brand-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-100',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-50 dark:border-gray-700 dark:hover:bg-gray-800',
        ghost: 'hover:bg-gray-100 dark:hover:bg-gray-800',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
        link: 'text-brand-600 underline-offset-4 hover:underline',
      },
      size: {
        sm: 'h-8 px-3 text-xs',
        md: 'h-10 px-4',
        lg: 'h-12 px-6 text-base',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

export type ButtonVariants = VariantProps<typeof buttonVariants>;
```

```tsx
// components/Button/Button.tsx
import { buttonVariants, type ButtonVariants } from './button.variants';
import { cn } from '$lib/utils';

interface ButtonProps extends ButtonVariants {
  className?: string;
  children: React.ReactNode;
}

export function Button({ variant, size, className, children, ...props }: ButtonProps) {
  return (
    <button className={cn(buttonVariants({ variant, size }), className)} {...props}>
      {children}
    </button>
  );
}
```

#### Pattern 2: cn() Utility (Tailwind Merge)
```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage: resolves conflicts intelligently
cn('px-4 py-2', 'px-6')           // -> 'py-2 px-6' (px-6 wins)
cn('text-red-500', condition && 'text-blue-500')  // -> conditional class
cn(buttonVariants({ variant }), className)  // -> merge with overrides
```

#### Pattern 3: Composition Over Long Class Lists
```tsx
// BAD: Class soup — unreadable, unmaintainable
<div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 sm:gap-6 p-4 sm:p-6 bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl shadow-sm hover:shadow-md transition-shadow">

// GOOD: Extract to component with named intent
<Card variant="elevated" responsive>
  <CardContent layout="row-on-desktop">
    ...
  </CardContent>
</Card>

// GOOD: Group related utilities with comments
<div class={cn(
  // Layout
  'flex flex-col sm:flex-row items-start sm:items-center justify-between',
  // Spacing
  'gap-4 sm:gap-6 p-4 sm:p-6',
  // Visual
  'bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800',
  'rounded-xl shadow-sm hover:shadow-md transition-shadow',
)}>
```

#### Pattern 4: Component Extraction Rules
```
WHEN TO EXTRACT A COMPONENT:
┌──────────────────────────────────────────────────────────────────────┐
│  Signal                        │  Action                            │
├────────────────────────────────┼────────────────────────────────────┤
│  Same classes repeated 3+ times│  Extract component                 │
│  Class list > 10 utilities     │  Extract component or use CVA      │
│  Variant needed (size, color)  │  Use CVA                           │
│  Complex responsive pattern    │  Extract component with props      │
│  Dark mode doubles class count │  Use semantic tokens instead       │
│  Conditional classes complex   │  Use cn() with clear conditions    │
└────────────────────────────────┴────────────────────────────────────┘

WHEN NOT TO EXTRACT:
- One-off layout styling (just use utilities inline)
- Simple 3-4 utility combinations
- Page-specific layout that won't repeat
```

### Step 8: Design System Integration
Connect Tailwind to a design system:

```
DESIGN TOKEN MAPPING:
┌──────────────────────────────────────────────────────────────────────┐
│  Design Token (Figma)     │  Tailwind Config          │  Class      │
├───────────────────────────┼───────────────────────────┼─────────────┤
│  Color/Primary/600        │  colors.brand.600         │  text-brand-600 │
│  Color/Neutral/100        │  colors.gray.100          │  bg-gray-100    │
│  Spacing/4                │  spacing.4 (default 1rem) │  p-4            │
│  Radius/Medium            │  borderRadius.card        │  rounded-card   │
│  Shadow/Elevation-1       │  boxShadow.card           │  shadow-card    │
│  Font/Heading/H1          │  (plugin base styles)     │  (h1 element)   │
│  Font/Body/Regular        │  fontSize.base            │  text-base      │
└───────────────────────────┴───────────────────────────┴─────────────┘

SYNC STRATEGY: <Manual | Style Dictionary | Figma plugin>
```

#### Tailwind Preset for Shared Design System
```typescript
// packages/design-tokens/tailwind-preset.ts
import type { Config } from 'tailwindcss';
import { tokens } from './generated-tokens';  // From Figma/Style Dictionary

export default {
  theme: {
    colors: tokens.colors,
    fontFamily: tokens.fonts,
    fontSize: tokens.fontSizes,
    spacing: tokens.spacing,
    borderRadius: tokens.radii,
    boxShadow: tokens.shadows,
  },
  plugins: [
    require('./plugins/typography'),
    require('./plugins/components'),
  ],
} satisfies Partial<Config>;

// In project tailwind.config.ts
import designSystem from '@company/design-tokens/tailwind-preset';

export default {
  presets: [designSystem],
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      // Project-specific extensions
    },
  },
} satisfies Config;
```

### Step 9: Validation
Validate the Tailwind setup against best practices:

```
TAILWIND AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                                    │  Status              │
├───────────────────────────────────────────┼──────────────────────┤
│  Content paths cover all templates        │  PASS | FAIL         │
│  Theme extends (not overrides) defaults   │  PASS | FAIL         │
│  Dark mode strategy configured            │  PASS | FAIL         │
│  No dynamic class name construction       │  PASS | FAIL         │
│  Minimal safelist usage                   │  PASS | FAIL         │
│  @apply used sparingly (< 10 instances)   │  PASS | FAIL         │
│  !important modifier usage minimal        │  PASS | FAIL         │
│  Arbitrary values count reasonable (< 20) │  PASS | FAIL         │
│  CVA/cn() used for component variants     │  PASS | FAIL         │
│  Responsive design mobile-first           │  PASS | FAIL         │
│  Semantic color tokens for dark mode      │  PASS | FAIL         │
│  CSS bundle size under budget             │  PASS | FAIL         │
│  PostCSS config present and correct       │  PASS | FAIL         │
│  No unused plugins                        │  PASS | FAIL         │
│  Typography plugin for prose content      │  PASS | FAIL | N/A   │
│  Forms plugin for form elements           │  PASS | FAIL | N/A   │
│  Accessibility (focus-visible rings)      │  PASS | FAIL         │
└───────────────────────────────────────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Deliverables & Handoff
Generate the styling artifacts:

```
TAILWIND SETUP COMPLETE:

Artifacts:
- Tailwind version: <3.x / 4.x>
- Configuration: <minimal / custom theme / design system preset>
- Custom plugins: <N> plugins
- Design tokens: <N> colors, <N> spacing, <N> shadows
- Dark mode: <class / media / semantic tokens>
- Component patterns: <CVA / cn() / extracted components>
- CSS bundle: <N> KB (gzipped)
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:ui — Component architecture audit
-> /godmode:a11y — Accessibility audit (focus styles, contrast)
-> /godmode:visual — Visual regression testing
-> /godmode:build — Build components with Tailwind
-> /godmode:designsystem — Full design system setup
```

Commit: `"tailwind: <project> — <description of configuration>"`

## Key Behaviors

1. **Utility-first, component-extract.** Start with utilities in markup. When patterns repeat or grow complex, extract to components with CVA or similar.
2. **Mobile-first always.** Default styles target mobile. Breakpoint prefixes add desktop enhancements. Never the reverse.
3. **Semantic tokens for dark mode.** CSS custom properties that switch between light and dark values mean components need fewer `dark:` prefixes.
4. **Config is your design system.** The Tailwind config is the single source of truth for colors, spacing, typography. Don't hardcode values in utilities.
5. **Class Variance Authority for variants.** When a component has multiple visual variants (size, color, state), use CVA to organize them cleanly.
6. **cn() for conditional and merge.** Always use `tailwind-merge` + `clsx` via `cn()` to handle conditional classes and prevent utility conflicts.
7. **Performance is passive.** JIT generates only what you use. Keep content paths accurate and avoid dynamic class construction, and CSS stays small automatically.

## Example Usage

### Setting up Tailwind for a new project
```
User: /godmode:tailwind Set up Tailwind for our React/Vite project

Tailwind: Starting assessment...

TAILWIND ASSESSMENT:
Framework: React (Vite)
Tailwind version: 4.x (latest)
Current CSS: none (new project)

Setting up:
  1. Install tailwindcss, @tailwindcss/vite
  2. Configure CSS-first theme with project colors
  3. Create semantic color tokens for dark mode
  4. Install and configure cn() utility (clsx + tailwind-merge)
  5. Set up CVA for Button, Input, Badge components
  6. Configure custom typography plugin
  7. Add focus-visible ring utilities

CSS bundle: 8.2 KB (gzipped)
```

### Migrating from CSS-in-JS to Tailwind
```
User: /godmode:tailwind Migrate from styled-components to Tailwind

Tailwind: Scanning styled-components usage...

Found 47 styled components
Token mapping:
  24 color tokens -> Tailwind theme colors
  8 spacing tokens -> Tailwind spacing scale
  6 font sizes -> Tailwind typography scale
  4 shadows -> Tailwind box shadows

Migration plan:
  Phase 1: Set up Tailwind config with matched tokens
  Phase 2: Convert simple styled components (32) to utility classes
  Phase 3: Convert complex styled components (15) to CVA patterns
  Phase 4: Remove styled-components dependency
  Phase 5: Verify visual regression tests pass
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Tailwind assessment and setup |
| `--audit` | Audit existing Tailwind configuration |
| `--config` | Generate or optimize tailwind.config |
| `--dark-mode` | Set up dark mode with semantic tokens |
| `--plugin <name>` | Create a custom Tailwind plugin |
| `--responsive` | Audit and improve responsive patterns |
| `--tokens` | Map design tokens to Tailwind config |
| `--migrate` | Migrate from other CSS approach to Tailwind |
| `--preset` | Create a shared Tailwind preset |
| `--perf` | CSS bundle size and performance audit |
| `--cva` | Set up CVA for component variants |
| `--v4` | Migrate from Tailwind 3 to Tailwind 4 |

## HARD RULES

1. **NEVER construct class names dynamically.** `bg-${color}-500` will not be included in the output. Use complete string literals in an object map.
2. **NEVER override the entire theme.** Use `theme.extend` to add values. Overriding `theme.colors` removes all default colors.
3. **NEVER hardcode colors or spacing values.** `text-[#1a2b3c]` or `mt-[13px]` defeats the design system. Add values to the config and use theme tokens.
4. **NEVER skip focus styles.** Every interactive element needs `focus-visible:ring-2` or equivalent. Keyboard users depend on visible focus.
5. **ALWAYS write mobile-first responsive.** `flex flex-col lg:flex-row` not `lg:flex flex-col`. Design for the smallest viewport first.
6. **ALWAYS include all template directories in `content` paths.** Missing a directory means classes used there will not be generated in production.
7. **NEVER use `@apply` everywhere.** Excessive `@apply` recreates CSS-in-JS with extra steps. Use utilities in markup or extract to components.
8. **NEVER safelist large pattern sets.** Safelisting `bg-*-*` includes thousands of classes. Safelist only specific, necessary classes.

## Auto-Detection

On activation, detect the Tailwind project context:

```bash
# Detect Tailwind installation and version
grep -r "tailwindcss" package.json 2>/dev/null

# Detect config file
ls tailwind.config.* postcss.config.* 2>/dev/null

# Detect CSS framework conflicts
grep -r "styled-components\|@emotion\|sass\|less\|css-modules" package.json 2>/dev/null

# Detect template file locations
find src/ -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.html" 2>/dev/null | head -5

# Detect existing design tokens
grep -r "theme\|extend" tailwind.config.* 2>/dev/null | head -10
```

## Output Format

End every Tailwind skill invocation with this summary block:

```
TAILWIND RESULT:
Action: <scaffold | component | theme | optimize | migrate | audit>
Files created/modified: <N>
Components styled: <N>
Tailwind version: <3 | 4>
Design tokens added: <N>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Append one TSV row to `.godmode/tailwind.tsv` after each invocation:

```
timestamp	project	action	files_count	components_count	tokens_count	build_status	notes
```

Field definitions:
- `timestamp`: ISO-8601 UTC
- `project`: directory name from `basename $(pwd)`
- `action`: scaffold | component | theme | optimize | migrate | audit
- `files_count`: number of files created or modified
- `components_count`: number of components styled
- `tokens_count`: number of design tokens added or modified
- `build_status`: passing | failing | not-checked
- `notes`: free-text, max 120 chars, no tabs

If `.godmode/` does not exist, create it and add `.godmode/` to `.gitignore` if not already present.

## Success Criteria

Every Tailwind skill invocation must pass ALL of these checks before reporting success:

1. CSS build completes without errors (`npx tailwindcss build` or framework build)
2. No dynamically constructed class names (e.g., `bg-${color}-500`)
3. No excessive `@apply` usage (utilities should be in markup, not CSS)
4. `theme.extend` used instead of overriding entire theme sections
5. All content paths correctly configured (no missing template directories)
6. Mobile-first responsive design (no desktop-first breakpoint patterns)
7. All interactive elements have focus-visible styles
8. No hardcoded colors or spacing values (use theme tokens)
9. No duplicate utility patterns across 3+ components (extract to component or CVA)
10. Dark mode support if project uses dark mode (consistent `dark:` variants)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

When errors occur, follow these remediation steps:

```
IF build fails (missing classes):
  1. Check content paths in tailwind.config.js — all template dirs must be listed
  2. Verify dynamic classes are in safelist or use complete string literals
  3. Check that PostCSS config includes tailwindcss plugin
  4. For Tailwind v4: verify @import "tailwindcss" in CSS entry point

IF styles not applying:
  1. Check CSS specificity — Tailwind utilities may be overridden by custom CSS
  2. Verify the class exists in the generated CSS (inspect build output)
  3. Check for typos in class names (Tailwind does not warn on invalid classes)
  4. Verify purge/content config is not removing needed classes

IF theme inconsistencies:
  1. Check that custom values use theme() function in CSS or config references
  2. Verify extend vs override in tailwind.config.js
  3. Check for conflicting plugin theme modifications
  4. Verify CSS custom properties match Tailwind token names

IF responsive design breaks:
  1. Verify mobile-first order: base styles first, then sm:, md:, lg:, xl:
  2. Check container queries vs media queries for component-level responsive
  3. Verify max-w and breakpoints are consistent across layouts
  4. Test with browser responsive mode at each breakpoint

IF dark mode issues:
  1. Verify darkMode config: 'class' for manual, 'media' for system preference
  2. Check that all color utilities have dark: variants
  3. Verify dark mode toggle updates the HTML class or data attribute
  4. Check that images/shadows have dark mode alternatives
```

## Anti-Patterns

- **Do NOT construct class names dynamically.** `bg-${color}-500` will not be included in the output. Use complete strings in an object map.
- **Do NOT use @apply everywhere.** Excessive `@apply` recreates CSS-in-JS with extra steps. Use utilities in markup or extract to components.
- **Do NOT override the entire theme.** Use `theme.extend` to add values. Overriding `theme.colors` removes all default colors.
- **Do NOT use !important modifier (`!`) casually.** If you need `!important`, you have a specificity problem. Fix the source, not the symptom.
- **Do NOT safelist large pattern sets.** Safelisting `bg-*-*` includes thousands of classes. Safelist only specific, necessary classes.
- **Do NOT ignore content paths.** Missing a template directory means classes used there won't be generated. Your production build will have missing styles.
- **Do NOT write desktop-first responsive.** `lg:flex flex-col` means "flex on desktop, column on everything." Write `flex flex-col lg:flex-row` instead — mobile first.
- **Do NOT duplicate utilities across components.** If 5 components share the same 12-class pattern, extract a component or use CVA.
- **Do NOT hardcode colors or spacing.** `text-[#1a2b3c]` or `mt-[13px]` defeats the design system. Add values to the config and use theme tokens.
- **Do NOT skip focus styles.** Every interactive element needs `focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2` or equivalent. Keyboard users depend on visible focus.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Replace `Agent("task")` → run the task inline in the current conversation
- Replace `EnterWorktree` → use `git stash` + work in current directory
- Replace `TodoWrite` → track progress with numbered comments in chat
- All Tailwind CSS conventions, patterns, and quality checks still apply identically
