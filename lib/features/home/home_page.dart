import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import '../../shared/widgets/section_header.dart';
import '../goals/widgets/goal_card.dart';
import 'widgets/finished_book_row.dart';
import 'widgets/reading_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.books,
    required this.goal,
    required this.finishedCount,
    required this.onOpenBook,
    required this.onUpdateProgress,
    required this.onSeeLibrary,
    required this.onToggleTheme,
    super.key,
  });

  final List<Book> books;
  final int goal;
  final int finishedCount;
  final ValueChanged<Book> onOpenBook;
  final ValueChanged<Book> onUpdateProgress;
  final VoidCallback onSeeLibrary;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final reading = books.where((book) => book.status == BookStatus.reading).toList();
    final finished = books.where((book) => book.status == BookStatus.finished).toList();
    final progress = goal == 0
        ? 0.0
        : (finishedCount / goal).clamp(0.0, 1.0).toDouble();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SATURDAY, AUGUST 23',
                        style: AppTextStyles.eyebrow(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Good morning,\nreader.',
                        style: AppTextStyles.editorial(
                          context,
                          32,
                          height: 1.04,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: onToggleTheme,
                  icon: const Icon(Icons.wb_sunny_outlined),
                ),
                const SizedBox(width: 2),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Currently reading',
              actionLabel: 'See all',
              onAction: onSeeLibrary,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
          sliver: reading.isEmpty
              ? SliverToBoxAdapter(child: _EmptyReadingCard(onAdd: onSeeLibrary))
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 226,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 20),
                      itemCount: reading.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final book = reading[index];
                        return ReadingCard(
                          book: book,
                          onTap: () => onOpenBook(book),
                          onUpdate: () => onUpdateProgress(book),
                        );
                      },
                    ),
                  ),
                ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: GoalCard(
              progress: progress,
              count: finishedCount,
              goal: goal,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recently finished',
              actionLabel: 'Library',
              onAction: onSeeLibrary,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          sliver: finished.isEmpty
              ? SliverToBoxAdapter(
                  child: Text(
                    'Your finished books will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FinishedBookRow(
                        book: finished[index],
                        onTap: () => onOpenBook(finished[index]),
                      ),
                    ),
                    childCount: finished.length,
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyReadingCard extends StatelessWidget {
  const _EmptyReadingCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 34,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nothing on your nightstand yet',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a book to start your next chapter.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onAdd, child: const Text('Add')),
        ],
      ),
    );
  }
}
