import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_formatters.dart';
import '../goals/widgets/goal_card.dart';
import '../goals/widgets/goal_editor_dialog.dart';
import 'stats_providers.dart';
import 'widgets/books_per_month_chart.dart';
import 'widgets/stat_tile.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({
    required this.goal,
    required this.onGoalChanged,
    super.key,
  });

  final int goal;
  final ValueChanged<int> onGoalChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(readingStatsProvider);

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
                  : (stats.finishedThisYear / goal).clamp(0.0, 1.0).toDouble(),
              count: stats.finishedThisYear,
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
                value: '${stats.finishedThisYear}',
                label: 'Books finished',
                icon: Icons.check_circle_outline_rounded,
              ),
              StatTile(
                value: formatCompactNumber(stats.totalPages),
                label: 'Pages read',
                icon: Icons.menu_book_rounded,
              ),
              StatTile(
                value: stats.averageRating == 0
                    ? '-'
                    : stats.averageRating.toStringAsFixed(1),
                label: 'Average rating',
                icon: Icons.star_outline_rounded,
              ),
              StatTile(
                value: stats.favoriteGenre,
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
            child: BooksPerMonthChart(values: stats.booksPerMonth),
          ),
        ),
      ],
    );
  }
}
