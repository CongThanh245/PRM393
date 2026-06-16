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
    final fmt = NumberFormat.decimalPattern();

    final metrics = [
      MetricTile(
        icon: Icons.article_outlined,
        label: 'Publications',
        value: fmt.format(summary.totalPublications),
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
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text('Dashboard · ${provider.keyword}'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (isWide) {
                  // Side-by-side: metrics grid (left) + chart (right)
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.0,
                              children: metrics,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: _TrendCard(summary: summary),
                      ),
                    ],
                  );
                }

                // Stacked: metric grid above chart
                final cols = constraints.maxWidth > 600 ? 3 : 2;
                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: cols == 3 ? 2.5 : 1.4,
                      children: metrics,
                    ),
                    const SizedBox(height: 16),
                    _TrendCard(summary: summary),
                  ],
                );
              },
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.summary});

  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.show_chart,
                    size: 16,
                    color: colorScheme.primary,
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
              height: 240,
              child: TrendChart(points: summary.trends),
            ),
          ],
        ),
      ),
    );
  }
}
