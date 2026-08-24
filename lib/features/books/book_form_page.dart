import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import 'widgets/cover_picker.dart';

class BookFormPage extends StatefulWidget {
  const BookFormPage({
    required this.onCancel,
    required this.onSave,
    this.initialBook,
    super.key,
  });

  final VoidCallback onCancel;
  final ValueChanged<Book> onSave;
  final Book? initialBook;

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _pagesController;
  late final TextEditingController _yearController;
  late BookStatus _status;
  late String _genre;

  bool get _isEditing => widget.initialBook != null;

  @override
  void initState() {
    super.initState();
    final book = widget.initialBook;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _pagesController = TextEditingController(
      text: book?.totalPages == null ? '' : '${book!.totalPages}',
    );
    _yearController = TextEditingController();
    _status = book?.status ?? BookStatus.wantToRead;
    _genre = book?.genre ?? 'Fiction';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A title is required')),
      );
      return;
    }

    final existing = widget.initialBook;
    final colors = [
      [AppColors.coverIndigo, AppColors.coverIndigoAccent],
      [AppColors.coverTerracotta, AppColors.coverTerracottaAccent],
      [AppColors.coverGreen, AppColors.coverGreenAccent],
    ];
    final pair = colors[title.length % colors.length];
    final author = _authorController.text.trim().isEmpty
        ? 'Unknown author'
        : _authorController.text.trim();

    widget.onSave(
      Book(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: title,
        author: author,
        status: _status,
        currentPage: existing?.currentPage ?? 0,
        totalPages: int.tryParse(_pagesController.text.trim()),
        genre: _genre,
        rating: existing?.rating,
        review: existing?.review,
        startedAt: existing?.startedAt ??
            (_status == BookStatus.reading ? DateTime.now() : null),
        finishedAt: existing?.finishedAt,
        coverColor: existing?.coverColor ?? pair[0],
        coverAccent: existing?.coverAccent ?? pair[1],
        coverIcon: existing?.coverIcon ?? Icons.auto_stories_rounded,
      ),
    );

    if (!_isEditing) {
      _titleController.clear();
      _authorController.clear();
      _pagesController.clear();
      _yearController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit book' : 'Add a book',
                    style: AppTextStyles.editorial(context, 30),
                  ),
                ),
                TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: CoverPicker()),
                const SizedBox(height: 26),
                Text(
                  'Book details',
                  style: AppTextStyles.editorial(context, 21),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'What are you reading?',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _authorController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    hintText: 'Who wrote it?',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pagesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Page count'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Year'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  'Shelf details',
                  style: AppTextStyles.editorial(context, 21),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<BookStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: BookStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _status = value ?? _status),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _genre,
                  decoration: const InputDecoration(labelText: 'Genre'),
                  items: const [
                    'Fiction',
                    'Creativity',
                    'Productivity',
                    'Nature',
                    'Biography',
                    'Other',
                  ]
                      .map((genre) => DropdownMenuItem(value: genre, child: Text(genre)))
                      .toList(),
                  onChanged: (value) => setState(() => _genre = value ?? _genre),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(_isEditing ? 'Save changes' : 'Save to my shelf'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
