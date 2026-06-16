# Utils Layer

> Pure computation helpers with no Flutter or network dependencies. Easy to unit test.

## Files

### `lib/utils/analytics_calculator.dart`

**Summary:** Static utility class that derives all analytics from a `List<Publication>`. No side effects, no state, no Flutter imports.
**Complexity:** medium | **Tags:** utils, analytics, computation

**Key class:** `AnalyticsCalculator` (static only — private constructor `._()`)

**Methods:**

| Method | Return | Algorithm |
|--------|--------|-----------|
| `publicationTrends(publications)` | `List<TrendPoint>` | Frequency map by year, sorted chronologically |
| `topJournals(publications)` | `List<JournalStat>` | Frequency map by venue name, sorted by count desc |
| `topAuthors(publications)` | `List<AuthorStat>` | Frequency map by author name, sorted by count desc |
| `influentialPapers(publications)` | `List<Publication>` | Sorted by `citedByCount` desc |
| `summary(publications)` | `DashboardSummary` | Calls all above, packages into aggregate |

**Extending analytics:** Add a new static method here, then expose it as a getter in `ResearchProvider`. No other changes required.

**Dependencies:**
- Imports: `publication.dart`, `dashboard_summary.dart`, `journal_stat.dart`, `author_stat.dart`, `trend_point.dart`
- Used by: `research_provider.dart`

---

### `lib/utils/abstract_parser.dart`

**Summary:** Top-level function `parseAbstractInvertedIndex()` that converts OpenAlex's inverted-index abstract format into a plain readable string.
**Complexity:** low | **Tags:** utils, parser

**Algorithm:**
1. Iterate `{word: [pos1, pos2, ...]}` entries
2. Build a `Map<int, String>` of position → word
3. Sort positions ascending
4. Join words with spaces

**Input:** `{"The": [0], "study": [1, 4], "of": [2], "quantum": [3]}` → `"The study of quantum study"`

**Dependencies:**
- Used by: `publication.dart` (called inside `fromJson`)

## Layer Relationships

Utils imports only from the Data models layer. It exports computation results back to
the State layer. No circular dependencies.
