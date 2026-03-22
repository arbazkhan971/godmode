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

## Workflow

### Step 1: Project Discovery & Assessment
```
TAILWIND ASSESSMENT:
Tailwind version: <3.x / 4.x>
Framework: <React / Vue / Svelte / Angular / Astro / plain HTML>
Build tool: <Vite / Webpack / PostCSS CLI / Turbopack>
Current CSS approach: <Tailwind / SCSS / CSS Modules / CSS-in-JS / plain CSS / none>
Design system: <existing tokens / Figma / none>
Component library: <shadcn/ui / DaisyUI / Headless UI / Radix / custom / none>
Dark mode: <class strategy / media strategy / none>
Quality score: <HIGH / MEDIUM / LOW>
```

### Step 2: Configuration & Customization

**Tailwind 4.x** — CSS-first configuration via `@theme {}` in app.css with `@import "tailwindcss"`. Define colors (oklch), fonts, spacing, shadows, radius, animations as CSS custom properties.

**Tailwind 3.x** — JS configuration via `tailwind.config.ts` with `satisfies Config`. Use `theme.extend` to add tokens.

Rules:
- **Extend, don't override** — use `theme.extend` to add tokens without losing defaults
- **Use oklch for colors** — perceptually uniform, better for generated palettes
- **CSS custom properties for semantic tokens** — enables runtime theme switching
- **Type the config** — use `satisfies Config` for TypeScript validation

### Step 3: Custom Plugin Creation
Use `plugin()` from `tailwindcss/plugin`:
- **`addComponents`** for multi-property classes — `.btn`, `.card`, `.badge`
- **`addUtilities`** for single-purpose classes — `.text-balance`, `.scrollbar-hidden`
- **`addBase`** for element defaults — typography reset, heading styles
- **Reference theme values** — `theme('colors.brand.500')` not hardcoded values
- **`addVariant`** for state variants — `hocus:`, `aria-selected:`

### Step 4: Responsive Design Patterns
Strategy: Mobile-first always. Default styles target mobile. Breakpoints add complexity for larger screens.

Breakpoints: default (0px mobile), xs (475px), sm (640px), md (768px), lg (1024px), xl (1280px), 2xl (1536px).

Rules:
- **Mobile-first always** — default for mobile, breakpoints for larger
- **Container queries over media queries** — for reusable components
- **Avoid fixed widths** — use `max-w-*`, `min-w-*`, and `flex-1`
- **Fluid typography** — use `clamp()` via arbitrary values

### Step 5: Dark Mode Implementation

**Class-Based Strategy (Recommended):** Toggle via class on `<html>`. Use `dark:` variant.

**Semantic Color Tokens (Better):** Define CSS custom properties in `:root` and `.dark`, reference in config. Components use semantic tokens — no `dark:` prefix needed.

**Dark Mode Toggle:** Store in localStorage, support light/dark/system. Inline script in `<head>` prevents flash.

Rules:
- **Class strategy over media strategy** — supports user toggle + system detection
- **Semantic tokens** — CSS custom properties so components skip `dark:` prefixes
- **Prevent flash** — inline script in `<head>` reads localStorage before render
- **Three modes: light, dark, system** — always support system preference

### Step 6: Performance Optimization
- **JIT is default in Tailwind 3+/4** — generates only classes you use
- **Content paths must cover all files** — missing a path = missing utilities in production
- **Never construct class names dynamically** — use complete strings or object maps
- **Minimize safelist** — safelisted classes are always in the bundle
- **Minimize `@apply`** — defeats utility-first; use only in base/component layers

### Step 7: Component Patterns — Avoiding Class Soup

**CVA (Class Variance Authority):** Organize variants (size, color, state) cleanly with `cva()`.

**cn() Utility:** `twMerge(clsx(inputs))` — resolves conflicts intelligently, handles conditional classes.

**Composition:** Extract to components when same classes appear 3+ times, class list > 10 utilities, or dark mode doubles class count. Do NOT extract one-off layouts or simple 3-4 utility combos.

### Step 8: Validation
```
TAILWIND AUDIT:
- Content paths cover all templates: PASS | FAIL
- Theme extends (not overrides) defaults: PASS | FAIL
- Dark mode strategy configured: PASS | FAIL
- No dynamic class name construction: PASS | FAIL
- Minimal safelist and @apply usage: PASS | FAIL
- CVA/cn() used for component variants: PASS | FAIL
- Responsive design mobile-first: PASS | FAIL
- Semantic color tokens for dark mode: PASS | FAIL
- CSS bundle size under budget: PASS | FAIL
- Accessibility (focus-visible rings): PASS | FAIL
VERDICT: <PASS | NEEDS REVISION>
```

## Key Behaviors

1. **Utility-first, component-extract.** Start with utilities in markup. Extract to components with CVA when patterns repeat.
2. **Mobile-first always.** Default styles target mobile. Breakpoint prefixes add desktop enhancements.
3. **Semantic tokens for dark mode.** CSS custom properties that switch between light/dark values.
4. **Config is your design system.** Single source of truth for colors, spacing, typography.
5. **CVA for variants.** When a component has multiple visual variants, use CVA.
6. **cn() for conditional and merge.** Always use `tailwind-merge` + `clsx` via `cn()`.
7. **Performance is passive.** JIT generates only what you use. Keep content paths accurate.

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
| `--perf` | CSS bundle size and performance audit |
| `--cva` | Set up CVA for component variants |
| `--v4` | Migrate from Tailwind 3 to Tailwind 4 |

## HARD RULES

1. **NEVER construct class names dynamically.** `bg-${color}-500` will not be included in the output.
2. **NEVER override the entire theme.** Use `theme.extend`.
3. **NEVER hardcode colors or spacing values.** Use theme tokens.
4. **NEVER skip focus styles.** Every interactive element needs `focus-visible:ring-2`.
5. **ALWAYS write mobile-first responsive.** `flex flex-col lg:flex-row` not `lg:flex flex-col`.
6. **ALWAYS include all template directories in content paths.**
7. **NEVER use `@apply` everywhere.** Use utilities in markup or extract to components.
8. **NEVER safelist large pattern sets.**

## Output Format

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

## Auto-Detection

```
1. Tailwind version: grep "tailwindcss" package.json
2. Config: ls tailwind.config.* postcss.config.*
3. CSS conflicts: grep for styled-components, @emotion, sass, less, css-modules
4. Template locations: scan src/ for .tsx, .jsx, .vue, .svelte, .html
5. Existing tokens: grep "theme|extend" in tailwind.config.*
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
Run the task inline. Use `git stash` instead of `EnterWorktree`. All conventions and quality checks still apply.

## Error Recovery
| Failure | Action |
|---------|--------|
| Tailwind classes not applying | Check `content` paths in config include all template file extensions. Verify PostCSS config loads Tailwind plugin. Run `npx tailwindcss --help` to confirm installation. |
| PurgeCSS removes needed classes | Add dynamic class patterns to `safelist` in config. For conditional classes, use complete strings (not concatenation). |
| Design token conflicts with UI library | Extend (don't replace) the default theme. Use `theme.extend` to add tokens alongside library defaults. |
| Build produces oversized CSS | Check for duplicate `@tailwind` directives. Enable CSS minification. Audit for unused safelist entries. |

## Success Criteria
1. `vite build` (or equivalent) completes without CSS-related errors.
2. No Tailwind classes missing from production build (visual spot-check on 3 key pages).
3. CSS bundle size within budget (typically <50KB gzipped for Tailwind).
4. Design tokens defined in config, not as arbitrary values in markup.

## TSV Logging
Append to `.godmode/tailwind-results.tsv`:
```
timestamp	action	files_modified	components_styled	build_status	css_size_kb	issues_fixed
```
One row per invocation. Never overwrite previous rows.

## Keep/Discard Discipline
```
After EACH Tailwind change:
  KEEP if: build passes AND no visual regressions AND CSS size stable or decreased
  DISCARD if: build fails OR classes missing in production OR CSS size increased >20%
  On discard: revert changes. Check content paths and safelist before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - Build passes with no CSS warnings
  - All components styled consistently using design tokens
  - CSS bundle size within budget
  - No arbitrary values in markup (all using theme tokens)
```
