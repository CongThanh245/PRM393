import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/research_provider.dart';
import 'repositories/publication_repository.dart';
import 'services/openalex_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ResearchProvider(
        repository: PublicationRepository(service: OpenAlexService()),
      ),
      child: const JournalTrendAnalyzerApp(),
    ),
  );
}
