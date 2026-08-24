import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.progress,
    required this.count,
    required this.goal,
    this.compact = false,
    super.key,
  });

  final double progress;
  final int count;
  final int goal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.all(compact ? 17 : 20),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 70 : 78,
            height: compact ? 70 : 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2026 reading goal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count of $goal books',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 19 : 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  progress >= 1
                      ? 'Goal complete - beautiful work.'
                      : '${goal - count} more to go this year',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
