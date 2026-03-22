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

# Find hardcoded z-index values
grep -rn "z-index:" src/ --include="*.css" --include="*.tsx" --include="*.scss"
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
      components/             # Sub-components
        TableHeader.tsx
        TableRow.tsx
        TableCell.tsx
      hooks/                  # Component-specific hooks
        useTableSort.ts
        useTablePagination.ts
      index.ts
  tokens/
    colors.css                # Color tokens
    typography.css            # Typography tokens
    spacing.css               # Spacing tokens
    index.css                 # Token aggregation
  styles/
    globals.css               # Global styles, resets
    utilities.css             # Utility classes
  hooks/
    useMediaQuery.ts          # Shared UI hooks
    useClickOutside.ts
    useFocusTrap.ts
```

#### Component File Template
```typescript
// components/Button/Button.tsx
import React, { forwardRef } from 'react';
import type { ButtonProps } from './Button.types';
import styles from './Button.module.css';
import { clsx } from 'clsx';

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'medium', children, className, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={clsx(styles.button, styles[variant], styles[size], className)}
        {...props}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

```typescript
// components/Button/Button.types.ts
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style variant */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** Size of the button */
  size?: 'small' | 'medium' | 'large';
  /** Loading state */
  loading?: boolean;
}
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
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost', 'danger'],
      description: 'Visual style variant',
    },
    size: {
      control: 'select',
      options: ['small', 'medium', 'large'],
      description: 'Size of the button',
    },
    disabled: { control: 'boolean' },
    loading: { control: 'boolean' },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: { children: 'Primary Button', variant: 'primary' },
};

export const Secondary: Story = {
  args: { children: 'Secondary Button', variant: 'secondary' },
};

export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="danger">Danger</Button>
    </div>
  ),
};

export const AllSizes: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
      <Button size="small">Small</Button>
      <Button size="medium">Medium</Button>
      <Button size="large">Large</Button>
    </div>
  ),
};

export const States: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
      <Button>Default</Button>
      <Button disabled>Disabled</Button>
      <Button loading>Loading</Button>
    </div>
  ),
};
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
    docs: {
      description: {
        component: 'Primary UI button component. Use for actions and form submissions.',
      },
    },
  },
};
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
|  Missing standards: <N> components                          |
|                                                             |
|  Design System:                                             |
|  Token coverage: <X>%                                       |
|  Hardcoded values: <N> violations                           |
|  Naming consistency: <HIGH/MEDIUM/LOW>                      |
|                                                             |
|  Storybook:                                                 |
|  Story coverage: <X>%                                       |
|  Doc coverage: <X>%                                         |
|  A11y addon coverage: <X>%                                  |
|                                                             |
|  CSS Architecture:                                          |
|  Current: <approach>                                        |
|  Recommendation: <keep/migrate to X>                        |
|  Justification: <reason>                                    |
|                                                             |
|  Priority Actions:                                          |
|  1. <highest impact improvement>                            |
|  2. <second improvement>                                    |
|  3. <third improvement>                                     |
+------------------------------------------------------------+
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

1. **Components are the unit of UI.** Every piece of UI should be a component with clear boundaries, typed props, tests, and documentation. No loose markup scattered across pages.
2. **Design tokens are mandatory.** Every color, spacing value, font size, shadow, and z-index should come from a token. Hardcoded values are bugs waiting to cause inconsistency.
3. **Storybook is the component catalog.** Every component needs stories. Stories serve as documentation, visual testing targets, and a development sandbox. No exceptions for "simple" components.
4. **Consistency over cleverness.** Every component should follow the same patterns: same prop naming, same file structure, same composition approach. Predictability is a feature.
5. **CSS architecture is a team decision.** Pick one approach and use it everywhere. Mixing CSS Modules with styled-components with Tailwind creates cognitive overhead and maintenance burden.
6. **Composition over configuration.** Prefer `<Card><Card.Header>Title</Card.Header></Card>` over `<Card title="Title" headerVariant="bold">`. Composition is more flexible and easier to type.
7. **Document the "why" not just the "what."** Component docs should explain when to use a component and when NOT to. "Use Button for actions, use Link for navigation" prevents misuse.

## Example Usage

### Full UI architecture review
```
User: /godmode:ui

UI: Analyzing component architecture...

UI ARCHITECTURE ANALYSIS:
Framework: React 18
Styling: Mixed (CSS Modules + some inline styles)
Component library: Custom (37 components)
Storybook: Yes (v7.6) — 22/37 components have stories
Design tokens: Partial (colors defined, spacing hardcoded)

Component Quality:
Well-structured: 18 components
Needs improvement: 12 components
Missing standards: 7 components

FINDING 1: 7 components have hardcoded color values
  Card.module.css: #f5f5f5 → should use var(--color-surface)
  Modal.module.css: #333 → should use var(--color-text-primary)
  ...

FINDING 2: 5 components missing ref forwarding
  Input, Select, Textarea, Checkbox, Radio

FINDING 3: 15 components missing Storybook stories
  ...

Priority Actions:
1. Replace 23 hardcoded values with design tokens
2. Add ref forwarding to 5 form components
3. Write Storybook stories for 15 undocumented components

Verdict: MEDIUM consistency — 12 violations require attention.
```

### CSS architecture decision
```
User: /godmode:ui --css-decision

UI: Analyzing project context for CSS recommendation...

Project context:
- React 18 with Next.js 14
- SSR required
- 3 developers
- Dark mode requirement
- No existing CSS architecture

Recommendation: Tailwind CSS + CSS custom properties for tokens

Justification:
- SSR compatible (no runtime CSS)
- Fast development velocity for small team
- Built-in dark mode support via class strategy
- Design tokens map directly to tailwind.config.ts
- Consistent output across team members
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full UI architecture audit |
| `--component <name>` | Audit a specific component |
| `--tokens` | Design token audit only |
| `--storybook` | Storybook coverage audit only |
| `--css-decision` | CSS architecture recommendation |
| `--structure` | Component directory structure audit |
| `--patterns` | Component API pattern consistency check |
| `--fix` | Auto-fix violations (token replacement, ref forwarding, display names) |
| `--init` | Initialize component library structure from scratch |
| `--generate <name>` | Generate a new component with all standard files |

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

# Detect component library
grep -r "radix\|shadcn\|chakra\|mantine\|ant-design\|material-ui\|headless" package.json 2>/dev/null

# Detect Storybook
ls .storybook/ 2>/dev/null
grep -r "storybook" package.json 2>/dev/null

# Count components
find src/ -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" 2>/dev/null | wc -l

# Detect design tokens
find src/ -name "tokens.*" -o -name "theme.*" -o -name "design-system.*" 2>/dev/null
```

## Multi-Agent Dispatch

For large component library builds, dispatch parallel agents:

```
DISPATCH 3 agents:
  Agent 1 (worktree: ui-primitives):  Primitive components (Button, Input, Label, Badge, Avatar)
  Agent 2 (worktree: ui-composite):   Composite components (Dialog, Dropdown, DataTable, Form)
  Agent 3 (worktree: ui-layout):      Layout components (Sidebar, Nav, Page, Grid) + design tokens

MERGE order: Agent 3 (tokens/layout) first, then Agent 1 (primitives), then Agent 2 (composites)
CONFLICT resolution: Token definitions in Agent 3 are authoritative
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
  3. Consider lazy-loading heavy components (code splitting)
  4. If unavoidable, document the size increase and justify it

IF TypeScript errors block build:
  1. Fix type errors in the component file first
  2. Update prop interfaces to match actual usage
  3. Never use `as any` to suppress errors — find the correct type
  4. Run `tsc --noEmit` to verify zero errors before commit
```

## Anti-Patterns

- **Do NOT mix CSS approaches.** CSS Modules in some components, styled-components in others, and Tailwind in a third creates maintenance chaos. Pick one and standardize.
- **Do NOT skip TypeScript types for props.** `any` props are not a component API. Every prop needs a type, a description, and a default value where appropriate.
- **Do NOT create God components.** A component with 30 props and 500 lines is not a component, it is an application. Break it down into smaller, composable pieces.
- **Do NOT use hardcoded values.** `color: #333` instead of `color: var(--color-text-primary)` means the next design update will miss this component. Use tokens.
- **Do NOT skip Storybook for "simple" components.** A "simple" Label component still has variants, states, and edge cases. It still needs documentation. Write the story.
- **Do NOT couple UI components to business logic.** A Button should not know about API calls. A DataTable should not know about user permissions. Pass data and callbacks via props.
- **Do NOT ignore mobile-first design.** Building desktop-first and then "fixing" mobile is 3x more work than starting mobile-first. Design for the smallest viewport first.
- **Do NOT use inline styles for component internals.** Inline styles bypass the cascade, cannot be themed, cannot be responsive, and cannot be overridden by consumers. Use your chosen CSS approach.


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
  │  Storybook story with all variants      │  10      │  Check stories  │
  │  Storybook docs (autodocs or MDX)       │  5       │  Check docs     │
  │  Unit test covering primary use case    │  10      │  Check test file│
  │  Accessibility (keyboard + ARIA)        │  10      │  axe-core check │
  │  Responsive (works at 320px+)           │  5       │  Visual check   │
  │  Loading/empty/error states handled     │  5       │  Check variants │
  │  displayName set (for React DevTools)   │  5       │  Check code     │
  └─────────────────────────────────────────┴──────────┴─────────────────┘

  FOR EACH component in the library:
    1. EVALUATE against each criterion
    2. CALCULATE score (0-100)
    3. CLASSIFY:
       - 90-100: EXCELLENT — no action needed
       - 70-89: GOOD — minor improvements
       - 50-69: NEEDS WORK — significant gaps
       - 0-49: POOR — major remediation required

  CONSISTENCY SCORECARD:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Component     │  Types │ Tokens │ Story │ Test │ A11y │  TOTAL     │
  ├────────────────┼────────┼────────┼───────┼──────┼──────┼────────────┤
  │  Button        │  10    │  15    │  10   │  10  │  10  │  92  EXCEL │
  │  Input         │  10    │  15    │  10   │  10  │  5   │  85  GOOD  │
  │  DataTable     │  5     │  10    │  0    │  0   │  0   │  35  POOR  │
  │  Modal         │  10    │  12    │  5    │  5   │  5   │  62  NEEDS │
  │  Card          │  10    │  15    │  10   │  10  │  10  │  88  GOOD  │
  │  Select        │  5     │  10    │  5    │  0   │  0   │  40  POOR  │
  │  ...           │  ...   │  ...   │  ...  │  ...  │  ... │  ...       │
  ├────────────────┼────────┼────────┼───────┼──────┼──────┼────────────┤
  │  LIBRARY AVG   │        │        │       │      │      │  <N>/100   │
  └────────────────┴────────┴────────┴───────┴──────┴──────┴────────────┘

  TARGET: Library average >= 85, no component below 70
  FIX PRIORITY: lowest-scoring components first

Phase 2 — Design Token Coverage Audit
  target: >= 95% of all visual values reference design tokens

  SCAN METHODOLOGY:
  1. EXTRACT all visual values from component styles:
     - Colors (hex, rgb, hsl, oklch)
     - Spacing (margin, padding, gap — px/rem values)
     - Typography (font-size, font-weight, line-height, font-family)
     - Borders (border-width, border-radius, border-color)
     - Shadows (box-shadow, text-shadow)
     - Z-index (any numeric z-index value)
     - Transitions (duration, easing)
  2. CLASSIFY each value:
     a. Token reference (var(--token-*), theme.spacing.*, etc.) → COMPLIANT
     b. Hardcoded value (#333, 16px, 1.5rem) → VIOLATION
     c. Functional value (100%, auto, inherit, 0) → EXEMPT
  3. CALCULATE coverage:
     coverage_pct = (compliant + exempt) / total_values * 100

  TOKEN COVERAGE BY CATEGORY:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Category      │  Total Values │  Tokenized │  Hardcoded │  Coverage │
  ├────────────────┼───────────────┼────────────┼────────────┼───────────┤
  │  Colors        │  <N>          │  <N>       │  <N>       │  <N>%     │
  │  Spacing       │  <N>          │  <N>       │  <N>       │  <N>%     │
  │  Typography    │  <N>          │  <N>       │  <N>       │  <N>%     │
  │  Borders       │  <N>          │  <N>       │  <N>       │  <N>%     │
  │  Shadows       │  <N>          │  <N>       │  <N>       │  <N>%     │
  │  Z-index       │  <N>          │  <N>       │  <N>       │  <N>%     │
  │  Transitions   │  <N>          │  <N>       │  <N>       │  <N>%     │
  ├────────────────┼───────────────┼────────────┼────────────┼───────────┤
  │  OVERALL       │  <N>          │  <N>       │  <N>       │  <N>%     │
  └────────────────┴───────────────┴────────────┴────────────┴───────────┘

  FOR EACH hardcoded value:
    1. IDENTIFY the file and line
    2. FIND the matching design token (or create one if missing)
    3. REPLACE hardcoded value with token reference
    4. VERIFY visual output unchanged

  TOKEN VIOLATION REMEDIATION:
  current_iteration = 0
  max_iterations = 8

  WHILE token_coverage < 95% AND current_iteration < max_iterations:
    1. SORT violations by frequency (most common hardcoded value first)
    2. BATCH fix: replace top 10 most-frequent hardcoded values with tokens
    3. RUN visual regression test (Storybook visual snapshots or Chromatic)
    4. IF regressions → revert, investigate, fix individually
    5. RECORD:
       file | property | hardcoded_value | token_reference | visual_regression
    6. RE-SCAN token coverage
    7. current_iteration += 1

Phase 3 — Component Completeness Audit
  Verify the library has all components needed by the application:

  COMPONENT COMPLETENESS MATRIX:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Category        │  Expected Components          │  Status          │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Primitives      │  Button, Input, Label, Badge  │  <N>/<N> present │
  │                  │  Avatar, Icon, Text, Divider  │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Form Controls   │  Select, Checkbox, Radio,     │  <N>/<N> present │
  │                  │  Switch, Slider, DatePicker   │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Feedback        │  Toast, Alert, Progress,      │  <N>/<N> present │
  │                  │  Spinner, Skeleton            │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Overlays        │  Modal, Drawer, Popover,      │  <N>/<N> present │
  │                  │  Tooltip, ContextMenu         │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Navigation      │  Tabs, Breadcrumb, Pagination │  <N>/<N> present │
  │                  │  Sidebar, Navbar, Menu        │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Data Display    │  Table, DataTable, Card,      │  <N>/<N> present │
  │                  │  List, Accordion, Tree        │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  Layout          │  Stack, Grid, Container,      │  <N>/<N> present │
  │                  │  AspectRatio, ScrollArea      │                  │
  ├──────────────────┼───────────────────────────────┼──────────────────┤
  │  TOTAL           │  <N> expected                 │  <N>/<N> (<N>%)  │
  └──────────────────┴───────────────────────────────┴──────────────────┘

  FOR EACH missing component:
    1. ASSESS: is this component actually used in the application?
       - Scan codebase for the pattern (e.g., inline modal implementation)
       - If found → component is needed, add to build queue
       - If not found → component is aspirational, deprioritize
    2. PRIORITIZE by usage frequency:
       - Used in 5+ places → HIGH priority (extract into shared component)
       - Used in 2-4 places → MEDIUM priority
       - Used in 1 place → LOW priority (may not need shared component)

FINAL COMPONENT LIBRARY REPORT:
┌──────────────────────────────────────────────────────────────────────┐
│  Metric                            │  Before   │  After    │ Target │
├────────────────────────────────────┼───────────┼───────────┼────────┤
│  Library avg consistency score     │  <N>/100  │  <N>/100  │ >= 85  │
│  Components below 70              │  <N>      │  0        │ 0      │
│  Design token coverage             │  <N>%     │  <N>%     │ >= 95% │
│  Hardcoded values remaining        │  <N>      │  <N>      │ < 10   │
│  Component completeness            │  <N>%     │  <N>%     │ >= 90% │
│  Storybook story coverage          │  <N>%     │  <N>%     │ 100%   │
│  Test coverage (component files)   │  <N>%     │  <N>%     │ >= 80% │
│  Accessibility violations (axe)    │  <N>      │  0        │ 0      │
└────────────────────────────────────┴───────────┴───────────┴────────┘
```

### Component Library Audit TSV Logging

Append one row per audit action to `.godmode/ui-audit.tsv`:

```
timestamp	project	phase	component	metric	before	after	technique	status
2024-01-15T10:30:00Z	my-app	consistency	DataTable	score	35	78	add-types+story+test	improved
2024-01-15T10:45:00Z	my-app	tokens	Card.module.css	coverage	72%	98%	replace-hardcoded	improved
2024-01-15T11:00:00Z	my-app	completeness	Toast	present	no	yes	created-component	added
```

### Component Library Audit Hard Rules

```
1. NEVER score a component above 70 if it has zero tests. Tests are not optional for shared components.
2. NEVER accept hardcoded colors or spacing in shared components. Every visual value must reference a design token.
3. ALWAYS run visual regression tests after batch-replacing hardcoded values with tokens.
4. NEVER add a component to the shared library without a Storybook story. Undocumented components are unused components.
5. ALWAYS audit token coverage after adding new components. New components are the most likely source of hardcoded values.
6. Log every audit finding in TSV format for tracking quality improvements across releases.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run UI tasks sequentially: primitive components, then composite components, then layout/tokens.
- Use branch isolation per task: `git checkout -b godmode-ui-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
