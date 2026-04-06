import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

@HiveType(typeId: 1)
class SavingsGoal {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double currentAmount;

  @HiveField(4)
  final DateTime deadline;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final bool isCompleted;

  SavingsGoal({
    String? id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.deadline,
    this.description,
    DateTime? createdAt,
    this.isCompleted = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get progressPercentage =>
      (currentAmount / targetAmount).clamp(0.0, 1.0);

  bool get isOnTrack {
    final daysRemaining = deadline.difference(DateTime.now()).inDays;
    final daysElapsed = DateTime.now().difference(createdAt).inDays;
    final totalDays = deadline.difference(createdAt).inDays;

    if (daysRemaining <= 0) return isCompleted;
    if (totalDays == 0) return false;

    final expectedProgress = 1 - (daysRemaining / totalDays);
    return progressPercentage >= expectedProgress;
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}