# Architecture

## System Overview

Journal Trend Analyzer follows a **layered architecture** with unidirectional data flow:

```
OpenAlex API
     ↓ HTTP
 OpenAlexService
     ↓ delegates
 PublicationRepository
     ↓ calls
 ResearchProvider  ←→  AnalyticsCalculator
     ↓ context.watch
  UI Screens / Widgets
```

The pattern is: **Service → Repository → Provider → UI**, with pure utility classes
(`AnalyticsCalculator`, `AbstractParser`) doing stateless computation outside the
Provider to keep business logic testable in isolation.

---

## Layers

### Config

**Purpose:** Application bootstrap, theming, and environment configuration.

| File | Purpose | Complexity |
|------|---------|------------|
| `lib/main.dart` | Entry point — loads `.env`, wires DI chain, mounts app | low |
| `lib/app.dart` | Root `MaterialApp` with full Material 3 design system | medium |

**Key relationships:**
- `main.dart` constructs the entire dependency graph manually (no service locator): `OpenAlexService → PublicationRepository → ResearchProvider`.
- `app.dart` defines the global `ThemeData` (colors, fonts, card shapes) consumed by every widget in the tree.

---

### State

**Purpose:** Provider-based state management and business logic orchestration.

| File | Purpose | Complexity |
|------|---------|------------|
| `lib/providers/research_provider.dart` | Single ChangeNotifier; owns search state and derived analytics | medium |

**Key relationships:**
- Depends on `PublicationRepository` (data fetch) and `AnalyticsCalculator` (analytics derivation).
- All UI screens (`SearchScreen`, `DashboardScreen`, `AnalyticsScreen`) read from this provider via `context.watch<ResearchProvider>()`.
- Computed getters (`trends`, `journals`, `authors`, `influentialPapers`, `summary`) are derived lazily from `_publications` on every access — no caching needed for a 50-item list.

---

### Data

**Purpose:** External API integration, repository abstraction, and domain models.

| File | Purpose | Complexity |
|------|---------|------------|
| `lib/services/openalex_service.dart` | HTTP client — OpenAlex `/works` endpoint, retry logic | high |
| `lib/repositories/publication_repository.dart` | Thin adapter decoupling Provider from HTTP | low |
| `lib/models/publication.dart` | Core domain model — parses OpenAlex JSON, strips HTML | medium |
| `lib/models/dashboard_summary.dart` | Aggregate model for dashboard KPIs | low |
| `lib/models/trend_point.dart` | `{year, count}` value object for charting | low |
| `lib/models/journal_stat.dart` | `{name, publicationCount}` for journal rankings | low |
| `lib/models/author_stat.dart` | `{name, publicationCount}` for author rankings | low |

**Key relationships:**
- `OpenAlexService` is the **only** network boundary. It requests 50 works sorted by `cited_by_count:desc`, handles retries (3 attempts, exponential backoff, 30 s timeout), and maps HTTP errors to typed `OpenAlexException` messages.
- `Publication.fromJson()` strips `<i>` HTML tags from `display_name` (an OpenAlex quirk) and reconstructs abstracts from OpenAlex's inverted-index format.

---

### Utils

**Purpose:** Pure computation helpers with no Flutter or network dependencies.

| File | Purpose | Complexity |
|------|---------|------------|
| `lib/utils/analytics_calculator.dart` | Aggregation: trends, journal/author rankings, summary stats | medium |
| `lib/utils/abstract_parser.dart` | Converts OpenAlex inverted-index → plain text | low |

**Key relationships:**
- `AnalyticsCalculator` is called exclusively by `ResearchProvider`. Its static methods take `List<Publication>` and return typed result models.
- `parseAbstractInvertedIndex()` is called inside `Publication.fromJson()`.

---

### UI / Screens

**Purpose:** Full-page widgets composing the app's navigation tree.

| File | Purpose | Complexity |
|------|---------|------------|
| `lib/screens/home_shell.dart` | Root shell with bottom/side navigation | low |
| `lib/screens/search_screen.dart` | Search field, quick chips, publication list | medium |
| `lib/screens/dashboard_screen.dart` | KPI grid + trend chart | medium |
| `lib/screens/analytics_screen.dart` | Three-tab rankings view | medium |
| `lib/screens/publication_detail_screen.dart` | Single publication detail + selectable text | low |

**Key relationships:**
- `HomeShell` uses a `switch` (not `IndexedStack`) to swap screens — `IndexedStack` causes `GlobalKey` conflicts when `AnalyticsScreen`'s `TabBarView` coexists in the tree with `InkWell` cards in other screens.
- `SearchScreen` and `AnalyticsScreen` both push `PublicationDetailScreen` via `Navigator.push`.

---

### UI / Widgets

**Purpose:** Reusable, self-contained presentational components.

| File | Purpose | Complexity |
|------|---------|------------|
| `lib/widgets/trend_chart.dart` | fl_chart line chart with smart x-axis labeling | high |
| `lib/widgets/publication_card.dart` | Tappable card with semantic color-coded chips | medium |
| `lib/widgets/metric_tile.dart` | KPI card with icon badge + Fira Code value | low |
| `lib/widgets/ranked_stat_list.dart` | Leaderboard with medal badges + progress bars | medium |
| `lib/widgets/empty_view.dart` | Centered placeholder for empty states | low |
| `lib/widgets/error_view.dart` | Error state with Retry button | low |
| `lib/widgets/loading_view.dart` | Centered spinner with message | low |

---

## Dependency Flow

```
Config ──────────────────────────────────────────┐
  main.dart (DI wiring)                           │
  app.dart (theme)                                │
                                                  ▼
Data ────────────────► State ──────────────► UI Screens
  OpenAlexService          ResearchProvider      HomeShell
  Repository               (ChangeNotifier)      SearchScreen
  Publication (model)           │                DashboardScreen
  DashboardSummary         Utils │               AnalyticsScreen
  TrendPoint              AnalyticsCalculator    DetailScreen
  JournalStat             AbstractParser              │
  AuthorStat                                          ▼
                                               UI Widgets
                                               PublicationCard
                                               MetricTile
                                               TrendChart
                                               RankedStatList
                                               EmptyView / ErrorView / LoadingView
```

No circular dependencies exist between layers. All data flows downward: Config bootstraps State, State pulls from Data, UI reads from State.

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Provider over Riverpod/Bloc | Simplest approach for a single-provider, single-search-flow app. No generated code needed. |
| Repository pattern | Decouples `ResearchProvider` from `http`; swap to a different API or add caching without touching state logic. |
| Static utility classes | `AnalyticsCalculator` has no state and no Flutter deps — easy to unit test without `flutter_test`. |
| `switch` in HomeShell | Avoids `GlobalKey` duplicates caused by `IndexedStack` keeping all three screens alive simultaneously. |
| `interval: 1` in TrendChart | fl_chart places x-axis labels at multiples of `interval` from 0; using 1 with a pre-computed `Set<int>` of label years avoids misaligned labels. |
| API key via `api_key` query param | OpenAlex now requires a paid key via `?api_key=…`. `flutter_dotenv` keeps the key out of source control. |
