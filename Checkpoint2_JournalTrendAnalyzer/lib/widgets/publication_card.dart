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

  static Color _citationBg(int count) {
    if (count > 500) return const Color(0xFFFEF3C7);
    if (count > 50) return const Color(0xFFECFDF5);
    if (count > 5) return const Color(0xFFEFF6FF);
    return const Color(0xFFF1F5F9);
  }

  static Color _citationFg(int count) {
    if (count > 500) return const Color(0xFFB45309);
    if (count > 50) return const Color(0xFF047857);
    if (count > 5) return const Color(0xFF1D4ED8);
    return const Color(0xFF475569);
  }

  @override
  Widget build(BuildContext context) {
    final citationText = NumberFormat.compact().format(publication.citedByCount);
    final citBg = _citationBg(publication.citedByCount);
    final citFg = _citationFg(publication.citedByCount);

    return Semantics(
      button: true,
      label: 'Open publication details',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
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
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      icon: Icons.calendar_today_outlined,
                      label: publication.publicationYear?.toString() ?? 'N/A',
                      bgColor: const Color(0xFFEFF6FF),
                      fgColor: const Color(0xFF1D4ED8),
                    ),
                    _Chip(
                      icon: Icons.format_quote,
                      label: '$citationText citations',
                      bgColor: citBg,
                      fgColor: citFg,
                    ),
                    _Chip(
                      icon: Icons.menu_book_outlined,
                      label: publication.journalName ?? 'Unknown venue',
                      bgColor: const Color(0xFFF5F3FF),
                      fgColor: const Color(0xFF6D28D9),
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
  const _Chip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
