---
name: responsive
description: Responsive and adaptive design with CSS Grid,
  Flexbox, container queries, and fluid typography.
---

## Activate When
- `/godmode:responsive`, "responsive design", "mobile-first"
- "container queries", "responsive layout", "adaptive"
- Building interfaces that must work across breakpoints

## Workflow

### 1. Assess Requirements
```bash
grep -r "@media\|@container" --include="*.css" \
  --include="*.scss" -l 2>/dev/null | head -10
grep -r "srcset\|sizes" --include="*.html" \
  --include="*.tsx" --include="*.jsx" -l 2>/dev/null
```
```
Framework: <React/Vue/Angular/vanilla>
CSS approach: <Tailwind/CSS Modules/SCSS/CSS-in-JS>
Target devices: 320px-1536px
Strategy: mobile-first (default) | desktop-first
```
IF new project: always mobile-first (min-width).
IF legacy desktop app: desktop-first (max-width).

### 2. Layout Strategy
```
Fluid: percentage/relative units (text-heavy, blogs)
Responsive: breakpoint-based (complex layouts)
Intrinsic: CSS Grid auto-fit/minmax (component-level)
Container queries: component responds to container
```

Mobile-first breakpoints:
sm: 640px, md: 768px, lg: 1024px, xl: 1280px

### 3. CSS Grid Patterns
```css
/* Auto-fit responsive card grid */
.card-grid {
  display: grid;
  grid-template-columns:
    repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: var(--spacing-6);
}
```
IF 2D layout (rows+columns): use Grid.
IF 1D alignment (row of buttons): use Flexbox.

### 4. Container Queries
```css
.card-container { container-type: inline-size; }
@container (min-width: 400px) {
  .card { flex-direction: row; }
}
```
IF component used in sidebar AND main content: use
container queries instead of viewport media queries.

### 5. Fluid Typography
```css
:root {
  --fluid-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --fluid-lg: clamp(1.125rem, 0.95rem + 0.875vw, 1.5rem);
  --fluid-xl: clamp(1.5rem, 1rem + 2.5vw, 3rem);
}
```
IF using fixed px font sizes: replace with clamp().
Eliminates need for typography breakpoints.

### 6. Responsive Images
```html
<img src="hero-800.jpg"
  srcset="hero-400.jpg 400w, hero-800.jpg 800w,
    hero-1200.jpg 1200w"
  sizes="(max-width: 640px) 100vw, 50vw"
  loading="lazy" alt="..." />
```
Always: `max-width: 100%; height: auto;` on images.
Use `<picture>` for art direction (different crops).
Modern formats: AVIF > WebP > JPEG fallback.

### 7. Touch vs Pointer
```css
@media (pointer: coarse) {
  .button { min-height: 44px; min-width: 44px; }
}
@media (pointer: fine) {
  .button { padding: 0.5rem 1rem; }
}
```
WCAG minimum touch target: 44x44px.

### 8. Responsive Tables
Stack on mobile (cards), scroll horizontal on desktop.
```css
@media (max-width: 767px) {
  .table thead { display: none; }
  .table td { display: block; }
  .table td::before { content: attr(data-label); }
}
```

### 9. Audit
```
[ ] No horizontal overflow 320px-1536px
[ ] All images use srcset+sizes or SVG
[ ] Touch targets >= 44x44px
[ ] Typography uses clamp() (no fixed px)
[ ] CSS Grid/Flexbox (no float layouts)
[ ] CLS < 0.1 (explicit dimensions on media)
[ ] Consistent media query direction
```

## Hard Rules
1. ALWAYS mobile-first for new projects.
2. NEVER use fixed px for font sizes.
3. EVERY image: srcset+sizes or SVG.
4. MINIMUM 44x44px touch targets (WCAG).
5. NEVER float-based layouts.
6. ALWAYS set width/height or aspect-ratio on media.
7. NEVER mix min-width and max-width queries.

## TSV Logging
Append `.godmode/responsive.tsv`:
```
timestamp	page	viewport	issue_type	before	after	status
```

## Keep/Discard
```
KEEP if: no overflow at any viewport AND CLS < 0.1.
DISCARD if: overflow detected OR CLS regressed.
```

## Stop Conditions
```
STOP when FIRST of:
  - No horizontal overflow 320px-1536px
  - All images responsive
  - All touch targets >= 44px
  - CLS < 0.1 across viewports
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Layout breaks at breakpoint | Check fixed widths, use max-width |
| Images overflow mobile | max-width:100%; height:auto |
| Touch targets too small | Add padding, min 44x44px |
| Horizontal scroll | Find overflowing element in DevTools |
