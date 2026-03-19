---
name: animation
description: |
  Animation and motion design skill. Activates when user needs to create CSS animations, integrate animation libraries (Framer Motion, GSAP, Lottie), build scroll-driven animations, design page transitions and micro-interactions, or optimize animation performance. Covers GPU compositing, reduced motion accessibility, and choreographed motion systems. Triggers on: /godmode:animation, "animate", "motion design", "page transition", "scroll animation", "micro-interaction", or when building interactive motion.
---

# Animation — Animation & Motion Design

## When to Activate
- User invokes `/godmode:animation`
- User says "animate," "motion design," "page transition," "micro-interaction"
- When adding animations to a web application
- When choosing an animation library (Framer Motion, GSAP, Lottie)
- When building scroll-driven animations or parallax effects
- When page transitions or route animations are needed
- When optimizing animation performance (jank, FPS drops)
- When ensuring animations respect reduced motion preferences

## Workflow

### Step 1: Analyze Animation Context
Survey the current animation landscape in the project:

```
ANIMATION ANALYSIS:
Framework: <React/Vue/Angular/Svelte/vanilla>
Current animations: <CSS only/library/mixed/none>
Animation library: <Framer Motion/GSAP/Lottie/AnimeJS/none>
CSS approach: <transitions/keyframes/@property/none>
Scroll animations: <yes/no>
Page transitions: <yes/no>
Reduced motion: <respected/ignored/not checked>

Animation inventory:
  Micro-interactions: <N> (hover, focus, press states)
  Transitions: <N> (page, modal, drawer, accordion)
  Scroll-driven: <N> (parallax, reveal, progress)
  Loading/skeleton: <N> (spinners, shimmer, progress)
  Data/chart: <N> (number counting, bar fill, graph draw)
  Decorative: <N> (background, ambient, particle)

Performance:
  Compositor-only: <N>/<total> animations
  Layout-triggering: <N> (width, height, top, left)
  Paint-triggering: <N> (color, background, box-shadow)
  will-change used: <yes/no/overused>
  requestAnimationFrame: <used/not used>
```

### Step 2: CSS Animation Foundations
Evaluate and implement CSS-first animations:

#### CSS Transitions
```
CSS TRANSITIONS — Best for state changes:

/* Recommended transition properties (compositor-only) */
.element {
  transition: transform 200ms ease-out,
              opacity 200ms ease-out;
}

/* AVOID transitioning layout properties */
.element-bad {
  transition: width 200ms, height 200ms, top 200ms; /* triggers layout */
}

TRANSITION TIMING GUIDE:
┌────────────────────────────────────────────────────────────────┐
│ Interaction       │ Duration   │ Easing                        │
├────────────────────────────────────────────────────────────────┤
│ Hover state       │ 150-200ms  │ ease-out                      │
│ Button press      │ 100-150ms  │ ease-in-out                   │
│ Toggle/switch     │ 200-250ms  │ ease-in-out                   │
│ Modal open        │ 200-300ms  │ ease-out (or spring)          │
│ Modal close       │ 150-200ms  │ ease-in (faster than open)    │
│ Drawer slide      │ 250-350ms  │ ease-out or cubic-bezier      │
│ Page transition   │ 300-500ms  │ ease-in-out                   │
│ Tooltip appear    │ 100-150ms  │ ease-out                      │
│ Notification      │ 200-300ms  │ ease-out (enter), ease-in (exit)│
│ Accordion expand  │ 200-300ms  │ ease-out                      │
│ Skeleton shimmer  │ 1500-2000ms│ linear (infinite)             │
└────────────────────────────────────────────────────────────────┘

Easing cheat sheet:
  ease-out:      fast start, gentle stop (entering elements)
  ease-in:       gentle start, fast end (exiting elements)
  ease-in-out:   gentle start and end (moving elements)
  linear:        constant speed (progress bars, looping)
  cubic-bezier(0.34, 1.56, 0.64, 1): spring overshoot
```

#### CSS Keyframe Animations
```
CSS KEYFRAMES — Best for multi-step and looping:

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

KEYFRAME CHECKLIST:
- [ ] Use transform and opacity only (compositor-friendly)
- [ ] animation-fill-mode: forwards (if element should stay at end state)
- [ ] animation-fill-mode: none (if element should return to initial)
- [ ] Finite iteration count (avoid infinite unless intentional: spinner, shimmer)
- [ ] animation-play-state for pause/resume control
- [ ] Stagger delays for list animations (calc-based or CSS custom properties)
```

#### CSS Scroll-Driven Animations (Modern)
```
CSS SCROLL-DRIVEN ANIMATIONS (2024+):

/* Scroll progress animation */
@keyframes reveal {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.scroll-reveal {
  animation: reveal linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 100%;
}

/* Scroll progress indicator */
.progress-bar {
  animation: grow linear;
  animation-timeline: scroll();
  transform-origin: left;
}

@keyframes grow {
  from { transform: scaleX(0); }
  to { transform: scaleX(1); }
}

SCROLL ANIMATION TYPES:
┌────────────────────────────────────────────────────────────────┐
│ Type             │ Timeline       │ Range                      │
├────────────────────────────────────────────────────────────────┤
│ Page progress    │ scroll()       │ 0% to 100% of document    │
│ Section reveal   │ view()         │ entry 0% to entry 100%    │
│ Parallax         │ scroll()       │ Custom range per layer    │
│ Pin + animate    │ view()         │ cover 0% to cover 100%    │
│ Horizontal scroll│ scroll(inline) │ 0% to 100% of container   │
└────────────────────────────────────────────────────────────────┘

Browser support: Chrome 115+, Edge 115+, Firefox 110+ (partial)
Fallback: IntersectionObserver + class toggle
```

### Step 3: Animation Library Selection
Choose the right library for the project:

```
ANIMATION LIBRARY DECISION MATRIX:
┌──────────────────────────────────────────────────────────────────────────┐
│ Criterion         │ Framer Motion│ GSAP        │ Lottie   │ CSS only   │
├──────────────────────────────────────────────────────────────────────────┤
│ React integration │ Native       │ Plugin      │ Plugin   │ Native     │
│ Bundle size       │ ~30KB        │ ~25KB       │ ~50KB+   │ 0KB        │
│ Spring physics    │ Excellent    │ Plugin      │ No       │ Approx     │
│ Gesture support   │ Built-in     │ No          │ No       │ No         │
│ Layout animation  │ Built-in     │ Flip plugin │ No       │ No         │
│ SVG animation     │ Good         │ Excellent   │ Excellent│ Basic      │
│ Scroll-driven     │ Good         │ ScrollTrigger│ Scroll  │ CSS native │
│ Timeline/sequence │ Basic        │ Excellent   │ Built-in │ Keyframes  │
│ Performance       │ Good         │ Excellent   │ Good     │ Excellent  │
│ Designer handoff  │ No           │ No          │ Yes (AE) │ No         │
│ Learning curve    │ Low          │ Moderate    │ Low      │ Low        │
│ License           │ MIT          │ Proprietary*│ MIT      │ N/A        │
│ SSR safe          │ Yes          │ Manual      │ Manual   │ Yes        │
└──────────────────────────────────────────────────────────────────────────┘
* GSAP free for most use, paid for some plugins

RECOMMENDATION LOGIC:
IF React project + component animations → Framer Motion
IF complex timelines + scroll effects → GSAP + ScrollTrigger
IF designer exports from After Effects → Lottie
IF simple hover/focus/toggle states → CSS only (no library needed)
IF Vue/Svelte → CSS + GSAP (or framework-native transitions)
IF performance-critical + many elements → CSS only or GSAP
IF gesture-driven UI (drag, swipe, pinch) → Framer Motion
```

### Step 4: Framer Motion Patterns (React)
Implement common animation patterns with Framer Motion:

```
FRAMER MOTION PATTERNS:

// 1. Enter/exit animations
<AnimatePresence mode="wait">
  {isVisible && (
    <motion.div
      key="modal"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    />
  )}
</AnimatePresence>

// 2. Staggered list
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.05 }
  }
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 }
};

<motion.ul variants={container} initial="hidden" animate="show">
  {items.map(i => <motion.li key={i} variants={item} />)}
</motion.ul>

// 3. Layout animations
<motion.div layout layoutId="shared-element">
  {/* Element smoothly animates between positions */}
</motion.div>

// 4. Scroll-triggered
<motion.div
  initial={{ opacity: 0, y: 50 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: "-100px" }}
  transition={{ duration: 0.5 }}
/>

// 5. Gesture animations
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
/>

// 6. Drag
<motion.div
  drag="x"
  dragConstraints={{ left: -200, right: 200 }}
  dragElastic={0.1}
  onDragEnd={(e, info) => {
    if (Math.abs(info.offset.x) > 100) handleSwipe(info.offset.x);
  }}
/>
```

### Step 5: GSAP Patterns
Implement GSAP-powered animations:

```
GSAP PATTERNS:

// 1. Basic tween
gsap.to(".box", {
  x: 200,
  rotation: 360,
  duration: 1,
  ease: "power2.out"
});

// 2. Timeline (choreographed sequence)
const tl = gsap.timeline({ defaults: { ease: "power2.out" } });
tl.from(".hero-title", { y: 50, opacity: 0, duration: 0.8 })
  .from(".hero-subtitle", { y: 30, opacity: 0, duration: 0.6 }, "-=0.4")
  .from(".hero-cta", { y: 20, opacity: 0, duration: 0.5 }, "-=0.3")
  .from(".hero-image", { scale: 0.9, opacity: 0, duration: 0.8 }, "-=0.5");

// 3. ScrollTrigger
gsap.registerPlugin(ScrollTrigger);

gsap.from(".section", {
  scrollTrigger: {
    trigger: ".section",
    start: "top 80%",
    end: "top 20%",
    scrub: true,       // ties animation to scroll position
    // pin: true,       // pins element during animation
    // markers: true,   // debug markers
  },
  y: 100,
  opacity: 0,
});

// 4. Stagger
gsap.from(".card", {
  y: 60,
  opacity: 0,
  duration: 0.8,
  stagger: { each: 0.1, from: "start" },
  ease: "back.out(1.7)"
});

// 5. SVG path animation
gsap.from(".path", {
  drawSVG: "0%",       // requires DrawSVGPlugin
  duration: 2,
  ease: "power1.inOut"
});

// 6. SplitText (text animation)
const split = new SplitText(".heading", { type: "chars,words" });
gsap.from(split.chars, {
  y: 50,
  opacity: 0,
  stagger: 0.02,
  duration: 0.5,
  ease: "back.out(1.7)"
});
```

### Step 6: Lottie Integration
Integrate designer-created animations:

```
LOTTIE INTEGRATION:

// React (lottie-react)
import Lottie from 'lottie-react';
import animationData from './animation.json';

<Lottie
  animationData={animationData}
  loop={false}
  autoplay={true}
  style={{ width: 200, height: 200 }}
  onComplete={() => console.log('done')}
/>

// Lottie-web (vanilla)
import lottie from 'lottie-web';

const anim = lottie.loadAnimation({
  container: document.querySelector('.lottie'),
  renderer: 'svg',     // svg | canvas | html
  loop: true,
  autoplay: true,
  path: '/animations/loading.json'
});

// Control
anim.play();
anim.pause();
anim.goToAndStop(30, true);  // frame 30
anim.setSpeed(1.5);
anim.setDirection(-1);       // reverse

LOTTIE OPTIMIZATION:
- [ ] Compress JSON with lottie-compress or bodymovin settings
- [ ] Use dotLottie format (.lottie) for 50-80% smaller files
- [ ] Limit animation complexity (< 30 layers, < 500 keyframes)
- [ ] Use SVG renderer for quality, canvas for performance
- [ ] Lazy-load animations below the fold
- [ ] Preload critical animations (loading, hero)
- [ ] Set explicit width/height to prevent layout shift
- [ ] Avoid expressions in After Effects export (increases file size)
```

### Step 7: Page Transitions & Micro-Interactions
Design cohesive motion systems:

#### Page Transitions
```
PAGE TRANSITION PATTERNS:
┌────────────────────────────────────────────────────────────────┐
│ Pattern          │ Description          │ Best for              │
├────────────────────────────────────────────────────────────────┤
│ Crossfade        │ Fade out old, in new │ Default / safe choice │
│ Slide            │ Slide in direction   │ Tab navigation        │
│ Shared element   │ Morph common element │ List -> detail view   │
│ Cover/uncover    │ New page covers old  │ Modal-like navigation │
│ Zoom             │ Zoom into element    │ Card -> full view     │
│ Stagger reveal   │ Elements enter seq   │ Dashboard pages       │
└────────────────────────────────────────────────────────────────┘

VIEW TRANSITION API (modern):
document.startViewTransition(() => {
  // Update DOM here
  updateContent();
});

/* CSS for view transitions */
::view-transition-old(root) {
  animation: fade-out 200ms ease-in;
}
::view-transition-new(root) {
  animation: fade-in 300ms ease-out;
}

/* Named transitions for shared elements */
.card-image {
  view-transition-name: hero-image;
}
```

#### Micro-Interaction Catalog
```
MICRO-INTERACTION CHECKLIST:
Buttons:
- [ ] Hover: subtle scale or color shift (150ms)
- [ ] Press: scale down (0.95-0.98) (100ms)
- [ ] Loading: spinner or progress indicator
- [ ] Success: checkmark with brief color flash
- [ ] Error: shake animation (3-4 oscillations, 300ms)

Form fields:
- [ ] Focus: border color transition + label float (200ms)
- [ ] Validation: icon slide-in (check/X) (200ms)
- [ ] Error: field shake + red border (300ms)
- [ ] Character count: progress ring or bar

Toggles and switches:
- [ ] Thumb slide with spring physics (200-250ms)
- [ ] Background color crossfade (200ms)
- [ ] Icon morph (sun/moon for dark mode)

Navigation:
- [ ] Active indicator slide (underline, pill) (200ms)
- [ ] Menu expand/collapse with stagger (250-350ms)
- [ ] Breadcrumb truncation with fade

Feedback:
- [ ] Toast/notification slide-in + auto-dismiss (300ms in, 200ms out)
- [ ] Skeleton shimmer while loading (continuous)
- [ ] Pull-to-refresh with elastic overscroll
- [ ] Swipe-to-dismiss with velocity-based threshold
```

### Step 8: Animation Performance
Ensure animations run at 60 FPS:

```
ANIMATION PERFORMANCE RULES:

COMPOSITOR-ONLY PROPERTIES (GPU-accelerated, no repaint):
  transform: translate, scale, rotate
  opacity
  filter (some browsers)
  clip-path (some browsers)

AVOID ANIMATING (triggers layout or paint):
  Layout: width, height, margin, padding, top, left, right, bottom
  Paint: color, background-color, border-color, box-shadow
  Both: font-size, border-width

PERFORMANCE CHECKLIST:
- [ ] Only animate transform and opacity where possible
- [ ] Use will-change sparingly (only on elements about to animate)
- [ ] Remove will-change after animation completes
- [ ] Use requestAnimationFrame for JS animations (never setInterval)
- [ ] Avoid layout thrashing (batch reads, then batch writes)
- [ ] Use contain: layout paint for animated containers
- [ ] Reduce paint areas (isolate animated elements in own layer)
- [ ] Debounce scroll/resize handlers (or use passive listeners)
- [ ] Test on low-end devices (4x CPU slowdown in DevTools)
- [ ] Monitor with Performance panel (aim for < 16.6ms per frame)

WILL-CHANGE USAGE:
/* Good — apply before animation, remove after */
.element:hover { will-change: transform; }
.element.animating { will-change: transform, opacity; }

/* Bad — applied to everything always */
* { will-change: transform; }  /* creates excessive layers, wastes GPU memory */

GPU COMPOSITING DIAGNOSIS:
  Chrome DevTools -> Rendering -> Layer borders (green = composited)
  Chrome DevTools -> Rendering -> Paint flashing (green = repaint)
  Chrome DevTools -> Performance -> check for "Layout" / "Paint" events during animation
```

### Step 9: Reduced Motion Accessibility
Respect user motion preferences:

```
REDUCED MOTION IMPLEMENTATION:

/* CSS: respect prefers-reduced-motion */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}

/* Alternative: keep subtle animations, remove dramatic ones */
@media (prefers-reduced-motion: reduce) {
  .parallax { transform: none; }
  .page-transition { animation: none; }
  .auto-play-video { animation-play-state: paused; }

  /* Keep opacity transitions — they are generally safe */
  .fade-in { transition: opacity 200ms ease-out; }
}

/* JavaScript: check preference */
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// Framer Motion
<motion.div
  animate={{ x: prefersReducedMotion ? 0 : 200 }}
  transition={prefersReducedMotion ? { duration: 0 } : { type: "spring" }}
/>

// GSAP
if (!prefersReducedMotion) {
  gsap.from(".element", { y: 50, opacity: 0 });
}

REDUCED MOTION CHECKLIST:
- [ ] prefers-reduced-motion media query applied globally
- [ ] Parallax effects disabled for reduced motion
- [ ] Auto-playing animations paused
- [ ] Page transitions replaced with instant or fade-only
- [ ] Scroll-triggered animations simplified to opacity-only
- [ ] Loading spinners kept (functional, not decorative)
- [ ] User can toggle animations in app settings (override OS preference)
- [ ] Tested with "Reduce motion" enabled in OS accessibility settings
```

### Step 10: Recommendations Report

```
+------------------------------------------------------------+
|  ANIMATION REPORT — <project>                               |
+------------------------------------------------------------+
|  Framework: <framework>                                     |
|  Animation library: <library or CSS-only>                   |
|  Total animations: <N>                                      |
|                                                             |
|  Animation Quality:                                         |
|  Compositor-only:     <N>/<total> (<X>%)                    |
|  Layout-triggering:   <N> (need fix)                        |
|  Paint-triggering:    <N> (need fix)                        |
|  Timing appropriate:  <N>/<total>                           |
|  Easing appropriate:  <N>/<total>                           |
|                                                             |
|  Accessibility:                                             |
|  Reduced motion:      <respected/partial/ignored>           |
|  Motion toggle:       <yes/no>                              |
|  Auto-play control:   <yes/no>                              |
|                                                             |
|  Performance:                                               |
|  Average FPS during animation: <X>                          |
|  Jank frames detected: <N>                                  |
|  will-change usage: <correct/overused/missing>              |
|                                                             |
|  Priority Actions:                                          |
|  1. <highest impact improvement>                            |
|  2. <second improvement>                                    |
|  3. <third improvement>                                     |
+------------------------------------------------------------+
```

### Step 11: Commit and Transition
1. If animations were added or improved:
   - Commit: `"animation: add <type> animations to <component/page>"`
2. If performance was optimized:
   - Commit: `"animation: optimize — replace layout-triggering properties with transforms"`
3. If accessibility was added:
   - Commit: `"animation: add prefers-reduced-motion support"`
4. Save report: `docs/animation/<project>-motion-audit.md`
5. Transition: "Motion design complete. Run `/godmode:a11y` for accessibility audit, `/godmode:perf` for performance profiling, or `/godmode:three` for 3D animations."

## Key Behaviors

1. **CSS first, libraries second.** Most hover effects, toggles, and simple transitions need zero JavaScript. CSS transitions and keyframes are the most performant option. Reach for Framer Motion or GSAP only when CSS cannot express the animation (spring physics, layout animations, complex timelines).
2. **Compositor-only properties are mandatory for smooth animation.** Animate `transform` and `opacity`. Animating `width`, `height`, `top`, `left`, `margin`, or `padding` triggers layout recalculation, which causes jank on every frame. If you need to animate size, use `transform: scale()`.
3. **Reduced motion is not optional.** Users with vestibular disorders, motion sensitivity, or epilepsy rely on `prefers-reduced-motion`. Every animation must have a reduced-motion alternative. This is an accessibility requirement, not a nice-to-have.
4. **Exit animations are as important as enter animations.** Elements disappearing instantly while entering smoothly feels broken. Use `AnimatePresence` in Framer Motion or animate out before removing from DOM. Exits should be faster than entrances.
5. **Timing communicates hierarchy.** Important elements animate first. Related elements stagger in sequence. Duration reflects distance and importance. A modal opening (300ms) should feel weightier than a tooltip appearing (100ms).
6. **Spring physics feel more natural than easing curves.** Real objects do not follow cubic-bezier curves. Spring-based animations (Framer Motion's `type: "spring"`) respond to velocity and feel connected to user input. Use springs for interactive elements.
7. **will-change is a performance hint, not a magic fix.** Applying `will-change: transform` to every element creates excessive GPU layers and wastes memory. Apply it just before animation starts, remove it after. Never use `* { will-change: transform; }`.

## Example Usage

### Full animation audit
```
User: /godmode:animation

Animation: Analyzing motion design...

ANIMATION ANALYSIS:
Framework: React 18 + Next.js
Animation library: Framer Motion 10
Total animations: 34

Animation Quality:
Compositor-only: 28/34 (82%)
Layout-triggering: 4 (animating width for accordion)
Paint-triggering: 2 (animating background-color on hover)
Timing appropriate: 30/34
Easing appropriate: 26/34 (8 using default ease instead of spring)

Accessibility:
Reduced motion: PARTIAL (global query exists but 12 animations bypass it)
Motion toggle: No
Auto-play control: No (hero animation auto-plays)

FINDING 1: Accordion animates height (layout trigger)
  Fix: Use grid-template-rows: 0fr -> 1fr trick or max-height

FINDING 2: 12 Framer Motion animations ignore reduced motion
  Fix: Create useReducedMotion() wrapper for all motion components

FINDING 3: Card hover animates box-shadow (paint trigger)
  Fix: Use pseudo-element with opacity for shadow transition

Priority Actions:
1. Fix 4 layout-triggering animations (accordion, sidebar)
2. Apply reduced motion to 12 bypassing animations
3. Replace box-shadow animation with opacity trick

Verdict: GOOD motion design, needs accessibility and perf fixes.
```

### Add page transitions
```
User: /godmode:animation --page-transitions

Animation: Setting up page transitions...

Detected: Next.js App Router

Recommendation: View Transitions API with Framer Motion fallback

Implementation:
1. View Transitions API for modern browsers (crossfade + shared elements)
2. Framer Motion AnimatePresence for unsupported browsers
3. Shared layout animation for list -> detail transitions
4. prefers-reduced-motion: instant page swap (opacity fade only)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full animation audit |
| `--micro` | Micro-interaction audit and recommendations |
| `--scroll` | Scroll-driven animation setup |
| `--page-transitions` | Page transition implementation |
| `--perf` | Animation performance profiling |
| `--a11y` | Reduced motion and accessibility audit |
| `--library` | Animation library selection guidance |
| `--timeline` | Complex timeline/sequence choreography |
| `--lottie` | Lottie integration and optimization |
| `--spring` | Spring physics configuration guide |

## Anti-Patterns

- **Do NOT animate layout properties.** Animating `width`, `height`, `top`, `left`, `margin`, or `padding` triggers layout recalculation every frame. Use `transform: translate/scale` and `opacity` instead. If you need to animate height, use the `grid-template-rows: 0fr/1fr` technique.
- **Do NOT apply will-change to everything.** `will-change: transform` on every element creates a GPU layer per element, exhausting video memory and causing compositing overhead worse than the jank it was supposed to prevent.
- **Do NOT ignore reduced motion.** Shipping animations without `prefers-reduced-motion` support is an accessibility violation. Users with vestibular disorders will experience nausea, dizziness, or seizures from motion they cannot control.
- **Do NOT use setInterval for animations.** `setInterval(animate, 16)` does not sync with the display refresh rate, causing visual tearing and jank. Use `requestAnimationFrame` or CSS animations, which synchronize with VSync.
- **Do NOT make exit animations slower than enter.** Users expect things to disappear quickly. A modal that takes 500ms to close feels sluggish. Enter: 200-300ms. Exit: 150-200ms. Closing is always faster than opening.
- **Do NOT use animation for essential content.** If the only way to see content is to wait for an animation to complete, screen readers and reduced-motion users miss it entirely. Animations enhance, they do not gate access.
- **Do NOT add animation without purpose.** Every animation should serve a function: indicate state change, guide attention, provide feedback, or communicate spatial relationship. Decorative animation that serves no UX purpose is visual noise.
