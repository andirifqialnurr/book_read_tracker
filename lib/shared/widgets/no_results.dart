import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class NoResults extends StatelessWidget {
  const NoResults({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 65),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'No books found',
              style: AppTextStyles.editorial(context, 21),
            ),
            const SizedBox(height: 5),
            Text(
              query.isEmpty ? 'Try a different filter.' : 'Nothing matched "$query".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
