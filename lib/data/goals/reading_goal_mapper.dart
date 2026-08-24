import '../../domain/goals/reading_goal.dart';

class ReadingGoalMapper {
  const ReadingGoalMapper._();

  static ReadingGoal fromRow(Map<String, Object?> row) {
    return ReadingGoal(
      id: row['id'] as int,
      year: row['year'] as int,
      targetBooks: row['target_books'] as int,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
    );
  }

  static Map<String, Object?> toUpsertRow({
    required int year,
    required int targetBooks,
    DateTime? now,
  }) {
    final timestamp = (now ?? DateTime.now()).toUtc().toIso8601String();
    return {
      'year': year,
      'target_books': targetBooks,
      'created_at': timestamp,
      'updated_at': timestamp,
    };
  }
}
