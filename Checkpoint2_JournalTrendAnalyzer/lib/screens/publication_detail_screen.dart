import 'package:flutter/material.dart';

import '../models/publication.dart';

class PublicationDetailScreen extends StatelessWidget {
  const PublicationDetailScreen({required this.publication, super.key});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Publication Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            publication.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _MetaGrid(publication: publication),
          const SizedBox(height: 16),
          _Section(
            title: 'Authors',
            child: Text(
              publication.authors.isEmpty
                  ? 'Unknown authors'
                  : publication.authors.join(', '),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Abstract',
            child: Text(
              publication.abstractText ?? 'No abstract available from OpenAlex.',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Year', publication.publicationYear?.toString() ?? 'Unknown'),
      ('Citations', publication.citedByCount.toString()),
      ('Venue', publication.journalName ?? 'Unknown venue'),
      ('DOI', publication.doi ?? 'Not available'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 520 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: crossAxisCount == 1 ? 4.6 : 3.4,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$1,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
