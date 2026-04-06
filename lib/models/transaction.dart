import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  transport,
  entertainment,
  utilities,
  shopping,
  health,
  education,
  other,
  salary,
  freelance,
  bonus,
}

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final TransactionCategory category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime createdAt;

  Transaction({
    String? id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Transaction.empty() {
    return Transaction(
      amount: 0,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now(),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}