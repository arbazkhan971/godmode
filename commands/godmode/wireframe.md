# /godmode:wireframe

Wireframing and prototyping skill — lo-fi wireframes (ASCII/text-based), component layout planning, navigation flows, responsive breakpoints, screen inventory, component hierarchy, and Figma-to-code translation guidance.

## Usage

```
/godmode:wireframe                          # Full wireframing workflow
/godmode:wireframe --ascii                  # Generate ASCII wireframes
/godmode:wireframe --sitemap                # Create sitemap and screen inventory
/godmode:wireframe --responsive             # Plan responsive breakpoints
/godmode:wireframe --components             # Map component hierarchy
/godmode:wireframe --figma                  # Figma-to-code translation guide
/godmode:wireframe --page <name>            # Wireframe a specific page
```

## What It Does

1. Creates screen inventory and sitemap
2. Generates lo-fi wireframes (ASCII art for terminal, structured specs for handoff)
3. Plans component hierarchy and reuse
4. Maps responsive breakpoints and layout shifts
5. Produces navigation flow diagrams
6. Generates Figma-to-code translation specs

## Output
- Wireframes at `docs/wireframes/<feature>/`
- Component hierarchy map
- Commit: `"wireframe: <feature> — <N> screens wireframed"`

## Next Step
→ `/godmode:ui` to implement the wireframed components
→ `/godmode:designsystem` to build the design system
→ `/godmode:responsive` for responsive implementation
