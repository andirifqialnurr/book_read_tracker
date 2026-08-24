import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_formatters.dart';
import '../../domain/books/book.dart';
import '../../domain/books/book_status.dart';
import '../goals/widgets/goal_card.dart';
import '../goals/widgets/goal_editor_dialog.dart';
import 'widgets/books_per_month_chart.dart';
import 'widgets/stat_tile.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({
    required this.books,
    required this.goal,
    required this.finishedCount,
    required this.totalPages,
    required this.onGoalChanged,
    super.key,
  });

  final List<Book> books;
  final int goal;
  final int finishedCount;
  final int totalPages;
  final ValueChanged<int> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    final ratings = books
        .where((book) => book.rating != null)
        .map((book) => book.rating!)
        .toList();
    final average = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    final genres = <String, int>{};
    for (final book in books.where((book) => book.status == BookStatus.finished)) {
      genres[book.genre] = (genres[book.genre] ?? 0) + 1;
    }
    final favoriteGenre = genres.entries.isEmpty
        ? '-'
        : genres.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final values = List<double>.generate(8, (index) {
      final month = index + 1;
      return books.where((book) {
        return book.finishedAt?.year == DateTime.now().year &&
            book.finishedAt?.month == month;
      }).length.toDouble();
    });

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Reading stats',
                    style: AppTextStyles.editorial(context, 30),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit annual goal',
                  onPressed: () => showGoalEditorDialog(
                    context: context,
                    current: goal,
                    onChanged: onGoalChanged,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: GoalCard(
              progress: goal == 0
                  ? 0.0
                  : (finishedCount / goal).clamp(0.0, 1.0).toDouble(),
              count: finishedCount,
              goal: goal,
              compact: true,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatTile(
                value: '$finishedCount',
                label: 'Books finished',
                icon: Icons.check_circle_outline_rounded,
              ),
              StatTile(
                value: formatCompactNumber(totalPages),
                label: 'Pages read',
                icon: Icons.menu_book_rounded,
              ),
              StatTile(
                value: average == 0 ? '-' : average.toStringAsFixed(1),
                label: 'Average rating',
                icon: Icons.star_outline_rounded,
              ),
              StatTile(
                value: favoriteGenre,
                label: 'Favorite genre',
                icon: Icons.local_library_outlined,
                smallValue: true,
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Books per month',
              style: AppTextStyles.editorial(context, 21),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          sliver: SliverToBoxAdapter(
            child: BooksPerMonthChart(values: values),
          ),
        ),
      ],
    );
  }
}
