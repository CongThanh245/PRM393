# UI / Widgets Layer

> Reusable, self-contained presentational components. No direct Provider access — all
> data passed via constructor parameters.

## Files

### `lib/widgets/trend_chart.dart`

**Summary:** fl_chart `LineChart` widget rendering publication counts over time. The most technically complex widget in the codebase.
**Complexity:** high | **Tags:** ui, widget, chart

**Key class:** `TrendChart`

**Props:** `points: List<TrendPoint>`

**Key implementation details:**

| Detail | Solution |
|--------|----------|
| X-axis label misalignment | `interval: 1` + pre-computed `Set<int>` of 5 evenly-distributed actual data years |
| Y-axis overcrowding | `_yInterval()` scales dynamically (1 for ≤5, 10 for ≤60, etc.) |
| Single-point edge case | `minX = year - 1`, `maxX = year + 1` when only one data point |
| Curve vs segments | `isCurved: sortedPoints.length > 2` |
| Label clipping | `clipData: const FlClipData.all()` |
| Fill area | Gradient from `primary.withOpacity(0.18)` to transparent |

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

### `lib/widgets/metric_tile.dart`

**Summary:** KPI card with a colored icon badge at top, label below, and the metric value in Fira Code monospace.
**Complexity:** low | **Tags:** ui, widget

**Key class:** `MetricTile`

**Props:** `icon: IconData`, `label: String`, `value: String`, `iconColor: Color?`

**Layout:** Column — icon badge → label → value. Designed for a grid; works at any aspect ratio.

---

### `lib/widgets/ranked_stat_list.dart`

**Summary:** Leaderboard `ListView` with rank badge circles, name + progress bar, and count pill. Medal colors for top 3.
**Complexity:** medium | **Tags:** ui, widget, list

**Key classes:** `RankedStatList`, `RankedStatItem`

**Props:** `title: String`, `items: List<RankedStatItem>`

**Medal system:**
| Rank | Badge bg | Badge fg | Bar color |
|------|----------|----------|-----------|
| 1 | `#FEF3C7` (gold) | `#B45309` | `#F59E0B` |
| 2 | `#F1F5F9` (silver) | `#64748B` | `#94A3B8` |
| 3 | `#FFF1EE` (bronze) | `#C2410C` | `#F97316` |
| 4+ | `#F8FAFC` (slate) | `#94A3B8` | `#3B82F6` |

Progress bar width = `item.count / maxCount` (relative to the top entry).

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

Widgets import only from the Data/models layer (`Publication`, `TrendPoint`) — never
from State or other screens. This keeps them pure presentational components that can be
composed and reused without Provider coupling. Navigation callbacks (`onTap`) are
passed in from screens as `VoidCallback`, keeping routing logic at the screen level.
