import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/research_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/publication_card.dart';
import '../widgets/ranked_stat_list.dart';
import 'publication_detail_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResearchProvider>();
    if (provider.publications.isEmpty) {
      return const EmptyView(
        icon: Icons.leaderboard,
        title: 'No analytics yet',
        message: 'Search a topic first to rank venues, authors, and papers.',
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics: ${provider.keyword}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Journals'),
              Tab(text: 'Authors'),
              Tab(text: 'Papers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RankedStatList(
              title: 'Top journals and venues',
              items: provider.journals
                  .take(20)
                  .map((item) => RankedStatItem(
                        name: item.name,
                        count: item.publicationCount,
                      ))
                  .toList(),
            ),
            RankedStatList(
              title: 'Top contributing authors',
              items: provider.authors
                  .take(20)
                  .map((item) => RankedStatItem(
                        name: item.name,
                        count: item.publicationCount,
                      ))
                  .toList(),
            ),
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.influentialPapers.take(20).length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final paper = provider.influentialPapers[index];
                return PublicationCard(
                  publication: paper,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PublicationDetailScreen(publication: paper),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
