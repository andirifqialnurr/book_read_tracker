import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatters.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import '../../shared/widgets/detail_section.dart';
import '../../shared/widgets/meta_row.dart';
import 'book_form_page.dart';
import 'book_providers.dart';
import 'widgets/book_cover.dart';
import 'widgets/finish_review_sheet.dart';
import 'widgets/progress_sheet.dart';

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({
    required this.bookId,
    super.key,
  });

  final int bookId;

  Future<void> _showProgress(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    await showProgressSheet(
      context: context,
      book: book,
      onUpdate: ref.read(bookDetailControllerProvider).updateBook,
    );
  }

  Future<void> _finishBook(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    await showFinishReviewSheet(
      context: context,
      book: book,
      onUpdate: ref.read(bookDetailControllerProvider).updateBook,
    );
  }

  Future<void> _editBook(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (editContext) => Scaffold(
          body: SafeArea(
            bottom: false,
            child: BookFormPage(
              initialBook: book,
              onCancel: () => Navigator.pop(editContext),
              onSave: (book) {
                ref.read(bookFormControllerProvider).updateBook(book);
                Navigator.pop(editContext);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete book', style: AppTextStyles.editorial(context, 22)),
        content: Text('Remove "${book.title}" from your shelf?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;
    ref.read(bookDetailControllerProvider).deleteBook(book.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookByIdProvider(bookId));
    if (book == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: const Center(child: Text('Book not found')),
      );
    }

    final progress = book.progress;
    final statusColor = book.status.color(Theme.of(context).brightness);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More actions',
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              if (value == 'edit') {
                _editBook(context, ref, book);
              } else if (value == 'delete') {
                _confirmDelete(context, ref, book);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit book')),
              PopupMenuItem(value: 'delete', child: Text('Delete book')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(book: book, width: 126, height: 188),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      book.status.label.toUpperCase(),
                      style: AppTextStyles.eyebrow(context, color: statusColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.title,
                      style: AppTextStyles.editorial(context, 25, height: 1.08),
                    ),
                    const SizedBox(height: 8),
                    Text(book.author, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Chip(label: Text(book.genre)),
                        if (book.totalPages != null)
                          Chip(label: Text('${book.totalPages} pages')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (progress != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading progress',
                  style: AppTextStyles.editorial(context, 20),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 10),
            ),
            const SizedBox(height: 8),
            Text(
              '${book.currentPage} of ${book.totalPages} pages',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showProgress(context, ref, book),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Update progress'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _finishBook(context, ref, book),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    book.status == BookStatus.finished
                        ? 'Edit review'
                        : 'Finish book',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          DetailSection(
            title: 'About this reading',
            child: Column(
              children: [
                if (book.startedAt != null)
                  MetaRow(
                    label: 'Started',
                    value: formatShelfDate(book.startedAt!),
                  ),
                if (book.finishedAt != null)
                  MetaRow(
                    label: 'Finished',
                    value: formatShelfDate(book.finishedAt!),
                  ),
                MetaRow(label: 'Shelf', value: book.status.label),
              ],
            ),
          ),
          if (book.rating != null || book.review != null) ...[
            const SizedBox(height: 26),
            DetailSection(
              title: 'Your review',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.star),
                        const SizedBox(width: 5),
                        Text(
                          '${book.rating!.toStringAsFixed(1)} / 5',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  if (book.review != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      book.review!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.55),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
