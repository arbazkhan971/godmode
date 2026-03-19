# /godmode:chart

Data visualization design and implementation. Selects optimal chart types for data communication goals, integrates with D3.js, Chart.js, Recharts, and Plotly, builds responsive and accessible charts, and designs multi-chart dashboard layouts.

## Usage

```
/godmode:chart                            # Full chart design and implementation workflow
/godmode:chart --type bar                 # Force a specific chart type
/godmode:chart --lib recharts             # Force a specific library
/godmode:chart --dashboard                # Design a multi-chart dashboard layout
/godmode:chart --responsive               # Focus on responsive chart design
/godmode:chart --a11y                     # Accessibility audit for existing charts
/godmode:chart --palette colorblind       # Use a specific color palette
/godmode:chart --data metrics.json        # Load data from file for prototyping
/godmode:chart --export svg               # Export chart as SVG, PNG, or PDF
/godmode:chart --perf                     # Profile chart rendering performance
```

## What It Does

1. Discovers data shape, audience, and communication goal
2. Selects optimal chart type (bar, line, scatter, heatmap, treemap, sankey, etc.)
3. Selects visualization library based on project framework and requirements
4. Transforms data into the format required by the chart library
5. Implements the chart with full configuration (axes, legends, tooltips, colors)
6. Applies responsive design across mobile, tablet, and desktop breakpoints
7. Validates accessibility (colorblind-safe palette, ARIA labels, data table alternative, keyboard navigation)
8. Optimizes rendering performance for large datasets (Canvas, WebGL, downsampling)
9. Composes multi-chart dashboard layouts with linked interactions

## Output
- Chart component at `src/components/charts/<ChartName>.tsx`
- Data transformer at `src/utils/chart-data/<transformer>.ts`
- Dashboard layout at `src/pages/<dashboard>.tsx` (if dashboard)
- Storybook story and tests
- Commit: `"chart: <component> — <chart type>, <library>, responsive + accessible"`

## Key Principles

1. **Data story first** — understand what the visualization communicates before choosing a chart type
2. **Accessibility is mandatory** — colorblind-safe palette, ARIA labels, data table alternative, keyboard navigation
3. **Responsive by default** — charts must work on mobile with graceful degradation
4. **Performance at scale** — match rendering strategy (SVG, Canvas, WebGL) to data volume
5. **No misleading visualizations** — bar charts start at 0, dual axes are labeled, scales are honest

## Next Step
After charts: `/godmode:a11y` for full accessibility audit, `/godmode:visual` for visual regression, or `/godmode:test` for data transformation tests.

## Examples

```
/godmode:chart                            # Design a chart from scratch
/godmode:chart --dashboard                # Build a multi-chart dashboard
/godmode:chart --type heatmap --lib d3    # Heatmap with D3.js
/godmode:chart --a11y                     # Audit chart accessibility
/godmode:chart --perf                     # Profile rendering performance
```
