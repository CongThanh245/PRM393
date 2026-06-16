# UI / Widgets Layer

> Reusable, self-contained presentational components. No direct Provider access — all
> data passed via constructor parameters.

## Files

### `lib/widgets/trend_chart.dart`

**Summary:** fl_chart `LineChart` rendering publication or citation counts over time with a peak-year vertical annotation line.
**Complexity:** high | **Tags:** ui, widget, chart

**Key class:** `TrendChart`

**Props:**
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `points` | `List<TrendPoint>` | required | x/y data series |
| `color` | `Color?` | theme primary | Line and fill color |
| `unit` | `String` | `'papers'` | Y-axis label unit |
| `showPeakLine` | `bool` | `true` | Whether to draw peak-year annotation |

**Key implementation details:**

| Detail | Solution |
|--------|----------|
| X-axis label misalignment | `interval: 1` + pre-computed `Set<int>` of 5 evenly-distributed actual data years |
| Y-axis overcrowding | `_yInterval()` scales dynamically (1 ≤5, 10 ≤60, 100 ≤600, …) |
| Single-point edge case | `minX = year − 1`, `maxX = year + 1` |
| Curve vs segments | `isCurved: sortedPoints.length > 2` |
| Label clipping | `clipData: const FlClipData.all()` |
| Fill area | Gradient from `color.0.18` to transparent |
| Peak annotation | `ExtraLinesData(verticalLines: [VerticalLine(dashArray:[5,5], label: 'Peak YYYY')])` |

---

### `lib/widgets/donut_chart.dart`

**Summary:** Interactive fl_chart `PieChart` donut with a tap-to-highlight legend and center label showing total or selected slice value.
**Complexity:** high | **Tags:** ui, widget, chart

**Key classes:** `DonutChart` (StatefulWidget), `DonutSlice`

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| `slices` | `List<DonutSlice>` | Data items (label, value, color) |
| `centerLabel` | `String?` | Label shown below the total in the donut center |

**Layout strategy (responsive via `LayoutBuilder`):**
- **Wide** (`availW ≥ 160 + 20 + 100`): `Row` with pie (`SizedBox 160×160`) on the left + `Expanded(Column(legendItems))` on the right. The `Expanded` legend fills the remaining card-content width so percentage values right-align to the same edge as leaderboard values in adjacent cards.
- **Narrow**: stacked `Column` — `Center(pie)` above `Center(legendBox)`.

**Legend item structure:**
```
[AnimatedDot] [Expanded(label, ellipsis)] [SizedBox(30, '%', right-align)]
```
The fixed-width `SizedBox(30)` keeps all `%` values column-aligned.

**Touch interaction:** `PieTouchData` highlights the tapped slice (radius 62 vs 50), bolds the legend row, and updates the center label/value.

---

### `lib/widgets/horizontal_bar_chart.dart`

**Summary:** Horizontal bar chart for ranked categorical data (keywords, journals, authors, countries, institutions).
**Complexity:** medium | **Tags:** ui, widget, chart

**Key classes:** `HorizontalBarChart`, `BarItem`

**Props:** `items: List<BarItem>`, `color: Color`, `maxItems: int`

**Layout:** `ListView` of rows — label text + proportional colored bar + count value. Bar width = `item.value / maxValue * availableWidth`.

---

### `lib/widgets/scatter_plot_widget.dart`

**Summary:** fl_chart `ScatterChart` plotting output (x) vs impact/citations (y) for author analysis.
**Complexity:** medium | **Tags:** ui, widget, chart

**Key class:** `ScatterPlotWidget`

**Props:** `points: List<AuthorImpact>`, `color: Color`

---

### `lib/widgets/metric_tile.dart`

**Summary:** KPI card with a colored left-accent strip, icon badge, label, and bold value. Used in all screen KPI grids.
**Complexity:** low | **Tags:** ui, widget

**Key class:** `MetricTile`

**Props:** `icon: IconData`, `label: String`, `value: String`, `iconColor: Color`, `subtitle: String?`

**Layout:** `Card(elevation:0, clip:antiAlias)` with `Stack` — `Positioned(left:0, top:0, bottom:0, width:3)` draws the accent bar; `Padding(fromLTRB(15,11,14,11))` holds the content column. Accent bar has `BorderRadius.only(topLeft, bottomLeft)` so it stays inside the card's rounded corners.

**Value style:** 18 px `FontWeight.w800` `#1E293B` (dark, not color-tinted) in Space Grotesk.

---

### `lib/widgets/insight_note.dart`

**Summary:** Callout box surfacing a data insight with a strong left-accent strip, icon, and optional bold label prefix.
**Complexity:** low | **Tags:** ui, widget

**Key class:** `InsightNote`

**Props:** `text: String`, `icon: IconData`, `color: Color?`, `label: String?`

**Layout:** `ClipRRect(r:8)` → `Container(Border.all uniform)` → `IntrinsicHeight(Row(stretch))` → `[Container(w:3, accent) | Expanded(Padding(Row(icon + RichText)))]`

**Why `ClipRRect` + `Border.all`:** Flutter throws "A borderRadius can only be given on borders with uniform colors" if `BoxDecoration` combines `borderRadius` with a `Border` that has different colors per side. `ClipRRect` handles rounding; `Border.all` (single uniform color) satisfies the constraint. The left accent is a separate `Container(width:3)`.

---

### `lib/widgets/year_range_filter.dart`

**Summary:** Row of year-chip toggles for client-side filtering. Reads and writes `ResearchProvider.setYearRange()`.
**Complexity:** low | **Tags:** ui, widget, filter

**Key class:** `YearRangeFilter`

**Behavior:** Derives available year range from `provider.publications`, renders chips for start/end years. Active selection highlighted in primary color.

---

### `lib/widgets/publication_card.dart`

**Summary:** Tappable `Card` displaying a publication's title, year, citation count, and journal — with citation count color-coded by magnitude.
**Complexity:** medium | **Tags:** ui, widget, card

**Key classes:** `PublicationCard`, `_Chip` (private)

**Citation color scale:**
| Count | Background | Foreground | Meaning |
|-------|------------|------------|---------|
| > 500 | amber `#FEF3C7` | `#B45309` | Highly cited |
| > 50 | green `#ECFDF5` | `#047857` | Well cited |
| > 5 | blue `#EFF6FF` | `#1D4ED8` | Moderately cited |
| ≤ 5 | slate `#F1F5F9` | `#475569` | Low citations |

**Props:** `publication: Publication`, `onTap: VoidCallback`

---

### `lib/widgets/ranked_stat_list.dart`

**Summary:** Leaderboard `ListView` with rank badge circles, name + progress bar, and count pill. Medal colors for top 3.
**Complexity:** medium | **Tags:** ui, widget, list

**Key classes:** `RankedStatList`, `RankedStatItem`

**Medal system:**
| Rank | Badge bg | Badge fg | Bar color |
|------|----------|----------|-----------|
| 1 | `#FEF3C7` (gold) | `#B45309` | `#F59E0B` |
| 2 | `#F1F5F9` (silver) | `#64748B` | `#94A3B8` |
| 3 | `#FFF1EE` (bronze) | `#C2410C` | `#F97316` |
| 4+ | `#F8FAFC` (slate) | `#94A3B8` | `#3B82F6` |

Progress bar width = `item.count / maxCount` (relative to top entry).

---

### `lib/widgets/empty_view.dart`

**Summary:** Centered column with a large icon, bold title, and subtitle message. Shown when no data is available.
**Complexity:** low | **Tags:** ui, widget, state

**Props:** `icon: IconData`, `title: String`, `message: String`

---

### `lib/widgets/error_view.dart`

**Summary:** Centered error indicator with message text and a "Retry" `ElevatedButton`.
**Complexity:** low | **Tags:** ui, widget, state

**Props:** `message: String`, `onRetry: VoidCallback`

---

### `lib/widgets/loading_view.dart`

**Summary:** Centered `CircularProgressIndicator` with an optional text message below.
**Complexity:** low | **Tags:** ui, widget, state

**Props:** `message: String`

## Layer Relationships

Widgets import only from the Data/models layer (`Publication`, `TrendPoint`, `DonutSlice`, etc.) — never from State or other screens. This keeps them pure presentational components that can be composed and reused without Provider coupling. Navigation callbacks (`onTap`) are passed in from screens as `VoidCallback`, keeping routing logic at the screen level.
