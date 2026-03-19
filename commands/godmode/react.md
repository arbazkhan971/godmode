# /godmode:react

Build excellent React applications with proper architecture. Covers component composition, state management selection, performance optimization, Server Components, concurrent features, and testing with React Testing Library.

## Usage

```
/godmode:react                             # Full React architecture workflow
/godmode:react --audit                     # Audit existing React project
/godmode:react --state                     # Design state management strategy
/godmode:react --perf                      # Performance optimization analysis
/godmode:react --test                      # Design testing strategy and patterns
/godmode:react --hooks                     # Design custom hook library
/godmode:react --migrate class-to-hooks    # Migrate class components to hooks
/godmode:react --migrate cra-to-vite       # Migrate CRA to Vite
/godmode:react --patterns                  # Component pattern catalog
/godmode:react --rsc                       # Server Components architecture guide
```

## What It Does

1. Assesses project context (framework, scale, pain points, existing patterns)
2. Designs component hierarchy (composition, slots, render props, HOCs, hooks)
3. Selects state management per category (server state, URL state, form state, UI state, global state)
4. Applies targeted performance optimization (memo, useMemo, useCallback, code splitting, virtualization)
5. Configures Server Components and concurrent features (useTransition, useDeferredValue, useOptimistic)
6. Designs testing strategy with React Testing Library and MSW
7. Validates against React best practices (15-point audit)
8. Generates component inventory and architecture documentation

## Output
- Component hierarchy with feature folders and layer responsibilities
- State management strategy map (which tool for which kind of state)
- Performance optimization plan with measured targets
- Testing patterns with RTL, MSW, and hook testing
- Architecture audit with PASS/NEEDS REVISION verdict
- Commit: `"react: <project> — component architecture, <state management>, <N> patterns"`

## Next Step
After React architecture: `/godmode:build` to implement components, `/godmode:test` for test suites, or `/godmode:a11y` for accessibility.

## Examples

```
/godmode:react Design component architecture for a project management app
/godmode:react --state Our app has Redux everywhere — help us simplify
/godmode:react --perf Board view re-renders all 200 cards when dragging
/godmode:react --test Set up testing patterns with React Testing Library
/godmode:react --audit Check our React app for architecture issues
```
