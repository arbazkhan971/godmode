---
name: ui
description: |
  UI component architecture skill. Activates when user needs to design component libraries, enforce design system consistency, set up Storybook, make CSS architecture decisions, or improve UI code quality. Covers component composition patterns, styling strategies, documentation, and design token management. Triggers on: /godmode:ui, "component architecture", "design system", "UI review", "Storybook setup", or when building reusable UI components.
---

# UI — UI Component Architecture

## When to Activate
- User invokes `/godmode:ui`
- User says "design system review," "component architecture," "UI structure"
- When creating a new component library or design system
- When choosing CSS architecture (CSS Modules vs Tailwind vs CSS-in-JS)
- Before building reusable components or shared UI packages
- When Storybook needs setup, configuration, or story writing
- When UI code review flags inconsistency with design system

## Workflow

### Step 1: Analyze Current UI Architecture
Survey the existing component structure and styling approach:

```
UI ARCHITECTURE ANALYSIS:
Framework: <React/Vue/Angular/Svelte/vanilla>
Styling approach: <CSS Modules/Tailwind/styled-components/Emotion/SCSS/vanilla CSS>
Component library: <custom/MUI/Ant/Chakra/shadcn/Radix/none>
Storybook: <yes (version)/no>
Design tokens: <yes (format)/no>
Component count: <N>

Directory structure:
  src/
    components/     <N> components
    styles/         <global styles>
    hooks/          <UI-specific hooks>
    utils/          <UI utilities>
    tokens/         <design tokens>

Consistency score: <HIGH/MEDIUM/LOW>
Issues detected: <N>
```

### Step 2: Component Composition Audit
Evaluate how components are structured and composed:

#### Component Hierarchy Analysis
```
COMPONENT HIERARCHY:
┌─────────────────────────────────────────────────────────────────┐
│ Level          │ Components    │ Examples                       │
├─────────────────────────────────────────────────────────────────┤
│ Atoms          │ <N>           │ Button, Input, Label, Icon     │
│ Molecules      │ <N>           │ FormField, SearchBar, Card     │
│ Organisms      │ <N>           │ Header, Sidebar, DataTable     │
│ Templates      │ <N>           │ DashboardLayout, AuthLayout    │
│ Pages          │ <N>           │ HomePage, SettingsPage         │
└─────────────────────────────────────────────────────────────────┘

Composition patterns detected:
- [ ] Compound components (Menu + Menu.Item)
- [ ] Render props
- [ ] Slots / children composition
- [ ] Higher-order components
- [ ] Custom hooks for UI logic
- [ ] Context providers for theming
```

#### Component Quality Checklist
For each component, assess:
```
COMPONENT: <Name>
- [ ] Single responsibility — does one thing well
- [ ] Props interface is minimal and well-typed
- [ ] Default props for optional values
- [ ] Forwards ref when wrapping native elements
- [ ] Accepts className/style for customization
- [ ] Has display name for dev tools
- [ ] Memoized appropriately (React.memo, useMemo)
- [ ] Error boundary for complex components
- [ ] Loading/empty/error states handled
- [ ] Accessible (keyboard, ARIA, contrast)
- [ ] Responsive across breakpoints
- [ ] Documented with Storybook stories
- [ ] Has unit/visual tests
```

### Step 3: CSS Architecture Decision
Evaluate and recommend the right CSS strategy:

#### CSS Approach Comparison
```
CSS ARCHITECTURE DECISION MATRIX:
┌─────────────────────────────────────────────────────────────────────────┐
│ Criterion         │ CSS Modules │ Tailwind  │ CSS-in-JS │ SCSS       │
├─────────────────────────────────────────────────────────────────────────┤
│ Scoping           │ Automatic   │ Utility   │ Automatic │ Manual     │
│ Bundle size       │ Small       │ Small*    │ Variable  │ Small      │
│ Runtime cost      │ None        │ None      │ Yes       │ None       │
│ Type safety       │ With plugin │ With plugin│ Native   │ No         │
│ DX/Speed          │ Good        │ Fast      │ Good      │ Good       │
│ Theming           │ CSS vars    │ Config    │ Native    │ Variables  │
│ SSR friendly      │ Yes         │ Yes       │ Depends   │ Yes        │
│ Learning curve    │ Low         │ Medium    │ Medium    │ Low        │
│ Design tokens     │ CSS vars    │ Config    │ Theme obj │ Variables  │
│ Team scalability  │ Good        │ Good      │ Moderate  │ Moderate   │
└─────────────────────────────────────────────────────────────────────────┘
* Tailwind with purge/JIT
```

#### Recommendation Logic
```
IF project has existing design system with tokens → CSS Modules + CSS custom properties
IF rapid prototyping or small team → Tailwind CSS
IF complex theming (dark mode, multi-brand) → CSS-in-JS (Emotion/styled-components)
IF legacy project with established SCSS → Keep SCSS, migrate incrementally
IF server-side rendering is critical → Avoid runtime CSS-in-JS
IF using component library (MUI, Chakra) → Match library's approach
```

### Step 4: Design System Consistency
Audit adherence to the design system:

#### Design Token Inventory
```
DESIGN TOKEN AUDIT:
┌─────────────────────────────────────────────────────────────────┐
│ Token Category   │ Defined │ Used │ Hardcoded │ Violations     │
├─────────────────────────────────────────────────────────────────┤
│ Colors           │ 24      │ 22   │ 7         │ 7 hardcoded    │
│ Typography       │ 8       │ 6    │ 3         │ 2 missing, 3 hc│
│ Spacing          │ 12      │ 10   │ 5         │ 5 hardcoded    │
│ Border radius    │ 4       │ 4    │ 1         │ 1 hardcoded    │
│ Shadows          │ 3       │ 2    │ 2         │ 1 missing, 2 hc│
│ Z-index          │ 5       │ 3    │ 4         │ 4 hardcoded    │
│ Breakpoints      │ 5       │ 5    │ 0         │ 0              │
│ Transitions      │ 3       │ 1    │ 2         │ 2 missing, 2 hc│
└─────────────────────────────────────────────────────────────────┘

hc = hardcoded (using raw values instead of tokens)

Total violations: <N>
Priority fixes: <list of highest-impact violations>
```

#### Hardcoded Value Detection
```bash
# Find hardcoded colors (hex, rgb, hsl not using tokens)
grep -rn "#[0-9a-fA-F]\{3,6\}" src/ --include="*.css" --include="*.tsx" --include="*.scss"

# Find hardcoded pixel values for spacing
grep -rn "margin:\|padding:\|gap:" src/ --include="*.css" --include="*.scss" | grep -v "var(--"

# ... (condensed)
```

### Step 5: Component Library Structure
Define or validate the component library architecture:

#### Recommended Directory Structure
```
src/
  components/
    Button/
      Button.tsx              # Component implementation
      Button.module.css       # Component styles
      Button.test.tsx         # Unit tests
      Button.stories.tsx      # Storybook stories
      Button.types.ts         # TypeScript interfaces
      index.ts                # Public export
    DataTable/
      DataTable.tsx
      DataTable.module.css
      DataTable.test.tsx
      DataTable.stories.tsx
      DataTable.types.ts
```

#### Component File Template
```typescript
// components/Button/Button.tsx
import React, { forwardRef } from 'react';
import type { ButtonProps } from './Button.types';
import styles from './Button.module.css';
import { clsx } from 'clsx';

# ... (condensed)
```

```typescript
// components/Button/Button.types.ts
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style variant */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** Size of the button */
  size?: 'small' | 'medium' | 'large';
# ... (condensed)
```

### Step 6: Storybook Integration
Set up or audit Storybook configuration:

#### Storybook Setup
```bash
# Initialize Storybook (auto-detects framework)
npx storybook@latest init

# Add essential addons
npm install --save-dev @storybook/addon-a11y @storybook/addon-viewport @storybook/addon-docs
```

#### Story Template
```typescript
// components/Button/Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Components/Button',
# ... (condensed)
```

#### Story Quality Checklist
```
STORYBOOK AUDIT:
┌─────────────────────────────────────────────────────────────────────┐
│ Component         │ Stories │ Docs  │ Controls │ A11y addon │ Status│
├─────────────────────────────────────────────────────────────────────┤
│ Button            │ 5       │ Yes   │ Yes      │ Passing    │ GOOD  │
│ Input             │ 3       │ Yes   │ Yes      │ 1 warning  │ OK    │
│ DataTable         │ 1       │ No    │ No       │ Not tested │ POOR  │
│ Modal             │ 0       │ No    │ No       │ Not tested │ NONE  │
│ Card              │ 2       │ Yes   │ Partial  │ Passing    │ OK    │
└─────────────────────────────────────────────────────────────────────┘

Coverage:
  Components with stories: <N>/<total> (<X>%)
  Components with docs: <N>/<total> (<X>%)
  Components with controls: <N>/<total> (<X>%)
  Components with a11y checks: <N>/<total> (<X>%)
```

### Step 7: Component Documentation
Ensure every component is properly documented:

#### Documentation Requirements
Each component must have:
```
1. Purpose — what the component does and when to use it
2. Props table — all props with types, defaults, and descriptions
3. Usage examples — code snippets for common use cases
4. Variants — visual examples of all variants/states
5. Do/Don't — guidance on correct vs incorrect usage
6. Accessibility — keyboard behavior, ARIA requirements
7. Related components — links to related or alternative components
```

#### Auto-doc with Storybook
```typescript
// In story file, use autodocs tag
const meta: Meta<typeof Button> = {
  title: 'Components/Button',
  component: Button,
  tags: ['autodocs'],  // Generates docs from JSDoc and TypeScript types
  parameters: {
# ... (condensed)
```

### Step 8: Pattern Consistency Rules
Define and enforce component patterns across the codebase:

#### Naming Conventions
```
NAMING RULES:
Components: PascalCase (Button, DataTable, NavigationBar)
Files: PascalCase matching component (Button.tsx, DataTable.tsx)
Styles: ComponentName.module.css (Button.module.css)
Stories: ComponentName.stories.tsx (Button.stories.tsx)
Tests: ComponentName.test.tsx (Button.test.tsx)
Types: ComponentName.types.ts (Button.types.ts)
Hooks: use<Purpose> (useMediaQuery, useFocusTrap)
Tokens: kebab-case with category prefix (--color-primary, --spacing-md)
```

#### Component API Conventions
```
API CONVENTIONS:
- Props extend native HTML element attributes
- variant prop for visual styles (not "type" or "kind")
- size prop for dimensions ("small" | "medium" | "large")
- Render children via children prop (not "content" or "text")
- Event handlers follow on<Event> convention (onClick, onChange)
- Boolean props are positive (isOpen, not isClosed)
- Ref forwarding for all components wrapping native elements
- className accepted for style customization
- No inline styles in component implementations
- Destructure known props, spread rest onto root element
```

#### Violations Report
```
PATTERN VIOLATIONS:
┌──────────────────────────────────────────────────────────────────┐
│ Violation                  │ Count │ Files                      │
├──────────────────────────────────────────────────────────────────┤
│ Hardcoded colors           │ 7     │ Card.css, Modal.css, ...   │
│ Missing TypeScript types   │ 3     │ Tooltip.tsx, Badge.tsx, ...│
│ No ref forwarding          │ 5     │ Input.tsx, Select.tsx, ... │
│ Inconsistent prop naming   │ 2     │ Tabs (kind vs variant)     │
│ Missing Storybook stories  │ 4     │ Modal, Toast, Drawer, ...  │
│ No display name            │ 6     │ Various forwardRef comps   │
│ Missing loading states     │ 3     │ DataTable, Form, Image     │
└──────────────────────────────────────────────────────────────────┘
```

### Step 9: Recommendations Report

```
+------------------------------------------------------------+
|  UI ARCHITECTURE REPORT — <project>                         |
+------------------------------------------------------------+
|  Framework: <framework>                                     |
|  Styling: <approach>                                        |
|  Components: <N> total                                      |
|                                                             |
|  Component Quality:                                         |
|  Well-structured:  <N> components                           |
|  Needs improvement: <N> components                          |
|                                                             |
```

### Step 10: Commit and Transition
1. If auto-fixes were applied (token replacement, ref forwarding, display names):
   - Commit: `"ui: fix <N> component architecture violations"`
2. If Storybook stories were generated:
   - Commit: `"ui: add Storybook stories for <N> components"`
3. Save report: `docs/ui/<project>-ui-audit.md`
4. Commit report: `"ui: <project> — architecture audit (<N> components, <N> violations)"`
5. Transition: "UI audit complete. Run `/godmode:a11y` for accessibility, or `/godmode:visual` for visual regression testing."

## Key Behaviors

1. **Components are the unit of UI.** Build every piece of UI as a component with clear boundaries, typed props, tests, and documentation. No loose markup scattered across pages.
2. **Design tokens are mandatory.** Every color, spacing value, font size, shadow, and z-index should come from a token. Hardcoded values are bugs waiting to cause inconsistency.
3. **Storybook is the component catalog.** Every component needs stories. Stories serve as documentation, visual testing targets, and a development sandbox. No exceptions for "simple" components.
4. **Consistency over cleverness.** Every component should follow the same patterns: same prop naming, same file structure, same composition approach. Predictability is a feature.
5. **CSS architecture is a team decision.** Pick one approach and use it everywhere. Mixing CSS Modules with styled-components with Tailwind creates cognitive overhead and maintenance burden.
6. **Composition over configuration.** Prefer `<Card><Card.Header>Title</Card.Header></Card>` over `<Card title="Title" headerVariant="bold">`. Composition is more flexible and easier to type.
7. **Document the "why" not the "what."** Component docs should explain when to use a component and when NOT to. "Use Button for actions, use Link for navigation" prevents misuse.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full UI architecture audit |
| `--component <name>` | Audit a specific component |
| `--tokens` | Design token audit only |

## HARD RULES

1. **NEVER mix CSS approaches.** Pick one (CSS Modules, Tailwind, styled-components) and standardize across the project.
2. **NEVER create God components.** A component with 30 props and 500 lines is not a component. Break it into smaller, composable pieces.
3. **NEVER hardcode colors or spacing.** Use design tokens (`var(--color-text-primary)`), not raw hex values or pixel literals.
4. **NEVER couple UI components to business logic.** A Button should not know about API calls. A DataTable should not know about user permissions. Pass data and callbacks via props.
5. **ALWAYS type every component prop.** `any` props are not a component API. Every prop needs a type and a description.
6. **ALWAYS write Storybook stories for every component**, including "simple" ones. They have variants, states, and edge cases.
7. **ALWAYS design mobile-first.** Building desktop-first and fixing mobile is 3x more work than starting mobile-first.
8. **NEVER use inline styles for component internals.** They bypass the cascade, cannot be themed, cannot be responsive, and cannot be overridden.

## Auto-Detection

On activation, detect the UI architecture context:

```bash
# Detect framework
grep -r "react\|vue\|svelte\|@angular/core" package.json 2>/dev/null

# Detect CSS approach
grep -r "tailwindcss\|styled-components\|@emotion\|css-modules\|sass\|less" package.json 2>/dev/null

# ... (condensed)
```

## Output Format

After each UI skill invocation, emit a summary table:

```
UI BUILD REPORT:
┌──────────────────────────────────────────────────────┐
│  Components built  │  <N>                             │
│  Components updated│  <N>                             │
│  Storybook stories │  <N> created / <N> updated       │
│  Tests             │  <N> passing, <N> failing        │
│  Tokens used       │  <N> design tokens referenced    │
│  A11y checks       │  <N> passing, <N> violations     │
│  Bundle impact     │  +<N> KB (gzipped)               │
│  Verdict           │  PASS | NEEDS REVISION           │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every UI skill run for tracking:

```
timestamp	skill	component	action	tests_pass	a11y_pass	bundle_kb	status
2026-03-20T14:00:00Z	ui	Button	create	12/12	0 violations	2.1	pass
2026-03-20T14:05:00Z	ui	DataTable	update	8/8	1 violation	4.3	needs_fix
```

## Success Criteria

The UI skill is complete when ALL of the following are true:
1. Every component renders without errors in Storybook (or equivalent)
2. Every component has TypeScript props with descriptions and default values
3. Every component has at least one test covering its primary use case
4. Zero accessibility violations from axe-core on all component stories
5. All design tokens are referenced (no hardcoded colors, spacing, or typography)
6. Bundle size impact is documented and within project budget
7. The build passes with zero TypeScript errors and zero lint warnings

## Error Recovery

```
IF component fails to render in Storybook:
  1. Check console for import errors or missing dependencies
  2. Verify all peer dependencies are installed
  3. Check for circular imports in component tree
  4. Revert last change and re-test

IF accessibility violations are found:
  1. Fix all CRITICAL violations immediately (keyboard traps, missing labels)
  2. Fix HIGH violations before commit (contrast, ARIA roles)
  3. Log MEDIUM violations as follow-up tasks
  4. Re-run axe-core after each fix to confirm resolution

IF bundle size exceeds budget:
  1. Check for accidentally imported full library (e.g., all of lodash)
  2. Verify tree-shaking is working (named imports, sideEffects: false)
```

## Component Library Audit Loop

Autoresearch-grade iterative audit for UI component library quality. Measures consistency scoring, design token coverage, and component completeness through structured, metrics-driven cycles.

```
COMPONENT LIBRARY AUDIT PROTOCOL:

Phase 1 — Consistency Scoring
  Score every component against a unified quality rubric (0-100 per component).

  COMPONENT QUALITY RUBRIC (per component, max 100 points):
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Criterion                              │  Points  │  How to Verify  │
  ├─────────────────────────────────────────┼──────────┼─────────────────┤
  │  TypeScript props with descriptions     │  10      │  Check .types.ts│
  │  Default values for optional props      │  5       │  Check defaults │
  │  Ref forwarding (if wraps native elem)  │  5       │  Check forwardRef│
  │  className/style override accepted      │  5       │  Check props    │
  │  Consistent prop naming (variant/size)  │  10      │  Compare to std │
  │  All design tokens used (no hardcoded)  │  15      │  Grep for raw   │
```
After EACH component fix or token replacement:
  1. MEASURE: Run visual regression test — does the component look the same?
  2. VERIFY: Storybook renders without errors, axe-core shows zero violations.
  3. DECIDE:
     - KEEP if: visual output unchanged AND no accessibility regressions AND tests pass
     - DISCARD if: visual regression detected OR new a11y violation OR build breaks
  4. COMMIT kept changes. Revert discarded changes before next component.

Never keep a token replacement that changes visual output without explicit approval.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All components render in Storybook without errors
  - Design token coverage >= 95% (no hardcoded visual values)
  - Zero accessibility violations from axe-core
  - User explicitly requests stop

DO NOT STOP just because:
  - One component has a low consistency score (fix it)
  - Storybook docs are incomplete for low-priority components
```
## Keep/Discard Discipline
```
After EACH UI change:
  KEEP if: visual regression test passes AND a11y audit clean AND responsive at all breakpoints
  DISCARD if: visual regression detected OR a11y violation introduced OR layout breaks at any breakpoint
  On discard: revert. Screenshot diff before and after to identify the regression.
```
