# UI / Screens Layer

> Full-page screen widgets composing the app's navigation tree.

## Files

### `lib/screens/home_shell.dart`

**Summary:** Root navigation shell. Owns tab index state and renders one screen at a time via a `switch` expression. Adapts between `NavigationRail` (desktop ≥ 800 px) and `NavigationBar` (mobile).
**Complexity:** low | **Tags:** ui, navigation, shell, responsive

**Key class:** `HomeShell` (StatefulWidget)

**Navigation destinations:**

| Index | Label | Screen |
|-------|-------|--------|
| 0 | Search | `SearchScreen` |
| 1 | Dashboard | `DashboardScreen` |
| 2 | Trends | `TrendsScreen` |
| 3 | Rankings | `AnalyticsScreen` |

**Responsive layout:**
- `maxWidth >= 800` → `NavigationRail` sidebar + `VerticalDivider` + `Expanded(screen)`
- `maxWidth < 800` → `Scaffold(body, bottomNavigationBar: NavigationBar)`

**Why `switch` and not `IndexedStack`:**
`IndexedStack` keeps all screens alive simultaneously. `AnalyticsScreen` registers a `DefaultTabController` `GlobalKey`; coexisting `InkWell`/`Card` in other screens register `_InkFeatures` keys. Flutter throws a duplicate-key exception at runtime. The `switch` mounts only one screen, eliminating the conflict.

---

### `lib/screens/search_screen.dart`

**Summary:** Primary search interface. `CustomScrollView` with pinned `SliverAppBar`, text field, 8 animated quick-topic chips, search button, and a state-driven results area.
**Complexity:** medium | **Tags:** ui, screen, search

**Key class:** `SearchScreen` (StatefulWidget)

**Behaviors:**
- `TextEditingController` initialized from `provider.keyword` in `initState()` — preserves text across tab switches.
- Quick-topic chips animate between active (primary color) and inactive states using `AnimatedContainer`.
- Results area is a `switch` on `ResearchStatus`: `idle` → `EmptyView`, `loading` → `LoadingView`, `empty` → `EmptyView`, `error` → `ErrorView`, `success` → `SliverList<PublicationCard>`.

**Navigation:** Taps on `PublicationCard` push `PublicationDetailScreen` via `Navigator.push`.

---

### `lib/screens/dashboard_screen.dart`

**Summary:** Overview screen showing KPI metrics and 4–5 chart cards across two responsive rows.
**Complexity:** high | **Tags:** ui, screen, dashboard, responsive

**Key classes:** `DashboardScreen`, `_SectionCard`, `_FilterHeader` (all private)

**Layout constants:**
| Constant | Value | Purpose |
|----------|-------|---------|
| `_kGap` | `16.0` | Standard spacing between sections |
| `_kGapSm` | `10.0` | Tight spacing (KPI grid rows) |
| `_kMaxContentWidth` | `1400.0` | `ConstrainedBox` cap for ultra-wide screens |
| `_kChartHeight` | `252.0` | Uniform chart content height across all cards |

**KPI metrics grid:**
| Metric | Icon | Color |
|--------|------|-------|
| Publications | `article_outlined` | `#1D4ED8` blue |
| Avg citations | `format_quote` | `#D97706` amber |
| Most active year | `calendar_today_outlined` | `#059669` green |
| Top venue | `location_city_outlined` | `#7C3AED` purple |
| Top author | `person_outlined` | `#2563EB` blue |
| Top paper | `emoji_events_outlined` | `#EA580C` orange |

**Responsive KPI grid:** `LayoutBuilder` drives `crossAxisCount`: ≤480 → 2 cols, ≤720 → 3 cols, wider → 3 cols. `childAspectRatio = (contentWidth − (n−1)×spacing) / n / 100` so each tile is exactly 100 px tall.

**Chart layout (wide ≥ 900 px):**
- Row 1: `pubTrendCard` (flex 6, `TrendChart`) + `donutCard` (flex 4, `DonutChart`) — same height via shared `_kChartHeight`
- Row 2: `citTrendCard` (50%) + `keywordsCard` (50%)
- Row 3: `countriesCard` (full width)

**Chart layout (narrow):** All cards stacked vertically.

**`_SectionCard` widget:**
- `Card(elevation:0, clipBehavior: antiAlias, BorderSide(#E8EDF5))`
- Header container: `BoxDecoration(color: iconColor.0.03, border: Border(top: accentColor 2.5px, bottom: #EEF2FF))` — no `borderRadius` on this container (avoids Flutter's non-uniform border color restriction)
- Body: `Padding(fromLTRB(16,14,16,16), child: child)`

**`_FilterHeader` widget:** Inline icon-pill label + `YearRangeFilter` chips.

**InsightNote:** Shown when 5-year growth rate can be computed. Color-coded green/red with icon.

---

### `lib/screens/trends_screen.dart`

**Summary:** Dedicated trends deep-dive screen with KPI tiles, year filter, insight note, and 4 chart cards (publication activity, citation activity, top keywords, research by country).
**Complexity:** high | **Tags:** ui, screen, trends, responsive

**Key classes:** `TrendsScreen`, `_FilterRow`, `_Section` (all private)

**Layout:** Mirrors dashboard structure — same `ConstrainedBox(1400)`, same `_Section` card style (top accent + divider), same `_kChartH = 252`.

**KPI tiles:**
| Metric | Color |
|--------|-------|
| Publications (filtered count) | `#1D4ED8` |
| Total citations | `#D97706` |
| Peak year | `#059669` |
| 5-yr growth rate | green or red |

**Responsive breakpoints:** `isWide > 900` → 2-column chart row; `isMed > 560` → 4-col KPI grid.

---

### `lib/screens/analytics_screen.dart`

**Summary:** Five-tab deep-dive ranking screen with charts, leaderboards, and scatter plots. Includes CSV export to clipboard.
**Complexity:** high | **Tags:** ui, screen, analytics, tabs

**Key classes:** `AnalyticsScreen`, `_ChartSection`, `_AnalyticsFilterHeader`, `_JournalsTab`, `_AuthorsTab`, `_KeywordsTab`, `_InstitutionsTab`, `_PapersTab`

**Tabs:**

| Tab | Key content |
|-----|------------|
| Journals | `DonutChart` (top 6 share) + `HorizontalBarChart` (top 20) + leaderboard |
| Authors | `DonutChart` (top 6 share) + `HorizontalBarChart` + `ScatterPlotWidget` (output vs impact) |
| Keywords | `DonutChart` (top 6 concepts) + `HorizontalBarChart` (top 20 keywords) |
| Institutions | `HorizontalBarChart` (top 20) + `InsightNote` |
| Top Papers | `MetricTile` grid + `ListView<PublicationCard>` sorted by citations |

**Export:** `IconButton` in AppBar calls `AnalyticsCalculator.exportCsv()` → `Clipboard.setData()` → `SnackBar` confirmation.

**`_ChartSection` widget:** Same visual style as dashboard `_SectionCard` (top accent, divider, body padding).

**`_AnalyticsFilterHeader`:** Inline year-filter header used in Papers tab.

---

### `lib/screens/publication_detail_screen.dart`

**Summary:** Full-detail view of a single publication. All content is wrapped in `SelectionArea` for copyable text.
**Complexity:** low | **Tags:** ui, screen, detail

**Displayed fields:** Title, authors (comma-joined), publication year, citation count, journal name, DOI (tappable link), abstract text.

**Dependencies:**
- Imports: `publication.dart`
- Pushed from: `search_screen.dart`, `analytics_screen.dart`

## Layer Relationships

All screens depend on `ResearchProvider` (State layer) via `context.watch<ResearchProvider>()`. `SearchScreen` and `AnalyticsScreen` both push `PublicationDetailScreen`. Screens render widgets from the UI/Widgets layer. No screen imports another screen directly except the push navigation to `PublicationDetailScreen`.
