import '../models/publication.dart';
import '../services/openalex_service.dart';

class PublicationRepository {
  const PublicationRepository({required OpenAlexService service})
      : _service = service;

  final OpenAlexService _service;

  Future<List<Publication>> search(String keyword) {
    return _service.searchWorks(keyword);
  }
}
