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
  Mobile (landscape):  481px - 767px
  Tablet (portrait):   768px - 1023px
  Tablet (landscape):  1024px - 1279px
  Desktop:             1280px - 1535px
  Large desktop:       1536px+

Strategy: <mobile-first / desktop-first / intrinsic>
Current state: <responsive / partially responsive / desktop-only>

Key layouts:
  - Navigation: <hamburger/sidebar/topbar>
  - Content grid: <1-col mobile, 2-col tablet, 3-col desktop>
  - Data tables: <scroll/stack/hide columns>
  - Forms: <single column / multi-column>
  - Images: <fluid / art direction / srcset>

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
│ Adaptive      │ Fixed layouts per         │ Complex apps with specific    │
│               │ breakpoint, snaps at      │ layouts per device category   │
│               │ each breakpoint           │                               │
│               │                          │                               │
│ Intrinsic     │ Components define own     │ Component libraries, design   │
│               │ responsive behavior via   │ systems, reusable layouts     │
│               │ container queries + clamp │                               │
│               │                          │                               │
│ Mobile-first  │ Base = mobile, add        │ Content-first sites, most     │
│               │ complexity with min-width │ web apps, progressive         │
│               │                          │ enhancement                   │
│               │                          │                               │
│ Desktop-first │ Base = desktop, simplify  │ Admin dashboards, enterprise  │
│               │ with max-width            │ tools primarily used on       │
│               │                          │ desktop                       │
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
  --breakpoint-2xl: 1536px;
}

/* Base styles: mobile (< 640px) */
.container {
  width: 100%;
  padding-inline: var(--spacing-4);
  margin-inline: auto;
}

/* Small screens and up */
@media (min-width: 640px) {
  .container { max-width: 640px; }
}

/* Medium screens and up */
@media (min-width: 768px) {
  .container { max-width: 768px; }
}

/* Large screens and up */
@media (min-width: 1024px) {
  .container { max-width: 1024px; }
}

/* Extra large screens and up */
@media (min-width: 1280px) {
  .container { max-width: 1280px; }
}

/* 2XL screens and up */
@media (min-width: 1536px) {
  .container { max-width: 1536px; }
}
```

#### Desktop-First Breakpoint System
```css
/* breakpoints-desktop-first.css — Desktop-first (max-width) */

/* Base styles: desktop */
.sidebar-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: var(--spacing-6);
}

/* Tablet and below: stack */
@media (max-width: 1023px) {
  .sidebar-layout {
    grid-template-columns: 1fr;
  }
}

/* Mobile: tighten spacing */
@media (max-width: 767px) {
  .sidebar-layout {
    gap: var(--spacing-3);
  }
}
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

/* Named grid areas for complex layouts */
.dashboard {
  display: grid;
  gap: var(--spacing-4);
  grid-template-areas:
    "header"
    "stats"
    "chart"
    "table"
    "sidebar";
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .dashboard {
    grid-template-areas:
      "header  header"
      "stats   stats"
      "chart   sidebar"
      "table   sidebar";
    grid-template-columns: 1fr 300px;
  }
}

@media (min-width: 1280px) {
  .dashboard {
    grid-template-areas:
      "header  header   header"
      "stats   stats    sidebar"
      "chart   chart    sidebar"
      "table   table    sidebar";
    grid-template-columns: 1fr 1fr 320px;
  }
}

.dashboard__header  { grid-area: header; }
.dashboard__stats   { grid-area: stats; }
.dashboard__chart   { grid-area: chart; }
.dashboard__table   { grid-area: table; }
.dashboard__sidebar { grid-area: sidebar; }
```

#### Subgrid for Alignment
```css
/* Subgrid — align child elements across grid items */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-6);
}

.card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3; /* header, body, footer aligned across cards */
}

.card__header { /* Aligns with other cards' headers */ }
.card__body   { /* Aligns with other cards' bodies */ }
.card__footer { /* Aligns with other cards' footers */ }
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

/* Component responds to its container, not viewport */
.card {
  display: flex;
  flex-direction: column;
  padding: var(--spacing-3);
}

/* When container is wider than 400px, go horizontal */
@container card (min-width: 400px) {
  .card {
    flex-direction: row;
    align-items: center;
    gap: var(--spacing-4);
  }

  .card__image {
    width: 200px;
    flex-shrink: 0;
  }
}

/* When container is wider than 600px, add extra details */
@container card (min-width: 600px) {
  .card__meta {
    display: flex;
    gap: var(--spacing-2);
  }

  .card__actions {
    margin-left: auto;
  }
}
```

#### Container Query Units
```css
/* Size relative to container, not viewport */
.card__title {
  font-size: clamp(1rem, 3cqi, 1.5rem);  /* cqi = container query inline */
}

.card__image {
  width: min(100%, 40cqi);
}
```

#### Container Query + Grid Pattern
```css
/* Sidebar component that adapts to its container */
.sidebar-widget {
  container-type: inline-size;
}

.widget-list {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--spacing-2);
}

@container (min-width: 300px) {
  .widget-list {
    grid-template-columns: repeat(2, 1fr);
  }
}

@container (min-width: 500px) {
  .widget-list {
    grid-template-columns: repeat(3, 1fr);
  }
}
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
}

.nav__brand {
  flex: 1;
}

.nav__toggle {
  display: block;
}

.nav__menu {
  flex-basis: 100%;
  display: none;
}

.nav__menu[data-open="true"] {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-1);
}

@media (min-width: 768px) {
  .nav__toggle {
    display: none;
  }

  .nav__menu {
    display: flex;
    flex-direction: row;
    flex-basis: auto;
    gap: var(--spacing-4);
  }
}
```

#### Holy Grail Layout
```css
/* Classic responsive layout: header, footer, sidebar, content */
.layout {
  display: flex;
  flex-direction: column;
  min-height: 100dvh;
}

.layout__main {
  display: flex;
  flex: 1;
  flex-direction: column;
}

.layout__content {
  flex: 1;
  padding: var(--spacing-4);
}

.layout__sidebar {
  padding: var(--spacing-4);
  background: var(--color-surface);
}

@media (min-width: 1024px) {
  .layout__main {
    flex-direction: row;
  }

  .layout__sidebar {
    width: 280px;
    flex-shrink: 0;
  }
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

.card-row > * {
  flex: 1 1 300px; /* Grow, shrink, minimum 300px */
  max-width: 100%;
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
  --fluid-xl: clamp(1.25rem, 0.95rem + 1.5vw, 2rem);
  --fluid-2xl: clamp(1.5rem, 0.9rem + 3vw, 3rem);
  --fluid-3xl: clamp(2rem, 1rem + 5vw, 4rem);
}

h1 { font-size: var(--fluid-3xl); }
h2 { font-size: var(--fluid-2xl); }
h3 { font-size: var(--fluid-xl); }
body { font-size: var(--fluid-base); }
.caption { font-size: var(--fluid-sm); }
```

#### Fluid Spacing
```css
:root {
  --fluid-space-xs: clamp(0.25rem, 0.2rem + 0.25vw, 0.5rem);
  --fluid-space-sm: clamp(0.5rem, 0.4rem + 0.5vw, 0.75rem);
  --fluid-space-md: clamp(1rem, 0.8rem + 1vw, 1.5rem);
  --fluid-space-lg: clamp(1.5rem, 1rem + 2.5vw, 3rem);
  --fluid-space-xl: clamp(2rem, 1rem + 5vw, 5rem);
}

.section {
  padding-block: var(--fluid-space-xl);
  padding-inline: var(--fluid-space-md);
}

.card {
  padding: var(--fluid-space-md);
  gap: var(--fluid-space-sm);
}
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
    hero-1200.jpg 1200w,
    hero-1600.jpg 1600w
  "
  sizes="
    (max-width: 640px) 100vw,
    (max-width: 1024px) 80vw,
    60vw
  "
  alt="Dashboard overview showing analytics charts"
  loading="lazy"
  decoding="async"
/>
```

#### Art Direction with <picture>
```html
<!-- Different images for different viewports (crop, composition) -->
<picture>
  <!-- Mobile: tight crop, portrait -->
  <source
    media="(max-width: 639px)"
    srcset="hero-mobile-400.jpg 400w, hero-mobile-800.jpg 800w"
    sizes="100vw"
  />
  <!-- Tablet: medium crop -->
  <source
    media="(max-width: 1023px)"
    srcset="hero-tablet-800.jpg 800w, hero-tablet-1200.jpg 1200w"
    sizes="80vw"
  />
  <!-- Desktop: full width, landscape -->
  <source
    srcset="hero-desktop-1200.jpg 1200w, hero-desktop-1600.jpg 1600w, hero-desktop-2400.jpg 2400w"
    sizes="60vw"
  />
  <img
    src="hero-desktop-1200.jpg"
    alt="Team collaboration workspace"
    loading="eager"
    fetchpriority="high"
  />
</picture>
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

@media (min-width: 768px) {
  .hero {
    background-image: url('hero-tablet.jpg');
    aspect-ratio: 16 / 9;
  }
}

@media (min-width: 1280px) {
  .hero {
    background-image: url('hero-desktop.jpg');
    aspect-ratio: 21 / 9;
  }
}

/* Serve high-DPI images to retina displays */
@media (min-resolution: 2dppx) {
  .hero {
    background-image: url('hero-mobile@2x.jpg');
  }
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
    box-shadow: none !important;
    text-shadow: none !important;
  }

  /* Hide non-essential elements */
  nav,
  .sidebar,
  .footer,
  .breadcrumb,
  .pagination,
  .social-share,
  button:not(.print-button),
  [role="navigation"],
  [role="complementary"],
  .no-print {
    display: none !important;
  }

  /* Show full URLs for links */
  a[href^="http"]::after {
    content: " (" attr(href) ")";
    font-size: 0.8em;
    font-weight: normal;
    color: #666 !important;
  }

  /* Internal links: don't show URL */
  a[href^="#"]::after,
  a[href^="/"]::after {
    content: none;
  }

  /* Page breaks */
  h1, h2, h3 {
    page-break-after: avoid;
    break-after: avoid;
  }

  table, figure, img {
    page-break-inside: avoid;
    break-inside: avoid;
  }

  /* Ensure images fit the page */
  img {
    max-width: 100% !important;
    height: auto !important;
  }

  /* Tables */
  table {
    border-collapse: collapse;
    width: 100%;
  }

  th, td {
    border: 1px solid #ddd !important;
    padding: 8px;
  }

  thead {
    display: table-header-group; /* Repeat header on each page */
  }

  /* Page margins */
  @page {
    margin: 2cm;
    size: A4;
  }

  @page :first {
    margin-top: 3cm; /* Extra top margin on first page */
  }

  /* Content area takes full width */
  .main-content {
    width: 100% !important;
    margin: 0 !important;
    padding: 0 !important;
  }
}
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

  .tooltip-trigger:hover .tooltip {
    display: block;
  }

  /* Smaller hit targets are acceptable */
  .icon-button {
    width: 32px;
    height: 32px;
  }
}

/* Coarse pointer (touch, motion controllers) */
@media (pointer: coarse) {
  .button {
    padding: var(--spacing-3) var(--spacing-5);
    min-height: 44px; /* WCAG 2.5.5 Target Size */
  }

  /* No hover on touch — use tap interactions */
  .tooltip-trigger:hover .tooltip {
    display: none; /* Disable hover tooltips on touch */
  }

  /* Larger hit targets required */
  .icon-button {
    width: 44px;
    height: 44px;
  }

  /* Add touch-friendly spacing between tappable elements */
  .button-group {
    gap: var(--spacing-3);
  }

  .list-item--interactive {
    padding: var(--spacing-3) var(--spacing-4);
  }
}

/* Any hover capability (mouse or stylus) */
@media (hover: hover) {
  .card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-lg);
  }

  .link:hover {
    text-decoration: underline;
  }
}

/* No hover capability (pure touch) */
@media (hover: none) {
  .card {
    /* Remove hover-dependent visual affordances */
    transition: none;
  }

  /* Use active state instead of hover for feedback */
  .link:active {
    opacity: 0.7;
  }
}
```

#### Touch-Specific Behaviors
```css
/* Prevent unwanted touch behaviors */
.interactive-canvas {
  touch-action: none; /* Full custom gesture handling */
}

.horizontal-scroll {
  touch-action: pan-x; /* Allow horizontal scroll, prevent vertical */
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scroll-snap-type: x mandatory;
}

.horizontal-scroll > * {
  scroll-snap-align: start;
}

/* Prevent text selection on interactive elements */
.draggable {
  user-select: none;
  -webkit-user-select: none;
}

/* Prevent double-tap zoom on interactive elements */
.interactive-element {
  touch-action: manipulation;
}
```

#### Responsive Interaction Patterns
```typescript
// hooks/usePointerType.ts — Detect pointer type at runtime
import { useState, useEffect } from 'react';

export function usePointerType(): 'fine' | 'coarse' | 'none' {
  const [pointer, setPointer] = useState<'fine' | 'coarse' | 'none'>(() => {
    if (typeof window === 'undefined') return 'fine';
    if (window.matchMedia('(pointer: coarse)').matches) return 'coarse';
    if (window.matchMedia('(pointer: fine)').matches) return 'fine';
    return 'none';
  });

  useEffect(() => {
    const coarse = window.matchMedia('(pointer: coarse)');
    const handler = (e: MediaQueryListEvent) => {
      setPointer(e.matches ? 'coarse' : 'fine');
    };
    coarse.addEventListener('change', handler);
    return () => coarse.removeEventListener('change', handler);
  }, []);

  return pointer;
}
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
}

.table-wrapper table {
  min-width: 600px; /* Force horizontal scroll below this */
  width: 100%;
}

/* Fade indicator for scroll */
.table-wrapper {
  position: relative;
}

.table-wrapper::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  width: 40px;
  background: linear-gradient(to right, transparent, var(--color-surface));
  pointer-events: none;
  opacity: 1;
  transition: opacity 0.2s;
}

/* Hide fade when scrolled to end (JS toggles this class) */
.table-wrapper--scrolled-end::after {
  opacity: 0;
}
```

#### Stack Pattern (Cards on Mobile)
```css
/* Desktop: regular table | Mobile: stacked cards */
@media (max-width: 767px) {
  .responsive-table thead {
    display: none; /* Hide header on mobile */
  }

  .responsive-table tr {
    display: block;
    margin-bottom: var(--spacing-3);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    padding: var(--spacing-3);
  }

  .responsive-table td {
    display: flex;
    justify-content: space-between;
    padding: var(--spacing-1) 0;
    border: none;
  }

  .responsive-table td::before {
    content: attr(data-label);
    font-weight: var(--font-weight-semibold);
    margin-right: var(--spacing-2);
  }
}
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
│   768px (tablet):        PASS / FAIL (<N> issues)             │
│   1024px (laptop):       PASS / FAIL (<N> issues)             │
│   1280px (desktop):      PASS / FAIL (<N> issues)             │
│   1536px (large):        PASS / FAIL (<N> issues)             │
│                                                               │
│ Common Issues                                                 │
│   Horizontal overflow: <N> pages                              │
│   Text too small (< 16px on mobile): <N> elements             │
│   Touch targets too small (< 44px): <N> elements              │
│   Images not responsive: <N> images                           │
│   Fixed widths breaking layout: <N> elements                  │
│   Hidden content on mobile: <N> elements (verify intentional) │
│                                                               │
│ Images                                                        │
│   Using srcset: <N>/<N> images                                │
│   Art direction (<picture>): <N>/<N> hero images              │
│   Modern formats (avif/webp): YES / NO                        │
│   Lazy loading: <N>/<N> below-fold images                     │
│                                                               │
│ Typography                                                    │
│   Fluid type: YES / NO                                        │
│   Readable at 320px: YES / NO                                 │
│   No horizontal scroll at 200% zoom: YES / NO                 │
│                                                               │
│ Print                                                         │
│   Print stylesheet: YES / NO                                  │
│   Non-essential elements hidden: YES / NO                     │
│   Links show URLs: YES / NO                                   │
│                                                               │
│ Touch / Pointer                                               │
│   Touch targets >= 44px: YES / NO                             │
│   Hover-dependent features have alternatives: YES / NO        │
│   Pointer media queries used: YES / NO                        │
│                                                               │
│ Verdict: RESPONSIVE / PARTIALLY RESPONSIVE / DESKTOP-ONLY     │
│ Score: <N>/100                                                │
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
6. **Touch targets must be at least 44x44px.** WCAG 2.5.5 requires minimum 44x44 CSS pixels. On touch devices, users cannot aim a 1px cursor. Buttons, links, and interactive elements must be large enough to tap without mis-tapping.
7. **Print is a viewport too.** If users might print the content (articles, invoices, reports, documentation), add a print stylesheet. Hide navigation, show link URLs, control page breaks, and ensure readability in black and white.

## Example Usage

### Build a responsive dashboard layout
```
User: /godmode:responsive

Responsive: Analyzing project layout...

RESPONSIVE REQUIREMENTS:
Project: Analytics Dashboard
Framework: React + Tailwind
Strategy: Mobile-first
Layouts:
  - Sidebar navigation (hidden on mobile, fixed on desktop)
  - Stats cards (1-col mobile, 2-col tablet, 4-col desktop)
  - Chart + table (stacked mobile, side-by-side desktop)
  - Data table (horizontal scroll on mobile)

Building responsive layouts...
  Created: DashboardLayout with CSS Grid areas
  Created: StatsGrid with auto-fit minmax pattern
  Created: ChartSection with container queries
  Created: ResponsiveTable with scroll + stack patterns
  Created: MobileNav with hamburger toggle
  Added: Fluid typography scale
  Added: Print stylesheet for report export

Viewport testing:
  320px: PASS
  768px: PASS
  1280px: PASS
  1536px: PASS

Score: 88/100 (RESPONSIVE)
Remaining: Add srcset to dashboard chart images.
```

### Audit an existing site
```
User: /godmode:responsive --audit

Responsive: Auditing responsive design...

Issues found:
1. CRITICAL: Horizontal overflow at 320px on /checkout page
   - Fixed-width table (800px) causes horizontal scroll
2. HIGH: Touch targets on footer links are 24x24px (need 44x44)
3. HIGH: Hero image is 2400px on all viewports (no srcset)
4. MEDIUM: Typography uses fixed px values (no fluid scaling)
5. LOW: No print stylesheet

Score: 52/100 (PARTIALLY RESPONSIVE)

Priority fixes:
1. Wrap checkout table in scrollable container or use stack pattern
2. Increase footer link padding to meet 44px minimum
3. Add srcset and sizes to hero image
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full responsive design — build or audit |
| `--audit` | Audit existing site for responsive issues |
| `--grid` | CSS Grid layout implementation |
| `--container-queries` | Container query setup |
| `--images` | Responsive images optimization |
| `--typography` | Fluid typography implementation |
| `--print` | Print stylesheet setup |
| `--touch` | Touch vs pointer interaction setup |
| `--breakpoints` | Breakpoint system audit and standardization |
| `--table <name>` | Make a specific table responsive |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check for CSS framework: tailwind.config, bootstrap, bulma, chakra-ui in package.json
2. Detect CSS methodology: grep for BEM (--), CSS Modules (.module.css), styled-components, Emotion
3. Check for existing breakpoints: grep for @media, @container in CSS/SCSS files
4. Detect preprocessor: .scss, .less, .styl files, postcss.config
5. Check for responsive images: grep for srcset, sizes, <picture> in templates/JSX
6. Detect viewport meta tag: grep for viewport in index.html, _document, layout
7. Check for container queries: grep for @container, container-type in CSS
8. Scan for fluid typography: grep for clamp(, calc( in font-size declarations
```

## Iterative Responsive Implementation Loop

```
current_iteration = 0
max_iterations = 10
pages_remaining = [list of pages/components to make responsive]

WHILE pages_remaining is not empty AND current_iteration < max_iterations:
    page = pages_remaining.pop(0)
    1. Audit at 5 viewports: 320px, 375px, 768px, 1024px, 1440px
    2. Identify issues: overflow, touch targets < 44px, fixed widths, missing srcset
    3. Fix layout: convert fixed widths to fluid (%, vw, fr, minmax)
    4. Fix typography: convert px to rem, add clamp() for fluid scaling
    5. Fix images: add srcset + sizes, lazy loading, aspect-ratio
    6. Fix interactions: ensure all hover states have tap alternatives
    7. Re-audit at all 5 viewports + 2 in-between sizes
    8. IF issues remain → fix and re-audit
    9. IF clean → commit: "responsive: <page> — fluid layout + images + typography"
    10. current_iteration += 1

POST-LOOP: Run Lighthouse mobile audit, verify no horizontal overflow at any width 320-1440
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "responsive-layout": CSS Grid/Flexbox, breakpoints, container queries
  Agent 2 — "responsive-media": images (srcset/picture), video, lazy loading
  Agent 3 — "responsive-typography": fluid type scale, spacing, touch targets

MERGE ORDER: layout → typography → media
CONFLICT ZONES: shared CSS custom properties, breakpoint tokens (define design tokens first)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER use px for font-size. Use rem + clamp() for fluid scaling.
2. NEVER use fixed pixel widths on layout containers. Use max-width + fluid units.
3. NEVER hide content on mobile as a responsive strategy. Restructure, don't hide.
4. EVERY image must have srcset + sizes OR be an SVG. No single-resolution raster images.
5. EVERY interactive element must have a minimum 44x44px touch target.
6. NEVER mix min-width and max-width media queries. Pick one direction (mobile-first = min-width).
7. EVERY page must be tested at 320px minimum width. No horizontal overflow allowed.
8. NEVER use viewport units for font-size without clamp(). Unbound vw = unreadable text.
9. EVERY layout must work without JavaScript. CSS-only responsive behavior.
10. ALWAYS set explicit width and height (or aspect-ratio) on images/video to prevent CLS.
```

## Anti-Patterns

- **Do NOT use px for font sizes.** Pixel font sizes do not scale with user preferences. Use `rem` for consistent scaling with the root font size, and `clamp()` for fluid scaling across viewports.
- **Do NOT hide content on mobile as a responsive strategy.** If content matters, it should be available on every device. If it does not matter, remove it on all devices. "Hide on mobile" usually means "we did not design for mobile."
- **Do NOT use `@media (max-width)` in a mobile-first codebase.** Mixing min-width and max-width creates overlapping breakpoints and specificity battles. Pick one direction (min-width for mobile-first) and stick with it.
- **Do NOT rely on hover for essential interactions.** Touch devices have no hover. If a dropdown menu only opens on hover, touch users cannot access it. Every hover interaction needs a tap/click alternative.
- **Do NOT use fixed pixel widths for layout containers.** `width: 960px` breaks on any viewport narrower than 960px. Use `max-width` with percentage or viewport units for fluid containers.
- **Do NOT serve the same image to all viewports.** A 2400px image on a 320px phone wastes bandwidth and slows the page. Use `srcset`, `sizes`, and `<picture>` for resolution and art direction.
- **Do NOT test only on one viewport.** Responsive bugs hide between breakpoints. Test at 320px, 375px, 768px, 1024px, 1280px, and 1536px at minimum. Test in between breakpoints too.
- **Do NOT use viewport units (vw) for font sizes without clamp().** `font-size: 5vw` creates text that is unreadably small on phones and absurdly large on ultrawide monitors. Always constrain with `clamp(min, preferred, max)`.
