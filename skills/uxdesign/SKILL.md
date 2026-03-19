---
name: uxdesign
description: |
  UI/UX design skill. Activates when user needs help with user research, persona creation, information architecture, wireframing, prototyping workflows, design system adherence, usability heuristic evaluation, user flow mapping, WCAG-compliant design, design handoff, A/B testing design variants, or mobile-first responsive design. Covers the full design process from discovery through developer handoff. Triggers on: /godmode:uxdesign, "UX review", "user flow", "wireframe", "design critique", "usability audit", "persona", or when designing interfaces and user experiences.
---

# UXDesign — UI/UX Design

## When to Activate
- User invokes `/godmode:uxdesign`
- User says "UX review," "design critique," "wireframe this," "user flow," "usability audit"
- When designing a new feature, page, or application from scratch
- When evaluating an existing interface for usability problems
- When creating or updating user personas and journey maps
- When structuring information architecture or navigation
- Before building UI to validate the design approach
- When preparing design specifications for developer handoff
- When planning A/B tests for design variants

## Workflow

### Step 1: Understand the Design Context
Establish what exists, who the users are, and what the goals are:

```
UX DESIGN CONTEXT:
Project: <name>
Stage: <discovery / definition / design / testing / handoff>
Platform: <web / iOS / Android / cross-platform / desktop>
Existing design system: <yes (name) / partial / no>
Design tools in use: <Figma / Sketch / Adobe XD / code-only / none>

Users:
  Primary audience: <who>
  Secondary audience: <who>
  Known pain points: <list>
  Accessibility requirements: <WCAG AA / AAA / none specified>

Business goals:
  Primary metric: <conversion / retention / engagement / task completion / other>
  Success criteria: <measurable outcome>
  Constraints: <timeline, budget, tech stack, brand guidelines>
```

### Step 2: User Research and Persona Creation
Define who you are designing for with actionable detail:

#### Persona Template
For each distinct user segment, build a persona:
```
PERSONA: <Name>
Role: <job title or user type>
Age range: <demographic bracket>
Tech comfort: <LOW / MEDIUM / HIGH>
Access method: <mobile-primary / desktop-primary / mixed>
Accessibility needs: <screen reader / low vision / motor impairment / cognitive / none known>

Goals:
  1. <Primary goal — what they want to accomplish>
  2. <Secondary goal>
  3. <Tertiary goal>

Frustrations:
  1. <What blocks them today>
  2. <What annoys them in current solutions>
  3. <What wastes their time>

Behaviors:
  - <How they currently solve the problem>
  - <Tools and platforms they already use>
  - <Frequency of use — daily / weekly / monthly>

Key scenarios:
  1. <Most common task they perform>
  2. <Edge case or stress scenario>
  3. <First-time use scenario>
```

#### Research Methods Selection
Choose research methods based on what you need to learn:
```
RESEARCH METHOD SELECTION:
┌──────────────────────────────────────────────────────────────────────┐
│ Question                          │ Method              │ Effort    │
├──────────────────────────────────────────────────────────────────────┤
│ What do users need?               │ User interviews     │ MEDIUM    │
│ How do users behave today?        │ Analytics review     │ LOW       │
│ Where do users get stuck?         │ Usability testing    │ MEDIUM    │
│ What do competitors do?           │ Competitive analysis │ LOW       │
│ What content do users expect?     │ Card sorting         │ MEDIUM    │
│ Can users find what they need?    │ Tree testing         │ LOW       │
│ What do users call things?        │ First-click testing  │ LOW       │
│ Which design performs better?     │ A/B testing          │ HIGH      │
│ What are users feeling?           │ Journey mapping      │ MEDIUM    │
└──────────────────────────────────────────────────────────────────────┘

Selected methods for this project:
1. <method> — <justification>
2. <method> — <justification>
```

### Step 3: Information Architecture
Structure the content and navigation before any visual design:

#### Site Map / App Structure
```
INFORMATION ARCHITECTURE:
┌─ Home
│  ├─ Dashboard
│  │  ├─ Overview
│  │  ├─ Analytics
│  │  └─ Notifications
│  ├─ [Feature Area 1]
│  │  ├─ List view
│  │  ├─ Detail view
│  │  └─ Create/Edit
│  ├─ [Feature Area 2]
│  │  ├─ ...
│  │  └─ ...
│  ├─ Settings
│  │  ├─ Profile
│  │  ├─ Preferences
│  │  └─ Billing
│  └─ Help / Support
│     ├─ Documentation
│     ├─ FAQ
│     └─ Contact

Navigation model: <top nav / side nav / tab bar / hamburger / combo>
Max depth: <N> levels
Estimated pages/screens: <N>
```

#### Navigation Design Principles
```
NAVIGATION EVALUATION:
- [ ] Primary actions reachable in 1-2 clicks/taps from any screen
- [ ] User always knows where they are (breadcrumbs, active states, page titles)
- [ ] User always knows where they can go (visible navigation, clear CTAs)
- [ ] User can always get back (back button, home link, undo)
- [ ] Navigation labels use user language, not internal jargon
- [ ] Destructive actions require confirmation
- [ ] Search is available for content-heavy applications (> 20 pages)
- [ ] Mobile nav collapses appropriately without hiding critical paths
```

### Step 4: User Flow Mapping
Map the critical paths users take through the interface:

#### User Flow Template
```
USER FLOW: <Flow Name>
Persona: <which persona>
Trigger: <what initiates this flow>
Goal: <what the user wants to accomplish>
Success metric: <how you measure completion>

Steps:
┌─────┬────────────────────┬──────────────────┬─────────────────────┐
│ #   │ Screen / State     │ User Action      │ System Response     │
├─────┼────────────────────┼──────────────────┼─────────────────────┤
│ 1   │ Landing page       │ Clicks "Sign up" │ Shows signup form   │
│ 2   │ Signup form        │ Fills fields     │ Validates in real   │
│     │                    │                  │ time                │
│ 3   │ Signup form        │ Clicks "Submit"  │ Creates account,    │
│     │                    │                  │ sends verification  │
│ 4   │ Confirmation       │ Checks email     │ Sends welcome email │
│ 5   │ Email link         │ Clicks verify    │ Redirects to        │
│     │                    │                  │ onboarding          │
│ 6   │ Onboarding         │ Completes steps  │ Shows dashboard     │
└─────┴────────────────────┴──────────────────┴─────────────────────┘

Decision points:
  Step 2 → Error: validation fails → show inline errors, do not clear fields
  Step 3 → Error: account exists → offer login link, do not reveal if email exists
  Step 5 → Error: link expired → offer resend option

Drop-off risks:
  Step 2: Too many required fields → minimize to email + password only
  Step 4: User never checks email → add "resend" + alternative verification
  Step 6: Onboarding too long → make skippable, max 3 steps
```

#### Flow Complexity Check
```
FLOW COMPLEXITY:
Total steps to complete primary goal: <N>
Required form fields: <N>
Decision points: <N>
Error states to handle: <N>
External dependencies (email, SMS, OAuth): <N>

Verdict:
  < 5 steps → GOOD — minimal friction
  5-8 steps → ACCEPTABLE — look for shortcuts
  > 8 steps → TOO COMPLEX — simplify or break into stages
```

### Step 5: Wireframing and Prototyping
Define layout and interaction before visual polish:

#### Wireframe Specification
For each screen, define the structural layout:
```
WIREFRAME: <Screen Name>
Purpose: <what this screen accomplishes>
Entry points: <how users arrive here>
Exit points: <where users go next>

Layout (top to bottom):
┌──────────────────────────────────────────────┐
│ [Header: Logo | Nav items | User menu]       │
├──────────────────────────────────────────────┤
│ [Page title + breadcrumb]                    │
├──────────────────────────────────────────────┤
│ [Primary content area]                       │
│  - <content block 1: purpose>                │
│  - <content block 2: purpose>                │
│  - <content block 3: purpose>                │
├──────────────────────────────────────────────┤
│ [Primary CTA: label and action]              │
│ [Secondary action: label and action]         │
├──────────────────────────────────────────────┤
│ [Footer: links | legal | support]            │
└──────────────────────────────────────────────┘

Content priority (most to least important):
  1. <what must be visible above the fold>
  2. <what should be visible without scrolling far>
  3. <what can live below the fold>

Interactive elements:
  - <element>: <interaction behavior>
  - <element>: <interaction behavior>

States:
  - Empty state: <what shows when no data>
  - Loading state: <skeleton / spinner / progressive>
  - Error state: <what shows on failure>
  - Success state: <confirmation / redirect>
```

#### Prototype Fidelity Guide
```
PROTOTYPE FIDELITY DECISION:
┌──────────────────────────────────────────────────────────────────────┐
│ Stage              │ Fidelity  │ Tool             │ Purpose          │
├──────────────────────────────────────────────────────────────────────┤
│ Early exploration  │ Low       │ Paper / Balsamiq │ Test structure    │
│ Stakeholder review │ Medium    │ Figma wireframes │ Align on layout  │
│ Usability testing  │ Med-High  │ Figma prototype  │ Test interactions │
│ Dev handoff        │ High      │ Figma + specs    │ Build reference   │
│ Quick validation   │ Code      │ HTML/CSS proto   │ Test in browser   │
└──────────────────────────────────────────────────────────────────────┘

Selected fidelity: <level>
Justification: <why this fidelity for this stage>
```

### Step 6: Design System Adherence
Validate that the design uses established patterns consistently:

```
DESIGN SYSTEM COMPLIANCE:
Design system: <name or "none — creating from scratch">

Token usage:
┌─────────────────────────────────────────────────────────────────────┐
│ Category         │ Token Used │ Custom Value │ Violation │ Status   │
├─────────────────────────────────────────────────────────────────────┤
│ Colors           │ <N>        │ <N>          │ <N>       │ OK/WARN  │
│ Typography       │ <N>        │ <N>          │ <N>       │ OK/WARN  │
│ Spacing          │ <N>        │ <N>          │ <N>       │ OK/WARN  │
│ Border radius    │ <N>        │ <N>          │ <N>       │ OK/WARN  │
│ Shadows          │ <N>        │ <N>          │ <N>       │ OK/WARN  │
│ Iconography      │ <N>        │ <N>          │ <N>       │ OK/WARN  │
└─────────────────────────────────────────────────────────────────────┘

Component reuse:
- [ ] Standard buttons used (no custom one-off button styles)
- [ ] Form inputs use system components (not custom-styled <input>)
- [ ] Modals/dialogs use system dialog component
- [ ] Navigation uses system nav patterns
- [ ] Cards/containers use system layout components
- [ ] Icons from approved icon set (not mixed icon libraries)

Pattern consistency:
- [ ] Same interaction pattern for same action type across all screens
- [ ] Consistent placement of primary/secondary actions
- [ ] Error handling follows one pattern everywhere
- [ ] Empty states follow one pattern everywhere
- [ ] Loading states follow one pattern everywhere
```

If no design system exists, recommend establishing one:
```
MINIMUM VIABLE DESIGN SYSTEM:
1. Color palette: primary, secondary, neutral, semantic (success/warning/error/info)
2. Typography scale: 5-7 sizes with defined weights and line heights
3. Spacing scale: 4px base unit (4, 8, 12, 16, 24, 32, 48, 64)
4. Border radius: 2-3 options (small, medium, large/full)
5. Shadow scale: 3 levels (subtle, medium, elevated)
6. Component patterns: button, input, card, modal, nav, table
7. Layout grid: 12-column with defined gutters and margins
```

### Step 7: Usability Heuristics Evaluation (Nielsen's 10)
Systematically evaluate the design against established usability principles:

```
USABILITY HEURISTICS EVALUATION:
Target: <screen, flow, or full application>
Evaluator: <AI-assisted heuristic review>

┌──────────────────────────────────────────────────────────────────────────┐
│ #  │ Heuristic                        │ Rating │ Issues │ Severity      │
├──────────────────────────────────────────────────────────────────────────┤
│ 1  │ Visibility of system status      │ 0-4    │ <N>    │ <worst sev>   │
│ 2  │ Match between system & real world│ 0-4    │ <N>    │ <worst sev>   │
│ 3  │ User control and freedom         │ 0-4    │ <N>    │ <worst sev>   │
│ 4  │ Consistency and standards        │ 0-4    │ <N>    │ <worst sev>   │
│ 5  │ Error prevention                 │ 0-4    │ <N>    │ <worst sev>   │
│ 6  │ Recognition rather than recall   │ 0-4    │ <N>    │ <worst sev>   │
│ 7  │ Flexibility and efficiency       │ 0-4    │ <N>    │ <worst sev>   │
│ 8  │ Aesthetic and minimalist design  │ 0-4    │ <N>    │ <worst sev>   │
│ 9  │ Help users recover from errors   │ 0-4    │ <N>    │ <worst sev>   │
│ 10 │ Help and documentation           │ 0-4    │ <N>    │ <worst sev>   │
└──────────────────────────────────────────────────────────────────────────┘

Severity scale: 0 = not a problem, 1 = cosmetic, 2 = minor, 3 = major, 4 = catastrophe
```

#### Detailed Heuristic Checks

```
H1 — VISIBILITY OF SYSTEM STATUS:
The system should keep users informed about what is going on through timely feedback.
- [ ] Loading indicators for operations > 1 second
- [ ] Progress bars for multi-step processes
- [ ] Success/failure feedback after every user action
- [ ] Current state clearly indicated (active tab, selected item, current step)
- [ ] Real-time validation on form fields (not just on submit)
- [ ] Upload progress shown with percentage or bar
- [ ] Sync status visible when applicable (saved / saving / offline)
Issues found: <list specific violations>

H2 — MATCH BETWEEN SYSTEM AND REAL WORLD:
The system should speak the users' language with familiar words, phrases, and concepts.
- [ ] Labels use user terminology, not developer or database jargon
- [ ] Icons are universally recognizable (or paired with text labels)
- [ ] Metaphors match real-world expectations (trash can = delete, not archive)
- [ ] Date/time formats match user locale
- [ ] Currency and number formats match user locale
- [ ] Actions named from user perspective ("Save my changes" not "POST /api/save")
Issues found: <list specific violations>

H3 — USER CONTROL AND FREEDOM:
Users need a clear emergency exit to leave unwanted states without extended dialogue.
- [ ] Undo available for destructive actions
- [ ] Cancel button on every form and dialog
- [ ] Back navigation works as expected (browser back, in-app back)
- [ ] Multi-step processes allow going back to previous steps
- [ ] Accidental clicks recoverable (confirmation on delete, undo on archive)
- [ ] Modal dialogs closable via X button, Escape key, and backdrop click
Issues found: <list specific violations>

H4 — CONSISTENCY AND STANDARDS:
Users should not have to wonder whether different words, situations, or actions mean the same thing.
- [ ] Same action, same label everywhere (not "Save" here and "Submit" there)
- [ ] Same icon, same meaning everywhere
- [ ] Platform conventions followed (underlined links, standard form patterns)
- [ ] Visual hierarchy consistent across all screens
- [ ] Interactive element affordances consistent (all clickable things look clickable)
- [ ] Terminology consistent (not "user" on one page and "member" on another)
Issues found: <list specific violations>

H5 — ERROR PREVENTION:
Good design prevents problems from occurring in the first place.
- [ ] Destructive actions require confirmation ("Delete 12 items? This cannot be undone.")
- [ ] Form inputs constrained to valid formats (date pickers, dropdowns, input masks)
- [ ] Disabled states for unavailable actions (grayed out, with tooltip explaining why)
- [ ] Inline validation before submission
- [ ] Smart defaults reduce required decisions
- [ ] Autocomplete and suggestions reduce typing errors
Issues found: <list specific violations>

H6 — RECOGNITION RATHER THAN RECALL:
Minimize user memory load by making objects, actions, and options visible.
- [ ] Recently used items accessible (recent searches, recent files)
- [ ] Form fields have placeholder examples or helper text
- [ ] Tooltips explain non-obvious icons and controls
- [ ] Options visible in dropdowns rather than requiring typed input
- [ ] Breadcrumbs show path taken
- [ ] Dashboard surfaces key information without requiring navigation
Issues found: <list specific violations>

H7 — FLEXIBILITY AND EFFICIENCY OF USE:
Accelerators for expert users without confusing novices.
- [ ] Keyboard shortcuts for frequent actions (with discoverability)
- [ ] Bulk actions for power users (select all, batch edit)
- [ ] Customizable views or layouts (table vs grid, column visibility)
- [ ] Search with filters for large data sets
- [ ] Default settings work for 80% of users; advanced settings available
- [ ] Frequently used actions prominent; rarely used actions accessible but not cluttering
Issues found: <list specific violations>

H8 — AESTHETIC AND MINIMALIST DESIGN:
Every extra unit of information competes with relevant information and diminishes visibility.
- [ ] No unnecessary decoration competing with content
- [ ] Visual hierarchy guides the eye to what matters first
- [ ] White space used to group and separate content
- [ ] Copy is concise — no unnecessary words
- [ ] Only relevant information shown by default (progressive disclosure for details)
- [ ] Data density appropriate for the task (dashboard is dense, onboarding is sparse)
Issues found: <list specific violations>

H9 — HELP USERS RECOGNIZE, DIAGNOSE, AND RECOVER FROM ERRORS:
Error messages in plain language, precisely indicating the problem and constructively suggesting a solution.
- [ ] Error messages name the specific field and problem ("Email address is invalid")
- [ ] Error messages suggest a fix ("Did you mean user@gmail.com?")
- [ ] Error state does not clear user input (user should not have to re-type)
- [ ] Errors displayed inline next to the problematic field
- [ ] System errors give actionable next steps ("Try again" or "Contact support")
- [ ] 404 pages help users navigate back (search, popular links, home link)
Issues found: <list specific violations>

H10 — HELP AND DOCUMENTATION:
Even if the system can be used without documentation, it should provide help that is searchable and task-focused.
- [ ] Onboarding or first-use guidance for new users
- [ ] Contextual help available (tooltips, info icons, inline hints)
- [ ] Documentation searchable
- [ ] Help content task-oriented ("How to export data"), not feature-oriented
- [ ] FAQ or troubleshooting for common issues
- [ ] Contact/support channel accessible from within the app
Issues found: <list specific violations>
```

### Step 8: Accessibility in Design (WCAG Compliance)
Build accessibility into the design from the start, not as an afterthought:

```
DESIGN-LEVEL ACCESSIBILITY AUDIT:
WCAG target: <AA / AAA>

Visual design:
- [ ] Color contrast: all text meets 4.5:1 ratio (3:1 for large text)
- [ ] Color is not the only differentiator (icons, patterns, or text supplement color)
- [ ] Focus states designed and visible (not relying on browser defaults)
- [ ] Touch targets minimum 44x44px on mobile
- [ ] Text resizable to 200% without layout breaking
- [ ] Motion/animation respects prefers-reduced-motion
- [ ] No essential information conveyed only through images

Interaction design:
- [ ] All functionality reachable via keyboard
- [ ] Tab order matches visual reading order
- [ ] Modals trap focus and return focus on close
- [ ] Error messages associated with form fields (not just page-level)
- [ ] Time limits can be extended or removed
- [ ] Auto-playing content can be paused

Content design:
- [ ] Link text is descriptive out of context (not "click here")
- [ ] Heading hierarchy is logical (no skipping levels)
- [ ] Form fields have visible labels (not placeholder-only)
- [ ] Instructions do not rely on sensory attributes alone ("the red button on the left")
- [ ] Language is plain and clear (aim for 8th grade reading level)

Inclusive design considerations:
- [ ] Designs reviewed for color blindness impact (protanopia, deuteranopia, tritanopia)
- [ ] Designs work with OS high contrast mode
- [ ] Designs work with OS large text settings
- [ ] Animations are subtle (no flashing above 3 Hz)
- [ ] Alternative text planned for all meaningful images
```

### Step 9: Mobile-First and Responsive Design
Design for the smallest screen first, then progressively enhance:

```
RESPONSIVE DESIGN STRATEGY:
Approach: <mobile-first / desktop-first / simultaneous>
Target breakpoints:
  Mobile:     320px - 767px
  Tablet:     768px - 1023px
  Desktop:    1024px - 1439px
  Large:      1440px+

MOBILE-FIRST DESIGN CHECKLIST:
Layout:
- [ ] Single-column layout at mobile (no horizontal scrolling)
- [ ] Content stacks vertically at narrow widths
- [ ] Navigation collapses to hamburger or bottom tab bar
- [ ] Cards stack vertically, not side by side
- [ ] Tables convert to card/list layout or scroll horizontally
- [ ] Sidebars become drawers or separate screens

Typography:
- [ ] Base font size >= 16px on mobile (prevents iOS zoom on focus)
- [ ] Line length 45-75 characters on desktop, fluid on mobile
- [ ] Headings scale down proportionally on mobile
- [ ] Body text remains readable without zooming

Touch:
- [ ] All tap targets >= 44x44px
- [ ] Adequate spacing between tap targets (>= 8px gap)
- [ ] No hover-dependent interactions (tooltip content accessible via tap)
- [ ] Swipe gestures have button alternatives
- [ ] Bottom sheet / action sheet for mobile instead of dropdowns

Performance:
- [ ] Images responsive (srcset or picture element)
- [ ] Lazy loading for below-fold images
- [ ] Critical content loads first (above the fold priority)
- [ ] No layout shift as content loads (reserved space for images/ads)

BREAKPOINT BEHAVIOR:
┌───────────────────────────────────────────────────────────────────────┐
│ Component         │ Mobile           │ Tablet          │ Desktop      │
├───────────────────────────────────────────────────────────────────────┤
│ Navigation        │ Hamburger/tabs   │ Collapsed sidebar│ Full sidebar│
│ Content grid      │ 1 column         │ 2 columns       │ 3-4 columns │
│ Data table        │ Card list        │ Horizontal scroll│ Full table  │
│ Sidebar           │ Hidden/drawer    │ Overlay          │ Persistent  │
│ Modal             │ Full screen      │ Centered overlay │ Centered    │
│ Form layout       │ Stacked fields   │ 2-column fields │ 2-column    │
│ Images            │ Full width       │ Constrained      │ Constrained │
│ Search            │ Icon → expand    │ Short bar        │ Full bar    │
└───────────────────────────────────────────────────────────────────────┘
```

### Step 10: A/B Testing Design Variants
When there are competing design approaches, structure testable variants:

```
A/B TEST DESIGN PLAN:
Hypothesis: <changing X will improve Y because Z>
Primary metric: <conversion rate / task completion time / error rate / engagement>
Secondary metrics: <bounce rate, satisfaction score, etc.>

Variants:
┌───────────────────────────────────────────────────────────────────────┐
│ Variant │ Description                    │ Key Difference             │
├───────────────────────────────────────────────────────────────────────┤
│ Control │ Current design                 │ Baseline                   │
│ A       │ <description>                  │ <single change>            │
│ B       │ <description>                  │ <single change>            │
└───────────────────────────────────────────────────────────────────────┘

RULES:
- Test ONE variable per experiment (button color OR copy OR placement — not all three)
- Each variant must be a complete, functional design (not a broken partial)
- Sample size must be statistically significant before drawing conclusions
- Run for minimum 1-2 full business cycles (usually 2 weeks)
- Document the exact design spec for each variant so it can be reproduced

Variant specification:
  Control: <detailed description of current state>
  Variant A: <exact change — be specific about color values, copy, layout>
  Variant B: <exact change>

Measurement plan:
  Tool: <Google Optimize / LaunchDarkly / Optimizely / PostHog / custom>
  Traffic split: <50/50 for two variants, 33/33/34 for three>
  Minimum sample: <N users per variant for statistical significance>
  Duration: <N days/weeks>
  Success threshold: <X% improvement with 95% confidence>
```

### Step 11: Design Handoff to Developers
Package the design for clean developer implementation:

```
DESIGN HANDOFF PACKAGE:
┌──────────────────────────────────────────────────────────────────────┐
│ Deliverable              │ Format           │ Status                 │
├──────────────────────────────────────────────────────────────────────┤
│ Screen designs (all states)│ Figma / images │ <done / in progress>   │
│ Component specifications │ Annotated specs  │ <done / in progress>   │
│ User flow diagrams       │ Flow chart       │ <done / in progress>   │
│ Interaction specs        │ Annotated or doc │ <done / in progress>   │
│ Responsive behavior      │ Breakpoint specs │ <done / in progress>   │
│ Design tokens            │ JSON / CSS vars  │ <done / in progress>   │
│ Asset exports            │ SVG / PNG / icons│ <done / in progress>   │
│ Copy / microcopy         │ Spreadsheet / doc│ <done / in progress>   │
│ Accessibility notes      │ Annotated specs  │ <done / in progress>   │
│ Animation specs          │ Timing / easing  │ <done / in progress>   │
└──────────────────────────────────────────────────────────────────────┘

Per-screen handoff checklist:
- [ ] All interactive states designed (default, hover, focus, active, disabled, loading, error, empty, success)
- [ ] Spacing and sizing annotated in design tokens (not pixel values)
- [ ] Typography specified using token names (not raw font-size/weight)
- [ ] Colors specified using token names (not hex values)
- [ ] Responsive behavior documented for every breakpoint
- [ ] Edge cases documented (long text truncation, missing images, zero-data states)
- [ ] Animations specified with duration, easing, and trigger
- [ ] Accessibility requirements noted (ARIA labels, keyboard behavior, focus management)
- [ ] Copy finalized (no "lorem ipsum" in handoff)
- [ ] Assets exported at required resolutions (1x, 2x, 3x for mobile; SVG preferred for icons)
```

### Step 12: Design Review and Report

```
+------------------------------------------------------------+
|  UX DESIGN REVIEW — <project / feature>                     |
+------------------------------------------------------------+
|  Stage: <discovery / wireframe / prototype / handoff>       |
|  Platform: <web / mobile / cross-platform>                  |
|  Personas: <N> defined                                      |
|  User flows: <N> mapped                                     |
|                                                             |
|  Heuristic Evaluation:                                      |
|  Score: <N>/40 (sum of all heuristic ratings)               |
|  Critical violations: <N>                                   |
|  Major violations: <N>                                      |
|  Minor violations: <N>                                      |
|                                                             |
|  Design System Compliance:                                  |
|  Token usage: <X>%                                          |
|  Component reuse: <X>%                                      |
|  Custom overrides: <N>                                      |
|                                                             |
|  Accessibility:                                             |
|  Contrast compliance: <PASS / FAIL>                         |
|  Keyboard design: <PASS / FAIL>                             |
|  Screen reader readiness: <PASS / FAIL>                     |
|                                                             |
|  Responsive:                                                |
|  Mobile design: <COMPLETE / PARTIAL / MISSING>              |
|  Breakpoint coverage: <N>/<total>                           |
|                                                             |
|  Verdict: <READY FOR DEV | NEEDS REVISION | EARLY STAGE>   |
+------------------------------------------------------------+
|  MUST ADDRESS:                                              |
|  1. <critical issue>                                        |
|  2. <critical issue>                                        |
|                                                             |
|  RECOMMENDED:                                               |
|  3. <improvement>                                           |
|  4. <improvement>                                           |
+------------------------------------------------------------+
```

Verdicts:
- **READY FOR DEV**: All critical flows designed, heuristic violations resolved, accessibility checked, responsive specs complete, handoff package ready.
- **NEEDS REVISION**: Design is close but has critical usability or accessibility issues that will cause rework if built as-is.
- **EARLY STAGE**: Design is conceptual or incomplete. Good for feedback but not ready for implementation.

### Step 13: Commit and Transition
1. If design specs were generated, save: `docs/ux/<feature>-ux-spec.md`
2. Commit: `"uxdesign: <feature> — <verdict> (<N> flows, <N> screens)"`
3. If READY FOR DEV: "Design spec complete. Run `/godmode:ui` for component architecture, or `/godmode:a11y` for detailed accessibility audit."
4. If NEEDS REVISION: "Design has <N> critical issues. Address the MUST ADDRESS items and re-run `/godmode:uxdesign`."
5. If A/B test planned: "Run `/godmode:scaffold` to set up feature flag infrastructure for variant testing."

## Key Behaviors

1. **Start with users, not screens.** Every design decision must trace back to a user need. If you cannot name which persona benefits from a design choice and why, the choice is arbitrary. Personas and flows come before wireframes.
2. **Design all states, not just the happy path.** Empty, loading, error, partial data, long text, first-time use, and returning user states must be designed. Developers will encounter these states whether you design them or not.
3. **Use the design system. Extend it only when justified.** Every custom color, spacing value, or component variant adds maintenance burden. Use existing tokens and components. If the system truly lacks what you need, propose an addition to the system rather than a one-off override.
4. **Mobile-first is a thinking model, not just a CSS strategy.** Starting with the smallest screen forces you to prioritize content and simplify interactions. The mobile design reveals what actually matters. Desktop adds space, not importance.
5. **One variable per test.** A/B tests that change layout, copy, and color simultaneously tell you nothing. Isolate the single variable you are testing. If you need to test multiple variables, run sequential tests.
6. **Handoff is a deliverable, not a conversation.** "Just look at the Figma" is not a handoff. Developers need annotated specs, documented states, responsive behavior, token references, and accessibility notes. Incomplete handoff causes implementation drift.
7. **Heuristic evaluation is cheap validation.** Before spending time on user testing, run a heuristic evaluation. It catches the obvious problems (missing feedback, inconsistent labels, no error prevention) in minutes, saving expensive usability testing sessions for subtle issues.

## Example Usage

### Full UX design review
```
User: /godmode:uxdesign

UXDesign: Analyzing design context...

UX DESIGN CONTEXT:
Project: E-commerce checkout redesign
Stage: Design
Platform: Web (responsive)
Design system: Partial (brand colors and typography defined, components inconsistent)

Running heuristic evaluation...

USABILITY HEURISTICS EVALUATION:
H1 Visibility of system status:       3/4 — checkout progress bar missing
H2 Match between system & real world:  4/4 — clear language
H3 User control and freedom:           2/4 — no back button in checkout, no undo on remove
H4 Consistency and standards:          2/4 — "Add to cart" vs "Buy" vs "Purchase" used interchangeably
H5 Error prevention:                   3/4 — address validation present, payment validation missing
H6 Recognition rather than recall:     3/4 — saved addresses available but not defaulted
H7 Flexibility and efficiency:         2/4 — no express checkout, no saved payment methods
H8 Aesthetic and minimalist design:    3/4 — checkout clean but cart page cluttered
H9 Help users recover from errors:     1/4 — payment errors show generic "something went wrong"
H10 Help and documentation:            3/4 — FAQ exists but not contextual

Score: 26/40
Critical violations: 2 (H3 no back navigation, H9 generic errors)
Major violations: 3 (H4 inconsistent labels, H7 no express checkout, H9 payment errors)

MUST ADDRESS:
1. Add back navigation in checkout flow (H3)
2. Replace generic error messages with specific ones (H9)
3. Standardize action labels to "Add to cart" everywhere (H4)

Verdict: NEEDS REVISION — 2 critical issues will cause user drop-off.
```

### User flow mapping
```
User: /godmode:uxdesign --flow "password reset"

UXDesign: Mapping password reset flow...

USER FLOW: Password Reset
Persona: Returning User (Sarah, non-technical)
Trigger: User cannot remember password on login page
Goal: Regain account access
Success metric: Reset completion rate (target: > 85%)

Steps:
1. Login page → clicks "Forgot password?" → Reset request form
2. Reset form → enters email → Confirmation page + email sent
3. Email → clicks reset link → New password form
4. New password form → enters new password → Success + auto-login

Decision points:
  Step 2 → email not found → show same confirmation (prevent enumeration)
  Step 3 → link expired → offer resend with prefilled email
  Step 4 → password too weak → inline validation with strength indicator

Drop-off risks:
  Step 2: User types wrong email → add "Check your email address" confirmation
  Step 3: Email delayed → show "Check spam folder, resend in 60 seconds"
  Step 4: Password requirements unclear → show requirements before user types

Flow complexity: 4 steps → GOOD
```

### Mobile-first design review
```
User: /godmode:uxdesign --mobile

UXDesign: Running mobile-first design review...

RESPONSIVE DESIGN AUDIT:
Breakpoints defined: 320px, 768px, 1024px, 1440px

Issues found:
1. Navigation: Desktop nav has 8 items — at mobile only 3 fit. Need priority+ menu pattern.
2. Data table on /reports: No mobile layout defined. Will cause horizontal scroll.
3. Modal: 600px wide fixed — will overflow at 320px. Use full-screen modal on mobile.
4. Touch targets: "Edit" and "Delete" buttons are 24x24px. Must be >= 44x44px.
5. Form: Two-column layout at all sizes. Must stack to single column on mobile.

MUST ADDRESS:
1. Design mobile navigation pattern (bottom tabs or hamburger with priority items)
2. Define card-list alternative for data tables below 768px
3. Set modal to full-screen below 768px
4. Increase action button touch targets to 44x44px
5. Stack form fields to single column below 768px

Verdict: NEEDS REVISION — mobile experience has 5 layout issues.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full UX design review (heuristics + accessibility + responsive + system compliance) |
| `--persona` | Create or review user personas |
| `--flow <name>` | Map a specific user flow |
| `--wireframe <screen>` | Generate wireframe specification for a screen |
| `--heuristics` | Run Nielsen's 10 heuristics evaluation only |
| `--ia` | Information architecture and navigation review only |
| `--mobile` | Mobile-first and responsive design audit only |
| `--handoff` | Generate design handoff package checklist |
| `--a11y-design` | Accessibility-in-design audit (design-level, not code-level) |
| `--ab-test <feature>` | Structure an A/B test for a design variant |
| `--system-check` | Design system adherence audit only |
| `--critique <screen>` | Focused design critique on a specific screen or component |

## HARD RULES

1. NEVER design screens without defining user flows first. Screens without flows are disconnected pictures that miss transitions, error paths, and edge cases.
2. NEVER hand off designs with placeholder text ("lorem ipsum"). Developers will ship it. Finalize copy before handoff.
3. ALWAYS design all interactive states: default, hover, focus, active, disabled, loading, error, empty, and success. An incomplete state matrix guarantees inconsistent implementation.
4. NEVER specify colors or typography with raw values (hex, px). Use design tokens. Raw values drift from the design system and create maintenance debt.
5. ALWAYS validate designs against WCAG 2.1 AA contrast ratios (4.5:1 for text, 3:1 for large text and UI components) before handoff. Accessibility retrofits cost 10x more than designing it in.
6. NEVER design only the happy path. A form with no error states, a list with no empty state, a page with no loading skeleton are incomplete deliverables.
7. ALWAYS document responsive behavior for every breakpoint in the design system. "It works on mobile" is not a responsive specification.
8. NEVER skip usability testing with real users. Heuristic evaluation catches structural issues; only real users reveal actual confusion, hesitation, and workarounds.

## Anti-Patterns

- **Do NOT design screens without defining user flows first.** Screens without flows are disconnected pictures. You will miss transitions, error paths, edge cases, and the actual user journey. Map the flow, then design the screens that support it.
- **Do NOT use placeholder text in handoff designs.** "Lorem ipsum" in a handoff guarantees that developers will ship placeholder text to production, or guess at copy that does not match the product voice. Finalize copy before handoff.
- **Do NOT design only the happy path.** A form with no error states, a list with no empty state, a page with no loading state — these are incomplete designs. Developers will improvise, and the result will be inconsistent.
- **Do NOT skip mobile design and say "it will be responsive."** Responsive CSS handles layout reflow, not design decisions. Choosing which content to prioritize, how navigation changes, and what interactions shift for touch requires explicit design.
- **Do NOT test multiple variables in one A/B test.** Changing the CTA color, copy, and position simultaneously means you learn nothing about which change caused the result. One variable per test. Always.
- **Do NOT hand off designs without state documentation.** Hover, focus, active, disabled, loading, error, empty, and success states must be specified. If developers have to guess, every developer will guess differently.
- **Do NOT ignore the design system to "move fast."** One-off colors, custom spacing, and unique component variants create visual debt that compounds. The 5 minutes saved now costs 5 hours in future inconsistency fixes.
- **Do NOT treat usability heuristics as optional.** A 10-minute heuristic evaluation catches problems that would take 2 hours to find in user testing and 20 hours to fix after development. Do the evaluation.
- **Do NOT design for yourself.** Your tech literacy, screen size, visual acuity, and motor skills are not representative of your users. Design for the persona with the lowest capability in your user base, and everyone benefits.
