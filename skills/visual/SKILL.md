---
name: visual
description: |
  Visual regression testing skill. Activates when user needs to detect unintended visual changes, validate component rendering across browsers, or verify design compliance. Uses component snapshot testing, pixel-level diffs, cross-browser comparison, and design token validation. Triggers on: /godmode:visual, "visual regression", "check visual changes", "compare screenshots", or as pre-ship UI quality gate.
---

# Visual — Visual Regression Testing

## When to Activate
- User invokes `/godmode:visual`
- User says "check for visual regressions," "compare screenshots," "visual diff"
- After CSS/styling changes, component refactors, or dependency upgrades
- Pre-ship quality gate during `/godmode:ship` for UI-heavy projects
- After design system or theme changes
- When upgrading frameworks or UI libraries

## Workflow

### Step 1: Assess Visual Testing Infrastructure
Determine what visual testing tools and baselines exist:

```
VISUAL TESTING STATE:
Framework: <React/Vue/Angular/Svelte/vanilla>
Styling: <CSS Modules/Tailwind/CSS-in-JS/SCSS>
Component library: <Storybook/Ladle/Histoire/none>
Existing visual tests: <yes/no — count>
Baseline snapshots: <yes/no — location>
CI integration: <yes/no>

Tools detected:
  - Snapshot testing: <jest-image-snapshot/playwright/cypress/backstop/none>
  - Storybook: <version or none>
  - Design tokens: <style-dictionary/figma-tokens/none>
```

If no visual testing infrastructure exists:
```
No visual testing infrastructure detected.
Recommended setup based on your stack:

<framework> + <styling> → <recommended tool chain>

Run `/godmode:setup --visual` to configure, or proceed with manual comparison.
```

### Step 2: Identify Components Under Test
Determine which components need visual regression testing:

```
VISUAL TEST SCOPE:
Mode: <full | changed-only | component>

Components to test:
┌───────────────────────────────────────────────────────────────┐
│ Component         │ Variants │ States    │ Breakpoints │ Risk │
├───────────────────────────────────────────────────────────────┤
│ Button            │ 4        │ 5         │ 3           │ LOW  │
│ DataTable         │ 2        │ 3         │ 3           │ HIGH │
│ NavigationBar     │ 1        │ 2         │ 3           │ MED  │
│ Modal             │ 3        │ 4         │ 2           │ HIGH │
│ Form/InputGroup   │ 6        │ 4         │ 3           │ MED  │
└───────────────────────────────────────────────────────────────┘

Total screenshots needed: <N>
Estimated time: <N> seconds
```

Risk factors that increase visual regression likelihood:
- Recently modified CSS/styling files
- Shared/global styles that affect multiple components
- Components with complex responsive layouts
- Components using CSS animations or transitions
- Components rendering user-generated content

### Step 3: Capture Baseline Screenshots
Generate reference screenshots for comparison:

#### Using Playwright
```bash
# Install Playwright browsers
npx playwright install chromium firefox webkit

# Capture baseline screenshots
npx playwright test --update-snapshots
```

```typescript
// visual-tests/components.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Visual Regression', () => {
  test('Button — all variants', async ({ page }) => {
    await page.goto('/storybook/iframe.html?id=button--all-variants');
    await expect(page).toHaveScreenshot('button-variants.png', {
      maxDiffPixelRatio: 0.01,
    });
  });

  test('DataTable — with data', async ({ page }) => {
    await page.goto('/storybook/iframe.html?id=datatable--with-data');
    await expect(page).toHaveScreenshot('datatable-data.png', {
      maxDiffPixelRatio: 0.01,
    });
  });
});
```

#### Using Storybook + Chromatic
```bash
# Run Chromatic visual tests
npx chromatic --project-token=$CHROMATIC_TOKEN

# With specific stories
npx chromatic --only-story-names "Button/*,DataTable/*"
```

#### Using BackstopJS
```bash
# Initialize BackstopJS
npx backstop init

# Capture reference screenshots
npx backstop reference

# Run visual comparison
npx backstop test
```

```
BASELINE CAPTURE:
Screenshots captured: <N>
Storage location: <path>
Browsers: <list>
Viewports: <list of widths>
Timestamp: <ISO timestamp>
```

### Step 4: Run Visual Comparison
Compare current state against baselines:

```bash
# Playwright visual comparison
npx playwright test --reporter=html

# BackstopJS comparison
npx backstop test --filter="<component>"

# Percy snapshot
npx percy exec -- <test command>
```

```
VISUAL DIFF RESULTS:
┌───────────────────────────────────────────────────────────────────────┐
│ Component         │ Status   │ Diff %  │ Changed Pixels │ Verdict    │
├───────────────────────────────────────────────────────────────────────┤
│ Button/primary    │ CHANGED  │ 2.3%    │ 847            │ REVIEW     │
│ Button/secondary  │ MATCH    │ 0.0%    │ 0              │ PASS       │
│ DataTable/default │ CHANGED  │ 0.1%    │ 12             │ PASS       │
│ Modal/large       │ NEW      │ —       │ —              │ BASELINE   │
│ NavBar/mobile     │ CHANGED  │ 15.7%   │ 4,291          │ FAIL       │
│ Form/error-state  │ MATCH    │ 0.0%    │ 0              │ PASS       │
└───────────────────────────────────────────────────────────────────────┘

Summary:
  PASS: <N> components unchanged or within threshold
  REVIEW: <N> components with minor changes (needs human review)
  FAIL: <N> components with significant unexpected changes
  NEW: <N> components without baselines (new screenshots saved)
```

Threshold configuration:
```
THRESHOLDS:
  maxDiffPixelRatio: 0.01   (1% of pixels — above this = REVIEW)
  maxDiffPixelRatio: 0.05   (5% of pixels — above this = FAIL)
  allowSizeMismatch: false  (dimension changes always fail)
  antialiasing: true        (ignore anti-aliasing differences)
```

### Step 5: Cross-Browser Visual Comparison
Test rendering consistency across browsers:

```bash
# Playwright multi-browser
npx playwright test --project=chromium --project=firefox --project=webkit

# Capture per-browser
for browser in chromium firefox webkit; do
  npx playwright test --project=$browser --update-snapshots
done
```

```
CROSS-BROWSER COMPARISON:
┌────────────────────────────────────────────────────────────────┐
│ Component         │ Chromium │ Firefox  │ WebKit   │ Consistent│
├────────────────────────────────────────────────────────────────┤
│ Button/primary    │ OK       │ OK       │ OK       │ YES       │
│ DataTable/default │ OK       │ 0.3% off │ OK       │ YES       │
│ Modal/large       │ OK       │ OK       │ 2.1% off │ NO        │
│ NavBar/mobile     │ OK       │ OK       │ OK       │ YES       │
│ Form/select       │ OK       │ DIFFERS  │ DIFFERS  │ NO        │
└────────────────────────────────────────────────────────────────┘

Browser-specific issues:
  Firefox: <N> rendering differences
  WebKit: <N> rendering differences
  Expected (native elements): <N>
  Unexpected (custom styles): <N>
```

Known cross-browser rendering differences to ignore:
- Native form elements (select, date inputs)
- Scrollbar styling
- Font rendering/anti-aliasing
- Focus ring styles

### Step 6: Responsive Breakpoint Testing
Verify component rendering at all breakpoints:

```
RESPONSIVE BREAKPOINTS:
┌──────────────────────────────────────────────────┐
│ Breakpoint  │ Width  │ Components Tested │ Issues │
├──────────────────────────────────────────────────┤
│ Mobile      │ 320px  │ <N>               │ <N>    │
│ Mobile L    │ 375px  │ <N>               │ <N>    │
│ Tablet      │ 768px  │ <N>               │ <N>    │
│ Desktop     │ 1024px │ <N>               │ <N>    │
│ Desktop L   │ 1440px │ <N>               │ <N>    │
│ Ultrawide   │ 1920px │ <N>               │ <N>    │
└──────────────────────────────────────────────────┘
```

Common responsive issues to check:
```
- [ ] Text overflow/truncation at narrow widths
- [ ] Image aspect ratios maintained
- [ ] Touch targets remain >= 44x44px on mobile
- [ ] Navigation collapses correctly to hamburger
- [ ] Tables scroll horizontally or stack vertically
- [ ] Modals fit within viewport at all sizes
- [ ] Font sizes remain readable (>= 16px on mobile)
- [ ] No horizontal scroll on any breakpoint
```

### Step 7: Design Compliance Validation
Compare implementation against design specifications:

```
DESIGN COMPLIANCE:
Design source: <Figma/Sketch/Adobe XD/design tokens>

Token Validation:
┌────────────────────────────────────────────────────────────┐
│ Token Category  │ Defined │ Used │ Mismatches │ Status    │
├────────────────────────────────────────────────────────────┤
│ Colors          │ 24      │ 22   │ 1          │ REVIEW    │
│ Typography      │ 8       │ 8    │ 0          │ PASS      │
│ Spacing         │ 12      │ 10   │ 2          │ REVIEW    │
│ Border radius   │ 4       │ 4    │ 0          │ PASS      │
│ Shadows         │ 3       │ 3    │ 0          │ PASS      │
│ Breakpoints     │ 5       │ 5    │ 0          │ PASS      │
└────────────────────────────────────────────────────────────┘

Mismatches:
1. Color: Button hover uses #0056b3, design specifies #0052a3
   File: src/components/Button.module.css:23
2. Spacing: Card padding uses 16px, design specifies 20px
   File: src/components/Card.module.css:8
```

### Step 8: Findings Report

For each visual regression found:
```
### FINDING <N>: <Title>
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**Type:** Regression | Cross-browser | Responsive | Design mismatch
**Component:** <component name>
**Location:** <file:line>
**Browser(s):** <affected browsers>
**Viewport(s):** <affected breakpoints>

**Baseline:**
<screenshot or description of expected appearance>

**Current:**
<screenshot or description of actual appearance>

**Diff:**
<highlighted differences>

**Root Cause:**
<CSS change, dependency update, or unintended side effect>

**Remediation:**
```css
/* Fix the visual regression */
<corrected CSS>
```

**Verification:**
<Re-run visual test to confirm match>
```

### Step 9: Visual Regression Report

```
+------------------------------------------------------------+
|  VISUAL REGRESSION REPORT — <target>                        |
+------------------------------------------------------------+
|  Components tested: <N>                                     |
|  Screenshots captured: <N>                                  |
|  Browsers: <list>                                           |
|  Breakpoints: <list>                                        |
|                                                             |
|  Results:                                                   |
|  PASS (unchanged):        <N>                               |
|  PASS (within threshold): <N>                               |
|  REVIEW (minor changes):  <N>                               |
|  FAIL (regressions):      <N>                               |
|  NEW (no baseline):       <N>                               |
|                                                             |
|  Cross-browser issues:    <N>                               |
|  Responsive issues:       <N>                               |
|  Design mismatches:       <N>                               |
|                                                             |
|  Verdict: <PASS | REVIEW NEEDED | FAIL>                     |
+------------------------------------------------------------+
|  MUST FIX:                                                  |
|  1. <CRITICAL/HIGH regression>                              |
|                                                             |
|  REVIEW:                                                    |
|  2. <Intentional change — update baseline?>                 |
|  3. <Minor diff — acceptable?>                              |
+------------------------------------------------------------+
```

Verdicts:
- **PASS**: No regressions. All components match baselines within threshold.
- **REVIEW NEEDED**: Minor changes detected. Human must confirm if intentional.
- **FAIL**: Significant unexpected regressions found. Must be fixed.

### Step 10: Update Baselines and Commit
1. If changes are intentional, update baselines:
   ```bash
   npx playwright test --update-snapshots
   ```
2. Commit updated baselines: `"visual: update baselines — <N> components updated"`
3. If regressions fixed, commit: `"fix: visual regression — <component> <description>"`
4. Save report: `docs/visual/<target>-visual-report.md`
5. Commit report: `"visual: <target> — <verdict> (<N> components, <N> browsers)"`

## Key Behaviors

1. **Baselines are the source of truth.** Every component must have a baseline screenshot. No baseline = no regression detection. Capture baselines before making changes.
2. **Threshold tuning matters.** Too strict (0%) = noisy false positives from anti-aliasing and sub-pixel rendering. Too loose (5%) = missed regressions. Start at 1% and adjust.
3. **Test all states, not just default.** A button has default, hover, active, focus, disabled, and loading states. Test all of them. Regressions often hide in non-default states.
4. **Cross-browser differences are not always bugs.** Native form elements render differently by design. Document known acceptable differences. Only flag unexpected inconsistencies.
5. **Responsive testing catches layout breaks.** A component that looks perfect at 1440px may overflow at 320px. Test at every breakpoint defined in the design system.
6. **Design tokens prevent drift.** If the design says `--color-primary: #0052a3`, the code must use that token, not a hardcoded `#0056b3`. Token validation catches drift before it becomes visible.
7. **Screenshot tests are fragile by nature.** Environment differences (OS, GPU, font rendering) cause false positives. Use Docker or CI with consistent environments for reliable baselines.

## Example Usage

### Full visual regression check
```
User: /godmode:visual

Visual: Detecting visual testing setup...

VISUAL TESTING STATE:
Framework: React 18
Styling: Tailwind CSS + CSS Modules
Component library: Storybook 7.6
Baseline snapshots: 48 screenshots in tests/__snapshots__
Browsers: Chromium, Firefox, WebKit

Capturing current screenshots...
Running visual comparison against baselines...

VISUAL DIFF RESULTS:
PASS: 44 components unchanged
REVIEW: 2 components with minor changes
FAIL: 1 component with significant regression
NEW: 1 component without baseline

FINDING 1: NavBar — layout break at mobile
Severity: HIGH
Type: Responsive regression
Location: src/components/NavBar.module.css:34
Cause: New padding override conflicts with flex layout
...

Verdict: FAIL — 1 HIGH regression requires fix.
```

### After CSS refactor
```
User: /godmode:visual --changed-only

Visual: Detecting changed files...
Changed CSS files: 3
Affected components: 7

Running visual comparison for 7 affected components...
All 7 components match baselines. No regressions detected.

Verdict: PASS
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full visual regression test across all components |
| `--changed-only` | Test only components affected by recent changes |
| `--component <name>` | Test a specific component |
| `--browser <name>` | Test in a specific browser only |
| `--breakpoint <width>` | Test at a specific viewport width only |
| `--update-baselines` | Accept current state as new baselines |
| `--design-check` | Run only design compliance validation |
| `--threshold <N>` | Override diff threshold (default: 0.01) |
| `--ci` | Output in CI-friendly format (exit code 1 on failure) |

## HARD RULES

1. **NEVER set diff threshold to 0%.** Sub-pixel rendering and anti-aliasing cause tiny differences across environments. A 0% threshold guarantees false positives.
2. **NEVER store screenshots in git without LFS.** Screenshot files are large binaries. Use Git LFS or an external storage bucket.
3. **NEVER run visual tests on developer machines for CI baselines.** OS-level font rendering differences between macOS and Linux cause every test to fail. Use consistent CI environments.
4. **ALWAYS test every visual state** (default, hover, focus, error, loading, empty, disabled). Not just the happy path.
5. **ALWAYS update baselines immediately after intentional changes.** Stale baselines produce false failures on every subsequent run.
6. **ALWAYS test at multiple breakpoints** (mobile 375px, tablet 768px, desktop 1280px minimum).
7. **NEVER test third-party components you don't control.** Browser chrome and native form elements change with browser updates.
8. **ALWAYS use a consistent CI environment** (same OS, browser version, viewport) for generating and comparing baselines.

## Auto-Detection

On activation, detect the visual testing context:

```bash
# Detect visual testing tools
grep -r "chromatic\|percy\|backstop\|playwright.*screenshot\|reg-suit\|loki" package.json 2>/dev/null

# Detect Storybook (primary source of component states)
ls .storybook/ 2>/dev/null
grep -r "storybook" package.json 2>/dev/null

# Detect component framework
grep -r "react\|vue\|svelte\|@angular" package.json 2>/dev/null

# Detect existing baseline screenshots
find . -name "*.png" -path "*__snapshots__*" -o -name "*.png" -path "*baselines*" 2>/dev/null | head -5

# Detect CSS approach (affects what might change visually)
grep -r "tailwindcss\|styled-components\|sass\|css-modules" package.json 2>/dev/null
```

## Anti-Patterns

- **Do NOT skip baseline updates after intentional changes.** Stale baselines produce false failures on every subsequent run. Update baselines immediately when changes are intentional.
- **Do NOT set threshold to 0%.** Sub-pixel rendering, anti-aliasing, and font hinting cause tiny differences across environments. A 0% threshold guarantees false positives.
- **Do NOT test only the happy path.** Default state looks fine but hover, focus, error, loading, and empty states often contain regressions. Test every state.
- **Do NOT ignore cross-browser results.** "It works in Chrome" is not sufficient. Firefox and Safari have real rendering differences that affect real users.
- **Do NOT store screenshots in git without LFS.** Screenshot files are large binaries. Use Git LFS, an external storage bucket, or a visual testing service like Chromatic/Percy.
- **Do NOT run visual tests on developer machines for CI baselines.** OS-level font rendering differences between macOS and Linux cause every test to fail. Use consistent CI environments for baselines.
- **Do NOT test third-party components you don't control.** Browser chrome, native form elements, and third-party widgets change with browser updates. Exclude them from strict visual matching.
