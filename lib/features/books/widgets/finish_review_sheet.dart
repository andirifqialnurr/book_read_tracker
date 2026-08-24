import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/books/book.dart';
import '../../../domain/books/book_status.dart';

Future<void> showFinishReviewSheet({
  required BuildContext context,
  required Book book,
  required FutureOr<void> Function(Book book) onUpdate,
}) async {
  final rating = ValueNotifier<double>(book.rating ?? 0);
  final reviewController = TextEditingController(text: book.review ?? '');
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.viewInsetsOf(sheetContext).bottom + 22,
      ),
      child: StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'A good one to remember.',
                style: AppTextStyles.editorial(context, 25),
              ),
              const SizedBox(height: 6),
              Text(
                'How did ${book.title} feel?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<double>(
                valueListenable: rating,
                builder: (_, value, __) => Row(
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      tooltip: 'Rate ${index + 1} stars',
                      onPressed: () {
                        rating.value = index + 1.0;
                        setSheetState(() {});
                      },
                      iconSize: 31,
                      color: index < value
                          ? AppColors.star
                          : Theme.of(context).dividerColor,
                      icon: Icon(
                        index < value
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Personal review',
                  hintText: 'A few words for future you...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await onUpdate(
                      book.copyWith(
                        status: BookStatus.finished,
                        rating: rating.value == 0 ? null : rating.value,
                        review: reviewController.text.trim().isEmpty
                            ? null
                            : reviewController.text.trim(),
                        finishedAt: DateTime.now(),
                      ),
                    );
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: const Text('Save as finished'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  rating.dispose();
  reviewController.dispose();
}
