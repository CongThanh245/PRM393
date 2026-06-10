import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/research_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/publication_card.dart';
import 'publication_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController(text: 'Artificial Intelligence');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResearchProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Journal Trend Analyzer'),
          actions: [
            IconButton(
              tooltip: 'Search topic',
              onPressed: () => provider.search(_controller.text),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore publication trends',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search OpenAlex for scholarly works, then review trends, journals, authors, and influential papers.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Research topic search field',
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: provider.search,
                    decoration: InputDecoration(
                      labelText: 'Research topic',
                      hintText: 'Cybersecurity, data science, blockchain',
                      prefixIcon: const Icon(Icons.manage_search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear',
                        onPressed: _controller.clear,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.status == ResearchStatus.loading
                        ? null
                        : () => provider.search(_controller.text),
                    icon: const Icon(Icons.search),
                    label: const Text('Search OpenAlex'),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildResults(context, provider),
      ],
    );
  }

  Widget _buildResults(BuildContext context, ResearchProvider provider) {
    switch (provider.status) {
      case ResearchStatus.idle:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.travel_explore,
            title: 'Start with a topic',
            message: 'Enter a keyword to retrieve live OpenAlex publications.',
          ),
        );
      case ResearchStatus.loading:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: LoadingView(message: 'Fetching OpenAlex publications'),
        );
      case ResearchStatus.empty:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.search_off,
            title: 'No publications found',
            message: 'Try a broader topic or a different keyword.',
          ),
        );
      case ResearchStatus.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            message: provider.errorMessage ?? 'Something went wrong.',
            onRetry: () => provider.search(_controller.text),
          ),
        );
      case ResearchStatus.success:
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList.separated(
            itemCount: provider.publications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final publication = provider.publications[index];
              return PublicationCard(
                publication: publication,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PublicationDetailScreen(
                        publication: publication,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }
}
