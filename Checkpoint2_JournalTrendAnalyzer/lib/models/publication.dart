import '../utils/abstract_parser.dart';

class Publication {
  const Publication({
    required this.id,
    required this.title,
    required this.citedByCount,
    required this.authors,
    this.doi,
    this.publicationYear,
    this.journalName,
    this.abstractText,
  });

  final String id;
  final String? doi;
  final String title;
  final int? publicationYear;
  final int citedByCount;
  final List<String> authors;
  final String? journalName;
  final String? abstractText;

  factory Publication.fromJson(Map<String, dynamic> json) {
    final authorships = json['authorships'];
    final authors = authorships is List
        ? authorships
            .map((item) => item is Map<String, dynamic> ? item['author'] : null)
            .whereType<Map<String, dynamic>>()
            .map((author) => author['display_name'])
            .whereType<String>()
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
        : <String>[];

    return Publication(
      id: _stringValue(json['id']) ?? '',
      doi: _stringValue(json['doi']),
      title: _stringValue(json['display_name']) ??
          _stringValue(json['title']) ??
          'Untitled publication',
      publicationYear: _intValue(json['publication_year']),
      citedByCount: _intValue(json['cited_by_count']) ?? 0,
      authors: authors,
      journalName: _extractJournalName(json),
      abstractText: parseAbstractInvertedIndex(json['abstract_inverted_index']),
    );
  }

  static String? _extractJournalName(Map<String, dynamic> json) {
    final primaryLocation = json['primary_location'];
    if (primaryLocation is Map<String, dynamic>) {
      final source = primaryLocation['source'];
      if (source is Map<String, dynamic>) {
        final name = _stringValue(source['display_name']);
        if (name != null) return name;
      }
    }

    final hostVenue = json['host_venue'];
    if (hostVenue is Map<String, dynamic>) {
      return _stringValue(hostVenue['display_name']);
    }
    return null;
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
