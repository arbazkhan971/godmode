# Recipe: Building a Design System from Scratch

> From design tokens to a published, accessible, visually tested component library.

---

## Context

Your product has grown beyond a single app. Multiple teams build features with inconsistent buttons, spacing, colors, and typography. Or you are starting a new product and want consistency from day one. A design system is the single source of truth for your UI — it defines the visual language (tokens), the building blocks (components), the rules (patterns), and the documentation that lets any developer build UI that looks and behaves correctly.

## The Chain

```
designsystem → ui → a11y → visual → docs → ship
```

> Note: "designsystem" is a conceptual phase here — use `/godmode:think` to design the system, then `/godmode:ui` to build components.

## When to Use This Recipe

- You have 2 or more products or teams sharing UI
- You are building a new product and want consistency from the start
- Your designers are frustrated by developer-built UI that "looks off"
- Your accessibility audit found inconsistencies across components
- You want to publish an open-source component library

---

## Session Transcript

### Phase 1: Design the System (think)

Define the design principles, token structure, and component inventory.

```
> /godmode:think I need to build a design system for our SaaS product suite.
  We have a main web app (Next.js), an admin dashboard (React), and a
  marketing site (Astro). All need to share the same visual language.
  We use Tailwind CSS.

Godmode: Researching existing patterns in your codebases...

CODEBASE ANALYSIS:
  Found 47 unique button variants across 3 projects
  Found 12 different font size scales
  Found 8 different gray palettes
  Found 3 different spacing systems (4px, 5px, and 8px base)
  Found 0 shared component libraries

One question: Should this be a standalone npm package that all three
projects import, or a monorepo with the design system as a workspace?

> Standalone npm package. We'll publish it to our private registry.

Godmode: Writing design system spec...

DESIGN SYSTEM SPEC:

  Name: Acme UI
  Package: @acme/ui

  Principles:
    1. Accessible first — WCAG 2.1 AA minimum, AAA for text
    2. Composable — small components that combine into patterns
    3. Themeable — light/dark mode, brand customization
    4. Framework-agnostic tokens — CSS custom properties at the base
    5. React components — built on Radix UI primitives

  Architecture:
    @acme/tokens    — Design tokens (colors, spacing, typography)
    @acme/ui        — React components (Button, Input, Card, etc.)
    @acme/icons     — Icon set (SVG → React components)
    @acme/tailwind  — Tailwind preset (maps tokens to Tailwind config)

  Token layers:
    Global tokens   → Primitive values (blue-500: #3B82F6)
    Semantic tokens  → Contextual meaning (color-primary: blue-500)
    Component tokens → Specific to component (button-bg: color-primary)

Saved: docs/specs/design-system.md
Commit: "spec: Acme UI design system — tokens, components, 3 consumers"
```

### Phase 2: Build Design Tokens

```
> /godmode:ui --tokens

Godmode: Building design token system...

TOKENS STRUCTURE:

  /packages/tokens
    /src
      /colors.ts       # Color palette + semantic mappings
      /spacing.ts      # 4px base unit scale
      /typography.ts   # Font families, sizes, weights, line heights
      /radius.ts       # Border radius scale
      /shadows.ts      # Elevation / shadow scale
      /motion.ts       # Animation durations, easings
      /breakpoints.ts  # Responsive breakpoints
    /dist
      /css/            # CSS custom properties output
      /json/           # JSON tokens (for Figma plugin sync)
      /tailwind/       # Tailwind config preset

COLOR TOKENS:
  Primitives (palette):
    gray-50 through gray-950 (11 steps)
    blue-50 through blue-950 (11 steps, primary)
    green-50 through green-950 (11 steps, success)
    red-50 through red-950 (11 steps, error)
    amber-50 through amber-950 (11 steps, warning)

  Semantic (light mode):
    --color-bg-primary: var(--gray-0)
    --color-bg-secondary: var(--gray-50)
    --color-bg-tertiary: var(--gray-100)
    --color-text-primary: var(--gray-950)
    --color-text-secondary: var(--gray-600)
    --color-text-disabled: var(--gray-400)
    --color-border-default: var(--gray-200)
    --color-border-strong: var(--gray-300)
    --color-accent-default: var(--blue-600)
    --color-accent-hover: var(--blue-700)
    --color-accent-active: var(--blue-800)
    --color-success: var(--green-600)
    --color-error: var(--red-600)
    --color-warning: var(--amber-600)

  Semantic (dark mode):
    --color-bg-primary: var(--gray-950)
    --color-bg-secondary: var(--gray-900)
    --color-text-primary: var(--gray-50)
    [... inverted mappings ...]

SPACING TOKENS (4px base):
    --space-0: 0
    --space-1: 4px
    --space-2: 8px
    --space-3: 12px
    --space-4: 16px
    --space-5: 20px
    --space-6: 24px
    --space-8: 32px
    --space-10: 40px
    --space-12: 48px
    --space-16: 64px
    --space-20: 80px

TYPOGRAPHY TOKENS:
    --font-family-sans: "Inter", system-ui, sans-serif
    --font-family-mono: "JetBrains Mono", monospace

    --font-size-xs:    12px / 16px
    --font-size-sm:    14px / 20px
    --font-size-base:  16px / 24px
    --font-size-lg:    18px / 28px
    --font-size-xl:    20px / 28px
    --font-size-2xl:   24px / 32px
    --font-size-3xl:   30px / 36px
    --font-size-4xl:   36px / 40px

    --font-weight-regular: 400
    --font-weight-medium:  500
    --font-weight-semibold: 600
    --font-weight-bold:    700

Commit: "tokens: color, spacing, typography, radius, shadow, motion tokens"
```

### Phase 3: Build Components

```
> /godmode:ui --components

Godmode: Building component library...

COMPONENT INVENTORY (Priority order):

  Tier 1 — Foundational (ship first):
    Button         — primary, secondary, outline, ghost, destructive; sizes sm/md/lg
    Input          — text, email, password, number, search; with label, error, helper
    Select         — single select, with search, grouped options
    Checkbox       — with label, indeterminate state
    Radio          — group with label
    Switch         — toggle with label
    Badge          — status indicators, color variants
    Avatar         — image with fallback initials, sizes

  Tier 2 — Layout:
    Card           — header, body, footer, with shadow levels
    Dialog         — modal with title, description, actions, close
    Sheet          — side panel (mobile-first alternative to dialog)
    Tabs           — horizontal tab navigation
    Accordion      — expandable sections
    Separator      — horizontal/vertical divider

  Tier 3 — Data:
    Table          — sortable, with row selection, pagination
    DataTable      — Table + column filtering, server-side data
    Tooltip        — hover information
    Popover        — click-triggered content
    DropdownMenu   — action menu with submenus
    Toast          — notification messages

  Tier 4 — Navigation:
    Breadcrumb     — location hierarchy
    Pagination     — page navigation
    NavigationMenu — top-level site navigation
    Sidebar        — app navigation

COMPONENT ARCHITECTURE (per component):
  /packages/ui/src/components/button/
    Button.tsx          # Component implementation
    Button.test.tsx     # Unit tests (behavior + accessibility)
    Button.stories.tsx  # Storybook stories (all variants)
    button.css          # Component-specific styles (if any)
    index.ts            # Public export

BUILDING:
  Each component follows TDD:
    RED:   test for rendering, accessibility, keyboard interaction
    GREEN: implement with Radix UI primitive + token-based styling
    REFACTOR: extract shared patterns

  Component rules:
    - Built on Radix UI primitives (accessibility built-in)
    - Styled with Tailwind classes mapped to tokens
    - Forwarded refs (React.forwardRef)
    - Polymorphic (asChild prop for render delegation)
    - All interactive states: default, hover, focus, active, disabled
    - Keyboard navigable: Tab, Enter, Space, Escape, Arrow keys

  Progress:
    ✓ Button (8 variants, 6 tests, 12 stories)
    ✓ Input (5 variants, 8 tests, 10 stories)
    ✓ Select (3 variants, 10 tests, 8 stories)
    ✓ Checkbox, Radio, Switch (18 tests, 15 stories)
    ✓ Badge, Avatar (6 tests, 8 stories)
    ✓ Card, Dialog, Sheet (12 tests, 14 stories)
    ✓ Table, Toast, Tooltip (15 tests, 12 stories)
    [... continues through all tiers ...]

  Total: 24 components, 112 tests, 96 Storybook stories

Commit: "ui: 24 components — Button through Sidebar, all tested and documented"
```

### Phase 4: Accessibility Audit

```
> /godmode:a11y

Godmode: Running accessibility audit on component library...

WCAG 2.1 AUDIT — COMPONENT LIBRARY:

  Automated checks (axe-core on every Storybook story):
    96 stories tested
    ✓ 94 stories pass all automated checks
    ✗ 2 findings:

    FINDING 1: Toast component — insufficient color contrast
      Level: AA violation
      Component: Toast (warning variant)
      Issue: amber-500 text on amber-50 background = 3.8:1 ratio (needs 4.5:1)
      Fix: Changed to amber-700 text → 5.2:1 ratio ✓

    FINDING 2: Dialog — focus trap incomplete
      Level: A violation
      Component: Dialog
      Issue: Tab key exits dialog when content overflows
      Fix: Added focus-trap-react to Dialog component ✓

  Manual checks (keyboard + screen reader):
    ✓ All buttons: Enter and Space activate
    ✓ All dialogs: Escape closes, focus returns to trigger
    ✓ All dropdowns: Arrow keys navigate, Enter selects
    ✓ All forms: Tab order matches visual order
    ✓ All text: resize to 200% without content loss
    ✓ Focus indicator: visible on all interactive elements (2px blue ring)
    ✓ Color: no information conveyed by color alone (icons + text accompany)
    ✓ Motion: respects prefers-reduced-motion

  Screen reader testing:
    ✓ VoiceOver (macOS Safari): all components announce correctly
    ✓ NVDA (Windows Chrome): all components announce correctly
    ✓ Role, state, and property announcements verified per component

VERDICT: PASS (2 findings fixed)
  WCAG 2.1 AA: COMPLIANT
  WCAG 2.1 AAA: PARTIAL (text contrast AAA for body text, not all decorative elements)

Commit: "a11y: WCAG 2.1 AA compliant — 2 findings fixed, all 96 stories pass"
```

### Phase 5: Visual Regression Testing

```
> /godmode:visual

Godmode: Setting up visual regression testing...

VISUAL TESTING CONFIGURED:

  Tool: Chromatic (connected to Storybook)
  Browsers: Chrome, Firefox, Safari
  Viewports: 375px (mobile), 768px (tablet), 1280px (desktop)

  Baseline captured:
    96 stories × 3 browsers × 3 viewports = 864 snapshots

  Test modes:
    - Light mode + Dark mode (all stories)
    - Default + Hover + Focus + Active + Disabled (interactive components)
    - LTR + RTL (text direction)

  Total visual snapshots: 1,728

  CI integration:
    On every PR: Chromatic runs visual diff
    Reviewers approve/reject visual changes
    No merge until visual review approved

  Threshold:
    Pixel diff > 0.1% → flagged for review
    Layout shift > 0 → auto-rejected

Commit: "visual: 1,728 visual regression snapshots across browsers and viewports"
```

### Phase 6: Documentation

```
> /godmode:docs --storybook

Godmode: Generating design system documentation...

DOCUMENTATION:

  Storybook (component playground):
    /storybook
      Getting Started      — Installation, setup, theming
      Design Tokens        — Color, spacing, typography with live previews
      Components
        /Button            — Props, variants, playground, code examples
        /Input             — Props, validation patterns, accessibility notes
        [... all 24 components ...]
      Patterns
        /Forms             — How to compose form layouts
        /Navigation        — App navigation patterns
        /Feedback          — Loading, error, empty states
      Changelog            — Version history with visual diffs

  Usage documentation:
    README.md:
      - Installation: npm install @acme/ui @acme/tokens
      - Quick start: import and use in 3 lines
      - Tailwind setup: add @acme/tailwind preset
      - Theming: customize tokens for brand

    CONTRIBUTING.md:
      - How to add a new component
      - Component checklist (tests, stories, a11y, visual)
      - PR template for component changes

  Figma sync:
    Token JSON exported for Figma Tokens plugin
    Component specs mapped to Figma components
    Designers and developers share the same token values

Commit: "docs: Storybook documentation site, usage guide, contributing guide"
```

### Phase 7: Ship (Publish to npm)

```
> /godmode:ship --npm

Godmode: Publishing design system packages...

PRE-PUBLISH CHECKS:
  ✓ All 112 tests passing
  ✓ All 96 accessibility checks passing
  ✓ All 1,728 visual snapshots approved
  ✓ Build: TypeScript compiles without errors
  ✓ Bundle size: @acme/ui = 42KB gzipped (tree-shakeable)
  ✓ No circular dependencies
  ✓ package.json exports configured (ESM + CJS)
  ✓ Type declarations included (.d.ts)

PUBLISHED:
  @acme/tokens@1.0.0   — Design tokens (CSS + JSON + Tailwind preset)
  @acme/ui@1.0.0        — React component library
  @acme/icons@1.0.0     — Icon set (48 icons)
  @acme/tailwind@1.0.0  — Tailwind CSS preset

  Registry: npm (private, @acme scope)

  Storybook deployed: https://design.acme.com
  Changelog published: CHANGELOG.md

ADOPTION:
  Migration guide for existing projects:
    1. Install: npm install @acme/ui @acme/tokens @acme/tailwind
    2. Add Tailwind preset to tailwind.config.ts
    3. Replace custom components one at a time
    4. Remove duplicated styles as components are adopted

  Estimated migration effort:
    Main web app:      ~3 days (47 custom components → 24 @acme/ui)
    Admin dashboard:   ~2 days (32 custom components → 20 @acme/ui)
    Marketing site:    ~1 day (tokens only, Astro doesn't use React)

Commit: "ship: @acme/ui@1.0.0 published — 24 components, accessible, tested"
```

---

## Design Token Architecture

### Token Layers

```
LAYER 1: PRIMITIVE TOKENS (raw values)
  blue-500: #3B82F6
  gray-900: #111827
  space-4: 16px
  radius-md: 6px

  → These never change between themes.
  → Named by what they ARE, not what they DO.

LAYER 2: SEMANTIC TOKENS (meaning)
  color-primary: blue-600        → light mode
  color-primary: blue-400        → dark mode
  color-bg-page: white           → light mode
  color-bg-page: gray-950        → dark mode

  → These change between themes.
  → Named by what they DO, not what they ARE.

LAYER 3: COMPONENT TOKENS (scoped)
  button-bg-primary: color-primary
  button-text-primary: white
  button-radius: radius-md
  button-padding-x: space-4
  button-padding-y: space-2

  → Scoped to a single component.
  → Override semantic tokens for component-specific needs.
```

### Token Distribution

```
DISTRIBUTION FORMATS:

  CSS Custom Properties (@acme/tokens/css):
    :root {
      --color-primary: #3B82F6;
      --space-4: 16px;
    }
    .dark {
      --color-primary: #60A5FA;
    }

  Tailwind Preset (@acme/tailwind):
    // tailwind.config.ts
    import { acmePreset } from '@acme/tailwind';
    export default {
      presets: [acmePreset],
    };

  JavaScript/TypeScript (@acme/tokens):
    import { colors, spacing } from '@acme/tokens';
    // colors.primary → '#3B82F6'

  JSON (@acme/tokens/json):
    For Figma Tokens plugin synchronization
    For Style Dictionary transformation
    For design tool integration
```

---

## Component Checklist

Every component must meet these criteria before shipping.

```
COMPONENT SHIP CHECKLIST:
  Functionality:
    [ ] All variants render correctly
    [ ] All interactive states work (hover, focus, active, disabled)
    [ ] Keyboard navigation works (Tab, Enter, Space, Escape, Arrows)
    [ ] Works with React.forwardRef
    [ ] Supports asChild for render delegation
    [ ] TypeScript types are complete and exported

  Accessibility:
    [ ] ARIA roles, states, and properties correct
    [ ] axe-core automated checks pass
    [ ] Screen reader announces correctly (VoiceOver + NVDA)
    [ ] Focus indicator is visible (2px ring)
    [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 UI)
    [ ] Works at 200% zoom without content loss
    [ ] Respects prefers-reduced-motion

  Visual:
    [ ] Light mode + Dark mode correct
    [ ] Mobile + Tablet + Desktop responsive
    [ ] LTR + RTL text direction
    [ ] Visual regression snapshots captured
    [ ] Matches Figma design spec (within 2px)

  Testing:
    [ ] Unit tests for all props and states
    [ ] Accessibility tests (render + interaction)
    [ ] Storybook stories for all variants
    [ ] Edge cases: empty content, long content, special characters

  Documentation:
    [ ] Storybook story with controls
    [ ] Props table with descriptions and defaults
    [ ] Usage examples (common patterns)
    [ ] Do's and Don'ts
    [ ] Accessibility notes (keyboard shortcuts, screen reader behavior)
```

---

## See Also

- [Master Skill Index](../skill-index.md) — `/godmode:ui`, `/godmode:a11y`, `/godmode:visual`
- [Skill Chains](../skill-chains.md) — frontend-quality chain
- [Building a Mobile App](mobile-app.md) — Shared design tokens for mobile
- [Building an MVP](startup-mvp.md) — Using shadcn/ui for fast MVPs
