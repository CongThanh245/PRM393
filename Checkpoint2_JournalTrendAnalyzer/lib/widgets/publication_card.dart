import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/publication.dart';

class PublicationCard extends StatelessWidget {
  const PublicationCard({
    required this.publication,
    required this.onTap,
    super.key,
  });

  final Publication publication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final citationText = NumberFormat.compact().format(publication.citedByCount);
    return Semantics(
      button: true,
      label: 'Open publication details',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publication.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      icon: Icons.calendar_today_outlined,
                      label: publication.publicationYear?.toString() ?? 'N/A',
                    ),
                    _Chip(
                      icon: Icons.format_quote,
                      label: '$citationText citations',
                    ),
                    _Chip(
                      icon: Icons.menu_book_outlined,
                      label: publication.journalName ?? 'Unknown venue',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
