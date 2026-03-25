---
name: tailwind
description: >
  Tailwind CSS mastery. Configuration, custom plugins,
  responsive design, dark mode, performance, CVA.
---

# Tailwind -- Tailwind CSS Mastery

## Activate When
- `/godmode:tailwind`, "set up Tailwind", "Tailwind config"
- "responsive design", "dark mode", "utility CSS"
- "Tailwind plugin", "design tokens"

## Workflow

### Step 1: Project Assessment
```bash
# Detect Tailwind version and config
grep "tailwindcss" package.json 2>/dev/null
ls tailwind.config.* postcss.config.* 2>/dev/null

# Check for CSS conflicts
grep -E "styled-components|@emotion|sass|less" \
  package.json 2>/dev/null
```
```
TAILWIND ASSESSMENT:
Version: <3.x / 4.x>
Framework: <React | Vue | Svelte | Angular>
Build tool: <Vite | Webpack | PostCSS CLI>
Component library: <shadcn | DaisyUI | custom | none>
Dark mode: <class | media | none>
Quality: HIGH | MEDIUM | LOW
```

### Step 2: Configuration
**Tailwind 4.x**: CSS-first via `@theme {}` in app.css
with `@import "tailwindcss"`. Define tokens as
CSS custom properties (oklch colors).

**Tailwind 3.x**: JS config via `tailwind.config.ts`
with `satisfies Config`. Use `theme.extend`.

Rules:
- Extend, don't override (use theme.extend)
- oklch for colors (perceptually uniform)
- CSS custom properties for semantic tokens
- Type the config (satisfies Config)

### Step 3: Custom Plugins
```
addComponents: multi-property (.btn, .card, .badge)
addUtilities: single-purpose (.text-balance)
addBase: element defaults (typography reset)
addVariant: state variants (hocus:, aria-selected:)
Reference theme values: theme('colors.brand.500')
```

### Step 4: Responsive Design
```
BREAKPOINTS:
  default: 0px (mobile)
  sm: 640px, md: 768px, lg: 1024px
  xl: 1280px, 2xl: 1536px

Mobile-first always.
IF reusable component: container queries over media
IF layout: max-w-* + flex-1, avoid fixed widths
IF typography: clamp() via arbitrary values
```

### Step 5: Dark Mode
```
CLASS STRATEGY (recommended): toggle via html class
  IF user toggle needed: class strategy
  IF system-only: media strategy
  IF multiple themes: CSS custom properties

SEMANTIC TOKENS:
  :root { --color-bg: white; --color-text: black; }
  .dark { --color-bg: #0a0a0a; --color-text: #fafafa; }
  Components use var(--color-bg) -- no dark: prefix.

PREVENT FLASH: inline script in <head> reads
  localStorage before render. Always support 3 modes:
  light, dark, system.
```

### Step 6: Performance
```
JIT default in 3+/4 (generates only used classes).
Content paths must cover ALL template files.
  Missing path = missing utilities in production.
NEVER construct classes dynamically.
  bg-${color}-500 will NOT be included.
  Use complete strings or object maps instead.
Minimize safelist (always in bundle).
Minimize @apply (defeats utility-first).
Target: <50KB gzipped CSS bundle.
```

### Step 7: Component Patterns
```
CVA (Class Variance Authority):
  Organize variants (size, color, state) cleanly.
cn() utility: twMerge(clsx(inputs))
  Resolves conflicts, handles conditionals.

EXTRACT to component when:
  Same classes appear 3+ times
  Class list > 10 utilities
  Dark mode doubles class count
DO NOT extract one-off layouts or 3-4 utility combos.
```

### Step 8: Validation
```
| Check                        | Status |
|------------------------------|--------|
| Content paths cover all files| PASS   |
| Theme extends (not overrides)| PASS   |
| Dark mode configured         | PASS   |
| No dynamic class construction| PASS   |
| Minimal safelist + @apply    | PASS   |
| CVA/cn() for variants        | PASS   |
| Mobile-first responsive      | PASS   |
| CSS bundle <50KB gzipped     | PASS   |
| Focus-visible rings          | PASS   |
VERDICT: PASS | NEEDS REVISION
```

## Key Behaviors
1. **Utility-first, component-extract.**
2. **Mobile-first always.**
3. **Semantic tokens for dark mode.**
4. **Config is your design system.**
5. **CVA for variants, cn() for conditional.**
6. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER construct class names dynamically.
2. NEVER override entire theme. Use theme.extend.
3. NEVER hardcode colors or spacing. Use tokens.
4. NEVER skip focus styles. focus-visible:ring-2.
5. ALWAYS write mobile-first responsive.
6. ALWAYS include all template dirs in content paths.
7. NEVER use @apply everywhere.
8. NEVER safelist large pattern sets.

## Auto-Detection
```bash
grep "tailwindcss" package.json 2>/dev/null
ls tailwind.config.* postcss.config.* 2>/dev/null
```

## TSV Logging
Append to `.godmode/tailwind-results.tsv`:
`timestamp\taction\tfiles\tcomponents\tbuild\tcss_kb\tissues`

## Output Format
```
TAILWIND: {action}. Files: {N}. Tokens: {N}.
CSS: {N}KB gzipped. Build: {status}. Issues: {N}.
```

## Keep/Discard Discipline
```
KEEP if: build passes AND no visual regressions
  AND CSS size stable or decreased
DISCARD if: build fails OR classes missing
  OR CSS size increased >20%. Revert.
```

## Stop Conditions
```
STOP when ALL of:
  - Build passes, no CSS warnings
  - All components use design tokens
  - CSS bundle within budget (<50KB gzipped)
  - No arbitrary values in markup
```
