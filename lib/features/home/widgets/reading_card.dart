import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../domain/books/book.dart';
import '../../books/widgets/book_cover.dart';

class ReadingCard extends StatelessWidget {
  const ReadingCard({
    required this.book,
    required this.onTap,
    required this.onUpdate,
    super.key,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final progress = book.progress ?? 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            BookCover(book: book, width: 100, height: 148),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.editorial(context, 19, height: 1.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${book.currentPage}/${book.totalPages}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(value: progress, minHeight: 7),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: OutlinedButton(onPressed: onUpdate, child: const Text('Update')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
