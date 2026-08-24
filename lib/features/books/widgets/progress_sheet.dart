import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../domain/books/book.dart';
import '../../../domain/books/book_rules.dart';

Future<void> showProgressSheet({
  required BuildContext context,
  required Book book,
  required ValueChanged<Book> onUpdate,
}) async {
  final controller = TextEditingController(text: '${book.currentPage}');
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update progress', style: AppTextStyles.editorial(context, 24)),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Current page',
              suffixText: book.totalPages == null ? null : 'of ${book.totalPages}',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final raw = int.tryParse(controller.text) ?? book.currentPage;
                final page = BookRules.clampProgressPage(
                  raw,
                  totalPages: book.totalPages,
                );
                onUpdate(book.copyWith(currentPage: page));
                Navigator.pop(sheetContext);
              },
              child: const Text('Save progress'),
            ),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
}
