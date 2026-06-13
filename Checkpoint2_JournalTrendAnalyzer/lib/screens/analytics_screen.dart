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

    final journals = provider.journals
        .take(20)
        .map((item) => RankedStatItem(name: item.name, count: item.publicationCount))
        .toList();
    final authors = provider.authors
        .take(20)
        .map((item) => RankedStatItem(name: item.name, count: item.publicationCount))
        .toList();
    final papers = provider.influentialPapers.take(20).toList();

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
              items: journals,
            ),
            RankedStatList(
              title: 'Top contributing authors',
              items: authors,
            ),
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: papers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final paper = papers[index];
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
