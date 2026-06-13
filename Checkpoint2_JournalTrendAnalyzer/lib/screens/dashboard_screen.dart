import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/research_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/metric_tile.dart';
import '../widgets/trend_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _colorPublications = Color(0xFF1E40AF);
  static const _colorCitations = Color(0xFFD97706);
  static const _colorYear = Color(0xFF059669);
  static const _colorVenue = Color(0xFF7C3AED);
  static const _colorAuthor = Color(0xFF2563EB);
  static const _colorPaper = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResearchProvider>();
    if (provider.publications.isEmpty) {
      return const EmptyView(
        icon: Icons.query_stats,
        title: 'No dashboard yet',
        message: 'Search a topic first to generate trend insights.',
      );
    }

    final summary = provider.summary;
    final numberFormat = NumberFormat.decimalPattern();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text('Dashboard: ${provider.keyword}'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isWide ? 2.5 : 1.4,
                    children: [
                      MetricTile(
                        icon: Icons.article_outlined,
                        label: 'Publications',
                        value: numberFormat.format(summary.totalPublications),
                        iconColor: _colorPublications,
                      ),
                      MetricTile(
                        icon: Icons.format_quote,
                        label: 'Avg citations',
                        value: summary.averageCitations.toStringAsFixed(1),
                        iconColor: _colorCitations,
                      ),
                      MetricTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Active year',
                        value: summary.mostActiveYear?.toString() ?? 'N/A',
                        iconColor: _colorYear,
                      ),
                      MetricTile(
                        icon: Icons.menu_book_outlined,
                        label: 'Top venue',
                        value: summary.topJournal?.name ?? 'N/A',
                        iconColor: _colorVenue,
                      ),
                      MetricTile(
                        icon: Icons.person_outline,
                        label: 'Top author',
                        value: summary.topAuthor?.name ?? 'N/A',
                        iconColor: _colorAuthor,
                      ),
                      MetricTile(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Top paper',
                        value: summary.mostInfluentialPaper?.title ?? 'N/A',
                        iconColor: _colorPaper,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _TrendCard(summary: summary),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.summary});

  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    size: 16,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Publication activity by year',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: TrendChart(points: summary.trends),
            ),
          ],
        ),
      ),
    );
  }
}
