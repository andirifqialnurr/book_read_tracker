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
  final _focusNode = FocusNode();
  bool _isSaving = false;
  bool _isManualEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.book.currentPage}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  int get _currentPage {
    return int.tryParse(_controller.text) ?? widget.book.currentPage;
  }

  void _incrementPage() {
    final nextPage = BookRules.clampProgressPage(
      _currentPage + 1,
      totalPages: widget.book.totalPages,
    );
    setState(() => _controller.text = '$nextPage');
  }

  void _startManualEditing() {
    setState(() => _isManualEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final page = BookRules.clampProgressPage(
      _currentPage,
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
                _isManualEditing
                    ? TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Current page',
                          suffixText: widget.book.totalPages == null
                              ? null
                              : 'of ${widget.book.totalPages}',
                        ),
                      )
                    : _ProgressStepper(
                        currentPage: _currentPage,
                        totalPages: widget.book.totalPages,
                        onEdit: _startManualEditing,
                        onIncrement: _incrementPage,
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

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({
    required this.currentPage,
    required this.totalPages,
    required this.onEdit,
    required this.onIncrement,
  });

  final int currentPage;
  final int? totalPages;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: 'Edit current page',
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onEdit,
              child: Container(
                height: 66,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor ??
                      theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Text(
                      '$currentPage',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (totalPages != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'of $totalPages',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Add one page',
          child: SizedBox.square(
            dimension: 54,
            child: FilledButton(
              onPressed: onIncrement,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
