import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ReadingGoalRepository extends StateNotifier<int> {
  ReadingGoalRepository(super.goal);

  Future<void> load();

  Future<void> setGoal(int goal);
}
