import 'package:flutter/foundation.dart';

import '../models/author_impact.dart';
import '../models/author_stat.dart';
import '../models/country_stat.dart';
import '../models/dashboard_summary.dart';
import '../models/institution_stat.dart';
import '../models/journal_stat.dart';
import '../models/keyword_stat.dart';
import '../models/publication.dart';
import '../models/trend_point.dart';
import '../repositories/publication_repository.dart';
import '../utils/analytics_calculator.dart';

enum ResearchStatus { idle, loading, success, empty, error }

class ResearchProvider extends ChangeNotifier {
  ResearchProvider({required PublicationRepository repository})
      : _repository = repository;

  final PublicationRepository _repository;

  ResearchStatus _status = ResearchStatus.idle;
  String _keyword = '';
  String? _errorMessage;
  List<Publication> _publications = const [];
  int? _yearFrom;
  int? _yearTo;

  ResearchStatus get status => _status;
  String get keyword => _keyword;
  String? get errorMessage => _errorMessage;
  List<Publication> get publications => _publications;
  int? get yearFrom => _yearFrom;
  int? get yearTo => _yearTo;
  bool get hasYearFilter => _yearFrom != null || _yearTo != null;

  List<Publication> get filteredPublications {
    if (!hasYearFilter) return _publications;
    return _publications.where((p) {
      final y = p.publicationYear;
      if (y == null) return false;
      if (_yearFrom != null && y < _yearFrom!) return false;
      if (_yearTo != null && y > _yearTo!) return false;
      return true;
    }).toList();
  }

  void setYearRange(int? from, int? to) {
    _yearFrom = from;
    _yearTo = to;
    notifyListeners();
  }

  // ── Computed analytics (all respect year filter) ────────────────────────────
  List<TrendPoint> get trends =>
      AnalyticsCalculator.publicationTrends(filteredPublications);
  List<JournalStat> get journals =>
      AnalyticsCalculator.topJournals(filteredPublications);
  List<AuthorStat> get authors =>
      AnalyticsCalculator.topAuthors(filteredPublications);
  List<Publication> get influentialPapers =>
      AnalyticsCalculator.influentialPapers(filteredPublications);
  DashboardSummary get summary =>
      AnalyticsCalculator.summary(filteredPublications);
  List<TrendPoint> get citationTrends =>
      AnalyticsCalculator.citationTrends(filteredPublications);
  List<KeywordStat> get topKeywords =>
      AnalyticsCalculator.topKeywords(filteredPublications);
  List<InstitutionStat> get topInstitutions =>
      AnalyticsCalculator.topInstitutions(filteredPublications);
  List<CountryStat> get topCountries =>
      AnalyticsCalculator.topCountries(filteredPublications);
  List<AuthorImpact> get authorImpacts =>
      AnalyticsCalculator.authorImpact(filteredPublications);
  List<MapEntry<String, int>> get workTypes =>
      AnalyticsCalculator.workTypeDistribution(filteredPublications);

  // ── Search ──────────────────────────────────────────────────────────────────
  Future<void> search(String rawKeyword) async {
    final nextKeyword = rawKeyword.trim();
    if (nextKeyword.isEmpty) {
      _status = ResearchStatus.error;
      _errorMessage = 'Enter a research topic or keyword.';
      notifyListeners();
      return;
    }

    _keyword = nextKeyword;
    _status = ResearchStatus.loading;
    _errorMessage = null;
    _yearFrom = null;
    _yearTo = null;
    notifyListeners();

    try {
      final results = await _repository.search(nextKeyword);
      _publications = results;
      _status =
          results.isEmpty ? ResearchStatus.empty : ResearchStatus.success;
    } catch (error) {
      _status = ResearchStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
