---
name: responsive
description: |
  Responsive and adaptive design skill. Activates when user needs to build responsive layouts using CSS Grid, Flexbox, container queries, and fluid typography. Covers mobile-first vs desktop-first strategies, responsive images with art direction, print stylesheets, and touch vs pointer interactions. Triggers on: /godmode:responsive, "responsive design", "mobile-first", "container queries", "responsive layout", "adaptive design", or when building interfaces that must work across breakpoints.
---

# Responsive — Responsive & Adaptive Design

## When to Activate
- User invokes `/godmode:responsive`
- User says "responsive design," "mobile-first," "make it responsive," "container queries"
- When building layouts that must work across phone, tablet, and desktop
- When implementing CSS Grid or Flexbox-based responsive layouts
- When configuring responsive images with art direction
- When adding print stylesheets
- When handling touch vs pointer interactions
- When auditing an existing site for responsive issues

## Workflow

### Step 1: Assess Responsive Requirements
Determine the target devices, breakpoints, and layout strategy:

```
RESPONSIVE REQUIREMENTS:
Project: <project name>
Framework: <React/Vue/Angular/vanilla>
CSS approach: <Tailwind/CSS Modules/SCSS/CSS-in-JS>

Target devices:
  Mobile (portrait):   320px - 480px
    # ... (condensed)
Issues detected: <N>
```

### Step 2: Responsive Layout Strategy
Choose and implement the right layout strategy:

#### Strategy Comparison
```
LAYOUT STRATEGY COMPARISON:
┌──────────────────────────────────────────────────────────────────────────┐
│ Strategy      │ Description              │ Best For                      │
├──────────────────────────────────────────────────────────────────────────┤
│ Fluid         │ Percentage/relative units │ Simple layouts, text-heavy    │
│               │ Scales continuously       │ Content sites, blogs          │
│               │                          │                               │
    # ... (condensed)
└──────────────────────────────────────────────────────────────────────────┘
```

#### Mobile-First Breakpoint System
```css
/* breakpoints.css — Mobile-first (min-width) */
:root {
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
# ... (condensed)
```

#### Desktop-First Breakpoint System
```css
/* breakpoints-desktop-first.css — Desktop-first (max-width) */

/* Base styles: desktop */
.sidebar-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
# ... (condensed)
```

### Step 3: CSS Grid Mastery
Implement responsive grid layouts:

#### Responsive Auto-Fit Grid
```css
/* The most useful responsive pattern — auto-fitting cards */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: var(--spacing-6);
}
# ... (condensed)
```

#### Subgrid for Alignment
```css
/* Subgrid — align child elements across grid items */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-6);
}
# ... (condensed)
```

### Step 4: Container Queries
Implement component-level responsive design:

#### Container Query Fundamentals
```css
/* Define containment context */
.card-container {
  container-type: inline-size;
  container-name: card;
}

# ... (condensed)
```

#### Container Query Units
```css
/* Size relative to container, not viewport */
.card__title {
  font-size: clamp(1rem, 3cqi, 1.5rem);  /* cqi = container query inline */
}

.card__image {
# ... (condensed)
```

#### Container Query + Grid Pattern
```css
/* Sidebar component that adapts to its container */
.sidebar-widget {
  container-type: inline-size;
}

.widget-list {
# ... (condensed)
```

### Step 5: Flexbox Patterns
Essential Flexbox patterns for responsive layouts:

#### Responsive Navigation
```css
/* Mobile: stacked hamburger | Desktop: horizontal nav */
.nav {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--spacing-2);
# ... (condensed)
```

#### Holy Grail Layout
```css
/* Classic responsive layout: header, footer, sidebar, content */
.layout {
  display: flex;
  flex-direction: column;
  min-height: 100dvh;
}
# ... (condensed)
```

#### Flexbox Wrapping Cards
```css
/* Cards that wrap and fill available space */
.card-row {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-4);
}
# ... (condensed)
```

### Step 6: Fluid Typography and Spacing
Implement continuously scaling typography:

#### Fluid Type Scale with clamp()
```css
:root {
  /* fluid-type(min-size, max-size, min-viewport, max-viewport) */
  --fluid-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
  --fluid-sm: clamp(0.875rem, 0.8rem + 0.375vw, 1rem);
  --fluid-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --fluid-lg: clamp(1.125rem, 0.95rem + 0.875vw, 1.5rem);
# ... (condensed)
```

#### Fluid Spacing
```css
:root {
  --fluid-space-xs: clamp(0.25rem, 0.2rem + 0.25vw, 0.5rem);
  --fluid-space-sm: clamp(0.5rem, 0.4rem + 0.5vw, 0.75rem);
  --fluid-space-md: clamp(1rem, 0.8rem + 1vw, 1.5rem);
  --fluid-space-lg: clamp(1.5rem, 1rem + 2.5vw, 3rem);
  --fluid-space-xl: clamp(2rem, 1rem + 5vw, 5rem);
# ... (condensed)
```

### Step 7: Responsive Images and Art Direction
Optimize images for every viewport:

#### srcset for Resolution Switching
```html
<!-- Same image, different resolutions -->
<img
  src="hero-800.jpg"
  srcset="
    hero-400.jpg 400w,
    hero-800.jpg 800w,
# ... (condensed)
```

#### Art Direction with <picture>
```html
<!-- Different images for different viewports (crop, composition) -->
<picture>
  <!-- Mobile: tight crop, portrait -->
  <source
    media="(max-width: 639px)"
    srcset="hero-mobile-400.jpg 400w, hero-mobile-800.jpg 800w"
# ... (condensed)
```

#### Modern Image Formats
```html
<!-- Serve modern formats with fallback -->
<picture>
  <source type="image/avif" srcset="photo.avif" />
  <source type="image/webp" srcset="photo.webp" />
  <img src="photo.jpg" alt="Product photo" loading="lazy" />
</picture>
```

#### Responsive CSS Background Images
```css
.hero {
  background-image: url('hero-mobile.jpg');
  background-size: cover;
  background-position: center;
  aspect-ratio: 4 / 3;
}
# ... (condensed)
```

### Step 8: Print Stylesheets
Ensure content prints well:

```css
/* print.css */
@media print {
  /* Reset backgrounds and colors for ink conservation */
  * {
    background: white !important;
    color: black !important;
# ... (condensed)
```

### Step 9: Touch vs Pointer Interactions
Handle differences between touch, mouse, and stylus input:

#### Pointer Media Queries
```css
/* Fine pointer (mouse, trackpad, stylus) */
@media (pointer: fine) {
  .button {
    padding: var(--spacing-2) var(--spacing-4);
    min-height: auto;
  }
# ... (condensed)
```

#### Touch-Specific Behaviors
```css
/* Prevent unwanted touch behaviors */
.interactive-canvas {
  touch-action: none; /* Full custom gesture handling */
}

.horizontal-scroll {
# ... (condensed)
```

#### Responsive Interaction Patterns
```typescript
// hooks/usePointerType.ts — Detect pointer type at runtime
import { useState, useEffect } from 'react';

export function usePointerType(): 'fine' | 'coarse' | 'none' {
  const [pointer, setPointer] = useState<'fine' | 'coarse' | 'none'>(() => {
    if (typeof window === 'undefined') return 'fine';
# ... (condensed)
```

### Step 10: Responsive Data Tables
Handle tables that don't fit on small screens:

#### Horizontal Scroll Pattern
```css
/* Simplest: wrap table in scrollable container */
.table-wrapper {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
# ... (condensed)
```

#### Stack Pattern (Cards on Mobile)
```css
/* Desktop: regular table | Mobile: stacked cards */
@media (max-width: 767px) {
  .responsive-table thead {
    display: none; /* Hide header on mobile */
  }

# ... (condensed)
```

### Step 11: Responsive Audit Report

```
RESPONSIVE DESIGN AUDIT:
┌──────────────────────────────────────────────────────────────┐
│ Breakpoints                                                   │
│   Strategy: <mobile-first / desktop-first / intrinsic>        │
│   Defined: <list breakpoints>                                 │
│   Consistent: YES / NO                                        │
│                                                               │
│ Layout Techniques                                             │
│   CSS Grid: <N> usages                                        │
│   Flexbox: <N> usages                                         │
│   Container queries: <N> usages                               │
│   Float (legacy): <N> usages — MIGRATE                        │
│   Absolute positioning for layout: <N> — MIGRATE              │
│                                                               │
│ Viewport Testing                                              │
│   320px (small mobile):  PASS / FAIL (<N> issues)             │
│   375px (iPhone):        PASS / FAIL (<N> issues)             │
    # ... (condensed)
└──────────────────────────────────────────────────────────────┘
```

Scoring:
- Layout techniques (Grid/Flex/Container queries): 0-25 points
- Viewport testing (all breakpoints pass): 0-25 points
- Images (srcset, art direction, formats): 0-15 points
- Typography (fluid, readable): 0-10 points
- Touch / pointer handling: 0-10 points
- Print stylesheet: 0-5 points
- No common issues (overflow, small text, tiny targets): 0-10 points

### Step 12: Commit and Transition
1. If responsive layouts were built: `"responsive: implement responsive layout with Grid + container queries"`
2. If images were optimized: `"responsive: add srcset and art direction for responsive images"`
3. If print stylesheet was added: `"responsive: add print stylesheet with page break controls"`
4. If audit was completed: Save report at `docs/responsive/<project>-responsive-audit.md`
5. Transition: "Responsive design complete. Run `/godmode:a11y` for accessibility, `/godmode:perf` for performance, or `/godmode:visual` for visual regression testing."

## Key Behaviors

1. **Mobile-first is the default.** Start with the smallest viewport. Add complexity with `min-width` media queries. Mobile-first forces you to prioritize content, which produces better designs at every size.
2. **Container queries are the future.** Components should respond to their container, not the viewport. A card in a sidebar and a card in the main content area have different space. Container queries make components truly reusable.
3. **CSS Grid for layout, Flexbox for alignment.** Grid is for 2D page-level layout (rows and columns). Flexbox is for 1D component-level alignment (a row of buttons, a nav bar). Using the right tool simplifies the code.
4. **Fluid typography eliminates breakpoints.** `clamp(1rem, 0.9rem + 0.5vw, 1.125rem)` scales smoothly between mobile and desktop. No media queries needed for type. Fewer breakpoints means less code and fewer edge cases.
5. **Images are the biggest responsive problem.** An unoptimized 2400px hero image on a 320px phone wastes bandwidth. Use `srcset` for resolution switching, `<picture>` for art direction, and modern formats (avif, webp) with fallbacks.
6. **Size touch targets at least 44x44px.** WCAG 2.5.5 requires minimum 44x44 CSS pixels. On touch devices, users cannot aim a 1px cursor. Size buttons, links, and interactive elements large enough to tap without mis-tapping.
7. **Print is a viewport too.** If users will print the content (articles, invoices, reports, documentation), add a print stylesheet. Hide navigation, show link URLs, control page breaks, and ensure readability in black and white.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full responsive design — build or audit |
| `--audit` | Audit existing site for responsive issues |
| `--grid` | CSS Grid layout implementation |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check for CSS framework: tailwind.config, bootstrap, bulma, chakra-ui in package.json
2. Detect CSS methodology: grep for BEM (--), CSS Modules (.module.css), styled-components, Emotion
3. Check for existing breakpoints: grep for @media, @container in CSS/SCSS files
4. Detect preprocessor: .scss, .less, .styl files, postcss.config
5. Check for responsive images: grep for srcset, sizes, <picture> in templates/JSX
6. Detect viewport meta tag: grep for viewport in index.html, _document, layout

## Iterative Responsive Implementation Loop

```
current_iteration = 0
max_iterations = 10
pages_remaining = [list of pages/components to make responsive]

WHILE pages_remaining is not empty AND current_iteration < max_iterations:
    page = pages_remaining.pop(0)
    1. Audit at 5 viewports: 320px, 375px, 768px, 1024px, 1440px

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER use px for font-size. Use rem + clamp() for fluid scaling.
2. NEVER use fixed pixel widths on layout containers. Use max-width + fluid units.
3. NEVER hide content on mobile as a responsive strategy. Restructure, don't hide.
4. EVERY image must have srcset + sizes OR be an SVG. No single-resolution raster images.
5. EVERY interactive element must have a minimum 44x44px touch target.
6. NEVER mix min-width and max-width media queries. Pick one direction (mobile-first = min-width).
7. TEST EVERY page at 320px minimum width. No horizontal overflow allowed.
8. NEVER use viewport units for font-size without clamp(). Unbound vw = unreadable text.
9. EVERY layout must work without JavaScript. CSS-only responsive behavior.
10. ALWAYS set explicit width and height (or aspect-ratio) on images/video to prevent CLS.
```

## Output Format

After each responsive skill invocation, emit a structured report:

```
RESPONSIVE AUDIT REPORT:
┌──────────────────────────────────────────────────────┐
│  Pages audited      │  <N>                            │
│  Breakpoints tested │  320, 375, 768, 1024, 1280, 1536│
│  Layout issues      │  <N> found / <N> fixed          │
│  Image optimization │  <N> images with srcset/sizes   │
│  Touch targets      │  <N> below 44px / <N> fixed     │
│  CLS score          │  <N> (target < 0.1)             │
│  Typography         │  fluid (clamp): YES / NO        │

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	skill	page	viewport	issue_type	element	before	after	status
2026-03-20T14:00:00Z	responsive	/home	320px	overflow	.hero-img	overflow-x	contained	fixed
2026-03-20T14:01:00Z	responsive	/pricing	768px	touch_target	.cta-btn	32px	48px	fixed
```

## Success Criteria

The responsive skill is complete when ALL of the following are true:
1. No horizontal overflow at any viewport from 320px to 1536px
2. All images use srcset + sizes or are SVG (no single-resolution raster images)
3. All interactive elements have minimum 44x44px touch targets
4. Typography uses clamp() or responsive units (no fixed px font sizes)
5. Layout uses CSS Grid and/or Flexbox (no float-based layouts)
6. CLS < 0.1 (all images/video have explicit width/height or aspect-ratio)
7. Media queries use consistent direction (mobile-first = min-width only)
8. Pages tested and passing at 320px, 375px, 768px, 1024px, 1280px, and 1536px

## Keep/Discard Discipline
```
After EACH implementation or optimization change:
  1. MEASURE: Run tests / validate the change produces correct output.
  2. COMPARE: Is the result better than before? (faster, safer, more correct)
  3. DECIDE:
     - KEEP if: tests pass AND quality improved AND no regressions introduced
     - DISCARD if: tests fail OR performance regressed OR new errors introduced
  4. COMMIT kept changes with descriptive message. Revert discarded changes before proceeding.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
  - Max iterations reached — report partial results with remaining items listed

DO NOT STOP just because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (handle that in a follow-up pass)
```


## Error Recovery
| Failure | Action |
|---------|--------|
| Layout breaks at specific breakpoint | Check for fixed widths. Use `max-width` instead of `width`. Test at breakpoint boundaries (e.g., 767px and 768px). |
| Images overflow container on mobile | Add `max-width: 100%; height: auto;` to all images. Use `object-fit: cover` for background images. |
| Touch targets too small on mobile | Minimum 44x44px touch targets (WCAG). Add padding to clickable elements. Increase spacing between adjacent targets. |
| Horizontal scroll on mobile | Find the overflowing element with DevTools. Check for `width` > 100vw, unbreaking text, or fixed-width tables. |
