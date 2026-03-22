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
Issues detected: <N>
```
### Step 2: Responsive Layout Strategy
Choose and implement the right layout strategy:

#### Strategy Comparison
```
LAYOUT STRATEGY COMPARISON:
| Strategy | Description | Best For |
|--|--|--|
| Fluid | Percentage/relative units | Simple layouts, text-heavy |
|  | Scales continuously | Content sites, blogs |
│               │                          │                               │
```

#### Mobile-First Breakpoint System
```css
/* breakpoints.css — Mobile-first (min-width) */
:root {
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
```

#### Desktop-First Breakpoint System
```css
/* breakpoints-desktop-first.css — Desktop-first (max-width) */

/* Base styles: desktop */
.sidebar-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
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
```

#### Subgrid for Alignment
```css
/* Subgrid — align child elements across grid items */
.card-grid {
  display: grid; /* parent grid for subgrid alignment */
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-6);
}
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

```

#### Container Query Units
```css
/* Size relative to container, not viewport */
.card__title {
  font-size: clamp(1rem, 3cqi, 1.5rem);  /* cqi = container query inline */
}

.card__image {
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
```

#### Holy Grail Layout
```css
/* Classic responsive layout: header, footer, sidebar, content */
.layout {
  display: flex; /* column-based holy grail layout */
  flex-direction: column;
  min-height: 100dvh;
}
```

#### Flexbox Wrapping Cards
```css
/* Cards that wrap and fill available space */
.card-row {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-4);
}
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
```

#### Fluid Spacing
```css
:root {
  --fluid-space-xs: clamp(0.25rem, 0.2rem + 0.25vw, 0.5rem);
  --fluid-space-sm: clamp(0.5rem, 0.4rem + 0.5vw, 0.75rem);
  --fluid-space-md: clamp(1rem, 0.8rem + 1vw, 1.5rem);
  --fluid-space-lg: clamp(1.5rem, 1rem + 2.5vw, 3rem);
  --fluid-space-xl: clamp(2rem, 1rem + 5vw, 5rem);
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
```

#### Art Direction with <picture>
```html
<!-- Different images for different viewports (crop, composition) -->
<picture>
  <!-- Mobile: tight crop, portrait -->
  <source
    media="(max-width: 639px)"
    srcset="hero-mobile-400.jpg 400w, hero-mobile-800.jpg 800w"
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
```

#### Touch-Specific Behaviors
```css
/* Prevent unwanted touch behaviors */
.interactive-canvas {
  touch-action: none; /* Full custom gesture handling */
}

.horizontal-scroll {
```

### Step 10: Responsive Data Tables
Handle tables that don't fit on small screens:

#### Stack Pattern (Cards on Mobile)
```css
/* Desktop: regular table | Mobile: stacked cards */
@media (max-width: 767px) {
  .responsive-table thead {
    display: none; /* Hide header on mobile */
  }

```

### Step 11: Responsive Audit Report

```
RESPONSIVE DESIGN AUDIT:
  Breakpoints
  Strategy: <mobile-first / desktop-first / intrinsic>
  Defined: <list breakpoints>
  Consistent: YES / NO
  Layout Techniques
  CSS Grid: <N> usages
  Flexbox: <N> usages
  ...
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
## Flags & Options

| Flag | Description |
|--|--|
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

  ...
```
## Output Format

After each responsive skill invocation, emit a structured report:

```
RESPONSIVE AUDIT REPORT:
| Pages audited | <N> |
|--|--|
| Breakpoints tested | 320, 375, 768, 1024, 1280, 1536 |
| Layout issues | <N> found / <N> fixed |
| Image optimization | <N> images with srcset/sizes |
| Touch targets | <N> below 44px / <N> fixed |
| CLS score | <N> (target < 0.1) |
| Typography | fluid (clamp): YES / NO |

## TSV Logging

  ...
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
## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
  - Max iterations reached — report partial results with remaining items listed

DO NOT STOP only because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (handle that in a follow-up pass)
```

## Error Recovery
| Failure | Action |
|--|--|
| Layout breaks at specific breakpoint | Check for fixed widths. Use `max-width` instead of `width`. Test at breakpoint boundaries (e.g., 767px and 768px). |
| Images overflow container on mobile | Add `max-width: 100%; height: auto;` to all images. Use `object-fit: cover` for background images. |
| Touch targets too small on mobile | Minimum 44x44px touch targets (WCAG). Add padding to clickable elements. Increase spacing between adjacent targets. |
| Horizontal scroll on mobile | Find the overflowing element with DevTools. Check for `width` > 100vw, unbreaking text, or fixed-width tables. |
