# /godmode:animation

Animation and motion design covering CSS animations, Framer Motion, GSAP, Lottie integration, scroll-driven animations, page transitions, micro-interactions, performance optimization, and reduced motion accessibility. Creates cohesive motion systems for web applications.

## Usage

```
/godmode:animation                         # Full animation audit
/godmode:animation --micro                 # Micro-interaction audit and recommendations
/godmode:animation --scroll                # Scroll-driven animation setup
/godmode:animation --page-transitions      # Page transition implementation
/godmode:animation --perf                  # Animation performance profiling
/godmode:animation --a11y                  # Reduced motion accessibility audit
/godmode:animation --library               # Animation library selection guidance
/godmode:animation --timeline              # Complex timeline/sequence choreography
/godmode:animation --lottie                # Lottie integration and optimization
/godmode:animation --spring                # Spring physics configuration guide
```

## What It Does

1. Analyzes current animation landscape (library, approach, inventory)
2. Evaluates CSS animation foundations (transitions, keyframes, scroll-driven)
3. Selects appropriate animation library (Framer Motion, GSAP, Lottie, CSS-only)
4. Implements Framer Motion patterns (enter/exit, stagger, layout, gesture)
5. Implements GSAP patterns (timelines, ScrollTrigger, stagger, SVG)
6. Integrates Lottie for designer-created animations
7. Designs page transitions and micro-interaction catalog
8. Optimizes animation performance (compositor-only, will-change, GPU layers)
9. Ensures reduced motion accessibility compliance

## Output
- Animation report at `docs/animation/<project>-motion-audit.md`
- Animation commit: `"animation: add <type> animations to <component>"`
- Performance commit: `"animation: optimize — replace layout-triggering properties"`
- Accessibility commit: `"animation: add prefers-reduced-motion support"`

## Key Principles

1. **CSS first** — most state changes need zero JavaScript
2. **Compositor-only** — animate transform and opacity, never width/height/top/left
3. **Reduced motion is not optional** — accessibility requirement, not nice-to-have
4. **Exit animations matter** — disappearing instantly while entering smoothly feels broken
5. **Timing communicates hierarchy** — important elements animate first
6. **Spring physics feel natural** — real objects do not follow cubic-bezier curves

## Next Step
After motion design: `/godmode:a11y` for accessibility, `/godmode:perf` for performance, `/godmode:three` for 3D animations, or `/godmode:ui` for component review.

## Examples

```
/godmode:animation                         # Full motion audit
/godmode:animation --scroll                # Set up scroll-driven animations
/godmode:animation --page-transitions      # Add route transitions
/godmode:animation --a11y                  # Check reduced motion compliance
```
