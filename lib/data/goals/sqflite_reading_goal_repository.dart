import '../../core/database/app_database.dart';
import '../../domain/goals/reading_goal_repository.dart';
import 'reading_goal_dao.dart';

class SqfliteReadingGoalRepository extends ReadingGoalRepository {
  SqfliteReadingGoalRepository(this._appDatabase) : super(defaultGoal);

  static const defaultGoal = 24;

  final AppDatabase _appDatabase;

  @override
  Future<void> load() async {
    final db = await _appDatabase.instance;
    final year = DateTime.now().year;
    final dao = ReadingGoalDao(db);
    final row = await dao.getGoalByYear(year);
    if (row == null) {
      await dao.upsertGoal(year: year, targetBooks: defaultGoal);
      state = defaultGoal;
      return;
    }
    state = row['target_books'] as int;
  }

  @override
  Future<void> setGoal(int goal) async {
    final nextGoal = goal.clamp(1, 999).toInt();
    state = nextGoal;
    final db = await _appDatabase.instance;
    await ReadingGoalDao(db).upsertGoal(
      year: DateTime.now().year,
      targetBooks: nextGoal,
    );
  }
}
