import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../data/goals/sqflite_reading_goal_repository.dart';
import '../../domain/goals/reading_goal_repository.dart';

class ReadingGoalController extends ReadingGoalRepository {
  ReadingGoalController() : super(24);

  @override
  Future<void> load() async {}

  @override
  Future<void> setGoal(int goal) async {
    state = goal.clamp(1, 999).toInt();
  }
}

final activeReadingGoalProvider =
    StateNotifierProvider<ReadingGoalRepository, int>(
  (ref) {
    final repository = SqfliteReadingGoalRepository(ref.watch(appDatabaseProvider));
    var disposed = false;
    ref.onDispose(() => disposed = true);
    Timer.run(() {
      if (!disposed) {
        unawaited(repository.load());
      }
    });
    return repository;
  },
);
