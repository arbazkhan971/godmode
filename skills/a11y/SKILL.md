---
name: a11y
description: |
  Accessibility testing and auditing skill. Activates when user needs to verify WCAG 2.1 AA/AAA compliance, audit color contrast, keyboard navigation, screen reader compatibility, or fix accessibility issues. Integrates with Axe, Pa11y, and Lighthouse. Combines automated scanning with manual checklist review. Triggers on: /godmode:a11y, "check accessibility", "WCAG audit", "a11y review", or as pre-ship quality gate.
---

# A11y — Accessibility Testing & Auditing

## When to Activate
- User invokes `/godmode:a11y`
- User says "check accessibility," "is this accessible?", "WCAG compliance"
- Pre-ship quality gate during `/godmode:ship` workflow
- After UI changes, component library updates, or design system modifications
- When building forms, navigation, modals, or interactive widgets
- Code review flags missing ARIA attributes or semantic HTML issues

## Workflow

### Step 1: Define Audit Scope
Determine which pages, components, or flows to audit:

```
A11Y AUDIT SCOPE:
Target: <page/component/entire app>
WCAG level: <AA (default) | AAA>
Frameworks detected: <React/Vue/Angular/vanilla HTML>
Components in scope:
  - Navigation: <files/components>
  - Forms: <files/components>
  - Modals/dialogs: <files/components>
  - Interactive widgets: <files/components>
  - Media content: <files/components>
  - Data tables: <files/components>
```

### Step 2: Automated Tool Scanning
Run automated accessibility scanners in sequence:

#### Axe-core Analysis
```bash
# Install if needed
npm install --save-dev @axe-core/cli

# Run axe against target
npx axe <url-or-file> --rules wcag2a,wcag2aa,wcag2aaa,best-practice

# For component-level testing
npx axe <component-storybook-url> --include <selector>
```

#### Pa11y Scanning
```bash
# Install if needed
npm install --save-dev pa11y pa11y-ci

# Single page audit
npx pa11y <url> --standard WCAG2AA --reporter cli

# Multi-page audit with pa11y-ci
npx pa11y-ci --config .pa11yci.json
```

#### Lighthouse Accessibility Audit
```bash
# Run Lighthouse accessibility category
npx lighthouse <url> --only-categories=accessibility --output=json --output-path=./a11y-report.json

# Parse score
node -e "const r = require('./a11y-report.json'); console.log('Score:', r.categories.accessibility.score * 100)"
```

```
AUTOMATED SCAN RESULTS:
Axe findings: <N> violations, <N> incomplete, <N> passes
Pa11y findings: <N> errors, <N> warnings, <N> notices
Lighthouse score: <N>/100

Tool agreement: <N> issues found by multiple tools (high confidence)
Tool-unique: <N> issues found by only one tool (verify manually)
```

### Step 3: WCAG 2.1 Compliance Checklist
Systematic check against WCAG 2.1 principles:

#### Perceivable (WCAG 1.x)
```
CHECK — Can all users perceive the content?

1.1 Text Alternatives:
- [ ] All images have meaningful alt text (not "image" or "photo")
- [ ] Decorative images have alt="" or role="presentation"
- [ ] Complex images (charts, diagrams) have long descriptions
- [ ] Icon buttons have accessible labels
- [ ] SVG elements have <title> or aria-label

1.2 Time-based Media:
- [ ] Videos have captions
- [ ] Audio has transcripts
- [ ] Auto-playing media can be paused/stopped

1.3 Adaptable:
- [ ] Content uses semantic HTML (headings, lists, landmarks)
- [ ] Heading hierarchy is logical (h1 > h2 > h3, no skips)
- [ ] Tables use <th>, scope, and caption
- [ ] Form inputs have associated <label> elements
- [ ] Reading order matches visual order
- [ ] Content does not rely solely on sensory characteristics (shape, color, position)

1.4 Distinguishable:
- [ ] Color contrast ratio >= 4.5:1 for normal text (AA)
- [ ] Color contrast ratio >= 3:1 for large text (AA)
- [ ] Color contrast ratio >= 7:1 for normal text (AAA)
- [ ] Color is not the only means of conveying information
- [ ] Text can be resized to 200% without loss of content
- [ ] No horizontal scrolling at 320px viewport width
- [ ] UI component contrast ratio >= 3:1 against adjacent colors
- [ ] Text spacing can be overridden without breaking layout
```

#### Operable (WCAG 2.x)
```
CHECK — Can all users operate the interface?

2.1 Keyboard Accessible:
- [ ] All interactive elements reachable via Tab key
- [ ] Tab order follows logical reading order
- [ ] No keyboard traps (can always Tab away)
- [ ] Custom widgets support expected keyboard patterns (Arrow keys, Enter, Escape)
- [ ] Keyboard shortcuts don't conflict with assistive technology
- [ ] Skip navigation link present and functional

2.2 Enough Time:
- [ ] Time limits can be extended or turned off
- [ ] Auto-updating content can be paused
- [ ] No content flashes more than 3 times per second

2.3 Seizures & Physical Reactions:
- [ ] No content flashes more than 3 times per second
- [ ] Animations respect prefers-reduced-motion

2.4 Navigable:
- [ ] Page has descriptive <title>
- [ ] Focus order is logical
- [ ] Link text is descriptive (not "click here" or "read more")
- [ ] Multiple ways to find pages (nav, search, sitemap)
- [ ] Headings and labels describe topic or purpose
- [ ] Focus is visible on all interactive elements

2.5 Input Modalities:
- [ ] Touch targets are at least 44x44 CSS pixels
- [ ] Pointer gestures have single-pointer alternatives
- [ ] Dragging has non-dragging alternatives
```

#### Understandable (WCAG 3.x)
```
CHECK — Can all users understand the content?

3.1 Readable:
- [ ] Page language declared with lang attribute
- [ ] Language changes marked with lang attribute on elements
- [ ] Unusual words or jargon are defined

3.2 Predictable:
- [ ] No unexpected context changes on focus
- [ ] No unexpected context changes on input (without warning)
- [ ] Navigation is consistent across pages
- [ ] Components with same function are identified consistently

3.3 Input Assistance:
- [ ] Error messages identify the field and describe the error
- [ ] Labels or instructions provided for user input
- [ ] Error suggestions provided when possible
- [ ] Submissions are reversible, checked, or confirmed
- [ ] Required fields are clearly indicated (not just by color)
```

#### Robust (WCAG 4.x)
```
CHECK — Does the content work with assistive technologies?

4.1 Compatible:
- [ ] HTML validates (no duplicate IDs, proper nesting)
- [ ] ARIA roles, states, and properties are valid
- [ ] ARIA attributes match element semantics
- [ ] Custom components expose name, role, value
- [ ] Status messages use aria-live or role="status"
- [ ] Dynamic content changes announced to screen readers
```

### Step 4: Color Contrast Deep Dive
Analyze every foreground/background color combination:

```
COLOR CONTRAST ANALYSIS:
┌──────────────────────────────────────────────┐
│ Element          │ FG      │ BG      │ Ratio │ Result │
├──────────────────────────────────────────────┤
│ Body text        │ #333    │ #fff    │ 12.6  │ AAA    │
│ Link text        │ #0066cc │ #fff    │ 5.4   │ AA     │
│ Placeholder      │ #999    │ #fff    │ 2.8   │ FAIL   │
│ Button text      │ #fff    │ #007bff │ 4.5   │ AA     │
│ Error message    │ #dc3545 │ #fff    │ 4.9   │ AA     │
│ Disabled text    │ #6c757d │ #e9ecef │ 3.1   │ FAIL*  │
└──────────────────────────────────────────────┘
* Disabled elements are exempt but should still be perceivable

Failures requiring remediation: <N>
```

Tools for color contrast:
```bash
# Using color-contrast-checker
npx color-contrast-checker --fg "#999" --bg "#fff"

# CSS custom property extraction and analysis
grep -r "color:" src/ --include="*.css" --include="*.scss"
```

### Step 5: Keyboard Navigation Audit
Test every interactive flow using keyboard only:

```
KEYBOARD NAVIGATION AUDIT:
Flow: <user flow being tested>

Step 1: Tab to first interactive element
  Expected: <element> receives focus
  Focus visible: YES/NO
  Focus order correct: YES/NO

Step 2: Navigate within component
  Expected key: <Tab/Arrow/Enter/Space/Escape>
  Behavior: <what should happen>
  Keyboard trap: YES/NO

Step 3: Complete action
  Expected: <action completes>
  Focus returns to: <appropriate element>
  Announcement: <what screen reader should say>
```

Test these common keyboard patterns:
```
KEYBOARD PATTERNS:
┌─────────────────────┬────────────────────────────────────────┐
│ Component           │ Expected Keyboard Behavior             │
├─────────────────────┼────────────────────────────────────────┤
│ Button              │ Enter/Space to activate                │
│ Link                │ Enter to follow                        │
│ Checkbox            │ Space to toggle                        │
│ Radio group         │ Arrow keys to move, Space to select    │
│ Select/Dropdown     │ Arrow keys to navigate, Enter to pick  │
│ Tab panel           │ Arrow keys between tabs, Tab into panel│
│ Modal/Dialog        │ Escape to close, Tab trapped inside    │
│ Menu                │ Arrow keys to navigate, Escape to close│
│ Accordion           │ Enter/Space to expand, Arrow to move   │
│ Slider              │ Arrow keys to adjust value             │
│ Date picker         │ Arrow keys for dates, Enter to select  │
│ Autocomplete        │ Arrow keys for options, Enter to pick  │
└─────────────────────┴────────────────────────────────────────┘
```

### Step 6: Screen Reader Testing
Verify content is announced correctly:

```
SCREEN READER AUDIT:
Screen reader: <VoiceOver (macOS) / NVDA (Windows) / JAWS / TalkBack (Android)>
Browser: <Safari / Chrome / Firefox>

Test 1: Page landmarks
  Expected: Banner, Navigation, Main, Contentinfo announced
  Result: <PASS/FAIL>

Test 2: Headings navigation
  Expected: All headings in logical hierarchy
  Result: <PASS/FAIL>

Test 3: Form interaction
  Expected: Labels, required state, error messages announced
  Result: <PASS/FAIL>

Test 4: Dynamic content
  Expected: Live region updates announced
  Result: <PASS/FAIL>

Test 5: Images and media
  Expected: Alt text read, decorative images skipped
  Result: <PASS/FAIL>
```

ARIA live region checklist:
```
- [ ] Toast notifications use aria-live="polite" or role="status"
- [ ] Error alerts use aria-live="assertive" or role="alert"
- [ ] Loading states announced with aria-busy="true"
- [ ] Dynamic content updates in aria-live regions
- [ ] aria-live region exists in DOM before content is injected
```

### Step 7: Findings Report

For each issue found:
```
### FINDING <N>: <Title>
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**WCAG criterion:** <number> — <name> (Level <A/AA/AAA>)
**Tool:** <axe/pa11y/lighthouse/manual>
**Location:** <file:line> or <page URL + selector>
**Evidence:**
```html
<!-- The inaccessible markup -->
<actual code>
```

**Impact:**
<Who is affected and how — specific disability/assistive technology>

**Remediation:**
```html
<!-- The accessible fix -->
<fixed code>
```

**Verification:**
<How to confirm the fix — tool command or manual test>
```

Severity definitions:
- **CRITICAL**: Complete blocker for assistive technology users. Missing form labels, keyboard traps, no alt text on functional images.
- **HIGH**: Significant barrier. Poor contrast on primary text, missing landmarks, unlabeled interactive elements.
- **MEDIUM**: Degraded experience. Missing skip link, non-descriptive link text, heading hierarchy issues.
- **LOW**: Minor inconvenience. Redundant ARIA, suboptimal focus order, missing lang attribute on foreign text.

### Step 8: Auto-Fix Common Issues
Apply automated fixes for straightforward issues:

```
AUTO-FIXABLE ISSUES:
1. Add missing alt="" to decorative images
2. Associate orphaned labels with inputs via for/id
3. Add aria-label to icon-only buttons
4. Fix heading hierarchy gaps
5. Add lang attribute to <html>
6. Add skip navigation link
7. Wrap form error messages in aria-live region
8. Add role="presentation" to layout tables
```

For each auto-fix:
```
FIX <N>: <description>
File: <path>
Before: <original code>
After: <fixed code>
WCAG: <criterion satisfied>
```

### Step 9: Accessibility Report

```
+------------------------------------------------------------+
|  ACCESSIBILITY AUDIT — <target>                             |
+------------------------------------------------------------+
|  WCAG Level: <AA/AAA>                                       |
|                                                             |
|  Automated Scores:                                          |
|  Axe: <N> violations                                        |
|  Pa11y: <N> errors                                          |
|  Lighthouse: <N>/100                                        |
|                                                             |
|  Manual Findings:                                           |
|  CRITICAL: <N>                                              |
|  HIGH:     <N>                                              |
|  MEDIUM:   <N>                                              |
|  LOW:      <N>                                              |
|                                                             |
|  Coverage:                                                  |
|  Perceivable:    <PASS/FAIL> (<N> issues)                   |
|  Operable:       <PASS/FAIL> (<N> issues)                   |
|  Understandable: <PASS/FAIL> (<N> issues)                   |
|  Robust:         <PASS/FAIL> (<N> issues)                   |
|                                                             |
|  Auto-fixed: <N> issues                                     |
|  Manual fix required: <N> issues                            |
|                                                             |
|  Verdict: <PASS | CONDITIONAL PASS | FAIL>                  |
+------------------------------------------------------------+
|  MUST FIX before shipping:                                  |
|  1. <CRITICAL/HIGH finding>                                 |
|  2. <CRITICAL/HIGH finding>                                 |
|                                                             |
|  SHOULD FIX:                                                |
|  3. <MEDIUM finding>                                        |
|  4. <MEDIUM finding>                                        |
+------------------------------------------------------------+
```

Verdicts:
- **PASS**: No CRITICAL or HIGH findings. Lighthouse score >= 90.
- **CONDITIONAL PASS**: No CRITICAL, but HIGH findings with accepted risk or remediation plan.
- **FAIL**: Any CRITICAL finding, or Lighthouse score < 70.

### Step 10: Commit and Transition
1. Save report as `docs/a11y/<target>-a11y-audit.md`
2. If auto-fixes were applied, commit: `"a11y: <target> — fix <N> accessibility issues"`
3. Commit report: `"a11y: <target> — <verdict> (score: <N>/100, <N> findings)"`
4. If FAIL: "Critical accessibility issues found. Fix the MUST FIX items, then re-audit with `/godmode:a11y`."
5. If PASS: "Accessibility audit passed. Ready for `/godmode:ship`."

## Key Behaviors

1. **Automated scanning is necessary but not sufficient.** Automated tools catch ~30-40% of accessibility issues. The manual checklist catches the rest. Always do both.
2. **Test with real assistive technology.** VoiceOver on macOS is free. NVDA on Windows is free. Use them. No amount of ARIA knowledge replaces hearing what a screen reader actually says.
3. **Fix the code, not just the ARIA.** Prefer semantic HTML over ARIA attributes. A `<button>` is better than `<div role="button" tabindex="0">`. ARIA is a patch, not a solution.
4. **Color contrast is non-negotiable.** If text fails contrast requirements, it must be fixed. There is no "accepted risk" for unreadable text.
5. **Keyboard access is non-negotiable.** If something cannot be activated by keyboard, it is broken for keyboard users, screen reader users, switch users, and voice control users.
6. **Test the actual user flows.** Don't just test individual components. Test the flows: sign up, log in, complete a purchase, fill out a form. The journey matters.
7. **Accessibility is not a feature.** It is a baseline quality requirement. Every component, every page, every release.

## Example Usage

### Full accessibility audit
```
User: /godmode:a11y

A11y: Detecting project structure...

A11Y AUDIT SCOPE:
Target: Entire application
WCAG level: AA
Framework: React with Tailwind CSS
Components in scope: 24 components, 8 pages

Running automated scans...
Axe: 7 violations found
Pa11y: 12 errors, 3 warnings
Lighthouse: 78/100

Running WCAG checklist...
Perceivable: 3 issues (missing alt text, low contrast placeholder)
Operable: 2 issues (keyboard trap in modal, missing skip link)
Understandable: 1 issue (missing error descriptions on form)
Robust: 2 issues (duplicate IDs, invalid ARIA)

FINDING 1: Keyboard trap in modal dialog
Severity: CRITICAL
WCAG: 2.1.2 — No Keyboard Trap (Level A)
Location: src/components/Modal.tsx:45
...

Auto-fixing 4 issues...
Manual fix required for 4 issues.

Verdict: FAIL — 1 CRITICAL, 2 HIGH findings require remediation.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full automated + manual audit at WCAG 2.1 AA level |
| `--aaa` | Audit against WCAG 2.1 AAA (stricter) |
| `--component <name>` | Audit a specific component |
| `--page <url>` | Audit a specific page |
| `--contrast-only` | Run only color contrast analysis |
| `--keyboard-only` | Run only keyboard navigation audit |
| `--screen-reader` | Focus on screen reader compatibility |
| `--fix` | Auto-fix issues after audit (invokes remediation) |
| `--ci` | Output in CI-friendly format (exit code 1 on failure) |

## Auto-Detection

Before prompting the user, automatically detect the project context:

```
AUTO-DETECT SEQUENCE:
1. Scan package.json / requirements.txt for framework:
   - React/Next.js → check for jsx/tsx files, component patterns
   - Vue → check for .vue files
   - Angular → check for angular.json
   - Vanilla → check for .html files
2. Detect UI library:
   - grep for '@mui', 'antd', '@chakra-ui', 'tailwind', 'bootstrap'
3. Detect existing a11y tooling:
   - Check devDependencies for axe-core, pa11y, jest-axe, cypress-axe
   - Check for .pa11yci.json, .axe config files
4. Detect existing a11y patterns:
   - grep for 'aria-', 'role=', 'alt=', 'sr-only', 'visually-hidden'
   - grep for 'prefers-reduced-motion' in CSS/SCSS
5. Detect testing infrastructure:
   - Storybook? → can use @storybook/addon-a11y
   - Jest? → can use jest-axe
   - Playwright/Cypress? → can use axe integration
6. Count components and pages in scope automatically
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. NEVER skip the manual checklist even if automated tools report 0 violations.
   Automated tools catch 30-40% of issues. The checklist catches the rest.
2. NEVER mark PASS if any CRITICAL finding exists — regardless of Lighthouse score.
3. NEVER auto-fix without verifying the fix does not break existing functionality.
4. git commit BEFORE running verify — if verify reveals regression, revert the commit.
5. Every finding MUST include: severity, WCAG criterion, location, evidence, remediation.
6. Log all findings in TSV format for tracking:
   SEVERITY\tWCAG\tLOCATION\tTOOL\tDESCRIPTION
7. Color contrast failures are ALWAYS HIGH or CRITICAL — no exceptions.
8. Keyboard traps are ALWAYS CRITICAL — no exceptions.
9. If auto-fix changes > 10 files, split into separate commits per concern.
10. Re-run automated scans AFTER applying fixes to confirm zero regressions.
```

## Output Format

After each accessibility audit, emit a structured report:

```
A11Y AUDIT REPORT:
┌──────────────────────────────────────────────────────┐
│  Pages audited      │  <N>                            │
│  Components audited │  <N>                            │
│  Total violations   │  <N>                            │
│  Critical           │  <N> (keyboard traps, no alt)   │
│  High               │  <N> (contrast, missing labels) │
│  Medium             │  <N> (aria improvements)        │
│  Low                │  <N> (best practice suggestions) │
│  Auto-fixed         │  <N>                            │
│  Manual review      │  <N>                            │
│  WCAG level         │  A | AA | AAA                   │
│  Verdict            │  PASS | NEEDS REMEDIATION       │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every finding for tracking and regression detection:

```
timestamp	skill	page	severity	wcag	element	tool	description	status
2026-03-20T14:00:00Z	a11y	/home	CRITICAL	2.1.2	.modal	manual	keyboard trap in modal	fixed
2026-03-20T14:01:00Z	a11y	/form	HIGH	1.4.3	.label	axe	contrast ratio 3.2:1 < 4.5:1	fixed
```

## Success Criteria

The a11y skill is complete when ALL of the following are true:
1. Zero CRITICAL violations (keyboard traps, missing alt text on meaningful images)
2. Zero HIGH violations (contrast failures, missing form labels, broken ARIA)
3. All MEDIUM violations documented with remediation plan and timeline
4. axe-core automated scan returns zero errors on all audited pages
5. Manual keyboard navigation test passes (all interactive elements reachable, no traps)
6. Screen reader spot-check confirms logical reading order and announced labels
7. All fixes committed and verified with re-scan showing no regressions

## Error Recovery

```
IF axe-core fails to run:
  1. Verify the page is fully loaded before scanning (wait for hydration)
  2. Check for CSP or CORS blocking the axe-core injection
  3. Try running in a different browser or headless mode
  4. Fall back to Lighthouse accessibility audit

IF fix introduces new violations:
  1. Re-run axe-core immediately after every fix
  2. If new violations appear, revert the fix
  3. Investigate whether the fix changed DOM structure affecting other elements
  4. Apply a more targeted fix that addresses the original issue without side effects

IF contrast fix conflicts with brand guidelines:
  1. Document the conflict with exact ratio values
  2. Propose the closest brand-compliant color that passes WCAG AA (4.5:1)
  3. Escalate to design team with before/after comparison
  4. Never ship a contrast violation — WCAG AA is non-negotiable

IF ARIA fix causes screen reader regression:
  1. Test with NVDA (Windows) or VoiceOver (macOS) before and after
  2. Prefer semantic HTML over ARIA (use <button> not <div role="button">)
  3. If ARIA is necessary, verify the role/state/property combination is valid
  4. Check WAI-ARIA Authoring Practices for the correct pattern
```

## Anti-Patterns

- **Do NOT rely solely on automated tools.** Automated tools catch 30-40% of issues. Manual testing is mandatory.
- **Do NOT add ARIA to fix semantic HTML problems.** Use `<button>` not `<div role="button">`. ARIA is a patch.
- **Do NOT hide content with display:none and expect screen readers to read it.** Use visually-hidden CSS class.
- **Do NOT use color alone to convey meaning.** Add text, icons, or patterns.
- **Do NOT skip keyboard testing.** Screen reader users, motor-impaired users, and power users all use keyboards.
- **Do NOT treat accessibility as a post-launch fix.** Retrofitting is 10x harder than building accessibly from the start.
- **Do NOT assume 100/100 Lighthouse score means accessible.** Lighthouse checks ~40 rules. WCAG has hundreds.

## Keep/Discard Discipline
```
After EACH accessibility fix:
  1. MEASURE: Re-run axe-core and manual check on the fixed component.
  2. COMPARE: Did the violation count decrease? Did any new violations appear?
  3. DECIDE:
     - KEEP if: target violation fixed AND no new violations introduced
     - DISCARD if: fix introduced new violations OR broke existing functionality
  4. COMMIT kept changes. Revert discarded changes before fixing the next issue.

Never keep a fix that introduces a keyboard trap or removes screen reader access.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Zero CRITICAL and zero HIGH violations remain
  - Lighthouse accessibility score >= 95
  - All WCAG 2.1 AA criteria have status PASS or N/A
  - User explicitly requests stop

DO NOT STOP just because:
  - MEDIUM or LOW findings remain (document them with remediation plan)
  - One automated tool still shows warnings (verify manually)
```


## Accessibility Audit Loop

Autoresearch-grade iterative accessibility compliance loop. Combines automated scanning with structured manual testing protocols to achieve and maintain WCAG compliance through measured, repeatable cycles.

```
ACCESSIBILITY AUDIT PROTOCOL:

Phase 1 — WCAG Checklist Compliance Loop
  target: zero CRITICAL, zero HIGH, all WCAG 2.1 AA criteria addressed
  current_iteration = 0
  max_iterations = 10

  WHILE (critical_count > 0 OR high_count > 0) AND current_iteration < max_iterations:
    1. RUN automated scan battery:
       npx axe <url> --rules wcag2a,wcag2aa,best-practice
       npx pa11y <url> --standard WCAG2AA --reporter json
       npx lighthouse <url> --only-categories=accessibility --output=json
    2. AGGREGATE findings:
       - Deduplicate across tools (same element + same criterion = one finding)
       - Classify: CRITICAL | HIGH | MEDIUM | LOW
       - Map each finding to WCAG criterion (e.g., 1.4.3, 2.1.1, 4.1.2)
    3. BUILD WCAG compliance matrix:

  WCAG 2.1 AA COMPLIANCE MATRIX:
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  Criterion  │  Title                       │  Auto │  Manual │  Status  │
  ├─────────────┼──────────────────────────────┼───────┼─────────┼──────────┤
  │  1.1.1      │  Non-text Content            │  PASS │  —      │  PASS    │
  │  1.3.1      │  Info and Relationships      │  PASS │  CHECK  │  PENDING │
  │  1.4.3      │  Contrast (Minimum)          │  FAIL │  —      │  FAIL    │
  │  1.4.11     │  Non-text Contrast           │  —    │  CHECK  │  PENDING │
  │  2.1.1      │  Keyboard                    │  —    │  PASS   │  PASS    │
  │  2.1.2      │  No Keyboard Trap            │  —    │  FAIL   │  CRITICAL│
  │  2.4.3      │  Focus Order                 │  —    │  CHECK  │  PENDING │
  │  2.4.7      │  Focus Visible               │  —    │  PASS   │  PASS    │
  │  2.5.5      │  Target Size                 │  —    │  CHECK  │  PENDING │
  │  3.3.1      │  Error Identification        │  PASS │  —      │  PASS    │
  │  3.3.2      │  Labels or Instructions      │  FAIL │  —      │  FAIL    │
  │  4.1.2      │  Name, Role, Value           │  FAIL │  CHECK  │  FAIL    │
  │  ...        │  (all 50 AA criteria)        │  ...  │  ...    │  ...     │
  └─────────────┴──────────────────────────────┴───────┴─────────┴──────────┘

    4. FIX findings in priority order: CRITICAL first, then HIGH
    5. RE-RUN automated scans after each batch of fixes
    6. VERIFY fixes did not introduce new violations
    7. RECORD:
       criterion | finding | severity | fix_applied | before_status | after_status
    8. current_iteration += 1

  CONVERGENCE CRITERIA:
    - Zero CRITICAL findings
    - Zero HIGH findings
    - All 50 WCAG 2.1 AA criteria have status PASS or N/A
    - Lighthouse accessibility score >= 95
    OR max 10 iterations (report remaining gaps with remediation plan)

Phase 2 — Screen Reader Testing Protocol
  Test with real assistive technology, not just ARIA validation.

  SCREEN READER TEST MATRIX:
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  Combination              │  Priority  │  Coverage                       │
  ├───────────────────────────┼────────────┼─────────────────────────────────┤
  │  VoiceOver + Safari/macOS │  PRIMARY   │  Most common screen reader/     │
  │                           │            │  browser combo on macOS         │
  │  NVDA + Firefox/Windows   │  PRIMARY   │  Most common free SR on Windows │
  │  NVDA + Chrome/Windows    │  SECONDARY │  Second most common on Windows  │
  │  JAWS + Chrome/Windows    │  SECONDARY │  Enterprise standard            │
  │  TalkBack + Chrome/Android│  MOBILE    │  Android accessibility          │
  │  VoiceOver + Safari/iOS   │  MOBILE    │  iOS accessibility              │
  └───────────────────────────┴────────────┴─────────────────────────────────┘

  FOR EACH priority combination:
    FOR EACH critical user flow (login, signup, primary task, checkout):
      1. NAVIGATE to the starting page using screen reader only (no mouse/trackpad)
      2. TEST landmark navigation:
         - VO+U (VoiceOver rotor) or NVDA+F7 (elements list)
         - Verify: Banner, Navigation, Main, Contentinfo landmarks announced
         - Verify: Heading hierarchy is logical (H1 → H2 → H3, no skips)
      3. TEST form interaction:
         - Tab to each form field
         - Verify: label announced on focus
         - Verify: required state announced
         - Submit with invalid data
         - Verify: error messages announced (via aria-live or role="alert")
         - Verify: focus moves to first error field
      4. TEST dynamic content:
         - Trigger a toast/notification
         - Verify: announced via aria-live="polite" or role="status"
         - Open a modal dialog
         - Verify: focus trapped inside modal, Escape closes, focus returns
         - Expand an accordion/disclosure
         - Verify: expanded/collapsed state announced
      5. TEST data tables:
         - Navigate with table commands (Ctrl+Alt+Arrow in VoiceOver)
         - Verify: column headers announced with each cell
         - Verify: row/column position announced
      6. RECORD findings per combination:
         flow | step | expected | actual | sr_combination | status

  SCREEN READER TEST RESULTS:
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  Flow          │  VO+Safari │  NVDA+FF  │  NVDA+Chrome │  TalkBack    │
  ├────────────────┼────────────┼───────────┼──────────────┼──────────────┤
  │  Login         │  PASS      │  PASS     │  PASS        │  PASS        │
  │  Signup        │  PASS      │  FAIL*    │  PASS        │  PENDING     │
  │  Dashboard     │  PASS      │  PASS     │  PASS        │  PASS        │
  │  Checkout      │  FAIL**    │  PASS     │  PASS        │  PENDING     │
  └────────────────┴────────────┴───────────┴──────────────┴──────────────┘
  * Error messages not announced in NVDA+Firefox — missing aria-live region
  ** Modal focus not trapped in VoiceOver — missing focus trap implementation

Phase 3 — Automated Regression Gate
  Set up automated accessibility testing in CI/CD:

  CI ACCESSIBILITY GATE:
  1. INSTALL: npm install --save-dev @axe-core/playwright  (or jest-axe, cypress-axe)
  2. CONFIGURE threshold:
     - Zero violations at "critical" and "serious" impact levels
     - Warning-only for "moderate" and "minor" impact levels
  3. ADD to CI pipeline (example with Playwright):
     ```
     test('page has no accessibility violations', async ({ page }) => {
       await page.goto('/');
       const results = await new AxeBuilder({ page })
         .withTags(['wcag2a', 'wcag2aa'])
         .analyze();
       expect(results.violations.filter(v =>
         v.impact === 'critical' || v.impact === 'serious'
       )).toHaveLength(0);
     });
     ```
  4. RUN on every PR — block merge if critical/serious violations found
  5. TRACK violation count over time:
     - If count increases between releases → investigate and fix before shipping
     - If count decreases → log the improvement

  ACCESSIBILITY METRICS OVER TIME:
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  Release    │  Axe Critical │  Axe Serious │  Lighthouse │  SR Flows   │
  ├─────────────┼───────────────┼──────────────┼─────────────┼─────────────┤
  │  v1.0.0     │  5            │  12          │  72         │  not tested │
  │  v1.1.0     │  0            │  4           │  88         │  4/6 pass   │
  │  v1.2.0     │  0            │  0           │  96         │  6/6 pass   │
  └─────────────┴───────────────┴──────────────┴─────────────┴─────────────┘

FINAL ACCESSIBILITY AUDIT REPORT:
┌──────────────────────────────────────────────────────────────────────────┐
│  Metric                            │  Before   │  After    │  Target    │
├────────────────────────────────────┼───────────┼───────────┼────────────┤
│  WCAG 2.1 AA criteria met         │  <N>/50   │  <N>/50   │  50/50     │
│  Axe critical violations           │  <N>      │  0        │  0         │
│  Axe serious violations            │  <N>      │  0        │  0         │
│  Lighthouse accessibility          │  <N>      │  <N>      │  >= 95     │
│  Color contrast failures           │  <N>      │  0        │  0         │
│  Keyboard traps                    │  <N>      │  0        │  0         │
│  Screen reader flows passing       │  <N>/<M>  │  <N>/<M>  │  100%      │
│  CI gate enabled                   │  NO       │  YES      │  YES       │
│  Touch targets >= 44px             │  <N>%     │  <N>%     │  100%      │
└────────────────────────────────────┴───────────┴───────────┴────────────┘
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
Run accessibility audits sequentially: perceivable, then operable, then understandable/robust, then autofix.
Use branch isolation per task: `git checkout -b godmode-a11y-{task}`, implement, commit, merge back.
