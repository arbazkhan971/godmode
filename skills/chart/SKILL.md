---
name: chart
description: |
  Data visualization skill. Activates when users need to create charts, graphs, dashboards, or any visual representation of data. Supports chart type selection (bar, line, scatter, heatmap, treemap, sankey), integrates with D3.js, Chart.js, Recharts, and Plotly, enforces dashboard design principles, responsive layouts, and accessibility standards for data visualizations. Triggers on: /godmode:chart, "create a chart", "visualize this data", "build a dashboard", or when the orchestrator detects data visualization work.
---

# Chart — Data Visualization

## When to Activate
- User invokes `/godmode:chart`
- User says "create a chart", "visualize this data", "make a graph"
- User says "build a dashboard", "display metrics", "plot this"
- When building reporting pages or analytics dashboards
- When `/godmode:plan` identifies data visualization tasks
- When `/godmode:review` flags visualization accessibility or usability issues

## Workflow

### Step 1: Data & Intent Discovery
Understand the data and what the visualization needs to communicate:

```
VISUALIZATION DISCOVERY:
Project: <name and purpose>
Data source: <API endpoint | database query | static JSON | CSV | real-time stream>
Data shape: <rows x columns, field names, types>
Audience: <executives | engineers | end-users | public>
Goal: <compare | trend | distribute | correlate | compose | flow | geospatial>
Interactivity: <static | hover tooltips | click-to-filter | drill-down | real-time>
Environment: <React | Vue | Angular | vanilla JS | server-side PDF | Jupyter>
Existing library: <D3.js | Chart.js | Recharts | Plotly | Nivo | Victory | none>
Constraints: <bundle size limit | IE support | print-friendly | offline | color-blind safe>
```

If the user hasn't specified, ask: "What story should this visualization tell? Who is the audience?"

### Step 2: Chart Type Selection
Select the optimal chart type based on the data and communication goal:

```
CHART TYPE SELECTION:
┌─────────────────────┬──────────────────────────────────────────────────────┐
│  Goal               │  Recommended Chart Types                            │
├─────────────────────┼──────────────────────────────────────────────────────┤
│  Compare values     │  Bar (vertical/horizontal), Grouped bar, Lollipop   │
│  Show trends        │  Line, Area, Sparkline, Step                        │
│  Show distribution  │  Histogram, Box plot, Violin, Density               │
│  Show correlation   │  Scatter, Bubble, Heatmap (correlation matrix)      │
│  Show composition   │  Stacked bar, Treemap, Sunburst, Waffle             │
│  Show flow/process  │  Sankey, Alluvial, Chord diagram                    │
│  Show hierarchy     │  Treemap, Sunburst, Dendrogram, Circle packing      │
│  Show geographic    │  Choropleth, Bubble map, Hex bin map                │
│  Show part-to-whole │  Donut, Stacked area, Marimekko                     │
│  Show ranking       │  Horizontal bar, Bump chart, Slope graph            │
│  Show time series   │  Line, Candlestick, Calendar heatmap               │
```

Rules:
- Never use pie charts for more than 5 categories — use bar charts instead
- Never use 3D charts — they distort perception and reduce accuracy
- Use line charts only for continuous data (time series) — not categorical
- Prefer horizontal bar charts when labels are long
- Use small multiples over complex multi-series charts when series exceed 5

### Step 3: Library Selection & Setup
Choose the right visualization library for the project:

```
LIBRARY SELECTION:
┌──────────────┬──────────────────────┬──────────────┬──────────────────────┐
│  Library     │  Best For            │  Bundle Size │  Learning Curve      │
├──────────────┼──────────────────────┼──────────────┼──────────────────────┤
│  D3.js       │  Custom, complex,    │  ~90KB       │  Steep — full control│
│              │  unique visualizations│             │  over every pixel    │
├──────────────┼──────────────────────┼──────────────┼──────────────────────┤
│  Chart.js    │  Standard charts,    │  ~60KB       │  Low — declarative   │
│              │  quick setup, canvas │              │  config-based API    │
├──────────────┼──────────────────────┼──────────────┼──────────────────────┤
│  Recharts    │  React dashboards,   │  ~120KB      │  Low — React-native  │
│              │  composable charts   │              │  component API       │
├──────────────┼──────────────────────┼──────────────┼──────────────────────┤
│  Plotly      │  Scientific/data     │  ~1MB        │  Medium — rich       │
│              │  analysis, 3D plots  │              │  interactive charts  │
```

### Step 4: Data Transformation
Prepare data for the selected chart type:

```
DATA TRANSFORMATION:
Source format: <raw data shape — e.g., array of objects, CSV rows, nested JSON>
Target format: <what the chart library expects>

Transformations needed:
  1. <transformation — e.g., group by category, aggregate sum>
  2. <transformation — e.g., pivot rows to columns>
  3. <transformation — e.g., normalize to percentages>
  4. <transformation — e.g., sort descending by value>
  5. <transformation — e.g., compute rolling average>

Missing data strategy: <omit | zero-fill | interpolate | show gap>
Outlier handling: <include | cap at percentile | separate series>
Date parsing: <format — e.g., ISO 8601, Unix timestamp>

Sample transformed data:
  <3-5 rows of the transformed data structure>
```

Generate the transformation code:
```typescript
// Data transformation pipeline
function transformData(raw: RawData[]): ChartData {
  return raw
    .filter(/* remove invalid entries */)
    .map(/* reshape to chart format */)
    .sort(/* order for readability */)
# ... (condensed)
```

### Step 5: Chart Implementation
Build the chart with full configuration:

```
CHART CONFIGURATION:
┌─────────────────────────────────────────────────────────────────────┐
│  Property              │  Value                                     │
├────────────────────────┼────────────────────────────────────────────┤
│  Type                  │  <bar | line | scatter | heatmap | ...>   │
│  Width                 │  <responsive | fixed px>                   │
│  Height                │  <responsive | fixed px>                   │
│  Aspect ratio          │  <16:9 | 4:3 | 1:1 | custom>             │
│  Margins               │  top=<N> right=<N> bottom=<N> left=<N>   │
│  Colors                │  <palette name or hex values>              │
│  Font family           │  <system | project font>                  │
│  Animation             │  <none | enter | update | transition>     │
│  Legend                 │  <position: top | right | bottom | none> │
│  Tooltip               │  <format and fields>                      │
│  Axis X                │  <label, format, ticks, rotation>         │
│  Axis Y                │  <label, format, ticks, domain>           │
│  Grid lines            │  <horizontal | vertical | both | none>    │
│  Annotations           │  <threshold lines, labels, callouts>      │
│  Interactions          │  <hover | click | brush | zoom | pan>     │
└────────────────────────┴────────────────────────────────────────────┘
```

#### D3.js Implementation Pattern
```typescript
import * as d3 from 'd3';

function createChart(container: HTMLElement, data: ChartData[], options: ChartOptions) {
  const { width, height, margin } = options;
  const innerWidth = width - margin.left - margin.right;
  const innerHeight = height - margin.top - margin.bottom;
# ... (condensed)
```

#### Recharts Implementation Pattern
```tsx
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

function Chart({ data }: { data: ChartData[] }) {
  return (
    <ResponsiveContainer width="100%" height={400}>
      <BarChart data={data} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
# ... (condensed)
```

### Step 6: Responsive Design
Ensure charts work across all viewport sizes:

```
RESPONSIVE STRATEGY:
┌──────────────────┬──────────────┬──────────────────────────────────────────┐
│  Breakpoint      │  Width       │  Adaptations                             │
├──────────────────┼──────────────┼──────────────────────────────────────────┤
│  Mobile          │  < 480px     │  Stack legend below, reduce tick count,  │
│                  │              │  hide secondary axes, enlarge touch       │
│                  │              │  targets, swap to simplified chart type   │
├──────────────────┼──────────────┼──────────────────────────────────────────┤
│  Tablet          │  480-1024px  │  Side legend, moderate tick density,     │
│                  │              │  full interactivity                       │
├──────────────────┼──────────────┼──────────────────────────────────────────┤
│  Desktop         │  > 1024px    │  Full layout, all annotations visible,   │
│                  │              │  hover tooltips, brush/zoom enabled       │
└──────────────────┴──────────────┴──────────────────────────────────────────┘

```

### Step 7: Color & Accessibility
Design accessible visualizations that work for everyone:

```
ACCESSIBILITY CHECKLIST:
┌──────────────────────────────────────────────────────────────────────┐
│  Check                                           │  Status           │
├──────────────────────────────────────────────────┼───────────────────┤
│  Color contrast ratio >= 3:1 against background  │  PASS | FAIL     │
│  Colorblind-safe palette (no red/green only)     │  PASS | FAIL     │
│  Patterns/textures as secondary differentiator   │  PASS | FAIL     │
│  aria-label on chart container (SVG role="img")  │  PASS | FAIL     │
│  Data table alternative available                │  PASS | FAIL     │
│  Keyboard navigable (focus on data points)       │  PASS | FAIL     │
│  Screen reader descriptions for trends           │  PASS | FAIL     │
│  Tooltip accessible via keyboard (not hover-only)│  PASS | FAIL     │
│  Text labels minimum 12px font size              │  PASS | FAIL     │
│  No information conveyed by color alone          │  PASS | FAIL     │
│  Reduced motion support (@prefers-reduced-motion)│  PASS | FAIL     │
```

### Step 8: Dashboard Composition
When building multi-chart dashboards, apply layout principles:

```
DASHBOARD DESIGN:
Layout: <grid columns — e.g., 12-column grid>
Sections:
  1. <KPI row — number cards with sparklines>
  2. <Primary chart — largest, most important visualization>
  3. <Supporting charts — 2-3 smaller charts providing context>
  4. <Detail table — filterable data table for drill-down>

DASHBOARD PRINCIPLES:
  1. Most important metric is top-left (F-pattern reading)
  2. KPI cards first — give the executive summary before details
  3. Max 7 ± 2 charts per dashboard (cognitive load limit)
  4. Consistent color encoding across all charts (same color = same category)
  5. Linked interactions — filtering one chart filters all charts
  6. Date range selector affects all charts simultaneously
```

### Step 9: Performance Optimization
Ensure charts render efficiently with large datasets:

```
PERFORMANCE STRATEGIES:
┌───────────────────┬─────────────────────────────────────────────────┐
│  < 1,000 points   │  Render all — no optimization needed            │
│  1K - 10K points  │  Canvas rendering (not SVG), debounce tooltips  │
│  10K - 100K points│  Data aggregation, LTTB downsampling, WebGL     │
│  > 100K points    │  Server-side aggregation, WebGL (deck.gl)       │
└───────────────────┴─────────────────────────────────────────────────┘

Key techniques: Canvas over SVG for > 1K points, LTTB downsampling for time series,
IntersectionObserver for lazy-loading, useMemo for data transforms, Web Workers for heavy processing.
```

### Step 10: Validation & Delivery
Validate the visualization and produce deliverables:

```
VISUALIZATION VALIDATION:
┌──────────────────────────────────────────────────────┬──────────────┐
│  Check                                               │  Status      │
├──────────────────────────────────────────────────────┼──────────────┤
│  Chart type matches data and communication goal      │  PASS | FAIL │
│  Data transformations produce correct output          │  PASS | FAIL │
│  Responsive at mobile, tablet, desktop breakpoints   │  PASS | FAIL │
│  Accessibility checklist complete (all items pass)    │  PASS | FAIL │
│  Color palette is colorblind-safe                    │  PASS | FAIL │
│  Performance acceptable at expected data volume      │  PASS | FAIL │
│  Tooltips show correct formatted values              │  PASS | FAIL │
│  Axis labels and titles are clear and formatted      │  PASS | FAIL │
│  Legend is present and correctly maps to data series  │  PASS | FAIL │
│  No misleading scale (y-axis starts at 0 for bars)  │  PASS | FAIL │
│  Loading and error states handled                    │  PASS | FAIL │
│  Data table alternative provided for screen readers  │  PASS | FAIL │
└──────────────────────────────────────────────────────┴──────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

Produce deliverables:

```
VISUALIZATION COMPLETE:

Artifacts:
- Chart component: src/components/charts/<ChartName>.tsx
- Data transformer: src/utils/chart-data/<transformer>.ts
- Dashboard layout: src/pages/<dashboard>.tsx (if dashboard)
- Storybook story: src/components/charts/<ChartName>.stories.tsx
- Tests: src/components/charts/__tests__/<ChartName>.test.tsx

Validation: <PASS | NEEDS REVISION>
Chart type: <type>
Library: <library>
Data points: <N>
Responsive: <yes — tested at 320px, 768px, 1440px>
Accessible: <yes — all 12 checks pass>
```

Commit: `"chart: <component> — <chart type>, <library>, <N> data series, responsive + accessible"`

## Key Behaviors

1. **Data story first, chart second.** Understand what the visualization needs to communicate before selecting a chart type. The chart is a means, not an end.
2. **Accessibility is not optional.** Every chart must have a data table alternative, colorblind-safe palette, and screen reader support. No exceptions.
3. **Responsive by default.** Charts must work on mobile. If a chart cannot adapt to a small screen, provide a simplified alternative.
4. **Performance scales with data.** Do not render 100K SVG nodes. Match the rendering strategy to the data volume.
5. **Consistent dashboards.** All charts in a dashboard use the same color encoding, typography, and interaction patterns.
6. **No misleading visualizations.** Bar charts start at 0. Dual axes are labeled clearly. Truncated axes are flagged.
7. **Color is not the only channel.** Use patterns, labels, and position in addition to color. Information must be perceivable without color vision.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full chart design and implementation workflow |
| `--type <chart>` | Force chart type: `bar`, `line`, `scatter`, `heatmap`, `treemap`, `sankey`, `pie`, `area` |
| `--lib <library>` | Force library: `d3`, `chartjs`, `recharts`, `plotly`, `nivo`, `victory` |

## HARD RULES

1. **NEVER use pie charts for more than 5 categories.** No exceptions. Use bar charts instead.
2. **NEVER use 3D charts.** They distort data and add no information.
3. **NEVER ship without a data table alternative** for screen readers.
4. **NEVER start bar chart y-axis above zero** unless explicitly documented with justification.
5. **ALWAYS test at 320px, 768px, and 1440px** before marking responsive as done.
6. **ALWAYS verify colorblind safety** with Chrome DevTools vision deficiency emulation.
7. **git commit BEFORE verify** — commit the chart component, then run visual/a11y tests.
8. **TSV logging** — log every chart creation:
   ```
   timestamp	chart_type	library	data_points	responsive	a11y_score	status
   ```

## Auto-Detection

On activation, automatically detect project context without asking:

```
AUTO-DETECT:
1. Framework:
   ls package.json 2>/dev/null && grep -o '"react"\|"vue"\|"angular"\|"svelte"' package.json
   # Determines component style and library compatibility

2. Existing chart libraries:
   grep -r "recharts\|chart.js\|d3\|plotly\|nivo\|victory" package.json 2>/dev/null
   # Prefer existing library over introducing a new one

3. Design system:
   ls src/theme* src/styles/tokens* tailwind.config* 2>/dev/null
   # Extract color palette, font family, spacing tokens

4. Data source:
   # Scan for API clients, GraphQL queries, or static data files
```

## Output Format

After each chart skill invocation, emit a structured report:

```
CHART BUILD REPORT:
┌──────────────────────────────────────────────────────┐
│  Charts created     │  <N>                            │
│  Charts updated     │  <N>                            │
│  Library used       │  <library name>                 │
│  Data points        │  <N> total across all charts    │
│  Responsive         │  YES / NO                       │
│  A11y (data table)  │  YES / NO                       │
│  Colorblind-safe    │  YES / NO                       │
│  Bundle impact      │  +<N> KB (gzipped)              │
│  Render time        │  <N> ms (largest chart)         │
│  Verdict            │  PASS | NEEDS REVISION          │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every chart creation for tracking:

```
timestamp	skill	chart_type	library	data_points	render_ms	a11y_table	status
2026-03-20T14:00:00Z	chart	bar	recharts	240	45	yes	pass
2026-03-20T14:05:00Z	chart	line	d3	12000	180	yes	pass
```

## Success Criteria

The chart skill is complete when ALL of the following are true:
1. Chart renders correctly with real or representative data
2. Chart is responsive (resizes without distortion on mobile through desktop)
3. A data table alternative exists for screen reader accessibility
4. Color palette is colorblind-safe (tested with a simulator or verified palette)
5. Axes are labeled with units, and the chart has a descriptive title
6. Tooltips show exact values on hover/touch
7. Chart respects `prefers-reduced-motion` (no gratuitous animation)
8. Bundle size impact is documented and within project budget

## Error Recovery

```
IF chart renders blank or does not appear:
  1. Check browser console for errors (missing data, wrong data shape)
  2. Verify data is loaded before chart mounts (check async data fetching)
  3. Confirm container has explicit width/height (many libraries require this)
  4. Test with hardcoded sample data to isolate data vs rendering issue

IF chart is too slow (> 500ms render):
  1. Check data point count — if > 1000, switch to canvas/WebGL renderer
  2. Enable data decimation or sampling for time series
  3. Debounce resize handlers to prevent layout thrashing
  4. Use virtualization for very large datasets

IF colors fail colorblind simulation:
  1. Switch to a verified colorblind-safe palette (e.g., Okabe-Ito, ColorBrewer)
  2. Add patterns or shapes in addition to color differentiation
```

## Data Visualization Audit Loop

Autoresearch-grade iterative audit for data visualization quality. Covers rendering performance, accessibility compliance, and responsive behavior through measured, repeatable cycles.

```
DATA VISUALIZATION AUDIT PROTOCOL:

Phase 1 — Rendering Performance Audit
  targets:
    Initial render: < 100ms for < 1K data points
    Initial render: < 500ms for 1K-10K data points
    Interaction response (tooltip, hover): < 50ms
    Resize/redraw: < 100ms
    Memory usage: no leaks on repeated re-renders
  current_iteration = 0
  max_iterations = 8

  FOR EACH chart/visualization in the application:
    1. MEASURE initial render time:
       - Browser DevTools Performance tab → record page load
```

## Keep/Discard Discipline
```
After EACH chart implementation or optimization:
  1. MEASURE: Render time, accessibility checks (12-point checklist), responsive behavior at 320/768/1440px.
  2. COMPARE: Did rendering performance stay within targets? Did accessibility score hold or improve?
  3. DECIDE:
     - KEEP if: renders within target time AND all a11y checks pass AND responsive at all breakpoints
     - DISCARD if: render time exceeds target OR accessibility regresses OR layout breaks at any breakpoint
  4. COMMIT kept changes. Revert discarded changes before the next chart.

Never keep a chart optimization that breaks colorblind safety or removes the data table alternative.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All charts render within performance targets (< 100ms for < 1K points, < 500ms for 1K-10K)
  - All 12 accessibility checks pass for every chart
  - Charts are responsive at 320px, 768px, and 1440px
  - User explicitly requests stop

DO NOT STOP just because:
  - One chart type is complex to make responsive (provide a simplified mobile version)
  - Colorblind palette looks less appealing than the original (accessibility is non-negotiable)
```
