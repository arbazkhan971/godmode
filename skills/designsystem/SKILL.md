---
name: designsystem
description: |
  Design system architecture skill. Activates when user needs to build, maintain, or audit a design system including token architecture (colors, spacing, typography, shadows), component API standards, theme systems (light/dark, custom), design-to-code pipelines (Figma tokens to CSS variables), versioning and distribution, and Storybook documentation. Triggers on: /godmode:designsystem, "design system", "design tokens", "theme architecture", "Figma to code", or when building a shared component library.
---

# Design System — Design System Architecture

## When to Activate
- User invokes `/godmode:designsystem`
- User says "design system," "design tokens," "theme architecture," "Figma to code"
- Creating a shared component library or establishing token architecture
- Building theme support (light/dark, multi-brand) or Figma-to-code pipeline
- Versioning/distributing a design system package or auditing for consistency

## Workflow

### Step 1: Assess Current State
```
DESIGN SYSTEM ASSESSMENT:
Project: <name>  Framework: <React/Vue/Angular/Svelte/Web Components>
Existing system: <none/partial/mature>
Token coverage: Colors/Spacing/Typography/Shadows/Borders/Motion — <defined/partial/none> each
Theme support: <none/light-dark/multi-brand>
Component count: <N>  Storybook: <yes/no>  Figma integration: <yes/no>
Maturity: NONE | STARTER | GROWING | MATURE
```

### Step 2: Token Architecture
Three-tier architecture is mandatory:

```
TIER 1: PRIMITIVES (raw values)      --primitive-blue-500: #3b82f6;
TIER 2: SEMANTIC (meaning)           --color-primary: var(--primitive-blue-500);
TIER 3: COMPONENT (specific)         --button-bg: var(--color-primary);
```

**Colors:** Neutral scale (50-950), brand scale, feedback (red/green/amber). Semantic: bg, surface, text-primary/secondary/tertiary, primary/hover/active, error/success/warning, border/border-strong/border-focus.

**Spacing:** 4px base unit scale: 0, px, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24 (in rem).

**Typography:** Font families (sans, mono), sizes (xs-5xl modular 1.25 scale), weights (400-700), line heights (tight/normal/relaxed).

**Shadows:** xs through 2xl + inner + focus ring.

### Step 3: Component API Standards
```
STANDARDS:
- variant: "primary"|"secondary"|"ghost"|"danger"  size: "sm"|"md"|"lg"
- Extend native HTML element props. Export all prop types.
- forwardRef on every component wrapping native elements. Set displayName.
- Compound components: <Card><Card.Header/><Card.Body/></Card>
- Defaults: variant="primary", size="md"
- on<Event> convention. Support controlled and uncontrolled modes.
- className always accepted as escape hatch.
```

### Step 4: Theme System
Light/dark via CSS custom properties on `[data-theme]`. ThemeProvider with system preference detection, localStorage persistence, flash-free SSR. Multi-brand via `[data-brand]` overriding primitive tokens.

### Step 5: Design-to-Code Pipeline
Figma Variables/Tokens Studio -> tokens.json (W3C format) -> Style Dictionary -> outputs (CSS variables, TypeScript constants, Tailwind config). CI automation: Figma webhook -> generate -> PR -> visual regression test.

### Step 6: Versioning & Distribution
Semantic versioning: MAJOR (remove token/component, rename, change defaults), MINOR (add component/token/variant), PATCH (fix values/bugs). Package structure: dist/css/, dist/js/, dist/tokens/. Release: version bump -> build -> changelog -> publish -> deploy Storybook.

### Step 7: Storybook Documentation
Initialize with essential addons (a11y, viewport, docs, designs). Structure: Introduction > Foundations (Colors, Typography, Spacing, Shadows) > Components (Atoms, Molecules, Organisms) > Patterns > Theming.

### Step 8: Audit Report
```
DESIGN SYSTEM AUDIT:
  Token Coverage: Colors/Spacing/Typography/Shadows — <N>/<N> used, <N> hardcoded
  Component API Compliance: <N>/<N> standards-compliant
  Theme System: Light/Dark/System preference/Persistence/Flash-free
  Pipeline: Figma sync automated/manual/none
  Documentation: Storybook coverage <X>%
  Score: <N>/100  Maturity: NONE | STARTER | GROWING | MATURE
```

### Step 9: Remediation Plan
Priority 1 (Critical): blocks adoption. Priority 2 (High): degrades consistency. Priority 3 (Medium): improves DX. Priority 4 (Low): polish.

### Step 10: Commit
```
Commit per area: "designsystem: <tokens|theme|pipeline|storybook> — <description>"
Transition: Run /godmode:ui for component audit, /godmode:a11y for accessibility
```

## Key Behaviors
1. **Tokens are the single source of truth.** Every visual decision is a token.
2. **Three-tier architecture is mandatory.** Primitives -> Semantic -> Component.
3. **Keep component APIs predictable.** Same prop naming, composition, typing everywhere.
4. **Theming is infrastructure.** Dark mode requires complete semantic token layer.
5. **Automate the pipeline.** Manual sync guarantees drift.
6. **Version like a product.** Semver, changelogs, migration guides.
7. **Storybook is the documentation.** If not in Storybook, it does not exist.

## Flags & Options

| Flag | Description |
|--|--|
| `--audit` | Audit existing design system maturity |
| `--tokens` | Token architecture only |
| `--theme` | Theme system setup |
| `--pipeline` | Figma-to-code pipeline setup |
| `--storybook` | Storybook documentation setup |
| `--init` | Initialize complete design system from scratch |

## HARD RULES
- NEVER use raw hex/rgb in component code — always reference semantic tokens
- NEVER skip the semantic token layer
- NEVER create a component without a Storybook story
- NEVER publish without a CHANGELOG entry
- NEVER modify token values affecting layout without MAJOR version bump
- ALL components MUST forward refs and accept className

## Auto-Detection
```
1. Scan for tailwind.config, CSS :root/[data-theme], tokens.json, style-dictionary config, .storybook/
2. Detect component library: shadcn/ui, radix, chakra, mantine, MUI
3. Check for Figma integration: .figma*, figma-tokens.json
4. Determine maturity: NONE (>10 hardcoded) | STARTER (<50% coverage) | GROWING | MATURE
```

## Multi-Agent Dispatch
```
Agent 1 (tokens): Build/audit token architecture — primitives, semantics, themes
Agent 2 (components): Audit component API compliance — ref forwarding, prop naming
Agent 3 (pipeline): Configure Figma-to-code pipeline — Style Dictionary, CI
Agent 4 (docs): Set up Storybook — foundation stories, component stories
MERGE: All -> visual regression test -> unified report
```

## TSV Logging
Log to `.godmode/designsystem-results.tsv`: `timestamp\tskill\ttarget\taction\ttokens_count\tcomponents_count\tcoverage_pct\tstatus`

## Success Criteria
1. All tokens in single source (Style Dictionary/Figma Tokens)
2. Semantic layer between primitives and components
3. Every component references only semantic tokens
4. Light + dark themes work by swapping tokens only
5. Every component has Storybook story with all variants
6. Token pipeline generates CSS custom properties
7. Token coverage >= 90%

## Error Recovery
- **Tokens out of sync with Figma:** Re-export, rebuild, diff, update only if changed.
- **Theme switching breaks:** Check semantic token usage, verify data-theme attribute, inspect computed styles.
- **Storybook fails:** Check imports, addon compatibility, clear cache.
- **Visual regression false positives:** Font rendering diffs, update baselines, use threshold tolerance.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-designsystem-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `DesignSystem: {tokens} tokens, {components} components. Theme: {light_dark|single}. Storybook: {passing|failing}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH design system change:
  KEEP if: all components use semantic tokens AND Storybook builds AND visual regression passes
  DISCARD if: primitive token used directly OR Storybook breaks OR visual regression detected
  On discard: revert. Fix token mapping before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - All components reference semantic tokens only
  - Storybook builds and deploys successfully
  - Theme switching works (light/dark) without layout breaks
  - Visual regression baseline established
```
