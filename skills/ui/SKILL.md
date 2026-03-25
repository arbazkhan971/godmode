---
name: ui
description: >
  UI component architecture. Design systems,
  Storybook, CSS architecture, design tokens,
  component patterns.
---

# UI -- UI Component Architecture

## Activate When
- `/godmode:ui`, "component architecture"
- "design system", "UI review", "Storybook setup"
- Building reusable components or shared UI packages

## Workflow

### Step 1: Analyze Current Architecture
```bash
# Detect framework and CSS approach
grep -r "react\|vue\|svelte\|@angular/core" \
  package.json 2>/dev/null
grep -r "tailwindcss\|styled-components\|@emotion\|sass" \
  package.json 2>/dev/null

# Count components
find src/ -name "*.tsx" -o -name "*.vue" \
  -o -name "*.svelte" 2>/dev/null | wc -l
```
```
UI AUDIT:
Framework: <React | Vue | Svelte | Angular>
Styling: <CSS Modules | Tailwind | CSS-in-JS>
Component library: <custom | MUI | shadcn | none>
Storybook: <yes (version) | no>
Design tokens: <yes | no>
Component count: <N>
```

### Step 2: Component Hierarchy
```
| Level     | Count | Examples              |
|----------|-------|----------------------|
| Atoms    | <N>   | Button, Input, Label  |
| Molecules| <N>   | FormField, SearchBar  |
| Organisms| <N>   | Header, DataTable     |
| Templates| <N>   | DashboardLayout       |
| Pages    | <N>   | HomePage, Settings    |
```

### Step 3: CSS Architecture Decision
```
IF existing design system with tokens:
  CSS Modules + CSS custom properties
IF rapid prototyping or small team:
  Tailwind CSS
IF complex theming (dark, multi-brand):
  CSS-in-JS (Emotion/styled-components)
IF SSR is critical:
  avoid runtime CSS-in-JS
IF legacy SCSS: keep, migrate incrementally
```
```
| Criterion   | CSS Modules | Tailwind | CSS-in-JS |
|------------|------------|---------|----------|
| Scoping    | Automatic  | Utility | Automatic|
| Bundle     | Small      | Small   | Variable |
| Runtime    | None       | None    | Yes      |
| Type safety| Plugin     | Plugin  | Native   |
```

### Step 4: Design Token Audit
```bash
# Find hardcoded colors
grep -rn "#[0-9a-fA-F]\{3,6\}" src/ \
  --include="*.css" --include="*.tsx" \
  --include="*.scss" 2>/dev/null | head -20

# Find hardcoded spacing
grep -rn "margin:\|padding:\|gap:" src/ \
  --include="*.css" --include="*.scss" \
  | grep -v "var(--" | head -20
```
```
| Token Category | Defined | Hardcoded | Violations |
|---------------|---------|-----------|-----------|
| Colors        | 24      | 7         | 7         |
| Typography    | 8       | 3         | 3         |
| Spacing       | 12      | 5         | 5         |
| Border radius | 4       | 1         | 1         |
| Shadows       | 3       | 2         | 2         |
```

### Step 5: Component Library Structure
```
src/components/Button/
  Button.tsx           Component
  Button.module.css    Styles
  Button.test.tsx      Tests
  Button.stories.tsx   Storybook
  Button.types.ts      TypeScript interfaces
  index.ts             Public exports
```

### Step 6: Storybook Setup
```bash
npx storybook@latest init
npm install --save-dev @storybook/addon-a11y \
  @storybook/addon-viewport @storybook/addon-docs
```

### Step 7: Pattern Consistency
```
NAMING RULES:
  Components: PascalCase (Button, DataTable)
  Files: PascalCase matching component
  Styles: ComponentName.module.css
  Tests: ComponentName.test.tsx
  Hooks: use<Purpose> (useMediaQuery)

API CONVENTIONS:
  variant for visual styles (not "type")
  size: "small" | "medium" | "large"
  children for content (not "text")
  on<Event> for handlers (onClick)
  Boolean props positive (isOpen, not isClosed)
  forwardRef on all native-wrapping components
```

### Step 8: Report
```
UI REPORT:
  Components: {N} total
  Well-structured: {N}, Needs work: {N}
  Token violations: {N} hardcoded values
  Stories coverage: {N}/{N} components
  Verdict: PASS | NEEDS REVISION
```

## Key Behaviors
1. **Components are the unit of UI.**
2. **Design tokens are mandatory.** No hardcoding.
3. **Every component needs stories.**
4. **Consistency over cleverness.**
5. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER mix CSS approaches in one project.
2. NEVER create God components (>30 props, >500 lines).
3. NEVER hardcode colors or spacing. Use tokens.
4. NEVER couple UI to business logic.
5. ALWAYS type every component prop.
6. ALWAYS write Storybook stories for every component.
7. ALWAYS design mobile-first.
8. NEVER use inline styles for component internals.

## Auto-Detection
```bash
grep -r "storybook" package.json 2>/dev/null
ls .storybook/ 2>/dev/null
find src/ -name "*.stories.*" 2>/dev/null | wc -l
```

## TSV Logging
Log to `.godmode/ui-results.tsv`:
`timestamp\tcomponent\taction\ttests\ta11y\tbundle_kb\tstatus`

## Output Format
```
UI: Components {N}. Stories: {N}. Tokens: {N}.
Violations: {N}. a11y: {N}. Status: {DONE|PARTIAL}.
```

## Keep/Discard Discipline
```
KEEP if: visual regression passes AND a11y clean
  AND responsive at all breakpoints
DISCARD if: visual regression OR a11y violation
  OR layout breaks. Revert on discard.
```

## Stop Conditions
```
STOP when:
  - All components render in Storybook
  - Design token coverage >= 95%
  - Zero a11y violations (axe-core)
  - User requests stop
```
