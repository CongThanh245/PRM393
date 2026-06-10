import 'package:flutter/foundation.dart';

import '../models/author_stat.dart';
import '../models/dashboard_summary.dart';
import '../models/journal_stat.dart';
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

  ResearchStatus get status => _status;
  String get keyword => _keyword;
  String? get errorMessage => _errorMessage;
  List<Publication> get publications => _publications;

  List<TrendPoint> get trends =>
      AnalyticsCalculator.publicationTrends(_publications);
  List<JournalStat> get journals =>
      AnalyticsCalculator.topJournals(_publications);
  List<AuthorStat> get authors => AnalyticsCalculator.topAuthors(_publications);
  List<Publication> get influentialPapers =>
      AnalyticsCalculator.influentialPapers(_publications);
  DashboardSummary get summary => AnalyticsCalculator.summary(_publications);

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
    notifyListeners();

    try {
      final results = await _repository.search(nextKeyword);
      _publications = results;
      _status = results.isEmpty ? ResearchStatus.empty : ResearchStatus.success;
    } catch (error) {
      _status = ResearchStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
