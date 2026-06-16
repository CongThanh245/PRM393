# State Layer

> Provider-based state management and business logic orchestration.

## Files

### `lib/providers/research_provider.dart`

**Summary:** The single source of truth for the entire app. A `ChangeNotifier` that manages the search lifecycle, year-range filtering, and exposes computed analytics via derived getters.
**Complexity:** medium | **Tags:** state, provider, business-logic

**Key class:** `ResearchProvider`
**Key enum:** `ResearchStatus { idle, loading, success, empty, error }`

**Public interface:**

| Member | Type | Description |
|--------|------|-------------|
| `status` | `ResearchStatus` | Current search lifecycle state |
| `keyword` | `String` | Last searched keyword |
| `publications` | `List<Publication>` | Raw results from OpenAlex (up to 100) |
| `errorMessage` | `String?` | Error detail when status is `error` |
| `yearFrom` | `int?` | Active year filter start (inclusive) |
| `yearTo` | `int?` | Active year filter end (inclusive) |
| `hasYearFilter` | `bool` | Whether any year filter is active |
| `filteredPublications` | `List<Publication>` | `publications` narrowed to `[yearFrom, yearTo]` |
| `trends` | `List<TrendPoint>` | Publications grouped by year (filtered) |
| `citationTrends` | `List<TrendPoint>` | Citations grouped by year (filtered) |
| `journals` | `List<JournalStat>` | Journals ranked by publication count |
| `authors` | `List<AuthorStat>` | Authors ranked by publication count |
| `influentialPapers` | `List<Publication>` | Sorted by citation count descending |
| `summary` | `DashboardSummary` | Aggregate of all KPI values |
| `topKeywords` | `List<KeywordStat>` | Concepts ranked by mention count |
| `topInstitutions` | `List<InstitutionStat>` | Institutions ranked by publication count |
| `topCountries` | `List<CountryStat>` | Countries ranked by publication count |
| `authorImpacts` | `List<AuthorImpact>` | Author output vs citation scatter data |
| `workTypes` | `List<MapEntry<String,int>>` | Work-type distribution (article, preprint, …) |
| `setYearRange(from, to)` | `void` | Updates year filter and notifies listeners |
| `search(keyword)` | `Future<void>` | Triggers a new search; resets year filter |

**All computed getters use `filteredPublications`**, so every chart and ranking automatically respects the active year filter without any extra wiring.

**Year filter reset:** `search()` always resets `_yearFrom = null` and `_yearTo = null` before fetching, so filters never carry across different search queries.

**State machine:**
```
idle → loading → success
              → empty
              → error → loading (retry)
```

**Dependencies:**
- Depends on: `PublicationRepository`, `AnalyticsCalculator`
- Uses models: `Publication`, `DashboardSummary`, `JournalStat`, `AuthorStat`, `TrendPoint`, `KeywordStat`, `InstitutionStat`, `CountryStat`, `AuthorImpact`
- Consumed by: `SearchScreen`, `DashboardScreen`, `TrendsScreen`, `AnalyticsScreen` via `context.watch<ResearchProvider>()`

## Layer Relationships

This is the central hub — every screen reads from it, and it reads from the Data
layer. State imports from 9 Data-layer model files and 1 Utils file (`AnalyticsCalculator`). No circular
dependencies: Data knows nothing about State.
