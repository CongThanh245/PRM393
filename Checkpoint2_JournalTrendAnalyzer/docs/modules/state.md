# State Layer

> Provider-based state management and business logic orchestration.

## Files

### `lib/providers/research_provider.dart`

**Summary:** The single source of truth for the entire app. A `ChangeNotifier` that manages the search lifecycle and exposes computed analytics via derived getters.
**Complexity:** medium | **Tags:** state, provider, business-logic

**Key class:** `ResearchProvider`
**Key enum:** `ResearchStatus { idle, loading, success, empty, error }`

**Public interface:**

| Member | Type | Description |
|--------|------|-------------|
| `status` | `ResearchStatus` | Current search lifecycle state |
| `keyword` | `String` | Last searched keyword |
| `publications` | `List<Publication>` | Raw results from OpenAlex |
| `errorMessage` | `String?` | Error detail when status is error |
| `trends` | `List<TrendPoint>` | Publications grouped by year |
| `journals` | `List<JournalStat>` | Journals ranked by publication count |
| `authors` | `List<AuthorStat>` | Authors ranked by publication count |
| `influentialPapers` | `List<Publication>` | Sorted by citation count descending |
| `summary` | `DashboardSummary` | Aggregate of all analytics |
| `search(keyword)` | `Future<void>` | Triggers a new search |

**State machine:**
```
idle → loading → success
              → empty
              → error → loading (retry)
```

**Dependencies:**
- Depends on: `PublicationRepository`, `AnalyticsCalculator`
- Uses models: `Publication`, `DashboardSummary`, `JournalStat`, `AuthorStat`, `TrendPoint`
- Consumed by: `SearchScreen`, `DashboardScreen`, `AnalyticsScreen` via `context.watch<ResearchProvider>()`

## Layer Relationships

This is the central hub — every screen reads from it, and it reads from the Data
layer. State imports from 5 Data layer files and 1 Utils file. No circular
dependencies: Data knows nothing about State.
