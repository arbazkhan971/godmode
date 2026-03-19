# /godmode:uxdesign

UI/UX design skill — user personas, information architecture, user flow mapping, usability heuristics (Nielsen's 10), design system adherence, accessibility in design, and developer handoff specs. Bridges the gap between design intent and code.

## Usage

```
/godmode:uxdesign                           # Full UX design workflow
/godmode:uxdesign --persona                 # Create user personas from data
/godmode:uxdesign --flows                   # Map user flows and navigation
/godmode:uxdesign --heuristics              # Nielsen's 10 heuristics evaluation
/godmode:uxdesign --handoff                 # Generate developer handoff spec
/godmode:uxdesign --audit                   # UX audit of existing interface
/godmode:uxdesign --mobile-first            # Mobile-first design approach
```

## What It Does

1. Gathers context — existing UI, user needs, business goals
2. Creates user personas with goals, pain points, and behaviors
3. Maps information architecture and navigation structure
4. Designs user flows for key tasks
5. Evaluates against Nielsen's 10 usability heuristics
6. Ensures WCAG accessibility compliance in design decisions
7. Produces developer handoff specs with exact measurements, tokens, and states

## Output
- UX spec at `docs/specs/<feature>-ux-design.md`
- User flows, personas, and IA diagrams
- Commit: `"ux: <feature> — UX design spec"`

## Next Step
→ `/godmode:wireframe` to create wireframes from the UX spec
→ `/godmode:ui` to implement components
→ `/godmode:a11y` for accessibility audit
