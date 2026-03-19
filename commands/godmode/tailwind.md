# /godmode:tailwind

Tailwind CSS mastery — configuration and customization, custom plugin creation, responsive design patterns, dark mode implementation, performance optimization (purging, JIT), and component patterns that avoid class soup. Master utility-first CSS for production applications.

## Usage

```
/godmode:tailwind                            # Full Tailwind assessment and setup
/godmode:tailwind --audit                    # Audit existing Tailwind configuration
/godmode:tailwind --config                   # Generate or optimize tailwind.config
/godmode:tailwind --dark-mode                # Set up dark mode with semantic tokens
/godmode:tailwind --plugin typography        # Create a custom Tailwind plugin
/godmode:tailwind --responsive               # Audit and improve responsive patterns
/godmode:tailwind --tokens                   # Map design tokens to Tailwind config
/godmode:tailwind --migrate                  # Migrate from other CSS to Tailwind
/godmode:tailwind --preset                   # Create a shared Tailwind preset
/godmode:tailwind --perf                     # CSS bundle size and performance audit
/godmode:tailwind --cva                      # Set up CVA for component variants
/godmode:tailwind --v4                       # Migrate from Tailwind 3 to Tailwind 4
```

## What It Does

1. Assesses project (Tailwind version, framework, build tool, design system, bundle size)
2. Configures theme with design tokens (colors, spacing, typography, shadows)
3. Sets up Tailwind 4.x CSS-first configuration or 3.x JS configuration
4. Creates custom plugins (components, utilities, base styles, variants)
5. Establishes responsive design patterns (mobile-first, container queries)
6. Implements dark mode with semantic color tokens (no dark: prefix needed)
7. Optimizes performance (content paths, JIT, no dynamic classes, minimal safelist)
8. Sets up component patterns with CVA and cn() (tailwind-merge + clsx)
9. Maps design system tokens from Figma/Style Dictionary to Tailwind config
10. Creates shared presets for multi-project design system consistency
11. Validates against 17-point best practices checklist

## Output
- Tailwind configuration with project design tokens
- Custom plugins for typography, components, and variants
- Dark mode system with semantic color tokens
- CVA variants for Button, Input, Badge components
- cn() utility for conditional and merge class handling
- CSS bundle size report
- Commit: `"tailwind: <project> — <description of configuration>"`

## Next Step
After setup: `/godmode:ui` for component architecture, `/godmode:a11y` for accessibility.
After building: `/godmode:visual` for visual regression testing.
Design system: `/godmode:designsystem` for full design system setup.

## Examples

```
/godmode:tailwind                            # Full assessment and setup
/godmode:tailwind --dark-mode                # Set up dark mode system
/godmode:tailwind --cva                      # Set up component variant patterns
/godmode:tailwind --migrate                  # Migrate from styled-components
/godmode:tailwind --perf                     # Audit CSS bundle size
```
