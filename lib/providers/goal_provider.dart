import 'package:finance_app/models/goal.dart';
import 'package:finance_app/services/database_service.dart';
import 'package:flutter/foundation.dart';


class GoalProvider extends ChangeNotifier {
  List<SavingsGoal> _goals = [];

  List<SavingsGoal> get goals => _goals;

  List<SavingsGoal> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();

  List<SavingsGoal> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  SavingsGoal? get primaryGoal {
    final active = activeGoals;
    if (active.isEmpty) return null;
    return active.first;
  }

  double get totalSavingsTarget =>
      _goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

  double get totalSavesSoFar =>
      _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);

  GoalProvider() {
    loadGoals();
  }

  void loadGoals() {
    _goals = DatabaseService.getAllGoals();
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await DatabaseService.addGoal(goal);
    _goals.add(goal);
    _goals.sort((a, b) => a.deadline.compareTo(b.deadline));
    notifyListeners();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await DatabaseService.updateGoal(goal);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      _goals.sort((a, b) => a.deadline.compareTo(b.deadline));
    }
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await DatabaseService.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Future<void> updateGoalProgress(String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final updated = goal.copyWith(currentAmount: amount);
      await updateGoal(updated);
    }
  }

  Future<void> completeGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final updated = goal.copyWith(isCompleted: true);
      await updateGoal(updated);
    }
  }

  SavingsGoal? getGoalById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SavingsGoal> getOnTrackGoals() {
    return activeGoals.where((g) => g.isOnTrack).toList();
  }

  List<SavingsGoal> getOffTrackGoals() {
    return activeGoals.where((g) => !g.isOnTrack).toList();
  }
}