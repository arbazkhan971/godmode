# /godmode:designsystem

Design system architecture covering token systems (colors, spacing, typography, shadows), component API standards, theme systems (light/dark, custom, multi-brand), design-to-code pipelines (Figma tokens to CSS variables via Style Dictionary), versioning and distribution, and Storybook documentation.

## Usage

```
/godmode:designsystem                         # Full design system — build or audit
/godmode:designsystem --audit                  # Audit existing design system maturity
/godmode:designsystem --tokens                 # Token architecture only
/godmode:designsystem --theme                  # Theme system setup (light/dark/multi-brand)
/godmode:designsystem --pipeline               # Design-to-code pipeline (Figma to CSS)
/godmode:designsystem --storybook              # Storybook documentation setup
/godmode:designsystem --version                # Distribution and versioning setup
/godmode:designsystem --api-standards          # Component API standards audit
/godmode:designsystem --init                   # Initialize complete design system from scratch
/godmode:designsystem --migrate                # Migrate hardcoded values to tokens
```

## What It Does

1. Assesses current design system maturity (NONE / STARTER / GROWING / MATURE)
2. Builds three-tier token architecture (primitive, semantic, component tokens)
3. Defines component API standards (prop naming, typing, ref forwarding, composition)
4. Implements theme system with light/dark mode and system preference detection
5. Configures Figma-to-CSS pipeline with Style Dictionary and CI automation
6. Sets up versioning and distribution (semantic versioning, changelog, npm)
7. Configures Storybook with foundation documentation and component catalog
8. Audits token coverage, hardcoded values, and API compliance

## Output
- Design system audit report at `docs/designsystem/<project>-design-system-audit.md`
- Token files: `tokens/primitives/*.css`, `tokens/semantic/*.css`
- Theme files: `themes/light.css`, `themes/dark.css`
- Pipeline config: `style-dictionary.config.js`
- Maturity score: NONE / STARTER / GROWING / MATURE (0-100)

## Next Step
After design system setup: `/godmode:ui` for component audit, `/godmode:a11y` for accessibility, `/godmode:responsive` for responsive design, or `/godmode:forms` for form architecture.

## Examples

```
/godmode:designsystem                         # Build or audit design system
/godmode:designsystem --tokens                # Create token architecture
/godmode:designsystem --theme                 # Set up dark mode
/godmode:designsystem --pipeline              # Automate Figma to CSS sync
/godmode:designsystem --migrate               # Replace hardcoded values with tokens
```
