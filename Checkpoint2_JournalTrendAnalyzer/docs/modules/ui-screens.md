# UI / Screens Layer

> Full-page screen widgets composing the app's navigation tree.

## Files

### `lib/screens/home_shell.dart`

**Summary:** Root navigation shell. Owns tab index state and renders exactly one screen at a time via a `switch` expression.
**Complexity:** low | **Tags:** ui, navigation, shell

**Key class:** `HomeShell` (StatefulWidget)

**Navigation destinations:** Search (index 0) | Dashboard (index 1) | Analytics (index 2)

**Why `switch` and not `IndexedStack`:**
`IndexedStack` keeps all three screens alive simultaneously. `AnalyticsScreen` registers a `DefaultTabController` `GlobalKey`, and screens with `InkWell`/`Card` register `_InkFeatures` keys. Flutter throws a duplicate-key exception at runtime. The `switch` mounts only one screen, eliminating the conflict.

**Responsive plan:** On wide screens (>= 800 px), replace `NavigationBar` with a `NavigationRail` sidebar.

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

**Summary:** Overview screen showing 6 KPI metrics and a yearly publication trend chart.
**Complexity:** medium | **Tags:** ui, screen, dashboard

**Key classes:** `DashboardScreen`, `_TrendCard` (private)

**Responsive grid:** `LayoutBuilder` switches between 2 columns (`maxWidth <= 600`) and 3 columns (wider). This responds to widget width, not screen width — correct behavior on tablets and split-screen.

**Metric tiles and colors:**
| Metric | Icon color |
|--------|------------|
| Publications | `#1E40AF` (deep blue) |
| Avg citations | `#D97706` (amber) |
| Active year | `#059669` (green) |
| Top venue | `#7C3AED` (purple) |
| Top author | `#2563EB` (blue) |
| Top paper | `#EA580C` (orange) |

---

### `lib/screens/analytics_screen.dart`

**Summary:** Three-tab deep-dive view: top journals, top authors, and most influential papers. Tabs are capped at top 20 entries.
**Complexity:** medium | **Tags:** ui, screen, analytics

**Key class:** `AnalyticsScreen` (StatelessWidget)

**Tabs:**
- **Journals** → `RankedStatList` with journal publication counts
- **Authors** → `RankedStatList` with author publication counts
- **Papers** → `ListView` of `PublicationCard` sorted by citations

Uses `DefaultTabController` (length 3) + `TabBarView`. Must be mounted as a full `Scaffold` with `AppBar(bottom: TabBar(...))`.

---

### `lib/screens/publication_detail_screen.dart`

**Summary:** Full-detail view of a single publication. All content is wrapped in `SelectionArea` for copyable text.
**Complexity:** low | **Tags:** ui, screen, detail

**Displayed fields:** Title, authors (comma-joined), publication year, citation count, journal name, DOI (tappable link), abstract text.

**Dependencies:**
- Imports: `publication.dart`
- Pushed from: `search_screen.dart`, `analytics_screen.dart`

## Layer Relationships

All screens depend on `ResearchProvider` (State layer). `SearchScreen` and
`AnalyticsScreen` both route to `PublicationDetailScreen`. Screens render
widgets from the UI/Widgets layer. No screen imports another screen directly
except the push navigation to `PublicationDetailScreen`.
