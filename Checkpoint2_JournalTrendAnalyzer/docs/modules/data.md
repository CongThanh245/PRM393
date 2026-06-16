# Data Layer

> External API integration, repository abstraction, and domain models.

## Files

### `lib/services/openalex_service.dart`

**Summary:** HTTP client for the OpenAlex REST API. Handles authentication, field selection, retry logic, and error mapping.
**Complexity:** high | **Tags:** service, http, api, network

**Key classes:** `OpenAlexService`, `OpenAlexException`

**API request:**
```
GET https://api.openalex.org/works
  ?search=<keyword>
  &per-page=50
  &sort=cited_by_count:desc
  &select=id,doi,title,display_name,publication_year,cited_by_count,
          authorships,primary_location,abstract_inverted_index
  &api_key=<env:OPENALEX_API_KEY>
```

**Retry policy:** 3 attempts, exponential backoff (1s, 2s), retries on timeout + 429 + 5xx.

**Error mapping:**
| Status | Message |
|--------|---------|
| 400 | Request parameters rejected |
| 403 | Rate limit exceeded |
| 404 | Resource not found |
| 429 | Daily limit exceeded |
| 5xx | Service temporarily unavailable |
| timeout | Request timed out |

**Dependencies:**
- Imports: `http`, `flutter_dotenv`, `publication.dart`

---

### `lib/repositories/publication_repository.dart`

**Summary:** Thin adapter that decouples `ResearchProvider` from `OpenAlexService`. Provides `search(keyword)` as a clean interface.
**Complexity:** low | **Tags:** repository, data-access

**Dependencies:**
- Imports: `openalex_service.dart`, `publication.dart`
- Used by: `research_provider.dart`

---

### `lib/models/publication.dart`

**Summary:** Core domain model. Parses OpenAlex JSON with several normalization steps: HTML stripping, inverted-index abstract reconstruction, and author deduplication.
**Complexity:** medium | **Tags:** model, domain

**Fields:** `id`, `doi`, `title`, `publicationYear`, `citedByCount`, `authors`, `journalName`, `abstractText`

**Notable parsing quirks:**
- `display_name` may contain `<i>`, `<b>` tags — stripped via `replaceAll(RegExp(r'<[^>]*>'), '')`
- `abstract_inverted_index` is a `{word: [positions]}` map — delegated to `parseAbstractInvertedIndex()`
- Venue extracted from `primary_location.source.display_name` with fallback to legacy `host_venue.display_name`

**Dependencies:**
- Imports: `abstract_parser.dart`
- Used by: `openalex_service.dart`, `publication_repository.dart`, `research_provider.dart`, `analytics_calculator.dart`, `publication_card.dart`, `publication_detail_screen.dart`

---

### `lib/models/dashboard_summary.dart`

**Summary:** Immutable aggregate holding all KPI values for the dashboard screen: counts, averages, top items, and trend series.
**Complexity:** low | **Tags:** model, aggregate

**Fields:** `totalPublications`, `averageCitations`, `mostActiveYear`, `trends`, `topJournal`, `topAuthor`, `mostInfluentialPaper`

---

### `lib/models/trend_point.dart`

**Summary:** `{year: int, count: int}` value object used as x/y data for the trend line chart.
**Complexity:** low

---

### `lib/models/journal_stat.dart`

**Summary:** `{name: String, publicationCount: int}` value object for journal leaderboard rows.
**Complexity:** low

---

### `lib/models/author_stat.dart`

**Summary:** `{name: String, publicationCount: int}` value object for author leaderboard rows.
**Complexity:** low

## Layer Relationships

Data is downstream of nothing except external infrastructure (HTTP, `.env`). It is
imported by State (via repository), Utils (via models), and UI/Widgets (via models).
Data does not import from State or UI — this is the key boundary that keeps models testable.
