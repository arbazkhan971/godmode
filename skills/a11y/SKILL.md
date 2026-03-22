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
```

### Step 2: Automated Tool Scanning
Run automated accessibility scanners in sequence:

#### Axe-core Analysis
```bash
# Install if needed
npm install --save-dev @axe-core/cli

```

#### Pa11y Scanning
```bash
# Install if needed
npm install --save-dev pa11y pa11y-ci

```

#### Lighthouse Accessibility Audit
```bash
# Run Lighthouse accessibility category
npx lighthouse <url> --only-categories=accessibility --output=json --output-path=./a11y-report.json

```

```
AUTOMATED SCAN RESULTS:
Axe findings: <N> violations, <N> incomplete, <N> passes
Pa11y findings: <N> errors, <N> warnings, <N> notices
```

### Step 3: WCAG 2.1 Compliance Checklist
Systematic check against WCAG 2.1 principles:

#### Perceivable (WCAG 1.x)
```
CHECK — Can all users perceive the content?

1.1 Text Alternatives:
```

#### Operable (WCAG 2.x)
```
CHECK — Can all users operate the interface?

2.1 Keyboard Accessible:
```

#### Understandable (WCAG 3.x)
```
CHECK — Can all users understand the content?

3.1 Readable:
```

#### Robust (WCAG 4.x)
```
CHECK — Does the content work with assistive technologies?

4.1 Compatible:
```

### Step 4: Color Contrast Deep Dive
Analyze every foreground/background color combination:

```
COLOR CONTRAST ANALYSIS:
| Element | FG | BG | Ratio | Result |
```

Tools for color contrast:
```bash
# Using color-contrast-checker
npx color-contrast-checker --fg "#999" --bg "#fff"

```

### Step 5: Keyboard Navigation Audit
Test every interactive flow using keyboard only:

```
KEYBOARD NAVIGATION AUDIT:
Flow: <user flow being tested>

```

Test these common keyboard patterns:
```
KEYBOARD PATTERNS:
| Component | Expected Keyboard Behavior |
```

### Step 6: Screen Reader Testing
Verify content is announced correctly:

```
SCREEN READER AUDIT:
Screen reader: <VoiceOver (macOS) / NVDA (Windows) / JAWS / TalkBack (Android)>
Browser: <Safari / Chrome / Firefox>
```

ARIA live region checklist:
```
- [ ] Toast notifications use aria-live="polite" or role="status"
- [ ] Error alerts use aria-live="assertive" or role="alert"
- [ ] Loading states announced with aria-busy="true"
```

### Step 7: Findings Report

For each issue found:
```
### FINDING <N>: <Title>
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**WCAG criterion:** <number> — <name> (Level <A/AA/AAA>)
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
|  ACCESSIBILITY AUDIT — <target>                             |
|  WCAG Level: <AA/AAA>                                       |
|  Automated Scores:                                          |
|  Axe: <N> violations                                        |
|  Pa11y: <N> errors                                          |
|  MUST FIX before shipping:                                  |
|  1. <CRITICAL/HIGH finding>                                 |
|  2. <CRITICAL/HIGH finding>                                 |
|  SHOULD FIX:                                                |
|  3. <MEDIUM finding>                                        |
|  4. <MEDIUM finding>                                        |
```

Verdicts:
- **PASS**: No CRITICAL or HIGH findings. Lighthouse score >= 90.
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

```
A11Y AUDIT REPORT:
| Pages audited | <N> |
|---|---|
| Components audited | <N> |
| Total violations | <N> |
| Critical | <N> (keyboard traps, no alt) |
| High | <N> (contrast, missing labels) |
| Medium | <N> (aria improvements) |
| Low | <N> (best practice suggestions) |
| Auto-fixed | <N> |
| Manual review | <N> |
| WCAG level | A | AA | AAA |
| Verdict | PASS | NEEDS REMEDIATION |
```

## TSV Logging

```
timestamp	skill	page	severity	wcag	element	tool	description	status
2026-03-20T14:00:00Z	a11y	/home	CRITICAL	2.1.2	.modal	manual	keyboard trap in modal	fixed
2026-03-20T14:01:00Z	a11y	/form	HIGH	1.4.3	.label	axe	contrast ratio 3.2:1 < 4.5:1	fixed
```

## Success Criteria

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
| Criterion | Title | Auto | Manual | Status |
|--|--|--|--|--|
| 1.1.1 | Non-text Content | PASS | — | PASS |
| 1.3.1 | Info and Relationships | PASS | CHECK | PENDING |
| 1.4.3 | Contrast (Minimum) | FAIL | — | FAIL |
| 1.4.11 | Non-text Contrast | — | CHECK | PENDING |
| 2.1.1 | Keyboard | — | PASS | PASS |
| 2.1.2 | No Keyboard Trap | — | FAIL | CRITICAL |
| 2.4.3 | Focus Order | — | CHECK | PENDING |
| 2.4.7 | Focus Visible | — | PASS | PASS |
| 2.5.5 | Target Size | — | CHECK | PENDING |
| 3.3.1 | Error Identification | PASS | — | PASS |
| 3.3.2 | Labels or Instructions | FAIL | — | FAIL |
| 4.1.2 | Name, Role, Value | FAIL | CHECK | FAIL |
| ... | (all 50 AA criteria) | ... | ... | ... |

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
| Combination | Priority | Coverage |
|---|---|---|
| VoiceOver + Safari/macOS | PRIMARY | Most common screen reader/ |
|  |  | browser combo on macOS |
| NVDA + Firefox/Windows | PRIMARY | Most common free SR on Windows |
| NVDA + Chrome/Windows | SECONDARY | Second most common on Windows |
| JAWS + Chrome/Windows | SECONDARY | Enterprise standard |
| TalkBack + Chrome/Android | MOBILE | Android accessibility |
| VoiceOver + Safari/iOS | MOBILE | iOS accessibility |

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
| Flow | VO+Safari | NVDA+FF | NVDA+Chrome | TalkBack |
|--|--|--|--|--|
| Login | PASS | PASS | PASS | PASS |
| Signup | PASS | FAIL* | PASS | PENDING |
| Dashboard | PASS | PASS | PASS | PASS |
| Checkout | FAIL** | PASS | PASS | PENDING |
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
     ```
  4. RUN on every PR — block merge if critical/serious violations found
  5. TRACK violation count over time:
     - If count increases between releases → investigate and fix before shipping
     - If count decreases → log the improvement

  ACCESSIBILITY METRICS OVER TIME:
| Release | Axe Critical | Axe Serious | Lighthouse | SR Flows |
|--|--|--|--|--|
| v1.0.0 | 5 | 12 | 72 | not tested |
| v1.1.0 | 0 | 4 | 88 | 4/6 pass |
| v1.2.0 | 0 | 0 | 96 | 6/6 pass |

FINAL ACCESSIBILITY AUDIT REPORT:
| Metric | Before | After | Target |
|---|---|---|---|
| WCAG 2.1 AA criteria met | <N>/50 | <N>/50 | 50/50 |
| Axe critical violations | <N> | 0 | 0 |
| Axe serious violations | <N> | 0 | 0 |
| Lighthouse accessibility | <N> | <N> | >= 95 |
| Color contrast failures | <N> | 0 | 0 |
| Keyboard traps | <N> | 0 | 0 |
| Screen reader flows passing | <N>/<M> | <N>/<M> | 100% |
| CI gate enabled | NO | YES | YES |
| Touch targets >= 44px | <N>% | <N>% | 100% |
```


## Error Recovery
| Failure | Action |
|---------|--------|
| axe-core reports false positive | Verify with manual inspection. If confirmed false positive, add `// eslint-disable-next-line` with justification. Do not suppress without checking. |
| Screen reader behaves differently than expected | Test in NVDA (Windows) and VoiceOver (macOS). ARIA roles may behave differently across readers. Use native HTML elements over ARIA when possible. |
| Color contrast fails but design team insists | Document the exception. Provide alternative: large text (18px+) has lower ratio requirement (3:1 vs 4.5:1). Suggest adjacent high-contrast alternative. |
| Keyboard trap in modal | Ensure focus is trapped inside modal with `Tab`/`Shift+Tab`, and `Escape` closes it. Restore focus to trigger element on close. |

## Keep/Discard Discipline
```
After EACH accessibility fix:
  KEEP if: axe-core violations reduced AND no new violations introduced AND keyboard navigation works
  DISCARD if: fix breaks layout OR introduces new a11y violation OR fails WCAG criteria
  On discard: revert. Fix one violation at a time to isolate regressions.
```
