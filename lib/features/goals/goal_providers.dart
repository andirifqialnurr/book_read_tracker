import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingGoalController extends StateNotifier<int> {
  ReadingGoalController() : super(24);

  void setGoal(int goal) {
    state = goal.clamp(1, 999).toInt();
  }
}

final activeReadingGoalProvider =
    StateNotifierProvider<ReadingGoalController, int>(
  (ref) => ReadingGoalController(),
);
