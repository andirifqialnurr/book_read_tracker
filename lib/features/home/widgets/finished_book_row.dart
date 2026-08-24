import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../domain/books/book.dart';
import '../../books/widgets/book_cover.dart';

class FinishedBookRow extends StatelessWidget {
  const FinishedBookRow({
    required this.book,
    required this.onTap,
    super.key,
  });

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            BookCover(book: book, width: 48, height: 68),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      if (book.rating != null) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          book.rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        book.finishedAt == null
                            ? ''
                            : formatShelfDate(book.finishedAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
