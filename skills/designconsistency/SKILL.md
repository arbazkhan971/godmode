---
name: designconsistency
description: |
  Design consistency enforcement skill. Activates when generating UI/UX code or reviewing frontend implementations. Ensures visual, behavioral, and structural consistency across all generated components. Solves the #1 problem with AI-generated UI: inconsistency in spacing, colors, typography, component patterns, and interaction behaviors across different generation sessions.
---

# Design Consistency — Enforce Visual & Behavioral Coherence

## When to Activate
- User invokes `/godmode:designconsistency`
- Any UI/frontend generation is happening (auto-activate as guardrail)
- User says "make it consistent," "fix the design," "it looks different"
- After `/godmode:ui`, `/godmode:wireframe`, or `/godmode:uxdesign` generates code
- Godmode orchestrator detects frontend work

## The Problem This Solves

AI-generated UI suffers from **session drift** — each generation session picks slightly different:
- Spacing values (12px vs 16px vs 1rem vs 0.75rem)
- Color shades (blue-500 vs blue-600, #3B82F6 vs #2563EB)
- Border radius (rounded-md vs rounded-lg)
- Font sizes and weights
- Component structure patterns
- Animation timing and easing
- Shadow depths and spreads
- Interaction patterns (hover, focus, active states)

This skill establishes a **design contract** and enforces it mechanically.

## Workflow

### Step 1: Extract the Design Contract

Before generating ANY UI code, build the design contract from the project:

```
1. Check for existing design system:
   - tailwind.config.js / tailwind.config.ts → extract theme
   - CSS variables in :root or theme files
   - Design tokens file (tokens.json, tokens.css, tokens.ts)
   - Component library (shadcn/ui, radix, chakra, etc.)
   - Storybook config

2. Check for existing components:
   - Scan src/components/ for patterns
   - Extract spacing, colors, typography from existing code
   - Map interaction patterns (hover effects, transitions, focus rings)

3. Check for Figma/design specs:
   - docs/design/ or docs/specs/ for design specs
   - Design tokens exported from Figma
```

If a design contract already exists, use it. If not, create one from what exists in the codebase.

### Step 2: Build the Design Contract File

Save as `docs/design/design-contract.md`:

```markdown
# Design Contract

## Spacing Scale
Use ONLY these values. No arbitrary numbers.
- xs: 4px (0.25rem)
- sm: 8px (0.5rem)
- md: 16px (1rem)
- lg: 24px (1.5rem)
- xl: 32px (2rem)
- 2xl: 48px (3rem)

## Color Palette
Primary: <exact hex/tailwind class>
Secondary: <exact hex/tailwind class>
Accent: <exact hex/tailwind class>
Background: <exact values>
Surface: <exact values>
Text primary: <exact value>
Text secondary: <exact value>
Text muted: <exact value>
Border: <exact value>
Error: <exact value>
Success: <exact value>
Warning: <exact value>

## Typography Scale
Heading 1: <size, weight, line-height, letter-spacing>
Heading 2: <size, weight, line-height>
Heading 3: <size, weight, line-height>
Body: <size, weight, line-height>
Small: <size, weight, line-height>
Caption: <size, weight, line-height>

## Border Radius
- none: 0
- sm: <value>
- default: <value>
- lg: <value>
- full: 9999px

## Shadows
- sm: <exact shadow>
- default: <exact shadow>
- lg: <exact shadow>

## Transitions
- Duration: <value>ms (default for ALL transitions)
- Easing: <value> (default for ALL transitions)
- Hover scale: <value> (if used)

## Component Patterns
- Card: <exact pattern — padding, border, radius, shadow>
- Button: <exact pattern — padding, font, radius, states>
- Input: <exact pattern — height, padding, border, focus>
- Badge: <exact pattern>
- Modal: <exact pattern — overlay, padding, radius, animation>
```

### Step 3: Pre-Generation Consistency Check

Before generating ANY UI component, run this checklist:

```
CONSISTENCY PRE-CHECK:
□ Design contract loaded from docs/design/design-contract.md
□ Existing component patterns scanned
□ Color values will use ONLY contract colors (no arbitrary hex)
□ Spacing values will use ONLY contract spacing (no arbitrary px/rem)
□ Typography will use ONLY contract type scale
□ Border radius will use ONLY contract values
□ Shadows will use ONLY contract values
□ Transitions will use contract duration and easing
□ Component structure follows existing patterns
```

### Step 4: Post-Generation Consistency Audit

After generating UI code, verify consistency mechanically:

```bash
# Check for arbitrary color values (should use design tokens)
grep -rn '#[0-9a-fA-F]\{3,8\}' <generated-files>
# Expected: 0 results (all colors should be via tokens/classes)

# Check for arbitrary spacing
grep -rn '[0-9]\+px' <generated-files>
grep -rn '[0-9]\+rem' <generated-files>
# Expected: only values from the spacing scale

# Check for inconsistent border radius
grep -rn 'rounded-' <generated-files>
# Expected: consistent usage of the same radius tier

# Check for inconsistent font sizes
grep -rn 'text-' <generated-files>
# Expected: only values from typography scale
```

### Step 5: Cross-Component Consistency Verification

Compare the generated component against ALL existing components:

```
CROSS-COMPONENT CHECK:
1. Cards — Do all cards use the same padding, border, shadow, radius?
2. Buttons — Do all buttons use the same height, padding, font, states?
3. Inputs — Do all inputs use the same height, border, focus ring?
4. Spacing — Is the same spacing used between similar elements?
5. Color usage — Are semantic colors used consistently (primary for actions, error for destructive)?
6. Hover states — Do all interactive elements use the same hover pattern?
7. Focus states — Do all focusable elements use the same focus ring?
8. Loading states — Do all loading states use the same spinner/skeleton pattern?
9. Empty states — Do all empty states follow the same layout?
10. Error states — Do all error displays use the same pattern?
```

### Step 6: Fix Inconsistencies

For each inconsistency found:
1. Identify which value is the "source of truth" (from design contract)
2. Replace the inconsistent value with the correct one
3. Verify visually or with a snapshot test
4. Commit: `"style: fix <component> — align with design contract"`

## Key Behaviors

1. **Design contract is law.** Never introduce values that aren't in the contract. If a new value is needed, update the contract FIRST, then use it everywhere.
2. **Extract before inventing.** Always check existing components before generating new ones. Match their patterns exactly.
3. **Mechanical verification.** Use grep/search to prove consistency, not visual inspection alone.
4. **Semantic tokens over raw values.** Always use `text-primary` over `#1a1a1a`, `space-4` over `16px`, `rounded-default` over `rounded-md`.
5. **One source of truth.** Colors, spacing, typography — each has exactly one definition. Everything else references it.
6. **Cross-session consistency.** The design contract file persists across sessions. Every new generation reads it first.
7. **Component patterns are reusable.** If you build a card pattern, every card uses it. No snowflakes.

## Consistency Rules for AI-Generated UI

These rules MUST be followed during any UI generation:

### Rule 1: No Magic Numbers
```
BAD:  padding: 13px;  margin-top: 22px;  gap: 18px;
GOOD: padding: 1rem;  margin-top: 1.5rem; gap: 1rem;
```

### Rule 2: No Arbitrary Colors
```
BAD:  color: #4a5568;  background: #edf2f7;
GOOD: color: text-secondary;  background: bg-surface;
```

### Rule 3: Component Structure Consistency
```
BAD:  Card A has p-4, Card B has p-6, Card C has px-4 py-6
GOOD: All cards use the <Card> component with the same base styles
```

### Rule 4: State Consistency
```
BAD:  Button hover is blue-600, Link hover is blue-700, Card hover has shadow
GOOD: All interactive hover states use the same color shift pattern
```

### Rule 5: Responsive Consistency
```
BAD:  Component A breaks at 640px, Component B at 768px, Component C at 600px
GOOD: All components use the same breakpoint scale: sm(640), md(768), lg(1024)
```

## Example Usage

### Before building a dashboard
```
User: /godmode:designconsistency

Design Consistency: Scanning project...

DESIGN CONTRACT STATUS:
✓ tailwind.config.ts found — extracting theme
✓ 14 existing components in src/components/
✓ shadcn/ui detected — using as base
✗ No design-contract.md found — generating from existing code

Extracted design contract:
- Colors: slate/blue palette (10 semantic tokens)
- Spacing: 4px base scale (6 values)
- Typography: Inter font, 6-step type scale
- Radius: rounded-lg (default), rounded-xl (cards)
- Shadows: shadow-sm (default), shadow-lg (elevated)

Saved to docs/design/design-contract.md

All future UI generation will enforce this contract.
```

### Auditing an existing page
```
User: /godmode:designconsistency --audit src/pages/Dashboard.tsx

CONSISTENCY AUDIT:
✗ Line 24: arbitrary color #6B7280 — should be text-muted
✗ Line 31: padding: 20px — not in spacing scale, should be p-5 (1.25rem)
✗ Line 45: rounded-md — rest of project uses rounded-lg
✓ Line 52: shadow-sm — matches contract
✗ Line 67: transition-all duration-200 — contract says 150ms

4 inconsistencies found. Run `/godmode:designconsistency --fix` to auto-correct.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Extract/create design contract, enforce on next generation |
| `--audit <path>` | Audit a file or directory for consistency |
| `--fix` | Auto-fix all inconsistencies to match the design contract |
| `--extract` | Extract design contract from existing codebase only |
| `--strict` | Fail the build if any inconsistency found (CI mode) |

## HARD RULES

- NEVER introduce a color, spacing, font size, border radius, or shadow value not in the design contract
- NEVER use raw hex/rgb values in component code — always use semantic tokens or design system classes
- NEVER generate UI without first reading `docs/design/design-contract.md` (or extracting one if it does not exist)
- NEVER approve a component that uses different spacing/radius/shadow from existing sibling components
- NEVER update the design contract without updating ALL existing components that reference the changed value
- ALL consistency audits MUST use mechanical grep/search verification, not visual inspection alone
- ALL new design contract values MUST be justified with a comment explaining why the existing scale was insufficient

## Iterative Audit Loop Protocol

When auditing or enforcing consistency across a codebase:

```
current_iteration = 0
violation_queue = [all_ui_files_and_components]
WHILE violation_queue is not empty:
    current_iteration += 1
    batch = violation_queue.pop(next 10 files)
    FOR each file in batch:
        grep for arbitrary hex colors, px/rem values, inconsistent classes
        compare against design contract values
        replace violations with contract-approved tokens
        log: file, line, violation type, old value, new value
    run build + visual snapshot check
    IF new violations discovered in dependencies or shared components:
        add to violation_queue
    report: "Iteration {current_iteration}: {N} files audited, {M} violations fixed, {remaining} files remaining"
```

## Multi-Agent Dispatch

```
DISPATCH 3 agents in separate worktrees:
  Agent 1 (extract):   Scan tailwind config, CSS variables, existing components → build/update design-contract.md
  Agent 2 (audit):     Run mechanical grep audit on all UI files → generate violation report with file:line:value
  Agent 3 (fix):       Apply contract-compliant replacements for all violations found by Agent 2
SYNC point: All agents complete
  Merge worktrees
  Run visual regression / snapshot comparison
  Generate before/after consistency report
```

## Auto-Detection

```
1. Check for existing design contract:
   - Scan for docs/design/design-contract.md → load if exists
   - Scan for tailwind.config.{js,ts} → extract theme tokens (colors, spacing, radius, shadows)
   - Scan for CSS files with :root or [data-theme] → extract CSS custom properties
   - Scan for tokens.json, tokens.css, design-tokens.* → detect token format
   - Check for .storybook/ → detect component documentation
2. Check for component library:
   - Detect shadcn/ui, radix, chakra, mantine, ant-design, MUI in package.json
   - Count components in src/components/ or packages/ui/
   - Scan for consistent patterns (shared padding, radius, shadow usage)
3. Determine current consistency level:
   - Count unique hex values, spacing values, radius values across all UI files
   - Compare against contract (if exists) to calculate violation percentage
4. Set workflow: If no contract exists, start at Step 1 (extract). If contract exists, start at Step 3 (pre-check).
```

## Anti-Patterns

- **Do NOT skip the design contract.** Every UI generation must read it first. "This is a quick component" is how drift starts.
- **Do NOT use hardcoded values.** Even if the design contract says "16px," use the token name, not the raw value.
- **Do NOT create component variants when a prop would do.** One Button component with variants, not three different button components.
- **Do NOT audit by eye.** Use grep/search to mechanically verify consistency. Visual inspection misses subtle differences.
- **Do NOT update the contract without updating existing components.** If you change the primary color in the contract, update it everywhere.
