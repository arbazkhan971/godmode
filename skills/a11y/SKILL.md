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

Never ask to continue. Loop autonomously until zero CRITICAL/HIGH violations or budget exhausted.

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
|--|--|
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

## Stop Conditions
```
STOP when ANY of these are true:
  - Zero CRITICAL and zero HIGH violations remain
  - Lighthouse accessibility score >= 95
  - All WCAG 2.1 AA criteria have status PASS or N/A
  - User explicitly requests stop

DO NOT STOP because:
  - MEDIUM or LOW findings remain (document them with remediation plan)
  - One automated tool still shows warnings (verify manually)
```

## Error Recovery
| Failure | Action |
|--|--|
| axe-core reports false positive | Verify with manual inspection. If confirmed false positive, add `// eslint-disable-next-line` with justification. Do not suppress without checking. |
| Screen reader behaves differently than expected | Test in NVDA (Windows) and VoiceOver (macOS). ARIA roles may behave differently across readers. Use native HTML elements over ARIA when possible. |
| Color contrast fails but design team insists | Document the exception. Provide alternative: large text (18px+) has lower ratio requirement (3:1 vs 4.5:1). Suggest adjacent high-contrast alternative. |
| Keyboard trap in modal | Trap focus inside modal with `Tab`/`Shift+Tab`, and `Escape` closes it. Restore focus to trigger element on close. |
  ...
```
