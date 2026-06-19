import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/research_provider.dart';
import '../utils/analytics_calculator.dart';
import 'dashboard_screen.dart';
import 'trends_screen.dart';

/// Hosts the Dashboard and Trends screens as two tabs of one page.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  void _exportCsv(BuildContext context, ResearchProvider provider) {
    final csv = AnalyticsCalculator.exportCsv(
      provider.filteredPublications,
      provider.keyword,
    );
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('CSV copied — ${provider.filteredPublications.length} papers'),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResearchProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Insights · ${provider.keyword}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Export CSV to clipboard',
              onPressed: provider.publications.isEmpty
                  ? null
                  : () => _exportCsv(context, provider),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined, size: 16), text: 'Dashboard'),
              Tab(icon: Icon(Icons.trending_up_outlined, size: 16), text: 'Trends'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardScreen(),
            TrendsScreen(),
          ],
        ),
      ),
    );
  }
}
