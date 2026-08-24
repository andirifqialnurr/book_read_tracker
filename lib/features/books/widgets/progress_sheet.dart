import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../domain/books/book.dart';
import '../../../domain/books/book_rules.dart';

Future<void> showProgressSheet({
  required BuildContext context,
  required Book book,
  required FutureOr<void> Function(Book book) onUpdate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _ProgressSheetContent(
      book: book,
      onUpdate: onUpdate,
    ),
  );
}

class _ProgressSheetContent extends StatefulWidget {
  const _ProgressSheetContent({
    required this.book,
    required this.onUpdate,
  });

  final Book book;
  final FutureOr<void> Function(Book book) onUpdate;

  @override
  State<_ProgressSheetContent> createState() => _ProgressSheetContentState();
}

class _ProgressSheetContentState extends State<_ProgressSheetContent> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.book.currentPage}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final raw = int.tryParse(_controller.text) ?? widget.book.currentPage;
    final page = BookRules.clampProgressPage(
      raw,
      totalPages: widget.book.totalPages,
    );
    await widget.onUpdate(widget.book.copyWith(currentPage: page));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxInset =
              constraints.maxHeight.isFinite ? constraints.maxHeight * .55 : 0.0;
          final bottomInset = keyboardInset.clamp(0.0, maxInset).toDouble();
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update progress',
                  style: AppTextStyles.editorial(context, 24),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Current page',
                    suffixText: widget.book.totalPages == null
                        ? null
                        : 'of ${widget.book.totalPages}',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: const Text('Save progress'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
